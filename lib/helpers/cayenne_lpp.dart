import 'dart:typed_data';
import 'package:gulf_coast_mesh_app/utils/app_logger.dart';

import '../connector/meshcore_protocol.dart';

class CayenneLpp {
  static const int lppDigitalInput = 0; // 1 byte
  static const int lppDigitalOutput = 1; // 1 byte
  static const int lppAnalogInput = 2; // 2 bytes, 0.01 signed
  static const int lppAnalogOutput = 3; // 2 bytes, 0.01 signed
  static const int lppGenericSensor = 100; // 4 bytes, unsigned
  static const int lppLuminosity = 101; // 2 bytes, 1 lux unsigned
  static const int lppPresence = 102; // 1 byte, bool
  static const int lppTemperature = 103; // 2 bytes, 0.1°C signed
  static const int lppRelativeHumidity = 104; // 1 byte, 0.5% unsigned
  static const int lppAccelerometer = 113; // 2 bytes per axis, 0.001G
  static const int lppBarometricPressure = 115; // 2 bytes 0.1hPa unsigned
  static const int lppVoltage = 116; // 2 bytes 0.01V unsigned
  static const int lppCurrent = 117; // 2 bytes 0.001A unsigned
  static const int lppFrequency = 118; // 4 bytes 1Hz unsigned
  static const int lppPercentage = 120; // 1 byte 1-100% unsigned
  static const int lppAltitude = 121; // 2 byte 1m signed
  static const int lppConcentration = 125; // 2 bytes, 1 ppm unsigned
  static const int lppPower = 128; // 2 byte, 1W, unsigned
  static const int lppDistance = 130; // 4 byte, 0.001m, unsigned
  static const int lppEnergy = 131; // 4 byte, 0.001kWh, unsigned
  static const int lppDirection = 132; // 2 bytes, 1deg, unsigned
  static const int lppUnixTime = 133; // 4 bytes, unsigned
  static const int lppGyrometer = 134; // 2 bytes per axis, 0.01 °/s
  static const int lppColour = 135; // 1 byte per RGB Color
  static const int lppGps =
      136; // 3 byte lon/lat 0.0001 °, 3 bytes alt 0.01 meter
  static const int lppSwitch = 142; // 1 byte, 0/1
  static const int lppPolyline =
      240; // 1 byte size, 1 byte delta factor, 3 byte lon/lat 0.0001° * factor, n (size-8) bytes deltas

  final BufferWriter _writer = BufferWriter();

  Uint8List toBytes() {
    return _writer.toBytes();
  }

  void addDigitalInput(int channel, int value) {
    _writer.writeByte(channel);
    _writer.writeByte(lppDigitalInput);
    _writer.writeByte(value);
  }

  void addTemperature(int channel, double value) {
    _writer.writeByte(channel);
    _writer.writeByte(lppTemperature);
    final val = (value * 10).toInt();
    _writer.writeBytes(_int16ToBE(val));
  }

  void addVoltage(int channel, double value) {
    _writer.writeByte(channel);
    _writer.writeByte(lppVoltage);
    final val = (value * 100).toInt();
    _writer.writeBytes(_int16ToBE(val));
  }

  void addGps(int channel, double lat, double lon, double alt) {
    _writer.writeByte(channel);
    _writer.writeByte(lppGps);
    _writer.writeBytes(_int24ToBE((lat * 10000).toInt()));
    _writer.writeBytes(_int24ToBE((lon * 10000).toInt()));
    _writer.writeBytes(_int24ToBE((alt * 100).toInt()));
  }

  Uint8List _int16ToBE(int value) {
    final bytes = Uint8List(2);
    final data = ByteData.view(bytes.buffer);
    data.setInt16(0, value, Endian.big);
    return bytes;
  }

  Uint8List _int24ToBE(int value) {
    final bytes = Uint8List(3);
    bytes[0] = (value >> 16) & 0xFF;
    bytes[1] = (value >> 8) & 0xFF;
    bytes[2] = value & 0xFF;
    return bytes;
  }

