import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/blocked_node.dart';
import 'package:gulf_coast_mesh_app/services/blocked_nodes_service.dart';
import 'package:gulf_coast_mesh_app/storage/blocked_nodes_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final keyA = 'AB' * 32;
  final keyB = 'cd' * 32;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });
  tearDown(PrefsManager.reset);

  test('block, isBlocked is case-insensitive, unblock', () async {
    final service = BlockedNodesService();
    var notified = 0;
    service.addListener(() => notified++);

    await service.block(publicKeyHex: keyA, name: 'A', type: 2);
    expect(service.isBlocked(keyA), isTrue);
    expect(service.isBlocked(keyA.toLowerCase()), isTrue);
    expect(service.isBlocked(keyB), isFalse);
    expect(service.entries.single.publicKeyHex, keyA.toLowerCase());

    await service.unblock(keyA.toUpperCase());
    expect(service.isBlocked(keyA), isFalse);
    expect(service.count, 0);
    expect(notified, 2);
  });

  test('unblock of an unknown key does not notify', () async {
    final service = BlockedNodesService();
    var notified = 0;
    service.addListener(() => notified++);
    await service.unblock(keyA);
    await service.unblockAll();
    expect(notified, 0);
  });

  test('unblockAll empties the list and persists', () async {
    final service = BlockedNodesService();
    await service.block(publicKeyHex: keyA, name: 'A', type: 2);
    await service.block(publicKeyHex: keyB, name: 'B', type: 1);
    await service.unblockAll();
    expect(service.entries, isEmpty);

    final reloaded = BlockedNodesService();
    await reloaded.load();
    expect(reloaded.entries, isEmpty);
  });

  test('entries are newest first', () async {
    final service = BlockedNodesService();
    await service.block(publicKeyHex: keyA, name: 'first', type: 2);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await service.block(publicKeyHex: keyB, name: 'second', type: 1);
    expect(service.entries.map((n) => n.name), ['second', 'first']);
  });

  test('persistence round trip', () async {
    final service = BlockedNodesService();
    await service.block(publicKeyHex: keyA, name: 'Bayou', type: 2);

    final reloaded = BlockedNodesService();
    await reloaded.load();
    final node = reloaded.entries.single;
    expect(node.publicKeyHex, keyA.toLowerCase());
    expect(node.name, 'Bayou');
    expect(node.type, 2);
    expect(reloaded.isBlocked(keyA), isTrue);
  });

  test('corrupt or missing data yields an empty list', () async {
    final store = BlockedNodesStore();
    expect(await store.loadNodes(), isEmpty);

    await PrefsManager.instance.setString('blocked_nodes', '{not json');
    expect(await store.loadNodes(), isEmpty);

    await PrefsManager.instance.setString('blocked_nodes', '{"a":1}');
    expect(await store.loadNodes(), isEmpty);

    final service = BlockedNodesService();
    await service.load();
    expect(service.entries, isEmpty);
  });

  test('one malformed entry does not discard the valid ones', () async {
    await PrefsManager.instance.setString(
      'blocked_nodes',
      '[1, {"name":"no key"}, {"key":"$keyB","name":"ok","type":"x"}]',
    );
    final nodes = await BlockedNodesStore().loadNodes();
    expect(nodes.single.publicKeyHex, keyB);
    expect(nodes.single.type, 0);
  });

  test('BlockedNode JSON round trip normalizes the key', () {
    final node = BlockedNode(
      publicKeyHex: keyA,
      name: 'N',
      type: 3,
      blockedAt: DateTime.fromMillisecondsSinceEpoch(1234567),
    );
    final copy = BlockedNode.fromJson(node.toJson());
    expect(copy.publicKeyHex, keyA.toLowerCase());
    expect(copy.blockedAt, node.blockedAt);
    expect(copy.type, 3);
  });

  test(
    'demo-mode blocks are not persisted and the real list returns',
    () async {
      final service = BlockedNodesService();
      await service.block(publicKeyHex: keyA, name: 'real', type: 2);

      service.enterDemoMode();
      expect(service.entries, isEmpty);
      await service.block(publicKeyHex: keyB, name: 'demo', type: 1);
      expect(service.isBlocked(keyB), isTrue);
      await service.unblock(keyB);
      await service.block(publicKeyHex: keyB, name: 'demo', type: 1);

      final storedDuringDemo = await BlockedNodesStore().loadNodes();
      expect(storedDuringDemo.map((n) => n.publicKeyHex), [keyA.toLowerCase()]);

      service.exitDemoMode();
      expect(service.entries.map((n) => n.name), ['real']);
      expect(service.isBlocked(keyB), isFalse);
      final storedAfter = await BlockedNodesStore().loadNodes();
      expect(storedAfter.map((n) => n.name), ['real']);
    },
  );
}
