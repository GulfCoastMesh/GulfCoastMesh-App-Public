class PathRecord {
  final int hopCount;
  final int tripTimeMs;
  final DateTime timestamp;
  final bool wasFloodDiscovery;
  final List<int> pathBytes;
  final int successCount;
  final int failureCount;

  PathRecord({
    required this.hopCount,
    required this.tripTimeMs,
    required this.timestamp,
    required this.wasFloodDiscovery,
    required this.pathBytes,
    required this.successCount,
    required this.failureCount,
  });

  String get displayText =>
      '$hopCount ${hopCount == 1 ? 'hop' : 'hops'} - ${(tripTimeMs / 1000).toStringAsFixed(2)}s';

  Map<String, dynamic> toJson() {
    return {
      'hop_count': hopCount,
      'trip_time_ms': tripTimeMs,
      'timestamp': timestamp.toIso8601String(),
      'was_flood': wasFloodDiscovery,
      'path_bytes': pathBytes,
      'success_count': successCount,
      'failure_count': failureCount,
    };
  }

  factory PathRecord.fromJson(Map<String, dynamic> json) {
    final rawHopCount = json['hop_count'];
    final rawTripTime = json['trip_time_ms'];
    final rawTimestamp = json['timestamp'];
    final rawWasFlood = json['was_flood'];
    final rawPathBytes = json['path_bytes'];
    if (rawHopCount is! num ||
        rawTripTime is! num ||
        rawTimestamp is! String ||
        rawWasFlood is! bool ||
        rawPathBytes is! List) {
      throw const FormatException('Invalid path history record');
    }
    final hopCount = rawHopCount.toInt();
    final tripTimeMs = rawTripTime.toInt();
    if (hopCount < 0 || tripTimeMs < 0) {
      throw const FormatException('Negative path history value');
    }
    final pathBytes = <int>[];
    for (final value in rawPathBytes) {
      if (value is! num) {
        throw const FormatException('Invalid path byte');
      }
      final byte = value.toInt();
      if (byte < 0 || byte > 0xff) {
        throw const FormatException('Path byte out of range');
      }
      pathBytes.add(byte);
    }
    final successCount = json['success_count'] is num
        ? (json['success_count'] as num).toInt()
        : 0;
    final failureCount = json['failure_count'] is num
        ? (json['failure_count'] as num).toInt()
        : 0;
    return PathRecord(
      hopCount: hopCount,
      tripTimeMs: tripTimeMs,
      timestamp: DateTime.parse(rawTimestamp),
      wasFloodDiscovery: rawWasFlood,
      pathBytes: pathBytes,
      successCount: successCount < 0 ? 0 : successCount,
      failureCount: failureCount < 0 ? 0 : failureCount,
    );
  }
}

class ContactPathHistory {
  final String contactPubKeyHex;
  final List<PathRecord> recentPaths;

  ContactPathHistory({
    required this.contactPubKeyHex,
    required this.recentPaths,
  });

  PathRecord? get fastest {
    if (recentPaths.isEmpty) return null;
    return recentPaths.reduce((a, b) => a.tripTimeMs < b.tripTimeMs ? a : b);
  }

  PathRecord? get mostRecent {
    if (recentPaths.isEmpty) return null;
    return recentPaths.first;
  }

  Map<String, dynamic> toJson() {
    return {'recent_paths': recentPaths.map((p) => p.toJson()).toList()};
  }

  factory ContactPathHistory.fromJson(
    String contactPubKeyHex,
    Map<String, dynamic> json,
  ) {
    final pathsList = <PathRecord>[];
    final rawPaths = json['recent_paths'];
    if (rawPaths is List) {
      for (final value in rawPaths) {
        if (value is! Map<String, dynamic>) continue;
        try {
          pathsList.add(PathRecord.fromJson(value));
        } catch (_) {
          // Preserve valid history entries when one stored record is corrupt.
        }
      }
    }

    return ContactPathHistory(
      contactPubKeyHex: contactPubKeyHex,
      recentPaths: pathsList,
    );
  }
}
