import 'dart:convert';

import 'package:http/http.dart' as http;

/// MeshBuddy prefix-reservation API client.
///
/// Spec: https://meshbuddy.gulfcoastmesh.org/api/spec
class MeshBuddyApiService {
  static const String defaultBaseUrl = 'https://meshbuddy.gulfcoastmesh.org';
  static const String defaultSource = 'gulfcoastmesh-app';

  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  MeshBuddyApiService({
    String? baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : baseUrl = (baseUrl ?? defaultBaseUrl).replaceAll(RegExp(r'/+$'), ''),
       _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<MeshBuddyStatus> getStatus() async {
    final response = await _get('/api/status');
    if (response.error != null) {
      throw MeshBuddyApiException(response.error!);
    }
    final data = response.data;
    if (data == null) {
      throw const MeshBuddyApiException('empty_response');
    }
    return MeshBuddyStatus.fromJson(data);
  }

  Future<MeshBuddyPrefixAvailability> checkPrefix(String prefix) async {
    final normalized = prefix.trim().toUpperCase();
    final response = await _get(
      '/api/prefix/${Uri.encodeComponent(normalized)}',
    );
    if (response.error != null) {
      throw MeshBuddyApiException(response.error!);
    }
    final data = response.data;
    if (data == null) {
      throw const MeshBuddyApiException('empty_response');
    }
    return MeshBuddyPrefixAvailability.fromJson(data);
  }

  Future<List<MeshBuddyReservation>> myReservations(String email) async {
    final response = await _post('/api/my-reservations', {
      'email': email.trim(),
    });
    if (response.error != null) {
      throw _exceptionFromHttpResponse(response);
    }
    final data = response.data;
    if (data == null) {
      throw const MeshBuddyApiException('empty_response');
    }
    if (data['success'] == false) {
      throw MeshBuddyApiException(
        formatMeshBuddyError(data),
        reason: _meshBuddyErrorReason(data),
      );
    }
    final list = data['reservations'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => MeshBuddyReservation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<MeshBuddyReservation> reserve({
    required String prefix,
    required String name,
    required double lat,
    required double lon,
    required double altitude,
    required String email,
    String? username,
    String? displayName,
    String? userId,
    String source = defaultSource,
  }) async {
    final body = <String, dynamic>{
      'prefix': prefix.trim().toUpperCase(),
      'name': name.trim(),
      'lat': lat,
      'lon': lon,
      'altitude': altitude,
      'email': email.trim(),
      'source': source,
    };
    if (username != null && username.trim().isNotEmpty) {
      body['username'] = username.trim();
    }
    if (displayName != null && displayName.trim().isNotEmpty) {
      body['display_name'] = displayName.trim();
    }
    if (userId != null && userId.trim().isNotEmpty) {
      body['user_id'] = userId.trim();
    }

    final response = await _post('/api/reserve', body);
    if (response.error != null) {
      throw _exceptionFromHttpResponse(response);
    }
    final data = response.data;
    if (data == null) {
      throw const MeshBuddyApiException('empty_response');
    }
    final reservation = data['reservation'];
    if (reservation is Map) {
      return MeshBuddyReservation.fromJson(
        Map<String, dynamic>.from(reservation),
      );
    }
    if (data['success'] == true) {
      // Some deployments may return fields at the top level.
      return MeshBuddyReservation.fromJson(data);
    }
    throw MeshBuddyApiException(
      formatMeshBuddyError(data),
      reason: _meshBuddyErrorReason(data),
    );
  }

  /// Generate a MeshCore vanity keypair for a reserved prefix.
  ///
  /// Spec: `POST /api/keygen` — requires [email] on the reservation. Private key
  /// is returned once and is not stored by the API. Uses a longer timeout because
  /// server-side vanity search can take tens of seconds.
  Future<MeshBuddyKeygenResult> keygen({
    required String prefix,
    required String email,
    Duration timeout = const Duration(seconds: 120),
  }) async {
    final response = await _post('/api/keygen', {
      'prefix': prefix.trim().toUpperCase(),
      'email': email.trim(),
    }, timeout: timeout);
    if (response.error != null) {
      throw _exceptionFromHttpResponse(response);
    }
    final data = response.data;
    if (data == null) {
      throw const MeshBuddyApiException('empty_response');
    }
    final result = MeshBuddyKeygenResult.fromJson(data);
    if (!result.isValid) {
      throw const MeshBuddyApiException('invalid_keygen_response');
    }
    return result;
  }

  Future<_MeshBuddyHttpResponse> _get(String path) async {
    try {
      final response = await _client
          .get(_uri(path), headers: {'Accept': 'application/json'})
          .timeout(timeout);
      return _parse(response);
    } catch (_) {
      return const _MeshBuddyHttpResponse(error: 'network_error');
    }
  }

  Future<_MeshBuddyHttpResponse> _post(
    String path,
    Map<String, dynamic> body, {
    Duration? timeout,
  }) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(timeout ?? this.timeout);
      return _parse(response);
    } catch (_) {
      return const _MeshBuddyHttpResponse(error: 'network_error');
    }
  }

  _MeshBuddyHttpResponse _parse(http.Response response) {
    Map<String, dynamic>? data;
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else if (decoded is Map) {
        data = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      data = null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (data != null) {
        return _MeshBuddyHttpResponse(
          data: data,
          httpStatus: response.statusCode,
          error: formatMeshBuddyError(data),
        );
      }
      return _MeshBuddyHttpResponse(
        httpStatus: response.statusCode,
        error: 'http_${response.statusCode}',
      );
    }
    return _MeshBuddyHttpResponse(data: data, httpStatus: response.statusCode);
  }

  void close() => _client.close();
}

class _MeshBuddyHttpResponse {
  final Map<String, dynamic>? data;
  final int? httpStatus;
  final String? error;

  const _MeshBuddyHttpResponse({this.data, this.httpStatus, this.error});
}

class MeshBuddyApiException implements Exception {
  final String message;
  final String? reason;

  const MeshBuddyApiException(this.message, {this.reason});

  @override
  String toString() => message;
}

class MeshBuddyStatus {
  final bool ok;
  final String service;
  final int prefixLength;
  final String timestamp;

  const MeshBuddyStatus({
    required this.ok,
    required this.service,
    required this.prefixLength,
    required this.timestamp,
  });

  factory MeshBuddyStatus.fromJson(Map<String, dynamic> json) {
    return MeshBuddyStatus(
      ok: json['ok'] == true || json['status'] == 'ok',
      service: json['service'] as String? ?? 'meshbuddy',
      prefixLength: (json['prefix_length'] as num?)?.toInt() ?? 4,
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}

class MeshBuddyReservation {
  final String prefix;
  final String name;
  final double lat;
  final double lon;
  final double altitude;
  final String status;
  final String? email;
  final String? createdAt;
  final String? updatedAt;

  const MeshBuddyReservation({
    required this.prefix,
    required this.name,
    required this.lat,
    required this.lon,
    required this.altitude,
    required this.status,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  bool get isReserved => status.toLowerCase() == 'reserved';
  bool get isDeployed => status.toLowerCase() == 'deployed';

  factory MeshBuddyReservation.fromJson(Map<String, dynamic> json) {
    return MeshBuddyReservation(
      prefix: (json['prefix'] as String? ?? '').toUpperCase(),
      name: json['name'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0,
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'reserved',
      email: json['email'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class MeshBuddyPrefixAvailability {
  final String prefix;
  final bool available;
  final String? reason;
  final MeshBuddyReservation? reservation;

  const MeshBuddyPrefixAvailability({
    required this.prefix,
    required this.available,
    this.reason,
    this.reservation,
  });

  factory MeshBuddyPrefixAvailability.fromJson(Map<String, dynamic> json) {
    MeshBuddyReservation? reservation;
    final raw = json['reservation'];
    if (raw is Map) {
      reservation = MeshBuddyReservation.fromJson(
        Map<String, dynamic>.from(raw),
      );
    }
    return MeshBuddyPrefixAvailability(
      prefix: (json['prefix'] as String? ?? '').toUpperCase(),
      available: json['available'] == true,
      reason: json['reason'] as String?,
      reservation: reservation,
    );
  }
}

/// Result of `POST /api/keygen`.
class MeshBuddyKeygenResult {
  final String prefix;
  final String publicKey;
  final String privateKey;
  final int attempts;
  final double elapsedSecs;

  const MeshBuddyKeygenResult({
    required this.prefix,
    required this.publicKey,
    required this.privateKey,
    required this.attempts,
    required this.elapsedSecs,
  });

  bool get isValid {
    final pub = publicKey.trim();
    final prv = privateKey.trim();
    if (pub.length != 64 || prv.length != 128) return false;
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(pub)) return false;
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(prv)) return false;
    final pfx = prefix.trim().toLowerCase();
    if (pfx.isEmpty) return false;
    return pub.toLowerCase().startsWith(pfx);
  }

  factory MeshBuddyKeygenResult.fromJson(Map<String, dynamic> json) {
    return MeshBuddyKeygenResult(
      prefix: (json['prefix'] as String? ?? '').toUpperCase(),
      publicKey: (json['public_key'] as String? ?? '').toUpperCase(),
      privateKey: (json['private_key'] as String? ?? '').toUpperCase(),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      elapsedSecs: (json['elapsed_secs'] as num?)?.toDouble() ?? 0,
    );
  }
}

String? _meshBuddyErrorReason(Map<String, dynamic> data) {
  final reason = data['reason'] as String?;
  if (reason != null && reason.isNotEmpty) return reason;
  return data['error'] as String?;
}

MeshBuddyApiException _exceptionFromHttpResponse(
  _MeshBuddyHttpResponse response,
) {
  final data = response.data;
  if (data != null) {
    return MeshBuddyApiException(
      formatMeshBuddyError(data),
      reason: _meshBuddyErrorReason(data),
    );
  }
  return MeshBuddyApiException(response.error ?? 'network_error');
}

String formatMeshBuddyError(Map<String, dynamic> data) {
  final message = data['message'] as String?;
  if (message != null && message.trim().isNotEmpty) {
    return _humanizeMeshBuddyErrorToken(message.trim());
  }
  final error = data['error'] as String?;
  if (error != null && error.trim().isNotEmpty) {
    return _humanizeMeshBuddyErrorToken(error.trim());
  }
  final reason = data['reason'] as String?;
  if (reason == null || reason.isEmpty) {
    if (data['success'] == false) return 'Request failed';
    return 'Unexpected MeshBuddy response';
  }
  return _humanizeMeshBuddyErrorToken(reason);
}

String _humanizeMeshBuddyErrorToken(String token) {
  return switch (token) {
    'reserved' => 'That prefix is already reserved',
    'deployed' => 'That prefix is already deployed',
    'unusable' => 'That prefix cannot be used (reserved by the system)',
    'invalid_prefix' => 'Invalid prefix format',
    'invalid_email' => 'Invalid email address',
    'missing_fields' => 'Missing required reservation fields',
    'rate_limited' => 'Too many requests — try again later',
    'network_error' => 'Network error contacting MeshBuddy',
    'invalid_keygen_response' => 'MeshBuddy returned an invalid keypair',
    'Not found' => 'No reservation found for that prefix/email',
    _ => token,
  };
}

/// Whether the app should fall back to on-device vanity search.
bool shouldFallbackToLocalKeygen(MeshBuddyApiException error) {
  final reason = (error.reason ?? error.message).toLowerCase();
  if (reason == 'network_error' || error.message == 'network_error') {
    return true;
  }
  if (error.message == 'http_503' || error.message == 'http_504') return true;
  if (reason.contains('unavailable') || reason.contains('timed out')) {
    return true;
  }
  if (reason.contains('timeout') || reason.contains('generator')) return true;
  return false;
}

String formatMeshBuddyException(Object error) {
  if (error is MeshBuddyApiException) {
    if (error.message == 'network_error') {
      return 'Network error contacting MeshBuddy';
    }
    if (error.message.startsWith('http_')) {
      return 'MeshBuddy API HTTP ${error.message.substring(5)}';
    }
    return error.message;
  }
  return error.toString();
}
