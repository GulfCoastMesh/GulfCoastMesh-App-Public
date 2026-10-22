const int kWardrivingMinIntervalSec = 15;
const double kWardrivingMinDistanceMeters = 25;

enum WardrivingMode { off, passive, active, hybrid, targeted }

/// Read-only explanation of whether a wardriving mode can be selected.
class WardrivingModeAvailability {
  final WardrivingMode mode;
  final bool enabled;
  final String reason;

  const WardrivingModeAvailability({
    required this.mode,
    required this.enabled,
    this.reason = '',
  });
}

enum WardrivingSessionState {
  idle,
  acquiring,
  ready,
  running,
  stopping,
  pausedBackground,
  error,
}

enum WardrivingEventType { tx, rx, discovery, trace }

class WardrivingMapEvent {
  final String id;
  final WardrivingEventType type;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final bool successful;
  final String? repeaterId;
  final double? snr;

  const WardrivingMapEvent({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.successful,
    this.repeaterId,
    this.snr,
  });
}

class WardrivingStats {
  final int txCount;
  final int rxCount;
  final int discCount;
  final int traceCount;
  final int uploadedCount;
  final int queueCount;

  const WardrivingStats({
    this.txCount = 0,
    this.rxCount = 0,
    this.discCount = 0,
    this.traceCount = 0,
    this.uploadedCount = 0,
    this.queueCount = 0,
  });

  WardrivingStats copyWith({
    int? txCount,
    int? rxCount,
    int? discCount,
    int? traceCount,
    int? uploadedCount,
    int? queueCount,
  }) {
    return WardrivingStats(
      txCount: txCount ?? this.txCount,
      rxCount: rxCount ?? this.rxCount,
      discCount: discCount ?? this.discCount,
      traceCount: traceCount ?? this.traceCount,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      queueCount: queueCount ?? this.queueCount,
    );
  }
}
