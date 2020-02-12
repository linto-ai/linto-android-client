import 'dart:async';
import 'package:mic_stream/mic_stream.dart';

enum UtteranceStatus {
  thresholdReached,
  timeout,
  canceled
}

class MicrophoneInput {
  int _sampleRate = 16000;
  int _encoding = 16;

  bool _isListening = false;
  Stream<List<int>> _micStream;
  StreamSubscription<List<int>> _listener;

  MicrophoneInput(int sampleRate, int encoding){
    _sampleRate = sampleRate;
    _encoding = encoding;
  }

  bool get isListening{
    return _isListening;
  }

  void startListening(Function(List<int>) sinkFun) {
    if (!_isListening) {
      _micStream = microphone(sampleRate: _sampleRate, audioFormat: AudioFormat.ENCODING_PCM_16BIT);
      _listener = _micStream.listen((samples) => sinkFun(samples));
      _isListening = true;
      print("start");
    }
  }
  void stopListening() {
    if (_isListening) {
      _listener.cancel();
      _isListening = false;
      print("stop");
    }
  }
}

class AudioController {
  int _sampleRate = 16000;
  int _speechTh ;
  int _silenceTh;
  int _head;
  int _tail;
  MicrophoneInput _microphone;

  void detectUtterance(Function(List<int>, UtteranceStatus) utteranceCallback) {}
  void cancelUtterance(){}

  void startListening(){}
  void stopListening(){}



}