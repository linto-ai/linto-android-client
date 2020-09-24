import 'package:linto_flutter_client/client/errors.dart';

typedef VoidCallback = void Function();
typedef MsgCallback = void Function(String msg);
typedef MQTTMessageCallback = void Function(String topic, String msg);
typedef SignalCallback = void Function(List<int> signal);
typedef BoolCallBack = void Function(bool value);
typedef PositionCallBack = void Function(Duration position);

class ClientErrorException implements Exception {
  ClientError error;
  ClientErrorException(String code) {
    error = ClientError(code : code);
  }
}

