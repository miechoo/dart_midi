import 'dart:math';

import 'package:dart_midi/src/byte_writer.dart';
import 'package:meta/meta.dart';

abstract class _EventWriter {
  int writeEvent(ByteWriter w);
}

abstract class MidiEvent implements _EventWriter {
  ///Every `MidiEvent` should have some String type for debugging purposes.
  final String type;
  final int eventTypeByte;
  String get eventTypeByteString => '0x${eventTypeByte?.toRadixString(16)}';
  int deltaTime = 0;

  //TODO: is it used?
  final bool meta;
  //TODO: is set to true by midi_parser.dart
  bool running = false;

  // This is a writer functionality
  //TODO: fix this ByteWriter stuff
  int lastEventTypeByte;
  //TODO: fix this
  bool useByte9ForNoteOff = false;

  MidiEvent({
    @required this.eventTypeByte,
    @required this.deltaTime,
    this.meta,
    @required this.type,
    //TODO: There is an need a verification if this.running is always used
    this.running,
  }) {
    assert(this.type != null, 'Event type should not be null');
    // assert(this.running != null, 'Running flag in event should not be null');
  }
}

/// Private class which is an abstraction of `NoteOnEvent` and `NoteOffEvent`.
/// It differs from other Events by having byte9 variable, which is specific only for this two classes.
abstract class _EventWithNote extends MidiEvent {
  bool byte9 = false;

  _EventWithNote({
    @required int eventTypeByte,
    @required this.byte9,
    @required int deltaTime,
    bool meta,
    @required bool running,
    String type,
  }) : super(
          eventTypeByte: eventTypeByte,
          deltaTime: deltaTime,
          meta: meta,
          running: running,
          type: type,
        );
}

/// Private class which is an abstraction of `TextEvent`, `CopyrightNoticeEvent`, `LyricsEvent`, `MarkerEvent`, `CuePointEvent`, `InstrumentNameEvent`.
/// It differs from other Events by having byte9 variable, which is specific only for this classes.
abstract class _EventWithText extends MidiEvent {
  String text;

  _EventWithText({
    @required int eventTypeByte,
    @required int deltaTime,
    bool meta,
    @required bool running,
    this.text,
    String type,
  }) : super(
          eventTypeByte: eventTypeByte,
          deltaTime: deltaTime,
          meta: meta,
          running: running,
          type: type,
        );
}

/// Private class which is an abstraction of `SequencerSpecificEvent`, `SequencerSpecificEvent`, `SystemExclusiveEvent`, `EndSystemExclusiveEvent`, `UnknownMetaEvent`, ``.
/// It differs from other Events by having data variable, which is specific only for this classes.
abstract class _EventWithData extends MidiEvent {
  List<int> data;

  _EventWithData({
    @required int eventTypeByte,
    @required this.data,
    @required int deltaTime,
    bool meta,
    @required bool running,
    String type,
  }) : super(
          eventTypeByte: eventTypeByte,
          deltaTime: deltaTime,
          meta: meta,
          running: running,
          type: type,
        );
}

class SequenceNumberEvent extends MidiEvent {
  int number;
  SequenceNumberEvent({int deltaTime, this.number})
      : super(
          deltaTime: deltaTime,
          eventTypeByte: 0xFF << 8 | 0x00,
          meta: true,
          type: 'sequenceNumber',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x00);
    w.writeVarInt(2);
    w.writeUInt16(number);
    return -1;
  }
}

class EndOfTrackEvent extends MidiEvent {
  EndOfTrackEvent({int deltaTime})
      : super(
          deltaTime: deltaTime,
          eventTypeByte: 0xFF << 16 | 0x2F << 8 | 0x00,
          meta: true,
          type: 'endOfTrack',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x2F);
    w.writeVarInt(0);
    return -1;
  }
}

class ProgramChangeMidiEvent extends MidiEvent {
  int channel;
  int programNumber;

  ProgramChangeMidiEvent({
    this.channel,
    int deltaTime,
    this.programNumber,
    bool running,
  }) : super(
          deltaTime: deltaTime,
          eventTypeByte: 0xC0,
          meta: false,
          running: running,
          type: 'programChange',
        );

  @override
  int writeEvent(ByteWriter w) {
    var eventTypeByte = 0xC0 | channel;
    if (eventTypeByte != lastEventTypeByte) w.writeUInt8(eventTypeByte);
    w.writeUInt8(programNumber);
    return eventTypeByte;
  }
}

