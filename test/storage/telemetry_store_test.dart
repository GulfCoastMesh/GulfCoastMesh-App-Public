import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/telemetry_sample.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/storage/telemetry_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

TelemetrySample sampleAt(int minute, {int? battery, int? noiseFloor}) {
  return TelemetrySample(
    timestamp: DateTime.utc(2026, 1, 1, 0, minute),
    batteryMillivolts: battery ?? 4000 + minute,
    noiseFloor: noiseFloor,
  );
}

void main() {
  late TelemetryStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    // No debounce so writes land synchronously enough to assert on.
    store = TelemetryStore(maxSamplesPerNode: 5, writeDebounce: Duration.zero);
  });

  tearDown(() {
    store.dispose();
    PrefsManager.reset();
  });

  test('appends and reads back in order', () async {
    await store.append(TelemetryStore.localNodeId, sampleAt(1));
    await store.append(TelemetryStore.localNodeId, sampleAt(2));

    final history = store.cached(TelemetryStore.localNodeId);
    expect(history, hasLength(2));
    expect(history[0].batteryMillivolts, 4001);
    expect(history[1].batteryMillivolts, 4002);
  });

  test('evicts oldest samples past the cap', () async {
    for (var i = 1; i <= 8; i++) {
      await store.append(TelemetryStore.localNodeId, sampleAt(i));
    }

    final history = store.cached(TelemetryStore.localNodeId);
    expect(history, hasLength(5));
    // 1..3 evicted, 4..8 retained.
    expect(history.first.batteryMillivolts, 4004);
    expect(history.last.batteryMillivolts, 4008);
  });

  test('empty samples are not stored', () async {
    await store.append(
      TelemetryStore.localNodeId,
      TelemetrySample(timestamp: DateTime.utc(2026)),
    );

    expect(store.cached(TelemetryStore.localNodeId), isEmpty);
  });

  test('history survives a reload from prefs', () async {
    await store.append(
      TelemetryStore.localNodeId,
      sampleAt(1, noiseFloor: -95),
    );
    await store.flush();

    final reopened = TelemetryStore(writeDebounce: Duration.zero);
    addTearDown(reopened.dispose);
    final history = await reopened.load(TelemetryStore.localNodeId);

    expect(history, hasLength(1));
    expect(history.single.noiseFloor, -95);
    expect(history.single.timestamp, DateTime.utc(2026, 1, 1, 0, 1));
  });

  test('separate nodes keep separate histories', () async {
    await store.append(TelemetryStore.localNodeId, sampleAt(1));
    await store.append('abc123', sampleAt(2));

    expect(store.cached(TelemetryStore.localNodeId), hasLength(1));
    expect(store.cached('abc123'), hasLength(1));
    expect(store.cached('abc123').single.batteryMillivolts, 4002);
  });

  test(
    'corrupt stored JSON yields an empty history rather than throwing',
    () async {
      PrefsManager.instance.setString('telemetry_history_bad', '{not json');

      expect(await store.load('bad'), isEmpty);
    },
  );

  test('skips malformed samples but keeps the good ones', () async {
    PrefsManager.instance.setString(
      'telemetry_history_mixed',
      jsonEncode([
        {'t': 1000, 'batt': 4100},
        {'batt': 4200}, // no timestamp
        'not an object',
        {'t': 2000, 'nf': -101},
      ]),
    );

    final history = await store.load('mixed');

    expect(history, hasLength(2));
    expect(history[0].batteryMillivolts, 4100);
    expect(history[1].noiseFloor, -101);
  });

  test('clear removes one node without touching others', () async {
    await store.append(TelemetryStore.localNodeId, sampleAt(1));
    await store.append('abc123', sampleAt(2));
    await store.flush();

    await store.clear('abc123');

    expect(store.cached(TelemetryStore.localNodeId), hasLength(1));
    expect(await store.load('abc123'), isEmpty);
  });

  test('knownNodeIds lists stored nodes', () async {
    await store.append(TelemetryStore.localNodeId, sampleAt(1));
    await store.append('abc123', sampleAt(2));
    await store.flush();

    expect(
      store.knownNodeIds()..sort(),
      containsAll(<String>[TelemetryStore.localNodeId, 'abc123']),
    );
  });

  group('TelemetrySample', () {
    test('round-trips every field including sensors', () {
      final original = TelemetrySample(
        timestamp: DateTime.utc(2026, 5, 6, 7, 8),
        batteryMillivolts: 4210,
        noiseFloor: -98,
        lastRssi: -70,
        lastSnr: 9,
        txAirSeconds: 120,
        rxAirSeconds: 340,
        uptimeSeconds: 99999,
        sensors: const {'ch1.voltage': 4.21, 'ch2.temperature': 25.5},
      );

      final restored = TelemetrySample.fromJson(original.toJson())!;

      expect(restored.timestamp, original.timestamp);
      expect(restored.batteryMillivolts, 4210);
      expect(restored.noiseFloor, -98);
      expect(restored.lastRssi, -70);
      expect(restored.lastSnr, 9);
      expect(restored.txAirSeconds, 120);
      expect(restored.rxAirSeconds, 340);
      expect(restored.uptimeSeconds, 99999);
      expect(restored.sensors['ch1.voltage'], closeTo(4.21, 1e-9));
      expect(restored.sensors['ch2.temperature'], closeTo(25.5, 1e-9));
    });

    test('omits absent fields from JSON rather than writing nulls', () {
      final json = TelemetrySample(
        timestamp: DateTime.utc(2026),
        noiseFloor: -90,
      ).toJson();

      expect(json.keys, unorderedEquals(<String>['t', 'nf']));
    });

    test('isEmpty distinguishes a blank sample from a real one', () {
      expect(TelemetrySample(timestamp: DateTime.utc(2026)).isEmpty, isTrue);
      expect(
        TelemetrySample(timestamp: DateTime.utc(2026), lastSnr: 0).isEmpty,
        isFalse,
      );
      expect(
        TelemetrySample(
          timestamp: DateTime.utc(2026),
          sensors: const {'ch1.voltage': 4.0},
        ).isEmpty,
        isFalse,
      );
    });

    test('value() maps each metric to its field', () {
      final sample = TelemetrySample(
        timestamp: DateTime.utc(2026),
        batteryMillivolts: 4000,
        noiseFloor: -95,
        lastRssi: -60,
        lastSnr: 8,
        txAirSeconds: 10,
        rxAirSeconds: 20,
        uptimeSeconds: 30,
      );

      expect(sample.value(TelemetryMetric.batteryMillivolts), 4000);
      expect(sample.value(TelemetryMetric.noiseFloor), -95);
      expect(sample.value(TelemetryMetric.rssi), -60);
      expect(sample.value(TelemetryMetric.snr), 8);
      expect(sample.value(TelemetryMetric.txAirSeconds), 10);
      expect(sample.value(TelemetryMetric.rxAirSeconds), 20);
      expect(sample.value(TelemetryMetric.uptimeSeconds), 30);
    });

    test('value() is null for a metric this sample lacks', () {
      final sample = TelemetrySample(timestamp: DateTime.utc(2026));
      for (final metric in TelemetryMetric.values) {
        expect(sample.value(metric), isNull, reason: metric.name);
      }
    });
  });
}
