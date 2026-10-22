import 'dart:convert';

import '../models/connection_profile.dart';
import 'prefs_manager.dart';

class ConnectionProfileStore {
  static const String _key = 'connection_profiles_v1';

  Future<void> saveProfiles(List<ConnectionProfile> profiles) async {
    final prefs = PrefsManager.instance;
    await prefs.setString(
      _key,
      jsonEncode(profiles.map((profile) => profile.toJson()).toList()),
    );
  }

  Future<List<ConnectionProfile>> loadProfiles() async {
    final prefs = PrefsManager.instance;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      // Skip individual malformed records rather than dropping every saved
      // connection because one entry is bad.
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ConnectionProfile.fromJson)
          .whereType<ConnectionProfile>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clear() async {
    await PrefsManager.instance.remove(_key);
  }
}