class ChannelAfterTouchEvent extends MidiEvent {
  int amount;
  int channel;

  ChannelAfterTouchEvent({
    this.amount,
    this.channel,
    int deltaTime,
    bool running,
  }) : super(
          eventTypeByte: 0xD0,
          deltaTime: deltaTime,
          meta: false,
          running: running,
          type: 'channelAftertouch',
        );

  @override
  int writeEvent(ByteWriter w) {
    var eventTypeByte = 0xD0 | channel;
    if (eventTypeByte != lastEventTypeByte) w.writeUInt8(eventTypeByte);
    w.writeUInt8(amount);
    return eventTypeByte;
  }
}

class PitchBendEvent extends MidiEvent {
  int channel;
  int value;

  PitchBendEvent({
    this.channel,
    int deltaTime,
    bool running,
    this.value,
  }) : super(
          eventTypeByte: 0xE0,
          deltaTime: deltaTime,
          meta: false,
          running: running,
          type: 'pitchBend',
        );

  @override
  int writeEvent(ByteWriter w) {
    var eventTypeByte = 0xE0 | channel;
    if (eventTypeByte != lastEventTypeByte) w.writeUInt8(eventTypeByte);
    var value14 = 0x2000 + value;
    var lsb14 = (value14 & 0x7F);
    var msb14 = (value14 >> 7) & 0x7F;
    w.writeUInt8(lsb14);
    w.writeUInt8(msb14);
    return eventTypeByte;
  }
}

class ControllerEvent extends MidiEvent {
  int channel;
  int controllerType;
  //TODO: there is not assignment to this variable, nor reading
  int number;
  int value;

  ControllerEvent({
    this.channel,
    bool running,
    int deltaTime,
    this.controllerType,
    this.value,
  }) : super(
          eventTypeByte: 0xB0,
          deltaTime: deltaTime,
          meta: false,
          running: running,
          type: 'controller',
        );

  @override
  int writeEvent(ByteWriter w) {
    var eventTypeByte = 0xB0 | channel;
    if (eventTypeByte != lastEventTypeByte) w.writeUInt8(eventTypeByte);
    w.writeUInt8(controllerType);
    w.writeUInt8(value);
    return eventTypeByte;
  }
}

class NoteOnEvent extends _EventWithNote {
  int channel;
  int noteNumber;
  int velocity;

  NoteOnEvent({
    bool byte9,
    this.channel,
    int deltaTime,
    this.noteNumber,
    bool running,
    this.velocity,
  }) : super(
          eventTypeByte: 0x90,
          byte9: byte9,
          deltaTime: deltaTime,
          meta: false,
          running: running,
          type: 'noteOn',
        );

  @override
  int writeEvent(ByteWriter w) {
    var eventTypeByte = 0x90 | channel;
    if (eventTypeByte != lastEventTypeByte) w.writeUInt8(eventTypeByte);
    w.writeUInt8(noteNumber);
    w.writeUInt8(velocity);
    return eventTypeByte;
  }
}

class NoteAfterTouchEvent extends MidiEvent {
  int amount;
  int channel;
  int noteNumber;

  NoteAfterTouchEvent({
    this.amount,
    this.channel,
    int deltaTime,
    this.noteNumber,
    bool running,
  }) : super(
          eventTypeByte: 0xA0,
          deltaTime: deltaTime,
          running: running,
          type: 'polyphonic',
          meta: false,
        );

  @override
  int writeEvent(ByteWriter w) {
    var eventTypeByte = 0xA0 | channel;
    if (eventTypeByte != lastEventTypeByte) w.writeUInt8(eventTypeByte);
    w.writeUInt8(noteNumber);
    w.writeUInt8(amount);
    return eventTypeByte;
  }
}

class NoteOffEvent extends _EventWithNote {
  int channel;
  int noteNumber;
  int velocity;

  NoteOffEvent({
    bool byte9,
    this.channel,
    int deltaTime,
    this.noteNumber,
    bool running,
    this.velocity,
  }) : super(
          eventTypeByte: 0x80,
          byte9: byte9,
          deltaTime: deltaTime,
          meta: false,
          running: running,
          type: 'noteOff',
        );

