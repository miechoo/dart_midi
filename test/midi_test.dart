import 'dart:io';

import 'package:test/test.dart';
import 'package:dart_midi/dart_midi.dart';

void main() {
  group('parser tests', () {
    test('parser and writer output matches', () {
      var file = File('./test/resources/MIDI_sample.mid');
      final parser = MidiParser();
      List<int> originalFileBuffer = file.readAsBytesSync();
      var parsedMidi = parser.parseMidiFromBuffer(originalFileBuffer);

      var writer = MidiWriter();
      List<int> writtenBuffer = writer.writeMidiToBuffer(parsedMidi);

      expect(originalFileBuffer, writtenBuffer);
    });
  });
}
