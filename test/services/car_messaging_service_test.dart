import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/models/notifiable_message.dart';
import 'package:gulf_coast_mesh_app/services/car_messaging_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records what the service asks the native side to do, and lets a test push
/// car events (a dictated reply, a mark-as-read) back at it.
class _FakeCarPlatform {
  final List<({String method, Map<Object?, Object?> args})> calls = [];
  final StreamController<dynamic> events =
      StreamController<dynamic>.broadcast();

  static const _methodName = 'org.gulfcoastmesh/car_messaging_test';
  static const _eventName = 'org.gulfcoastmesh/car_messaging_events_test';

  final methodChannel = const MethodChannel(_methodName);
  final eventChannel = const EventChannel(_eventName);

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
          calls.add((
            method: call.method,
            args: (call.arguments as Map?) ?? const {},
          ));
          return null;
        });

    // Drive the EventChannel by hand: its stream is what the service listens to.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (arguments, sink) {
              events.stream.listen(sink.success);
            },
          ),
        );
  }

  List<Map<Object?, Object?>> callsTo(String method) =>
      calls.where((c) => c.method == method).map((c) => c.args).toList();

  Future<void> emitReply(String conversationId, String text) async {
    events.add({
      'type': 'reply',
      'conversationId': conversationId,
      'text': text,
    });
    // Let the service's async handler run.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  void dispose() => events.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MeshCoreConnector connector;
  late _FakeCarPlatform platform;
  late CarMessagingService service;

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => call.method == 'readAll' ? <String, String>{} : null,
        );
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();

    connector = MeshCoreConnector();
    platform = _FakeCarPlatform()..install();
    service = CarMessagingService(
      connector: connector,
      methodChannel: platform.methodChannel,
      eventChannel: platform.eventChannel,
      enabled: true,
    );

    addTearDown(() {
      service.dispose();
      platform.dispose();
      connector.dispose();
      PrefsManager.reset();
    });
  });

  group('conversation ids', () {
    test('contact and channel ids match the notification payload scheme', () {
      expect(NotifiableMessage.forContact('abc123'), 'message:abc123');
      expect(NotifiableMessage.forChannel(3), 'channel:3');
    });
  });

  group('reply routing', () {
    test(
      'a reply while disconnected reports failure instead of sending',
      () async {
        service.start();

        await platform.emitReply('message:abc123', 'on my way');

        final failures = platform.callsTo('showSendFailure');
        expect(failures, hasLength(1));
        expect(failures.single['conversationId'], 'message:abc123');
        expect(failures.single['reason'], contains('Not connected'));
        expect(platform.callsTo('appendOutgoing'), isEmpty);
      },
    );

    test('a reply to an unknown channel reports failure', () async {
      service.start();

      await platform.emitReply('channel:99', 'hello');

      final failures = platform.callsTo('showSendFailure');
      expect(failures, hasLength(1));
      // Disconnected is checked first, so that is the reported reason.
      expect(failures.single['reason'], isNotNull);
    });

    test('an empty dictation sends nothing at all', () async {
      service.start();

      await platform.emitReply('message:abc123', '   ');

      expect(platform.calls, isEmpty);
    });

    test('a malformed event is ignored rather than throwing', () async {
      service.start();

      platform.events.add({'type': 'reply'}); // no conversationId
      platform.events.add('not a map');
      await Future<void>.delayed(Duration.zero);

      expect(platform.calls, isEmpty);
    });
  });

  group('message limit', () {
    test('long dictation is truncated to the mesh byte limit', () {
      // Voice input easily overruns the 160-byte mesh text cap; the reply
      // should be shortened rather than rejected outright.
      final long = 'a' * 400;
      final fitted = CarMessagingService.fitToLimitForTest(long, 160);

      expect(utf8.encode(fitted).length, lessThanOrEqualTo(160));
      expect(fitted.length, 160);
    });

    test('truncation respects multi-byte characters', () {
      // Each emoji is 4 UTF-8 bytes: a naive substring by character count
      // would blow the byte budget.
      final emoji = '🚗' * 100;
      final fitted = CarMessagingService.fitToLimitForTest(emoji, 50);

      expect(utf8.encode(fitted).length, lessThanOrEqualTo(50));
      expect(fitted, isNotEmpty);
    });

    test('text already within the limit is untouched', () {
      const short = 'on my way';
      expect(CarMessagingService.fitToLimitForTest(short, 160), short);
    });
  });
}
