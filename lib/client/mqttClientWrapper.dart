import 'dart:convert';
import 'dart:typed_data';
import 'package:linto_flutter_client/logic/customtypes.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_buffers.dart' show Uint8Buffer;

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
  static const STATUS_TOPIC = "/status";
  MqttServerClient client;
  MQTTCurrentConnectionState connectionState = MQTTCurrentConnectionState.IDLE;
  MQTTSubscriptionState subscriptionState = MQTTSubscriptionState.IDLE;

  MsgCallback _onError;
  MQTTMessageCallback _onMessage = (topic, msg) => print("$topic : $msg");
  String _subTopic;
  String _pubTopic;
  bool _retainStatus = false;
  Map<String, dynamic> deviceInfo;

  set onMessage(MQTTMessageCallback cb) {
    _onMessage = cb;
  }

  set onError(MsgCallback cb) {
    _onError = cb;
  }

  MQTTClientWrapper(Function(String) onError, Function(String) onMessage) {
    _onError = onError;
  }

  Future<void> setupClient(String serverURI,
                           String serverPort,
                           String name,
                           String subscribingTopic,
                           String publishingTopic,
                           Map<String, dynamic> deviceInfos,
                           {bool usesLogin: false, String login : "", String password : "", bool retain = false}) async {
    this.deviceInfo = deviceInfos;
    _retainStatus = retain;
    client = MqttServerClient.withPort(serverURI, name, int.parse(serverPort));
      client.onDisconnected = _onDisconnect;
      client.onConnected = () => _onConnect();
      client.onSubscribed = _onSubscribe;
      _subTopic = subscribingTopic;
      _pubTopic = publishingTopic;
      final connMess = MqttConnectMessage()
        .withClientIdentifier(name)
        .keepAliveFor(60)
        .withWillTopic("$_pubTopic/status")
        .withWillMessage(jsonEncode({"connexion" : "offline", ...deviceInfos}))
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

      if(_retainStatus) {
        connMess.withWillRetain();
      }

      if (usesLogin) {
        connMess.authenticateAs(login, password);
      }
      client.connectionMessage = connMess;

      await _connectClient();
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

  void subscribeToTopic(String topicName) {
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

  void _onConnect() {
    connectionState = MQTTCurrentConnectionState.CONNECTED;
    print('MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    publish("$_pubTopic$STATUS_TOPIC", {"connexion": "online", ...deviceInfo}, retain: _retainStatus);
    subscribeToTopic("$_subTopic/#");
  }

  void _onSubscribe(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MQTTSubscriptionState.SUBSCRIBED;
  }

  void publish(String topic, Map<String, dynamic> payload, {bool retain: false,}) {
    if (connectionState != MQTTCurrentConnectionState.CONNECTED){
      print("Broker disconnected");
      return;
    }
    var payload_formated = jsonEncode(payload);
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(payload_formated);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload, retain: retain);
    print("Published on $topic.");
  }

  void publishRaw(String topic, Uint8List payload) {
    Uint8Buffer dataBuffer = Uint8Buffer();
    dataBuffer.addAll(payload);
    client.publishMessage(topic, MqttQos.atMostOnce, dataBuffer);
  }

  void disconnect() {
    publish("$_pubTopic$STATUS_TOPIC", {"connexion": "offline", ...deviceInfo}, retain: _retainStatus);
    client.disconnect();
  }
}