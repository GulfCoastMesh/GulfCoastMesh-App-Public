/// One point-in-time reading from a node.
///
/// Every field is nullable because the sources are independent: a battery reply
/// carries no noise floor, a radio-stats reply carries no battery, and a remote
/// LPP payload may carry only what its sensors report. A sample records what was
/// known at [timestamp], not a complete picture.
class TelemetrySample {
  /// Always UTC. Normalized on construction so a sample built from
  /// `DateTime.now()` compares equal to the same sample read back from storage
  /// — `DateTime.fromMillisecondsSinceEpoch` yields local time otherwise, and
  /// two DateTimes for the same instant are unequal if their `isUtc` differs.
  /// Convert with `.toLocal()` for display.
  final DateTime timestamp;
  final int? batteryMillivolts;
  final int? noiseFloor;
  final int? lastRssi;
  final int? lastSnr;
  final int? txAirSeconds;
  final int? rxAirSeconds;
  final int? uptimeSeconds;

  /// Decoded Cayenne LPP readings keyed as `ch<n>.<name>` (e.g. `ch1.voltage`),
  /// so sensors from different channels never collide.
  final Map<String, double> sensors;

  TelemetrySample({
    required DateTime timestamp,
    this.batteryMillivolts,
    this.noiseFloor,
    this.lastRssi,
    this.lastSnr,
    this.txAirSeconds,
    this.rxAirSeconds,
    this.uptimeSeconds,
    this.sensors = const {},
  }) : timestamp = timestamp.toUtc();

  /// True when there is nothing worth storing — avoids filling the ring buffer
  /// with empty samples when a poll returns nothing.
  bool get isEmpty =>
      batteryMillivolts == null &&
      noiseFloor == null &&
      lastRssi == null &&
      lastSnr == null &&
      txAirSeconds == null &&
      rxAirSeconds == null &&
      uptimeSeconds == null &&
      sensors.isEmpty;

  /// Numeric series value for [metric], or null when this sample lacks it.
  double? value(TelemetryMetric metric) {
    switch (metric) {
      case TelemetryMetric.batteryMillivolts:
        return batteryMillivolts?.toDouble();
      case TelemetryMetric.noiseFloor:
        return noiseFloor?.toDouble();
      case TelemetryMetric.rssi:
        return lastRssi?.toDouble();
      case TelemetryMetric.snr:
        return lastSnr?.toDouble();
      case TelemetryMetric.txAirSeconds:
        return txAirSeconds?.toDouble();
      case TelemetryMetric.rxAirSeconds:
        return rxAirSeconds?.toDouble();
      case TelemetryMetric.uptimeSeconds:
        return uptimeSeconds?.toDouble();
    }
  }

  Map<String, dynamic> toJson() => {
    't': timestamp.millisecondsSinceEpoch,
    if (batteryMillivolts != null) 'batt': batteryMillivolts,
    if (noiseFloor != null) 'nf': noiseFloor,
    if (lastRssi != null) 'rssi': lastRssi,
    if (lastSnr != null) 'snr': lastSnr,
    if (txAirSeconds != null) 'tx': txAirSeconds,
    if (rxAirSeconds != null) 'rx': rxAirSeconds,
    if (uptimeSeconds != null) 'up': uptimeSeconds,
    if (sensors.isNotEmpty) 's': sensors,
  };

  /// Returns null for a record that cannot be trusted, so one corrupt sample is
  /// skipped instead of discarding a node's whole history.
  static TelemetrySample? fromJson(Map<String, dynamic> json) {
    final millis = json['t'];
    if (millis is! int) return null;

    int? readInt(String key) {
      final value = json[key];
      return value is int ? value : null;
    }

    final rawSensors = json['s'];
    final sensors = <String, double>{};
    if (rawSensors is Map) {
      for (final entry in rawSensors.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is String && value is num) {
          sensors[key] = value.toDouble();
        }
      }
    }

    return TelemetrySample(
      timestamp: DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
      batteryMillivolts: readInt('batt'),
      noiseFloor: readInt('nf'),
      lastRssi: readInt('rssi'),
      lastSnr: readInt('snr'),
      txAirSeconds: readInt('tx'),
      rxAirSeconds: readInt('rx'),
      uptimeSeconds: readInt('up'),
      sensors: sensors,
    );
  }
}

/// The built-in numeric series a node can be charted on.
enum TelemetryMetric {
  batteryMillivolts,
  noiseFloor,
  rssi,
  snr,
  txAirSeconds,
  rxAirSeconds,
  uptimeSeconds,
}
