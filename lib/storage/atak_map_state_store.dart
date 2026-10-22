import 'prefs_manager.dart';

class AtakMapStateStore {
  static const String _hiddenKey = 'atak_hidden_marker_ids';
  static const String _removedKey = 'atak_removed_marker_ids';
  static const String _hiddenSharedKey = 'shared_hidden_marker_ids';

  Future<Set<String>> loadHiddenIds() async {
    final prefs = PrefsManager.instance;
    final items = prefs.getStringList(_hiddenKey) ?? const [];
    return items.toSet();
  }

  Future<void> saveHiddenIds(Set<String> ids) async {
    final prefs = PrefsManager.instance;
    await prefs.setStringList(_hiddenKey, ids.toList());
  }

  Future<Set<String>> loadRemovedIds() async {
    final prefs = PrefsManager.instance;
    final items = prefs.getStringList(_removedKey) ?? const [];
    return items.toSet();
  }

  Future<void> saveRemovedIds(Set<String> ids) async {
    final prefs = PrefsManager.instance;
    await prefs.setStringList(_removedKey, ids.toList());
  }

  Future<Set<String>> loadSharedHiddenIds() async {
    final prefs = PrefsManager.instance;
    final items = prefs.getStringList(_hiddenSharedKey) ?? const [];
    return items.toSet();
  }

  Future<void> saveSharedHiddenIds(Set<String> ids) async {
    final prefs = PrefsManager.instance;
    await prefs.setStringList(_hiddenSharedKey, ids.toList());
  }
}
