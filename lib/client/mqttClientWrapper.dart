import 'dart:convert';
import 'package:linto_flutter_client/logic/customtypes.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MQTTCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}

enum MQTTSubscriptionState {
  IDLE,
  SUBSCRIBED
}

class MQTTClientWrapper {
  MqttServerClient client;
  MQTTCurrentConnectionState connectionState = MQTTCurrentConnectionState.IDLE;
  MQTTSubscriptionState subscriptionState = MQTTSubscriptionState.IDLE;

  MsgCallback _onError;
  MQTTMessageCallback _onMessage = (topic, msg) => print("$topic : $msg");
  String _comTopic;

  set onMessage(MQTTMessageCallback cb) {
    _onMessage = cb;
  }

  set onError(MsgCallback cb) {
    _onError = cb;
  }

  MQTTClientWrapper(Function(String) onError, Function(String) onMessage) {
    _onError = onError;
  }

  Future<void> setupClient(String serverURI, String serverPort, String name, String topic,{bool usesLogin: false, String login : "", String password : ""}) async {
      client = MqttServerClient.withPort(serverURI, name, int.parse(serverPort));
      client.onDisconnected = _onDisconnect;
      client.onConnected = () => _onConnect("$topic/status");
      client.onSubscribed = _onSubscribe;
      _comTopic = topic;
      final connMess = MqttConnectMessage()
        .withClientIdentifier(name)
        .keepAliveFor(3600)
        .withWillTopic("$topic/status")
        .withWillMessage(jsonEncode({"connexion" : "offline"}))
        .startClean()
        .withWillRetain()
        .withWillQos(MqttQos.atLeastOnce);

      if (usesLogin) {
        connMess.authenticateAs(login, password);
      }
      client.connectionMessage = connMess;

      await _connectClient("$topic/status");
      if(connectionState == MQTTCurrentConnectionState.CONNECTED) {
        _subscribeToTopic("$topic/#");
      }
  }

  Future<void> _connectClient(String statusTopic) async {
      try {
          print('MQTTClientWrapper::Mosquitto client connecting....');
          connectionState = MQTTCurrentConnectionState.CONNECTING;
          await client.connect();
      } on Exception catch (e) {
          print('MQTTClientWrapper::client exception - $e');
          connectionState = MQTTCurrentConnectionState.ERROR_WHEN_CONNECTING;
          client.disconnect();
      }
      if (client.connectionStatus.state == MqttConnectionState.connected) {
          connectionState = MQTTCurrentConnectionState.CONNECTED;
          publish(statusTopic, {"connexion" : "online"}, retain: true);
          print('MQTTClientWrapper::Mosquitto client connected');
      } else {
        print('MQTTClientWrapper::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
        connectionState = MQTTCurrentConnectionState.ERROR_WHEN_CONNECTING;
        client.disconnect();
      }
  }

  void _subscribeToTopic(String topicName) {
    print('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String payload =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final String topic = recMess.variableHeader.topicName;
      print("MQTTClientWrapper::GOT A NEW MESSAGE $payload");
      _onMessage(topic, payload);
    });

  }

  void _onDisconnect() {
    print('MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
      print('MQTTClientWrapper::OnDisconnected callback is solicited, this is correct');
    }
    connectionState = MQTTCurrentConnectionState.DISCONNECTED;
  }

  void _reconnect() async {
    while (connectionState != MQTTCurrentConnectionState.CONNECTED) {
      print("Try to reconnect to broker.");
      await _connectClient("$_comTopic/status");

    }
  }

  void _onConnect(String topic) {
    connectionState = MQTTCurrentConnectionState.CONNECTED;
    print('MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
  }

  void _onSubscribe(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MQTTSubscriptionState.SUBSCRIBED;
  }

  void publish(String topic, Map<String, dynamic> payload, {bool retain: false,}) {
    if (connectionState != MQTTCurrentConnectionState.CONNECTED) return;
    var payload_formated = jsonEncode(payload);
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(payload_formated);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload, retain: retain);
  }

  void disconnect() {
    client.disconnect();
  }
}