import 'dart:convert';
import 'dart:typed_data';

// Buffer Reader - sequential binary data reader with pointer tracking
class BufferReader {
  int _pointer = 0;
  final Uint8List _buffer;

  BufferReader(Uint8List data) : _buffer = Uint8List.fromList(data);

  int get remaining => _buffer.length - _pointer;

  int readByte() => readBytes(1)[0];

  Uint8List readBytes(int count) {
    if (count < 0) {
      throw RangeError.value(count, 'count', 'Must not be negative');
    }
    if (_pointer + count > _buffer.length) {
      throw RangeError(
        'Attempted to read $count bytes at offset $_pointer, but only $remaining bytes remaining in buffer of length ${_buffer.length}',
      );
    }
    final data = _buffer.sublist(_pointer, _pointer + count);
    _pointer += count;
    return data;
  }

  void skipBytes(int count) {
    if (count < 0) {
      throw RangeError.value(count, 'count', 'Must not be negative');
    }
    if (_pointer + count > _buffer.length) {
      throw RangeError(
        'Attempted to skip $count bytes at offset $_pointer, but only $remaining bytes remaining in buffer of length ${_buffer.length}',
      );
    }
    _pointer += count;
  }

  Uint8List readRemainingBytes() => readBytes(remaining);

  String readString() =>
      utf8.decode(readRemainingBytes(), allowMalformed: true);

  String readCString(int maxLength) {
    final value = <int>[];
    final bytes = readBytes(maxLength);
    for (final byte in bytes) {
      if (byte == 0) break;
      value.add(byte);
    }
    try {
      return utf8.decode(Uint8List.fromList(value), allowMalformed: true);
    } catch (e) {
      return String.fromCharCodes(value); // Latin-1 fallback
    }
  }

  int readUInt8() => readBytes(1).buffer.asByteData().getUint8(0);
  int readInt8() => readBytes(1).buffer.asByteData().getInt8(0);
  int readUInt16LE() =>
      readBytes(2).buffer.asByteData().getUint16(0, Endian.little);
  int readUInt16BE() =>
      readBytes(2).buffer.asByteData().getUint16(0, Endian.big);
  int readUInt32LE() =>
      readBytes(4).buffer.asByteData().getUint32(0, Endian.little);
  int readUInt32BE() =>
      readBytes(4).buffer.asByteData().getUint32(0, Endian.big);
  int readInt16LE() =>
      readBytes(2).buffer.asByteData().getInt16(0, Endian.little);
  int readInt16BE() => readBytes(2).buffer.asByteData().getInt16(0, Endian.big);
  int readInt32LE() =>
      readBytes(4).buffer.asByteData().getInt32(0, Endian.little);

  int readInt24BE() {
    var value = (readByte() << 16) | (readByte() << 8) | readByte();
    if ((value & 0x800000) != 0) value -= 0x1000000;
    return value;
  }
}

Uint8List _encodeUtf8Prefix(String value, int maxBytes) {
  if (maxBytes <= 0) return Uint8List(0);
  final builder = BytesBuilder();
  var length = 0;
  for (final rune in value.runes) {
    final encodedRune = utf8.encode(String.fromCharCode(rune));
    if (length + encodedRune.length > maxBytes) break;
    builder.add(encodedRune);
    length += encodedRune.length;
  }
  return builder.toBytes();
}

// Buffer Writer - accumulating binary data builder
class BufferWriter {
  final BytesBuilder _builder = BytesBuilder();

  Uint8List toBytes() => _builder.toBytes();

  void writeByte(int byte) => _builder.addByte(byte);
  void writeBytes(Uint8List bytes) => _builder.add(bytes);

  void writeUInt16LE(int num) {
    final bytes = Uint8List(2)
      ..buffer.asByteData().setUint16(0, num, Endian.little);
    writeBytes(bytes);
  }

  void writeUInt32LE(int num) {
    final bytes = Uint8List(4)
      ..buffer.asByteData().setUint32(0, num, Endian.little);
    writeBytes(bytes);
  }

  void writeInt32LE(int num) {
    final bytes = Uint8List(4)
      ..buffer.asByteData().setInt32(0, num, Endian.little);
    writeBytes(bytes);
  }

  void writeString(String string) =>
      writeBytes(Uint8List.fromList(utf8.encode(string)));

  void writeCString(String string, int maxLength) {
    if (maxLength <= 0) return;
    final bytes = Uint8List(maxLength);
    final encoded = _encodeUtf8Prefix(string, maxLength - 1);
    bytes.setRange(0, encoded.length, encoded);
    writeBytes(bytes);
  }

  void writeHex(String hex) {
    // Validate hex string length is even and not empty
    if (hex.isEmpty || hex.length % 2 != 0) {
      throw FormatException('Invalid hex string length: ${hex.length}');
    }
    List<int> result = [];
    for (int i = 0; i < hex.length ~/ 2; i++) {
      final hexByte = hex.substring(i * 2, i * 2 + 2);
      final byte = int.tryParse(hexByte, radix: 16);
      if (byte == null) {
        throw FormatException(
          'Invalid hex characters at position $i: $hexByte',
        );
      }
      result.add(byte);
    }
    writeBytes(Uint8List.fromList(result));
  }
}

// Command codes (to device)
const int cmdAppStart = 1;
const int cmdSendTxtMsg = 2;
const int cmdSendChannelTxtMsg = 3;
const int cmdGetContacts = 4;
const int cmdGetDeviceTime = 5;
const int cmdSetDeviceTime = 6;
const int cmdSendSelfAdvert = 7;
const int cmdSetAdvertName = 8;
const int cmdAddUpdateContact = 9;
const int cmdSyncNextMessage = 10;
const int cmdSetRadioParams = 11;
const int cmdSetRadioTxPower = 12;
const int cmdResetPath = 13;
const int cmdSetAdvertLatLon = 14;
const int cmdRemoveContact = 15;
const int cmdShareContact = 16;
const int cmdExportContact = 17;
const int cmdImportContact = 18;
const int cmdReboot = 19;
const int cmdGetBattAndStorage = 20;

/// Send a direct-route raw custom payload (MeshCore companion v1.15+).
///
/// Frame format is `[command][path length][path bytes][payload bytes]`.
const int cmdSendRawData = 0x19;

/// Send a binary datagram to a channel (MeshCore firmware v1.15+).
///
/// This shares the numeric value with no companion command in the legacy
/// protocol. The response-side channel datagram notification is also 0x1B,
/// but command and response namespaces are independent.
const int cmdSendChannelData = 0x3E;
const int cmdDeviceQuery = 22;
const int cmdSendLogin = 26;
const int cmdSendStatusReq = 27;
const int cmdGetContactByKey = 30;
const int cmdGetChannel = 31;
const int cmdSetChannel = 32;
const int cmdSendTracePath = 36;
const int cmdSendControlData = 55; // 0x37 - discovery / control packets (v8+)
const int cmdGetStats = 56; // 0x38
const int cmdSetOtherParams = 38;
const int cmdGetRadioSettings = 57;
const int cmdGetTelemetryReq = 39;
const int cmdGetCustomVar = 40;
const int cmdSetCustomVar = 41;
const int cmdSendBinaryReq = 50;
const int cmdSetFloodScopeKey = 0x36; // per-send flood scope override (v8+)
const int cmdSetPathHashMode = 0x3D;
const int cmdSetDefaultFloodScope = 0x3F; // persist default flood scope (v11+)
const int cmdGetDefaultFloodScope = 0x40;

