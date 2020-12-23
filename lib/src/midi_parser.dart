import 'package:dart_midi/src/byte_reader.dart';
import 'package:dart_midi/src/midi_events.dart';
import 'package:dart_midi/src/midi_file.dart';
import 'package:dart_midi/src/midi_header.dart';
import 'dart:io';

/// MidiParser is a class responsible of parsing MIDI data into dart objects
class MidiParser {
  int _lastEventTypeByte;

  MidiParser();

  /// Reads a midi file from provided [buffer]
  ///
  /// Returns parsed [MidiFile]
  MidiFile parseMidiFromBuffer(List<int> buffer) {
    var p = new ByteReader(buffer);

    var headerChunk = p.readChunk();
    if (headerChunk.id != 'MThd') throw "Bad MIDI file.  Expected 'MHdr', got: '${headerChunk.id}'";
    var header = parseHeader(headerChunk.bytes);

    List<List<MidiEvent>> tracks = [];
    for (var i = 0; !p.eof && i < header.numTracks; i++) {
      var trackChunk = p.readChunk();
      if (trackChunk.id != 'MTrk') throw "Bad MIDI file.  Expected 'MTrk', got: '${trackChunk.id}'";
      var track = parseTrack(trackChunk.bytes);
      tracks.add(track);
    }

    return MidiFile(tracks, header);
  }

  /// Reads a provided byte [data] into [MidiHeader]
  MidiHeader parseHeader(List<int> data) {
    final ByteReader p = ByteReader(data);

    final int format = p.readUInt16();
    final int numTracks = p.readUInt16();
    int framesPerSecond;
    int ticksPerFrame;
    int ticksPerBeat;

    final int timeDivision = p.readUInt16();
    if (timeDivision & 0x8000 != 0) {
      framesPerSecond = 0x100 - (timeDivision >> 8);
      ticksPerFrame = timeDivision & 0xFF;
    } else {
      ticksPerBeat = timeDivision;
    }

    return MidiHeader(
      format: format,
      framesPerSecond: framesPerSecond,
      numTracks: numTracks,
      ticksPerBeat: ticksPerBeat,
      ticksPerFrame: ticksPerFrame,
    );
  }

  /// Parses provided [file] and returns [MidiFile]
  MidiFile parseMidiFromFile(File file) {
    return parseMidiFromBuffer(file.readAsBytesSync());
  }

