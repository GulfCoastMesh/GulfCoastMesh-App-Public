import 'dart:async';
import 'dart:convert';

import 'prefs_manager.dart';

/// Storage for unread message tracking with debounced writes to reduce I/O.
class UnreadStore {
  UnreadStore({Future<void> Function(String key, String value)? write})
    : _write =
          write ??
          ((key, value) => PrefsManager.instance.setString(key, value));

  static const String _contactUnreadCountKey = 'contact_unread_count';
  final Future<void> Function(String key, String value) _write;

  // Debounce timers to batch rapid writes
  Timer? _contactUnreadSaveTimer;
  static const Duration _saveDebounceDuration = Duration(milliseconds: 500);

  // Pending write data
  Map<String, int>? _pendingContactUnreadCount;
  Future<void> _writeChain = Future.value();

  /// Dispose timers when no longer needed
  void dispose() {
    _contactUnreadSaveTimer?.cancel();
  }

  Future<Map<String, int>> loadContactUnreadCount() async {
    final prefs = PrefsManager.instance;
    final jsonStr = prefs.getString(_contactUnreadCountKey);
    if (jsonStr == null) return {};

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return {
        for (final entry in json.entries)
          if (entry.value is num &&
              (entry.value as num).isFinite &&
              (entry.value as num) >= 0 &&
              (entry.value as num).toInt() == entry.value)
            entry.key: (entry.value as num).toInt(),
      };
    } catch (_) {
      return {};
    }
  }

  void saveContactUnreadCount(Map<String, int> counts) {
    _pendingContactUnreadCount = Map<String, int>.from(counts);

    _contactUnreadSaveTimer?.cancel();

    _contactUnreadSaveTimer = Timer(_saveDebounceDuration, () {
      _contactUnreadSaveTimer = null;
      unawaited(_flushContactUnreadCount().catchError((_) {}));
    });
  }

  Future<void> _flushContactUnreadCount() async {
    final pending = _pendingContactUnreadCount;
    if (pending == null) {
      await _writeChain.catchError((_) {});
      return;
    }
    _pendingContactUnreadCount = null;

    final jsonStr = jsonEncode(pending);
    final operation = _writeChain
        .catchError((_) {})
        .then((_) => _write(_contactUnreadCountKey, jsonStr));
    _writeChain = operation;
    try {
      await operation;
    } catch (_) {
      // A newer snapshot is authoritative. Restore this one only when no
      // update arrived while the write was in flight so a later flush retries.
      _pendingContactUnreadCount ??= pending;
      rethrow;
    }
  }

  /// Immediately flush pending writes (call before app termination or disposal)
  Future<void> flush() async {
    _contactUnreadSaveTimer?.cancel();
    await _flushContactUnreadCount();
  }
}