// Text message types
const int txtTypePlain = 0;
const int txtTypeCliData = 1;

// Repeater request types (for server requests)
const int reqTypeGetStatus = 0x01;
const int reqTypeKeepAlive = 0x02;
const int reqTypeGetTelemetry = 0x03;
const int reqTypeGetAccessList = 0x05;
const int reqTypeGetNeighbors = 0x06;

// Repeater response codes
const int respServerLoginOk = 0;

// Response codes (from device)
const int respCodeOk = 0;
const int respCodeErr = 1;
const int respCodeContactsStart = 2;
const int respCodeContact = 3;
const int respCodeEndOfContacts = 4;
const int respCodeSelfInfo = 5;
const int respCodeSent = 6;
const int respCodeContactMsgRecv = 7;
const int respCodeChannelMsgRecv = 8;
const int respCodeCurrTime = 9;
const int respCodeNoMoreMessages = 10;
const int respCodeExportContact = 11;
const int respCodeBattAndStorage = 12;
const int respCodeDeviceInfo = 13;
const int respCodeContactMsgRecvV3 = 16;
const int respCodeChannelMsgRecvV3 = 17;
const int respCodeChannelInfo = 18;
const int respCodeRadioSettings = 25;
const int respCodeStats = 24; // 0x18

/// Binary channel datagram notification (firmware v1.15+).
const int respCodeChannelDataReceived = 0x1B;
const int respCodeCustomVars = 21;
const int respCodeDefaultFloodScope = 0x1C; // 28

/// Zero-padded name field size for default flood scope frames.
const int defaultFloodScopeNameField = 31;

/// Key size for default flood scope frames.
const int defaultFloodScopeKeyBytes = 16;

// Push codes (async from device)
const int pushCodeAdvert = 0x80;
const int pushCodePathUpdated = 0x81;
const int pushCodeSendConfirmed = 0x82;
const int pushCodeMsgWaiting = 0x83;

/// Companion push carrying a raw custom payload.
const int pushCodeRawData = 0x84;
const int pushCodeLoginSuccess = 0x85;
const int pushCodeLoginFail = 0x86;
const int pushCodeStatusResponse = 0x87;
const int pushCodeLogRxData = 0x88;
const int pushCodeTraceData = 0x89;
const int pushCodeNewAdvert = 0x8A;
const int pushCodeTelemetryResponse = 0x8B;
const int pushCodeBinaryResponse = 0x8C;
const int pushCodeControlData = 0x8E;

// Discovery control sub-types (upper nibble of control payload flags byte)
const int discoverReqSubType = 0x80;
const int discoverRespSubType = 0x90;

// Discovery node flags are distinct from advertisement type values.
const int discoverNodeTypeRepeater = 0x02;
const int discoverNodeTypeRoom = 0x04;
const int discoverTypeFilterRepeaterRoom =
    discoverNodeTypeRepeater | discoverNodeTypeRoom;

// Contact/advertisement types
const int advTypeChat = 1;
const int advTypeRepeater = 2;
const int advTypeRoom = 3;
const int advTypeSensor = 4;

// Payload Types
const int payloadTypeREQ =
    0x00; // request (prefixed with dest/src hashes, MAC) (enc data: timestamp, blob)
const int payloadTypeRESPONSE =
    0x01; // response to REQ or ANON_REQ (prefixed with dest/src hashes, MAC) (enc data: timestamp, blob)
const int payloadTypeTXTMSG =
    0x02; // a plain text message (prefixed with dest/src hashes, MAC) (enc data: timestamp, text)
const int payloadTypeACK = 0x03; // a simple ack
const int payloadTypeADVERT = 0x04; // a node advertising its Identity
const int payloadTypeGRPTXT =
    0x05; // an (unverified) group text message (prefixed with channel hash, MAC) (enc data: timestamp, "name: msg")
const int payloadTypeGRPDATA =
    0x06; // an (unverified) group datagram (prefixed with channel hash, MAC) (enc data: timestamp, blob)
const int payloadTypeANONREQ =
    0x07; // generic request (prefixed with dest_hash, ephemeral pub_key, MAC) (enc data: ...)
const int payloadTypePATH =
    0x08; // returned path (prefixed with dest/src hashes, MAC) (enc data: path, extra)
const int payloadTypeTRACE = 0x09; // trace a path, collecting SNI for each hop
const int payloadTypeMULTIPART = 0x0A; // packet is one of a set of packets
const int payloadTypeCONTROL = 0x0B; // a control/discovery packet
//...
const int payloadTypeRawCustom =
    0x0F; // custom packet as raw bytes, for applications with custom encryption, payloads, etc

// Sizes
const int pubKeySize = 32;
const int maxPathSize = 64;
const int pathHashSize = 1;
const int maxNameSize = 32;
const int maxFrameSize = 172;

/// Maximum channel-datagram payload used by MeshCore One and SAR. Firmware's
/// command builder clamps to this value even though the BLE frame has a few
/// spare bytes in flood mode.
const int channelDataMaxPayloadBytes = 163;
const int floodPathSentinel = 0xFF;

/// MeshCore's developer/experimental application namespace. Meshcore-SAR
/// uses `MeshCoreConstants.dataTypeDev`, whose wire value is 0xFFFF.
const int dataTypeDev = 0xFFFF;
const int appProtocolVersion = 10;
const int defaultPathHashMode = 1; // 2-byte hashes
// Matches firmware MAX_TEXT_LEN (10 * CIPHER_BLOCK_SIZE).
const int maxTextPayloadBytes = 160;
const int _sendTextMsgOverheadBytes =
    1 + 1 + 1 + 4 + 6 + 1 + 2; // +2 safety margin
const int _sendChannelTextMsgOverheadBytes =
    1 + 1 + 1 + 4 + 1 + 2; // +2 safety margin

int maxContactMessageBytes() {
  final byFrame = maxFrameSize - _sendTextMsgOverheadBytes;
  return _minPositive(byFrame, maxTextPayloadBytes);
}

int maxChannelMessageBytes(String? senderName) {
  final nameLength = _senderNameBytes(senderName);
  final prefixBytes = nameLength + 2; // "<name>: "
  final byPayload = maxTextPayloadBytes - prefixBytes;
  final byFrame = maxFrameSize - _sendChannelTextMsgOverheadBytes;
  return _minPositive(byPayload, byFrame);
}

/// Maximum payload bytes that can accompany a raw-data command for a literal
/// path of [pathLength] bytes. The result includes the custom packet header
/// (for example the six-byte `V` or `I` media header).
int maxRawDataPayloadBytesForPath(int pathLength) {
  if (pathLength < 0 || pathLength > maxPathSize) {
    throw ArgumentError.value(
      pathLength,
      'pathLength',
      'must be between 0 and $maxPathSize bytes',
    );
  }
  // [command][path length][path bytes][raw payload bytes].
  return maxFrameSize - 2 - pathLength;
}

