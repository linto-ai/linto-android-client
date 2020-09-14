import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'package:linto_flutter_client/logic/userpref.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';
import 'package:linto_flutter_client/audio/audioPlayer.dart';
import 'package:linto_flutter_client/logic/uicontroller.dart';
import 'package:linto_flutter_client/audio/utils/wav.dart';
import 'package:linto_flutter_client/audio/tts.dart';
import 'package:linto_flutter_client/logic/transactions.dart';


/// MainController is the central controller of the app.
/// It links the UI, client and modules.
class MainController {
  static final  Map<String, String> _audioAssets = {
    'START' : 'sounds/detection.wav',
    'STOP': 'sounds/detectEnd.wav',
    'CANCELED' : 'sounds/canceled.wav'};

  final LinTOClient client = LinTOClient();           // Network connectivity
  final AudioManager audioManager = AudioManager();   // Audio input
  final Audio _audioPlayer = Audio();                 // Audio output
  final TTS _tts = TTS();                             // Text to speech
  VoiceUIController currentUI;                        // UI interface
  UserPreferences userPreferences = UserPreferences();// Persistent user preferences

  ClientState state = ClientState.INITIALIZING;       // App State

  Transaction _currentTransaction = Transaction("");  // Current transaction.

  /// Stop client session
  void disconnect() {
    // Disconnect from broker
    userPreferences.clientPreferences["reconnect"] = false;
    client.disconnect();
    // Cut Audio
    audioManager.stopDetecting();
    // Set flags
    state = ClientState.DISCONNECTED;
    currentUI.onDisconnect();
  }

  /// Request permission from device
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

  void init() {
    if (state == ClientState.INITIALIZING) {
      audioManager.onReady = _onAudioReady;
      audioManager.initialize();
      _tts.initTts();
      _tts.startCallback = currentUI.onLintoSpeakingStart;
      _tts.stopCallback = currentUI.onLintoSpeakingStop;
    } else if (state == ClientState.DISCONNECTED) {
      audioManager.startDetecting();
    }
    client.onMQTTMsg = _onMessage;
    state = ClientState.IDLE;
  }

  /// Called on MQTT message received.
  void _onMessage(String topic, String msg) {
    Map<String, dynamic> decodedMsg = jsonDecode(utf8.decode(msg.runes.toList()));
    String targetTopic = topic.split('/').last;
    if (decodedMsg.keys.contains("error")) {
      _resolveErrors(decodedMsg['error']);
      return;
    } else if(decodedMsg.keys.contains("behavior")) {
      _resolveBehaviors(decodedMsg['behavior']);
    }
  }

  void _resolveBehaviors(Map<String, dynamic> behaviors) {
    if (!{"say", "ask", "display"}.any(behaviors.keys.contains)) {
      currentUI.onError("Failed to interpret server response.");
    }
    if (behaviors.keys.contains("say")) {
      say(behaviors["say"]["text"], currentUI.onLintoSpeakingStop);
      currentUI.onMessage(behaviors["say"]["text"]);
    } else if (behaviors.keys.contains("ask")) {
      _currentTransaction.conversationData = behaviors["conversationData"];
      _currentTransaction.transactionState = TransactionState.WFORCLIENT;
      ask(behaviors["ask"]["text"]);
    }

    if (behaviors.keys.contains("display")) {
      display(behaviors["display"]["content"], behaviors["display"]["type"] == 'URL');
    }
  }

  void _resolveErrors(Map<String, dynamic> error) {

  }

  /// Synthesize speech
  void say(String value, VoidCallback stopCallback){
    ClientState formerState = state;
    state = ClientState.SPEAKING;
    audioManager.stopDetecting();
    _tts.stopCallback = stopCallback;
    _tts.speak(value);
    state = formerState;
    if(state == ClientState.LISTENING) {
      audioManager.startDetecting();
    }
  }

  void ask(String value) {
    say(value, audioManager.detectUtterance);
  }

  void display(String content, bool isURL) {
    currentUI.display(content, isURL);
  }

  /// Simulate keyword spotted
  void triggerKeyWord() {
    audioManager.triggerKeyword();
  }

  /// Cancel utterance detection
  void abord() {
    if (state == ClientState.LISTENING) {
      audioManager.cancelUtterance();
    }
    _tts.stop();

    state = ClientState.IDLE;
    if (! audioManager.isDetecting) {
      audioManager.startDetecting();
    }
  }

  void displayWebview(String toDisplay, bool isURL) {

  }

  /// Bind audio input callbacks
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
    _audioPlayer.playAsset(_audioAssets['START']);
    print(DateTime.now());
    Future.delayed(const Duration(milliseconds: 750)).whenComplete(() {
      print(DateTime.now());
      audioManager.detectUtterance();
      state = ClientState.LISTENING;
    });
  }

  void _onUtteranceStart() {
    currentUI.onUtteranceStart();
  }

  void _onUtteranceEnd(List<int> signal) {
    _audioPlayer.playAsset(_audioAssets['STOP']);
    currentUI.onUtteranceEnd();
    if (_currentTransaction.transactionState == TransactionState.WFORCLIENT) {

    } else {
      _newTransaction();
    }
    _sendAudioRequest(_currentTransaction, signal);
    _currentTransaction.transactionState = TransactionState.WFORSERVER;
    state = ClientState.REQUESTPENDING;
    currentUI.onRequestPending();
  }

  void _newTransaction() {
    _currentTransaction = Transaction(Uuid().v4(), transactionState: TransactionState.WFORCLIENT);
  }

  void _sendAudioRequest(Transaction transaction, List<int> audio) {
    Map<String, dynamic> request = Map<String, dynamic>();
    request["transaction_id"] = transaction.transactionID;
    request["audio"] = base64.encode(rawSig2Wav(audio, 16000, 1, 16));
    print(request["audio"].length);
    request['conversationData'] = transaction.conversationData;
    client.sendMessage(request, subTopic: "/nlp/file/${transaction.transactionID}");
  }

  void _onUtteranceCanceled() {
    currentUI.onUtteranceCanceled();
    _audioPlayer.playAsset(_audioAssets['CANCELED']);
    state = ClientState.IDLE;
    audioManager.startDetecting();
  }
}

enum ClientState {
  INITIALIZING,
  IDLE,
  LISTENING,
  REQUESTPENDING,
  SPEAKING,
  DISCONNECTED
}