import 'dart:async';
import 'dart:typed_data';

import '../connector/meshcore_protocol.dart';
import '../helpers/wardriving_crypto.dart';
import '../helpers/wardriving_packet.dart';

class WardrivingRepeaterEcho {
  final String repeaterId;
  final bool isMultiHop;
  final List<String> pathHops;
  double? snr;
  int? rssi;
  int seenCount;

  WardrivingRepeaterEcho({
    required this.repeaterId,
    this.isMultiHop = false,
    this.pathHops = const [],
    this.snr,
    this.rssi,
    this.seenCount = 1,
  });
}

class WardrivingTxTracker {
  bool isListening = false;
  String? sentPayload;
  int? expectedChannelHash;
  Uint8List? channelKey;
  final Map<String, WardrivingRepeaterEcho> repeaters = {};
  final Map<String, WardrivingRepeaterEcho> multiHopRepeaters = {};
  Timer? _windowTimer;

  String? carpeaterPrefix;
  bool disableRssiFilter = false;
  bool Function(String repeaterId)? shouldIgnoreRepeater;
  bool Function(String repeaterId)? isRegionalCarpeater;

  void Function(String repeaterId, double? snr, int? rssi, bool isNew)?
  onEchoReceived;
  void Function(
    String repeaterId,
    double? snr,
    int? rssi,
    List<String> pathHops,
    bool isNew,
  )?
  onMultiHopEchoReceived;

  void startTracking({
    required String payload,
    required int channelHash,
    required Uint8List channelKey,
    Duration windowDuration = const Duration(seconds: 5),
  }) {
    isListening = true;
    sentPayload = payload;
    expectedChannelHash = channelHash;
    this.channelKey = channelKey;
    repeaters.clear();
    multiHopRepeaters.clear();

    _windowTimer?.cancel();
    _windowTimer = Timer(windowDuration, stopTracking);
  }

  void stopTracking() {
    isListening = false;
    _windowTimer?.cancel();
    _windowTimer = null;
  }

  bool handlePacket(WardrivingRawPacket packet) {
    if (!isListening || !packet.isGroupText) return false;
    if (packet.pathHashCount == 0) return false;

    final firstHop = packet.firstHopHex;
    if (firstHop == null) return false;
    var pathHex = firstHop;
    double? reportedSnr = packet.snr;
    int? reportedRssi = packet.rssi;
    var carpeaterStripped = false;

    if (carpeaterPrefix != null &&
        matchesRepeaterPrefix(pathHex, carpeaterPrefix!)) {
      if (packet.pathHashCount < 2) return false;
      final underlyingHop = packet.hopHexAt(1);
      if (underlyingHop == null) return false;
      pathHex = underlyingHop;
      carpeaterStripped = true;
      reportedSnr = null;
      reportedRssi = null;
    }

    final isMultiHop = !carpeaterStripped && packet.pathHashCount > 1;
    final pathHops = <String>[];
    for (var index = 0; index < packet.pathHashCount; index++) {
      final hop = packet.hopHexAt(index);
      if (hop == null) return false;
      pathHops.add(hop);
    }
    if (isMultiHop) pathHex = pathHops.last;

    if (isRegionalCarpeater != null &&
        (isRegionalCarpeater!(firstHop) || isRegionalCarpeater!(pathHex))) {
      return false;
    }

    if (!carpeaterStripped &&
        shouldIgnoreRepeater != null &&
        shouldIgnoreRepeater!(pathHex.toUpperCase())) {
      return false;
    }

    if (!carpeaterStripped &&
        !disableRssiFilter &&
        isCarpeaterRssi(packet.rssi)) {
      return false;
    }

    final packetChannelHash = packet.channelHash;
    if (packetChannelHash == null || packetChannelHash != expectedChannelHash) {
      return false;
    }

    final key = channelKey;
    final expected = sentPayload;
    if (key != null && expected != null) {
      final decrypted = decryptGroupTextMessage(key, packet.payload);
      if (decrypted == null) return false;
      if (decrypted != expected && !decrypted.contains(expected)) {
        return false;
      }
    }

    final target = isMultiHop ? multiHopRepeaters : repeaters;
    final isNew = !target.containsKey(pathHex);
    if (isNew) {
      target[pathHex] = WardrivingRepeaterEcho(
        repeaterId: pathHex,
        isMultiHop: isMultiHop,
        pathHops: isMultiHop ? List.unmodifiable(pathHops) : const [],
        snr: reportedSnr,
        rssi: reportedRssi,
      );
    } else {
      final existing = target[pathHex]!;
      existing.seenCount++;
      if (reportedSnr != null &&
          (existing.snr == null || reportedSnr > existing.snr!)) {
        existing.snr = reportedSnr;
        existing.rssi = reportedRssi;
      }
    }

    final echo = target[pathHex]!;
    if (isMultiHop) {
      onMultiHopEchoReceived?.call(
        pathHex,
        echo.snr,
        echo.rssi,
        echo.pathHops,
        isNew,
      );
    } else {
      onEchoReceived?.call(pathHex, echo.snr, echo.rssi, isNew);
    }
    return true;
  }

  void dispose() {
    stopTracking();
  }

  /// A configured CARpeater may be a full public key while a radio packet
  /// carries only a one- to three-byte path hash. Compare their shared prefix
  /// instead of requiring the shorter on-air ID to contain the full key.
  static bool matchesRepeaterPrefix(String observedId, String configuredId) {
    final observed = observedId.toUpperCase();
    final configured = configuredId.toUpperCase();
    final length = observed.length < configured.length
        ? observed.length
        : configured.length;
    return length > 0 &&
        observed.substring(0, length) == configured.substring(0, length);
  }
}

