import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';


class Audio {

  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;

  AudioPlayer _audioPlayer;
  Duration audioDuration;
  Audio() {
    _audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  }

  void playAsset(String audioPath, {bool isAsset: false}) async {
    if (isAsset) {
      var audioCache = AudioCache();
      audioCache.play(audioPath);
    } else {
      _audioPlayer.play(audioPath, isLocal: true);
    }
  }

  Future<void> setupAudio(String filePath, PositionCallBack positionCallBack, VoidCallback completionCallBack, PositionCallBack onDurationChanged) async {
    _positionSubscription = _audioPlayer.onAudioPositionChanged.listen((p) => positionCallBack(p), onError: (_msg) => print(_msg));
    _playerCompleteSubscription = _audioPlayer.onPlayerCompletion.listen((p) => completionCallBack());
    _durationSubscription = _audioPlayer.onDurationChanged.listen((event) => onDurationChanged(event));
    _audioPlayer.setUrl(filePath, isLocal: true);
  }

  void seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }

  void pauseAudio() {
    _audioPlayer.pause();
  }

  void resumeAudio() {
    _audioPlayer.resume();
  }

  void platAt(Duration duration) {
    _audioPlayer.seek(duration);
  }

  void setAudioDuration(Duration duration) {
    this.audioDuration = duration;
  }

  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
  }

  Stream<Duration> get onPositionChanged {
    return _audioPlayer.onAudioPositionChanged;
  }
}
