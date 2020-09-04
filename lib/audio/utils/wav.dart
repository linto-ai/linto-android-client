import 'dart:typed_data';

/// Converts List<int> signal into a wave file buffer including header.
Uint8List rawSig2Wav(List<int> signal, int sampleRate, int channels, int encoding) {
  Uint8List header = generateWavHeader(signal.length * 2, sampleRate, channels, encoding);
  Uint8List signal_uint8 = listIntToUintList(signal);
  print(signal_uint8.length);
  Uint8List waveContent = Uint8List(header.length + signal_uint8.length);
  waveContent.setAll(0, header);
  waveContent.setAll(header.length, signal_uint8);
  return waveContent;
}

/// Generates a wav header with given signal parameters
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
/// Converts a List<int> to a Uint8List with little endian int16 encoding
Uint8List listIntToUintList(List<int> signal) {
  return Int16List.fromList(signal).buffer.asUint8List();
}