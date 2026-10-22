import 'dart:async';

import 'package:flutter/foundation.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/cayenne_lpp.dart';
import '../models/app_settings.dart';
import '../models/contact.dart';
import '../models/telemetry_sample.dart';
import '../storage/telemetry_store.dart';
import 'app_settings_service.dart';
import 'notification_service.dart';

/// Emits a threshold alert. Matches [NotificationService.showTelemetryAlert].
typedef TelemetryAlertHandler =
    Future<void> Function({
      required String title,
      required String body,
      String? nodeId,
    });

/// Samples telemetry on a schedule and keeps a bounded history per node.
///
/// Two very different cadences:
/// - **Local** (the connected companion) is cheap — battery and radio stats
///   ride an already-open link — so it samples on a short interval.
/// - **Remote** repeaters cost LoRa airtime on both the request and the reply,
///   so polling is off by default, opt-in per node, and floored at a much
///   longer interval.
class TelemetryMonitorService extends ChangeNotifier {
  TelemetryMonitorService({
    required MeshCoreConnector connector,
    required AppSettingsService settingsService,
    TelemetryStore? store,
    TelemetryAlertHandler? onAlert,
  }) : _connector = connector,
       _settingsService = settingsService,
       _store = store ?? TelemetryStore(),
       // A tear-off of the notification singleton by default; injectable so the
       // alert transitions can be tested without the platform channel.
       _onAlert = onAlert ?? NotificationService().showTelemetryAlert {
    _settingsService.addListener(_onSettingsChanged);
    _radioStatsSubscription = _connector.radioStats.listen(_onRadioStats);
    _frameSubscription = _connector.receivedFrames.listen(_onFrame);
  }

  final MeshCoreConnector _connector;
  final AppSettingsService _settingsService;
  final TelemetryStore _store;
  final TelemetryAlertHandler _onAlert;

  StreamSubscription<RadioStats>? _radioStatsSubscription;
  StreamSubscription<Uint8List>? _frameSubscription;
  Timer? _localTimer;
  Timer? _remoteTimer;

  /// Remote replies are matched by the 4-byte tag the firmware echoes back.
  final Map<String, Uint8List> _pendingRemoteTags = {};
  String? _awaitingSentTagFor;

  DateTime? _lastLocalSampleAt;
  DateTime? _lastRemotePollAt;
  String? _lastError;

  /// Alerts already fired this session, so a metric that stays over threshold
  /// notifies once rather than on every sample.
  final Set<String> _firedAlerts = {};

  AppSettings get _settings => _settingsService.settings;

  DateTime? get lastLocalSampleAt => _lastLocalSampleAt;
  DateTime? get lastRemotePollAt => _lastRemotePollAt;
  String? get lastError => _lastError;

  bool get isMonitoring => _localTimer != null;

  List<TelemetrySample> localHistory() =>
      _store.cached(TelemetryStore.localNodeId);

  List<TelemetrySample> historyFor(String nodeId) => _store.cached(nodeId);

  Future<List<TelemetrySample>> loadHistory(String nodeId) =>
      _store.load(nodeId);

  Future<void> start() async {
    await _store.load(TelemetryStore.localNodeId);
    _applySchedule();
    notifyListeners();
  }

  void _onSettingsChanged() => _applySchedule();

  void _applySchedule() {
    _localTimer?.cancel();
    _localTimer = null;
    _remoteTimer?.cancel();
    _remoteTimer = null;

    if (!_settings.telemetryMonitorEnabled) {
      notifyListeners();
      return;
    }

    _localTimer = Timer.periodic(
      Duration(
        seconds: clampTelemetryIntervalSec(_settings.telemetryIntervalSec),
      ),
      (_) => unawaited(sampleLocalNow()),
    );

    if (_settings.telemetryRemoteEnabled &&
        _settings.telemetryRemoteNodeKeys.isNotEmpty) {
      _remoteTimer = Timer.periodic(
        Duration(
          seconds: clampTelemetryRemoteIntervalSec(
            _settings.telemetryRemoteIntervalSec,
          ),
        ),
        (_) => unawaited(pollRemoteNow()),
      );
    }
    notifyListeners();
  }

  /// Asks the companion for battery and radio stats. The replies arrive
  /// asynchronously and are recorded by [_onRadioStats] / [_onFrame].
  Future<void> sampleLocalNow() async {
    if (!_connector.isConnected) return;
    try {
      await _connector.requestBatteryStatus(force: true);
      await _connector.requestRadioStats();
    } catch (e) {
      _lastError = 'Local telemetry request failed: $e';
      debugPrint(_lastError);
      notifyListeners();
    }
  }

  void _onRadioStats(RadioStats stats) {
    unawaited(
      _record(
        TelemetryStore.localNodeId,
        TelemetrySample(
          timestamp: DateTime.now(),
          batteryMillivolts: _connector.batteryMillivolts,
          noiseFloor: stats.noiseFloor,
          lastRssi: stats.lastRssi,
          lastSnr: stats.lastSnr,
          txAirSeconds: stats.txAirSeconds,
          rxAirSeconds: stats.rxAirSeconds,
        ),
      ),
    );
  }