/// Convert a discovered route containing multi-byte path hashes to the
/// literal one-byte-per-hop path accepted by the companion's raw-data
/// command.  The normal text/channel commands use an encoded path descriptor,
/// but `CMD_SEND_RAW_DATA` (0x19) consumes a byte count followed by one byte
/// for each hop.  Meshcore-SAR performs this same down-sampling before it
/// sends media fetches and fragments.
Uint8List rawDataPathForRoute({
  required int hopCount,
  required Uint8List path,
  required int hashSizeBytes,
}) {
  if (hopCount < 0 || hopCount > maxPathSize) {
    throw ArgumentError.value(
      hopCount,
      'hopCount',
      'must be between 0 and $maxPathSize',
    );
  }
  if (hashSizeBytes < 1 || hashSizeBytes > 3) {
    throw ArgumentError.value(
      hashSizeBytes,
      'hashSizeBytes',
      'must be between 1 and 3',
    );
  }
  final requiredBytes = hopCount * hashSizeBytes;
  if (path.length < requiredBytes) {
    throw ArgumentError.value(
      path.length,
      'path',
      'must contain at least $requiredBytes bytes for $hopCount hops',
    );
  }
  if (hopCount == 0) return Uint8List(0);
  if (hashSizeBytes == 1) {
    return Uint8List.fromList(path.sublist(0, hopCount));
  }
  return Uint8List.fromList([
    for (var hop = 0; hop < hopCount; hop++) path[hop * hashSizeBytes],
  ]);
}

/// Build `CMD_SEND_RAW_DATA` for a direct route.
///
/// The companion expects a literal path-byte count, followed by those path
/// bytes and the custom payload. This function validates the complete frame
/// against [maxFrameSize] and never truncates either input.
Uint8List buildSendRawDataFrame({
  required Uint8List path,
  required Uint8List payload,
  int? pathLength,
}) {
  final length = pathLength ?? path.length;
  if (length < 0 || length > maxPathSize) {
    throw ArgumentError.value(
      length,
      'pathLength',
      'must be between 0 and $maxPathSize bytes',
    );
  }
  if (path.length != length) {
    throw ArgumentError.value(
      path.length,
      'path',
      'must contain exactly $length bytes',
    );
  }
  final maxPayload = maxRawDataPayloadBytesForPath(length);
  if (payload.isEmpty) {
    throw ArgumentError.value(payload, 'payload', 'must not be empty');
  }
  if (payload.length > maxPayload) {
    throw ArgumentError.value(
      payload.length,
      'payload',
      'exceeds $maxPayload bytes for a $length-byte path',
    );
  }

  final writer = BufferWriter();
  writer.writeByte(cmdSendRawData);
  writer.writeByte(length);
  writer.writeBytes(path);
  writer.writeBytes(payload);
  final frame = writer.toBytes();
  // Keep this assertion next to the builder so a future framing change cannot
  // accidentally bypass the companion limit.
  if (frame.length > maxFrameSize) {
    throw StateError('Raw-data frame exceeds $maxFrameSize bytes');
  }
  return frame;
}

/// Decoded `CMD_SEND_RAW_DATA` frame. This is also useful for validating test
/// fixtures before they are handed to a transport.
class RawDataFrame {
  final Uint8List path;
  final Uint8List payload;

  const RawDataFrame({required this.path, required this.payload});

  int get pathLength => path.length;

  static RawDataFrame? tryParse(Uint8List frame) {
    if (frame.length < 3 ||
        frame.length > maxFrameSize ||
        frame[0] != cmdSendRawData) {
      return null;
    }
    final pathLength = frame[1];
    if (pathLength > maxPathSize || frame.length < 2 + pathLength + 1) {
      return null;
    }
    final payloadOffset = 2 + pathLength;
    return RawDataFrame(
      path: Uint8List.fromList(frame.sublist(2, payloadOffset)),
      payload: Uint8List.fromList(frame.sublist(payloadOffset)),
    );
  }
}

/// Build `CMD_SEND_CHANNEL_DATA`.
///
/// Wire format is `[0x3E][channel][pathLen][path?][dataType LE16][payload]`.
/// A path length of `0xFF` requests flooding and therefore has no path bytes.
/// The payload is capped at 163 bytes, matching MeshCore One's PacketBuilder
/// and the SAR client. The reference builder truncates an oversized payload;
/// callers should therefore validate media sizes before invoking this helper.
Uint8List buildSendChannelDataFrame({
  required int channelIndex,
  required int dataType,
  required Uint8List payload,
  int pathLength = floodPathSentinel,
  Uint8List? pathBytes,
}) {
  if (channelIndex < 0 || channelIndex > 0xFF) {
    throw ArgumentError.value(channelIndex, 'channelIndex', 'must be 0..255');
  }
  if (dataType <= 0 || dataType > 0xFFFF) {
    throw ArgumentError.value(dataType, 'dataType', 'must be 1..65535');
  }
  if (payload.isEmpty) {
    throw ArgumentError.value(payload.length, 'payload', 'must not be empty');
  }
  final path = pathBytes ?? Uint8List(0);
  if (pathLength < 0 || pathLength > 0xFF) {
    throw ArgumentError.value(pathLength, 'pathLength', 'must be 0..255');
  }
  if (pathLength == floodPathSentinel) {
    if (path.isNotEmpty) {
      throw ArgumentError.value(
        path,
        'pathBytes',
        'must be empty for a flood path',
      );
    }
  } else {
    final expected = decodePathByteLength(pathLength);
    if (path.length != expected) {
      throw ArgumentError.value(
        path.length,
        'pathBytes',
        'must contain exactly $expected bytes for pathLength $pathLength',
      );
    }
  }

  final boundedPayload = payload.length > channelDataMaxPayloadBytes
      ? Uint8List.fromList(payload.sublist(0, channelDataMaxPayloadBytes))
      : payload;
  final frameLength = 1 + 1 + 1 + path.length + 2 + boundedPayload.length;
  if (frameLength > maxFrameSize) {
    throw ArgumentError.value(
      boundedPayload.length,
      'payload',
      'channel data frame exceeds $maxFrameSize bytes',
    );
  }
  final writer = BufferWriter();
  writer.writeByte(cmdSendChannelData);
  writer.writeByte(channelIndex);
  writer.writeByte(pathLength);
  if (path.isNotEmpty) writer.writeBytes(path);
  writer.writeUInt16LE(dataType);
  writer.writeBytes(boundedPayload);
  return writer.toBytes();
}

/// Parsed `RESP_CODE_CHANNEL_DATA_RECV` notification. The opcode is retained
/// in the input frame and stripped by this parser.
class ChannelDataFrame {
  final double snr;
  final int channelIndex;
  final int pathLength;
  final int dataType;
  final Uint8List payload;

  const ChannelDataFrame({
    required this.snr,
    required this.channelIndex,
    required this.pathLength,
    required this.dataType,
    required this.payload,
  });

  static ChannelDataFrame? tryParse(Uint8List frame) {
    // opcode + snr + reserved(2) + channel + path + type(2) + len
    if (frame.length < 9 || frame[0] != respCodeChannelDataReceived) {
      return null;
    }
    final dataLength = frame[8];
    final available = frame.length - 9;
    final length = dataLength <= available ? dataLength : available;
    return ChannelDataFrame(
      snr: frame[1].toSigned(8) / 4.0,
      channelIndex: frame[4],
      pathLength: frame[5],
      dataType: readUint16LE(frame, 6),
      payload: Uint8List.fromList(frame.sublist(9, 9 + length)),
    );
  }
}

int _senderNameBytes(String? senderName) {
  if (senderName == null || senderName.isEmpty) return maxNameSize - 1;
  final bytes = utf8.encode(senderName);
  final maxBytes = maxNameSize - 1;
  return bytes.length > maxBytes ? maxBytes : bytes.length;
}

