import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/services/repeater_command_service.dart';
import 'package:gulf_coast_mesh_app/services/weather_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('demo mode', () {
    late MeshCoreConnector connector;

    setUp(() => connector = MeshCoreConnector());
    tearDown(() => connector.dispose());

    test(
      'starts with representative connected data and exits cleanly',
      () async {
        await connector.enterDemoMode();

        expect(connector.isDemoMode, isTrue);
        expect(connector.isConnected, isTrue);
        expect(connector.deviceDisplayName, 'Demo Operator');
        expect(connector.contacts, hasLength(greaterThanOrEqualTo(5)));
        expect(
          connector.contacts.any((contact) => contact.type == advTypeRepeater),
          isTrue,
        );
        expect(
          connector.contacts.any((contact) => contact.type == advTypeRoom),
          isTrue,
        );
        expect(
          connector.channels.any((channel) => channel.name == '#weather'),
          isTrue,
        );
        expect(
          connector.channels.any((channel) => channel.name == '#wx-bot-hidden'),
          isTrue,
        );
        expect(
          connector.getChannelMessages(connector.channels.first),
          isNotEmpty,
        );

        final contact = connector.contacts.first;
        expect(await connector.loadOlderChannelMessages(0), isEmpty);
        expect(
          await connector.loadOlderMessages(contact.publicKeyHex),
          isEmpty,
        );
        expect(await connector.loadTacticalChannelMessages(2), hasLength(2));
        final before = connector.getMessages(contact).length;
        await connector.sendMessage(contact, 'Demo outbound message');
        expect(connector.getMessages(contact), hasLength(before + 1));
        expect(connector.getMessages(contact).last.status.name, 'delivered');

        await connector.exitDemoMode();
        expect(connector.isDemoMode, isFalse);
        expect(connector.isConnected, isFalse);
        expect(connector.contacts, isEmpty);
        expect(connector.channels, isEmpty);

        await connector.enterDemoMode();
        expect(connector.isConnected, isTrue);
        await connector.disconnect();
        expect(connector.isDemoMode, isFalse);
      },
    );

    test('emulates repeater login and binary status responses', () async {
      await connector.enterDemoMode();
      final repeater = connector.contacts.firstWhere(
        (contact) => contact.type == advTypeRepeater,
      );
      final frames = <List<int>>[];
      final subscription = connector.receivedFrames.listen(frames.add);

      await connector.sendFrame(
        buildSendLoginFrame(repeater.publicKey, 'any demo password'),
      );
      await connector.sendFrame(
        buildSendStatusRequestFrame(repeater.publicKey),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(
        frames.any((frame) => frame.first == pushCodeLoginSuccess),
        isTrue,
      );
      final status = frames.firstWhere(
        (frame) => frame.first == pushCodeStatusResponse,
      );
      expect(status, hasLength(60));

      await connector.sendFrame(
        buildSendBinaryReq(
          repeater.publicKey,
          payload: Uint8List.fromList([reqTypeGetTelemetry]),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 180));
      expect(frames.any((frame) => frame.first == respCodeSent), isTrue);
      expect(
        frames.any((frame) => frame.first == pushCodeBinaryResponse),
        isTrue,
      );

      final commands = RepeaterCommandService(connector);
      final commandReplies = connector.receivedFrames.listen((frame) {
        final parsed = parseContactMessageText(frame);
        if (parsed != null) commands.handleResponse(repeater, parsed.text);
      });
      final version = await commands.sendCommand(repeater, 'ver', retries: 1);
      expect(version, contains('v1.12.0-demo'));
      await commandReplies.cancel();
      commands.dispose();
      await subscription.cancel();
    });

    test(
      'weather client discovers the demo bot and receives a report',
      () async {
        await connector.enterDemoMode();
        final weather = WeatherApiService(connector);
        addTearDown(weather.dispose);

        await weather.discover();
        expect(weather.status, WeatherStatus.ready);
        await weather.requestWeather('39501');

        expect(weather.status, WeatherStatus.ready);
        expect(weather.report?.zipCode, '39501');
        expect(weather.report?.hourly, isNotEmpty);
        expect(weather.report?.alerts, isNotEmpty);
        await weather.requestCurrent('39501');
        expect(weather.currentSummary?['l'], 'Gulf Coast (demo)');
        await weather.requestVersion();
        expect(weather.toolResult?['git_commit'], 'demo-api2');
        await weather.requestHelp();
        expect(weather.capabilities, 255);
        await weather.requestRadar(30.4515, -91.1871, 3);
        expect(weather.status, WeatherStatus.ready);
        expect(weather.radar?['s'], 'forecast');
        expect(weather.radar?['c'], hasLength(812));
        weather.selectBotContact(
          connector.contacts.firstWhere((c) => c.name == 'DeltaWX'),
        );
        await weather.ping();
        expect(weather.toolResult?['k'], 'pong');
        await weather.subscribe('39501');
        expect(weather.toolResult?['status'], 'enabled');
        await weather.unsubscribe();
        expect(weather.toolResult?['status'], 'stopped');
      },
    );
  });
}
