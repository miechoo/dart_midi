/// Base class for `HeardeChunk` and `TrackChunk`
class DataChunk {
  final String id;
  final int length;
  final List<int> bytes;
  DataChunk({this.id, this.length, this.bytes});
}

/// Specialisation of `DataChunk`. Represents Header data.
class HeaderChunk extends DataChunk {
  static const _ChunkType __chunkType = _ChunkTypeHeader();
  String get chunkType => __chunkType.toString();
  List<int> _headerData;
  List<int> get data => _headerData;
  HeaderChunk({
    List<int> bytes,
    int length,
  }) : super(
          bytes: bytes,
          id: 'MThd',
          length: length,
        ) {
    _headerData = bytes;
  }
}

/// Specialisation of `DataChunk`. Represents Track data.
class TrackChunk extends DataChunk {
  static const _ChunkType __chunkType = _ChunkTypeTrack();
  String get chunkType => __chunkType.toString();
  List<int> _trackData;
  List<int> get data => _trackData;
  TrackChunk({
    List<int> bytes,
    String id,
    int length,
  }) : super(
          bytes: bytes,
          id: 'MTrk',
          length: length,
        ) {
    _trackData = bytes;
  }
}

enum _ChunkTypesEnum { HeaderChunk, TrackChunk }

abstract class _ChunkType {
  final _ChunkTypesEnum type;

  const _ChunkType(this.type);

  String toString() {
    return type.toString();
  }
}

class _ChunkTypeHeader extends _ChunkType {
  const _ChunkTypeHeader() : super(_ChunkTypesEnum.HeaderChunk);
}

class _ChunkTypeTrack extends _ChunkType {
  const _ChunkTypeTrack() : super(_ChunkTypesEnum.TrackChunk);
}
