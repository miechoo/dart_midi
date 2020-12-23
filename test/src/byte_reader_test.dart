import 'package:dart_midi/dart_midi.dart';
import 'package:test/test.dart';

void main() {
  List<int> buffer;
  ByteReader reader;
  setUp(() {
    buffer = [0xFF, 0xFE, 0xFD, 0xFC, 0xFB, 0xFA, 0xF9, 0xF8, 0xF7, 0xF6, 0xF5, 0xF4, 0xF3, 0xF2, 0xF1, 0xF0];
    reader = ByteReader(buffer);
  });
  group('byte reader ...', () {
    test('readUInt8', () async {
      expect(reader.readUInt8(), 0xFF);
    });
    test('readUInt16', () async {
      expect(reader.readUInt16(), 0xFF << 8 | 0xFE);
    });
    test('readUInt24', () async {
      expect(reader.readUInt24(), 0xFF << 16 | 0xFE << 8 | 0xFD);
    });
    test('readUInt32', () async {
      expect(reader.readUInt32(), 0xFF << 24 | 0xFE << 16 | 0xFD << 8 | 0xFC);
    });
    test('readUInt8, readUInt16, readUInt24, readUInt32', () async {
      expect(reader.readUInt8(), 0xFF);
      expect(reader.readUInt16(), 0xFE << 8 | 0xFD);
      expect(reader.readUInt24(), 0xFC << 16 | 0xFB << 8 | 0xFA);
      expect(reader.readUInt32(), 0xF9 << 24 | 0xF8 << 16 | 0xF7 << 8 | 0xF6);
    });
  });
}
