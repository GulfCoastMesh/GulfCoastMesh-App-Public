import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/weather_api2_codec.dart';
import 'package:gulf_coast_mesh_app/helpers/weather_inflate.dart';

import '../support/weather_api2_fixtures.dart';

void main() {
  test('documented error, null weather and compressed weather vectors', () {
    expect(decodeFrames(['~W2BgECA1sid3giLDFd'])['error'], 1);
    final empty = decodeFrames(['~W2AQECA9kEgMri0AYAAA']);
    expect(empty['z'], '00601');
    expect(empty['n'], List.filled(6, null));
    final weather = decodeFrames([weatherVector]);
    expect(weather['n'], [68, 2, 50, 225, 10, 77]);
    expect((weather['h'] as List).last, [240, 72, 2, 225, 10, 10]);
    expect(weather['a'], [
      [6, 2],
    ]);
  });

  test(
    'Python fixture preserves negative values, irregular hours and null transitions',
    () {
      final result = decodeFrames([
        '~W2AQECA9kEgMri0AY7Ew7OBQAnSzUADgDIAR-0AQkAvAUEK7QBCrsFADU',
      ]);
      expect(result['n'], [-10, 7, null, 359, 0, -20]);
      expect(result['h'], [
        [0, null, 7, null, 0, 100],
        [90, -5, 7, 350, 2, null],
        [180, 0, null, 0, null, 0],
      ]);
      expect(result['x'], true);
    },
  );

  test('all positional types accept omitted optional fields', () {
    final fixtures = {
      2: [
        255,
        [140, 16],
        ['F', 'mph', '%'],
      ],
      3: ['abc123'],
      4: [
        'stopped',
        null,
        ['00601'],
      ],
      5: ['2026-09-12T12:00:00Z', 'Direct'],
      6: ['radar', 7],
      7: ['00601', 'City', null, 'Cloudy'],
    };
    for (final entry in fixtures.entries) {
      expect(
        decodeFrames([positional(entry.key, entry.value)])['k'],
        isNotNull,
      );
    }
    expect(
      () => decodeFrames([
        positional(3, ['commit', 'extra']),
      ]),
      throwsFormatException,
    );
    expect(
      () => decodeFrames([
        positional(2, ['wrong']),
      ]),
      throwsFormatException,
    );
    expect(
      () => decodeFrames([
        positional(4, ['stopped', null, 'wrong']),
      ]),
      throwsFormatException,
    );
  });

  test(
    'Python radar fixture decodes signed metadata and cross-byte cell codes',
    () {
      final radar = decodeFrames([forecastRadarVector]);
      expect(radar['s'], 'forecast');
      expect(radar['lat'], 30.4515);
      expect(radar['lon'], -91.1871);
      expect(radar['i'], 1779992800);
      expect(radar['c'], List.generate(812, (i) => i % 8));
    },
  );

  test(
    'four-message Python radar accepts reordered and identical duplicates',
    () {
      final first = WeatherApi2Frame(observedRadarVectors[2]);
      final group = WeatherApi2Group(first);
      expect(group.add(first), isNull);
      expect(group.add(first), isNull);
      expect(group.received, 1);
      expect(group.add(WeatherApi2Frame(observedRadarVectors[0])), isNull);
      expect(group.add(WeatherApi2Frame(observedRadarVectors[3])), isNull);
      final radar = group.add(WeatherApi2Frame(observedRadarVectors[1]))!;
      expect(radar['s'], 'observed');
      expect(radar.containsKey('i'), false);
      expect((radar['c'] as List).take(8), [1, 0, 4, 3, 3, 2, 1, 1]);
      expect(radar['c'], hasLength(812));
    },
  );

  test(
    'conflicting copies, flags, reserved types and oversized frames fail',
    () {
      final frame = WeatherApi2Frame(observedRadarVectors.first);
      final group = WeatherApi2Group(frame)..add(frame);
      final raw = base64Url.decode(
        base64Url.normalize(observedRadarVectors.first.substring(3)),
      );
      raw[10] ^= 1;
      expect(
        () => group.add(WeatherApi2Frame(armor(raw))),
        throwsFormatException,
      );
      raw[0] ^= 16;
      expect(
        () => group.add(WeatherApi2Frame(armor(raw))),
        throwsFormatException,
      );
      for (final flags in [0, 9, 128, 255]) {
        expect(
          () => WeatherApi2Frame(armor([flags, 1, 2, 3, 0])),
          throwsFormatException,
        );
      }
      expect(
        () => WeatherApi2Frame(armor([72, 1, 2, 3, 0, 5, 0])),
        throwsFormatException,
      );
      expect(() => WeatherApi2Frame('~w2AQECAw'), throwsFormatException);
      expect(
        () => WeatherApi2Frame(armor(List.filled(103, 1))),
        throwsFormatException,
      );
    },
  );

  test('both radar profiles enforce metadata, exact lengths and padding', () {
    for (final width in [28, 32]) {
      final bytes = radarPayload(width);
      expect(
        decodeWeatherApi2Payload(8, bytes)['c'],
        hasLength(width == 28 ? 616 : 812),
      );
      expect(
        () => decodeWeatherApi2Payload(8, bytes.sublist(0, bytes.length - 1)),
        throwsFormatException,
      );
      bytes[0] = 2;
      expect(() => decodeWeatherApi2Payload(8, bytes), throwsFormatException);
      bytes[0] = 1; // Forecast without issue time.
      expect(() => decodeWeatherApi2Payload(8, bytes), throwsFormatException);
    }
    final padded = radarPayload(32)..last = 128;
    expect(() => decodeWeatherApi2Payload(8, padded), throwsFormatException);
  });

  test(
    'binary weather rejects noncanonical integers, masks and trailing bytes',
    () {
      for (final bytes in [
        [128, 0],
        List.filled(11, 255),
        [0, 0, 64],
        [0, 0, 0, 128],
        [0, 0, 0, 0, 0],
      ]) {
        expect(
          () => decodeWeatherApi2Payload(1, Uint8List.fromList(bytes)),
          throwsFormatException,
        );
      }
    },
  );

  test(
    'bounded inflater agrees with zlib across stored, fixed and dynamic blocks',
    () {
      final random = Random(2026);
      final fixtures = <List<int>>[
        [],
        [1],
        List.generate(8192, (i) => i % 251),
        List.generate(4096, (_) => random.nextInt(256)),
        utf8.encode(
          List.filled(80, 'Gulf Coast weather rain rain radar cloudy ').join(),
        ),
      ];
      for (final fixture in fixtures) {
        for (final level in [0, 1, 6, 9]) {
          final packed = Uint8List.fromList(
            ZLibEncoder(raw: true, level: level).convert(fixture),
          );
          expect(inflateWeatherPayload(packed), fixture);
          expect(
            () => inflateWeatherPayload(packed.sublist(0, packed.length - 1)),
            throwsFormatException,
          );
          expect(
            () => inflateWeatherPayload(Uint8List.fromList([...packed, 0])),
            throwsFormatException,
          );
        }
      }
      final bomb = Uint8List.fromList(
        ZLibEncoder(raw: true).convert(List.filled(8193, 0)),
      );
      expect(() => inflateWeatherPayload(bomb), throwsFormatException);
      expect(
        () => inflateWeatherPayload(Uint8List.fromList([7])),
        throwsFormatException,
      );
    },
  );
}
