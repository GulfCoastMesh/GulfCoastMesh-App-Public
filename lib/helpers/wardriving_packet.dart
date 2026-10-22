import 'dart:convert';
import 'dart:typed_data';

import '../connector/meshcore_protocol.dart';

const int _phRouteMask = 0x03;
const int _phTypeShift = 2;
const int _phTypeMask = 0x0F;
const int _payloadTypeGroupText = 0x05;
const int _routeTransportFlood = 0x00;
const int _routeTransportDirect = 0x03;

class WardrivingRawPacket {
  final double snr;
  final int rssi;
  final int routeType;
  final int payloadType;
  final int pathLenByte;
  final Uint8List pathBytes;
  final Uint8List payload;

  const WardrivingRawPacket({
    required this.snr,
    required this.rssi,
    required this.routeType,
    required this.payloadType,
    required this.pathLenByte,
    required this.pathBytes,
    required this.payload,
  });

  bool get isGroupText => payloadType == _payloadTypeGroupText;
  bool get isTrace => payloadType == payloadTypeTRACE;

  int get pathHashSize => decodePathHashSize(pathLenByte);

  int get pathHashCount => decodePathHopCount(pathLenByte);

  int? get channelHash => payload.isNotEmpty && isGroupText ? payload[0] : null;

  Uint8List get encryptedPayload =>
      payload.length > 1 ? payload.sublist(1) : Uint8List(0);

  String? hopHexAt(int index) {
    final hashSize = pathHashSize;
    final start = index * hashSize;
    if (start + hashSize > pathBytes.length) return null;
    return formatPathIdList(
      pathBytes.sublist(start, start + hashSize),
      hashSizeBytes: hashSize,
    );
  }

  String? get firstHopHex => hopHexAt(0);

  String? get lastHopHex =>
      pathHashCount == 0 ? null : hopHexAt(pathHashCount - 1);
}

WardrivingRawPacket? parseLogRxDataFrame(Uint8List frame) {
  if (frame.isEmpty || frame[0] != pushCodeLogRxData) return null;
  if (frame.length < 4) return null;

  final packet = BufferReader(frame);
  try {
    packet.skipBytes(1);
    final snr = packet.readInt8() / 4.0;
    final rssi = packet.readByte().toSigned(8);
    final header = packet.readByte();
    final routeType = header & _phRouteMask;
    final payloadType = (header >> _phTypeShift) & _phTypeMask;
    // Transport routes prepend 4 hash bytes before path_len (same as connector).
    if (routeType == _routeTransportFlood ||
        routeType == _routeTransportDirect) {
      packet.skipBytes(4);
    }
    final pathLenByte = packet.readByte();
    final pathByteLen = decodePathByteLength(pathLenByte);
    final pathBytes = packet.readBytes(pathByteLen);
    final payload = packet.readBytes(packet.remaining);
    return WardrivingRawPacket(
      snr: snr,
      rssi: rssi,
      routeType: routeType,
      payloadType: payloadType,
      pathLenByte: pathLenByte,
      pathBytes: pathBytes,
      payload: payload,
    );
  } catch (_) {
    return null;
  }
}

bool isCarpeaterRssi(int rssi, {int threshold = -30}) {
  return rssi >= threshold;
}

/// Returns whether an ADVERT payload has the signed-advert layout and a
/// plausible application name. This is deliberately structural only: packet
/// signature verification belongs to the radio protocol, while wardriving
/// uses it to reject malformed traffic before crediting a repeater.
///
/// Layout: `[pubkey:32][timestamp:4][signature:64][flags][lat/lon?:8][name]`.
/// The name flag is bit 7 and the optional lat/lon flag is bit 4.
bool isValidWardrivingAdvert(Uint8List payload) {
  const appDataOffset = 32 + 4 + 64;
  const advertNameFlag = 0x80;
  const advertLatLonFlag = 0x10;
  const minPrintableRatio = 0.6;

  if (payload.length <= appDataOffset) return false;
  final flags = payload[appDataOffset];
  if ((flags & advertNameFlag) == 0) return false;

  var nameOffset = appDataOffset + 1;
  if ((flags & advertLatLonFlag) != 0) nameOffset += 8;
  if (payload.length <= nameOffset) return false;

  try {
    var name = utf8.decode(payload.sublist(nameOffset), allowMalformed: true);
    name = name.replaceFirst(RegExp(r'\x00+$'), '').trim();
    if (name.isEmpty) return false;

    var printable = 0;
    for (final codeUnit in name.codeUnits) {
      if (codeUnit >= 32 && codeUnit <= 126) printable++;
    }
    return printable / name.length >= minPrintableRatio;
  } catch (_) {
    return false;
  }
}