  /// Watches for the tag the firmware assigns an outgoing binary request, then
  /// for the matching reply. Mirrors the flow TelemetryScreen uses for its
  /// one-shot pulls, but for every opted-in node at once.
  void _onFrame(Uint8List frame) {
    if (frame.length < 6) return;

    if (frame[0] == respCodeSent) {
      final awaiting = _awaitingSentTagFor;
      if (awaiting != null) {
        _pendingRemoteTags[awaiting] = frame.sublist(2, 6);
        _awaitingSentTagFor = null;
      }
      return;
    }

    if (frame[0] != pushCodeBinaryResponse) return;
    final tag = frame.sublist(2, 6);
    String? matched;
    for (final entry in _pendingRemoteTags.entries) {
      if (listEquals(entry.value, tag)) {
        matched = entry.key;
        break;
      }
    }
    if (matched == null) return;
    _pendingRemoteTags.remove(matched);

    final decoded = CayenneLpp.parseByChannel(frame.sublist(6));
    if (decoded.isEmpty) return;

    final sensors = <String, double>{};
    int? batteryMv;
    for (final channel in decoded) {
      final index = channel['channel'] as int;
      final values = channel['values'] as Map<String, dynamic>;
      for (final entry in values.entries) {
        final value = entry.value;
        if (value is num) {
          sensors['ch$index.${entry.key}'] = value.toDouble();
        } else if (value is bool) {
          sensors['ch$index.${entry.key}'] = value ? 1 : 0;
        }
      }
      // Channel 1 voltage is the repeater's own battery by convention.
      if (index == 1 && values['voltage'] is num) {
        batteryMv = ((values['voltage'] as num) * 1000).round();
      }
    }

    if (batteryMv != null) {
      _connector.updateRepeaterBatterySnapshot(
        matched,
        batteryMv,
        source: 'telemetry-monitor',
      );
    }

    unawaited(
      _record(
        matched,
        TelemetrySample(
          timestamp: DateTime.now(),
          batteryMillivolts: batteryMv,
          sensors: sensors,
        ),
      ),
    );
  }

  /// Polls every opted-in repeater once, spaced out so a batch of requests
  /// does not saturate the radio.
  Future<void> pollRemoteNow() async {
    if (!_connector.isConnected) return;
    if (!_settings.telemetryRemoteEnabled) return;

    final keys = _settings.telemetryRemoteNodeKeys
        .where(_settingsService.hasRecentRepeaterLogin)
        .toList();
    if (keys.isEmpty) return;

    _lastRemotePollAt = DateTime.now();
    notifyListeners();

    for (final key in keys) {
      final contact = _contactFor(key);
      if (contact == null) continue;
      try {
        await _requestRemoteTelemetry(contact);
      } catch (e) {
        _lastError = 'Telemetry request to ${contact.displayName} failed: $e';
        debugPrint(_lastError);
      }
      // One in flight at a time: the tag correlation is only unambiguous while
      // a single request is outstanding, and back-to-back sends would collide
      // on the air anyway.
      await Future<void>.delayed(const Duration(seconds: 5));
    }
    notifyListeners();
  }

  Contact? _contactFor(String publicKeyHex) {
    for (final contact in _connector.contacts) {
      if (contact.publicKeyHex == publicKeyHex) return contact;
    }
    return null;
  }

  Future<void> _requestRemoteTelemetry(Contact repeater) async {
    await _connector.preparePathForContactSend(repeater);
    _awaitingSentTagFor = repeater.publicKeyHex;
    await _connector.sendFrame(
      buildSendBinaryReq(
        repeater.publicKey,
        payload: Uint8List.fromList([reqTypeGetTelemetry]),
      ),
    );
  }

  Future<void> _record(String nodeId, TelemetrySample sample) async {
    if (sample.isEmpty) return;
    await _store.append(nodeId, sample);
    if (nodeId == TelemetryStore.localNodeId) {
      _lastLocalSampleAt = sample.timestamp;
    }
    _checkAlerts(nodeId, sample);
    notifyListeners();
  }

  void _checkAlerts(String nodeId, TelemetrySample sample) {
    if (!_settings.telemetryAlertsEnabled) return;

    final battery = sample.batteryMillivolts;
    if (battery != null && battery > 0) {
      _evaluateAlert(
        key: '$nodeId.battery',
        tripped: battery <= _settings.telemetryLowBatteryMillivolts,
        title: 'Low battery',
        body:
            '${_nodeLabel(nodeId)} is at '
            '${(battery / 1000).toStringAsFixed(2)} V',
      );
    }

    final noiseFloor = sample.noiseFloor;
    if (noiseFloor != null) {
      _evaluateAlert(
        key: '$nodeId.noise',
        // Noise floor is negative dBm: closer to zero is worse.
        tripped: noiseFloor >= _settings.telemetryNoiseFloorAlertDbm,
        title: 'High noise floor',
        body: '${_nodeLabel(nodeId)} noise floor is $noiseFloor dBm',
      );
    }
  }

  /// Fires once on the transition into an alert state and re-arms only after
  /// the metric recovers, so a persistently low battery does not notify on
  /// every sample.
  void _evaluateAlert({
    required String key,
    required bool tripped,
    required String title,
    required String body,
  }) {
    if (!tripped) {
      _firedAlerts.remove(key);
      return;
    }
    if (!_firedAlerts.add(key)) return;
    unawaited(_onAlert(title: title, body: body));
  }

  String _nodeLabel(String nodeId) {
    if (nodeId == TelemetryStore.localNodeId) {
      return _connector.deviceDisplayName;
    }
    return _contactFor(nodeId)?.displayName ?? 'Node';
  }

  /// Records a sample as if it had arrived from the radio, so history and
  /// alert behaviour can be exercised without hardware.
  @visibleForTesting
  Future<void> recordSampleForTest(String nodeId, TelemetrySample sample) =>
      _record(nodeId, sample);

  Future<void> clearHistory(String nodeId) => _store.clear(nodeId);

  Future<void> flush() => _store.flush();

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    unawaited(_radioStatsSubscription?.cancel());
    unawaited(_frameSubscription?.cancel());
    _localTimer?.cancel();
    _remoteTimer?.cancel();
    unawaited(_store.flush());
    _store.dispose();
    super.dispose();
  }
}
