import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/helpers/edit_helper.dart';
import 'package:gulf_coast_mesh_app/helpers/reaction_helper.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';
import 'package:gulf_coast_mesh_app/models/channel_message.dart';
import 'package:gulf_coast_mesh_app/models/message.dart';
import 'package:gulf_coast_mesh_app/services/notification_service.dart';
import 'package:gulf_coast_mesh_app/storage/channel_message_store.dart';
import 'package:gulf_coast_mesh_app/storage/message_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_meshcore_transport.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final key = Uint8List.fromList(List.filled(32, 7));
  final keyHex = pubKeyToHex(key);
  final start = DateTime.utc(2026, 1, 1);
  final channel = Channel(index: 1, name: '#history', psk: Uint8List(16));
  late MeshCoreConnector connector;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'demo_history_cleanup_v1': true});
    PrefsManager.reset();
    await PrefsManager.initialize();
    NotificationService().suppressNotifications(true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => call.method == 'readAll' ? <String, String>{} : null,
        );
    connector = MeshCoreConnector(
      transportOverrides: {
        for (final kind in MeshCoreTransportKind.values)
          kind: FakeMeshCoreTransport(kind),
      },
    );
    await connector.connect(
      const MeshCoreDevice(
        id: 'test:5000',
        displayName: 'Test radio',
        transportKind: MeshCoreTransportKind.tcp,
      ),
    );
  });

  tearDown(() async {
    connector.dispose();
    await Future<void>.delayed(Duration.zero);
    NotificationService().suppressNotifications(false);
    PrefsManager.reset();
  });

  Future<void> loadContact() async {
    final frame = Uint8List(contactFrameSize)..[0] = respCodeContact;
    frame.setAll(contactPubKeyOffset, key);
    frame[contactTypeOffset] = advTypeChat;
    connector.handleFrameForTest(frame);
    await Future<void>.delayed(Duration.zero);
  }

  void receiveDm(String text, int seconds) {
    final timestamp = start.millisecondsSinceEpoch ~/ 1000 + seconds;
    final frame = BufferWriter()
      ..writeByte(respCodeContactMsgRecv)
      ..writeBytes(key.sublist(0, 6))
      ..writeByte(0)
      ..writeByte(txtTypePlain)
      ..writeUInt32LE(timestamp)
      ..writeBytes(Uint8List.fromList(utf8.encode(text)));
    connector.handleFrameForTest(frame.toBytes());
  }

  void receiveChannel(String text, int seconds) {
    final frame = BufferWriter()
      ..writeByte(respCodeChannelMsgRecv)
      ..writeByte(channel.index)
      ..writeByte(0)
      ..writeByte(txtTypePlain)
      ..writeUInt32LE(start.millisecondsSinceEpoch ~/ 1000 + seconds)
      ..writeBytes(Uint8List.fromList(utf8.encode('Remote: $text')));
    connector.handleFrameForTest(frame.toBytes());
  }

  test(
    'weather replies reach the service without notifications or unread activity',
    () async {
      final hidden = Channel(
        index: channel.index,
        name: '#wx-bot-hidden',
        psk: Uint8List(16),
      );
      connector.addChannelForTest(hidden);
      await connector.loadUnreadState();
      final received = <ChannelMessage>[];
      final notifications = <Object>[];
      final incoming = connector.receivedChannelMessages.listen(received.add);
      final alerts = connector.notifiableMessages.listen(notifications.add);
      addTearDown(incoming.cancel);
      addTearDown(alerts.cancel);
      receiveChannel('weather reply', 1);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(received, hasLength(1));
      expect(hidden.unreadCount, 0);
      expect(connector.getTotalUnreadCount(), 0);
      expect(notifications, isEmpty);
    },
  );

  test(
    'DM window saves preserve older history and legacy message edits',
    () async {
      final store = MessageStore();
      await store.saveMessages(keyHex, [
        for (var i = 0; i < 250; i++)
          Message(
            senderKey: key,
            text: 'dm-$i',
            timestamp: start.add(Duration(seconds: i)),
            isOutgoing: i == 248,
            status: MessageStatus.delivered,
          ),
      ]);
      await loadContact();
      final contact = connector.contacts.single;
      expect(connector.getMessages(contact), hasLength(200));
      expect(await store.loadMessages(keyHex), hasLength(250));

      // Exercise real incoming control-message handling, including null legacy IDs.
      final target = connector.getMessages(contact).last;
      receiveDm(
        EditHelper.buildEditText(
          newText: 'edited history',
          targetText: target.text,
          targetTimestamp: target.timestamp.millisecondsSinceEpoch ~/ 1000,
        ),
        300,
      );
      receiveDm('a new message', 301);
      receiveDm(
        ReactionHelper.buildDMReactionText(
          emoji: '👍',
          targetText: 'dm-248',
          targetTimestamp: start.millisecondsSinceEpoch ~/ 1000 + 248,
        ),
        302,
      );
      await Future<void>.delayed(Duration.zero);
      final removed = connector.getMessages(contact).first;
      await connector.deleteMessage(removed);
      connector.setOutgoingMessageStatus(
        contact,
        connector.getMessages(contact).last,
        MessageStatus.sent,
      );
      final older = await connector.loadOlderMessages(keyHex, count: 25);
      expect(older, hasLength(25));
      expect(older.first.text, 'dm-25');
      final saved = await store.loadMessages(keyHex);
      expect(saved, hasLength(250));
      expect(saved.first.text, 'dm-0');
      expect(saved.where((m) => m.text == removed.text), isEmpty);
      expect(saved.where((m) => m.text == 'dm-249'), isEmpty);
      expect(saved.where((m) => m.text == 'edited history'), hasLength(1));
      expect(saved.singleWhere((m) => m.text == 'dm-248').reactions['👍'], 1);
      expect(saved.last.status, MessageStatus.sent);

      // Deleting a paged-in message must not restore the earlier deletion.
      await connector.deleteMessage(older.last);
      expect(await store.loadMessages(keyHex), hasLength(249));
      expect(await connector.loadOlderMessages(keyHex), hasLength(25));
      expect(await connector.loadOlderMessages(keyHex), isEmpty);
    },
  );

  test(
    'channel edits, sends, deletions and tactical scans preserve the archive',
    () async {
      final store = ChannelMessageStore();
      await store.saveChannelMessages(1, [
        for (var i = 0; i < 250; i++)
          ChannelMessage(
            senderName: 'Remote',
            text: i == 0 ? 'a:v1|pos|30|-90|1767225600|Remote' : 'channel-$i',
            timestamp: start.add(Duration(seconds: i)),
            isOutgoing: false,
            status: ChannelMessageStatus.sent,
            channelIndex: 1,
          ),
      ]);
      connector.addChannelForTest(channel);
      await connector.loadAllChannelMessages(maxChannels: 2);
      expect(connector.getChannelMessages(channel), hasLength(200));
      expect(await store.loadChannelMessages(1), hasLength(250));
      expect(await connector.loadTacticalChannelMessages(1), hasLength(1));

      final target = connector.getChannelMessages(channel).last;
      receiveChannel(
        EditHelper.buildChannelEditText(
          newText: 'edited channel history',
          targetSender: 'Remote',
          targetText: target.text,
          targetTimestamp: target.timestamp.millisecondsSinceEpoch ~/ 1000,
        ),
        300,
      );
      receiveChannel(
        ReactionHelper.buildReactionText(
          emoji: '👍',
          targetSender: 'Remote',
          targetText: 'edited channel history',
          targetTimestamp: target.timestamp.millisecondsSinceEpoch ~/ 1000,
        ),
        301,
      );
      await connector.sendChannelMessage(channel, 'new outgoing');
      connector.handleFrameForTest(Uint8List.fromList([respCodeOk]));
      final removed = connector.getChannelMessages(channel).first;
      await connector.deleteChannelMessage(removed);
      final older = await connector.loadOlderChannelMessages(1, count: 25);
      expect(older, hasLength(25));
      expect(older.first.text, 'channel-25');
      await connector.deleteChannelMessage(older.last);
      final saved = await store.loadChannelMessages(1);
      expect(saved, hasLength(249));
      expect(saved.where((m) => m.messageId == removed.messageId), isEmpty);
      expect(saved.last.text, 'new outgoing');
      expect(saved.last.status, ChannelMessageStatus.sent);
      final edited = saved.singleWhere((m) => m.messageId == target.messageId);
      expect(edited.text, 'edited channel history');
      expect(edited.reactions['👍'], 1);
      expect(await connector.loadTacticalChannelMessages(1), hasLength(1));

      final restarted = MeshCoreConnector();
      addTearDown(restarted.dispose);
      await restarted.loadAllChannelMessages(maxChannels: 2);
      expect(restarted.getChannelMessages(channel), hasLength(200));
      expect(await restarted.loadOlderChannelMessages(1), hasLength(49));
      expect(await store.loadChannelMessages(1), hasLength(249));
    },
  );

  test(
    'a DM arriving during initial load is saved with the full archive',
    () async {
      final store = MessageStore();
      await store.saveMessages(keyHex, [
        for (var i = 0; i < 250; i++)
          Message(
            senderKey: key,
            text: 'dm-$i',
            timestamp: start.add(Duration(seconds: i)),
            isOutgoing: false,
          ),
      ]);
      final loading = loadContact();
      receiveDm('received while loading', 300);
      await loading;
      final saved = await store.loadMessages(keyHex);
      expect(saved, hasLength(251));
      expect(saved.last.text, 'received while loading');
      expect(await connector.loadOlderMessages(keyHex), hasLength(50));
      expect(await connector.loadOlderMessages(keyHex), hasLength(1));
    },
  );
}
