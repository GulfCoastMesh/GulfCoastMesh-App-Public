import 'dart:async';
import 'dart:convert';

import '../models/telemetry_sample.dart';
import 'prefs_manager.dart';

/// Bounded per-node telemetry history in SharedPreferences.
///
/// The app has no database, and a time series would bloat prefs without a cap,
/// so each node keeps a fixed-size ring buffer and writes are debounced —
/// sampling every 30 s would otherwise rewrite the whole blob that often.
///
/// If retention ever needs to outgrow [maxSamplesPerNode], that is the point to
/// introduce a real database rather than raising the cap.
class TelemetryStore {
  TelemetryStore({this.maxSamplesPerNode = 500, Duration? writeDebounce})
    : _writeDebounce = writeDebounce ?? const Duration(milliseconds: 500);

  static const String _keyPrefix = 'telemetry_history_';
  static const String _localNodeId = '__local__';

  final int maxSamplesPerNode;
  final Duration _writeDebounce;

  final Map<String, List<TelemetrySample>> _cache = {};
  final Map<String, Timer> _pendingWrites = {};

  /// Key for the connected companion, which has no contact public key.
  static String get localNodeId => _localNodeId;

  String _keyFor(String nodeId) => '$_keyPrefix$nodeId';

  Future<List<TelemetrySample>> load(String nodeId) async {
    final cached = _cache[nodeId];
    if (cached != null) return List.unmodifiable(cached);

    final raw = PrefsManager.instance.getString(_keyFor(nodeId));
    final samples = <TelemetrySample>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final entry in decoded) {
            if (entry is! Map<String, dynamic>) continue;
            final sample = TelemetrySample.fromJson(entry);
            if (sample != null) samples.add(sample);
          }
        }
      } catch (_) {
        // Corrupt history is not worth failing over; start this node fresh.
      }
    }
    _cache[nodeId] = samples;
    return List.unmodifiable(samples);
  }

  /// Appends [sample], evicting the oldest entries past the cap.
  ///
  /// Empty samples are dropped so a poll that returned nothing does not push
  /// real history out of the buffer.
  Future<void> append(String nodeId, TelemetrySample sample) async {
    if (sample.isEmpty) return;
    final samples = _cache[nodeId] ?? (await load(nodeId)).toList();
    _cache[nodeId] = samples;

    samples.add(sample);
    if (samples.length > maxSamplesPerNode) {
      samples.removeRange(0, samples.length - maxSamplesPerNode);
    }
    _scheduleWrite(nodeId);
  }

  List<TelemetrySample> cached(String nodeId) =>
      List.unmodifiable(_cache[nodeId] ?? const <TelemetrySample>[]);

  /// Node ids with stored history, including ones not yet loaded this session.
  List<String> knownNodeIds() {
    return PrefsManager.instance
        .getKeys()
        .where((key) => key.startsWith(_keyPrefix))
        .map((key) => key.substring(_keyPrefix.length))
        .toList();
  }

  void _scheduleWrite(String nodeId) {
    _pendingWrites[nodeId]?.cancel();
    _pendingWrites[nodeId] = Timer(_writeDebounce, () {
      unawaited(_write(nodeId));
    });
  }

  Future<void> _write(String nodeId) async {
    _pendingWrites.remove(nodeId)?.cancel();
    final samples = _cache[nodeId];
    if (samples == null) return;
    await PrefsManager.instance.setString(
      _keyFor(nodeId),
      jsonEncode(samples.map((sample) => sample.toJson()).toList()),
    );
  }

  /// Forces any debounced writes out — call before the app can be torn down.
  Future<void> flush() async {
    final pending = _pendingWrites.keys.toList();
    for (final nodeId in pending) {
      await _write(nodeId);
    }
  }

  Future<void> clear(String nodeId) async {
    _pendingWrites.remove(nodeId)?.cancel();
    _cache.remove(nodeId);
    await PrefsManager.instance.remove(_keyFor(nodeId));
  }

  Future<void> clearAll() async {
    for (final nodeId in knownNodeIds()) {
      await clear(nodeId);
    }
    _cache.clear();
  }

  void dispose() {
    for (final timer in _pendingWrites.values) {
      timer.cancel();
    }
    _pendingWrites.clear();
  }
}
