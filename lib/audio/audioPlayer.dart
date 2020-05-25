import 'dart:ffi';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

class Audio {
  static final int WAV_HEADER_LENGTH = 44;
  
  AudioCache _audioPlayer;

  Audio() {
    _audioPlayer = AudioCache();
  }

  void playAsset(String assetPath) async {
    _audioPlayer.play(assetPath);
  }

  void playPCM(List<int> signal, {int sampleRate : 16000, int channels: 1}) {
  }


}