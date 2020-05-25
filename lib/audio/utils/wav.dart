import 'dart:typed_data';

ByteData rawSig2Wav(List<int> signal, int sampleRate, int channels, int encoding) {
  Uint8List header = generateWavHeader(signal.length, sampleRate, channels, encoding);
  Uint16List signal_16 = Uint16List.fromList(signal); // TODO Check conversion endian  ?
  Uint8List waveContent = Uint8List(header.length + signal_16.length * 2);
  waveContent.setAll(0, header);
  waveContent.setAll(header.length, Uint8List.fromList(signal_16.buffer.asUint8List()));
}

Uint8List generateWavHeader(int sigLength, int sampleRate, int channels, int encoding) {
  Uint8List header = Uint8List(44); // Header is 44 bytes long
  header.setAll(0, [82, 73, 70, 70]); // 'RIFF'
  Uint32List signalLength = Uint32List.fromList([(sigLength * encoding ~/ 8) + 36]); // File length
  header.setAll(4, signalLength.buffer.asUint8List()); // 4 bytes
  header.setAll(8, [87, 65, 86, 69]); // 'WAVE' 4 bytes
  header.setAll(12, [102, 109, 116, 32]); // 'fmt ' 4 bytes
  header.setAll(16, Uint32List.fromList([16]).buffer.asUint8List()); // Length of data above 2 bytes
  header.setAll(20, Uint16List.fromList([1]).buffer.asUint8List()); // 1 = PCM 2 bytes
  header.setAll(22, Uint16List.fromList([1]).buffer.asUint8List()); // Number of channel 2 bytes
  header.setAll(24, Uint32List.fromList([sampleRate]).buffer.asUint8List()); // Samplerate 4 bytes
  header.setAll(28, Uint32List.fromList([sampleRate * encoding * channels]).buffer.asUint8List()); //chunk size 4 bytes
  header.setAll(32, Uint16List.fromList([(encoding * channels) ~/ 8]).buffer.asUint8List()); // frame length 4 bytes
  header.setAll(34, Uint16List.fromList([encoding]).buffer.asUint8List()); //encoding 2 bytes
  header.setAll(36, [100, 97, 116, 97]); // 'data' 4 bytes
  header.setAll(40, Uint32List.fromList([sigLength]).buffer.asUint8List());
  return header;
}