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

  Function(String) _onError;
  Function(String) _onMessage = (message) => print(message);

  MQTTClientWrapper(Function(String) onError, Function(String) onMessage) {
    _onError = onError;
  }

  void setupClient(String serverURI, String serverPort, String serverLogin, String serverPassword, String topic) async {
      client = MqttServerClient.withPort(serverURI, serverLogin, int.parse(serverPort));
      client.logging(on: false);
      client.keepAlivePeriod = 20;
      client.onDisconnected = _onDisconnect;
      client.onConnected = _onConnect;
      client.onSubscribed = _onSubscribe;
      await _connectClient();
      if(connectionState == MQTTCurrentConnectionState.CONNECTED) {
        _subscribeToTopic(topic);
      }
  }

  Future<void> _connectClient() async {
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
      print("MQTTClientWrapper::GOT A NEW MESSAGE $payload");
      _onMessage(payload);
    });

  }

  void _onDisconnect() {
    print('MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
      print('MQTTClientWrapper::OnDisconnected callback is solicited, this is correct');
    }
    connectionState = MQTTCurrentConnectionState.DISCONNECTED;
  }

  void _onConnect() {
    connectionState = MQTTCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
  }

  void _onSubscribe(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MQTTSubscriptionState.SUBSCRIBED;
  }
}