int _minPositive(int a, int b) {
  final minValue = a < b ? a : b;
  return minValue < 0 ? 0 : minValue;
}

/// Path hash mode stored in firmware prefs: 0=1-byte, 1=2-byte, 2=3-byte.
bool isValidPathHashMode(int mode) => mode >= 0 && mode <= 2;

/// Parses `get path.hash.mode` CLI response (expects 0, 1, or 2).
int? parsePathHashModeCliValue(String value) {
  if (value.contains(',')) return null;
  final mode = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
  if (mode == null || !isValidPathHashMode(mode)) return null;
  return mode;
}

int pathHashBytesForMode(int mode) => (mode.clamp(0, 2)) + 1;

int pathHashModeForBytes(int hashSizeBytes) => (hashSizeBytes.clamp(1, 3)) - 1;

/// Hop count from encoded path_length byte (bits 0-5).
int decodePathHopCount(int pathLenByte) => pathLenByte & 0x3F;

/// Hash size in bytes from encoded path_length byte (bits 6-7).
int decodePathHashSize(int pathLenByte) {
  final sizeCode = (pathLenByte >> 6) & 0x03;
  if (sizeCode >= 3) return 1;
  return sizeCode + 1;
}

/// Total path field byte length from encoded path_length metadata.
int decodePathByteLength(int pathLenByte) {
  if (pathLenByte == 0 || pathLenByte == 0xFF) return 0;
  if ((pathLenByte & 0xC0) != 0) {
    return decodePathHopCount(pathLenByte) * decodePathHashSize(pathLenByte);
  }
  return pathLenByte;
}

/// Encode path_length metadata for multibyte path hashes.
int encodePathLength({required int hopCount, required int hashSizeBytes}) {
  final sizeCode = (hashSizeBytes.clamp(1, 3) - 1) & 0x03;
  return ((sizeCode & 0x03) << 6) | (hopCount & 0x3F);
}

/// Resolve hop count and hash size from a contact/path length field.
///
/// When the field doesn't self-describe its hash size (top 2 bits unset),
/// [fallbackHashSizeBytes] (the app's currently configured/negotiated path
/// hash mode) is used instead of assuming legacy 1-byte hashes, since
/// firmware doesn't always set those bits even when using multi-byte hashes.
({int hopCount, int hashSizeBytes, int pathByteLength}) parsePathLengthField(
  int pathLenField, {
  int fallbackHashSizeBytes = 1,
}) {
  if (pathLenField <= 0) {
    return (
      hopCount: 0,
      hashSizeBytes: fallbackHashSizeBytes,
      pathByteLength: 0,
    );
  }
  if ((pathLenField & 0xC0) != 0) {
    final hashSize = decodePathHashSize(pathLenField);
    final hopCount = decodePathHopCount(pathLenField);
    return (
      hopCount: hopCount,
      hashSizeBytes: hashSize,
      pathByteLength: hopCount * hashSize,
    );
  }
  final hashSize = fallbackHashSizeBytes.clamp(1, 3);
  return (
    hopCount: pathLenField,
    hashSizeBytes: hashSize,
    pathByteLength: pathLenField * hashSize,
  );
}

String formatPathIdList(Uint8List pathBytes, {required int hashSizeBytes}) {
  if (pathBytes.isEmpty) return '';
  final parts = <String>[];
  for (var i = 0; i < pathBytes.length; i += hashSizeBytes) {
    final end = (i + hashSizeBytes) <= pathBytes.length
        ? (i + hashSizeBytes)
        : pathBytes.length;
    final chunk = pathBytes.sublist(i, end);
    parts.add(
      chunk
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(),
    );
  }
  return parts.join(',');
}

