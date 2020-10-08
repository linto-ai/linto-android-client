import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
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

  static const int _SAMPLE_RATE = 16000;
  static const int _ENCODING = 2;

  static const int _N_PREV_FRAME = 15;
  static const int _N_FOLLOW_FRAME = 15;

  StreamSubscription<List<int>> audioSub;
  StreamController<List<int>> speechStream = StreamController<List<int>>();

  /// Frame size (sample), must be compatible with the vad engine.
  static const int _VAD_FRAME_LENGTH = 480;

  /// Signal buffer
  List<int> _signalBuffer = List<int>();

  /// Previous frames
  Queue<List<int>> _prevFrames = Queue<List<int>>();

  /// Following frames
  int _followToken = 0;

  /// Utterance buffer max size (second)
  static const int _BUFFER_MAX_LENGTH = 20;

  /// Utterance buffer
  List<int> _utteranceBuffer = List<int>(_SAMPLE_RATE * _BUFFER_MAX_LENGTH);
  int _currentUttBufferPos = 0;

  /// Utterance thresholds (n_frame * [_VAD_FRAME_LENGTH])
  static const int _SPEECH_TH = 7; // ~200ms non-consecutive speech
  static const int _SILENCE_TH = 35; // ~1050ms consecutive silence.
  static const int _TIMEOUT_TH = 133; // ~4s consecutive silence

  /// Utterance counters
  int _speechC = 0;
  int _silenceC = 0;

  /// State
  bool _utteranceDet = false;

  /// Defines if speechCallback shall be called on speech frames.
  bool _streamable = true;
  set streamable(bool v) {
    _streamable = v;
  }

  Utterance(Stream audioStream) {
    audioSub = audioStream.listen((frame) => onFrame(frame));
  }

  Function(List<int>, UtteranceStatus) _utteranceCallback;
  /// Set the callback function for utterance spotting.
  set utteranceCallback(Function(List<int>, UtteranceStatus) cbFun) {
    _utteranceCallback = cbFun;
  }

  /// Push [frame] into [_signalBuffer].
  /// If [_signalBuffer] reaches [_VAD_FRAME_LENGTH] detects speech.
  /// If it does detect speech, calls [speechCallback] function.
  ///
  /// If _uttDetection is true, detects utterance and calls [utteranceCallback] at the end of utterance.
  ///
  void onFrame(List<int> frame) async {
    _signalBuffer.addAll(frame);
    List<int> currentFrame;
    while(_signalBuffer.length >= _VAD_FRAME_LENGTH) {
       currentFrame = _signalBuffer.sublist(0, _VAD_FRAME_LENGTH);
       _signalBuffer = _signalBuffer.sublist(_VAD_FRAME_LENGTH);
       if (_utteranceDet) { // Add frame to utterance buffer
         _utteranceBuffer.setAll(_currentUttBufferPos, currentFrame);
         _currentUttBufferPos += currentFrame.length;
         print("Added ${currentFrame.length} -> $_currentUttBufferPos (${_signalBuffer.length})"); // DEBUG
         if (_currentUttBufferPos + _VAD_FRAME_LENGTH > _SAMPLE_RATE * _BUFFER_MAX_LENGTH) {
           _onUtteranceBufferFull();
         }
       }
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

  /// Callback on speech frame
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
      speechStream.add(frame);
    }
    _speechC += 1;
    _silenceC = 0;
  }

  /// Clear buffered signal
  void clear() {
    _followToken = 0;
    _prevFrames.clear();
  }

  /// Callback on silence frame
  void _onSilenceFrame(List<int> frame) {
    if (_streamable) {
      if (_followToken < _N_FOLLOW_FRAME) {
        _followToken += 1;
        speechStream.add(frame);
      } else {
        _addToFrameBuffer(frame);
      }
    }
    _silenceC += 1;
    if (_utteranceDet) {
      if (_silenceC >= _TIMEOUT_TH) {                                 // Timeout
        _onUtteranceTimeout();
        //print("Sp : $_speechC | Sil: $_silenceC | buffer size: $_currentUttBufferPos");
      } else if (_silenceC > _SILENCE_TH && _speechC > _SPEECH_TH) {  // Utterance complete
        _onUtteranceEnd();
      }
    }
  }

  /// Cache silence frame in a queue.
  void _addToFrameBuffer(List<int> frame) {
    _prevFrames.add(frame);
    if (_prevFrames.length > _N_PREV_FRAME) {
      _prevFrames.removeFirst();
    }
  }

  /// Starts detecting utterance.
  /// When utterance end is detected calls [callBack] with signal and status
  void detectUtterance(Function(List<int>, UtteranceStatus) callBack) {
    _currentUttBufferPos = 0;
    print("Start detecting utterance");
    _utteranceCallback = callBack;
    _silenceC = 0;
    _speechC = 0;
    _streamable = false;
    _utteranceDet = true;
  }

  /// Stops utterance detection
  void stopDetectUtterance() {
    _utteranceCallback = null;
    _streamable = true;
    _utteranceDet = false;
  }

  /// Cancels utterance detection
  void cancelDetUtterance() {
    _onUtteranceCanceled();
  }

  /// Called when [_utteranceBuffer] has reached full capacity.
  void _onUtteranceBufferFull() {
    print('UTTERANCE: buffer full');
    _utteranceCallback(_utteranceBuffer, UtteranceStatus.maxBufferLength);
    stopDetectUtterance();
  }
  /// Called at utterance end
  void _onUtteranceEnd() {
    print('UTTERANCE: threshold reached');
    print("Sp : $_speechC | Sil: $_silenceC | buffer size: $_currentUttBufferPos");
    _utteranceCallback(_utteranceBuffer.sublist(0, _currentUttBufferPos), UtteranceStatus.thresholdReached);
    stopDetectUtterance();
  }

  /// Called when [_silenceC] has reach [_TIMEOUT_TH] value
  void _onUtteranceTimeout() {
    print('UTTERANCE: timeout');
    _utteranceCallback(null, UtteranceStatus.timeout);
    stopDetectUtterance();
  }

  /// Called when [cancelDetUtterance] is invoked
  void _onUtteranceCanceled() {
    print('UTTERANCE: canceled');
    _utteranceCallback(null, UtteranceStatus.canceled);
    stopDetectUtterance();
  }
}