class WardrivingDiscTracker {
  bool isListening = false;
  final Map<String, DiscoverResponse> discoveries = {};
  Timer? _windowTimer;
  int hopBytes = 1;
  Uint8List? expectedTag;

  void Function(DiscoverResponse response)? onDiscovery;

  void startTracking({
    Uint8List? tag,
    Duration windowDuration = const Duration(seconds: 7),
  }) {
    isListening = true;
    discoveries.clear();
    expectedTag = tag == null ? null : Uint8List.fromList(tag);
    _windowTimer?.cancel();
    _windowTimer = Timer(windowDuration, stopTracking);
  }

  void stopTracking() {
    isListening = false;
    _windowTimer?.cancel();
    _windowTimer = null;
  }

  bool handleControlData(Uint8List frame) {
    if (!isListening) return false;
    final response = parseDiscoverResponseFrame(frame, hopBytes: hopBytes);
    if (response == null) return false;
    final tag = expectedTag;
    if (tag != null &&
        (tag.length != response.tag.length ||
            !List<int>.generate(
              tag.length,
              (i) => i,
            ).every((i) => tag[i] == response.tag[i]))) {
      return false;
    }

    final repeaterId = response.repeaterId(hopBytes);
    final existing = discoveries[repeaterId];
    if (existing == null || response.localSnr > existing.localSnr) {
      discoveries[repeaterId] = response;
      onDiscovery?.call(response);
    }
    return true;
  }

  void dispose() {
    stopTracking();
  }
}

/// Tracks a single targeted zero-hop trace response.
class WardrivingTraceTracker {
  bool isListening = false;
  Uint8List? expectedTag;
  TraceResponse? response;
  double? pendingBleSnr;
  int? pendingBleRssi;
  Timer? _windowTimer;
  void Function(TraceResponse response)? onTrace;

  void startTracking({
    required Uint8List tag,
    Duration windowDuration = const Duration(seconds: 7),
  }) {
    stopTracking();
    expectedTag = Uint8List.fromList(tag);
    response = null;
    pendingBleSnr = null;
    pendingBleRssi = null;
    isListening = true;
    _windowTimer = Timer(windowDuration, stopTracking);
  }

  bool captureBleMetadata(WardrivingRawPacket packet) {
    if (!isListening || !packet.isTrace) return false;
    pendingBleSnr = packet.snr;
    pendingBleRssi = packet.rssi;
    return true;
  }

  bool handleTraceData(Uint8List frame) {
    if (!isListening) return false;
    final parsed = parseTraceResponseFrame(frame, expectedTag: expectedTag);
    if (parsed == null) return false;
    response = parsed;
    onTrace?.call(parsed);
    return true;
  }

  void stopTracking() {
    isListening = false;
    _windowTimer?.cancel();
    _windowTimer = null;
  }

  void dispose() => stopTracking();
}

class WardrivingRxLogger {
  final Map<String, double> _pending = {};
  Timer? _batchTimer;
  Duration batchInterval = const Duration(seconds: 15);
  void Function(Map<String, double> repeaters)? onBatchReady;
  bool disableRssiFilter = false;
  String? carpeaterPrefix;
  bool Function(String repeaterId)? shouldIgnoreRepeater;
  bool Function(String repeaterId)? isRegionalCarpeater;
  bool Function(WardrivingRawPacket packet)? shouldAcceptPacket;

  WardrivingRxLogger() {
    _batchTimer = Timer.periodic(batchInterval, (_) => flush());
  }

  void record(WardrivingRawPacket packet, {int hopBytes = 1}) {
    if (packet.pathHashCount == 0) return;
    if (!packet.isGroupText && packet.payloadType != payloadTypeADVERT) {
      return;
    }
    // The final hop delivered this packet to us. `hopBytes` describes the
    // width of each ID, not which hop to credit; the packet itself already
    // decodes that width from pathLenByte.
    var repeaterId = packet.lastHopHex;
    if (repeaterId == null) return;

    var skipRssiFilter = false;
    final carpeater = carpeaterPrefix;
    if (carpeater != null &&
        WardrivingTxTracker.matchesRepeaterPrefix(repeaterId, carpeater)) {
      if (packet.pathHashCount < 2) return;
      repeaterId = packet.hopHexAt(packet.pathHashCount - 2);
      if (repeaterId == null) return;
      skipRssiFilter = true;
    }

    if (isRegionalCarpeater?.call(repeaterId) ?? false) return;
    if (!skipRssiFilter && (shouldIgnoreRepeater?.call(repeaterId) ?? false)) {
      return;
    }
    if (!skipRssiFilter && !disableRssiFilter && isCarpeaterRssi(packet.rssi)) {
      return;
    }
    if (!(shouldAcceptPacket?.call(packet) ?? true)) return;

    final existing = _pending[repeaterId];
    if (existing == null || packet.snr > existing) {
      _pending[repeaterId] = packet.snr;
    }
  }

  void flush() {
    if (_pending.isEmpty) return;
    final batch = Map<String, double>.from(_pending);
    _pending.clear();
    onBatchReady?.call(batch);
  }

  void dispose() {
    _batchTimer?.cancel();
    _batchTimer = null;
    flush();
  }
}
