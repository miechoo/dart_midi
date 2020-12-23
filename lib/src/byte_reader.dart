import 'package:dart_midi/src/data_chunk.dart';

class ByteReader {
  final List<int> buffer;
  int pos = 0;

  @Deprecated('this getter is deprecated')
  //TODO: refactor this variable
  bool get eof => this.pos >= buffer.length;

  ByteReader(this.buffer);

  /// used to set: metatypeByte, event.channel.
  /// Reads one byte with 8 bits of data from the common buffer
  int readUInt8() {
    //TODO: add exception when try to read index out of scope
    var result = this.buffer[this.pos];
    this.pos += 1;
    return result;
  }

  int readInt8() {
    var u = this.readUInt8();
    if (u & 0x80 != 0) {
      return u - 0x100;
    } else
      return u;
  }

  /// Reads two bytes with 8 bits of data from the common buffer
  int readUInt16() {
    var b0 = this.readUInt8();
    var b1 = this.readUInt8();
    return b0 << 8 | b1;
  }

  int readInt16() {
    var u = this.readUInt16();
    if (u & 0x8000 != 0) {
      return u - 0x10000;
    } else
      return u;
  }

  /// Reads three bytes with 8 bits of data from the common buffer
  int readUInt24() {
    var b0 = this.readUInt8();
    var b1 = this.readUInt8();
    var b2 = this.readUInt8();
    return b0 << 16 | b1 << 8 | b2;
  }

  int readInt24() {
    var u = this.readUInt16();
    if (u & 0x800000 != 0) {
      return u - 0x1000000;
    } else
      return u;
  }

  /// Reads four bytes with 8 bits of data from the common buffer
  int readUInt32() {
    var b0 = this.readUInt8();
    var b1 = this.readUInt8();
    var b2 = this.readUInt8();
    var b3 = this.readUInt8();

    return b0 << 24 | b1 << 16 | b2 << 8 | b3;
  }

  List<int> readBytes(int len) {
    var bytes = this.buffer.sublist(this.pos, this.pos + len);
    this.pos += len;
    return bytes;
  }

  String readString(int len) {
    var bytes = this.readBytes(len);
    return String.fromCharCodes(bytes);
  }

  /// used to set deltaTime and 'lenght' string variable
  int readVarInt() {
    var result = 0;
    while (!this.eof) {
      var b = this.readUInt8();
      if (b & 0x80 != 0) {
        result += (b & 0x7f);
        result <<= 7;
      } else {
        // b is last byte
        return result + b;
      }
    }
    // premature eof
    return result;
  }

  DataChunk readChunk() {
    var id = this.readString(4);
    var length = this.readUInt32();
    var data = this.readBytes(length);
    return DataChunk(id: id, length: length, bytes: data);
  }
}
