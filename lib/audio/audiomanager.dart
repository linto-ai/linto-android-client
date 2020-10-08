import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'audioPlayer.dart';
import 'package:mfcc/mfcc.dart';
import 'microphone.dart';
import 'kws.dart';
import 'utterance.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';
import 'package:linto_flutter_client/audio/utils/wav.dart' show listIntToUintList;
import 'package:linto_flutter_client/audio/utils/wav.dart' show generateWavHeader, rawToWav;

const String CONFIG_FILE_PATH = "assets/config/config.json";

enum VoiceState {
  INIT,
  IDLE,
  LISTENING,
  REQUESTPENDING,
  SPEAKING,
  MUTED
}

/// Audio Manager manages audio inputs.
/// Sound is collected using the Microphone class and processed
/// frame by frame.
class AudioManager {
  /// Settings
  Map _settings;

  /// Audio recording state
  VoiceState currentState = VoiceState.INIT;

  /// True if input is recorded
  bool _inputRecorded = false;

  /// True if microphone input is active
  bool _isListening = true;

  /// True if utterance is recorded
  bool _isDetectingUtterance = false;

  /// True if audio is being recorded
  bool _isRecording;

  /// True if KWS is active
  bool _isDetecting = false;

  /// True if Manager is ready to operate
  bool _isReady = false;

  bool get isRecording {
    return _isRecording;
  }

  bool get isDetectingUtterance {
    return _isDetectingUtterance;
  }

  bool get isDetecting {
    return _isDetecting;
  }

  bool get isReady {
    return _isReady;
}

  /// Processing
  /// Feature extraction
  MFCC _mfcc;

  /// Audio input
  MicrophoneInput _microphone;
  StreamSubscription<List<int>> micStreamSub;

  /// Audio output
  StreamController<List<int>> audioStream = StreamController<List<int>>.broadcast();
  StreamController<List<double>> featureStream = StreamController<List<double>>();

  /// Keyword spotting
  KWS _kws;

  /// Voice activity and utterance detection
  Utterance _utterance;

  /// Audio player
  Audio _audio;

  /// Audio buffer for request
  List<double> signalBuffer = List<double>();

  /// File IO for recording
  File _currentWritingFile;
  IOSink _currentFileSink;

  /// UI CallBacks
  VoidCallback _onDetection = () => print('Unset onDetection Callback');
  VoidCallback _onReady = () => print('Unset onReady Callback');
  VoidCallback _onUtteranceStart = () => print('Unset onUtteranceStart Callback');
  SignalCallback _onUtteranceEnd = (signal) => print('Unset onUtteranceEnd Callback with signal length ${signal.length}');
  VoidCallback _onCanceled = () => print('Unset onCanceled Callback');

  AudioManager() : super();

  /// Reads audio settings from config file (json)
  Future<Map> _loadSettings() async {
    return jsonDecode(await rootBundle.loadString(CONFIG_FILE_PATH));
  }

  void initialize() async {
    _settings = await _loadSettings();
    print('config loaded');
    _microphone = MicrophoneInput(_settings['audio']['samplingRate'], _settings['audio']['encoding'], _settings['audio']['channels']);
    micStreamSub = _microphone.audioInputStream.stream.listen((frame) => _onAudioFrames(frame));
    _mfcc = MFCC(_settings['audio']['samplingRate'],
                 _settings['audio']['features']['nFFT'],
                 _settings['audio']['features']['numFilters'],
                 _settings['audio']['features']['numCoefs'],
                 energy: _settings['audio']['features']['energy'],
                 preEmphasis: _settings['audio']['features']['preEmp']);
    print('initialized');
    _kws = KWS(featureStream.stream);
    await _kws.loadModel('linto_tflite.tflite');
    _kws.onDetection = _onKWSpotted;
    _utterance = Utterance(audioStream.stream);
    _utterance.speechStream.stream.listen((frame) => _onSpeechFrame(frame));
    _audio = Audio();
    setVoiceState(VoiceState.IDLE);
    _microphone.startListening();
    _onReady();
  }

  /// Called on microphone audio frame
  void _onAudioFrames(List<num> frame) {
    audioStream.add(frame);
    if (_inputRecorded) {
      Uint8List signalBytes = listIntToUintList(frame);
      _currentFileSink.add(signalBytes);
    }
  }

