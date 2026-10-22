import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';
import 'package:gulf_coast_mesh_app/services/weather_api_service.dart';

import '../support/fake_weather_connector.dart';
import '../support/weather_api2_fixtures.dart';

void main() {
  late FakeWeatherConnector connector;
  late WeatherApiService weather;
  setUp(() {
    connector = FakeWeatherConnector();
    weather = WeatherApiService(connector);
  });
  tearDown(() {
    weather.dispose();
    connector.dispose();
  });
  Future<void> discover() async {
    connector.onSend = (_) => connector.emit(
      positional(2, [
        255,
        [140, 16],
        ['F', 'mph', '%'],
      ]),
    );
    await weather.discover();
    connector.onSend = null;
    expect(weather.status, WeatherStatus.ready);
    expect(connector.sent.last, 'bot api2');
  }

  test(
    'discovery accepts the hidden API channel name without a hash',
    () async {
      connector.channelList
        ..clear()
        ..add(
          Channel(
            index: 3,
            name: 'wx-bot-hidden',
            psk: Channel.derivePskFromHashtag('#wx-bot-hidden'),
          ),
        );

      await discover();

      expect(connector.configuredChannels, isEmpty);
    },
  );

  test(
    'discovery creates the hidden API channel in the first free slot',
    () async {
      connector.channelList
        ..clear()
        ..add(
          Channel(
            index: 0,
            name: '#weather',
            psk: Channel.derivePskFromHashtag('#weather'),
          ),
        );

      await discover();

      expect(connector.configuredChannels, hasLength(1));
      final configured = connector.configuredChannels.single;
      expect(configured.index, 1);
      expect(configured.name, '#wx-bot-hidden');
      expect(
        configured.psk,
        orderedEquals(Channel.derivePskFromHashtag('#wx-bot-hidden')),
      );
      expect(
        connector.channelList.any((channel) => channel.name == '#weather'),
        true,
      );
    },
  );

  test(
    'discovery pins sender and forecasts ignore wrong channel and sender',
    () async {
      await discover();
      final request = weather.requestWeather('00601');
      connector.emit(weatherVector, sender: 'Other bot');
      connector.emit(weatherVector, channel: 2);
      expect(weather.report, isNull);
      expect(weather.isBusy, true);
      connector.emit(weatherVector);
      await request;
      expect(connector.sent.last, 'wx 00601 all api2');
      expect(weather.report!.current.apparentTemperatureF, 77);
      expect(weather.report!.hourly, hasLength(5));
    },
  );

  test(
    'radar waits for all parts and validates requested coordinates/hour',
    () async {
      await discover();
      final request = weather.requestRadar(30.4515, -91.1871, 0);
      connector.emit(withResponseId(forecastRadarVector, 9)); // Wrong hour.
      expect(weather.radar, isNull);
      for (final frame in observedRadarVectors.take(3)) {
        connector.emit(frame);
      }
      expect(weather.receivedParts, 3);
      expect(weather.radar, isNull);
      connector.emit(observedRadarVectors.last);
      await request;
      expect(weather.radar!['s'], 'observed');
      expect(connector.sent.last, 'wx radar 30.45150 -91.18710 now api2');
    },
  );

  test(
    'DM tools require selection and do not accept channel replies or history',
    () async {
      await discover();
      await weather.ping();
      expect(connector.dmSent, isEmpty);
      expect(weather.errorMessage, contains('Select'));
      weather.selectBotContact(connector.bot);
      final old = positional(5, ['old', 'Direct']);
      connector.emitDm(old);
      final request = weather.ping();
      connector.emit(positional(5, ['channel', 'Direct']));
      expect(weather.toolResult, isNull);
      connector.emitDm(positional(5, ['2026-09-12T12:00:00Z', 'Direct', 12.5]));
      await request;
      expect(connector.dmSent.last, 'ping api2');
      expect(weather.toolResult!['approx_direct_miles'], 12.5);
    },
  );

  test(
    'subscription commands and acknowledgements use selected bot DMs',
    () async {
      await discover();
      weather.selectBotContact(connector.bot);
      final enable = weather.subscribe('00601-1234');
      connector.emitDm(
        withResponseId(positional(4, ['enabled', '60601']), 9),
      ); // Wrong ZIP.
      expect(weather.toolResult, isNull);
      connector.emitDm(positional(4, ['enabled', '00601']));
      await enable;
      expect(connector.dmSent.last, 'wx report 00601 api2');
      final stop = weather.unsubscribe();
      connector.emitDm(
        positional(4, [
          'stopped',
          null,
          ['00601'],
        ]),
      );
      await stop;
      expect(connector.dmSent.last, 'wx report stop api2');
      expect(weather.toolResult!['status'], 'stopped');
    },
  );

  test('refresh errors preserve prior report and permit correction', () async {
    await discover();
    final first = weather.requestWeather('00601');
    connector.emit(weatherVector);
    await first;
    final next = weather.requestWeather('99999');
    connector.emit(positional(6, ['wx', 1, '99999']));
    await next;
    expect(weather.status, WeatherStatus.error);
    expect(weather.report!.zipCode, '00601');
    expect(weather.errorMessage, contains('not found'));
    await weather.requestWeather('bad');
    expect(weather.isBusy, false);
  });

  test(
    'missing hourly timestamp stays unavailable rather than becoming now',
    () async {
      await discover();
      final request = weather.requestWeather('00601');
      // Independent Python encoder fixture with a null hourly time offset.
      connector.emit('~W2AQECA9kEgMri0AY_iAEEZMIDFJoBAT6IAQTCAxQU');
      await request;
      expect(weather.report!.hourly.single.minutesAfterGenerated, isNull);
    },
  );

  test(
    'disconnect cancels pending work without resurrecting stale state',
    () async {
      await discover();
      final pending = weather.requestWeather('00601');
      connector.disconnect();
      await pending;
      connector.emit(weatherVector);
      expect(weather.status, WeatherStatus.idle);
      expect(weather.report, isNull);
      expect(weather.errorMessage, isNull);
      expect(weather.isBusy, false);
    },
  );

  testWidgets('partial responses expire and a retry starts cleanly', (
    tester,
  ) async {
    await discover();
    final request = weather.requestRadar(30.4515, -91.1871, 0);
    connector.emit(observedRadarVectors.first);
    await tester.pump(const Duration(seconds: 61));
    await request;
    expect(weather.status, WeatherStatus.error);
    expect(weather.radar, isNull);
    final retry = weather.requestRadar(30.4515, -91.1871, 0);
    for (final frame in observedRadarVectors.skip(1)) {
      connector.emit(frame);
    }
    expect(weather.radar, isNull);
    connector.emit(observedRadarVectors.first);
    await retry;
    expect(weather.status, WeatherStatus.ready);
  });
  group('normalizeUsZip', () {
    test('accepts five digit ZIP codes and ZIP+4', () {
      expect(normalizeUsZip('70112'), '70112');
      expect(normalizeUsZip(' 70112-1234 '), '70112');
    });

    test('rejects non-US ZIP formats', () {
      expect(normalizeUsZip('7011'), isNull);
      expect(normalizeUsZip('70112 1234'), isNull);
      expect(normalizeUsZip('ABC12'), isNull);
    });
  });
}
