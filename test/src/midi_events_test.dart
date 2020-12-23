import 'package:test/test.dart';

import '../../lib/dart_midi.dart';

void main() {
  group('model test', () {
    test('NoteOnEvent tests', () {
      NoteOnEvent event = NoteOnEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'noteOn');
      checkByteCode(event, 0x90);
    });
    test('NoteOffEvent tests', () {
      NoteOffEvent event = NoteOffEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'noteOff');
      checkByteCode(event, 0x80);
    });
    test('EndOfTrackEvent tests', () {
      EndOfTrackEvent event = EndOfTrackEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'endOfTrack');
      checkByteCode(event, 0xFF << 16 | 0x2F << 8 | 0x00);
    });
    test('NoteAfterTouchEvent tests', () {
      NoteAfterTouchEvent event = NoteAfterTouchEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'polyphonic');
      checkByteCode(event, 0xA0);
    });
    test('ControllerEvent tests', () {
      ControllerEvent event = ControllerEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'controller');
      checkByteCode(event, 0xB0);
    });
    test('ProgramChangeMidiEvent tests', () {
      ProgramChangeMidiEvent event = ProgramChangeMidiEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'programChange');
      checkByteCode(event, 0xC0);
    });
    test('ChannelAfterTouchEvent tests', () {
      ChannelAfterTouchEvent event = ChannelAfterTouchEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'channelAftertouch');
      checkByteCode(event, 0xD0);
    });
    test('PitchBendEvent tests', () {
      PitchBendEvent event = PitchBendEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'pitchBend');
      checkByteCode(event, 0xE0);
    });
    test('TextEvent tests', () {
      TextEvent event = TextEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'text');
      checkByteCode(event, 0xFF << 8 | 0x01);
    });
    test('CopyrightNoticeEvent tests', () {
      CopyrightNoticeEvent event = CopyrightNoticeEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'copyrightNotice');
      checkByteCode(event, 0xFF << 8 | 0x02);
    });
    test('TrackNameEvent tests', () {
      TrackNameEvent event = TrackNameEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'trackName');
      checkByteCode(event, 0xFF << 8 | 0x03);
    });
    test('InstrumentNameEvent tests', () {
      InstrumentNameEvent event = InstrumentNameEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'instrumentName');
      checkByteCode(event, 0xFF << 8 | 0x04);
    });
    test('LyricsEvent tests', () {
      LyricsEvent event = LyricsEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'lyrics');
      checkByteCode(event, 0xFF << 8 | 0x05);
    });
    test('MarkerEvent tests', () {
      MarkerEvent event = MarkerEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'marker');
      checkByteCode(event, 0xFF << 8 | 0x06);
    });
    test('CuePointEvent tests', () {
      CuePointEvent event = CuePointEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'cuePoint');
      checkByteCode(event, 0xFF << 8 | 0x07);
    });
    test('ChannelPrefixEvent tests', () {
      ChannelPrefixEvent event = ChannelPrefixEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'channelPrefix');
      checkByteCode(event, 0xFF << 16 | 0x20 << 8 | 0x01);
    });
    test('PortPrefixEvent tests', () {
      PortPrefixEvent event = PortPrefixEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'portPrefix');
      checkByteCode(event, 0xFF << 16 | 0x21 << 8 | 0x01);
    });
    test('SetTempoEvent tests', () {
      SetTempoEvent event = SetTempoEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'setTempo');
      checkByteCode(event, 0xFF << 16 | 0x51 << 8 | 0x03);
    });
    test('SequencerSpecificEvent tests', () {
      SequencerSpecificEvent event = SequencerSpecificEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'sequencerSpecific');
      checkByteCode(event, 0xFF << 8 | 0x7F);
    });
    test('SystemExclusiveEvent tests', () {
      SystemExclusiveEvent event = SystemExclusiveEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'sysEx');
      checkByteCode(event, 0xF0);
    });
    test('EndSystemExclusiveEvent tests', () {
      EndSystemExclusiveEvent event = EndSystemExclusiveEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'endSysEx');
      checkByteCode(event, 0xF7);
    });
    test('UnknownMetaEvent tests', () {
      UnknownMetaEvent event = UnknownMetaEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'unknownMeta');
      checkByteCode(event, 0xFF);
    });
    test('SmpteOffsetEvent tests', () {
      SmpteOffsetEvent event = SmpteOffsetEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'smpteOffset');
      checkByteCode(event, 0xFF << 16 | 0x54 << 8 | 0x05);
    });
    test('TimeSignatureEvent tests', () {
      TimeSignatureEvent event = TimeSignatureEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'timeSignature');
      checkByteCode(event, 0xFF << 16 | 0x58 << 8 | 0x04);
    });
    test('KeySignatureEvent tests', () {
      KeySignatureEvent event = KeySignatureEvent();
      expect(event, isA<MidiEvent>(), reason: 'The ${event.runtimeType}  is not an MidiEvent');
      checkType(event, 'keySignature');
      checkByteCode(event, 0xFF << 16 | 0x59 << 8 | 0x02);
    });
  });
}

void checkByteCode(MidiEvent event, int byteCode) {
  expect(event.eventTypeByte, byteCode,
      reason:
          'The ${event.runtimeType} has wrong byteCode: found 0x${event.eventTypeByte?.toRadixString(16)}[${event.eventTypeByte}], expected 0x${byteCode.toRadixString(16)}[$byteCode]');
}

void checkType(dynamic event, String expectedType) {
  expect(event.type, expectedType, reason: 'The ${event.runtimeType} has wrong type: found ${event.type}, expected ${expectedType}');
}
