import 'dart:convert';

import 'package:linto_flutter_client/logic/options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';
import 'package:linto_flutter_client/audio/audioPlayer.dart';
import 'package:linto_flutter_client/logic/uicontroller.dart';
import 'package:linto_flutter_client/audio/utils/wav.dart';
import 'package:linto_flutter_client/audio/tts.dart';
import 'package:linto_flutter_client/logic/transactions.dart';


class MainController {
  final LinTOClient client = LinTOClient(); // Network connectivity
  final AudioManager audioManager = AudioManager(); // Audio input
  final Audio _audioPlayer = Audio(); // Audio output
  final TTS _tts = TTS(); // Text to speech
  VoiceUIController currentUI; // UI interface
  Options options = Options();

  ClientState state = ClientState.INITIALIZING;
  Transaction _currentTransaction = Transaction("");

  final Map<String, String> audioAssets = {'START' : 'sounds/detection.wav',
                                           'STOP': 'sounds/detectEnd.wav',
                                           'CANCELED' : 'sounds/canceled.wav'
  };

  Future disconnect() async {

  }

  Future<bool> requestPermissions() async {
    if (! await Permission.microphone.status.isGranted) {
      if( ! await Permission.microphone.request().isGranted) {
        return false;
      }
    }
    if (! await Permission.mediaLibrary.status.isGranted) {
      if( ! await Permission.mediaLibrary.request().isGranted) {
        return false;
      }
    }
    return true;
  }

  void initializeAudio() {
    if (! audioManager.isReady) {
      audioManager.onReady = _onAudioReady;
      audioManager.initialize();
      _tts.initTts();
      _tts.startCallback = currentUI.onLintoSpeakingStart;
      _tts.stopCallback = currentUI.onLintoSpeakingStop;
      state = ClientState.IDLE;
      client.onMQTTMsg = _onMessage;
      options.loadUserPref();
    }
  }

  void _onMessage(String topic, String msg) {
    var decodedMsg = jsonDecode(utf8.decode(msg.runes.toList()));
    String targetTopic = topic.split('/').last;
    if (targetTopic == 'say') {
      say(decodedMsg['value']);
      currentUI.onMessage('"${decodedMsg['value']}"');
    }
  }

  void say(String value){
    //shutdown detection
    _tts.speak(value);
    //resolve
  }

  void triggerKeyWord() {
    audioManager.triggerKeyword();
  }

  void abord() {
    if (state == ClientState.LISTENNING) {
      audioManager.cancelUtterance();
    }
    state = ClientState.IDLE;
    if (! audioManager.isDetecting) {
      audioManager.startDetecting();
    }
  }

  void _onAudioReady() {
    audioManager.onKeyWordSpotted = _onKeywordSpotted;
    audioManager.onUtteranceStart = _onUtteranceStart;
    audioManager.onUtteranceEnd = _onUtteranceEnd;
    audioManager.onCanceled = _onUtteranceCanceled;
    audioManager.startDetecting();
    state = ClientState.IDLE;
  }

  void _onKeywordSpotted() {
    currentUI.onKeywordSpotted();
    _audioPlayer.playAsset(audioAssets['START']);
    audioManager.detectUtterance();
    state = ClientState.LISTENNING;
  }

  void _onUtteranceStart() {

    currentUI.onUtteranceStart();
  }

  void _onUtteranceEnd(List<int> signal) {
    currentUI.onUtteranceEnd();
    _audioPlayer.playAsset(audioAssets['STOP']);
    client.sendMessage({'audio': rawSig2Wav(signal, 16000, 1, 16)});
    state = ClientState.REQUESTPENDING;
    currentUI.onRequestPending();
  }

  void _onUtteranceCanceled() {
    currentUI.onUtteranceCanceled();
    _audioPlayer.playAsset(audioAssets['CANCELED']);
    state = ClientState.IDLE;
    audioManager.startDetecting();
  }
}

enum ClientState {
  INITIALIZING,
  IDLE,
  LISTENNING,
  REQUESTPENDING,
  SPEAKING,
}