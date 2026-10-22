import '../storage/prefs_manager.dart';

class MapMarkerService {
  static const String _removedKey = 'map_removed_marker_ids';

  Future<Set<String>> loadRemovedIds() async {
    final prefs = PrefsManager.instance;
    final items = prefs.getStringList(_removedKey) ?? const [];
    return items.toSet();
  }

  Future<void> saveRemovedIds(Set<String> ids) async {
    final prefs = PrefsManager.instance;
    await prefs.setStringList(_removedKey, ids.toList());
  }
}
