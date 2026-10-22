import 'dart:typed_data';
import '../connector/meshcore_protocol.dart';
import '../helpers/atak_location_access.dart';

class Contact {
  final Uint8List publicKey;
  final String name;
  final int type;
  final int pathLength; // -1 = flood, 0+ = direct hops (from device)
  final Uint8List path; // Path bytes from device
  final int?
  pathOverride; // User's path override: -1 = force flood, null = auto
  final Uint8List? pathOverrideBytes; // User's path override bytes
  final double? latitude;
  final double? longitude;
  final DateTime lastSeen;
  final DateTime lastMessageAt;
  final bool isFavorite;
  final DateTime? firstSeenAt;

  /// User-chosen local override for [name]. Never sent over the mesh —
  /// only changes how this contact appears in this app.
  final String? nickname;

  Contact({
    required this.publicKey,
    required this.name,
    required this.type,
    required this.pathLength,
    required this.path,
    this.pathOverride,
    this.pathOverrideBytes,
    this.latitude,
    this.longitude,
    required this.lastSeen,
    DateTime? lastMessageAt,
    this.isFavorite = false,
    this.firstSeenAt,
    this.nickname,
  }) : lastMessageAt = lastMessageAt ?? lastSeen;

  /// [nickname] when set, otherwise the mesh-advertised [name].
  String get displayName {
    final trimmed = nickname?.trim();
    return trimmed != null && trimmed.isNotEmpty ? trimmed : name;
  }

  static const Duration newContactWindow = Duration(days: 7);

  bool get isNew {
    final first = firstSeenAt;
    if (first == null) return false;
    final age = DateTime.now().difference(first);
    return !age.isNegative && age < newContactWindow;
  }

  String get publicKeyHex => pubKeyToHex(publicKey);

  String get typeLabel {
    switch (type) {
      case advTypeChat:
        return 'Chat';
      case advTypeRepeater:
        return 'Repeater';
      case advTypeRoom:
        return 'Room';
      case advTypeSensor:
        return 'Sensor';
      default:
        return 'Unknown';
    }
  }

  String get pathLabel {
    if (pathOverride != null) {
      if (pathOverride! < 0) return 'Flood (forced)';
      if (pathOverride == 0) return 'Direct (forced)';
      return '$pathOverride hops (forced)';
    }
    if (pathLength < 0) return 'Flood';
    if (pathLength == 0) return 'Direct';
    return '$displayHopCount hops';
  }

  int get displayHopCount {
    if (pathLength <= 0) return pathLength;
    if ((pathLength & 0xC0) != 0) {
      return decodePathHopCount(pathLength);
    }
    return pathLength;
  }

  int get effectivePathHashSize {
    if (pathOverrideBytes != null &&
        pathOverride != null &&
        pathOverride! > 0 &&
        pathOverrideBytes!.isNotEmpty) {
      final inferred = pathOverrideBytes!.length ~/ pathOverride!;
      if (inferred >= 1 && inferred <= 3) return inferred;
    }
    if (pathLength > 0 && (pathLength & 0xC0) != 0) {
      return decodePathHashSize(pathLength);
    }
    if (path.isNotEmpty && pathLength > 0 && path.length % pathLength == 0) {
      final inferred = path.length ~/ pathLength;
      if (inferred >= 1 && inferred <= 3) return inferred;
    }
    return pathHashSize;
  }

  bool get hasLocation {
    if (latitude == null || longitude == null) return false;
    return isValidMapCoordinate(latitude!, longitude!);
  }

  Contact copyWith({
    Uint8List? publicKey,
    String? name,
    int? type,
    int? pathLength,
    Uint8List? path,
    int? pathOverride,
    Uint8List? pathOverrideBytes,
    bool clearPathOverride = false,
    double? latitude,
    double? longitude,
    DateTime? lastSeen,
    DateTime? lastMessageAt,
    bool? isFavorite,
    DateTime? firstSeenAt,
    String? nickname,
    bool clearNickname = false,
  }) {
    return Contact(
      publicKey: publicKey ?? this.publicKey,
      name: name ?? this.name,
      type: type ?? this.type,
      pathLength: pathLength ?? this.pathLength,
      path: path ?? this.path,
      pathOverride: clearPathOverride
          ? null
          : (pathOverride ?? this.pathOverride),
      pathOverrideBytes: clearPathOverride
          ? null
          : (pathOverrideBytes ?? this.pathOverrideBytes),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastSeen: lastSeen ?? this.lastSeen,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isFavorite: isFavorite ?? this.isFavorite,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      nickname: clearNickname ? null : (nickname ?? this.nickname),
    );
  }