bool pathBytesMatchPublicKey(
  Uint8List pathBytes,
  Uint8List publicKey, {
  required int hashSizeBytes,
}) {
  if (pathBytes.isEmpty || publicKey.length < hashSizeBytes) return false;
  for (var i = 0; i + hashSizeBytes <= pathBytes.length; i += hashSizeBytes) {
    final prefix = pathBytes.sublist(i, i + hashSizeBytes);
    var matches = true;
    for (var j = 0; j < prefix.length; j++) {
      if (publicKey[j] != prefix[j]) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }
  return false;
}

// Contact frame offsets
const int contactPubKeyOffset = 1;
const int contactTypeOffset = 33;
const int contactFlagsOffset = 34;
const int contactPathLenOffset = 35;
const int contactPathOffset = 36;
const int contactNameOffset = 100;
const int contactTimestampOffset = 132;
const int contactLatOffset = 136;
const int contactLonOffset = 140;
const int contactLastmodOffset = 144;
const int contactFrameSize = 148;

// Message frame offsets
const int msgPubKeyOffset = 1;
const int msgTimestampOffset = 33;
const int msgFlagsOffset = 37;
const int msgTextOffset = 38;

class ParsedContactText {
  final Uint8List senderPrefix;
  final String text;

  const ParsedContactText({required this.senderPrefix, required this.text});
}

ParsedContactText? parseContactMessageText(Uint8List frame) {
  if (frame.isEmpty) return null;
  final code = frame[0];
  if (code != respCodeContactMsgRecv && code != respCodeContactMsgRecvV3) {
    return null;
  }

  // Companion radio layout:
  // [code][snr?][res?][res?][prefix x6][path_len][txt_type][timestamp x4][extra?][text...]
  final isV3 = code == respCodeContactMsgRecvV3;
  final prefixOffset = isV3 ? 4 : 1;
  const prefixLen = 6;
  final txtTypeOffset = prefixOffset + prefixLen + 1;
  final timestampOffset = txtTypeOffset + 1;
  final baseTextOffset = timestampOffset + 4;
  if (frame.length <= baseTextOffset) return null;

  final flags = frame[txtTypeOffset];
  final shiftedType = flags >> 2;
  final rawType = flags;
  final isPlain = shiftedType == txtTypePlain || rawType == txtTypePlain;
  final isCli = shiftedType == txtTypeCliData || rawType == txtTypeCliData;
  if (!isPlain && !isCli) {
    return null;
  }

  var text = readCString(
    frame,
    baseTextOffset,
    frame.length - baseTextOffset,
  ).trim();
  if (text.isEmpty && frame.length > baseTextOffset + 4) {
    text = readCString(
      frame,
      baseTextOffset + 4,
      frame.length - (baseTextOffset + 4),
    ).trim();
  }
  if (text.isEmpty) return null;

  final senderPrefix = frame.sublist(prefixOffset, prefixOffset + prefixLen);
  return ParsedContactText(senderPrefix: senderPrefix, text: text);
}

// Helper to read uint32 little-endian
int readUint32LE(Uint8List data, int offset) {
  return data[offset] |
      (data[offset + 1] << 8) |
      (data[offset + 2] << 16) |
      (data[offset + 3] << 24);
}

// Helper to read uint16 little-endian
int readUint16LE(Uint8List data, int offset) {
  return data[offset] | (data[offset + 1] << 8);
}

// Helper to read int32 little-endian
int readInt32LE(Uint8List data, int offset) {
  int val = readUint32LE(data, offset);
  if (val >= 0x80000000) val -= 0x100000000;
  return val;
}

// Helper to read null-terminated UTF-8 string
String readCString(Uint8List data, int offset, int maxLen) {
  int end = offset;
  while (end < offset + maxLen && end < data.length && data[end] != 0) {
    end++;
  }
  try {
    return utf8.decode(data.sublist(offset, end), allowMalformed: true);
  } catch (e) {
    // Fallback to Latin-1 if UTF-8 decoding fails
    return String.fromCharCodes(data.sublist(offset, end));
  }
}

// Helper to convert public key to hex string
String pubKeyToHex(Uint8List pubKey) {
  return pubKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

// Helper to convert hex string to public key
Uint8List hexToPubKey(String hex) {
  if (hex.length.isOdd) {
    throw ArgumentError.value(hex, 'hex', 'hex string must have even length');
  }
  final result = Uint8List(pubKeySize);
  final byteCount = hex.length ~/ 2;
  for (int i = 0; i < pubKeySize && i < byteCount; i++) {
    final byte = int.tryParse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    if (byte == null) {
      throw ArgumentError.value(
        hex,
        'hex',
        'hex string contains non-hex chars',
      );
    }
    result[i] = byte;
  }
  return result;
}

// Build CMD_GET_CONTACTS frame
Uint8List buildGetContactsFrame({int? since}) {
  final writer = BufferWriter();
  writer.writeByte(cmdGetContacts);
  if (since != null) {
    writer.writeUInt32LE(since);
  }
  return writer.toBytes();
}

// Build CMD_SEND_LOGIN frame
// Format: [cmd][pub_key x32][password...]\0
Uint8List buildSendLoginFrame(Uint8List recipientPubKey, String password) {
  final writer = BufferWriter();
  writer.writeByte(cmdSendLogin);
  writer.writeBytes(recipientPubKey);
  writer.writeString(password);
  writer.writeByte(0);
  return writer.toBytes();
}

// Build CMD_SEND_STATUS_REQ frame
// Format: [cmd][pub_key x32]
Uint8List buildSendStatusRequestFrame(Uint8List recipientPubKey) {
  final writer = BufferWriter();
  writer.writeByte(cmdSendStatusReq);
  writer.writeBytes(recipientPubKey);
  return writer.toBytes();
}

// Build CMD_SEND_TXT_MSG frame (companion_radio format)
// Format: [cmd][txt_type][attempt][timestamp x4][pub_key_prefix x6][text...]\0
Uint8List buildSendTextMsgFrame(
  Uint8List recipientPubKey,
  String text, {
  int attempt = 0,
  int? timestampSeconds,
}) {
  if (recipientPubKey.length < 6) {
    throw ArgumentError.value(
      recipientPubKey,
      'recipientPubKey',
      'must be at least 6 bytes (pubkey prefix)',
    );
  }
  final timestamp =
      timestampSeconds ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
  final writer = BufferWriter();
  writer.writeByte(cmdSendTxtMsg);
  writer.writeByte(txtTypePlain);
  writer.writeByte(attempt.clamp(0, 3));
  writer.writeUInt32LE(timestamp);
  writer.writeBytes(recipientPubKey.sublist(0, 6));
  writer.writeString(text);
  writer.writeByte(0);
  return writer.toBytes();
}

// Build CMD_SEND_CHANNEL_TXT_MSG frame
// Format: [cmd][txt_type][channel_idx][timestamp x4][text...]
Uint8List buildSendChannelTextMsgFrame(int channelIndex, String text) {
  final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final writer = BufferWriter();
  writer.writeByte(cmdSendChannelTxtMsg);
  writer.writeByte(txtTypePlain);
  writer.writeByte(channelIndex);
  writer.writeUInt32LE(timestamp);
  writer.writeString(text);
  writer.writeByte(0);
  return writer.toBytes();
}

// Build CMD_REMOVE_CONTACT frame
Uint8List buildRemoveContactFrame(Uint8List pubKey) {
  final writer = BufferWriter();
  writer.writeByte(cmdRemoveContact);
  writer.writeBytes(pubKey);
  return writer.toBytes();
}

// Build CMD_APP_START frame
// Format: [cmd][app_ver][reserved x6][app_name...]
Uint8List buildAppStartFrame({
  String appName = 'Gulf Coast Mesh App',
  int appVersion = 1,
}) {
  final writer = BufferWriter();
  writer.writeByte(cmdAppStart);
  writer.writeByte(appVersion);
  writer.writeBytes(Uint8List(6)); // reserved bytes
  writer.writeString(appName);
  writer.writeByte(0);
  return writer.toBytes();
}

// Build CMD_DEVICE_QUERY frame
Uint8List buildDeviceQueryFrame({int appVersion = appProtocolVersion}) {
  return Uint8List.fromList([cmdDeviceQuery, appVersion]);
}

// Build CMD_GET_DEVICE_TIME frame
Uint8List buildGetDeviceTimeFrame() {
  return Uint8List.fromList([cmdGetDeviceTime]);
}

// Build CMD_GET_BATT_AND_STORAGE frame
Uint8List buildGetBattAndStorageFrame() {
  return Uint8List.fromList([cmdGetBattAndStorage]);
}

// Build CMD_SET_DEVICE_TIME frame
Uint8List buildSetDeviceTimeFrame(int timestamp) {
  final writer = BufferWriter();
  writer.writeByte(cmdSetDeviceTime);
  writer.writeUInt32LE(timestamp);
  return writer.toBytes();
}

// Build CMD_SEND_SELF_ADVERT frame
// Format: [cmd][flood_flag]
Uint8List buildSendSelfAdvertFrame({bool flood = false}) {
  return Uint8List.fromList([cmdSendSelfAdvert, flood ? 1 : 0]);
}

// Build CMD_SET_ADVERT_NAME frame
// Format: [cmd][name...]
Uint8List buildSetAdvertNameFrame(String name) {
  final writer = BufferWriter();
  writer.writeByte(cmdSetAdvertName);
  writer.writeBytes(_encodeUtf8Prefix(name, maxNameSize - 1));
  return writer.toBytes();
}

// Build CMD_SET_ADVERT_LATLON frame
// Format: [cmd][lat x4][lon x4]
Uint8List buildSetAdvertLatLonFrame(double lat, double lon) {
  final writer = BufferWriter();
  writer.writeByte(cmdSetAdvertLatLon);
  writer.writeInt32LE((lat * 1000000).round());
  writer.writeInt32LE((lon * 1000000).round());
  return writer.toBytes();
}

Uint8List buildSetCustomVarFrame(String value) {
  final writer = BufferWriter();
  writer.writeByte(cmdSetCustomVar);
  writer.writeString(value);
  writer.writeByte(0);
  return writer.toBytes();
}

// Build CMD_REBOOT frame
// Format: [cmd]["reboot"]
Uint8List buildRebootFrame() {
  return Uint8List.fromList([cmdReboot, ...utf8.encode('reboot')]);
}

// Build CMD_SYNC_NEXT_MESSAGE frame
Uint8List buildSyncNextMessageFrame() {
  return Uint8List.fromList([cmdSyncNextMessage]);
}

// Build CMD_GET_CHANNEL frame
Uint8List buildGetChannelFrame(int channelIndex) {
  return Uint8List.fromList([cmdGetChannel, channelIndex]);
}

// Build CMD_SET_CHANNEL frame
// Format: [cmd][idx][name x32][psk x16]
Uint8List buildSetChannelFrame(int channelIndex, String name, Uint8List psk) {
  final writer = BufferWriter();
  writer.writeByte(cmdSetChannel);
  writer.writeByte(channelIndex);
  writer.writeCString(name, 32);
  // Write PSK (16 bytes, zero-padded)
  final pskPadded = Uint8List(16);
  for (int i = 0; i < 16 && i < psk.length; i++) {
    pskPadded[i] = psk[i];
  }
  writer.writeBytes(pskPadded);
  return writer.toBytes();
}

// Build CMD_SET_RADIO_PARAMS frame
// Format: [cmd][freq x4][bw x4][sf][cr] (pre-v9)
//         [cmd][freq x4][bw x4][sf][cr][repeat] (firmware v9+)
// freq: frequency in Hz (300000-2500000)
// bw: bandwidth in Hz (7000-500000)
// sf: spreading factor (5-12)
// cr: coding rate (5-8)
// clientRepeat: enable off-grid packet repeat (firmware v9+, omit for older)
Uint8List buildSetRadioParamsFrame(
  int freqHz,
  int bwHz,
  int sf,
  int cr, {
  bool? clientRepeat,
}) {
  final writer = BufferWriter();
  writer.writeByte(cmdSetRadioParams);
  writer.writeUInt32LE(freqHz);
  writer.writeUInt32LE(bwHz);
  writer.writeByte(sf);
  writer.writeByte(cr);
  if (clientRepeat != null) {
    writer.writeByte(clientRepeat ? 1 : 0);
  }
  return writer.toBytes();
}

// Build CMD_SET_RADIO_TX_POWER frame
// Format: [cmd][power_dbm]
Uint8List buildSetRadioTxPowerFrame(int powerDbm) {
  return Uint8List.fromList([cmdSetRadioTxPower, powerDbm]);
}

// Build CMD_RESET_PATH frame
// Format: [cmd][pub_key x32]
Uint8List buildResetPathFrame(Uint8List pubKey) {
  final writer = BufferWriter();
  writer.writeByte(cmdResetPath);
  writer.writeBytes(pubKey);
  return writer.toBytes();
}

// Build CMD_ADD_UPDATE_CONTACT frame to set custom path
// Format: [cmd][pub_key x32][type][flags][path_len][path x64][name x32][timestamp x4]
Uint8List buildUpdateContactPathFrame(
  Uint8List pubKey,
  Uint8List customPath,
  int pathLen, {
  int type = 1, // ADV_TYPE_CHAT
  int flags = 0,
  String name = '',
}) {
  final writer = BufferWriter();
  writer.writeByte(cmdAddUpdateContact);
  writer.writeBytes(pubKey);
  writer.writeByte(type);
  writer.writeByte(flags);
  writer.writeByte(pathLen);

  // Path data (64 bytes, zero-padded)
  final pathPadded = Uint8List(maxPathSize);
  if (customPath.isNotEmpty && pathLen > 0) {
    final copyLen = customPath.length < maxPathSize
        ? customPath.length
        : maxPathSize;
    for (int i = 0; i < copyLen; i++) {
      pathPadded[i] = customPath[i];
    }
  }
  writer.writeBytes(pathPadded);

  // Name (32 bytes, null-padded)
  writer.writeCString(name, maxNameSize);

  // Timestamp
  final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  writer.writeUInt32LE(timestamp);

  return writer.toBytes();
}

// Build CMD_GET_CONTACT_BY_KEY frame
// Format: [cmd][pub_key x32]
Uint8List buildGetContactByKeyFrame(Uint8List pubKey) {
  final writer = BufferWriter();
  writer.writeByte(cmdGetContactByKey);
  writer.writeBytes(pubKey);
  return writer.toBytes();
}

// Build CMD_GET_RADIO_SETTINGS frame
Uint8List buildGetRadioSettingsFrame() {
  return Uint8List.fromList([cmdGetRadioSettings]);
}

//Build CMD_GET_CUSTOM_VARS frame
Uint8List buildGetCustomVarsFrame() {
  return Uint8List.fromList([cmdGetCustomVar]);
}

// Calculate LoRa airtime for a packet
// Based on Semtech SX127x datasheet formula
// Returns airtime in milliseconds
int calculateLoRaAirtime({
  required int payloadBytes,
  required int spreadingFactor,
  required int bandwidthHz,
  required int codingRate,
  int preambleSymbols = 8,
  bool lowDataRateOptimize = false,
  bool explicitHeader = true,
}) {
  // Symbol duration (Ts) in milliseconds
  final symbolDuration = (1 << spreadingFactor) / (bandwidthHz / 1000.0);

  // Preamble time
  final preambleTime = (preambleSymbols + 4.25) * symbolDuration;

  // Payload symbol count
  final headerBytes = explicitHeader ? 0 : 20;
  final crc = 1; // CRC enabled
  final de = lowDataRateOptimize ? 1 : 0;

  final numerator =
      8 * payloadBytes - 4 * spreadingFactor + 28 + 16 * crc - headerBytes;
  final denominator = 4 * (spreadingFactor - 2 * de);
  var payloadSymbols =
      8 + ((numerator / denominator).ceil()) * (codingRate + 4);

  if (payloadSymbols < 0) {
    payloadSymbols = 8;
  }

  final payloadTime = payloadSymbols * symbolDuration;

  return (preambleTime + payloadTime).ceil();
}

// Calculate timeout for a message based on radio settings
// Returns timeout in milliseconds
int calculateMessageTimeout({
  required int freqHz,
  required int bwHz,
  required int sf,
  required int cr,
  required int pathLength,
  int messageBytes = 100, // Average message size
}) {
  // Calculate airtime for one packet
  final airtime = calculateLoRaAirtime(
    payloadBytes: messageBytes,
    spreadingFactor: sf,
    bandwidthHz: bwHz,
    codingRate: cr,
    lowDataRateOptimize: sf >= 11,
  );

  if (pathLength < 0) {
    // Flood mode: Base delay + 16× airtime
    return 500 + (16 * airtime);
  } else {
    // Direct path: Base delay + ((airtime×6 + 250ms)×(hops+1))
    return 500 + ((airtime * 6 + 250) * (pathLength + 1));
  }
}

// Build CLI command text message frame (companion_radio format)
// Format: [cmd][txt_type][attempt][timestamp x4][pub_key_prefix x6][text...]\0
Uint8List buildSendCliCommandFrame(
  Uint8List repeaterPubKey,
  String command, {
  int attempt = 0,
  int? timestampSeconds,
}) {
  final timestamp =
      timestampSeconds ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
  final writer = BufferWriter();
  writer.writeByte(cmdSendTxtMsg);
  writer.writeByte(txtTypeCliData);
  writer.writeByte(attempt.clamp(0, 3));
  writer.writeUInt32LE(timestamp);
  writer.writeBytes(repeaterPubKey.sublist(0, 6));
  writer.writeString(command);
  writer.writeByte(0);
  return writer.toBytes();
}

// Build a telemetry request frame
// Format: [cmd][pub_key x32][payload]
Uint8List buildSendBinaryReq(Uint8List repeaterPubKey, {Uint8List? payload}) {
  final writer = BufferWriter();
  writer.writeByte(cmdSendBinaryReq);
  writer.writeBytes(repeaterPubKey);
  if (payload != null && payload.isNotEmpty) {
    writer.writeBytes(payload);
  }
  return writer.toBytes();
}

//Build a trace request frame
//[cmd][tag x4][auth x4][flag][payload]
Uint8List buildTraceReq(int tag, int auth, int flag, {Uint8List? payload}) {
  final writer = BufferWriter();
  writer.writeByte(cmdSendTracePath);
  writer.writeUInt32LE(tag);
  writer.writeUInt32LE(auth);
  writer.writeByte(flag);
  if (payload != null && payload.isNotEmpty) {
    writer.writeBytes(payload);
  }
  return writer.toBytes();
}

// Build a export contact frame
// [cmd][pub_key x32 / if empty exports your contact info]
Uint8List buildExportContactFrame(Uint8List pubKey) {
  final writer = BufferWriter();
  writer.writeByte(cmdExportContact);
  writer.writeBytes(pubKey);
  return writer.toBytes();
}

// Build a import contact frame
// [cmd][contact_frame x98+]
/// Builds CMD_IMPORT_CONTACT from a hex advert payload.
///
/// [contactFrame] comes from a QR code or the clipboard, so its length is
/// attacker-controlled; reject anything that cannot fit a companion frame
/// rather than handing an oversized write to the transport.
Uint8List buildImportContactFrame(String contactFrame) {
  final writer = BufferWriter();
  writer.writeByte(cmdImportContact);
  writer.writeHex(contactFrame);
  final frame = writer.toBytes();
  if (frame.length > maxFrameSize) {
    throw ArgumentError.value(
      contactFrame,
      'contactFrame',
      'contact advert is ${frame.length} bytes, over the $maxFrameSize limit',
    );
  }
  return frame;
}

// Build a export contact frame
// [cmd][pub_key x32]
Uint8List buildZeroHopContact(Uint8List pubKey) {
  final writer = BufferWriter();
  writer.writeByte(cmdShareContact);
  writer.writeBytes(pubKey);
  return writer.toBytes();
}

// Build CMD_SET_OTHER_PARAMS frame
// Format: [cmd][allowAutoAddContacts][allowTelemetryFlags][advertLocationPolicy][multiAcks]
Uint8List buildSetOtherParamsFrame(
  bool allowAutoAddContacts,
  int allowTelemetryFlags,
  int advertLocationPolicy,
  int multiAcks,
) {
  final writer = BufferWriter();
  writer.writeByte(cmdSetOtherParams);
  writer.writeByte(
    allowAutoAddContacts ? 0x00 : 0x01,
  ); // Allow Auto Add Contacts
  writer.writeByte(allowTelemetryFlags); // Allow Telemetry Flags
  writer.writeByte(advertLocationPolicy); // Advertisement Location Policy
  writer.writeByte(multiAcks); // Multi Acknowledgements
  return writer.toBytes();
}

/// Build CMD_SET_PATH_HASH_MODE frame (firmware v10+).
/// Format: [cmd][reserved=0][mode] where mode is 0=1-byte, 1=2-byte, 2=3-byte.
Uint8List buildSetPathHashModeFrame(int mode) {
  if (!isValidPathHashMode(mode)) {
    throw ArgumentError.value(mode, 'mode', 'must be 0, 1, or 2');
  }
  return Uint8List.fromList([cmdSetPathHashMode, 0, mode]);
}

/// Build CMD_SET_DEFAULT_FLOOD_SCOPE frame (firmware v11+ / MeshCore v1.15+).
///
/// Wire format:
/// - clear: `[0x3F]`
/// - set: `[0x3F][name:31 zero-padded UTF-8][key:16]`
///
/// Empty [name] clears the persisted default scope. Non-empty names are capped
/// at 30 UTF-8 bytes so firmware's `strlen` parse stays `< 31`.
Uint8List buildSetDefaultFloodScopeFrame({
  required String name,
  required Uint8List scopeKey,
}) {
  if (name.isEmpty) {
    return Uint8List.fromList([cmdSetDefaultFloodScope]);
  }

  final writer = BufferWriter();
  writer.writeByte(cmdSetDefaultFloodScope);
  writer.writeCString(name, defaultFloodScopeNameField);

  final key = Uint8List(defaultFloodScopeKeyBytes);
  for (var i = 0; i < defaultFloodScopeKeyBytes && i < scopeKey.length; i++) {
    key[i] = scopeKey[i];
  }
  writer.writeBytes(key);
  return writer.toBytes();
}

/// Build CMD_SET_FLOOD_SCOPE_KEY frame (v8+): per-send / session override.
///
/// Wire format:
/// - set: `[0x36][0x00][key x16]`
/// - clear override: `[0x36][0x00]`
/// - unscoped sends: `[0x36][0x01]` (firmware v12+)
Uint8List buildSetFloodScopeKeyFrame(Uint8List scopeKey) {
  final key = Uint8List(defaultFloodScopeKeyBytes);
  for (var i = 0; i < defaultFloodScopeKeyBytes && i < scopeKey.length; i++) {
    key[i] = scopeKey[i];
  }
  final writer = BufferWriter();
  writer.writeByte(cmdSetFloodScopeKey);
  writer.writeByte(0x00);
  writer.writeBytes(key);
  return writer.toBytes();
}

/// Clear the session flood-scope key override (`[0x36][0x00]`).
Uint8List buildClearFloodScopeKeyFrame() {
  return Uint8List.fromList([cmdSetFloodScopeKey, 0x00]);
}

/// Force unscoped flood sends for this session (`[0x36][0x01]`, v12+).
Uint8List buildUnscopedFloodScopeFrame() {
  return Uint8List.fromList([cmdSetFloodScopeKey, 0x01]);
}

/// Build CMD_GET_DEFAULT_FLOOD_SCOPE frame (firmware v11+).
Uint8List buildGetDefaultFloodScopeFrame() {
  return Uint8List.fromList([cmdGetDefaultFloodScope]);
}

/// Parsed RESP_CODE_DEFAULT_FLOOD_SCOPE payload (without response code byte).
class DefaultFloodScopeInfo {
  final String name;
  final Uint8List key;

  const DefaultFloodScopeInfo({required this.name, required this.key});

  /// Parse payload after the response code.
  ///
  /// Empty payload means no default scope is configured.
  static DefaultFloodScopeInfo? fromPayload(Uint8List payload) {
    if (payload.isEmpty) return null;
    if (payload.length <
        defaultFloodScopeNameField + defaultFloodScopeKeyBytes) {
      return null;
    }
    final name = readCString(payload, 0, defaultFloodScopeNameField);
    if (name.isEmpty) return null;
    final key = Uint8List.fromList(
      payload.sublist(
        defaultFloodScopeNameField,
        defaultFloodScopeNameField + defaultFloodScopeKeyBytes,
      ),
    );
    return DefaultFloodScopeInfo(name: name, key: key);
  }
}

/// Build CMD_SEND_CONTROL_DATA frame for a zero-hop DISCOVER_REQ.
///
/// The companion wire format is exactly `[0x37][0x80][0x06][tag x4]
/// [since x4]`.  In particular, there is no extra control subtype byte.
Uint8List buildSendDiscoverReqFrame({
  required int tag,
  int typeFilter = discoverTypeFilterRepeaterRoom,
  int since = 0,
}) {
  final writer = BufferWriter();
  writer.writeByte(cmdSendControlData);
  writer.writeByte(discoverReqSubType);
  writer.writeByte(typeFilter);
  writer.writeUInt32LE(tag);
  writer.writeUInt32LE(since);
  return writer.toBytes();
}

/// Parsed DISCOVER_RESP from PUSH_CODE_CONTROL_DATA companion frame.
class DiscoverResponse {
  final Uint8List tag;
  final int nodeType;
  final double localSnr;
  final int localRssi;
  final double remoteSnr;
  final String pubkeyHex;
  final String? pathHopHex;

  const DiscoverResponse({
    required this.tag,
    required this.nodeType,
    required this.localSnr,
    required this.localRssi,
    required this.remoteSnr,
    required this.pubkeyHex,
    this.pathHopHex,
  });

  String repeaterId(int hopBytes) {
    if (pathHopHex != null && pathHopHex!.isNotEmpty) {
      return pathHopHex!;
    }
    final hexLen = (hopBytes.clamp(1, 3)) * 2;
    if (pubkeyHex.length <= hexLen) return pubkeyHex;
    return pubkeyHex.substring(0, hexLen);
  }

  String get nodeTypeName =>
      nodeType == discoverNodeTypeRepeater ? 'REPEATER' : 'ROOM';
}

/// Parse PUSH_CODE_CONTROL_DATA frame body for DISCOVER_RESP.
DiscoverResponse? parseDiscoverResponseFrame(
  Uint8List frame, {
  int hopBytes = 1,
}) {
  if (frame.isEmpty || frame[0] != pushCodeControlData) return null;
  if (frame.length < 40) return null;

  // [code][snr][rssi][path_len][path...][control_payload...]
  final pathLenByte = frame[3];
  final pathByteLen = decodePathByteLength(pathLenByte);
  final payloadOffset = 4 + pathByteLen;
  if (frame.length < payloadOffset + 39) return null;

  String? pathHopHex;
  if (pathByteLen > 0) {
    final hashSize = decodePathHashSize(pathLenByte);
    final hexLen = (hopBytes.clamp(1, hashSize)) * 2;
    pathHopHex = formatPathIdList(
      frame.sublist(4, 4 + hashSize.clamp(1, pathByteLen)),
      hashSizeBytes: hashSize,
    );
    if (pathHopHex.length > hexLen) {
      pathHopHex = pathHopHex.substring(0, hexLen);
    }
  }

  final payload = frame.sublist(payloadOffset);
  final flags = payload[0];
  if ((flags & 0xF0) != discoverRespSubType) return null;

  final nodeType = flags & 0x0F;
  if (nodeType != discoverNodeTypeRepeater &&
      nodeType != discoverNodeTypeRoom) {
    return null;
  }

  final remoteSnrRaw = payload[2].toSigned(8);
  final remoteSnr = remoteSnrRaw / 4.0;
  final tag = Uint8List.fromList(payload.sublist(3, 7));
  final pubkey = payload.sublist(7, 39);
  final pubkeyHex = pubkey
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();

  final localSnr = frame[1].toSigned(8) / 4.0;
  final localRssi = frame[2].toSigned(8);

  return DiscoverResponse(
    tag: tag,
    nodeType: nodeType,
    localSnr: localSnr,
    localRssi: localRssi,
    remoteSnr: remoteSnr,
    pubkeyHex: pubkeyHex,
    pathHopHex: pathHopHex,
  );
}

/// Statistics selector values accepted by CMD_GET_STATS.
const int statsTypeCore = 0;
const int statsTypeRadio = 1;
const int statsTypePackets = 2;

/// Build a radio statistics request.  The response is [respCodeStats].
Uint8List buildGetStatsFrame({int statsType = statsTypeRadio}) {
  if (statsType < 0 || statsType > 0xff) {
    throw ArgumentError.value(statsType, 'statsType');
  }
  return Uint8List.fromList([cmdGetStats, statsType]);
}

/// Radio statistics returned by MeshCore's 0x18 response.
class RadioStats {
  final int noiseFloor;
  final int lastRssi;
  final int lastSnr;
  final int txAirSeconds;
  final int rxAirSeconds;

  const RadioStats({
    required this.noiseFloor,
    required this.lastRssi,
    required this.lastSnr,
    required this.txAirSeconds,
    required this.rxAirSeconds,
  });
}

/// Parse a radio stats response.  Returns null for another stats type or a
/// truncated/oversized response (some firmware uses 0x18 for peer frames).
RadioStats? parseRadioStatsFrame(Uint8List frame) {
  if (frame.isEmpty ||
      frame[0] != respCodeStats ||
      frame.length < 14 ||
      frame.length > 31) {
    return null;
  }
  final reader = BufferReader(Uint8List.fromList(frame.sublist(1)));
  if (reader.readUInt8() != statsTypeRadio) return null;
  return RadioStats(
    noiseFloor: reader.readInt16LE(),
    lastRssi: reader.readInt8(),
    lastSnr: reader.readInt8(),
    txAirSeconds: reader.readUInt32LE(),
    rxAirSeconds: reader.readUInt32LE(),
  );
}

/// Build CMD_SEND_TRACE_PATH for a zero-hop target.
/// Format: [cmd][tag x4][auth x4][path-size][target hash].
Uint8List buildSendTracePathFrame({
  required int tag,
  required Uint8List target,
  int auth = 0,
  int hopBytes = 1,
}) {
  if (target.isEmpty ||
      !const [1, 2, 4].contains(hopBytes) ||
      target.length != hopBytes) {
    throw ArgumentError('target must contain exactly 1, 2, or 4 hash bytes');
  }
  final writer = BufferWriter();
  writer.writeByte(cmdSendTracePath);
  writer.writeUInt32LE(tag);
  writer.writeUInt32LE(auth);
  writer.writeByte(
    hopBytes == 1
        ? 0
        : hopBytes == 2
        ? 1
        : 2,
  );
  writer.writeBytes(target);
  return writer.toBytes();
}

class TraceResponse {
  final Uint8List tag;
  final List<Uint8List> path;
  final List<double> pathSnr;

  const TraceResponse({
    required this.tag,
    required this.path,
    required this.pathSnr,
  });

  String? get firstHopHex => path.isEmpty
      ? null
      : path.first
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join()
            .toUpperCase();
}

/// Parse PUSH_CODE_TRACE_DATA (0x89).  The body is
/// [reserved][path_len][flags][tag x4][auth x4][path hashes][SNR bytes].
TraceResponse? parseTraceResponseFrame(
  Uint8List frame, {
  Uint8List? expectedTag,
}) {
  var offset = frame.isNotEmpty && frame[0] == pushCodeTraceData ? 1 : 0;
  if (frame.length < offset + 11) return null;
  final body = frame.sublist(offset);
  final pathLen = body[1];
  final hashBytes = 1 << (body[2] & 3);
  if (pathLen == 0 || pathLen % hashBytes != 0) return null;
  final tag = Uint8List.fromList(body.sublist(3, 7));
  if (expectedTag != null) {
    if (expectedTag.length != 4 ||
        !List<int>.generate(
          4,
          (i) => i,
        ).every((i) => tag[i] == expectedTag[i])) {
      return null;
    }
  }
  final hopCount = pathLen ~/ hashBytes;
  final pathEnd = 11 + pathLen;
  if (body.length < pathEnd + hopCount + 1) return null;
  final path = <Uint8List>[];
  for (var i = 0; i < hopCount; i++) {
    path.add(
      Uint8List.fromList(
        body.sublist(11 + i * hashBytes, 11 + (i + 1) * hashBytes),
      ),
    );
  }
  final snr = [
    for (var i = 0; i < hopCount + 1; i++) body[pathEnd + i].toSigned(8) / 4.0,
  ];
  return TraceResponse(tag: tag, path: path, pathSnr: snr);
}
