import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:mfcc/mfcc.dart';
import 'microphone.dart';
import 'kws.dart';
import 'utterance.dart';

final String CONFIG_FILE_PATH = "assets/config/config.json";

class AudioManager {
  // Settings
  Map _settings;

  // Status
  bool _isRecording = false;
  bool _isDetecting = false;
  bool _isReady = false;

  bool get isRecording {
    return _isRecording;
  }

  bool get isDetecting {
    return _isDetecting;
  }

  // Processing
  MFCC _mfcc;
  MicrophoneInput _microphone;
  KWS _kws;
  Utterance _utterance;

  //Buffer
  List<double> signalBuffer = List<double>();

  void initialize() async {
    _settings = await _loadSettings();
    print('config loaded');
    _microphone = MicrophoneInput(_settings['audio']['samplingRate'], _settings['audio']['encoding'], _settings['audio']['channels']);
    _microphone.frameSink = _onAudioFrames;
    _mfcc = MFCC(_settings['audio']['samplingRate'], _settings['audio']['features']['nFFT'], _settings['audio']['features']['numFilters'], _settings['audio']['features']['numCoefs']);
    print('initialized');
    _kws = KWS();
    _kws.loadModel('linto_tflite.tflite');
  }

  // Callback functions
  void _onAudioFrames(List<double> frames) {
    signalBuffer.addAll(frames);
    if (signalBuffer.length >= _settings['audio']['features']['windowLength']) {
      List<double> frame = signalBuffer.sublist(0,1024);
      signalBuffer = signalBuffer.sublist(512);
      var features = _mfcc.process_frame(frame);
      print(features);
    }
  }
  // Controller
  void detectUtterance(Function(Uint8List, UtteranceStatus) command) {}
  void cancelUtterance() {}

  void startDetecting() {
    if (!_isDetecting) {
      _isDetecting = true;
      _microphone.startListening();
    }
    // 1. Start microphone
    // 2. Extract MFCC from stream
    // 3. Infere
  }
  void stopDetecting() {
    if (_isDetecting) {
      _isDetecting = false;
      _microphone.stopListening();
    }
  }

  Future<Map> _loadSettings() async {
    return jsonDecode(await rootBundle.loadString(CONFIG_FILE_PATH));
  }

  void dummyDetect() async {
    await _kws.detect();
  }

}