  String get pathIdList {
    final pathBytes = _pathBytesForDisplay;
    if (pathBytes.isEmpty) return '';
    return formatPathIdList(pathBytes, hashSizeBytes: effectivePathHashSize);
  }

  String get shortPubKeyHex {
    return "<${publicKeyHex.substring(0, 8)}...${publicKeyHex.substring(publicKeyHex.length - 8)}>";
  }

  Uint8List? get traceRouteBytes {
    final pathBytes = _pathBytesForDisplay;
    Uint8List? traceBytes;

    if (pathBytes.isEmpty) {
      traceBytes = Uint8List(1);
      traceBytes[0] = publicKey[0];
      return traceBytes;
    }

    if (type == advTypeRepeater || type == advTypeRoom) {
      final len = (pathBytes.length + pathBytes.length + 1);
      traceBytes = Uint8List(len);
      traceBytes[pathBytes.length] = publicKey[0];
      for (int i = 0; i < pathBytes.length; i++) {
        traceBytes[i] = pathBytes[i];
        if (i < pathBytes.length) {
          traceBytes[len - 1 - i] = pathBytes[i];
        }
      }
    } else {
      if (pathBytes.length < 2) {
        return pathBytes[0] == 0 ? null : pathBytes;
      }
      final len = (pathBytes.length + pathBytes.length - 1);
      traceBytes = Uint8List(len);
      for (int i = 0; i < pathBytes.length; i++) {
        traceBytes[i] = pathBytes[i];
        if (i < pathBytes.length - 1) {
          traceBytes[len - 1 - i] = pathBytes[i];
        }
      }
    }
    return traceBytes;
  }

  Uint8List get _pathBytesForDisplay {
    if (pathOverride != null) {
      if (pathOverride! < 0) return Uint8List(0);
      return pathOverrideBytes ?? Uint8List(0);
    }
    return path;
  }

  static Contact? fromFrame(Uint8List data, {int fallbackHashSizeBytes = 1}) {
    if (data.isEmpty) return null;
    if (data[0] != respCodeContact) return null;
    try {
      final pubKey = Uint8List.fromList(
        data.sublist(contactPubKeyOffset, contactPubKeyOffset + pubKeySize),
      );
      final type = data[contactTypeOffset];
      final pathLenField = data[contactPathLenOffset];
      Uint8List pathBytes;
      int storedPathLength;
      if (pathLenField == 0xFF) {
        storedPathLength = -1;
        pathBytes = Uint8List(0);
      } else {
        // Bits 6-7 describe the hash size; three-byte routes set the sign bit.
        // 0b11 is reserved, except for the explicit flood sentinel above.
        if ((pathLenField & 0xC0) == 0xC0) return null;
        final parsed = parsePathLengthField(
          pathLenField,
          fallbackHashSizeBytes: fallbackHashSizeBytes,
        );
        final byteLen = parsed.pathByteLength;
        if (byteLen > maxPathSize) return null;
        pathBytes = byteLen > 0
            ? Uint8List.fromList(
                data.sublist(contactPathOffset, contactPathOffset + byteLen),
              )
            : Uint8List(0);
        storedPathLength = (pathLenField & 0xC0) != 0
            ? parsed.hopCount
            : pathLenField;
      }
      final name = readCString(data, contactNameOffset, maxNameSize);
      final lastmod = readUint32LE(data, contactLastmodOffset);

      double? lat, lon;
      final latRaw = readInt32LE(data, contactLatOffset);
      final lonRaw = readInt32LE(data, contactLonOffset);
      if (latRaw != 0 || lonRaw != 0) {
        lat = latRaw / 1e6;
        lon = lonRaw / 1e6;
        if (!isValidMapCoordinate(lat, lon)) {
          lat = null;
          lon = null;
        }
      }

      return Contact(
        publicKey: pubKey,
        name: name.isEmpty ? 'Unknown' : name,
        type: type,
        pathLength: storedPathLength,
        path: pathBytes,
        latitude: lat,
        longitude: lon,
        lastSeen: DateTime.fromMillisecondsSinceEpoch(lastmod * 1000),
      );
    } catch (e) {
      // If parsing fails, return null
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Contact && publicKeyHex == other.publicKeyHex;

  @override
  int get hashCode => publicKeyHex.hashCode;
}
