import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';
import 'package:gulf_coast_mesh_app/storage/channel_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/storage/secure_password_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ChannelStore store;
  late InMemorySecurePasswordStore secrets;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    secrets = InMemorySecurePasswordStore();
    store = ChannelStore(secretStore: secrets);
  });

  tearDown(() {
    PrefsManager.reset();
  });

  Map<String, dynamic> goodChannel(int index, String name) {
    return {
      'index': index,
      'name': name,
      'psk': base64Encode(List.filled(16, index & 0xff)),
      'unreadCount': 0,
    };
  }

  test('one corrupt record does not drop the others', () async {
    final bad = {'index': 'not-an-int', 'name': 'corrupt'};

    await PrefsManager.instance.setString(
      'channels',
      jsonEncode([goodChannel(0, 'public'), bad, goodChannel(1, 'side')]),
    );

    final loaded = await store.loadChannels();
    expect(loaded.map((c) => c.name), ['public', 'side']);
    expect(loaded.map((c) => c.index), [0, 1]);
  });

  test('top-level invalid json returns empty list', () async {
    await PrefsManager.instance.setString('channels', 'not json');
    final loaded = await store.loadChannels();
    expect(loaded, isEmpty);
  });

  test('migrates embedded PSK into secure storage', () async {
    await PrefsManager.instance.setString(
      'channels',
      jsonEncode([goodChannel(0, 'public')]),
    );

    final loaded = await store.loadChannels();
    expect(loaded.single.psk, List.filled(16, 0));

    final prefsJson = PrefsManager.instance.getString('channels')!;
    expect(prefsJson.contains('"psk"'), isFalse);
    expect(await secrets.read('channel_psks_v1'), isNotNull);
  });

  test('round-trips PSK via secure storage', () async {
    final channel = Channel(
      index: 3,
      name: '#ops',
      psk: Uint8List.fromList(List.generate(16, (i) => i + 1)),
    );
    await store.saveChannels([channel]);
    final loaded = await store.loadChannels();
    expect(loaded.single.psk, channel.psk);
    expect(loaded.single.name, '#ops');
  });

  test('round-trips isFavorite', () async {
    final favorite = Channel(
      index: 0,
      name: '#favorite',
      psk: Uint8List(16),
      isFavorite: true,
    );
    final notFavorite = Channel(index: 1, name: '#other', psk: Uint8List(16));
    await store.saveChannels([favorite, notFavorite]);

    final loaded = await store.loadChannels();
    expect(loaded[0].isFavorite, isTrue);
    expect(loaded[1].isFavorite, isFalse);
  });

  test('missing isFavorite in stored json defaults to false', () async {
    await PrefsManager.instance.setString(
      'channels',
      jsonEncode([goodChannel(0, 'public')]),
    );

    final loaded = await store.loadChannels();
    expect(loaded.single.isFavorite, isFalse);
  });
}