  @override
  int writeEvent(ByteWriter w) {
    // Use 0x90 when opts.useByte9ForNoteOff is set and velocity is zero, or when event.byte9 is explicitly set on it.
    // parseMidi will set event.byte9 for each event, so that we can get an exact copy by default.
    // Explicitly set opts.useByte9ForNoteOff to false, to override event.byte9 and always use 0x80 for noteOff events.
    var noteByte = ((useByte9ForNoteOff != false && byte9) || (useByte9ForNoteOff && velocity == 0)) ? 0x90 : 0x80;

    var eventTypeByte = noteByte | channel;
    if (eventTypeByte != lastEventTypeByte) w.writeUInt8(eventTypeByte);
    w.writeUInt8(noteNumber);
    w.writeUInt8(velocity);
    return eventTypeByte;
  }
}

class TextEvent extends _EventWithText {
  TextEvent({
    int deltaTime,
    String text,
  }) : super(
          eventTypeByte: 0xFF << 8 | 0x01,
          deltaTime: deltaTime,
          meta: true,
          text: text,
          type: 'text',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x01);
    w.writeVarInt(text.length);
    w.writeString(text);
    return -1;
  }
}

class CopyrightNoticeEvent extends _EventWithText {
  CopyrightNoticeEvent({
    int deltaTime,
    String text,
  }) : super(
          eventTypeByte: 0xFF << 8 | 0x02,
          deltaTime: deltaTime,
          meta: true,
          text: text,
          type: 'copyrightNotice',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x02);
    w.writeVarInt(text.length);
    w.writeString(text);
    return -1;
  }
}

class LyricsEvent extends _EventWithText {
  LyricsEvent({
    String text,
    int deltaTime,
  }) : super(
          eventTypeByte: 0xFF << 8 | 0x05,
          deltaTime: deltaTime,
          meta: true,
          text: text,
          type: 'lyrics',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x05);
    w.writeVarInt(text.length);
    w.writeString(text);
    return -1;
  }
}

class MarkerEvent extends _EventWithText {
  MarkerEvent({
    String text,
    int deltaTime,
  }) : super(
          eventTypeByte: 0xFF << 8 | 0x06,
          deltaTime: deltaTime,
          meta: true,
          text: text,
          type: 'marker',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x06);
    w.writeVarInt(text.length);
    w.writeString(text);
    return -1;
  }
}

class CuePointEvent extends _EventWithText {
  CuePointEvent({
    int deltaTime,
    String text,
  }) : super(
          eventTypeByte: 0xFF << 8 | 0x07,
          deltaTime: deltaTime,
          meta: true,
          text: text,
          type: 'cuePoint',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x07);
    w.writeVarInt(text.length);
    w.writeString(text);
    return -1;
  }
}

class InstrumentNameEvent extends _EventWithText {
  InstrumentNameEvent({
    int deltaTime,
    String text,
  }) : super(
          eventTypeByte: 0xFF << 8 | 0x04,
          deltaTime: deltaTime,
          meta: true,
          text: text,
          type: 'instrumentName',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x04);
    w.writeVarInt(text.length);
    w.writeString(text);
    return -1;
  }
}

class TrackNameEvent extends _EventWithText {
  TrackNameEvent({
    int deltaTime,
    String text,
  }) : super(
          eventTypeByte: 0xFF << 8 | 0x03,
          deltaTime: deltaTime,
          meta: true,
          text: text,
          type: 'trackName',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x03);
    w.writeVarInt(text.length);
    w.writeString(text);
    return -1;
  }
}

class ChannelPrefixEvent extends MidiEvent {
  int channel;

  ChannelPrefixEvent({
    this.channel,
    int deltaTime,
  }) : super(
          eventTypeByte: 0xFF << 16 | 0x20 << 8 | 0x01,
          deltaTime: deltaTime,
          meta: true,
          type: 'channelPrefix',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x20);
    w.writeVarInt(1);
    w.writeUInt8(channel);
    return -1;
  }
}

class PortPrefixEvent extends MidiEvent {
  int channel;
  //TODO: there is no assignment to this variable
  int port;

  PortPrefixEvent({
    this.channel,
    int deltaTime,
  }) : super(
          eventTypeByte: 0xFF << 16 | 0x21 << 8 | 0x01,
          deltaTime: deltaTime,
          meta: true,
          type: 'portPrefix',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x21);
    w.writeVarInt(1);
    w.writeUInt8(port);
    return -1;
  }
}

class SetTempoEvent extends MidiEvent {
  int microsecondsPerBeat;