  /// Called on speech frame
  /// Utterance (speech) -> _onSpeechFrame
  void _onSpeechFrame(List<num> signal) {
    if (_isDetecting) {
      var frames = signal.map((v) => v.toDouble()).toList();
      signalBuffer.addAll(frames);
      while (signalBuffer.length >= _settings['audio']['features']['windowLength']) {
        List<double> frame = signalBuffer.sublist(0,1024).toList();
        signalBuffer = signalBuffer.sublist(512).toList();
        featureStream.add(_mfcc.process_frame(frame));
      }
    }
  }

  /// Start utterance detection
  void detectUtterance() {
    _isDetectingUtterance = true;
    _onUtteranceStart();
    _utterance.detectUtterance(_onUtterance);
    setVoiceState(VoiceState.LISTENING);
  }

  /// Cancel utterance detection
  /// Utterance should call _OnUtterance with status canceled in return.
  void cancelUtterance() {
    if (_isDetectingUtterance) {
      _utterance.cancelDetUtterance();
    }
  }

  /// Utterance callback
  /// Utterance (utterance end) -> _onUtterance
  void _onUtterance(List<int> audioBuffer, UtteranceStatus status){
    switch (status) {
      case UtteranceStatus.thresholdReached : {
        _onUtteranceEnd(audioBuffer);
      }
      break;
      case UtteranceStatus.maxBufferLength: {
        _onUtteranceEnd(audioBuffer);
      }
      break;
      case UtteranceStatus.canceled: {
        _onCanceled();
      }
      break;
      case UtteranceStatus.timeout: {
        _onCanceled();
      }
      break;
    }
    _isDetectingUtterance = false;
  }

  /// Starts keyword spotting
  void startDetecting() {
    if (!_isDetecting) {
      _isDetecting = true;
    }
  }

  /// Suspends keyword spotting
  void stopDetecting() {
    if (_isDetecting) {
      _isDetecting = false;
    }
  }

  void _onKWSpotted(double confidence) {
    if (_isDetecting) {
      _kws.flushFeatures();
      stopDetecting();
      _onDetection();
      print("KEYWORD SPOTTED !! at $confidence");
    }
  }

  /// Triggers keyword.
  void triggerKeyword() async {
    _onKWSpotted(1.0);
  }

  /// Start audio recording.
  /// Returns the path of a temporary raw file.
  Future<String> startRecording() async {
    if (_inputRecorded) {
      stopRecording();
    }
    String filePath = await createTempFile();
    _currentWritingFile = File(filePath);
    _currentFileSink = _currentWritingFile.openWrite();
    _inputRecorded = true;
    return filePath;
  }

  /// Create a temporary file
  /// Creating a new file will overwrite the previous one.
  Future<String> createTempFile({String ext : "raw"}) async {
    Directory tempPath = await getTemporaryDirectory();
    return "${tempPath.path}/recording.$ext";
  }

  /// Pauses recording.
  void pauseRecording() {
    if (_inputRecorded) {
      _inputRecorded = false;
    }
  }

  /// Resumes recording.
  void resumeRecording() {
    if (!_inputRecorded) {
      _inputRecorded = true;
    }
  }

  ///Stops recording and create a temporary wave file in tmp folder.
  ///Return wave file path
  Future<String> stopRecording() async {
    if (_inputRecorded) {
      _inputRecorded = false;
      _currentFileSink.close();
      String filePath = await createTempFile(ext: "wav");
      rawToWav(_currentWritingFile.path, filePath);
      print("Recorder: File size: ${_currentWritingFile.lengthSync()}");
      print("Recorder: File written at: $filePath");
      return filePath;
    }
  }

  /// Get the path to a Document Directory File using [fileName].
  Future<String> getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  /// Callbacks setters
  void set onKeyWordSpotted(VoidCallback callback) {
    _onDetection = callback;
  }

  void set onReady(VoidCallback callback) {
    _onReady = callback;
  }

  void set onUtteranceStart(VoidCallback callback) {
    _onUtteranceStart = callback;
  }

  void set onUtteranceEnd(SignalCallback callback) {
    _onUtteranceEnd = callback;
  }

  void set onCanceled(VoidCallback callback) {
    _onCanceled = callback;
  }

  /// Change audiomanager state.
  void setVoiceState(VoiceState state) {
    currentState = state;
    print('Changing state to ${state.toString()}');
  }

  void dispose() {
    audioStream.close();
  }
}
