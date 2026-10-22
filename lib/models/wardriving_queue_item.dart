class WardrivingQueueItem {
  final String type;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String heardRepeats;
  final bool externalAntenna;
  final int? noiseFloor;
  final double? powerWatts;
  int retryCount;
  DateTime? lastRetryAt;
  final String? wireTag;
  final int? pingCounter;
  String? wireTagSessionId;
  final String? stableId;
  final DateTime? canUploadAfter;
  final String? contactPrefix;
  final String? iata;

  WardrivingQueueItem({
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.heardRepeats,
    required this.externalAntenna,
    this.noiseFloor,
    this.powerWatts,
    this.retryCount = 0,
    this.lastRetryAt,
    this.wireTag,
    this.pingCounter,
    this.wireTagSessionId,
    this.stableId,
    this.canUploadAfter,
    this.contactPrefix,
    this.iata,
  });

  factory WardrivingQueueItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    final latitude = json['latitude'];
    final longitude = json['longitude'];
    final timestamp = json['timestamp'];
    final heardRepeats = json['heard_repeats'];
    if (type is! String ||
        latitude is! num ||
        longitude is! num ||
        timestamp is! String ||
        heardRepeats is! String) {
      throw const FormatException('Invalid wardriving queue item');
    }
    final lat = latitude.toDouble();
    final lon = longitude.toDouble();
    if (!lat.isFinite ||
        !lon.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lon < -180 ||
        lon > 180) {
      throw const FormatException('Invalid wardriving coordinates');
    }
    return WardrivingQueueItem(
      type: type,
      latitude: lat,
      longitude: lon,
      timestamp: DateTime.parse(timestamp),
      heardRepeats: heardRepeats,
      externalAntenna: json['external_antenna'] as bool? ?? false,
      noiseFloor: (json['noise_floor'] as num?)?.toInt(),
      powerWatts: (json['power_watts'] as num?)?.toDouble(),
      retryCount: (json['retry_count'] as num?)?.toInt() ?? 0,
      lastRetryAt: json['last_retry_at'] != null
          ? DateTime.parse(json['last_retry_at'] as String)
          : null,
      wireTag: json['wire_tag'] as String?,
      pingCounter: (json['ping_counter'] as num?)?.toInt(),
      wireTagSessionId: json['wire_tag_session_id'] as String?,
      stableId: json['id'] as String?,
      canUploadAfter: json['can_upload_after'] != null
          ? DateTime.tryParse(json['can_upload_after'] as String)
          : null,
      contactPrefix: json['contact_prefix'] as String?,
      iata: json['iata'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
    'heard_repeats': heardRepeats,
    'external_antenna': externalAntenna,
    'noise_floor': noiseFloor,
    'power_watts': powerWatts,
    'retry_count': retryCount,
    'last_retry_at': lastRetryAt?.toIso8601String(),
    'wire_tag': wireTag,
    'ping_counter': pingCounter,
    'wire_tag_session_id': wireTagSessionId,
    'id': stableId,
    'can_upload_after': canUploadAfter?.toIso8601String(),
    'contact_prefix': contactPrefix,
    'iata': iata,
  };

  Map<String, dynamic> toApiJson({String? contactPrefix, String? iata}) {
    final effectiveContact = contactPrefix ?? this.contactPrefix;
    final effectiveIata = iata ?? this.iata;
    if (type == 'TRACE') {
      final parts = heardRepeats.split(':');
      return {
        'type': type,
        'lat': latitude,
        'lon': longitude,
        'noisefloor': noiseFloor,
        'repeater_id': parts.isNotEmpty ? parts[0] : '',
        'local_snr': parts.length > 1 ? double.tryParse(parts[1]) : null,
        'local_rssi': parts.length > 2 ? int.tryParse(parts[2]) : null,
        'remote_snr': parts.length > 3 ? double.tryParse(parts[3]) : null,
        'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
        'external_antenna': externalAntenna,
        'power': _powerString(),
        'contact': ?effectiveContact,
        'iata': ?effectiveIata,
      };
    }
    if (type == 'DISC') {
      if (heardRepeats == 'None') {
        return {
          'type': type,
          'lat': latitude,
          'lon': longitude,
          'noisefloor': noiseFloor,
          'repeater_id': 'None',
          'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
          'external_antenna': externalAntenna,
          'power': _powerString(),
          'contact': ?effectiveContact,
          'iata': ?effectiveIata,
          if (wireTag != null) 'wire_tag': wireTag,
          if (pingCounter != null) 'ping_counter': pingCounter,
        };
      }
      final parts = heardRepeats.split(':');
      return {
        'type': type,
        'lat': latitude,
        'lon': longitude,
        'noisefloor': noiseFloor,
        'repeater_id': parts.isNotEmpty ? parts[0] : '',
        'node_type': parts.length > 1 ? parts[1] : '',
        'local_snr': parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0,
        'local_rssi': parts.length > 3 ? int.tryParse(parts[3]) ?? 0 : 0,
        'remote_snr': parts.length > 4 ? double.tryParse(parts[4]) ?? 0.0 : 0.0,
        'public_key': parts.length > 5 ? parts[5] : '',
        'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
        'external_antenna': externalAntenna,
        'power': _powerString(),
        'contact': ?effectiveContact,
        'iata': ?effectiveIata,
        if (wireTag != null) 'wire_tag': wireTag,
        if (pingCounter != null) 'ping_counter': pingCounter,
      };
    }

    return {
      'type': type,
      'lat': latitude,
      'lon': longitude,
      'noisefloor': noiseFloor,
      'heard_repeats': heardRepeats,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
      'external_antenna': externalAntenna,
      'power': _powerString(),
      'contact': ?effectiveContact,
      'iata': ?effectiveIata,
      if (wireTag != null) 'wire_tag': wireTag,
      if (pingCounter != null) 'ping_counter': pingCounter,
    };
  }

  String? _powerString() =>
      powerWatts != null ? '${powerWatts!.toStringAsFixed(1)}w' : null;

  /// A tagged TX can only be uploaded under the session that minted it.
  bool get hasWireTag => wireTag != null || pingCounter != null;

  /// Records the session that derived this item's tag. The first binding wins:
  /// a retry or a restored queue item must never be rebound to a new session.
  void bindWireTagSession(String? sessionId) {
    if (hasWireTag && wireTagSessionId == null && sessionId != null) {
      wireTagSessionId = sessionId;
    }
  }

  Duration get nextRetryDelay {
    final seconds = switch (retryCount) {
      <= 0 => 5,
      1 => 15,
      2 => 30,
      3 => 60,
      4 => 120,
      _ => 300,
    };
    return Duration(seconds: seconds);
  }

  bool get isReadyForRetry {
    if (canUploadAfter != null && DateTime.now().isBefore(canUploadAfter!)) {
      return false;
    }
    if (lastRetryAt == null) return true;
    return DateTime.now().difference(lastRetryAt!) >= nextRetryDelay;
  }

  void markRetried() {
    if (retryCount < 5) retryCount++;
    lastRetryAt = DateTime.now();
  }

  static WardrivingQueueItem tx({
    required double latitude,
    required double longitude,
    required String heardRepeats,
    required DateTime timestamp,
    required bool externalAntenna,
    int? noiseFloor,
    double? powerWatts,
    String? wireTag,
    int? pingCounter,
    String? wireTagSessionId,
    String? contactPrefix,
    String? iata,
  }) {
    return WardrivingQueueItem(
      type: 'TX',
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      heardRepeats: heardRepeats,
      externalAntenna: externalAntenna,
      noiseFloor: noiseFloor,
      powerWatts: powerWatts,
      wireTag: wireTag,
      pingCounter: pingCounter,
      wireTagSessionId: wireTagSessionId,
      contactPrefix: contactPrefix,
      iata: iata,
    );
  }

  static WardrivingQueueItem rx({
    required double latitude,
    required double longitude,
    required String heardRepeats,
    required DateTime timestamp,
    required bool externalAntenna,
    int? noiseFloor,
    double? powerWatts,
    String? contactPrefix,
    String? iata,
  }) {
    return WardrivingQueueItem(
      type: 'RX',
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      heardRepeats: heardRepeats,
      externalAntenna: externalAntenna,
      noiseFloor: noiseFloor,
      powerWatts: powerWatts,
      contactPrefix: contactPrefix,
      iata: iata,
    );
  }

  static WardrivingQueueItem disc({
    required double latitude,
    required double longitude,
    required String heardRepeats,
    required DateTime timestamp,
    required bool externalAntenna,
    int? noiseFloor,
    double? powerWatts,
    String? contactPrefix,
    String? iata,
  }) {
    return WardrivingQueueItem(
      type: 'DISC',
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      heardRepeats: heardRepeats,
      externalAntenna: externalAntenna,
      noiseFloor: noiseFloor,
      powerWatts: powerWatts,
      contactPrefix: contactPrefix,
      iata: iata,
    );
  }

  static WardrivingQueueItem trace({
    required double latitude,
    required double longitude,
    required String heardRepeats,
    required DateTime timestamp,
    required bool externalAntenna,
    int? noiseFloor,
    double? powerWatts,
    String? contactPrefix,
    String? iata,
  }) => WardrivingQueueItem(
    type: 'TRACE',
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp,
    heardRepeats: heardRepeats,
    externalAntenna: externalAntenna,
    noiseFloor: noiseFloor,
    powerWatts: powerWatts,
    contactPrefix: contactPrefix,
    iata: iata,
  );
}
