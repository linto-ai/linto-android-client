import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:linto_flutter_client/client/mqttClientWrapper.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';
import 'package:linto_flutter_client/logic/userpref.dart';

enum AuthenticationStep{
  WELCOME,
  DIRECTCONNECT,
  SERVERSELECTION,
  CREDENTIALS,
  AUTHENTICATED,
  CONNECTED
}

class LinTOClient {

  final String APIROUTES = "/auths";
  final String APIAUTHSUFFIX = "/android/login";
  final String APILOGOUTSUFFIX = "/android/logout";
  final String APISCOPES = "/scopes";
  final String APIPREFIX = "/overwatch";

  final String MQTTINGRESS = '/tolinto';
  final String MQTTEGRESS = '/fromlinto';

  String _token;
  String _refreshToken;
  // TODO expiring time
  String _authServURI;

  String _login;
  String _password;
  String _mqttHost;
  String _mqttPort;
  String _mqttLogin;
  String _mqttPassword;
  bool _mqttUseLogin;
  String _subscribingTopic;
  String _publishingTopic;
  String _sessionID;

  List<ApplicationScope> scopes; // List available scopes
  ApplicationScope _selectedScope;

  List<dynamic>  _authRoutes;
  Map<String, dynamic> _authRoute;

  bool _authentificated = false;

  MQTTClientWrapper mqttClient;

  String get login {
    return _login;
  }

  String get server {
    return _authServURI;
  }

  ApplicationScope get currentScope {
    return _selectedScope;
  }

  bool get isConnected {
    return _authentificated;
  }

  Map<String, dynamic> get authRoute {
    return _authRoute;
  }

  String get brokerURL {
    return "$_mqttHost:$_mqttPort";
  }

  String get deviceID {
    return _sessionID;
  }

  set onMQTTMsg(MQTTMessageCallback cb) {
    mqttClient.onMessage = cb;
  }

  /// Retrieve last used login from config file
  Future<String> getLastUser() async {
    String content =  await rootBundle.loadString('assets/config/config.json');
    var data = json.decode(content);
    String lastlog = data['client']['last_login'];
    return lastlog;
  }
  /// Retrieve last used server from config file
  Future<String> getLastServer() async {
    String content =  await rootBundle.loadString('assets/config/config.json');
    var data = json.decode(content);
    String lastlog = data['client']['last_server'];
    return lastlog;
  }

