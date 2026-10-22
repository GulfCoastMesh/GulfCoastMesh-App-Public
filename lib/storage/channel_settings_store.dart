import '../helpers/region_scope_codes.dart';
import 'prefs_manager.dart';

class ChannelSettingsStore {
  static const String _smazKeyPrefix = 'channel_smaz_';
  static const String _regionScopeKeyPrefix = 'channel_region_scope_';

  Future<bool> loadSmazEnabled(int channelIndex) async {
    final prefs = PrefsManager.instance;
    final key = '$_smazKeyPrefix$channelIndex';
    return prefs.getBool(key) ?? false;
  }

  Future<void> saveSmazEnabled(int channelIndex, bool enabled) async {
    final prefs = PrefsManager.instance;
    final key = '$_smazKeyPrefix$channelIndex';
    await prefs.setBool(key, enabled);
  }

  /// Per-channel flood scope code, or null when unscoped / device default.
  Future<String?> loadRegionScope(int channelIndex) async {
    final prefs = PrefsManager.instance;
    final key = '$_regionScopeKeyPrefix$channelIndex';
    final value = prefs.getString(key)?.trim();
    if (value == null || value.isEmpty) return null;
    final canonical = RegionScopeCodes.canonicalize(value);
    if (canonical != value) await prefs.setString(key, canonical);
    return canonical;
  }

  Future<void> saveRegionScope(int channelIndex, String? scope) async {
    final prefs = PrefsManager.instance;
    final key = '$_regionScopeKeyPrefix$channelIndex';
    final trimmed = scope == null ? null : RegionScopeCodes.canonicalize(scope);
    if (trimmed == null || trimmed.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, trimmed);
    }
  }
}
