import 'dart:convert';
import '../models/contact_group.dart';
import 'prefs_manager.dart';

class ContactGroupStore {
  static const String _key = 'contact_groups';

  Future<List<ContactGroup>> loadGroups() async {
    final prefs = PrefsManager.instance;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final groups = <ContactGroup>[];
        for (final value in decoded) {
          if (value is! Map<String, dynamic>) continue;
          try {
            final group = ContactGroup.fromJson(value);
            if (group.name.trim().isNotEmpty) groups.add(group);
          } catch (_) {
            // Skip one malformed group without discarding valid records.
          }
        }
        return groups;
      }
    } catch (_) {
      // Return empty list on parse errors.
    }
    return [];
  }

  Future<void> saveGroups(List<ContactGroup> groups) async {
    final prefs = PrefsManager.instance;
    final encoded = jsonEncode(groups.map((group) => group.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