  /// Ask server at [server] which authentication method are available.
  Future<List<dynamic>> requestRoutes(String server) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json'};
    var response;
    try {
      response = await http.get("$server$APIPREFIX$APIROUTES",
          headers: requestHeaders).timeout(Duration(seconds: 5));
    } on TimeoutException catch (_) {
      throw ClientErrorException('0x0009');
    } on SocketException catch (_) {
      throw ClientErrorException('0x0010');
    }
    switch(response.statusCode) {
      case 200: {
        _authServURI = server;
        var routes;
        try {
          routes = jsonDecode(utf8.decode(response.body.runes.toList()));
        } on Exception catch(_) {
          throw ClientErrorException('0x0007');
        }
        _authRoutes = routes;
        return routes;
      }
      break;

      case 401: {
        throw ClientErrorException('0x0002');
      }
      break;

      case 404: {
        throw ClientErrorException('0x0008');
      }
      break;

      default: {
        throw ClientErrorException('0xFFFF');
      }
      break;
    }
  }

  void setAuthRoute(Map<String, dynamic> route) {
    _authRoute = route;
  }
  
  /// Ask authentification API at [authServURI]
  /// Return Future<List> containing the success as a boolean and a error message if the authentification failed
  Future<bool> requestAuthentification(String login, String password) async {
    print("Sending auth request at $_authServURI$APIPREFIX${_authRoute['basePath']}$APIAUTHSUFFIX : $login *******");
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json'};
    var response;
    try {
      response = await http.post("$_authServURI$APIPREFIX${_authRoute['basePath']}$APIAUTHSUFFIX",
          headers: requestHeaders,
          body: jsonEncode({"email": login, "password" : password})).timeout(Duration(seconds: 5));
    } on TimeoutException catch (_) {
      throw ClientErrorException('0x0009');
    } on SocketException catch (_) {
      throw ClientErrorException('0x0010');
    }
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    switch(response.statusCode) {

      case 202: {
        try {
          print('Response status: ${response.statusCode}');

          var res = json.decode(response.body);

          var userInfo = res["user"];
          _sessionID = userInfo["session_id"];
          _token = userInfo["auth_token"];
          _refreshToken = userInfo["refresh_token"];
          _sessionID = userInfo["session_id"];
          var mqttInfo = res["mqtt"];
          _mqttHost = mqttInfo["mqtt_host"];
          _mqttPort = mqttInfo["mqtt_port"];
          _mqttLogin = mqttInfo["mqtt_login"];
          _mqttPassword = mqttInfo["mqtt_password"];
          _mqttUseLogin = mqttInfo["mqtt_use_login"];

        } on Exception catch (_) {
          throw ClientErrorException('0x0007');
        }
        _login = login;
        _password = password;
        return true;
      }
      break;

      case 401: {
        throw ClientErrorException('0x0002');
      }
      break;

      case 404: {
        throw ClientErrorException('0x0008');
      }
      break;

      default: {
        throw ClientErrorException('0xFFFF');
      }
      break;
    }
  }

  /// Request scopes from the server
  /// Should return an array or {topic, name, description}
  /// Throws [ClientErrorException] if an error is encountered.
  Future<List<ApplicationScope>> requestScopes() async {
    print("Requesting scopes from server ...");
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Accept': 'application/json', 'Authorization' : 'Android $_token'};
    var response;
    try {
      response = await http.get("$_authServURI$APIPREFIX${_authRoute['basePath']}$APISCOPES", headers: requestHeaders);
    } on TimeoutException catch (_) {
      throw ClientErrorException('0x0009');
    } on SocketException catch (_) {
      throw ClientErrorException('0x0010');
    }
    switch(response.statusCode) {
      case 200: {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        List<dynamic> res;
        try {
          res = json.decode(response.body);
          scopes = res.map((scope){return ApplicationScope(scope["topic"], scope["name"], scope["description"]);}).toList();
        } on Exception catch (_) {
          throw ClientErrorException('0x0007');
        }
        if (res.length == 0) {
          throw ClientErrorException('0x0011');
        }
        return scopes;
      }
      break;

      case 401: {
        print(response.body);
        throw ClientErrorException('0x0004');
      }
      break;

      case 404: {
        throw ClientErrorException('0x0008');
      }
      break;

      default: {
        throw ClientErrorException('0xFFFF');
      }
      break;
    }
  }

  Future<bool> setScope(ApplicationScope scope) async{
    _selectedScope = scope;
    _publishingTopic = "${scope.topic}$MQTTEGRESS/$_sessionID";
    _subscribingTopic = "${scope.topic}$MQTTINGRESS/$_sessionID";

    await connectToBroker();
    _authentificated =  mqttClient.connectionState == MQTTCurrentConnectionState.CONNECTED;

    return _authentificated;
  }

  Future<bool> changeScope(ApplicationScope scope) async {
    await mqttClient.disconnect();
    await setScope(scope);
  }

  Future<AuthenticationStep> reconnect(UserPreferences userPrefs) async {
    disconnect();
    return userPrefs.clientPreferences["auth_cred"] ? credentialReconnect(userPrefs) : directReconnect(userPrefs);
  }

  Future<AuthenticationStep> credentialReconnect(UserPreferences userPrefs) async {
    AuthenticationStep step = AuthenticationStep.SERVERSELECTION;
    var prefs = userPrefs.clientPreferences["credentials"];
    List<dynamic> routes;
    try {
      routes = await requestRoutes(prefs["last_server"]);
    } on ClientErrorException catch(error) {
      return step;
    }

    if (routes.map((e) => e['basePath']).contains(prefs["last_route"]['basePath'])){
      setAuthRoute(prefs["last_route"]);
      step = AuthenticationStep.CREDENTIALS;
    } else {
      return step;
    }

    try {
      await requestAuthentification(prefs["last_login"], userPrefs.passwordC);
    } on ClientErrorException catch(error) {
      return step;
    }

    var scopes;
    try {
      scopes = await requestScopes();
    } on ClientErrorException catch(error) {
      return step;
    }

    step = AuthenticationStep.AUTHENTICATED;

    if ( ! scopes.map((e) => e.topic).contains(prefs["last_scope"])){
      return step;
    }

    var success = await setScope(getScopeByTopic(prefs["last_scope"]));
    if (!success) {
      return step;
    }
    return AuthenticationStep.CONNECTED;
  }


  Future<AuthenticationStep> directReconnect(UserPreferences userPrefs) async {
    var prefs = userPrefs.clientPreferences["direct"];
    bool res = await directConnexion(prefs["broker_ip"], prefs["broker_port"], prefs["broker_id"], userPrefs.passwordM, prefs["serial_number"], prefs["scope"], true);
    if (res) {
      _selectedScope = prefs["scope"];
      _sessionID = prefs["serial_number"];
      return AuthenticationStep.CONNECTED;
    } else {
      return AuthenticationStep.DIRECTCONNECT;
    }
  }

  void connectToBroker() async {
    mqttClient = MQTTClientWrapper((msg) => print("Error : $msg"), (msg) => print("Message ! $msg"));
    await mqttClient.setupClient(_mqttHost, _mqttPort, _sessionID, _subscribingTopic, login : _mqttLogin , password: _mqttPassword, usesLogin: _mqttUseLogin);
  }

  void sendMessage(Map<String, dynamic> message, {String subTopic : ""}) {
    if (mqttClient.connectionState != MQTTCurrentConnectionState.CONNECTED) {
      print("Client MQTT disconnected disconnected, reconnecting...");
      //TODO
      return;
    }
    message['auth_token'] = "Android ${_token}";
    mqttClient.publish("$_publishingTopic$subTopic", message);
    print("Send message on $_publishingTopic$subTopic");
  }

  /// Direct connexion to the broker
  Future<bool> directConnexion(String broker, String port, String login, String password, String id, String scope, bool useLogin) async {
    _sessionID = id;
    _mqttUseLogin = useLogin;
    _mqttHost = broker;
    _mqttPort = port;
    _mqttPassword = password;
    _mqttLogin = login;
    _publishingTopic = "$scope$MQTTEGRESS/$id";
    _subscribingTopic = "$scope$MQTTINGRESS/$id";
    _selectedScope = ApplicationScope(scope, "Direct connexion", "Direct connexion");
    scopes = [_selectedScope];
    await this.connectToBroker();
    return mqttClient.connectionState == MQTTCurrentConnectionState.CONNECTED;
  }

  void requestNewToken() {
    //TODO
  }

  void disconnect() async {
    if (_authentificated) {
      Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Accept': 'application/json', 'Authorization' : 'Android $_token'};
      var response;
      try {
        response = await http.get("$_authServURI$APIPREFIX${_authRoute['basePath']}$APILOGOUTSUFFIX", headers: requestHeaders);
      } on TimeoutException catch (_) {
        print('Disconnect timeout');
      } on SocketException catch (_) {
        print('Disconnect didn\'t reach server.');
      }
      switch(response.statusCode) {
        case 200: {
          print('Disconnect response status: ${response.statusCode}');
        }
        break;
        default: {
          print('Disconnect response status: ${response.statusCode}');
        }
        break;
      }
      _authentificated = false;
      mqttClient.disconnect();
    }
  }
  ApplicationScope getScopeByTopic(String topic) {
    for (ApplicationScope scope in scopes) {
      if (scope.topic == topic) {
        return scope;
      }
    }
    return null;
  }
}

class ApplicationScope {
  final String topic;
  final String name;
  final String description;
  ApplicationScope(this.topic, this.name, this.description);
  Map<String, String> toMap() {
    return {"topic" : topic, "name" : name, "description" : description};
  }

  @override
  bool operator==(other) {
    return other.topic == this.topic;
  }

}