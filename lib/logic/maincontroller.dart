import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';
import 'package:linto_flutter_client/audio/audioPlayer.dart';
import 'package:linto_flutter_client/logic/uicontroller.dart';
import 'package:linto_flutter_client/audio/utils/wav.dart';
import 'package:linto_flutter_client/audio/tts.dart';


class MainController {
  final LinTOClient client = LinTOClient(); // Network connectivity
  final AudioManager audioManager = AudioManager(); // Audio input
  final Audio _audioPlayer = Audio(); // Audio output
  final TTS _tts = TTS(); // Text to speech
  VoiceUIController currentUI; // UI interface

  TransactionState state = TransactionState.INITIALIZING;

  final Map<String, String> audioAssets = {'START' : 'sounds/detection.wav',
                                           'STOP': 'sounds/detectEnd.wav',
                                           'CANCELED' : 'sounds/canceled.wav'
  };

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
      state = TransactionState.IDLE;
      client.onMQTTMsg = _onMessage;
    }
  }

  void _onMessage(String msg) {
    print("MESSAGE RECEIVED");
    var decodedmsg = jsonDecode(msg);
    if (decodedmsg.keys.contains('say')) {
      _tts.speak(decodedmsg['say']);
    }
  }

  void triggerKeyWord() {
    audioManager.triggerKeyword();
  }

  void abord() {
    if (state == TransactionState.LISTENNING) {
      audioManager.cancelUtterance();
    }
    state = TransactionState.IDLE;
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
    state = TransactionState.IDLE;
  }

  void _onKeywordSpotted() {
    currentUI.onKeywordSpotted();
    _audioPlayer.playAsset(audioAssets['START']);
    audioManager.detectUtterance();
    state = TransactionState.LISTENNING;
  }

  void _onUtteranceStart() {

    currentUI.onUtteranceStart();
  }

  void _onUtteranceEnd(List<int> signal) {
    currentUI.onUtteranceEnd();
    _audioPlayer.playAsset(audioAssets['STOP']);
    client.sendMessage({'audio': rawSig2Wav(signal, 16000, 1, 16)});
    state = TransactionState.REQUESTPENDING;
    currentUI.onRequestPending();
  }

  void _onUtteranceCanceled() {
    currentUI.onUtteranceCanceled();
    _audioPlayer.playAsset(audioAssets['CANCELED']);
    state = TransactionState.IDLE;
    audioManager.startDetecting();
  }
}

enum TransactionState {
  INITIALIZING,
  IDLE,
  LISTENNING,
  REQUESTPENDING,
  SPEAKING,
}