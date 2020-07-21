import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';

/// KeyWord Spotting interface with platform inference engine.
/// As for now, only can load LinTo models relying on the inputs parameters defined in the config file.
/// Expect features input using [pushFeatures].
class KWS {
  static const platform = const MethodChannel('tf_lite');
  bool isReady = false;
  Uint8List _featureBuffer = Uint8List(1560);
  double _threshold = 0.3;
  Function(double) _callback = (v) => print('Detected at ' + v.toString());

  set onDetection(Function(double) cb) {
    _callback = cb;
  }

  /// Loads the given [modelPath]. Should be called right after instantiation.
  /// Throws an exception if it cannot load the model.
  Future<void> loadModel(String modelPath) async {
    var result = await platform.invokeMethod('loadModel', <String, dynamic>{'modelPath': modelPath});
    if (!result) {
      throw Exception("Could not load the KWS model.");
    } else {
      isReady = true;
    }
  }

  /// Call the inference on the current feature buffer.
  Future<void> detect() async {
    if (isReady) {
      var result = await platform.invokeMethod('detect', <String, dynamic>{'input' : _featureBuffer});
      //print(result);
      if (result > _threshold) {
        _callback(result);
      }
    } else {
      throw Exception("Could not infere as model hasn't been loaded.");
    }
  }
  /// Empty the internal feature queue.
  void flushFeatures() {
    _featureBuffer = Uint8List(1560);
  }

  /// Add the [features] to the fixed size internal feature buffer queue then call [detect].
  void pushFeatures(List<double> features) {
    Float32List float32Values = Float32List.fromList(features);
    Uint8List byteValues = float32Values.buffer.asUint8List();
    _featureBuffer = Uint8List.fromList(_featureBuffer.sublist(byteValues.length).toList() + byteValues.toList());
    detect();
  }

}