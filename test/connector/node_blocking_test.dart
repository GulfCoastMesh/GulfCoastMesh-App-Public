import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/models/notifiable_message.dart';
import 'package:gulf_coast_mesh_app/services/app_settings_service.dart';
import 'package:gulf_coast_mesh_app/services/blocked_nodes_service.dart';
import 'package:gulf_coast_mesh_app/storage/blocked_nodes_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/node_blocking_fixtures.dart';
import '../support/recording_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MeshCoreConnector connector;
  late AppSettingsService settings;
  late BlockedNodesService blocked;
  late RecordingNotificationService sink;
  final alice = blockingTestContact('Alice', seed: 1);
  final bob = blockingTestContact('Bob', seed: 2);

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'contact_unread_count':
          '{"${alice.publicKeyHex}": 2, "${bob.publicKeyHex}": 3}',
    });
    PrefsManager.reset();
    await PrefsManager.initialize();
    sink = RecordingNotificationService();
    connector = MeshCoreConnector(notificationService: sink);
    settings = AppSettingsService();
    blocked = BlockedNodesService();
    connector.attachAppSettingsServiceForTest(settings);
    connector.attachBlockedNodesService(blocked);
    connector.addContactForTest(alice);
    connector.addContactForTest(bob);
    await connector.loadUnreadState();
  });

  tearDown(() {
    connector.dispose();
    settings.dispose();
    blocked.dispose();
    PrefsManager.reset();
  });

  Future<void> block(String key) =>
      blocked.block(publicKeyHex: key, name: 'x', type: 1);

  test(
    'switch OFF: blocked keys are not hidden and counts are untouched',
    () async {
      await block(alice.publicKeyHex);
      expect(connector.isNodeHidden(alice.publicKeyHex), isFalse);
      expect(connector.visibleContacts, hasLength(2));
      expect(connector.getTotalUnreadCount(), 5);
    },
  );

  test('switch ON: only blocked keys are hidden', () async {
    await settings.setExperimentalNodeBlockingEnabled(true);
    await block(alice.publicKeyHex);
    expect(connector.isNodeHidden(alice.publicKeyHex), isTrue);
    expect(connector.isNodeHidden(bob.publicKeyHex), isFalse);
    expect(connector.visibleContacts.map((c) => c.name), ['Bob']);
    // The full list is never filtered: routing and path lookup need it.
    expect(connector.contacts, hasLength(2));
  });

  test(
    'unread totals exclude blocked contacts and return on unblock',
    () async {
      await settings.setExperimentalNodeBlockingEnabled(true);
      await block(alice.publicKeyHex);
      expect(connector.getUnreadCountForContact(alice), 0);
      expect(connector.getUnreadCountForContact(bob), 3);
      expect(connector.getTotalUnreadCount(), 3);

      await blocked.unblock(alice.publicKeyHex);
      expect(connector.getTotalUnreadCount(), 5);
    },
  );

  test('connector notifies listeners when the block list changes', () async {
    var notified = 0;
    connector.addListener(() => notified++);
    await block(alice.publicKeyHex);
    await blocked.unblock(alice.publicKeyHex);
    expect(notified, 2);
  });

  test('demo mode blocks never leak into the real list', () async {
    await settings.setExperimentalNodeBlockingEnabled(true);
    await block(alice.publicKeyHex);

    await connector.enterDemoMode();
    expect(blocked.entries, isEmpty);
    final demoNode = connector.contacts.first;
    await blocked.block(
      publicKeyHex: demoNode.publicKeyHex,
      name: demoNode.name,
      type: demoNode.type,
    );
    expect(connector.isNodeHidden(demoNode.publicKeyHex), isTrue);

    await connector.exitDemoMode();
    expect(blocked.entries.map((n) => n.publicKeyHex), [alice.publicKeyHex]);
    final stored = await BlockedNodesStore().loadNodes();
    expect(stored.map((n) => n.publicKeyHex), [alice.publicKeyHex]);
  });

  test(
    'toggling the switch notifies; unrelated settings changes do not',
    () async {
      var notified = 0;
      connector.addListener(() => notified++);

      await settings.setExperimentalNodeBlockingEnabled(true);
      expect(notified, 1);
      await settings.setExperimentalWeatherEnabled(true);
      await settings.setExperimentalNodeBlockingEnabled(true);
      expect(notified, 1);
      await settings.setExperimentalNodeBlockingEnabled(false);
      expect(notified, 2);
    },
  );

  group('incoming direct message', () {
    // Demo mode gives the connector a self key and a chat contact without BLE.
    Future<Uint8List> enterDemoAndBuildFrame() async {
      await connector.enterDemoMode();
      final sender = connector.contacts.firstWhere(
        (c) => c.type == advTypeChat,
      );
      final frame = BytesBuilder()
        ..addByte(respCodeContactMsgRecv)
        ..add(sender.publicKey.sublist(0, 6))
        ..addByte(0xFF)
        ..addByte(txtTypePlain)
        ..add([1, 2, 3, 4])
        ..add('hello there'.codeUnits)
        ..addByte(0);
      return frame.toBytes();
    }

    Future<List<NotifiableMessage>> deliver(Uint8List frame) async {
      final emitted = <NotifiableMessage>[];
      final sub = connector.notifiableMessages.listen(emitted.add);
      connector.handleFrameForTest(frame);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();
      return emitted;
    }

    test('is notified when the sender is not blocked', () async {
      final frame = await enterDemoAndBuildFrame();
      final emitted = await deliver(frame);
      expect(emitted, hasLength(1));
      expect(sink.messages, hasLength(1));
    });

    test('is muted when the switch is ON and the sender is blocked', () async {
      final frame = await enterDemoAndBuildFrame();
      final sender = connector.contacts.firstWhere(
        (c) => c.type == advTypeChat,
      );
      await settings.setExperimentalNodeBlockingEnabled(true);
      await block(sender.publicKeyHex);

      final emitted = await deliver(frame);
      expect(emitted, isEmpty);
      expect(sink.messages, isEmpty);
      // The message is still received and saved.
      expect(connector.getMessages(sender).last.text, 'hello there');
    });

    test(
      'is delivered when the sender is blocked but the switch is OFF',
      () async {
        final frame = await enterDemoAndBuildFrame();
        final sender = connector.contacts.firstWhere(
          (c) => c.type == advTypeChat,
        );
        await block(sender.publicKeyHex);

        final emitted = await deliver(frame);
        expect(emitted, hasLength(1));
        expect(sink.messages, hasLength(1));
      },
    );
  });
}
