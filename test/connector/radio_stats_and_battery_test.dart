import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimum radio stats frame: [code][type][noise x2][rssi][snr][tx x4][rx x4].
Uint8List _radioStatsFrame({
  int type = statsTypeRadio,
  int noiseFloor = -96,
  int lastRssi = -110,
  int lastSnr = -8,
  int txAirSeconds = 1234,
  int rxAirSeconds = 5678,
  int trailingBytes = 0,
}) {
  final body = ByteData(13);
  body.setUint8(0, type);
  body.setInt16(1, noiseFloor, Endian.little);
  body.setInt8(3, lastRssi);
  body.setInt8(4, lastSnr);
  body.setUint32(5, txAirSeconds, Endian.little);
  body.setUint32(9, rxAirSeconds, Endian.little);
  return Uint8List.fromList([
    respCodeStats,
    ...body.buffer.asUint8List(),
    ...List.filled(trailingBytes, 0),
  ]);
}

Uint8List _batteryFrame({
  int? batteryMv,
  int? storageUsedKb,
  int? storageTotalKb,
}) {
  final out = <int>[respCodeBattAndStorage];
  if (batteryMv == null) return Uint8List.fromList(out);
  final data = ByteData(10);
  data.setUint16(0, batteryMv, Endian.little);
  if (storageUsedKb != null) data.setUint32(2, storageUsedKb, Endian.little);
  if (storageTotalKb != null) data.setUint32(6, storageTotalKb, Endian.little);
  final keep = storageUsedKb == null ? 2 : 10;
  out.addAll(data.buffer.asUint8List().sublist(0, keep));
  return Uint8List.fromList(out);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (call) async => call.method == 'readAll' ? <String, String>{} : null,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });

  tearDown(PrefsManager.reset);

  group('parseRadioStatsFrame', () {
    test('reads every field little-endian with the right signedness', () {
      final stats = parseRadioStatsFrame(_radioStatsFrame())!;

      expect(stats.noiseFloor, -96);
      expect(stats.lastRssi, -110);
      expect(stats.lastSnr, -8);
      expect(stats.txAirSeconds, 1234);
      expect(stats.rxAirSeconds, 5678);
    });

    test('accepts large unsigned airtime counters', () {
      final stats = parseRadioStatsFrame(
        _radioStatsFrame(txAirSeconds: 0xFFFFFFFF, rxAirSeconds: 0x80000000),
      )!;

      expect(stats.txAirSeconds, 0xFFFFFFFF);
      expect(stats.rxAirSeconds, 0x80000000);
    });

    test('tolerates firmware appending fields up to the 31-byte cap', () {
      expect(
        parseRadioStatsFrame(_radioStatsFrame(trailingBytes: 17)),
        isNotNull,
      );
      expect(parseRadioStatsFrame(_radioStatsFrame(trailingBytes: 18)), isNull);
    });

    test('rejects an empty frame, a wrong code, and a wrong stats type', () {
      expect(parseRadioStatsFrame(Uint8List(0)), isNull);

      final wrongCode = _radioStatsFrame();
      wrongCode[0] = respCodeOk;
      expect(parseRadioStatsFrame(wrongCode), isNull);

      expect(parseRadioStatsFrame(_radioStatsFrame(type: 0)), isNull);
      expect(parseRadioStatsFrame(_radioStatsFrame(type: 2)), isNull);
    });

    test('rejects a frame truncated below the fixed 13-byte body', () {
      final full = _radioStatsFrame();
      for (var length = 1; length < 14; length++) {
        expect(
          parseRadioStatsFrame(Uint8List.fromList(full.sublist(0, length))),
          isNull,
          reason: 'a $length-byte frame cannot hold radio stats',
        );
      }
    });
  });

  group('radio stats frames reaching the connector', () {
    test('a valid frame publishes stats and the noise floor', () async {
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);

      final published = expectLater(
        connector.radioStats,
        emits(isA<RadioStats>().having((s) => s.lastRssi, 'lastRssi', -110)),
      );
      connector.handleFrameForTest(_radioStatsFrame());

      expect(connector.lastRadioStats?.noiseFloor, -96);
      await published;
    });

    test('a zero noise floor is treated as no reading and dropped', () {
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);

      connector.handleFrameForTest(_radioStatsFrame());
      connector.handleFrameForTest(
        _radioStatsFrame(noiseFloor: 0, lastRssi: -1),
      );

      // The earlier good sample must survive the empty one.
      expect(connector.lastRadioStats?.noiseFloor, -96);
      expect(connector.lastRadioStats?.lastRssi, -110);
    });
  });

  group('battery and storage frames', () {
    test('an 11-byte frame fills battery and both storage counters', () {
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);

      connector.handleFrameForTest(
        _batteryFrame(
          batteryMv: 4103,
          storageUsedKb: 2048,
          storageTotalKb: 8192,
        ),
      );

      expect(connector.batteryMillivolts, 4103);
      expect(connector.storageUsedKb, 2048);
      expect(connector.storageTotalKb, 8192);
    });

    test('a 3-byte frame sets battery and leaves storage unknown', () {
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);

      connector.handleFrameForTest(_batteryFrame(batteryMv: 3700));

      expect(connector.batteryMillivolts, 3700);
      expect(connector.storageUsedKb, isNull);
      expect(connector.storageTotalKb, isNull);
    });

    test('a short frame changes nothing', () {
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);

      connector.handleFrameForTest(_batteryFrame(batteryMv: 4103));
      connector.handleFrameForTest(_batteryFrame());
      connector.handleFrameForTest(
        Uint8List.fromList([respCodeBattAndStorage, 0x10]),
      );

      expect(connector.batteryMillivolts, 4103);
    });

    test('a partial storage tail is ignored rather than half-applied', () {
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);

      connector.handleFrameForTest(
        Uint8List.fromList([
          respCodeBattAndStorage,
          0x07,
          0x10, // 4103 mV
          1, 2, 3, 4, // storage_used_kb
          5, 6, // storage_total_kb truncated mid-field
        ]),
      );

      expect(connector.batteryMillivolts, 4103);
      expect(connector.storageUsedKb, isNull);
      expect(connector.storageTotalKb, isNull);
    });
  });
}
