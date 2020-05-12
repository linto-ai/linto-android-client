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

final String CONFIG_FILE_PATH = "assets/config/config.json";

class AudioManager {
  // Settings
  Map _settings;

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

  // Debug
  Function(String) debugPromptFun;

  // Processing
  MFCC _mfcc;
  MicrophoneInput _microphone;
  KWS _kws;
  Utterance _utterance;
  Audio _audio;

  //Buffer
  List<double> signalBuffer = List<double>();

  File _currentWritingFile;

  // UI CallBacks
  VoidCallback _onDetection = () => print('Unset onDetection Callback');
  VoidCallback _onReady = () => print('Unset onReady Callback');
  VoidCallback _onUtteranceStart = () => print('Unset onUtteranceStart Callback');
  VoidCallback _onUtteranceEnd = () => print('Unset onUtteranceEnd Callback');
  VoidCallback _onCanceled = () => print('Unset onCanceled Callback');

  // Client callback
  SignalCallback _onCommand = (file) => print('Unset onCommand Callback');

  AudioManager() :super();

  void initialize() async {
    _settings = await _loadSettings();
    print('config loaded');
    _microphone = MicrophoneInput(_settings['audio']['samplingRate'], _settings['audio']['encoding'], _settings['audio']['channels']);
    _microphone.frameSink = _onAudioFrames;
    _mfcc = MFCC(_settings['audio']['samplingRate'], _settings['audio']['features']['nFFT'], _settings['audio']['features']['numFilters'], _settings['audio']['features']['numCoefs'], energy: false);
    print('initialized');
    _kws = KWS();
    await _kws.loadModel('linto_tflite.tflite');
    _kws.onDetection = _onKWSpotted;
    _utterance = Utterance();
    _utterance.speechCallback =_onSpeechFrame;
    _utterance.silenceCallback = _onSilenceFrame;
    _audio = Audio();
    _onReady();
  }

  // Callback functions
  void _onAudioFrames(List<num> signal) {
    _utterance.onFrame(signal);
    //Stopwatch stopwatch = new Stopwatch()..start();
    //print('$i mfcc extracted in ${stopwatch.elapsed.inMilliseconds} ms');
  }

  void _onSilenceFrame(List<int> frame) {
  }

  void _onSpeechFrame(List<num> signal) {
    if (_isDetecting) {
      var frames = signal.map((v) => v.toDouble()).toList();
      signalBuffer.addAll(frames);
      while (signalBuffer.length >= _settings['audio']['features']['windowLength']) {
        List<double> frame = signalBuffer.sublist(0,1024).toList();
        signalBuffer = signalBuffer.sublist(512).toList();
        var features = _mfcc.process_frame(frame);
        _kws.pushFeatures(features);
      }
    }
  }

  // Controller
  void detectUtterance() {
    _isDetectingUtterance = true;
    _utterance.detectUtterance(_onUtterance);
  }

  void cancelUtterance() {
    if (_isDetectingUtterance) {
      print("AAAAAAAA");
      _utterance.cancelDetUtterance();
    }

  }

  void _onUtterance(List<int> audioBuffer, UtteranceStatus status){
    switch (status) {
      case UtteranceStatus.thresholdReached: {
        playSoundEnd();
      }
      break;
      case UtteranceStatus.maxBufferLength: {
        playSoundEnd();
      }
      break;
      case UtteranceStatus.canceled: {
        playSoundAborted();
      }
      break;
      case UtteranceStatus.timeout: {
        playSoundAborted();
      }
      break;
    }
    _isDetectingUtterance = false;
    _onUtteranceEnd();
    startDetecting();
  }

  void startDetecting() {
    if (!_isDetecting) {
      _isDetecting = true;
      _microphone.startListening();
    }
  }
  void stopDetecting() {
    if (_isDetecting) {
      _isDetecting = false;
    }
  }

  Future<Map> _loadSettings() async {
    return jsonDecode(await rootBundle.loadString(CONFIG_FILE_PATH));
  }

  void _onKWSpotted(double confidence) {
    if (_isDetecting) {
      _kws.flushFeatures();
      playSound();
      _onDetection();
      stopDetecting();
      print("KEYWORD SPOTTED !! at $confidence");
      detectUtterance();
    }
  }

  void triggerKeyword() async {
    _onKWSpotted(1.0);
  }

  void playSound() {
    _audio.playAsset('sounds/detection.wav');
  }

  void playSoundEnd() {
    _audio.playAsset('sounds/detectEnd.wav');
  }

  void playSoundAborted() {
    _audio.playAsset('sounds/canceled.wav');
  }

  Future<void> startRecording(String fileName) async {
    if (_inputRecorded) {
      stopRecording();
    }
    String filePath = await getFilePath(fileName);
    _currentWritingFile = File(filePath);
  }

  void pauseRecording() {

  }

  void stopRecording() {

  }
  /// Get the path to a Document Directory File using [fileName].
  Future<String> getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }


  ///   SETTERS
  void set onKeyWordSpotted(VoidCallback callback) {
    _onDetection = callback;
  }

  void set onReady(VoidCallback callback) {
    _onReady = callback;
  }

  void set onUtteranceStart(VoidCallback callback) {
    _onUtteranceStart = callback;
  }

  void set onUtteranceEnd(VoidCallback callback) {
    _onUtteranceEnd = callback;
  }

  void set onCanceled(VoidCallback callback) {
    _onCanceled = callback;
  }
}

typedef VoidCallback = void Function();

typedef SignalCallback = void Function(File signal);