  /// Reads event from provided [p] and returns parsed [MidiEvent]
  MidiEvent readEvent(ByteReader p) {
    /// read from p.readVarInt();
    int deltaTime = p.readVarInt();

    int eventTypeByte = p.readUInt8();

    if ((eventTypeByte & 0xf0) == 0xf0) {
      // system / meta event
      if (eventTypeByte == 0xff) {
        // meta event
        final int metatypeByte = p.readUInt8();
        final int length = p.readVarInt();
        switch (metatypeByte) {
          case 0x00:
            if (length != 2) throw 'Expected length for sequenceNumber event is 2, got ${length.toString()}';
            return SequenceNumberEvent(
              deltaTime: deltaTime,
              number: p.readUInt16(),
            );
          case 0x01:
            return TextEvent(
              deltaTime: deltaTime,
              text: p.readString(length),
            );
          case 0x02:
            return CopyrightNoticeEvent(
              deltaTime: deltaTime,
              text: p.readString(length),
            );
          case 0x03:
            return TrackNameEvent(
              deltaTime: deltaTime,
              text: p.readString(length),
            );
          case 0x04:
            return InstrumentNameEvent(
              deltaTime: deltaTime,
              text: p.readString(length),
            );
          case 0x05:
            return LyricsEvent(
              deltaTime: deltaTime,
              text: p.readString(length),
            );
          case 0x06:
            return MarkerEvent(
              deltaTime: deltaTime,
              text: p.readString(length),
            );
          case 0x07:
            return CuePointEvent(
              deltaTime: deltaTime,
              text: p.readString(length),
            );
          case 0x20:
            if (length != 1) throw 'Expected length for channelPrefix event is 1, got ${length.toString()}';
            return ChannelPrefixEvent(
              deltaTime: deltaTime,
              channel: p.readUInt8(),
            );
          case 0x21:
            if (length != 1) throw 'Expected length for portPrefix event is 1, got ${length.toString()}';
            return PortPrefixEvent(
              deltaTime: deltaTime,
              channel: p.readUInt8(),
            );
          case 0x2f:
            if (length != 0) throw 'Expected length for endOfTrack event is 0, got ${length.toString()}';
            return EndOfTrackEvent(
              deltaTime: deltaTime,
            );
          case 0x51:
            if (length != 3) throw 'Expected length for setTempo event is 3, got ${length.toString()}';
            return SetTempoEvent(
              deltaTime: deltaTime,
              microsecondsPerBeat: p.readUInt24(),
            );
          case 0x54:
            if (length != 5) throw 'Expected length for smpteOffset event is 5, got ${length.toString()}';
            Map<int, int> frameRates = {0x00: 24, 0x20: 25, 0x40: 29, 0x60: 30};
            int hourByte = p.readUInt8();
            int frameRate = frameRates[hourByte & 0x60];
            int hour = hourByte & 0x1f;
            int min = p.readUInt8();
            int sec = p.readUInt8();
            int frame = p.readUInt8();
            int subFrame = p.readUInt8();
            return SmpteOffsetEvent(
              deltaTime: deltaTime,
              frameRate: frameRate,
              hour: hour,
              min: min,
              sec: sec,
              frame: frame,
              subFrame: subFrame,
            );
          case 0x58:
            if (length != 4) throw 'Expected length for timeSignature event is 4, got ${length.toString()}';
            int numerator = p.readUInt8();
            int denominator = (1 << p.readUInt8());
            int metronome = p.readUInt8();
            int thirtyseconds = p.readUInt8();
            return TimeSignatureEvent(
              deltaTime: deltaTime,
              denominator: denominator,
              metronome: metronome,
              numerator: numerator,
              thirtyseconds: thirtyseconds,
            );
          case 0x59:
            if (length != 2) throw 'Expected length for keySignature event is 2, got ${length.toString()}';
            int key = p.readInt8();
            int scale = p.readUInt8();
            return KeySignatureEvent(
              deltaTime: deltaTime,
              key: key,
              scale: scale,
            );
          case 0x7f:
            List<int> data = p.readBytes(length);
            return SequencerSpecificEvent(
              deltaTime: deltaTime,
              data: data,
            );
          default:
            List<int> data = p.readBytes(length);
            return UnknownMetaEvent(
              deltaTime: deltaTime,
              data: data,
              metatypeByte: metatypeByte,
            );
        }
      } else if (eventTypeByte == 0xf0) {
        // TODO: check when it occurs

        int length = p.readVarInt();
        List<int> data = p.readBytes(length);
        return SystemExclusiveEvent(
          deltaTime: deltaTime,
          data: data,
        );
      } else if (eventTypeByte == 0xf7) {
        int length = p.readVarInt();
        List<int> data = p.readBytes(length);
        return EndSystemExclusiveEvent(
          deltaTime: deltaTime,
          data: data,
        );
      } else {
        throw 'Unrecognised MIDI event type byte: ${eventTypeByte.toString()}';
      }
    } else {
      // channel event
      int param1;
      bool running = false;
      if ((eventTypeByte & 0x80) == 0) {
        // running status - reuse lastEventTypeByte as the event type.
        // eventTypeByte is actually the first parameter
        if (_lastEventTypeByte == null) throw "Running status byte encountered before status byte";
        param1 = eventTypeByte;
        eventTypeByte = _lastEventTypeByte;
        running = true;
      } else {
        param1 = p.readUInt8();
        _lastEventTypeByte = eventTypeByte;
      }
      var eventType = eventTypeByte >> 4;
      var channel = eventTypeByte & 0x0f;
      switch (eventType) {
        //TODO: check the difference between 0x08 and 0x09
        case 0x08:
          int velocity = p.readUInt8();
          return NoteOffEvent(deltaTime: deltaTime, running: running, channel: channel, noteNumber: param1, velocity: velocity);
        case 0x09:
          int velocity = p.readUInt8();
          if (velocity == 0) {
            return NoteOffEvent(
              byte9: true,
              channel: channel,
              deltaTime: deltaTime,
              noteNumber: param1,
              running: running,
              velocity: velocity,
            );
          } else {
            // (velocity != 0) || (velocity == null)
            return NoteOnEvent(
              byte9: false,
              channel: channel,
              deltaTime: deltaTime,
              noteNumber: param1,
              running: running,
              velocity: velocity,
            );
          }
          break;
        case 0x0a:
          return NoteAfterTouchEvent(
            amount: p.readUInt8(),
            channel: channel,
            deltaTime: deltaTime,
            noteNumber: param1,
            running: running,
          );
        case 0x0b:
          return ControllerEvent(
            channel: channel,
            running: running,
            deltaTime: deltaTime,
            controllerType: param1,
            value: p.readUInt8(),
          );
        case 0x0c:
          return ProgramChangeMidiEvent(
            channel: channel,
            deltaTime: deltaTime,
            programNumber: param1,
            running: running,
          );
        case 0x0d:
          return ChannelAfterTouchEvent(
            amount: param1,
            channel: channel,
            deltaTime: deltaTime,
            running: running,
          );
        case 0x0e:
          return PitchBendEvent(
            channel: channel,
            deltaTime: deltaTime,
            running: running,
            value: (param1 + (p.readUInt8() << 7)) - 0x2000,
          );
        default:
          throw 'Unrecognised MIDI event type: ${eventType.toString()}';
      }
    }
  }

  /// Parses provided [data] and returns a list of [MidiEvent]
  List<MidiEvent> parseTrack(List<int> data) {
    var p = new ByteReader(data);
    List<MidiEvent> events = [];
    while (!p.eof) {
      var event = readEvent(p);
      events.add(event);
    }
    return events;
  }
}
