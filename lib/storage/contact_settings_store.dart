import 'prefs_manager.dart';

class ContactSettingsStore {
  static const String _smazKeyPrefix = 'contact_smaz_';

  Future<bool> loadSmazEnabled(String contactKeyHex) async {
    final prefs = PrefsManager.instance;
    final key = '$_smazKeyPrefix$contactKeyHex';
    return prefs.getBool(key) ?? false;
  }

  Future<void> saveSmazEnabled(String contactKeyHex, bool enabled) async {
    final prefs = PrefsManager.instance;
    final key = '$_smazKeyPrefix$contactKeyHex';
    await prefs.setBool(key, enabled);
  }
}
