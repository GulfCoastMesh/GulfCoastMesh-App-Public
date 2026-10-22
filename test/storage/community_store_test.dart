import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/community.dart';
import 'package:gulf_coast_mesh_app/storage/community_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/storage/secure_password_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CommunityStore store;
  late InMemorySecurePasswordStore secrets;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    secrets = InMemorySecurePasswordStore();
    store = CommunityStore(secretStore: secrets);
  });

  tearDown(() {
    PrefsManager.reset();
  });

  Map<String, dynamic> goodCommunity(String id, String name) {
    return {
      'id': id,
      'name': name,
      'secret': base64Encode(List.filled(32, 7)),
      'created_at': 1700000000000,
      'hashtag_channels': <String>[],
    };
  }

  test('one corrupt record does not drop the others', () async {
    final bad = {'id': 'broken', 'name': 42};

    await PrefsManager.instance.setString(
      'communities_v1',
      jsonEncode([
        goodCommunity('a', 'Alpha'),
        bad,
        goodCommunity('b', 'Beta'),
      ]),
    );

    final loaded = await store.loadCommunities();
    expect(loaded.map((c) => c.id), ['a', 'b']);
    expect(loaded.map((c) => c.name), ['Alpha', 'Beta']);
    expect(PrefsManager.instance.getString('communities_v1'), isNull);
    expect(await secrets.read('communities_secure_v1'), isNotNull);
  });

  test('community with a short secret is skipped', () async {
    final shortSecret = goodCommunity('bad', 'Short')
      ..['secret'] = base64Encode(List.filled(4, 7));
    await secrets.write(
      'communities_secure_v1',
      jsonEncode([goodCommunity('a', 'Alpha'), shortSecret]),
    );

    final loaded = await store.loadCommunities();
    expect(loaded.map((community) => community.id), ['a']);
  });

  test('top-level invalid json returns empty list', () async {
    await PrefsManager.instance.setString('communities_v1', 'not json');
    final loaded = await store.loadCommunities();
    // Migration writes invalid JSON into secure storage and parse yields empty.
    expect(loaded, isEmpty);
  });

  test('concurrent additions do not overwrite each other', () async {
    final delayedSecrets = _DelayedFirstWriteSecureStore();
    final concurrentStore = CommunityStore(secretStore: delayedSecrets);
    final first = concurrentStore.addCommunity(_community('a', 'Alpha'));
    await delayedSecrets.firstWriteStarted.future;
    final second = concurrentStore.addCommunity(_community('b', 'Beta'));
    delayedSecrets.releaseFirstWrite.complete();

    await Future.wait([first, second]);
    expect(
      (await concurrentStore.loadCommunities()).map(
        (community) => community.id,
      ),
      ['a', 'b'],
    );
  });
}

Community _community(String id, String name) => Community(
  id: id,
  name: name,
  secret: Uint8List.fromList(List.filled(32, 7)),
  createdAt: DateTime.utc(2026, 1, 1),
);

class _DelayedFirstWriteSecureStore implements SecurePasswordStore {
  final firstWriteStarted = Completer<void>();
  final releaseFirstWrite = Completer<void>();
  final Map<String, String> _data = {};
  var _writeCount = 0;

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _writeCount++;
    if (_writeCount == 1) {
      firstWriteStarted.complete();
      await releaseFirstWrite.future;
    }
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<Map<String, String>> readAll() async => Map.of(_data);
}
