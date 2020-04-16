import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'audioPlayer.dart';
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

  // CallBacks
  final VoidCallback onDetection;
  final VoidCallback onReady;

  AudioManager({this.onDetection, this.onReady}) :super();

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
    onReady();
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
    var frames = signal.map((v) => v.toDouble()).toList();
    signalBuffer.addAll(frames);
    while (signalBuffer.length >= _settings['audio']['features']['windowLength']) {
      List<double> frame = signalBuffer.sublist(0,1024).toList();
      signalBuffer = signalBuffer.sublist(512).toList();
      var features = _mfcc.process_frame(frame);
      _kws.pushFeatures(features);
    }
  }

  // Controller
  void detectUtterance() {
    _utterance.streamable = false;
    _utterance.detectUtterance((x, _) => print("Utterance of length ${x.length}"));
  }
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

  void _onKWSpotted(double confidence) {
    if (_isDetecting) {
      _kws.flushFeatures();
      playSound();
      onDetection();
      stopDetecting();
      print("KEYWORD SPOTTED !! at $confidence");
    }
  }

  void dummyDetect() async {
    _kws.flushFeatures();
    playSound();
    onDetection();
    stopDetecting();
    print("KEYWORD SPOTTED !! at DUMMY");
  }

  void playSound() {
    _audio.playAsset('sounds/detection.wav');
  }
}

typedef VoidCallback = void Function();