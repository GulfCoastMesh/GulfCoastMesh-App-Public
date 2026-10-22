import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../storage/prefs_manager.dart';

class CrashLogEntry {
  final DateTime timestamp;
  final String error;
  final String? stackTrace;

  CrashLogEntry({
    required this.timestamp,
    required this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() => {
    't': timestamp.millisecondsSinceEpoch,
    'e': error,
    's': stackTrace,
  };

  static CrashLogEntry? fromJson(Map<String, dynamic> json) {
    final ms = json['t'];
    final error = json['e'];
    if (ms is! int || error is! String) return null;
    return CrashLogEntry(
      timestamp: DateTime.fromMillisecondsSinceEpoch(ms),
      error: error,
      stackTrace: json['s'] as String?,
    );
  }
}

/// Captures uncaught errors app-wide, independent of the opt-in app debug
/// log toggle — a crash is exactly the moment logging is most likely to
/// have been off, so this always records regardless of settings. Wired up
/// via [FlutterError.onError] and [PlatformDispatcher.instance.onError] in
/// main.dart.
///
/// Persisted immediately to disk (not just kept in memory) so a report
/// filed after the *next* launch can still include a crash that killed the
/// process outright, not just ones the app recovered from. Crashes are
/// rare, so a small cap is plenty.
class CrashLogService extends ChangeNotifier {
  static const int maxEntries = 20;
  static const String _prefsKey = 'crash_log_entries';

  final List<CrashLogEntry> _entries = [];
  bool _notifyScheduled = false;

  CrashLogService() {
    _entries.addAll(_loadPersisted());
  }

  List<CrashLogEntry> get entries => List.unmodifiable(_entries);

  void record(Object error, StackTrace? stackTrace) {
    _entries.add(
      CrashLogEntry(
        timestamp: DateTime.now(),
        error: error.toString(),
        stackTrace: stackTrace?.toString(),
      ),
    );
    if (_entries.length > maxEntries) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }
    _persist();
    _notifyListenersSafely();
  }

  void clear() {
    _entries.clear();
    _persist();
    _notifyListenersSafely();
  }

  List<CrashLogEntry> _loadPersisted() {
    final raw = PrefsManager.instance.getStringList(_prefsKey) ?? [];
    final entries = <CrashLogEntry>[];
    for (final line in raw) {
      try {
        final entry = CrashLogEntry.fromJson(
          jsonDecode(line) as Map<String, dynamic>,
        );
        if (entry != null) entries.add(entry);
      } catch (_) {
        // Skip a corrupted entry rather than losing the rest of the log.
      }
    }
    return entries;
  }

  void _persist() {
    unawaited(
      PrefsManager.instance.setStringList(
        _prefsKey,
        _entries.map((e) => jsonEncode(e.toJson())).toList(),
      ),
    );
  }

  /// Mirrors the same pattern as [FrameDebugLogService]/[AppDebugLogService]:
  /// avoid the "setState/markNeedsBuild called during build" assertion when
  /// an error is recorded during the build phase.
  void _notifyListenersSafely() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    final canNotifyNow =
        phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks;
    if (canNotifyNow) {
      notifyListeners();
      return;
    }

    if (_notifyScheduled) return;
    _notifyScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      notifyListeners();
    });
  }
}
