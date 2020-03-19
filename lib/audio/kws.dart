
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/services.dart';

List<int> TEST_BUFFER = [38, 135, 118, 192, 161, 7, 143, 63, 19, 124, 13, 190, 177, 31, 83, 63, 212, 242, 174, 60, 242, 56, 165, 62, 11, 57, 195, 61, 73, 48, 164, 189, 129, 93, 8, 191, 25, 44, 221, 190, 122, 245, 206, 190, 57, 137, 199, 190, 243, 133, 185, 188, 20, 50, 162, 192, 194, 44, 8, 64, 80, 148, 150, 63, 130, 218, 203, 63, 215, 254, 213, 63, 125, 35, 141, 63, 92, 17, 243, 188, 82, 184, 164, 190, 206, 73, 25, 62, 189, 169, 47, 63, 143, 42, 234, 62, 192, 255, 234, 59, 102, 166, 198, 189, 55, 36, 147, 192, 32, 54, 198, 63, 241, 150, 15, 190, 44, 249, 191, 62, 172, 201, 168, 62, 218, 183, 3, 63, 212, 239, 176, 62, 179, 128, 198, 187, 23, 235, 89, 59, 67, 190, 84, 191, 172, 116, 217, 190, 195, 85, 146, 190, 64, 230, 180, 61, 33, 238, 138, 192, 215, 164, 88, 64, 66, 143, 200, 63, 210, 36, 143, 63, 6, 138, 153, 62, 151, 252, 81, 63, 164, 51, 69, 63, 220, 4, 220, 62, 71, 51, 193, 62, 90, 217, 99, 60, 81, 166, 221, 190, 159, 110, 21, 190, 140, 66, 139, 190, 175, 93, 164, 192, 207, 225, 202, 63, 9, 151, 8, 63, 144, 31, 186, 63, 89, 180, 120, 63, 69, 218, 164, 63, 237, 141, 151, 63, 58, 117, 30, 63, 117, 165, 3, 62, 194, 18, 103, 190, 64, 21, 242, 189, 244, 0, 255, 190, 23, 255, 107, 190, 207, 12, 143, 192, 42, 58, 253, 63, 53, 23, 177, 190, 240, 148, 29, 62, 206, 78, 85, 63, 100, 203, 111, 63, 248, 219, 55, 63, 238, 175, 143, 62, 100, 6, 56, 62, 246, 230, 198, 189, 34, 106, 70, 188, 64, 84, 172, 62, 223, 126, 135, 62, 151, 199, 151, 192, 136, 225, 46, 64, 82, 162, 136, 63, 106, 185, 160, 63, 88, 119, 161, 63, 11, 148, 197, 62, 212, 215, 219, 61, 229, 132, 67, 190, 183, 248, 197, 189, 66, 85, 28, 191, 107, 199, 159, 189, 240, 110, 136, 185, 244, 195, 57, 60, 230, 227, 148, 192, 59, 54, 58, 64, 113, 223, 168, 63, 89, 245, 160, 63, 116, 85, 98, 63, 235, 254, 136, 63, 88, 139, 112, 63, 235, 160, 255, 189, 161, 180, 245, 190, 20, 214, 245, 190, 31, 47, 64, 191, 6, 143, 140, 188, 72, 173, 36, 62, 94, 110, 160, 192, 155, 55, 14, 64, 144, 32, 122, 63, 112, 199, 44, 63, 247, 13, 177, 62, 83, 227, 115, 63, 40, 10, 92, 63, 196, 77, 28, 63, 42, 211, 205, 189, 199, 203, 29, 190, 204, 192, 43, 191, 142, 232, 159, 190, 193, 234, 82, 62, 39, 4, 190, 192, 70, 88, 136, 63, 186, 230, 165, 62, 44, 31, 170, 63, 183, 130, 179, 63, 243, 15, 179, 63, 127, 109, 250, 62, 243, 26, 95, 62, 179, 163, 249, 62, 33, 56, 46, 189, 220, 25, 95, 189, 41, 228, 62, 60, 81, 13, 244, 61, 122, 151, 181, 192, 108, 124, 2, 64, 152, 68, 3, 63, 183, 207, 144, 63, 159, 61, 95, 63, 2, 107, 232, 62, 31, 8, 112, 190, 142, 27, 44, 63, 196, 38, 173, 62, 196, 239, 185, 190, 47, 211, 215, 190, 178, 1, 194, 190, 31, 12, 177, 190, 51, 155, 217, 192, 100, 107, 7, 63, 248, 96, 104, 189, 68, 202, 56, 63, 104, 53, 9, 62, 15, 107, 110, 63, 224, 243, 56, 63, 13, 122, 129, 62, 222, 248, 209, 189, 190, 125, 157, 190, 242, 28, 241, 190, 119, 158, 23, 191, 139, 9, 10, 191, 101, 154, 60, 191, 180, 199, 106, 63, 214, 43, 213, 191, 177, 1, 125, 192, 223, 90, 114, 192, 76, 30, 130, 191, 172, 149, 137, 190, 245, 171, 24, 191, 117, 212, 108, 190, 102, 149, 9, 190, 61, 71, 139, 190, 206, 193, 23, 63, 37, 63, 12, 63, 123, 40, 181, 191, 86, 60, 4, 64, 82, 146, 255, 191, 180, 95, 179, 192, 215, 107, 35, 192, 123, 0, 200, 191, 176, 13, 69, 62, 118, 148, 251, 190, 184, 33, 150, 190, 1, 242, 43, 191, 236, 210, 83, 191, 33, 77, 100, 190, 229, 33, 155, 63, 90, 129, 20, 60, 175, 155, 69, 64, 229, 26, 94, 192, 69, 196, 166, 192, 35, 202, 182, 191, 149, 212, 9, 192, 1, 225, 24, 191, 102, 167, 62, 191, 222, 202, 153, 191, 187, 165, 98, 191, 84, 255, 207, 190, 74, 170, 32, 190, 69, 243, 105, 63, 118, 111, 224, 63, 177, 65, 47, 64, 39, 68, 106, 192, 87, 112, 130, 192, 0, 159, 44, 192, 16, 250, 213, 191, 246, 193, 97, 188, 77, 53, 112, 191, 196, 180, 206, 190, 170, 97, 109, 191, 131, 225, 252, 61, 186, 194, 161, 63, 211, 15, 172, 63, 132, 55, 223, 63, 205, 239, 124, 64, 51, 235, 12, 192, 121, 220, 62, 192, 161, 178, 24, 192, 141, 116, 162, 191, 34, 61, 14, 191, 12, 35, 37, 191, 123, 71, 75, 191, 94, 226, 133, 191, 211, 33, 56, 63, 23, 91, 155, 63, 227, 188, 184, 63, 194, 41, 109, 62, 5, 194, 34, 64, 112, 185, 172, 191, 96, 19, 198, 191, 17, 219, 211, 191, 252, 137, 138, 191, 150, 53, 56, 191, 225, 153, 58, 191, 98, 109, 125, 189, 230, 190, 233, 190, 158, 192, 67, 61, 193, 222, 26, 63, 167, 138, 82, 63, 209, 77, 200, 192, 237, 83, 134, 63, 246, 36, 8, 192, 93, 82, 20, 191, 28, 18, 192, 190, 96, 98, 9, 190, 105, 148, 81, 191, 82, 252, 64, 61, 78, 104, 130, 63, 88, 130, 36, 191, 252, 237, 155, 190, 172, 61, 200, 62, 173, 251, 206, 62, 128, 213, 28, 192, 140, 44, 5, 64, 57, 225, 100, 192, 233, 195, 39, 192, 49, 67, 58, 192, 25, 199, 165, 62, 213, 114, 156, 63, 240, 178, 66, 190, 177, 141, 2, 62, 128, 172, 125, 191, 75, 233, 230, 61, 83, 238, 146, 190, 57, 82, 168, 62, 9, 233, 4, 64, 64, 175, 63, 63, 97, 206, 110, 192, 68, 18, 48, 192, 245, 78, 177, 191, 165, 203, 8, 63, 160, 157, 64, 64, 232, 196, 184, 63, 4, 251, 143, 62, 195, 117, 180, 191, 12, 195, 143, 190, 79, 114, 4, 191, 163, 91, 111, 191, 248, 4, 220, 63, 195, 165, 201, 191, 126, 252, 165, 192, 249, 78, 31, 192, 48, 25, 113, 191, 232, 210, 214, 189, 140, 111, 199, 63, 6, 81, 136, 63, 215, 12, 8, 191, 129, 57, 66, 192, 2, 53, 150, 190, 226, 56, 159, 63, 106, 59, 92, 63, 34, 165, 133, 62, 225, 133, 5, 191, 236, 255, 160, 192, 27, 180, 87, 192, 137, 31, 175, 191, 244, 241, 11, 63, 155, 64, 176, 63, 243, 218, 152, 63, 20, 108, 78, 188, 6, 207, 215, 191, 211, 28, 104, 187, 182, 97, 202, 63, 98, 72, 169, 63, 3, 235, 247, 191, 244, 229, 92, 63, 178, 207, 86, 192, 24, 67, 15, 192, 50, 118, 16, 191, 143, 185, 35, 63, 28, 127, 224, 63, 138, 189, 164, 63, 252, 33, 105, 191, 246, 128, 236, 191, 55, 60, 99, 191, 140, 96, 65, 62, 176, 125, 19, 63, 22, 108, 145, 192, 254, 231, 38, 63, 202, 253, 151, 191, 215, 172, 202, 190, 96, 86, 95, 61, 139, 105, 74, 63, 112, 239, 78, 63, 182, 1, 229, 62, 10, 97, 4, 191, 22, 206, 199, 190, 174, 121, 191, 190, 224, 13, 7, 62, 70, 85, 0, 63, 176, 91, 202, 192, 122, 225, 175, 63, 40, 137, 136, 60, 198, 160, 24, 63, 86, 209, 42, 63, 125, 123, 179, 63, 168, 252, 210, 63, 207, 78, 142, 63, 23, 75, 199, 62, 223, 39, 24, 191, 222, 185, 201, 190, 195, 141, 199, 61, 213, 238, 23, 63, 21, 86, 43, 192, 17, 251, 254, 191, 58, 148, 62, 192, 36, 65, 73, 191, 23, 106, 164, 190, 198, 149, 0, 63, 222, 48, 111, 63, 253, 86, 203, 63, 86, 217, 219, 62, 212, 238, 192, 191, 111, 180, 142, 191, 80, 253, 73, 63, 161, 44, 0, 63, 27, 0, 140, 192, 27, 6, 172, 62, 222, 114, 46, 191, 212, 26, 109, 63, 76, 202, 129, 63, 23, 103, 82, 63, 159, 183, 40, 63, 204, 180, 32, 63, 160, 164, 105, 188, 145, 69, 75, 191, 160, 6, 57, 191, 177, 33, 160, 190, 181, 142, 70, 62, 76, 168, 159, 192, 255, 25, 142, 190, 145, 157, 115, 191, 189, 129, 153, 62, 173, 70, 248, 61, 146, 200, 219, 62, 118, 160, 148, 63, 40, 107, 151, 63, 15, 241, 249, 62, 49, 101, 146, 191, 148, 242, 196, 190, 208, 102, 33, 63, 7, 102, 2, 189, 21, 61, 172, 192, 230, 119, 135, 63, 157, 142, 108, 190, 211, 191, 40, 63, 150, 45, 132, 60, 214, 223, 194, 62, 194, 201, 148, 62, 160, 133, 77, 62, 175, 97, 154, 62, 109, 28, 224, 190, 3, 47, 62, 190, 45, 241, 57, 190, 79, 28, 148, 62];
Uint8List TEST_INPUT = Uint8List.fromList(TEST_BUFFER);

class KWS {
  static const platform = const MethodChannel('tf_lite');
  Uint8List _featureBuffer = Uint8List(1560);
  double _threshold = 0.4;
  Function(double) _callback = (v) => print('Detected at ' + v.toString());

  set onDetection(Function(double) cb) {
    _callback = cb;
  }

  Future<void> loadModel(String modelPath) async {
    var result = await platform.invokeMethod('loadModel', <String, dynamic>{'modelPath': modelPath});

  }

  Future<void> detect() async {
    var result = await platform.invokeMethod('detect', <String, dynamic>{'input' : _featureBuffer});
    if (result > _threshold) {
      _callback(result);
    }
  }

  void flushFeatures() {
    _featureBuffer = Uint8List(1560);
  }

  void pushFeatures(List<double> features) {
    Float32List float32Values = Float32List.fromList(features);
    Uint8List byteValues = float32Values.buffer.asUint8List();
    _featureBuffer = Uint8List.fromList(_featureBuffer.sublist(byteValues.length).toList() + byteValues.toList());

    detect();
  }

}