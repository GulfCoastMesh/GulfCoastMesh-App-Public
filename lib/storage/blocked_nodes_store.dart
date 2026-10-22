import 'dart:convert';
import '../models/blocked_node.dart';
import 'prefs_manager.dart';

class BlockedNodesStore {
  static const String _key = 'blocked_nodes';

  Future<List<BlockedNode>> loadNodes() async {
    final raw = PrefsManager.instance.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final nodes = <BlockedNode>[];
        for (final value in decoded) {
          if (value is! Map<String, dynamic>) continue;
          try {
            nodes.add(BlockedNode.fromJson(value));
          } catch (_) {
            // Skip one malformed entry without discarding valid records.
          }
        }
        return nodes;
      }
    } catch (_) {
      // Return empty list on parse errors.
    }
    return [];
  }

  Future<void> saveNodes(List<BlockedNode> nodes) async {
    final encoded = jsonEncode(nodes.map((node) => node.toJson()).toList());
    await PrefsManager.instance.setString(_key, encoded);
  }
}
