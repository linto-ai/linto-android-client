import 'package:linto_flutter_client/client/errors.dart';

typedef VoidCallback = void Function();
typedef MsgCallback = void Function(String msg);
typedef SignalCallback = void Function(List<int> signal);

class ClientErrorException implements Exception {
  ClientError error;
  ClientErrorException(String code) {
    error = ClientError(code : code);
  }
}
