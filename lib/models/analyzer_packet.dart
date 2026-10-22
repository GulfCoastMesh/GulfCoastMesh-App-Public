import 'dart:typed_data';

import '../connector/meshcore_protocol.dart';

enum AnalyzerPacketType { dm, channel, advert, discovery }

enum AnalyzerRouteType { direct, flood, transport, unknown }

/// MeshCore PH route field (bits 0-1). Matches connector `_route*` constants.
const int analyzerRouteTransportFlood = 0x00;
const int analyzerRouteFlood = 0x01;
const int analyzerRouteDirect = 0x02;
const int analyzerRouteTransportDirect = 0x03;

String analyzerRouteTypeLabel(AnalyzerRouteType type) {
  switch (type) {
    case AnalyzerRouteType.direct:
      return 'Direct';
    case AnalyzerRouteType.flood:
      return 'Flood';
    case AnalyzerRouteType.transport:
      return 'Transport';
    case AnalyzerRouteType.unknown:
      return 'Unknown';
  }
}

String analyzerPayloadTypeLabel(int payloadType) {
  switch (payloadType) {
    case 0x00:
      return 'REQ';
    case 0x01:
      return 'RESP';
    case 0x02:
      return 'TXT';
    case 0x03:
      return 'ACK';
    case 0x04:
      return 'ADVERT';
    case 0x05:
      return 'GRP_TXT';
    case 0x06:
      return 'GRP_DATA';
    case 0x07:
      return 'ANON_REQ';
    case 0x08:
      return 'PATH';
    case 0x09:
      return 'TRACE';
    case 0x0A:
      return 'MULTIPART';
    case 0x0B:
      return 'CONTROL';
    case 0x0F:
      return 'RAW';
    default:
      return '0x${payloadType.toRadixString(16).padLeft(2, '0')}';
  }
}

AnalyzerRouteType decodeAnalyzerRouteType(int routeType) {
  switch (routeType & 0x03) {
    case analyzerRouteTransportFlood:
    case analyzerRouteTransportDirect:
      return AnalyzerRouteType.transport;
    case analyzerRouteFlood:
      return AnalyzerRouteType.flood;
    case analyzerRouteDirect:
      return AnalyzerRouteType.direct;
    default:
      return AnalyzerRouteType.unknown;
  }
}

AnalyzerPacketType analyzerPacketTypeFromPayload(int payloadType) {
  switch (payloadType) {
    case payloadTypeTXTMSG:
      return AnalyzerPacketType.dm;
    case payloadTypeGRPTXT:
    case payloadTypeGRPDATA:
      return AnalyzerPacketType.channel;
    case payloadTypeADVERT:
      return AnalyzerPacketType.advert;
    default:
      return AnalyzerPacketType.discovery;
  }
}

class AnalyzerPacket {
  final DateTime timestamp;
  final AnalyzerPacketType type;
  final String senderName;
  final double snr;
  final int rssi;
  final int hopCount;
  final Uint8List pathBytes;
  final AnalyzerRouteType routeType;
  final int payloadType;
  final String? channelName;
  final String rawHex;
  final int? channelIndex;

  const AnalyzerPacket({
    required this.timestamp,
    required this.type,
    required this.senderName,
    required this.snr,
    required this.rssi,
    required this.hopCount,
    required this.pathBytes,
    required this.routeType,
    required this.payloadType,
    this.channelName,
    required this.rawHex,
    this.channelIndex,
  });

  String get payloadTypeLabel => analyzerPayloadTypeLabel(payloadType);

  String get routeTypeLabel => analyzerRouteTypeLabel(routeType);

  String get pathHex {
    if (pathBytes.isEmpty) return '';
    return pathBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }
}
