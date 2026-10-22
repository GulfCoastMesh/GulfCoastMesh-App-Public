import 'dart:convert';
import 'prefs_manager.dart';

class ChannelOrderStore {
  static const String _key = 'channel_order';

  Future<void> saveChannelOrder(List<int> order) async {
    final prefs = PrefsManager.instance;
    await prefs.setString(_key, jsonEncode(order));
  }

  Future<List<int>> loadChannelOrder() async {
    final prefs = PrefsManager.instance;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((value) => value is int ? value : int.tryParse('$value'))
            .whereType<int>()
            .toList();
      }
    } catch (_) {
      // fall through to legacy parse
    }
    return raw
        .split(',')
        .map((value) => int.tryParse(value))
        .whereType<int>()
        .toList();
  }
}
