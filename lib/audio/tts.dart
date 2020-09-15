
import 'package:flutter_tts/flutter_tts.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';

enum TtsState { playing, stopped }

class TTS {
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 1.0;

  TtsState ttsState = TtsState.stopped;

  VoidCallback _startCallback = () => ("Start playing");
  VoidCallback _stopCallback = () => ("Stop playing");
  VoidCallback _cancelCallback = () => ("cancel playing");
  MsgCallback _errorCallback = (msg) => ("Error : $msg");

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  set startCallback(VoidCallback cb) {
    _startCallback = cb;
  }

  set stopCallback(VoidCallback cb) {
    _stopCallback = cb;
  }

  set cancelCallback(VoidCallback cb) {
    _cancelCallback = cb;
  }

  set errorCallback(MsgCallback cb) {
    _errorCallback = cb;
  }

  initTts() async {
    flutterTts = FlutterTts();
    getLanguages();
    flutterTts.setLanguage("fr-FR");
    flutterTts.setStartHandler(_startCallback);
    flutterTts.setCompletionHandler(_stopCallback);
  }

  Future<void> getLanguages() async {
    languages = await flutterTts.getLanguages;
  }

  /// Changes current tts language
  /// Returns success.
  Future<bool> changeLanguage(String lang) async {
    if (languages.contains(lang)) {
      flutterTts.setLanguage(lang);
      return true;
    }
    return false;
  }

  Future speak(String text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    flutterTts.setCompletionHandler(_stopCallback);

    var result = await flutterTts.speak(text);
    if (result == 1) {
      ttsState = TtsState.playing;
    }
  }

  Future stop() async {
    var result = await flutterTts.stop();
    if (result == 1) ttsState = TtsState.stopped;
  }

  @override
  void dispose() {
    flutterTts.stop();
  }
}