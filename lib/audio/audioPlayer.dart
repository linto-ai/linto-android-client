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

  String _rawSig2Wav(List<int> signal, int sampleRate, int channels, int encoding) {
    Uint8List header = _generateWavHeader(signal.length, sampleRate, channels, encoding);
  }

  Uint8List _generateWavHeader(int sigLength, int sampleRate, int channels, int encoding) {
    Uint8List header = Uint8List(44);
    Uint32List signalLength = Uint32List.fromList([sigLength]);
    header.setAll(0, [82, 73, 70, 70]); // RIFF
    header.setAll(4, signalLength.buffer.asUint8List());

  }
}