import 'package:linto_flutter_client/logic/maincontroller.dart';

class VoiceUIController{
  MainController _mainController;

  bool isActiveView;

  ///VOICE RELATED
  void onKeywordSpotted() {
    print('Keyword spotted');
  }

  void onUtteranceStart() {
    print('Utterance Start');
  }

  void onUtteranceCanceled() {
    print('Utterance Canceled');
  }

  void onUtteranceEnd() {
    print('Utterance Ended');
  }

  /// CLIENT RELATED

  void onError(String errorMessage) {
    print("An error occured");
  }

  void onRequestPending() {
    print('Request pending');
  }

  void onLintoSpeakingStart() {
    print('Linto start speaking ');
  }

  void onLintoSpeakingStop() {
    print('Linto stop speaking');
  }

  void onMessage(String msg) {
    print('Received message : $msg');
  }

  void onDisconnect() {
    print('Disconnected');
  }

  void display(String content, bool isURL) {
    print("Displaying content");
  }
}