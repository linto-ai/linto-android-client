import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:linto_flutter_client/client/mqttClientWrapper.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';
import 'package:linto_flutter_client/logic/userpref.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';

enum AuthenticationStep{
  WELCOME,
  DIRECTCONNECT,
  SERVERSELECTION,
  CREDENTIALS,
  AUTHENTICATED,
  CONNECTED
}

class LinTOClient {
  static const String CLIENT_VERSION = "0.2.2";

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

  bool _authenticated = false;

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
    return _authenticated;
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

  String get version {
    return LinTOClient.CLIENT_VERSION;
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
    } on Exception catch (_) {
      throw ClientErrorException('0xFFFF');
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
          scopes = res.map((scope){return ApplicationScope(scope["topic"], scope["name"] ?? "No name.", scope["description"] ?? "No description");}).toList();
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

  Future<bool> setScope(ApplicationScope scope) async {
    _selectedScope = scope;
    _publishingTopic = "${scope.topic}$MQTTEGRESS/$_sessionID";
    _subscribingTopic = "${scope.topic}$MQTTINGRESS/$_sessionID";

    await connectToBroker();
    _authenticated =  mqttClient.connectionState == MQTTCurrentConnectionState.CONNECTED;
    return _authenticated;
  }

  Future<bool> changeScope(ApplicationScope scope) async {
    await mqttClient.disconnect();
    await setScope(scope);
  }

  Future<AuthenticationStep> reconnect(UserPreferences userPrefs) async {
    disconnect();
    return userPrefs.getBool("auth_cred") ? credentialReconnect(userPrefs) : directReconnect(userPrefs);
  }

  Future<AuthenticationStep> credentialReconnect(UserPreferences userPrefs) async {
    AuthenticationStep step = AuthenticationStep.SERVERSELECTION;
    List<dynamic> routes;
    try {
      routes = await requestRoutes(userPrefs.getString("cred_server"));
    } on ClientErrorException catch(_) {
      return step;
    }

    for (Map<String, dynamic> route in routes) {
      if(route['basePath'] == userPrefs.getString("cred_route")) {
        setAuthRoute(route);
        step = AuthenticationStep.CREDENTIALS;
      }
    }
    if (step == AuthenticationStep.SERVERSELECTION) return step;

    try {
      await requestAuthentification(userPrefs.getString("cred_login"), userPrefs.passwordC);
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

    if ( ! scopes.map((e) => e.topic).contains(userPrefs.getString("cred_app"))){
      return step;
    }

    var success = await setScope(getScopeByTopic(userPrefs.getString("cred_app")));
    if (!success) {
      return step;
    }
    return AuthenticationStep.CONNECTED;
  }

  Future<AuthenticationStep> directReconnect(UserPreferences userPrefs) async {
    bool res = await directConnexion(userPrefs.getString("direct_ip"),
                                     userPrefs.getString("direct_port"),
                                     userPrefs.getString("direct_id"),
                                     userPrefs.passwordM,
                                     userPrefs.getString("direct_sn"),
                                     userPrefs.getString("direct_app"), true);
    if (res) {
      return AuthenticationStep.CONNECTED;
    } else {
      return AuthenticationStep.DIRECTCONNECT;
    }
  }

  void connectToBroker({bool directConnexion = false}) async {
    mqttClient = MQTTClientWrapper((msg) => print("Error : $msg"), (msg) => print("Message ! $msg"));
    Map<String, dynamic> deviceInfos = await getDeviceInfo();
    await mqttClient.setupClient(_mqttHost,
                                 _mqttPort,
                                 _sessionID,
                                 _subscribingTopic,
                                 _publishingTopic,
                                 deviceInfos,
                                 login : _mqttLogin ,
                                 password: _mqttPassword,
                                 usesLogin: _mqttUseLogin,
                                 retain: directConnexion);
  }

  void sendMessage(Map<String, dynamic> message, {String subTopic : ""}) {
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
    await this.connectToBroker(directConnexion: true);
    _authenticated = mqttClient.connectionState == MQTTCurrentConnectionState.CONNECTED;
    return _authenticated;
  }

  void requestNewToken() {
    //TODO
  }

  void disconnect() async {
    if (_authenticated) {
      Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Accept': 'application/json', 'Authorization' : 'Android $_token'};
      if(_authRoute != null) {
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
      }
      _authenticated = false;
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

  void pong() {
    sendMessage(Map<String, dynamic>(), subTopic: "/pong");
  }


  /// Returns device's informations
  Future<Map<String, dynamic>> getDeviceInfo() async {
    WifiInfoWrapper wifiObject;
    Map<String, dynamic> ret = Map<String, dynamic>();
    ret["config"] = Map<String, dynamic>();
    ret["config"]["network"] = List<Map<String, String>>();
    ret["config"]["firmware"] = CLIENT_VERSION;
    try {
      wifiObject = await WifiInfoPlugin.wifiDetails;
    } on Exception catch(_) {
      return ret;
    }
    var network = Map<String, String>();
    network["mac_address"] = wifiObject.macAddress;
    network["gateway_ip"] = wifiObject.routerIp;
    network["type"] = wifiObject.connectionType;
    network["ip_address"] = wifiObject.ipAddress;
    network["name"] = "android";
    ret["config"]["network"].add(network);
    return ret;
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