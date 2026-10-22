import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/wardriving.dart';

enum MeshMapperUploadResult {
  success,
  retryable,
  nonRetryable,

  /// No usable response arrived, so the server never rejected the samples.
  unreachable,

  /// The server explicitly asked this session to wait (for example, 429).
  held,
}

/// Result of a heartbeat call. Distinguishes a transient transport error
/// (so callers can keep their current session and retry later) from a
/// definitive server response (success or explicit failure).
class MeshMapperHeartbeatResult {
  final Map<String, dynamic>? data;
  final bool isTransientFailure;
  final String? transientError;

  const MeshMapperHeartbeatResult.response(Map<String, dynamic> this.data)
    : isTransientFailure = false,
      transientError = null;

  const MeshMapperHeartbeatResult.transient(String this.transientError)
    : data = null,
      isTransientFailure = true;

  const MeshMapperHeartbeatResult.noSession()
    : data = null,
      isTransientFailure = false,
      transientError = null;
}

class MeshMapperApiResponse {
  const MeshMapperApiResponse({this.data, this.httpStatus, this.error});

  final Map<String, dynamic>? data;
  final int? httpStatus;
  final String? error;

  bool get isSuccess => data?['success'] == true;
  String? get reason => data?['reason'] as String?;
  String? get message => data?['message'] as String?;
}

class MeshMapperRepeater {
  final String id;
  final String hexId;
  final String name;
  final double? latitude;
  final double? longitude;

  const MeshMapperRepeater({
    required this.id,
    required this.hexId,
    required this.name,
    this.latitude,
    this.longitude,
  });

  factory MeshMapperRepeater.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['repeater_id'] ?? '')
        .toString()
        .toUpperCase();
    final hexId = (json['hex_id'] ?? json['hex'] ?? id)
        .toString()
        .replaceAll(':', '')
        .toUpperCase();
    final longitudeValue = json['lon'] ?? json['lng'];
    return MeshMapperRepeater(
      id: id,
      hexId: hexId,
      name: (json['name'] ?? json['label'] ?? id).toString(),
      latitude: (json['lat'] as num?)?.toDouble(),
      longitude: longitudeValue is num ? longitudeValue.toDouble() : null,
    );
  }

  String get targetId => hexId.isNotEmpty ? hexId : id;
}

String? meshMapperZoneCode(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim().toUpperCase();
  }
  if (value is Map) {
    final code = value['code'] ?? value['iata'];
    if (code is String && code.trim().isNotEmpty) {
      return code.trim().toUpperCase();
    }
  }
  return null;
}

String? _meshMapperBodyError(MeshMapperApiResponse response) {
  final message = response.message;
  if (message != null && message.isNotEmpty) return message;
  final reason = response.reason;
  if (reason != null && reason.isNotEmpty) {
    return switch (reason) {
      'invalid_key' || 'bad_key' => 'Invalid MeshMapper API key for this build',
      'unauthorized' => 'MeshMapper API unauthorized',
      'unknown_device' =>
        'Unknown device public key. Advertise on the mesh first.',
      'zone_full' => 'Wardriving zone is full. Try Passive mode.',
      'zone_disabled' => 'Wardriving is disabled in this zone',
      'session_expired' => 'MeshMapper session expired',
      'session_invalid' ||
      'session_revoked' ||
      'bad_session' => 'MeshMapper session invalid',
      _ => reason,
    };
  }
  return null;
}

String formatMeshMapperAuthError(MeshMapperApiResponse response) {
  if (response.error != null) {
    return switch (response.error!) {
      'missing_api_key' => 'MeshMapper API not configured for this build',
      'missing_coords' => 'GPS coordinates unavailable',
      'missing_identity' => 'Device identity unavailable',
      'missing_zone' => 'MeshMapper zone unavailable',
      'network_error' => 'Network error contacting MeshMapper',
      _ => response.error!,
    };
  }
  final bodyError = _meshMapperBodyError(response);
  if (bodyError != null) return bodyError;
  if (response.httpStatus != null && response.httpStatus != 200) {
    return 'MeshMapper API HTTP ${response.httpStatus}';
  }
  return 'Could not acquire MeshMapper session';
}

