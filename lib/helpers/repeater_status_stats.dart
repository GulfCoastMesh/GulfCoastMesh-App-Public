import 'dart:typed_data';

/// Binary repeater status payload carried by `PUSH_CODE_STATUS_RESPONSE`.
///
/// Wire layout after the 8-byte header (`[code][reserved][prefix x6]`), all
/// little-endian, 52 bytes total:
///
/// | offset | size | field |
/// |---|---|---|
/// | 0  | u16 | battery_mv |
/// | 2  | u16 | queue_len |
/// | 4  | i16 | noise_floor |
/// | 6  | i16 | last_rssi |
/// | 8  | u32 | packets_recv |
/// | 12 | u32 | packets_sent |
/// | 16 | u32 | tx_air_secs |
/// | 20 | u32 | uptime_secs |
/// | 24 | u32 | flood_tx |
/// | 28 | u32 | direct_tx |
/// | 32 | u32 | flood_rx |
/// | 36 | u32 | direct_rx |
/// | 40 | u16 | err_events |
/// | 42 | i16 | last_snr (quarter-dB) |
/// | 44 | u16 | direct_dups |
/// | 46 | u16 | flood_dups |
/// | 48 | u32 | rx_air_secs |
class RepeaterStatusStats {
  final int batteryMv;
  final int queueLen;
  final int noiseFloor;
  final int lastRssi;
  final int packetsRecv;
  final int packetsSent;
  final int txAirSecs;
  final int uptimeSecs;
  final int floodTx;
  final int directTx;
  final int floodRx;
  final int directRx;
  final int errEvents;

  /// Raw quarter-dB SNR as sent by firmware. See [lastSnr] for dB.
  final int lastSnrRaw;
  final int directDups;
  final int floodDups;
  final int rxAirSecs;

  const RepeaterStatusStats({
    required this.batteryMv,
    required this.queueLen,
    required this.noiseFloor,
    required this.lastRssi,
    required this.packetsRecv,
    required this.packetsSent,
    required this.txAirSecs,
    required this.uptimeSecs,
    required this.floodTx,
    required this.directTx,
    required this.floodRx,
    required this.directRx,
    required this.errEvents,
    required this.lastSnrRaw,
    required this.directDups,
    required this.floodDups,
    required this.rxAirSecs,
  });

  /// Firmware reports SNR in quarter-dB steps.
  double get lastSnr => lastSnrRaw / 4.0;
}

/// Bytes of `PUSH_CODE_STATUS_RESPONSE` before the stats block: the frame code,
/// one reserved byte, then the six-byte sender prefix.
const int repeaterStatusPayloadOffset = 8;

/// Size of the stats block itself.
const int repeaterStatusStatsSize = 52;

/// Total frame length a parseable binary status response must reach.
const int repeaterStatusResponseBytes =
    repeaterStatusPayloadOffset + repeaterStatusStatsSize;

/// The six-byte sender prefix a status frame carries, or null when truncated.
Uint8List? repeaterStatusPrefix(Uint8List frame) {
  if (frame.length < repeaterStatusPayloadOffset) return null;
  return Uint8List.sublistView(frame, 2, repeaterStatusPayloadOffset);
}

/// Decode the 52-byte stats block, or null when [frame] is too short.
///
/// The caller is responsible for checking the frame code and matching the
/// sender prefix against the repeater it asked.
RepeaterStatusStats? parseRepeaterStatusStats(Uint8List frame) {
  if (frame.length < repeaterStatusResponseBytes) return null;
  final data = ByteData.sublistView(
    frame,
    repeaterStatusPayloadOffset,
    repeaterStatusResponseBytes,
  );
  return RepeaterStatusStats(
    batteryMv: data.getUint16(0, Endian.little),
    queueLen: data.getUint16(2, Endian.little),
    noiseFloor: data.getInt16(4, Endian.little),
    lastRssi: data.getInt16(6, Endian.little),
    packetsRecv: data.getUint32(8, Endian.little),
    packetsSent: data.getUint32(12, Endian.little),
    txAirSecs: data.getUint32(16, Endian.little),
    uptimeSecs: data.getUint32(20, Endian.little),
    floodTx: data.getUint32(24, Endian.little),
    directTx: data.getUint32(28, Endian.little),
    floodRx: data.getUint32(32, Endian.little),
    directRx: data.getUint32(36, Endian.little),
    errEvents: data.getUint16(40, Endian.little),
    lastSnrRaw: data.getInt16(42, Endian.little),
    directDups: data.getUint16(44, Endian.little),
    floodDups: data.getUint16(46, Endian.little),
    rxAirSecs: data.getUint32(48, Endian.little),
  );
}
