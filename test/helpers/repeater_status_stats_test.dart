import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/helpers/repeater_status_stats.dart';

/// Builds a status frame whose 52-byte stats block encodes each field with a
/// distinct value, so a swapped or misaligned field is impossible to miss.
Uint8List _buildStatusFrame({
  Uint8List? prefix,
  int batteryMv = 4103,
  int queueLen = 7,
  int noiseFloor = -96,
  int lastRssi = -112,
  int packetsRecv = 123456,
  int packetsSent = 654321,
  int txAirSecs = 1111,
  int uptimeSecs = 86400,
  int floodTx = 21,
  int directTx = 22,
  int floodRx = 23,
  int directRx = 24,
  int errEvents = 5,
  int lastSnrRaw = -26,
  int directDups = 31,
  int floodDups = 32,
  int rxAirSecs = 2222,
}) {
  final frame = Uint8List(repeaterStatusResponseBytes);
  frame[0] = pushCodeStatusResponse;
  frame.setAll(2, prefix ?? Uint8List.fromList([1, 2, 3, 4, 5, 6]));
  final data = ByteData.sublistView(frame, repeaterStatusPayloadOffset);
  data.setUint16(0, batteryMv, Endian.little);
  data.setUint16(2, queueLen, Endian.little);
  data.setInt16(4, noiseFloor, Endian.little);
  data.setInt16(6, lastRssi, Endian.little);
  data.setUint32(8, packetsRecv, Endian.little);
  data.setUint32(12, packetsSent, Endian.little);
  data.setUint32(16, txAirSecs, Endian.little);
  data.setUint32(20, uptimeSecs, Endian.little);
  data.setUint32(24, floodTx, Endian.little);
  data.setUint32(28, directTx, Endian.little);
  data.setUint32(32, floodRx, Endian.little);
  data.setUint32(36, directRx, Endian.little);
  data.setUint16(40, errEvents, Endian.little);
  data.setInt16(42, lastSnrRaw, Endian.little);
  data.setUint16(44, directDups, Endian.little);
  data.setUint16(46, floodDups, Endian.little);
  data.setUint32(48, rxAirSecs, Endian.little);
  return frame;
}

void main() {
  test('the stats block is exactly 52 bytes after an 8-byte header', () {
    expect(repeaterStatusStatsSize, 52);
    expect(repeaterStatusResponseBytes, 60);
  });

  test('every field is read from its documented offset', () {
    final stats = parseRepeaterStatusStats(_buildStatusFrame())!;

    expect(stats.batteryMv, 4103);
    expect(stats.queueLen, 7);
    expect(stats.noiseFloor, -96);
    expect(stats.lastRssi, -112);
    expect(stats.packetsRecv, 123456);
    expect(stats.packetsSent, 654321);
    expect(stats.txAirSecs, 1111);
    expect(stats.uptimeSecs, 86400);
    expect(stats.floodTx, 21);
    expect(stats.directTx, 22);
    expect(stats.floodRx, 23);
    expect(stats.directRx, 24);
    expect(stats.errEvents, 5);
    expect(stats.directDups, 31);
    expect(stats.floodDups, 32);
    expect(stats.rxAirSecs, 2222);
  });

  test('SNR is reported in quarter-dB steps', () {
    expect(
      parseRepeaterStatusStats(_buildStatusFrame(lastSnrRaw: -26))!.lastSnr,
      -6.5,
    );
    expect(
      parseRepeaterStatusStats(_buildStatusFrame(lastSnrRaw: 40))!.lastSnr,
      10.0,
    );
  });

  test(
    'signed fields survive negative values, unsigned ones stay positive',
    () {
      final stats = parseRepeaterStatusStats(
        _buildStatusFrame(
          noiseFloor: -32768,
          lastRssi: -1,
          packetsRecv: 0xFFFFFFFF,
          queueLen: 0xFFFF,
        ),
      )!;

      expect(stats.noiseFloor, -32768);
      expect(stats.lastRssi, -1);
      expect(stats.packetsRecv, 0xFFFFFFFF);
      expect(stats.queueLen, 0xFFFF);
    },
  );

  test('a frame one byte short of the stats block is rejected', () {
    final short = Uint8List.sublistView(
      _buildStatusFrame(),
      0,
      repeaterStatusResponseBytes - 1,
    );
    expect(parseRepeaterStatusStats(Uint8List.fromList(short)), isNull);
    expect(parseRepeaterStatusStats(Uint8List(0)), isNull);
  });

  test('trailing bytes past the stats block are ignored', () {
    final padded = Uint8List.fromList([..._buildStatusFrame(), 0xDE, 0xAD]);
    expect(parseRepeaterStatusStats(padded)!.batteryMv, 4103);
  });

  group('repeaterStatusPrefix', () {
    test('returns the six bytes that identify the sender', () {
      final frame = _buildStatusFrame(
        prefix: Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF]),
      );
      expect(repeaterStatusPrefix(frame), [0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF]);
    });

    test('returns null when the header itself is truncated', () {
      expect(repeaterStatusPrefix(Uint8List(7)), isNull);
    });
  });
}
