import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/helpers/wardriving_packet.dart';
import 'package:gulf_coast_mesh_app/wardriving/wardriving_trackers.dart';

void main() {
  group('buildSendDiscoverReqFrame', () {
    test('builds expected DISCOVER_REQ frame', () {
      final frame = buildSendDiscoverReqFrame(tag: 0x12345678, since: 42);

      expect(
        frame,
        Uint8List.fromList([
          0x37,
          0x80,
          0x06,
          0x78,
          0x56,
          0x34,
          0x12,
          42,
          0,
          0,
          0,
        ]),
      );
      expect(frame[0], cmdSendControlData);
      expect(frame[1], discoverReqSubType);
      expect(frame[2], discoverTypeFilterRepeaterRoom);
      expect(frame[3], 0x78);
      expect(frame[4], 0x56);
      expect(frame[5], 0x34);
      expect(frame[6], 0x12);
      expect(frame[7], 42);
      expect(frame[8], 0);
      expect(frame[9], 0);
      expect(frame[10], 0);
      expect(frame.length, 11);
    });
  });

  group('parseDiscoverResponseFrame', () {
    test('parses DISCOVER_RESP with path and payload', () {
      final pubkey = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
      final payload = Uint8List(39);
      payload[0] = discoverRespSubType | discoverNodeTypeRepeater;
      payload[2] = 20; // remote SNR raw = 5.0
      payload.setRange(7, 39, pubkey);

      final frame = Uint8List(4 + 1 + payload.length);
      frame[0] = pushCodeControlData;
      frame[1] = 48; // local SNR raw = 12.0
      frame[2] = 0xCE; // -50 RSSI
      frame[3] = 1; // path length
      frame[4] = 0x4E; // path hop
      frame.setRange(5, 5 + payload.length, payload);

      final response = parseDiscoverResponseFrame(frame, hopBytes: 1);
      expect(response, isNotNull);
      expect(response!.nodeType, discoverNodeTypeRepeater);
      expect(response.localSnr, closeTo(12.0, 0.01));
      expect(response.localRssi, -50);
      expect(response.remoteSnr, closeTo(5.0, 0.01));
      expect(response.repeaterId(1), '4E');
      expect(response.pubkeyHex.length, 64);
    });

    test('returns null for non-discovery control data', () {
      final frame = Uint8List.fromList([pushCodeControlData, 0, 0, 0]);
      expect(parseDiscoverResponseFrame(frame), isNull);
    });
  });

  group('isValidWardrivingAdvert', () {
    Uint8List advert({
      int flags = 0x80,
      List<int> location = const [],
      List<int> name = const [78, 111, 100, 101],
    }) {
      final payload = Uint8List(101 + location.length + name.length);
      payload[100] = flags;
      payload.setRange(101, 101 + location.length, location);
      payload.setRange(101 + location.length, payload.length, name);
      return payload;
    }

    test('accepts a name after the signed advert header', () {
      expect(isValidWardrivingAdvert(advert()), isTrue);
      expect(
        isValidWardrivingAdvert(
          advert(
            flags: 0x90,
            location: List<int>.filled(8, 0),
            name: [84, 114, 117, 99, 107, 0, 0],
          ),
        ),
        isTrue,
      );
    });

    test('rejects truncated or unnamed advert payloads', () {
      expect(isValidWardrivingAdvert(Uint8List(100)), isFalse);
      expect(isValidWardrivingAdvert(advert(flags: 0)), isFalse);
      expect(isValidWardrivingAdvert(advert(name: const [])), isFalse);
      expect(
        isValidWardrivingAdvert(advert(name: const [0, 0, 32, 0])),
        isFalse,
      );
      // The location flag requires all eight location bytes before the name.
      expect(
        isValidWardrivingAdvert(advert(flags: 0x90, name: const [78])),
        isFalse,
      );
    });

    test('rejects implausible binary names', () {
      expect(
        isValidWardrivingAdvert(advert(name: List<int>.filled(12, 1))),
        isFalse,
      );
      // Matches the reference's 60% printable threshold.
      expect(
        isValidWardrivingAdvert(advert(name: const [78, 111, 100, 1, 2])),
        isTrue,
      );
    });
  });

  test('trace tracker carries BLE SNR and RSSI into the trace window', () {
    final tracker = WardrivingTraceTracker()
      ..startTracking(tag: Uint8List.fromList([1, 2, 3, 4]));
    final packet = WardrivingRawPacket(
      snr: 7.25,
      rssi: -71,
      routeType: 1,
      payloadType: payloadTypeTRACE,
      pathLenByte: 0,
      pathBytes: Uint8List(0),
      payload: Uint8List(0),
    );

    expect(tracker.captureBleMetadata(packet), isTrue);
    expect(tracker.pendingBleSnr, 7.25);
    expect(tracker.pendingBleRssi, -71);
    tracker.dispose();
  });

  group('WardrivingTxTracker', () {
    test('strips a full configured CARpeater key from a short path hash', () {
      final tracker = WardrivingTxTracker()
        ..carpeaterPrefix = 'AABBCCDDEEFF'
        ..startTracking(
          payload: 'ping',
          channelHash: 0x42,
          channelKey: Uint8List(16),
        );
      tracker.channelKey = null;
      final packet = WardrivingRawPacket(
        snr: 8,
        rssi: -90,
        routeType: 1,
        payloadType: payloadTypeGRPTXT,
        pathLenByte: 2,
        pathBytes: Uint8List.fromList([0xAA, 0x12]),
        // Omit the key so this test isolates path/CARpeater attribution.
        payload: Uint8List.fromList([0x42]),
      );

      expect(tracker.handlePacket(packet), isTrue);
      expect(tracker.repeaters.keys, ['12']);
      expect(tracker.repeaters['12']!.snr, isNull);
      expect(tracker.repeaters['12']!.rssi, isNull);
      tracker.dispose();
    });
  });

  group('WardrivingRxLogger', () {
    test('credits the final hop for multi-byte path hashes', () {
      final logger = WardrivingRxLogger();
      Map<String, double>? batch;
      logger.onBatchReady = (repeaters) => batch = repeaters;
      final packet = WardrivingRawPacket(
        snr: 6.5,
        rssi: -80,
        routeType: 1,
        payloadType: payloadTypeGRPTXT,
        // Two hops whose IDs are each two bytes.
        pathLenByte: 0x42,
        pathBytes: Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD]),
        payload: Uint8List(0),
      );

      logger.record(packet, hopBytes: 2);
      logger.flush();

      expect(batch, {'CCDD': 6.5});
      logger.dispose();
    });

    test('filters unsupported packet types and local CARpeater delivery', () {
      final logger = WardrivingRxLogger();
      Map<String, double>? batch;
      logger.onBatchReady = (repeaters) => batch = repeaters;

      logger.record(
        WardrivingRawPacket(
          snr: 3,
          rssi: -80,
          routeType: 1,
          payloadType: payloadTypeTRACE,
          pathLenByte: 1,
          pathBytes: Uint8List.fromList([0xAA]),
          payload: Uint8List(0),
        ),
      );
      logger.record(
        WardrivingRawPacket(
          snr: 3,
          rssi: -20,
          routeType: 1,
          payloadType: payloadTypeADVERT,
          pathLenByte: 1,
          pathBytes: Uint8List.fromList([0xAA]),
          payload: Uint8List(0),
        ),
      );

      logger.carpeaterPrefix = 'AABBCCDDEEFF';
      logger.record(
        WardrivingRawPacket(
          snr: 3,
          rssi: -20,
          routeType: 1,
          payloadType: payloadTypeADVERT,
          pathLenByte: 2,
          pathBytes: Uint8List.fromList([0x12, 0xAA]),
          payload: Uint8List(0),
        ),
      );
      logger.flush();

      expect(batch, {'12': 3.0});
      logger.dispose();
    });
  });

  test('tracks multi-hop TX echoes separately from direct TX evidence', () {
    final tracker = WardrivingTxTracker()
      ..disableRssiFilter = true
      ..startTracking(
        payload: 'ping',
        channelHash: 0x42,
        channelKey: Uint8List(16),
      );
    tracker.channelKey = null;
    final packet = WardrivingRawPacket(
      snr: 4,
      rssi: -80,
      routeType: 1,
      payloadType: payloadTypeGRPTXT,
      pathLenByte: 2,
      pathBytes: Uint8List.fromList([0xAA, 0xBB]),
      payload: Uint8List.fromList([0x42]),
    );

    expect(tracker.handlePacket(packet), isTrue);
    expect(tracker.repeaters, isEmpty);
    expect(tracker.multiHopRepeaters.keys, ['BB']);
    expect(tracker.multiHopRepeaters['BB']!.pathHops, ['AA', 'BB']);
    tracker.dispose();
  });
}
