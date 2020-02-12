
import 'dart:typed_data';

import 'package:flutter/services.dart';


class KWS {
  static const platform = const MethodChannel('tf_lite');

  Future<void> loadModel(String modelPath) async {
    var result = await platform.invokeMethod('loadModel', <String, dynamic>{'modelPath': modelPath});
    print(result);
  }

  Future<void> detect() async {
    var input = Uint8List(1560);
    var result = await platform.invokeMethod('detect', <String, dynamic>{'input' : input});
    print(result);
  }
}