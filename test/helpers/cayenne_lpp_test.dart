import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/cayenne_lpp.dart';

Uint8List bytes(List<int> values) => Uint8List.fromList(values);

void main() {
  group('parseByChannel', () {
    test('decodes the repeater battery/temperature/humidity payload', () {
      // What MeshCore repeaters actually send: ch1 voltage 4.21V,
      // ch1 temperature 25.0C, ch1 humidity 65%.
      final frame = bytes([
        1, CayenneLpp.lppVoltage, 0x01, 0xA5, // 421 / 100
        1, CayenneLpp.lppTemperature, 0x00, 0xFA, // 250 / 10
        1, CayenneLpp.lppRelativeHumidity, 130, // 130 / 2
      ]);

      final parsed = CayenneLpp.parseByChannel(frame);

      expect(parsed, hasLength(1));
      expect(parsed.single['channel'], 1);
      final values = parsed.single['values'] as Map<String, dynamic>;
      expect(values['voltage'], closeTo(4.21, 1e-9));
      expect(values['temperature'], closeTo(25.0, 1e-9));
      expect(values['humidity'], closeTo(65.0, 1e-9));
    });

    test('groups by channel and sorts ascending', () {
      final frame = bytes([
        3,
        CayenneLpp.lppPercentage,
        40,
        1,
        CayenneLpp.lppPercentage,
        10,
        2,
        CayenneLpp.lppPercentage,
        20,
      ]);

      final parsed = CayenneLpp.parseByChannel(frame);

      expect(parsed.map((c) => c['channel']), [1, 2, 3]);
    });

    test('stops at the 00 00 padding terminator', () {
      final frame = bytes([
        1,
        CayenneLpp.lppPercentage,
        42,
        0,
        0,
        9,
        CayenneLpp.lppPercentage,
        99,
      ]);

      final parsed = CayenneLpp.parseByChannel(frame);

      expect(parsed, hasLength(1));
      expect(
        (parsed.single['values'] as Map<String, dynamic>)['percentage'],
        42,
      );
    });

    test('signed values decode negative', () {
      final frame = bytes([
        1, CayenneLpp.lppTemperature, 0xFF, 0x38, // -200 / 10 = -20.0
        1, CayenneLpp.lppAltitude, 0xFF, 0xFB, // -5 m
      ]);

      final values =
          CayenneLpp.parseByChannel(frame).single['values']
              as Map<String, dynamic>;

      expect(values['temperature'], closeTo(-20.0, 1e-9));
      expect(values['altitude'], -5);
    });

    test('keeps values decoded before an unsupported type', () {
      // lppPolyline is variable-length, so parsing cannot continue past it —
      // but what came before must survive.
      final frame = bytes([
        1,
        CayenneLpp.lppTemperature,
        0x00,
        0xFA,
        1,
        CayenneLpp.lppPolyline,
        0x08,
        0x00,
        2,
        CayenneLpp.lppPercentage,
        50,
      ]);

      final parsed = CayenneLpp.parseByChannel(frame);

      expect(parsed, hasLength(1), reason: 'channel 2 is past the abort point');
      expect(
        (parsed.single['values'] as Map<String, dynamic>)['temperature'],
        closeTo(25.0, 1e-9),
      );
    });

    test('a truncated trailing value keeps the earlier ones', () {
      final frame = bytes([
        1, CayenneLpp.lppTemperature, 0x00, 0xFA,
        1, CayenneLpp.lppVoltage, 0x01, // one byte short
      ]);

      final parsed = CayenneLpp.parseByChannel(frame);

      expect(parsed, hasLength(1));
      final values = parsed.single['values'] as Map<String, dynamic>;
      expect(values['temperature'], closeTo(25.0, 1e-9));
      expect(values.containsKey('voltage'), isFalse);
    });

    test('a channel whose only value fails to decode is not emitted', () {
      final frame = bytes([7, CayenneLpp.lppPolyline, 0x08]);

      expect(CayenneLpp.parseByChannel(frame), isEmpty);
    });

    test('empty input yields nothing', () {
      expect(CayenneLpp.parseByChannel(bytes([])), isEmpty);
    });

    group('types that previously aborted the whole payload', () {
      test('multi-axis accelerometer and gyrometer', () {
        final frame = bytes([
          1, CayenneLpp.lppAccelerometer,
          0x03, 0xE8, 0xFC, 0x18, 0x00, 0x00, // 1.0, -1.0, 0.0 G
          1, CayenneLpp.lppGyrometer,
          0x00, 0x64, 0xFF, 0x9C, 0x00, 0x00, // 1.0, -1.0, 0.0 deg/s
          1, CayenneLpp.lppPercentage, 77,
        ]);

        final values =
            CayenneLpp.parseByChannel(frame).single['values']
                as Map<String, dynamic>;

        expect(values['accelerometer'], {'x': 1.0, 'y': -1.0, 'z': 0.0});
        expect(values['gyrometer'], {'x': 1.0, 'y': -1.0, 'z': 0.0});
        // Proves the 6-byte widths were consumed exactly — a wrong width would
        // desynchronize and lose this.
        expect(values['percentage'], 77);
      });

      test('colour, switch and digital io', () {
        final frame = bytes([
          1,
          CayenneLpp.lppColour,
          0x10,
          0x20,
          0x30,
          1,
          CayenneLpp.lppSwitch,
          1,
          1,
          CayenneLpp.lppDigitalInput,
          1,
          1,
          CayenneLpp.lppDigitalOutput,
          0,
          1,
          CayenneLpp.lppPercentage,
          55,
        ]);

        final values =
            CayenneLpp.parseByChannel(frame).single['values']
                as Map<String, dynamic>;

        expect(values['colour'], {'r': 0x10, 'g': 0x20, 'b': 0x30});
        expect(values['switch'], isTrue);
        expect(values['digital_input'], 1);
        expect(values['digital_output'], 0);
        expect(values['percentage'], 55);
      });

      test('four-byte frequency, distance, energy and unix time', () {
        final frame = bytes([
          1, CayenneLpp.lppFrequency, 0x00, 0x0D, 0xF6, 0x38, // 915000 Hz
          1, CayenneLpp.lppDistance, 0x00, 0x00, 0x27, 0x10, // 10.0 m
          1, CayenneLpp.lppEnergy, 0x00, 0x00, 0x03, 0xE8, // 1.0 kWh
          1, CayenneLpp.lppUnixTime, 0x68, 0x00, 0x00, 0x00,
          1, CayenneLpp.lppPercentage, 33,
        ]);

        final values =
            CayenneLpp.parseByChannel(frame).single['values']
                as Map<String, dynamic>;

        expect(values['frequency'], 915000);
        expect(values['distance'], closeTo(10.0, 1e-9));
        expect(values['energy'], closeTo(1.0, 1e-9));
        expect(values['unix_time'], 0x68000000);
        expect(values['percentage'], 33);
      });

      test('analog in/out and direction', () {
        final frame = bytes([
          1, CayenneLpp.lppAnalogInput, 0xFF, 0x9C, // -1.00
          1, CayenneLpp.lppAnalogOutput, 0x00, 0x64, // 1.00
          1, CayenneLpp.lppDirection, 0x00, 0xB4, // 180 deg
          1, CayenneLpp.lppPercentage, 12,
        ]);

        final values =
            CayenneLpp.parseByChannel(frame).single['values']
                as Map<String, dynamic>;

        expect(values['analog_input'], closeTo(-1.0, 1e-9));
        expect(values['analog_output'], closeTo(1.0, 1e-9));
        expect(values['direction'], 180);
        expect(values['percentage'], 12);
      });
    });

    test('gps decodes lat/lon/alt', () {
      final frame = bytes([
        1, CayenneLpp.lppGps,
        0x04, 0xF2, 0x9D, // 32.4253
        0xF2, 0x58, 0x43, // -89.4909
        0x00, 0x03, 0xE8, // 10.00 m
      ]);

      final gps =
          (CayenneLpp.parseByChannel(frame).single['values']
              as Map<String, dynamic>)['gps'];

      expect(gps['latitude'], closeTo(32.4253, 1e-4));
      expect(gps['longitude'], closeTo(-89.4909, 1e-4));
      expect(gps['altitude'], closeTo(10.0, 1e-9));
    });
  });

  group('parse', () {
    test('returns a flat channel/type/value list', () {
      final frame = bytes([
        1,
        CayenneLpp.lppTemperature,
        0x00,
        0xFA,
        2,
        CayenneLpp.lppPercentage,
        50,
      ]);

      final parsed = CayenneLpp.parse(frame);

      expect(parsed, hasLength(2));
      expect(parsed[0]['channel'], 1);
      expect(parsed[0]['type'], CayenneLpp.lppTemperature);
      expect(parsed[0]['value'], closeTo(25.0, 1e-9));
      expect(parsed[1]['channel'], 2);
      expect(parsed[1]['value'], 50);
    });

    test('keeps entries decoded before an unsupported type', () {
      final frame = bytes([
        1,
        CayenneLpp.lppTemperature,
        0x00,
        0xFA,
        1,
        CayenneLpp.lppPolyline,
        0x08,
      ]);

      expect(CayenneLpp.parse(frame), hasLength(1));
    });
  });

  group('encoding round-trips through the decoder', () {
    test('voltage, temperature and gps', () {
      final lpp = CayenneLpp()
        ..addVoltage(1, 4.2)
        ..addTemperature(2, -3.5)
        ..addGps(3, 32.4253, -89.4909, 10.0);

      final parsed = CayenneLpp.parseByChannel(lpp.toBytes());

      expect(parsed, hasLength(3));
      expect((parsed[0]['values'] as Map)['voltage'], closeTo(4.2, 1e-9));
      expect((parsed[1]['values'] as Map)['temperature'], closeTo(-3.5, 1e-9));
      final gps = (parsed[2]['values'] as Map)['gps'];
      expect(gps['latitude'], closeTo(32.4253, 1e-4));
      expect(gps['longitude'], closeTo(-89.4909, 1e-4));
    });
  });
}
