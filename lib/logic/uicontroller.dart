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
  void onRequestPending() {
    print('Request pending');
  }

  void onLintoSpeakingStart(String text) {
    print('Linto says $text');
  }

  void onLintoSpeakingStop() {
    print('Linto stop speaking');
  }
}