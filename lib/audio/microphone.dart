import 'dart:async';
import 'package:mic_stream/mic_stream.dart';


class MicrophoneInput {
  int _sampleRate;
  int _encoding;
  int _channels;

  //flags
  bool _isListening = false;

  Stream<List<int>> _micStream;
  StreamSubscription<List<int>> _listener;
  StreamController<List<int>> audioInputStream;

  Function(List<num>) _frameSink;

    bool get isListening{
    return _isListening;
  }

  MicrophoneInput(int sampleRate, int encoding, int channels) {
    _sampleRate = sampleRate;
    _channels = channels;
    audioInputStream = StreamController<List<int>>();
  }

  void startListening() {
    if (!_isListening) {
      _micStream = microphone(sampleRate: _sampleRate, audioFormat: AudioFormat.ENCODING_PCM_16BIT, audioSource: AudioSource.MIC);
      _listener = _micStream.listen((samples) => audioInputStream.add(samples));
      _isListening = true;
    }
  }
  void stopListening() {
    if (_isListening) {
      _listener.cancel();
      _isListening = false;
    }
  }
}