String formatMeshMapperZoneStatusError(MeshMapperApiResponse response) {
  if (response.error != null) {
    return switch (response.error!) {
      'missing_api_key' => 'MeshMapper API not configured for this build',
      'network_error' => 'Network error contacting MeshMapper',
      _ => response.error!,
    };
  }
  if (response.isSuccess && response.data?['in_zone'] == false) {
    final nearest = response.data?['nearest_zone'] as Map<String, dynamic>?;
    if (nearest != null) {
      final name = nearest['name'] as String? ?? 'unknown';
      final distance = nearest['distance_km'];
      if (distance is num) {
        return 'Outside coverage zone (nearest: $name, ${distance.round()} km)';
      }
      return 'Outside coverage zone (nearest: $name)';
    }
    return 'Outside MeshMapper coverage zone';
  }
  final bodyError = _meshMapperBodyError(response);
  if (bodyError != null) return bodyError;
  if (response.httpStatus != null && response.httpStatus != 200) {
    return 'MeshMapper API HTTP ${response.httpStatus}';
  }
  return formatMeshMapperAuthError(response);
}

bool shouldAttemptMeshMapperRegistration(MeshMapperApiResponse stage1) {
  if (stage1.isSuccess) return false;
  if (stage1.error != null) return false;
  final reason = stage1.reason;
  if (reason == 'gps_inaccurate' || reason == 'gps_stale') return false;
  return true;
}

