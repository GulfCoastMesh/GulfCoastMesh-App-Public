import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';
import 'package:gulf_coast_mesh_app/models/telemetry_sample.dart';
import 'package:gulf_coast_mesh_app/services/app_settings_service.dart';
import 'package:gulf_coast_mesh_app/services/telemetry_monitor_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/storage/telemetry_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MeshCoreConnector connector;
  late AppSettingsService settingsService;
  late TelemetryStore store;
  late List<({String title, String body})> alerts;
  late TelemetryMonitorService monitor;

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => call.method == 'readAll' ? <String, String>{} : null,
        );

    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();

    connector = MeshCoreConnector();
    settingsService = AppSettingsService();
    await settingsService.loadSettings();
    store = TelemetryStore(writeDebounce: Duration.zero);
    alerts = [];

    monitor = TelemetryMonitorService(
      connector: connector,
      settingsService: settingsService,
      store: store,
      onAlert:
          ({
            required String title,
            required String body,
            String? nodeId,
          }) async {
            alerts.add((title: title, body: body));
          },
    );

    addTearDown(() {
      monitor.dispose();
      connector.dispose();
      PrefsManager.reset();
    });
  });

  TelemetrySample sample({int? battery, int? noiseFloor}) => TelemetrySample(
    timestamp: DateTime.now(),
    batteryMillivolts: battery,
    noiseFloor: noiseFloor,
  );

  Future<void> record(TelemetrySample s) =>
      monitor.recordSampleForTest(TelemetryStore.localNodeId, s);

  group('history', () {
    test('records samples and exposes them per node', () async {
      await record(sample(battery: 4100));
      await record(sample(battery: 4050));

      final history = monitor.historyFor(TelemetryStore.localNodeId);
      expect(history, hasLength(2));
      expect(history.last.batteryMillivolts, 4050);
      expect(monitor.lastLocalSampleAt, isNotNull);
    });

    test('an empty sample is not recorded', () async {
      await record(TelemetrySample(timestamp: DateTime.now()));

      expect(monitor.historyFor(TelemetryStore.localNodeId), isEmpty);
    });

    test('clearHistory empties one node', () async {
      await record(sample(battery: 4100));
      await monitor.clearHistory(TelemetryStore.localNodeId);

      expect(monitor.historyFor(TelemetryStore.localNodeId), isEmpty);
    });
  });

  group('threshold alerts', () {
    setUp(() async {
      await settingsService.setTelemetryAlertsEnabled(true);
      await settingsService.setTelemetryLowBatteryMillivolts(3400);
      await settingsService.setTelemetryNoiseFloorAlertDbm(-90);
    });

    test('fires once when battery crosses the threshold', () async {
      await record(sample(battery: 3500));
      expect(alerts, isEmpty, reason: 'above threshold');

      await record(sample(battery: 3300));
      expect(alerts, hasLength(1));
      expect(alerts.single.title, 'Low battery');
      expect(alerts.single.body, contains('3.30 V'));
    });

    test('does not re-fire while the metric stays below threshold', () async {
      await record(sample(battery: 3300));
      await record(sample(battery: 3200));
      await record(sample(battery: 3100));

      expect(alerts, hasLength(1));
    });

    test(
      're-arms after recovery and fires again on the next crossing',
      () async {
        await record(sample(battery: 3300));
        expect(alerts, hasLength(1));

        await record(sample(battery: 3900)); // recovered
        await record(sample(battery: 3300)); // crosses again

        expect(alerts, hasLength(2));
      },
    );

    test('noise floor alerts on rising toward zero, not falling', () async {
      // Noise floor is negative dBm: -80 is worse than -100.
      await record(sample(noiseFloor: -100));
      expect(alerts, isEmpty);

      await record(sample(noiseFloor: -85));
      expect(alerts, hasLength(1));
      expect(alerts.single.title, 'High noise floor');
    });

    test('battery and noise floor alert independently', () async {
      await record(sample(battery: 3300, noiseFloor: -85));

      expect(alerts, hasLength(2));
      expect(
        alerts.map((a) => a.title),
        containsAll(<String>['Low battery', 'High noise floor']),
      );
    });

    test('nothing fires when alerts are disabled', () async {
      await settingsService.setTelemetryAlertsEnabled(false);

      await record(sample(battery: 3000, noiseFloor: -70));

      expect(alerts, isEmpty);
    });

    test('a zero battery reading is ignored rather than alerting', () async {
      // Firmware reports 0 mV when it has no battery sensor; treating that as
      // a flat battery would alert every single sample.
      await record(sample(battery: 0, noiseFloor: -100));

      expect(alerts, isEmpty);
    });
  });

  group('scheduling', () {
    test('is not monitoring until enabled', () async {
      await monitor.start();
      expect(monitor.isMonitoring, isFalse);
    });

    test('starts and stops with the setting', () async {
      await monitor.start();

      await settingsService.setTelemetryMonitorEnabled(true);
      expect(monitor.isMonitoring, isTrue);

      await settingsService.setTelemetryMonitorEnabled(false);
      expect(monitor.isMonitoring, isFalse);
    });

    test('remote polling does nothing while disconnected', () async {
      await settingsService.setTelemetryMonitorEnabled(true);
      await settingsService.setTelemetryRemoteEnabled(true);
      await settingsService.setTelemetryRemoteNode('abc123', true);

      await monitor.pollRemoteNow();

      expect(monitor.lastRemotePollAt, isNull);
    });
  });

  group('settings', () {
    test(
      'only treats successful repeater logins from the last 30 days as recent',
      () async {
        final loginAt = DateTime.utc(2026, 1, 1, 12);
        await settingsService.recordSuccessfulRepeaterLogin('abc', at: loginAt);

        expect(
          settingsService.hasRecentRepeaterLogin(
            'abc',
            now: loginAt.add(const Duration(days: 30)),
          ),
          isTrue,
        );
        expect(
          settingsService.hasRecentRepeaterLogin(
            'abc',
            now: loginAt.add(const Duration(days: 30, milliseconds: 1)),
          ),
          isFalse,
        );
        expect(
          settingsService.hasRecentRepeaterLogin('missing', now: loginAt),
          isFalse,
        );
      },
    );

    test('successful repeater login timestamps survive a reload', () async {
      final loginAt = DateTime.utc(2026, 2, 3, 4, 5);
      await settingsService.recordSuccessfulRepeaterLogin('abc', at: loginAt);

      final reloaded = AppSettingsService();
      await reloaded.loadSettings();

      expect(
        reloaded.settings.repeaterLastSuccessfulLoginMillis['abc'],
        loginAt.millisecondsSinceEpoch,
      );
    });

    test('remote node opt-in is per node and idempotent', () async {
      await settingsService.setTelemetryRemoteNode('aaa', true);
      await settingsService.setTelemetryRemoteNode('bbb', true);
      await settingsService.setTelemetryRemoteNode('aaa', true);

      expect(settingsService.settings.telemetryRemoteNodeKeys, ['aaa', 'bbb']);

      await settingsService.setTelemetryRemoteNode('aaa', false);
      expect(settingsService.settings.telemetryRemoteNodeKeys, ['bbb']);
    });

    test(
      'remote interval only permits the three low-airtime choices',
      () async {
        for (final interval in kTelemetryRemoteIntervalOptionsSec) {
          await settingsService.setTelemetryRemoteIntervalSec(interval);
          expect(settingsService.settings.telemetryRemoteIntervalSec, interval);
        }

        await settingsService.setTelemetryRemoteIntervalSec(1800);
        expect(
          settingsService.settings.telemetryRemoteIntervalSec,
          kTelemetryRemoteDefaultIntervalSec,
        );
      },
    );

    test('telemetry settings survive a reload', () async {
      await settingsService.setTelemetryMonitorEnabled(true);
      await settingsService.setTelemetryIntervalSec(300);
      await settingsService.setTelemetryRemoteNode('abc', true);

      final reloaded = AppSettingsService();
      await reloaded.loadSettings();

      expect(reloaded.settings.telemetryMonitorEnabled, isTrue);
      expect(reloaded.settings.telemetryIntervalSec, 300);
      expect(reloaded.settings.telemetryRemoteNodeKeys, ['abc']);
    });
  });
}