  SetTempoEvent({
    int deltaTime,
    this.microsecondsPerBeat,
  }) : super(
          eventTypeByte: 0xFF << 16 | 0x51 << 8 | 0x03,
          deltaTime: deltaTime,
          meta: true,
          type: 'setTempo',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x51);
    w.writeVarInt(3);
    w.writeUInt24(microsecondsPerBeat);
    return -1;
  }
}

class SequencerSpecificEvent extends _EventWithData {
  SequencerSpecificEvent({
    List<int> data,
    int deltaTime,
  }) : super(
          eventTypeByte: 0xFF << 8 | 0x7F,
          data: data,
          deltaTime: deltaTime,
          meta: true,
          type: 'sequencerSpecific',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x7F);
    w.writeVarInt(data.length);
    w.writeBytes(data);

    return -1;
  }
}

class SystemExclusiveEvent extends _EventWithData {
  SystemExclusiveEvent({
    List<int> data,
    int deltaTime,
  }) : super(
          eventTypeByte: 0xF0,
          data: data,
          deltaTime: deltaTime,
          meta: false,
          type: 'sysEx',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xF0);
    w.writeVarInt(data.length);
    w.writeBytes(data);

    return -1;
  }
}

class EndSystemExclusiveEvent extends _EventWithData {
  EndSystemExclusiveEvent({
    List<int> data,
    int deltaTime,
  }) : super(
          eventTypeByte: 0xF7,
          data: data,
          deltaTime: deltaTime,
          meta: false,
          type: 'endSysEx',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xF7);
    w.writeVarInt(data.length);
    w.writeBytes(data);
    return -1;
  }
}

class UnknownMetaEvent extends _EventWithData {
  int metatypeByte;

  UnknownMetaEvent({
    List<int> data,
    int deltaTime,
    this.metatypeByte,
  }) : super(
          eventTypeByte: 0xFF,
          data: data,
          deltaTime: deltaTime,
          meta: true,
          type: 'unknownMeta',
        );

  @override
  int writeEvent(ByteWriter w) {
    if (metatypeByte != null) {
      w.writeUInt8(0xFF);
      w.writeUInt8(metatypeByte);
      w.writeVarInt(data.length);
      w.writeBytes(data);
    }
    return -1;
  }
}

class SmpteOffsetEvent extends MidiEvent {
  int frame;
  int frameRate;
  int hour;
  int min;
  int sec;
  int subFrame;

  SmpteOffsetEvent({
    int deltaTime,
    this.frame,
    this.frameRate,
    this.hour,
    this.min,
    this.sec,
    this.subFrame,
  }) : super(
          eventTypeByte: 0xFF << 16 | 0x54 << 8 | 0x05,
          deltaTime: deltaTime,
          meta: true,
          type: 'smpteOffset',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x54);
    w.writeVarInt(5);
    var frameRates = {24: 0x00, 25: 0x20, 29: 0x40, 30: 0x60};
    var hourByte = (hour & 0x1F) | frameRates[frameRate];
    w.writeUInt8(hourByte);
    w.writeUInt8(min);
    w.writeUInt8(sec);
    w.writeUInt8(frame);
    w.writeUInt8(subFrame);
    return -1;
  }
}

class TimeSignatureEvent extends MidiEvent {
  int denominator;
  int metronome;
  int numerator;
  int thirtyseconds;

  TimeSignatureEvent({
    int deltaTime,
    this.denominator,
    this.metronome,
    this.numerator,
    this.thirtyseconds,
  }) : super(
          eventTypeByte: 0xFF << 16 | 0x58 << 8 | 0x04,
          deltaTime: deltaTime,
          meta: true,
          type: 'timeSignature',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x58);
    w.writeVarInt(4);
    w.writeUInt8(numerator);
    var _denominator = (log(denominator) / ln2).floor() & 0xFF;
    w.writeUInt8(_denominator);
    w.writeUInt8(metronome);
    w.writeUInt8(thirtyseconds ?? 8);
    return -1;
  }
}

class KeySignatureEvent extends MidiEvent {
  int key;
  int scale;

  KeySignatureEvent({
    int deltaTime,
    this.key,
    this.scale,
  }) : super(
          eventTypeByte: 0xFF << 16 | 0x59 << 8 | 0x02,
          deltaTime: deltaTime,
          meta: true,
          type: 'keySignature',
        );

  @override
  int writeEvent(ByteWriter w) {
    w.writeUInt8(0xFF);
    w.writeUInt8(0x59);
    w.writeVarInt(2);
    w.writeInt8(key);
    w.writeUInt8(scale);
    return -1;
  }
}
