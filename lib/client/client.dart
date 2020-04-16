import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:http/http.dart' as http;

String _token;
// Authentification API rest
// MQTT client
// Refresh token


class LinTOClient {
  String _token;
  String _authServIP;
  int _authServPort;
  String _login;
  String _password;

  bool _authentificated = false;

  MqttServerClient mqttClient;

  Future<bool> requestAuthentification(String login, String password, String authServURI, bool testOveride) async {
    if (testOveride) {
      print("Auth override");
      _authentificated = true;
      return true;
    }
    print("Sending auth request at $authServURI : $login *******");
    var response = await http.post(authServURI, body : {'login' : login, 'password': password});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}