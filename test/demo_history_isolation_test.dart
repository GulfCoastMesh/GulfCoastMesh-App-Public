import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/models/channel_message.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/models/message.dart';
import 'package:gulf_coast_mesh_app/storage/channel_message_store.dart';
import 'package:gulf_coast_mesh_app/storage/contact_store.dart';
import 'package:gulf_coast_mesh_app/storage/message_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChannelMessageStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    store = ChannelMessageStore();
  });

  tearDown(PrefsManager.reset);

  ChannelMessage channelMessage(String text) => ChannelMessage(
    senderName: 'real-node',
    text: text,
    timestamp: DateTime(2026, 1, 1),
    isOutgoing: false,
    status: ChannelMessageStatus.sent,
    channelIndex: 0,
  );

  test(
    'startup cleanup removes persisted demo fixtures but keeps real history',
    () async {
      await store.saveChannelMessages(0, [
        channelMessage('real history'),
        channelMessage('Good evening from Gulfport harbor.'),
        channelMessage('Copy in Gulf Breeze, FL — 4 hops.'),
        channelMessage('Hi from Pearl River, LA.'),
      ]);
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);

      await connector.loadAllChannelMessages(maxChannels: 1);

      expect(
        (await store.loadChannelMessages(0)).map((message) => message.text),
        ['real history'],
      );
    },
  );

  test(
    'startup cleanup removes direct-message history for demo contacts',
    () async {
      final store = MessageStore();
      final demoKey = Uint8List.fromList(
        List<int>.generate(32, (index) => (11 + index * 3) & 0xFF),
      );
      await store.saveMessages(
        '0b0e1114171a1d202326292c2f3235383b3e4144474a4d505356595c5f626568',
        [
          Message(
            senderKey: demoKey,
            text: 'demo history',
            timestamp: DateTime(2026, 1, 1),
            isOutgoing: false,
            status: MessageStatus.delivered,
          ),
        ],
      );
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);

      await connector.loadAllChannelMessages(maxChannels: 1);

      expect(
        await store.loadMessages(
          '0b0e1114171a1d202326292c2f3235383b3e4144474a4d505356595c5f626568',
        ),
        isEmpty,
      );
    },
  );

  test('contact cache excludes persisted demo contacts', () async {
    final store = ContactStore();
    final demoKey = Uint8List.fromList(
      List<int>.generate(32, (index) => (11 + index * 3) & 0xFF),
    );
    await store.saveContacts([
      Contact(
        publicKey: demoKey,
        name: 'BayouRelay_1',
        type: 1,
        pathLength: 1,
        path: Uint8List(0),
        lastSeen: DateTime(2026, 1, 1),
        lastMessageAt: DateTime(2026, 1, 1),
      ),
    ]);
    final connector = MeshCoreConnector();
    addTearDown(connector.dispose);

    await connector.loadContactCache();

    expect(await store.loadContacts(), isEmpty);
  });
}
