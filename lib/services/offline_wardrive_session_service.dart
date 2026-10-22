import 'dart:convert';
import '../models/offline_wardrive_session.dart';
import '../storage/prefs_manager.dart';

/// SharedPreferences-backed offline wardrive sessions. The JSON format is
/// intentionally simple so sessions remain exportable and migration-safe.
class OfflineWardriveSessionService {
  static const _key = 'offline_wardrive_sessions_v1';
  List<OfflineWardriveSession> _sessions = [];
  bool _initialized = false;

  List<OfflineWardriveSession> get sessions => List.unmodifiable(_sessions);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final raw = PrefsManager.instance.getStringList(_key) ?? const [];
    _sessions = raw
        .map((value) {
          try {
            return OfflineWardriveSession.fromJson(jsonDecode(value));
          } catch (_) {
            return null;
          }
        })
        .whereType<OfflineWardriveSession>()
        .toList();
  }

  Future<void> save(OfflineWardriveSession session) async {
    await init();
    _sessions.removeWhere((e) => e.id == session.id);
    _sessions.insert(0, session);
    await _persist();
  }

  Future<void> delete(String id) async {
    await init();
    _sessions.removeWhere((e) => e.id == id);
    await _persist();
  }

  OfflineWardriveSession? get(String id) {
    for (final session in _sessions) {
      if (session.id == id) return session;
    }
    return null;
  }

  Future<void> _persist() => PrefsManager.instance.setStringList(
    _key,
    _sessions.map((e) => jsonEncode(e.toJson())).toList(),
  );
}
