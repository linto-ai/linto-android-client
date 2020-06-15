import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:linto_flutter_client/client/mqttClientWrapper.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';

class LinTOClient {
  String _token;
  String _authServURI;
  String _selectedScope;
  String _login;
  String _password;
  String _mqttHost;
  String _mqttPort;
  String _subscribingTopic;
  String _publishingTopic;

  bool _authentificated = false;

  MQTTClientWrapper mqttClient;

  String get login {
    return _login;
  }

  String get server {
    return _authServURI;
  }

  String get currentScope {
    return _selectedScope;
  }

  bool get isConnected {
    return _authentificated;
  }

  set onMQTTMsg(MsgCallback cb) {
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
  
  /// Ask authentification API at [authServURI]
  /// Return Future<List> containing the success as a boolean and a error message if the authentification failed
  Future<bool> requestAuthentification(String login, String password, String authServURI) async {
    print("Sending auth request at $authServURI : $login *******");
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'authorization': 'Basic ' + base64Encode(utf8.encode('$login:$password'))};
    var response;
    try {
      response = await http.get("$authServURI/login",
          headers: requestHeaders).timeout(Duration(seconds: 5));
    } on TimeoutException catch (_) {
      throw ClientErrorException('0x0009');
    } on SocketException catch (_) {
      throw ClientErrorException('0x0010');
    }
    _authServURI = authServURI;
    switch(response.statusCode) {
      case 202: {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        var res = json.decode(response.body);
        _authServURI = authServURI;
        _login = login;
        _password = password;
        _token = res['token'];
        _mqttHost = res['host'];
        _mqttPort = res['port'];
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
  /// Throws [ClientErrorException] if an error is encountered.
  Future<Map<String, dynamic>> requestScopes() async {
    print("Requesting scopes from server ...");
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Accept': 'application/json', 'Authorization' : 'Bearer $_token'  };
    var response;
    try {
      response = await http.get("$_authServURI/scopes", headers: requestHeaders);
    } on TimeoutException catch (_) {
      throw ClientErrorException('0x0009');
    } on SocketException catch (_) {
      throw ClientErrorException('0x0010');
    }
    switch(response.statusCode) {
      case 200: {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        Map<String, dynamic> res = json.decode(response.body);
        if (! res.keys.contains('scopes')) {
          throw ClientErrorException('0x0007');
        }
        return res['scopes'];
      }
      break;

      case 401: {
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

  Future<bool> setScope(String scope) async{
    _selectedScope = scope;
    await connectToBroker();
    _authentificated =  mqttClient.connectionState == MQTTCurrentConnectionState.CONNECTED;
    return _authentificated;
  }

  void connectToBroker() async {
    String topic = "$_selectedScope/tolinto/$_login";
    mqttClient = MQTTClientWrapper((msg) => print("Error : $msg"), (msg) => print("Message ! $msg"));
    await mqttClient.setupClient(_mqttHost, _mqttPort, _login, topic);
  }

  void sendMessage(Map<String, dynamic> message) {
    mqttClient.publish(message);
  }
}