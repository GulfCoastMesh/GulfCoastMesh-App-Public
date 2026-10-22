import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_meshcore_transport.dart';

/// The companion's generic OK/ERR carries no identifier, so the pending-ACK
/// queue is correlated purely by position. These tests pin that invariant:
/// giving up on a command must not shift the entries behind it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (call) async => call.method == 'readAll' ? <String, String>{} : null,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });

  tearDown(PrefsManager.reset);

  final channelSend = Uint8List.fromList([cmdSendChannelTxtMsg, 0, 0]);
  final importContact = Uint8List.fromList([cmdImportContact, 1, 2, 3]);
  final ok = Uint8List.fromList([respCodeOk]);
  final err = Uint8List.fromList([respCodeErr, 5]);

  MeshCoreConnector build() {
    final connector = MeshCoreConnector();
    addTearDown(connector.dispose);
    return connector;
  }

  Future<({MeshCoreConnector connector, FakeMeshCoreTransport transport})>
  connected() async {
    final transports = {
      for (final kind in MeshCoreTransportKind.values)
        kind: FakeMeshCoreTransport(kind),
    };
    final connector = MeshCoreConnector(transportOverrides: transports);
    addTearDown(connector.dispose);
    await connector.connect(
      const MeshCoreDevice(
        id: 'test:5000',
        displayName: 'Test radio',
        transportKind: MeshCoreTransportKind.tcp,
      ),
    );
    return (
      connector: connector,
      transport: transports[MeshCoreTransportKind.tcp]!,
    );
  }

  for (final success in [true, false]) {
    for (final early in [true, false]) {
      test(
        '${success ? 'OK' : 'ERR'} ${early ? 'during' : 'after'} a write resolves its command',
        () async {
          final h = await connected();
          final outcomes = <bool>[];
          h.transport.onSend = (frame) async {
            if (early && frame[0] == cmdImportContact) {
              h.transport.receive(success ? ok : err);
            }
          };
          await h.connector.sendFrame(
            importContact,
            expectsGenericAck: true,
            completion: outcomes.add,
          );
          if (!early) h.transport.receive(success ? ok : err);
          await Future<void>.delayed(Duration.zero);
          expect(outcomes, [success]);
          expect(h.connector.pendingGenericAckCountForTest, 0);
        },
      );
    }
  }

  test('failed write removes only its own pending entry', () async {
    final h = await connected();
    final firstWrite = Completer<void>();
    h.transport.onSend = (frame) async {
      if (frame[0] == cmdImportContact && frame[1] == 1) {
        await firstWrite.future;
      }
    };
    final first = h.connector.sendFrame(importContact, expectsGenericAck: true);
    final failure = expectLater(first, throwsStateError);
    final outcomes = <bool>[];
    await h.connector.sendFrame(
      Uint8List.fromList([cmdImportContact, 2]),
      expectsGenericAck: true,
      completion: outcomes.add,
    );
    firstWrite.completeError(StateError('write failed'));
    await failure;
    expect(h.connector.pendingGenericAckCountForTest, 1);
    h.transport.receive(ok);
    await Future<void>.delayed(Duration.zero);
    expect(outcomes, [true]);
    expect(h.connector.pendingGenericAckCountForTest, 0);
  });

  test('an early acknowledgement wins over a late write error', () async {
    final h = await connected();
    final outcomes = <bool>[];
    h.transport.onSend = (frame) async {
      if (frame[0] != cmdImportContact) return;
      h.transport.receive(ok);
      await Future<void>.delayed(Duration.zero);
      throw StateError('late write error');
    };
    await h.connector.sendFrame(
      importContact,
      expectsGenericAck: true,
      completion: outcomes.add,
    );
    expect(outcomes, [true]);
    expect(h.connector.pendingGenericAckCountForTest, 0);
  });

  test(
    'disconnect during a write does not leave a new pending entry',
    () async {
      final h = await connected();
      final write = Completer<void>();
      h.transport.onSend = (frame) async {
        if (frame[0] == cmdImportContact) await write.future;
      };
      final sending = h.connector.sendFrame(
        importContact,
        expectsGenericAck: true,
      );
      await h.connector.disconnect();
      write.complete();
      await sending;
      expect(h.connector.pendingGenericAckCountForTest, 0);
    },
  );

  test('giving up on a send does not hand its ACK to the next command', () {
    final connector = build();
    final importResults = <bool>[];

    // A channel send goes out, then a contact import, before either is acked.
    connector.trackPendingGenericAckForTest(
      channelSend,
      channelSendQueueId: 'send-a',
    );
    connector.trackPendingGenericAckForTest(
      importContact,
      completion: importResults.add,
    );
    expect(connector.pendingGenericAckCountForTest, 2);

    // The send times out and the app stops tracking it, but the companion
    // still owes an OK for it.
    connector.cancelPendingGenericAckForTest('send-a');
    expect(
      connector.pendingGenericAckCountForTest,
      2,
      reason: 'the slot must stay queued to preserve positional correlation',
    );

    // That late OK belongs to the abandoned send, NOT to the import.
    connector.handleFrameForTest(ok);
    expect(
      importResults,
      isEmpty,
      reason: 'the import must not be reported successful by another OK',
    );
    expect(connector.pendingGenericAckCountForTest, 1);

    // The import's own OK resolves it.
    connector.handleFrameForTest(ok);
    expect(importResults, [true]);
    expect(connector.pendingGenericAckCountForTest, 0);
  });

  test('a cancelled entry absorbs an ERR the same way', () {
    final connector = build();
    final importResults = <bool>[];

    connector.trackPendingGenericAckForTest(
      channelSend,
      channelSendQueueId: 'send-a',
    );
    connector.trackPendingGenericAckForTest(
      importContact,
      completion: importResults.add,
    );
    connector.cancelPendingGenericAckForTest('send-a');

    connector.handleFrameForTest(err);
    expect(importResults, isEmpty);

    connector.handleFrameForTest(err);
    expect(importResults, [false]);
  });

  test('ordinary acks still resolve in order', () {
    final connector = build();
    final results = <String>[];

    connector.trackPendingGenericAckForTest(
      importContact,
      completion: (ok) => results.add('first:$ok'),
    );
    connector.trackPendingGenericAckForTest(
      importContact,
      completion: (ok) => results.add('second:$ok'),
    );

    connector.handleFrameForTest(ok);
    expect(results, ['first:true']);
    connector.handleFrameForTest(err);
    expect(results, ['first:true', 'second:false']);
    expect(connector.pendingGenericAckCountForTest, 0);
  });

  test('only commands whose ack drives state are queued', () {
    final connector = build();

    // A radio-settings read acks too, but nothing keys off it; queuing it
    // would desync every entry behind it.
    connector.trackPendingGenericAckForTest(
      Uint8List.fromList([cmdGetRadioSettings]),
    );
    expect(connector.pendingGenericAckCountForTest, 0);

    connector.trackPendingGenericAckForTest(Uint8List(0));
    expect(connector.pendingGenericAckCountForTest, 0);
  });

  test('an ack with nothing outstanding is ignored', () {
    final connector = build();
    expect(() => connector.handleFrameForTest(ok), returnsNormally);
    expect(() => connector.handleFrameForTest(err), returnsNormally);
    expect(connector.pendingGenericAckCountForTest, 0);
  });
}
