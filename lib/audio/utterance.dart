import 'dart:typed_data';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum UtteranceStatus {
  thresholdReached,
  timeout,
  canceled,
  maxBufferLength
}
/// Class to detect speech and isolate vocal utterances.
class Utterance {
  static const platform = const MethodChannel("vader");

  static final int _SAMPLE_RATE = 16000;
  static final int _ENCODING = 2;

  static final int _N_PREV_FRAME = 10;
  static final int _N_FOLLOW_FRAME = 10;

  /// Frame size (sample), must be compatible with the vad engine.
  static final int _VAD_FRAME_LENGTH = 480;

  /// Signal buffer
  List<int> _signalBuffer = List<int>();

  /// Previous frames
  Queue<List<int>> _prevFrames = Queue<List<int>>();

  /// Following frames
  int _followToken = 0;

  /// Utterance buffer max size (second)
  static final int _BUFFER_MAX_LENGTH = 20;

  /// Utterance buffer
  List<int> _utteranceBuffer = List<int>(_SAMPLE_RATE * _BUFFER_MAX_LENGTH);
  /// Actual utterance buffer length (sample)
  int _bufferLength = 0;

  /// Utterance thresholds (n_frame * [_VAD_FRAME_LENGTH])
  final int _SPEECH_TH = 16; // ~500ms
  final int _SILENCE_TH = 23; // ~700ms
  final int _TIMEOUT_TH = 133; // ~4s

  /// Utterance counters
  int _speechC = 0;
  int _silenceC = 0;


  /// Defines if speechCallback shall be called on speech frames.
  bool _streamable = true;
  set streamable(bool v) {
    _streamable = v;
  }

  Function(List<int>) _speechCallback = (l) => print("Frame of length ${l.length} contains speech");
  /// Set the callback function called for voiced audio frames.
  set speechCallback(Function(List<int>) cbFun) {
    _speechCallback = cbFun;
  }

  Function(List<int>) _silenceCallback = (l) => print("Frame of length ${l.length} contains silence");
  /// Set the callback function called for voiced audio frames.
  set silenceCallback(Function(List<int>) cbFun) {
    _silenceCallback = cbFun;
  }

  Function(List<int>, UtteranceStatus) _utteranceCallback;
  /// Set the callback function for utterance spotting
  set utteranceCallback(Function(List<int>, UtteranceStatus) cbFun) {
    _utteranceCallback = cbFun;
  }

  /// Push [frame] into [_signalBuffer].
  /// If [_signalBuffer] reaches [_VAD_FRAME_LENGTH] detects speech.
  /// If it does, calls [speechCallback] function.
  ///
  /// If _uttDetection is true, detects utterance and calls [utteranceCallback] at the end of utterance.
  ///
  void onFrame(List<int> frame) async {
    // Get [_VAD_FRAME_LENGTH] while
    _signalBuffer.addAll(frame);
    List<int> currentFrame;
    while(_signalBuffer.length >= _VAD_FRAME_LENGTH) {
       currentFrame = _signalBuffer.sublist(0, _VAD_FRAME_LENGTH);
       _signalBuffer = _signalBuffer.sublist(_VAD_FRAME_LENGTH);
       _isSpeech(currentFrame);
    }
  }

  /// Detects if [frame] contains speech
  void _isSpeech(List<int> frame) async{
    assert (frame.length == _VAD_FRAME_LENGTH);
    Int16List int16list = Int16List.fromList(frame); // Tranform List<int32> to Int16List
    Uint8List frameBuffer = int16list.buffer.asUint8List(); // Transform List<int> to Uint8List
    bool result = await platform.invokeMethod('isSpeech', <String, dynamic>{'frame' : frameBuffer}); // Call plateform method
    if (result) {
      _onSpeechFrame(frame);
    } else {
      _onSilenceFrame(frame);
    }
  }

  void _onSpeechFrame(List<int> frame) {
    _followToken = 0;
    List<int> speechFrame = List<int>();
    if (_streamable) {
      if (_prevFrames.length > 0 ) {
        while (_prevFrames.length > 0 ) {
          speechFrame += _prevFrames.removeFirst();
        }
      }
      speechFrame += frame;
      _speechCallback(speechFrame);
    }
  }

  void clear() {
    _bufferLength = 0;
    _followToken = 0;
    _prevFrames.clear();
  }

  void _onSilenceFrame(List<int> frame) {
    if (_streamable) {
      if (_followToken < _N_FOLLOW_FRAME) {
        _followToken += 1;
        _speechCallback(frame);
      } else {
        _silenceCallback(frame);
        _addToFrameBuffer(frame);
      }
    }
  }

  void _addToFrameBuffer(List<int> frame) {
    _prevFrames.add(frame);
    if (_prevFrames.length > _N_PREV_FRAME) {
      _prevFrames.removeFirst();
    }
  }

  void detectUtterance(Function(List<int>, UtteranceStatus) callBack) {
    _utteranceCallback = callBack;
  }

  void _writeFile() async {
    //final directory = await getApplicationDocumentsDirectory();
    final directory = await getExternalStorageDirectory();
    print("Directory-> ${directory.path}");
    var file = File('${directory.path}/audio.pcm');
    file.writeAsBytes(_utteranceBuffer.sublist(0, _bufferLength).toList());
  }
}