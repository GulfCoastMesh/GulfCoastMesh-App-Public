import 'dart:typed_data';

const Map<int, (double, double)> meshMapperCoverageGridSteps = {
  300: (0.0027, 0.00384),
  100: (0.0009, 0.00128),
};

class MeshMapperCoverageCell {
  final int id;
  final int latitudeIndex;
  final int longitudeIndex;
  final int status;

  const MeshMapperCoverageCell({
    required this.id,
    required this.latitudeIndex,
    required this.longitudeIndex,
    required this.status,
  });
}

List<MeshMapperCoverageCell> decodeMeshMapperCoverageCells(Uint8List bytes) {
  try {
    final tile = _ProtoReader(bytes);
    while (!tile.isDone) {
      final tag = tile.readVarint();
      final field = tag ~/ 8;
      final wire = tag % 8;
      if (field == 3 && wire == 2) {
        return _decodeLayer(_ProtoReader(tile.readBytes(tile.readVarint())));
      }
      _skipField(tile, wire);
    }
  } catch (_) {
    // Foreign or malformed tiles are simply ignored.
  }
  return const [];
}

List<MeshMapperCoverageCell> _decodeLayer(_ProtoReader layer) {
  final keys = <String>[];
  final values = <int>[];
  final features = <_ProtoReader>[];
  while (!layer.isDone) {
    final tag = layer.readVarint();
    final field = tag ~/ 8;
    final wire = tag % 8;
    if (field == 2 && wire == 2) {
      features.add(_ProtoReader(layer.readBytes(layer.readVarint())));
    } else if (field == 3 && wire == 2) {
      keys.add(String.fromCharCodes(layer.readBytes(layer.readVarint())));
    } else if (field == 4 && wire == 2) {
      values.add(
        _decodeValue(_ProtoReader(layer.readBytes(layer.readVarint()))),
      );
    } else {
      _skipField(layer, wire);
    }
  }

  final cells = <MeshMapperCoverageCell>[];
  for (final feature in features) {
    var id = 0;
    final tags = <int>[];
    while (!feature.isDone) {
      final tag = feature.readVarint();
      final field = tag ~/ 8;
      final wire = tag % 8;
      if (field == 1 && wire == 0) {
        id = feature.readVarint();
      } else if (field == 2 && wire == 2) {
        final packed = _ProtoReader(feature.readBytes(feature.readVarint()));
        while (!packed.isDone) {
          tags.add(packed.readVarint());
        }
      } else {
        _skipField(feature, wire);
      }
    }

    int? latitudeIndex;
    int? longitudeIndex;
    int? status;
    for (var index = 0; index + 1 < tags.length; index += 2) {
      final keyIndex = tags[index];
      final valueIndex = tags[index + 1];
      final key = keyIndex < keys.length ? keys[keyIndex] : '';
      final value = valueIndex < values.length ? values[valueIndex] : 0;
      if (key == 'i') latitudeIndex = value;
      if (key == 'j') longitudeIndex = value;
      if (key == 'st') status = value;
    }
    if (latitudeIndex != null && longitudeIndex != null && status != null) {
      cells.add(
        MeshMapperCoverageCell(
          id: id,
          latitudeIndex: latitudeIndex,
          longitudeIndex: longitudeIndex,
          status: status,
        ),
      );
    }
  }
  return cells;
}

int _decodeValue(_ProtoReader value) {
  while (!value.isDone) {
    final tag = value.readVarint();
    final field = tag ~/ 8;
    final wire = tag % 8;
    if (field == 6 && wire == 0) {
      final encoded = value.readVarint();
      return encoded.isOdd ? -((encoded + 1) ~/ 2) : encoded ~/ 2;
    }
    _skipField(value, wire);
  }
  return 0;
}

void _skipField(_ProtoReader reader, int wire) {
  switch (wire) {
    case 0:
      reader.readVarint();
    case 1:
      reader.skip(8);
    case 2:
      reader.skip(reader.readVarint());
    case 5:
      reader.skip(4);
    default:
      throw const FormatException('Unsupported protobuf wire type');
  }
}

class _ProtoReader {
  final Uint8List bytes;
  int offset = 0;

  _ProtoReader(this.bytes);

  bool get isDone => offset >= bytes.length;

  int readVarint() {
    var value = 0;
    var multiplier = 1;
    while (true) {
      if (isDone) throw const FormatException('Truncated varint');
      final byte = bytes[offset++];
      value += (byte % 128) * multiplier;
      if (byte < 128) return value;
      multiplier *= 128;
    }
  }

  Uint8List readBytes(int length) {
    if (length < 0 || offset + length > bytes.length) {
      throw const FormatException('Truncated field');
    }
    final result = Uint8List.sublistView(bytes, offset, offset + length);
    offset += length;
    return result;
  }

  void skip(int length) => readBytes(length);
}
