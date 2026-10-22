import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/helpers/wardriving_packet.dart';
import 'package:gulf_coast_mesh_app/models/analyzer_packet.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/services/mesh_analyzer_state.dart';

void main() {
  test('path travel finishes before the existing fade and expiry window', () {
    final start = DateTime(2026);
    final path = AnimatedPath(
      points: [],
      createdAt: start,
      packetType: AnalyzerPacketType.channel,
      label: 'test',
    );
    expect(
      path.travelProgressAt(start.subtract(const Duration(seconds: 1))),
      0,
    );
    expect(
      path.travelProgressAt(start.add(const Duration(milliseconds: 1500))),
      .5,
    );
    expect(path.travelProgressAt(start.add(const Duration(seconds: 3))), 1);
    expect(path.opacityAt(start.add(const Duration(seconds: 5))), 1);
    expect(path.opacityAt(start.add(const Duration(seconds: 6))), .5);
    expect(path.isExpired(start.add(const Duration(seconds: 7))), isTrue);
  });
  group('decodeAnalyzerRouteType', () {
    test('matches MeshCore PH route constants', () {
      expect(
        decodeAnalyzerRouteType(analyzerRouteTransportFlood),
        AnalyzerRouteType.transport,
      );
      expect(
        decodeAnalyzerRouteType(analyzerRouteFlood),
        AnalyzerRouteType.flood,
      );
      expect(
        decodeAnalyzerRouteType(analyzerRouteDirect),
        AnalyzerRouteType.direct,
      );
      expect(
        decodeAnalyzerRouteType(analyzerRouteTransportDirect),
        AnalyzerRouteType.transport,
      );
    });
  });

  group('analyzerPacketTypeFromPayload', () {
    test('maps payload types to analyzer categories', () {
      expect(
        analyzerPacketTypeFromPayload(payloadTypeTXTMSG),
        AnalyzerPacketType.dm,
      );
      expect(
        analyzerPacketTypeFromPayload(payloadTypeGRPTXT),
        AnalyzerPacketType.channel,
      );
      expect(
        analyzerPacketTypeFromPayload(payloadTypeGRPDATA),
        AnalyzerPacketType.channel,
      );
      expect(
        analyzerPacketTypeFromPayload(payloadTypeADVERT),
        AnalyzerPacketType.advert,
      );
      expect(
        analyzerPacketTypeFromPayload(payloadTypeCONTROL),
        AnalyzerPacketType.discovery,
      );
      expect(
        analyzerPacketTypeFromPayload(payloadTypeACK),
        AnalyzerPacketType.discovery,
      );
    });
  });

  group('MeshAnalyzerState path helpers', () {
    Contact contact(String name, List<int> keyBytes) {
      return Contact(
        publicKey: Uint8List.fromList(keyBytes),
        name: name,
        type: advTypeChat,
        pathLength: 0,
        path: Uint8List(0),
        lastSeen: DateTime.utc(2026, 1, 1),
      );
    }

    test('resolveSenderFromPath uses the first hop (origin)', () {
      final contacts = [
        contact('Origin', [0xAA, 0x01]),
        contact('Relay', [0xBB, 0x02]),
      ];
      final path = Uint8List.fromList([0xAA, 0xBB]);
      expect(
        MeshAnalyzerState.resolveSenderFromPath(path, contacts, 1),
        'Origin',
      );
    });

    test('resolvePathContacts walks hops in order', () {
      final contacts = [
        contact('Origin', [0xAA]),
        contact('Relay', [0xBB]),
        contact('Near', [0xCC]),
      ];
      final path = Uint8List.fromList([0xAA, 0xBB, 0xCC]);
      final resolved = MeshAnalyzerState.resolvePathContacts(path, contacts, 1);
      expect(resolved.map((c) => c.name).toList(), ['Origin', 'Relay', 'Near']);
    });
  });

  group('parseLogRxDataFrame transport skip', () {
    Uint8List buildFrame({
      required int routeType,
      required int payloadType,
      required List<int> pathBytes,
      List<int> transportBytes = const [0x11, 0x22, 0x33, 0x44],
      List<int> payload = const [0x05, 0x99],
    }) {
      final header = (payloadType << 2) | (routeType & 0x03);
      final hasTransport =
          routeType == analyzerRouteTransportFlood ||
          routeType == analyzerRouteTransportDirect;
      final pathLenByte = pathBytes.length; // hop count with 1-byte hashes
      final bytes = <int>[
        pushCodeLogRxData,
        28, // snr raw = 7.0
        0xCE, // rssi = -50
        header,
        if (hasTransport) ...transportBytes,
        pathLenByte,
        ...pathBytes,
        ...payload,
      ];
      return Uint8List.fromList(bytes);
    }

    test('skips transport codes before path for transport flood', () {
      final frame = buildFrame(
        routeType: analyzerRouteTransportFlood,
        payloadType: payloadTypeGRPTXT,
        pathBytes: [0xAA, 0xBB],
      );
      final packet = parseLogRxDataFrame(frame);
      expect(packet, isNotNull);
      expect(packet!.routeType, analyzerRouteTransportFlood);
      expect(packet.payloadType, payloadTypeGRPTXT);
      expect(packet.pathBytes, Uint8List.fromList([0xAA, 0xBB]));
      expect(packet.payload, Uint8List.fromList([0x05, 0x99]));
      expect(packet.snr, closeTo(7.0, 0.01));
      expect(packet.rssi, -50);
    });

    test('does not skip bytes for plain flood', () {
      final frame = buildFrame(
        routeType: analyzerRouteFlood,
        payloadType: payloadTypeTXTMSG,
        pathBytes: [0xAA],
        payload: [0x01, 0x02],
      );
      final packet = parseLogRxDataFrame(frame);
      expect(packet, isNotNull);
      expect(packet!.pathBytes, Uint8List.fromList([0xAA]));
      expect(packet.payload, Uint8List.fromList([0x01, 0x02]));
    });
  });
}
