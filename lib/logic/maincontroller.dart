import 'dart:typed_data';

import 'package:linto_flutter_client/audio/utterance.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';
import 'package:linto_flutter_client/audio/audioPlayer.dart';
import 'package:linto_flutter_client/logic/uicontroller.dart';
import 'package:linto_flutter_client/audio/audioPlayer.dart';

class MainController {
  final LinTOClient client = LinTOClient(); // Network connectivity
  final AudioManager audioManager = AudioManager(); // Audio input
  final Audio _audioPlayer = Audio(); // Audio output
  VoiceUIController currentUI; // UI interface

  TransactionState state = TransactionState.INITIALIZING;

  final Map<String, String> audioAssets = {'START' : 'sounds/detection.wav',
                                           'STOP': 'sounds/detectEnd.wav',
                                           'CANCELED' : 'sounds/canceled.wav'
  };

  void initializeAudio() {
    if (! audioManager.isReady) {
      audioManager.onReady = _onAudioReady;
      audioManager.initialize();
    }
  }

  void triggerKeyWord() {
    audioManager.triggerKeyword();
  }

  void abord() {
    if (state == TransactionState.LISTENNING) {
      audioManager.cancelUtterance();
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
    audioManager.detectUtterance();
    state = TransactionState.LISTENNING;
  }

  void _onUtteranceStart() {
    _audioPlayer.playAsset(audioAssets['START']);
    currentUI.onUtteranceStart();
  }

  void _onUtteranceEnd(List<int> signal) {
    currentUI.onUtteranceEnd();
    _audioPlayer.playAsset(audioAssets['STOP']);
    client.sendMessage({'message': Uint8List.fromList((signal))});
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