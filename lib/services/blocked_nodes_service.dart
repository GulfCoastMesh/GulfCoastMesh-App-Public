import 'package:flutter/foundation.dart';

import '../models/blocked_node.dart';
import '../storage/blocked_nodes_store.dart';

/// The persisted list of nodes the user chose to hide. Independent of the
/// contact cache, so it survives contact deletion, resync and restart.
class BlockedNodesService extends ChangeNotifier {
  BlockedNodesService({BlockedNodesStore? store})
    : _store = store ?? BlockedNodesStore();

  final BlockedNodesStore _store;
  final Map<String, BlockedNode> _nodes = {};
  Map<String, BlockedNode>? _realNodesDuringDemo;

  bool get _inDemo => _realNodesDuringDemo != null;

  Future<void> load() async {
    final loaded = await _store.loadNodes();
    _nodes
      ..clear()
      ..addEntries(loaded.map((node) => MapEntry(node.publicKeyHex, node)));
    notifyListeners();
  }

  /// Blocked nodes, newest first.
  List<BlockedNode> get entries {
    final list = _nodes.values.toList();
    list.sort((a, b) => b.blockedAt.compareTo(a.blockedAt));
    return list;
  }

  int get count => _nodes.length;

  bool isBlocked(String publicKeyHex) =>
      _nodes.containsKey(publicKeyHex.toLowerCase());

  Future<void> block({
    required String publicKeyHex,
    required String name,
    required int type,
  }) async {
    final node = BlockedNode(
      publicKeyHex: publicKeyHex,
      name: name,
      type: type,
      blockedAt: DateTime.now(),
    );
    _nodes[node.publicKeyHex] = node;
    notifyListeners();
    await _persist();
  }

  Future<void> unblock(String publicKeyHex) async {
    if (_nodes.remove(publicKeyHex.toLowerCase()) == null) return;
    notifyListeners();
    await _persist();
  }

  Future<void> unblockAll() async {
    if (_nodes.isEmpty) return;
    _nodes.clear();
    notifyListeners();
    await _persist();
  }

  /// Demo mode keeps its blocks in memory only; the real list is set aside.
  void enterDemoMode() {
    if (_inDemo) return;
    _realNodesDuringDemo = Map.of(_nodes);
    _nodes.clear();
    notifyListeners();
  }

  void exitDemoMode() {
    final real = _realNodesDuringDemo;
    if (real == null) return;
    _realNodesDuringDemo = null;
    _nodes
      ..clear()
      ..addAll(real);
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_inDemo) return;
    await _store.saveNodes(_nodes.values.toList());
  }
}
