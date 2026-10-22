import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ChannelStore persists channel PSKs via flutter_secure_storage; stub its
  // platform channel so saveChannels() doesn't throw MissingPluginException.
  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannel, (call) async {
        if (call.method == 'readAll') return <String, String>{};
        return null;
      });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });

  tearDown(PrefsManager.reset);

  test('connector disposal is idempotent and rejects later sends', () async {
    final connector = MeshCoreConnector();

    connector.dispose();
    connector.dispose();
    connector.notifyListeners();

    await expectLater(
      connector.sendFrame(Uint8List.fromList([1])),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'disconnected message sends fail instead of silently dropping text',
    () async {
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);
      final contact = Contact(
        publicKey: Uint8List(32),
        name: 'Remote',
        type: 1,
        pathLength: 0,
        path: Uint8List(0),
        lastSeen: DateTime.utc(2026, 1, 1),
      );
      final channel = Channel(index: 1, name: '#test', psk: Uint8List(16));

      await expectLater(
        connector.sendMessage(contact, 'keep this draft'),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        connector.sendChannelMessage(channel, 'keep this draft'),
        throwsA(isA<StateError>()),
      );
      await expectLater(connector.syncTime(), throwsA(isA<StateError>()));
      await expectLater(
        connector.setNodeName('New name'),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        connector.setNodeLocation(lat: 1, lon: 2),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        connector.setCustomVar('gps:1'),
        throwsA(isA<StateError>()),
      );
      await expectLater(connector.sendSelfAdvert(), throwsA(isA<StateError>()));
      await expectLater(
        connector.sendCliCommand('ver'),
        throwsA(isA<StateError>()),
      );
      await expectLater(connector.rebootDevice(), throwsA(isA<StateError>()));
      await expectLater(
        connector.removeContact(contact),
        throwsA(isA<StateError>()),
      );
    },
  );

  test(
    'setContactNickname sets, overrides, and clears a local nickname',
    () async {
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);

      connector.addContactForTest(
        Contact(
          publicKey: Uint8List.fromList(List.filled(32, 7)),
          name: 'Remote',
          type: 1,
          pathLength: 0,
          path: Uint8List(0),
          lastSeen: DateTime.utc(2026, 1, 1),
        ),
      );
      final contact = connector.contacts.first;
      expect(contact.nickname, isNull);

      await connector.setContactNickname(contact, 'Bay Relay');
      var updated = connector.contacts.firstWhere(
        (c) => c.publicKeyHex == contact.publicKeyHex,
      );
      expect(updated.nickname, 'Bay Relay');
      expect(updated.displayName, 'Bay Relay');

      // Blank input clears the nickname rather than setting it literally.
      await connector.setContactNickname(updated, '   ');
      updated = connector.contacts.firstWhere(
        (c) => c.publicKeyHex == contact.publicKeyHex,
      );
      expect(updated.nickname, isNull);
      expect(updated.displayName, contact.name);
    },
  );

  test('toggleChannelFavorite flips and persists isFavorite', () async {
    final connector = MeshCoreConnector();
    addTearDown(connector.dispose);

    final channel = Channel(index: 0, name: '#ops', psk: Uint8List(16));
    connector.addChannelForTest(channel);
    expect(connector.channels.single.isFavorite, isFalse);

    await connector.toggleChannelFavorite(channel);
    expect(connector.channels.single.isFavorite, isTrue);

    await connector.toggleChannelFavorite(channel);
    expect(connector.channels.single.isFavorite, isFalse);
  });

  test('setChannel reports a disconnected no-op as an error', () async {
    final connector = MeshCoreConnector();
    addTearDown(connector.dispose);

    await expectLater(
      connector.setChannel(
        0,
        '#offline',
        Channel.derivePskFromHashtag('offline'),
      ),
      throwsStateError,
    );
  });

  test('truncated default flood scope response preserves known state', () {
    final connector = MeshCoreConnector();
    addTearDown(connector.dispose);
    final nameField = Uint8List(defaultFloodScopeNameField);
    nameField.setAll(0, 'regional'.codeUnits);
    connector.handleFrameForTest(
      Uint8List.fromList([
        respCodeDefaultFloodScope,
        ...nameField,
        ...Uint8List(defaultFloodScopeKeyBytes),
      ]),
    );
    expect(connector.defaultFloodScopeName, 'regional');

    connector.handleFrameForTest(
      Uint8List.fromList([respCodeDefaultFloodScope, 1, 2]),
    );
    expect(connector.defaultFloodScopeName, 'regional');

    connector.handleFrameForTest(
      Uint8List.fromList([respCodeDefaultFloodScope]),
    );
    expect(connector.defaultFloodScopeName, isNull);
  });

  test(
    'importContactAdvert rejects an invalid URI before touching the wire',
    () async {
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);

      await expectLater(
        connector.importContactAdvert('not-a-uri'),
        throwsA(isA<FormatException>()),
      );
      await expectLater(
        connector.importContactAdvert('meshcore://zz'),
        throwsA(isA<FormatException>()),
      );
      await expectLater(
        connector.importContactAdvert('meshcore://'),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test('importContactAdvert requires a live connection', () async {
    final connector = MeshCoreConnector();
    addTearDown(connector.dispose);
    final hex = 'ab' * 98;

    await expectLater(
      connector.importContactAdvert('meshcore://$hex'),
      throwsA(isA<StateError>()),
    );
  });
}