Map<String, dynamic>? buildMeshMapperAuthRequestBody({
  required String apiKey,
  required String reason,
  String? publicKey,
  String? contactUri,
  String? who,
  String? appVersion,
  double? power,
  String? model,
  double? lat,
  double? lon,
  double? accuracyMeters,
  String? sessionId,
  String? iataCode,
  bool offlineMode = false,
}) {
  if (apiKey.isEmpty) return null;

  final payload = <String, dynamic>{'key': apiKey, 'reason': reason};
  if (offlineMode) payload['offline_mode'] = true;
  if (contactUri != null) {
    payload['contact_uri'] = contactUri;
  } else if (publicKey != null) {
    payload['public_key'] = publicKey;
  } else if (reason != 'disconnect') {
    return null;
  }

  if (reason == 'connect' || reason == 'register') {
    if (lat == null || lon == null) return null;
    final iata = meshMapperZoneCode(iataCode);
    if (iata != null) payload['iata'] = iata;
    if (who != null) payload['who'] = who;
    payload['ver'] = appVersion ?? 'UNKNOWN';
    if (power != null) payload['power'] = '${power}w';
    if (model != null) payload['model'] = model;
    payload['coords'] = {
      'lat': lat,
      'lng': lon,
      'accuracy_m': accuracyMeters ?? 999,
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
  } else if (reason == 'disconnect') {
    if (sessionId != null) {
      payload['session_id'] = sessionId;
    }
  }

  return payload;
}

class MeshMapperApiService {
  static const String baseUrl = 'https://meshmapper.net';
  static const String wardriveEndpoint = '$baseUrl/wardrive-api.php/wardrive';
  static const String geoAuthStatusUrl = '$baseUrl/wardrive-api.php/status';
  static const String geoAuthUrl = '$baseUrl/wardrive-api.php/auth';
  static const String apiKey = String.fromEnvironment('API_KEY');
  static const Duration heartbeatBuffer = Duration(minutes: 1);
  static const Duration defaultWardriveRetryAfter = Duration(seconds: 75);
  static const Duration maxWardriveRetryAfter = Duration(hours: 1);

  final http.Client _client;
  final String _apiKey;
  final DateTime Function() _now;
  String? _sessionId;
  bool _txAllowed = false;
  bool _rxAllowed = false;
  String? _wireKey;
  int _resumeCounter = 0;
  bool _floodDisabled = false;
  int? _sessionExpiresAt;
  Timer? _heartbeatTimer;
  List<String> _channels = [];
  List<String> _scopes = [];
  String? _zone;
  bool _enforceHybrid = false;
  bool _enforceDiscDrop = false;
  int _minModeInterval = kWardrivingMinIntervalSec;
  int _apiHopBytes = 1;
  bool _heartbeatEnabled = false;
  int _heartbeatRetryCount = 0;
  ({double lat, double lon})? Function()? _gpsProvider;
  DateTime? _wardriveBlockedUntil;
  int _sessionEpoch = 0;

  void Function(String reason, String? message)? onSessionError;

  /// Invoked before replacing a live session with a different server session.
  /// Wire tags are derived from their originating session, so callers that
  /// preserve a queue must remove tagged entries before the replacement.
  FutureOr<void> Function(String previousSessionId, String sessionId)?
  onSessionIdChanged;

  MeshMapperApiService({
    http.Client? client,
    DateTime Function()? now,
    String apiKey = MeshMapperApiService.apiKey,
  }) : _client = client ?? http.Client(),
       _apiKey = apiKey,
       _now = now ?? DateTime.now;

  bool get hasApiKey => _apiKey.isNotEmpty;
  bool get hasSession => _sessionId != null;
  bool get txAllowed => _txAllowed;
  bool get rxAllowed => _rxAllowed;
  String? get wireKey => _wireKey;
  int get resumeCounter => _resumeCounter;
  bool get floodDisabled => _floodDisabled;
  int nextPingCounter() => _resumeCounter >= 2047 ? 2047 : ++_resumeCounter;
  String? get sessionId => _sessionId;
  int? get sessionExpiresAt => _sessionExpiresAt;
  List<String> get channels => List.unmodifiable(_channels);
  List<String> get scopes => List.unmodifiable(_scopes);
  String? get zone => _zone;
  bool get enforceHybrid => _enforceHybrid;
  bool get enforceDiscDrop => _enforceDiscDrop;
  int get minModeInterval => _minModeInterval;
  int get apiHopBytes => _apiHopBytes;
  bool get enforceHopBytes => _apiHopBytes > 1;

  ({String? id, int epoch}) _captureSession() =>
      (id: _sessionId, epoch: _sessionEpoch);

  bool _isCurrentSession(({String? id, int epoch}) captured) =>
      captured.id == _sessionId && captured.epoch == _sessionEpoch;

  /// Remaining server-requested hold for this session's wardrive door.
  /// A 429 pauses uploads, heartbeats, and session preflights together so a
  /// retry cannot extend the server's penalty or accidentally expire a valid
  /// session.
  Duration? get wardriveBackoff {
    final until = _wardriveBlockedUntil;
    if (until == null) return null;
    final remaining = until.difference(_now());
    if (remaining <= Duration.zero) {
      _wardriveBlockedUntil = null;
      return null;
    }
    return remaining;
  }

  bool get isWardriveHeld => wardriveBackoff != null;

  static Duration parseRetryAfter(String? raw) {
    final seconds = int.tryParse(raw?.trim() ?? '');
    if (seconds == null || seconds <= 0) return defaultWardriveRetryAfter;
    return Duration(seconds: seconds) > maxWardriveRetryAfter
        ? maxWardriveRetryAfter
        : Duration(seconds: seconds);
  }

  void _noteWardriveRateLimit(http.Response response) {
    _wardriveBlockedUntil = _now().add(
      parseRetryAfter(response.headers['retry-after']),
    );
  }

  Future<MeshMapperApiResponse> checkZoneStatus({
    required double lat,
    required double lon,
    required double accuracyMeters,
    required String appVersion,
  }) async {
    if (!hasApiKey) {
      return const MeshMapperApiResponse(error: 'missing_api_key');
    }
    try {
      final payload = {
        'lat': lat,
        'lng': lon,
        'accuracy_m': accuracyMeters,
        'ver': appVersion,
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'key': _apiKey,
      };
      final response = await _client
          .post(
            Uri.parse(geoAuthStatusUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 10));
      Map<String, dynamic>? data;
      try {
        data = json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {
        data = null;
      }
      if (response.statusCode != 200) {
        return MeshMapperApiResponse(
          data: data,
          httpStatus: response.statusCode,
        );
      }
      if (data?['success'] == true && data?['in_zone'] != false) {
        // A successful status response is authoritative. Retaining a prior
        // zone when this response omits one routes later uploads to stale UI.
        _zone =
            meshMapperZoneCode(data?['zone']) ??
            meshMapperZoneCode(data?['iata']);
      }
      return MeshMapperApiResponse(data: data);
    } catch (_) {
      return const MeshMapperApiResponse(error: 'network_error');
    }
  }

  Future<MeshMapperApiResponse> requestAuth({
    required String reason,
    String? publicKey,
    String? contactUri,
    String? who,
    String? appVersion,
    double? power,
    String? model,
    double? lat,
    double? lon,
    double? accuracyMeters,
    String? sessionId,
    String? iataCode,
    bool offlineMode = false,
    bool skipSessionStore = false,
  }) async {
    if (!hasApiKey) {
      return const MeshMapperApiResponse(error: 'missing_api_key');
    }
    final capturedSession = _captureSession();
    try {
      final payload = buildMeshMapperAuthRequestBody(
        apiKey: _apiKey,
        reason: reason,
        publicKey: publicKey,
        contactUri: contactUri,
        who: who,
        appVersion: appVersion,
        power: power,
        model: model,
        lat: lat,
        lon: lon,
        accuracyMeters: accuracyMeters,
        sessionId: sessionId ?? _sessionId,
        iataCode: iataCode,
        offlineMode: offlineMode,
      );
      if (payload == null) {
        if (reason == 'connect' || reason == 'register') {
          if (lat == null || lon == null) {
            return const MeshMapperApiResponse(error: 'missing_coords');
          }
          return const MeshMapperApiResponse(error: 'missing_identity');
        }
        return const MeshMapperApiResponse(error: 'missing_api_key');
      }

      final response = await _client
          .post(
            Uri.parse(geoAuthUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 10));
      Map<String, dynamic>? data;
      try {
        data = json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {
        data = null;
      }
      if (response.statusCode != 200) {
        return MeshMapperApiResponse(
          data: data,
          httpStatus: response.statusCode,
        );
      }

      if ((reason == 'connect' || reason == 'register') &&
          data?['success'] == true &&
          !skipSessionStore) {
        if (!_isCurrentSession(capturedSession)) {
          return MeshMapperApiResponse(data: data);
        }
        final previousSessionId = _sessionId;
        final newSessionId = data!['session_id'] as String?;
        if (previousSessionId != null &&
            newSessionId != null &&
            previousSessionId != newSessionId) {
          await onSessionIdChanged?.call(previousSessionId, newSessionId);
          if (!_isCurrentSession(capturedSession)) {
            return MeshMapperApiResponse(data: data);
          }
        }
        _sessionId = newSessionId;
        _sessionEpoch++;
        // A server backoff belongs to the session that earned it. Never carry
        // a prior session's hold into a newly issued session.
        if (previousSessionId != _sessionId) _wardriveBlockedUntil = null;
        _txAllowed = data['tx_allowed'] == true;
        _rxAllowed = data['rx_allowed'] == true;
        _wireKey = data['wire_key'] as String?;
        _resumeCounter = (data['resume_counter'] as num?)?.toInt() ?? 0;
        _floodDisabled = data['flood_disabled'] == true;
        _sessionExpiresAt = data['expires_at'] as int?;
        _channels = (data['channels'] as List?)?.cast<String>() ?? [];
        _scopes = (data['scopes'] as List?)?.cast<String>() ?? [];
        _zone =
            meshMapperZoneCode(data['zone']) ??
            meshMapperZoneCode(data['iata']) ??
            (_scopes.isEmpty ? _zone : meshMapperZoneCode(_scopes.first));
        _enforceHybrid = data['enforce_hybrid'] == true;
        _enforceDiscDrop = data['disc_drop'] == true;
        final minInterval = data['min_mode_interval'];
        _minModeInterval = minInterval is int && minInterval > 0
            ? minInterval
            : kWardrivingMinIntervalSec;
        final hopBytes = data['hop_bytes'];
        _apiHopBytes = hopBytes is int && hopBytes >= 1 && hopBytes <= 3
            ? hopBytes
            : 1;
      } else if (reason == 'disconnect' &&
          sessionId == null &&
          _isCurrentSession(capturedSession)) {
        _clearSession();
      }
      return MeshMapperApiResponse(data: data);
    } catch (_) {
      return const MeshMapperApiResponse(error: 'network_error');
    }
  }

  Future<Map<String, dynamic>?> submitWardriveData(
    List<Map<String, dynamic>> entries,
  ) async {
    if (_sessionId == null || !hasApiKey) return null;
    if (wardriveBackoff != null) {
      return const {'success': false, 'reason': 'held'};
    }
    final capturedSession = _captureSession();
    try {
      final payload = {
        'key': _apiKey,
        'session_id': capturedSession.id,
        'data': entries,
      };
      final response = await _client
          .post(
            Uri.parse(wardriveEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30));
      // The API returns useful, definitive JSON errors (notably expired and
      // invalid sessions) with non-200 statuses. Dropping that body turns a
      // session failure into an anonymous network retry and strands the queue.
      if (response.statusCode == 429 && _isCurrentSession(capturedSession)) {
        _noteWardriveRateLimit(response);
      }
      Map<String, dynamic>? data;
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map) data = Map<String, dynamic>.from(decoded);
      } catch (_) {
        // The 429 itself is authoritative even if an intermediary discarded
        // the JSON body. Return a held result rather than spending a retry.
      }
      if (response.statusCode == 429) {
        return {
          ...?data,
          'success': false,
          'reason': data?['reason'] ?? 'held',
        };
      }
      if (data == null) return null;
      // The old server may still answer after a disconnect/re-auth. Its
      // result can be returned to the original queue operation, but it must
      // not alter the new session's expiry, zone, hold, or callbacks.
      if (!_isCurrentSession(capturedSession)) return data;
      if (data['success'] == true && data['expires_at'] != null) {
        _sessionExpiresAt = data['expires_at'] as int;
        _zone =
            meshMapperZoneCode(data['zone']) ??
            meshMapperZoneCode(data['iata']) ??
            _zone;
        _scheduleHeartbeat(_sessionExpiresAt!);
      } else {
        final reason = data['reason'] as String?;
        const sessionErrors = {
          'session_expired',
          'session_invalid',
          'session_revoked',
          'bad_session',
          'invalid_key',
          'unauthorized',
          'bad_key',
          'zone_full',
          'zone_disabled',
        };
        if (sessionErrors.contains(reason)) {
          final message = data['message'] as String?;
          _clearSession();
          onSessionError?.call(reason ?? 'session_error', message);
        }
      }
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Uploads using a temporary session without mutating the live session.
  Future<Map<String, dynamic>?> submitWardriveDataWithSessionId(
    List<Map<String, dynamic>> entries,
    String sessionId,
  ) async {
    if (sessionId.isEmpty || !hasApiKey) return null;
    try {
      final response = await _client
          .post(
            Uri.parse(wardriveEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'key': _apiKey,
              'session_id': sessionId,
              'data': entries,
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return null;
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<List<MeshMapperRepeater>> fetchRepeaters(String zone) async {
    if (zone.trim().isEmpty) return const [];
    try {
      final response = await _client
          .get(
            Uri.parse(
              'https://${zone.toLowerCase()}.meshmapper.net/get_repeaters.php',
            ),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return const [];
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .where((entry) {
            final enabled = entry['enabled'];
            return enabled != false && enabled != 0 && enabled != '0';
          })
          .map(
            (entry) =>
                MeshMapperRepeater.fromJson(Map<String, dynamic>.from(entry)),
          )
          .where((entry) => entry.targetId.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<Uint8List?> fetchCoverageTile({
    required String zone,
    required int zoom,
    required int x,
    required int y,
    required int gridSize,
    bool fresh = false,
  }) async {
    if (zone.isEmpty || zoom < 7 || zoom > 14) return null;
    try {
      final uri = Uri.https(
        '${zone.toLowerCase()}.meshmapper.net',
        '/vector_tile.php',
        {
          'z': '$zoom',
          'x': '$x',
          'y': '$y',
          'gsize': gridSize == 100 ? '100' : '300',
          if (fresh) 'fresh': '1',
        },
      );
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 204) return Uint8List(0);
      return response.statusCode == 200 ? response.bodyBytes : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMapData({
    required String zone,
    required double lat,
    required double lon,
    required double radiusMeters,
  }) => _fetchCoveragePoints(
    zone: zone,
    body: {
      'request': 'map_data',
      'lat': lat,
      'lon': lon,
      'radius': radiusMeters,
    },
  );

  Future<List<Map<String, dynamic>>> fetchRepeaterCoverage({
    required String zone,
    required String prefix,
  }) => _fetchCoveragePoints(
    zone: zone,
    body: {'request': 'repeater_coverage', 'prefix': prefix},
  );

  Future<List<Map<String, dynamic>>> _fetchCoveragePoints({
    required String zone,
    required Map<String, dynamic> body,
  }) async {
    if (!hasApiKey || zone.isEmpty) return const [];
    try {
      final response = await _client
          .post(
            Uri.parse(
              'https://${zone.toLowerCase()}.meshmapper.net/app_coverage.php',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'key': _apiKey, ...body}),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return const [];
      final decoded = json.decode(response.body);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>?> sendHeartbeat({
    double? lat,
    double? lon,
  }) async {
    final result = await sendHeartbeatTyped(lat: lat, lon: lon);
    return result.data;
  }

  Future<MeshMapperHeartbeatResult> sendHeartbeatTyped({
    double? lat,
    double? lon,
  }) async {
    if (_sessionId == null || !hasApiKey) {
      return const MeshMapperHeartbeatResult.noSession();
    }
    if (wardriveBackoff != null) {
      return const MeshMapperHeartbeatResult.response({
        'success': false,
        'reason': 'held',
      });
    }
    final capturedSession = _captureSession();
    try {
      final payload = <String, dynamic>{
        'key': _apiKey,
        'session_id': capturedSession.id,
        'heartbeat': true,
      };
      if (lat != null && lon != null) {
        payload['coords'] = {
          'lat': lat,
          'lon': lon,
          'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        };
      }
      final response = await _client
          .post(
            Uri.parse(wardriveEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 429) {
        if (_isCurrentSession(capturedSession)) {
          _noteWardriveRateLimit(response);
        }
        Map<String, dynamic>? data;
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map) data = Map<String, dynamic>.from(decoded);
        } catch (_) {
          // The HTTP status and Retry-After are enough to preserve the
          // session and defer every wardrive sender.
        }
        return MeshMapperHeartbeatResult.response({
          ...?data,
          'success': false,
          'reason': data?['reason'] ?? 'held',
        });
      }
      if (response.statusCode != 200) {
        return MeshMapperHeartbeatResult.transient(
          'http_${response.statusCode}',
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (!_isCurrentSession(capturedSession)) {
        return MeshMapperHeartbeatResult.response(data);
      }
      if (data['success'] == true && data['expires_at'] != null) {
        _sessionExpiresAt = data['expires_at'] as int;
        _zone =
            meshMapperZoneCode(data['zone']) ??
            meshMapperZoneCode(data['iata']) ??
            _zone;
        _scheduleHeartbeat(_sessionExpiresAt!);
      }
      return MeshMapperHeartbeatResult.response(data);
    } catch (e) {
      return MeshMapperHeartbeatResult.transient(e.toString());
    }
  }

  Future<({bool isValid, String? reason, String? message})> checkSessionValid({
    double? lat,
    double? lon,
  }) async {
    if (_sessionId == null) {
      return (
        isValid: false,
        reason: 'no_session',
        message: 'No active session',
      );
    }
    if (wardriveBackoff != null) {
      // A rate limit is not a session verdict. Avoid re-arming the server's
      // penalty and keep using the last known-valid session until the hold
      // expires.
      return (isValid: true, reason: null, message: null);
    }
    final capturedSession = _captureSession();
    final result = await sendHeartbeatTyped(lat: lat, lon: lon);
    if (!_isCurrentSession(capturedSession)) {
      return (isValid: true, reason: 'superseded', message: null);
    }
    if (result.isTransientFailure) {
      // Transport hiccup — keep current session, let callers retry later
      // instead of forcing a re-register on every network blip.
      return (
        isValid: true,
        reason: 'transient',
        message: result.transientError,
      );
    }
    final data = result.data;
    if (data == null) {
      return (
        isValid: false,
        reason: 'no_response',
        message: 'Server did not respond',
      );
    }
    if (data['success'] == true) {
      return (isValid: true, reason: null, message: null);
    }
    final reason = data['reason'] as String?;
    final message = data['message'] as String?;
    if (reason == 'rate_limited' || reason == 'held') {
      return (isValid: true, reason: null, message: null);
    }
    const criticalErrors = {
      'session_expired',
      'session_invalid',
      'session_revoked',
      'bad_session',
      'invalid_key',
      'unauthorized',
      'bad_key',
      'zone_full',
      'zone_disabled',
    };
    if (criticalErrors.contains(reason)) {
      _clearSession();
      onSessionError?.call(reason ?? 'error', message);
    }
    return (isValid: false, reason: reason, message: message);
  }

  void enableHeartbeat({({double lat, double lon})? Function()? gpsProvider}) {
    _heartbeatEnabled = true;
    _gpsProvider = gpsProvider;
    if (_sessionExpiresAt != null) {
      _scheduleHeartbeat(_sessionExpiresAt!);
    }
  }

  void disableHeartbeat() {
    _heartbeatEnabled = false;
    _gpsProvider = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _heartbeatRetryCount = 0;
  }

  Future<void> disconnect() async {
    final capturedSession = _captureSession();
    if (capturedSession.id != null) {
      await requestAuth(reason: 'disconnect');
    }
    if (!_isCurrentSession(capturedSession)) {
      // A successful disconnect request already cleared this session. Do not
      // touch a replacement session, but finish disabling its old heartbeat.
      if (_sessionId == null) disableHeartbeat();
      return;
    }
    disableHeartbeat();
    _clearSession();
  }

  void _scheduleHeartbeat(int expiresAtSeconds) {
    if (!_heartbeatEnabled) return;
    _heartbeatTimer?.cancel();
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      expiresAtSeconds * 1000,
    );
    final sendAt = expiresAt.subtract(heartbeatBuffer);
    final normalDelay = sendAt.difference(_now());
    final hold = wardriveBackoff;
    final delay = hold != null && hold > normalDelay ? hold : normalDelay;
    _heartbeatTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      _runScheduledHeartbeat,
    );
  }

  Future<void> _runScheduledHeartbeat() async {
    if (!_heartbeatEnabled || _sessionId == null) return;
    final capturedSession = _captureSession();
    final coords = _gpsProvider?.call();
    final result = await sendHeartbeatTyped(lat: coords?.lat, lon: coords?.lon);
    // A request issued by a released session has no authority over the
    // replacement session's retry timer, expiry, or error callback.
    if (!_isCurrentSession(capturedSession)) return;
    if (!_heartbeatEnabled) return;
    if (result.isTransientFailure) {
      if (_heartbeatRetryCount >= 5) {
        _clearSession();
        onSessionError?.call(
          'heartbeat_failed',
          'MeshMapper heartbeat failed after retries',
        );
        return;
      }
      final delaySeconds = min(30 * (1 << _heartbeatRetryCount), 120);
      _heartbeatRetryCount++;
      _heartbeatTimer = Timer(
        Duration(seconds: delaySeconds),
        _runScheduledHeartbeat,
      );
      return;
    }
    _heartbeatRetryCount = 0;
    final data = result.data;
    if (data?['success'] == true) return;
    final reason = data?['reason'] as String? ?? 'heartbeat_failed';
    if (reason == 'rate_limited' || reason == 'held') {
      // A 429 leaves the server session valid. Re-arm the keepalive after the
      // shared hold instead of treating it as a terminal heartbeat failure.
      final expiresAt = _sessionExpiresAt;
      if (expiresAt != null) _scheduleHeartbeat(expiresAt);
      return;
    }
    final message = data?['message'] as String?;
    _clearSession();
    onSessionError?.call(reason, message);
  }

  void _clearSession() {
    _sessionEpoch++;
    _sessionId = null;
    _txAllowed = false;
    _rxAllowed = false;
    _wireKey = null;
    _resumeCounter = 0;
    _floodDisabled = false;
    _sessionExpiresAt = null;
    _channels = [];
    _scopes = [];
    _zone = null;
    _enforceHybrid = false;
    _enforceDiscDrop = false;
    _minModeInterval = kWardrivingMinIntervalSec;
    _apiHopBytes = 1;
    _wardriveBlockedUntil = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _heartbeatRetryCount = 0;
  }

  void dispose() {
    disableHeartbeat();
    _client.close();
  }
}

MeshMapperUploadResult classifyUploadResponse(Map<String, dynamic>? response) {
  if (response == null) return MeshMapperUploadResult.unreachable;
  if (response['success'] == true) return MeshMapperUploadResult.success;
  final reason = response['reason'] as String? ?? '';
  if (reason == 'rate_limited' || reason == 'held') {
    return MeshMapperUploadResult.held;
  }
  const nonRetryable = {
    'gps_inaccurate',
    'gps_stale',
    'invalid_request',
    'outofdate',
  };
  if (nonRetryable.contains(reason)) {
    return MeshMapperUploadResult.nonRetryable;
  }
  return MeshMapperUploadResult.retryable;
}