  /// Decodes one value of [type], advancing [buffer] by exactly its width.
  ///
  /// Returns null for a type of unknown width — the caller must then stop,
  /// because without the width there is no way to find the next channel byte.
  ///
  /// Both [parse] and [parseByChannel] read through here so a newly supported
  /// type only has to be added once.
  static ({String key, Object value})? _readValue(
    BufferReader buffer,
    int type,
  ) {
    switch (type) {
      case lppDigitalInput:
        return (key: 'digital_input', value: buffer.readUInt8());
      case lppDigitalOutput:
        return (key: 'digital_output', value: buffer.readUInt8());
      case lppAnalogInput:
        return (key: 'analog_input', value: buffer.readInt16BE() / 100.0);
      case lppAnalogOutput:
        return (key: 'analog_output', value: buffer.readInt16BE() / 100.0);
      case lppGenericSensor:
        return (key: 'generic', value: buffer.readUInt32BE());
      case lppLuminosity:
        return (key: 'luminosity', value: buffer.readUInt16BE());
      case lppPresence:
        return (key: 'presence', value: buffer.readUInt8() != 0);
      case lppTemperature:
        return (key: 'temperature', value: buffer.readInt16BE() / 10.0);
      case lppRelativeHumidity:
        return (key: 'humidity', value: buffer.readUInt8() / 2.0);
      case lppAccelerometer:
        return (
          key: 'accelerometer',
          value: {
            'x': buffer.readInt16BE() / 1000.0,
            'y': buffer.readInt16BE() / 1000.0,
            'z': buffer.readInt16BE() / 1000.0,
          },
        );
      case lppBarometricPressure:
        return (key: 'pressure', value: buffer.readUInt16BE() / 10.0);
      case lppVoltage:
        return (key: 'voltage', value: buffer.readInt16BE() / 100.0);
      case lppCurrent:
        return (key: 'current', value: buffer.readInt16BE() / 1000.0);
      case lppFrequency:
        return (key: 'frequency', value: buffer.readUInt32BE());
      case lppPercentage:
        return (key: 'percentage', value: buffer.readUInt8());
      case lppAltitude:
        return (key: 'altitude', value: buffer.readInt16BE());
      case lppConcentration:
        return (key: 'concentration', value: buffer.readUInt16BE());
      case lppPower:
        return (key: 'power', value: buffer.readUInt16BE());
      case lppDistance:
        return (key: 'distance', value: buffer.readUInt32BE() / 1000.0);
      case lppEnergy:
        return (key: 'energy', value: buffer.readUInt32BE() / 1000.0);
      case lppDirection:
        return (key: 'direction', value: buffer.readUInt16BE());
      case lppUnixTime:
        return (key: 'unix_time', value: buffer.readUInt32BE());
      case lppGyrometer:
        return (
          key: 'gyrometer',
          value: {
            'x': buffer.readInt16BE() / 100.0,
            'y': buffer.readInt16BE() / 100.0,
            'z': buffer.readInt16BE() / 100.0,
          },
        );
      case lppColour:
        return (
          key: 'colour',
          value: {
            'r': buffer.readUInt8(),
            'g': buffer.readUInt8(),
            'b': buffer.readUInt8(),
          },
        );
      case lppGps:
        return (
          key: 'gps',
          value: {
            'latitude': buffer.readInt24BE() / 10000.0,
            'longitude': buffer.readInt24BE() / 10000.0,
            'altitude': buffer.readInt24BE() / 100.0,
          },
        );
      case lppSwitch:
        return (key: 'switch', value: buffer.readUInt8() != 0);
      default:
        // lppPolyline is variable-length and the rest are unknown; either way
        // the next channel boundary is unfindable from here.
        return null;
    }
  }

  static List<Map<String, dynamic>> parse(Uint8List bytes) {
    final buffer = BufferReader(bytes);
    final telemetry = <Map<String, dynamic>>[];
    try {
      while (buffer.remaining >= 2) {
        final channel = buffer.readUInt8();
        final type = buffer.readUInt8();

        if (channel == 0 && type == 0) {
          break;
        }

        final decoded = _readValue(buffer, type);
        if (decoded == null) {
          appLogger.error(
            'Unsupported Cayenne LPP type $type; stopped parsing',
          );
          return telemetry;
        }
        telemetry.add({
          'channel': channel,
          'type': type,
          'value': decoded.value,
        });
      }
      return telemetry;
    } catch (e) {
      // Handle parsing errors, possibly due to malformed data
      appLogger.error('Error parsing Cayenne LPP data: $e');
      // Return any telemetry parsed so far to preserve partial data
      return telemetry;
    }
  }

  static List<Map<String, dynamic>> parseByChannel(Uint8List bytes) {
    final buffer = BufferReader(bytes);
    final Map<int, Map<String, dynamic>> channels = {};

    List<Map<String, dynamic>> sorted() {
      // A channel whose first value failed to decode was registered but never
      // filled; emitting it would render an empty card.
      final out = channels.values
          .where((c) => (c['values'] as Map).isNotEmpty)
          .toList();
      out.sort((a, b) => (a['channel'] as int).compareTo(b['channel'] as int));
      return out;
    }

    try {
      while (buffer.remaining >= 2) {
        final channel = buffer.readUInt8();
        final type = buffer.readUInt8();

        // Optional: stop on padding (00 00)
        if (channel == 0 && type == 0) {
          break;
        }

        final channelData = channels.putIfAbsent(
          channel,
          () => {'channel': channel, 'values': <String, dynamic>{}},
        );

        final decoded = _readValue(buffer, type);
        if (decoded == null) {
          // Stopped parsing to avoid misalignment.
          appLogger.error(
            'Unsupported Cayenne LPP type $type; stopped parsing',
          );
          return sorted();
        }
        (channelData['values'] as Map<String, dynamic>)[decoded.key] =
            decoded.value;
      }

      return sorted();
    } catch (e) {
      // Handle parsing errors, possibly due to malformed data
      appLogger.error('Error parsing Cayenne LPP data: $e');
      // Preserve whatever decoded cleanly rather than discarding the payload.
      return sorted();
    }
  }
}
