import 'dart:convert';

import '../helpers/region_scope_codes.dart';
import '../models/gulf_coast_region_tree.dart';
import '../models/mesh_region.dart';
import 'prefs_manager.dart';

/// Persists user-known region codes (seeded with Gulf Coast operational scopes).
class KnownRegionsStore {
  static const String _key = 'known_mesh_regions';

  Future<List<String>> load() async {
    final prefs = PrefsManager.instance;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return _seedCodes();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final codes = decoded
            .map((value) => value?.toString().trim() ?? '')
            .where((value) => value.isNotEmpty)
            .toList();
        final migrated = _withSeeds(codes);
        final encoded = jsonEncode(migrated);
        if (encoded != raw) await prefs.setString(_key, encoded);
        return migrated;
      }
    } catch (_) {
      // fall through
    }
    return _seedCodes();
  }

  Future<void> save(List<String> codes) async {
    final prefs = PrefsManager.instance;
    await prefs.setString(_key, jsonEncode(_withSeeds(codes)));
  }

  Future<List<String>> add(String code) async {
    final trimmed = RegionScopeCodes.canonicalize(code);
    final current = await load();
    if (trimmed.isEmpty || current.contains(trimmed)) return current;
    final next = [...current, trimmed];
    await save(next);
    return next;
  }

  List<String> _seedCodes() => _withSeeds(const []);

  List<String> _withSeeds(List<String> codes) {
    final seen = <String>{};
    final result = <String>[];

    // Operational send scopes first (us, us-la, …).
    for (final code in GulfCoastRegionTree.sendSelectableCodes) {
      if (seen.add(code)) result.add(code);
    }
    // Include the distinct MeshMapper scopes still assigned by the policy.
    for (final preset in MeshRegion.gulfCoastPresets) {
      if (seen.add(preset.code)) result.add(preset.code);
    }
    for (final code in codes) {
      final trimmed = RegionScopeCodes.canonicalize(code);
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed)) result.add(trimmed);
    }
    return result;
  }
}
