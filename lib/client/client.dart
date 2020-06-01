import 'package:mqtt_client/mqtt_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:linto_flutter_client/client/mqttClientWrapper.dart';

// MQTT client
// Refresh token


class LinTOClient {
  String _token;
  String _authServURI;
  String _login;
  String _password;
  String _mqttHost;
  String _mqttPort;
  String _mqttLogin;
  String _mqttPassword;

  bool _authentificated = false;

  MQTTClientWrapper mqttClient;

  Future<String> getLastUser() async {
    String content =  await rootBundle.loadString('assets/config/config.json');
    var data = json.decode(content);
    String lastlog = data['client']['last_login'];
    return lastlog;
  }

  Future<String> getLastServer() async {
    String content =  await rootBundle.loadString('assets/config/config.json');
    var data = json.decode(content);
    String lastlog = data['client']['last_server'];
    return lastlog;
  }
  /// Ask authentification API at [authServURI]
  /// Return Future<List> containing the success as a boolean and a error message if the authentification failed
  Future<List> requestAuthentification(String login, String password, String authServURI, bool testOveride) async {
    if (testOveride) {
      print("Auth override");
      _authentificated = true;
      return [true];
    }
    print("Sending auth request at $authServURI : $login *******");
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Accept': 'application/json' };
    var response;
     response = await http.post(authServURI,
          body: json.encode({'login': login, 'password': password}),
          headers: requestHeaders);

    if (response.statusCode == 200) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      var res = json.decode(response.body);
      _authServURI = authServURI;
      _login = login;
      _password = password;
      _mqttHost = res['mqtt_uri'];
      _mqttPort = res['mqtt_port'];
      _mqttLogin = res['mqtt_login'];
      _mqttPassword = res['mqtt_password'];
      _token = res['auth_token'];
      _authentificated = true;
      connectToBroker(_mqttHost, _mqttPort, _mqttLogin, _mqttPassword);
    } else if (response.statusCode == 404) {
      return [false, "Error 404"];
    } else if (response.statusCode == 403){
      var res = json.decode(response.body);
      return [false, "${response.statusCode} : ${res['error']}"];
    } else {
      return [false, "${response.statusCode} : authentification error"];
    }
    return [true];
    }

  void connectToBroker(String host, String port, String login, String password) {
    String topic = "/tolinto/$login";
    mqttClient = MQTTClientWrapper((msg) => print("Error : $msg"), (msg) => print("Message ! $msg"));
    mqttClient.setupClient(host, port, login, password, topic);
  }

  void sendMessage(Map<String, dynamic> message) {
    mqttClient.publish(message);
  }
}