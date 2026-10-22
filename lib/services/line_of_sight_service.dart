import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

typedef ElevationDataSource =
    Future<List<double?>> Function(List<LatLng> points);

class LineOfSightSample {
  final double distanceMeters;
  final double terrainMeters;
  final double lineHeightMeters;
  final double clearanceMeters;

  const LineOfSightSample({
    required this.distanceMeters,
    required this.terrainMeters,
    required this.lineHeightMeters,
    required this.clearanceMeters,
  });
}

class LineOfSightResult {
  final bool hasData;
  final bool isClear;
  final double totalDistanceMeters;
  final double maxObstructionMeters;
  final double? firstObstructionDistanceMeters;
  final List<LineOfSightSample> samples;
  final String? errorMessage;

  const LineOfSightResult({
    required this.hasData,
    required this.isClear,
    required this.totalDistanceMeters,
    required this.maxObstructionMeters,
    required this.firstObstructionDistanceMeters,
    required this.samples,
    this.errorMessage,
  });

  const LineOfSightResult.error({
    required this.totalDistanceMeters,
    required this.errorMessage,
  }) : hasData = false,
       isClear = false,
       maxObstructionMeters = 0,
       firstObstructionDistanceMeters = null,
       samples = const [];
}

class LineOfSightPathSegment {
  final int index;
  final LatLng start;
  final LatLng end;
  final LineOfSightResult result;

  const LineOfSightPathSegment({
    required this.index,
    required this.start,
    required this.end,
    required this.result,
  });
}

class LineOfSightPathResult {
  final List<LineOfSightPathSegment> segments;
  final int clearSegments;
  final int blockedSegments;
  final int unknownSegments;

  const LineOfSightPathResult({
    required this.segments,
    required this.clearSegments,
    required this.blockedSegments,
    required this.unknownSegments,
  });
}

class LineOfSightService {
  static const String errorElevationUnavailable =
      'los_error_elevation_unavailable';
  static const String errorInvalidInput = 'los_error_invalid_input';

  static const double _earthRadiusMeters = 6371000.0;
  static const Distance _distance = Distance();
  static const Duration _cacheTtl = Duration(hours: 24);
  static const int _maxFetchAttempts = 4; // initial try + 3 retries
  static const Duration _initialBackoff = Duration(milliseconds: 300);

  final http.Client _httpClient;
  final bool _ownsHttpClient;
  final ElevationDataSource? _elevationDataSource;
  final Map<String, _CachedElevation> _elevationCache = {};

  LineOfSightService({
    http.Client? httpClient,
    ElevationDataSource? elevationDataSource,
  }) : _httpClient = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null,
       _elevationDataSource = elevationDataSource;

  Future<LineOfSightPathResult> analyzePath(
    List<LatLng> points, {
    double startAntennaHeightMeters = 1.5,
    double endAntennaHeightMeters = 1.5,
    double kFactor = 4.0 / 3.0,
    double obstructionToleranceMeters = 0.0,
  }) async {
    if (points.length < 2) {
      return const LineOfSightPathResult(
        segments: [],
        clearSegments: 0,
        blockedSegments: 0,
        unknownSegments: 0,
      );
    }

    final segments = <LineOfSightPathSegment>[];
    var clearSegments = 0;
    var blockedSegments = 0;
    var unknownSegments = 0;

    for (int i = 0; i < points.length - 1; i++) {
      final result = await analyzeLink(
        points[i],
        points[i + 1],
        startAntennaHeightMeters: startAntennaHeightMeters,
        endAntennaHeightMeters: endAntennaHeightMeters,
        kFactor: kFactor,
        obstructionToleranceMeters: obstructionToleranceMeters,
      );
      segments.add(
        LineOfSightPathSegment(
          index: i,
          start: points[i],
          end: points[i + 1],
          result: result,
        ),
      );

      if (!result.hasData) {
        unknownSegments++;
      } else if (result.isClear) {
        clearSegments++;
      } else {
        blockedSegments++;
      }
    }

    return LineOfSightPathResult(
      segments: segments,
      clearSegments: clearSegments,
      blockedSegments: blockedSegments,
      unknownSegments: unknownSegments,
    );
  }

  Future<LineOfSightResult> analyzeLink(
    LatLng start,
    LatLng end, {
    double startAntennaHeightMeters = 1.5,
    double endAntennaHeightMeters = 1.5,
    double kFactor = 4.0 / 3.0,
    double obstructionToleranceMeters = 0.0,
  }) async {
    final totalDistanceMeters = _distance.as(LengthUnit.Meter, start, end);
    if (totalDistanceMeters <= 1) {
      return LineOfSightResult(
        hasData: true,
        isClear: true,
        totalDistanceMeters: totalDistanceMeters,
        maxObstructionMeters: 0,
        firstObstructionDistanceMeters: null,
        samples: const [],
      );
    }

    final samplePoints = _buildSamplePoints(start, end, totalDistanceMeters);
    final elevations = await _getElevations(samplePoints);

    if (elevations.any((e) => e == null)) {
      return LineOfSightResult.error(
        totalDistanceMeters: totalDistanceMeters,
        errorMessage: errorElevationUnavailable,
      );
    }

    return computeFromElevations(
      points: samplePoints,
      elevations: elevations.cast<double>(),
      startAntennaHeightMeters: startAntennaHeightMeters,
      endAntennaHeightMeters: endAntennaHeightMeters,
      kFactor: kFactor,
      obstructionToleranceMeters: obstructionToleranceMeters,
    );
  }

  static LineOfSightResult computeFromElevations({
    required List<LatLng> points,
    required List<double> elevations,
    double startAntennaHeightMeters = 1.5,
    double endAntennaHeightMeters = 1.5,
    double kFactor = 4.0 / 3.0,
    double obstructionToleranceMeters = 0.0,
  }) {
    if (points.length < 2 || elevations.length != points.length) {
      return const LineOfSightResult.error(
        totalDistanceMeters: 0,
        errorMessage: errorInvalidInput,
      );
    }

    final totalDistanceMeters = _distance.as(
      LengthUnit.Meter,
      points.first,
      points.last,
    );
    final effectiveEarthRadius = _earthRadiusMeters * kFactor;
    final startLineHeight = elevations.first + startAntennaHeightMeters;
    final endLineHeight = elevations.last + endAntennaHeightMeters;

    var maxObstructionMeters = 0.0;
    double? firstObstructionDistanceMeters;
    final samples = <LineOfSightSample>[];
    var isClear = true;

    for (int i = 0; i < points.length; i++) {
      final fraction = points.length == 1 ? 0.0 : i / (points.length - 1);
      final distanceFromStart = totalDistanceMeters * fraction;
      final lineHeight =
          startLineHeight + (endLineHeight - startLineHeight) * fraction;

      final earthBulge =
          (distanceFromStart * (totalDistanceMeters - distanceFromStart)) /
          (2 * effectiveEarthRadius);
      final terrainHeight = elevations[i] + earthBulge;
      final clearance = lineHeight - terrainHeight;

      if (clearance < -obstructionToleranceMeters) {
        isClear = false;
        final obstruction = -clearance;
        if (obstruction > maxObstructionMeters) {
          maxObstructionMeters = obstruction;
        }
        firstObstructionDistanceMeters ??= distanceFromStart;
      }

      samples.add(
        LineOfSightSample(
          distanceMeters: distanceFromStart,
          terrainMeters: terrainHeight,
          lineHeightMeters: lineHeight,
          clearanceMeters: clearance,
        ),
      );
    }

    return LineOfSightResult(
      hasData: true,
      isClear: isClear,
      totalDistanceMeters: totalDistanceMeters,
      maxObstructionMeters: maxObstructionMeters,
      firstObstructionDistanceMeters: firstObstructionDistanceMeters,
      samples: samples,
    );
  }

  List<LatLng> _buildSamplePoints(
    LatLng start,
    LatLng end,
    double distanceMeters,
  ) {
    final sampleCount = distanceMeters < 2000
        ? 21
        : distanceMeters < 10000
        ? 41
        : 81;

    final points = <LatLng>[];
    for (int i = 0; i < sampleCount; i++) {
      final t = i / (sampleCount - 1);
      points.add(
        LatLng(
          start.latitude + (end.latitude - start.latitude) * t,
          start.longitude + (end.longitude - start.longitude) * t,
        ),
      );
    }
    return points;
  }

  Future<List<double?>> _getElevations(List<LatLng> points) async {
    final dataSource = _elevationDataSource;
    if (dataSource != null) {
      return dataSource(points);
    }

    final uncached = <int, LatLng>{};
    final values = List<double?>.filled(points.length, null);
    for (int i = 0; i < points.length; i++) {
      final key = _cacheKey(points[i]);
      final cached = _readCachedValue(key);
      if (cached != null) {
        values[i] = cached;
      } else {
        uncached[i] = points[i];
      }
    }

    if (uncached.isEmpty) return values;

    final latCsv = uncached.values
        .map((p) => p.latitude.toStringAsFixed(6))
        .join(',');
    final lonCsv = uncached.values
        .map((p) => p.longitude.toStringAsFixed(6))
        .join(',');

    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/elevation?latitude=$latCsv&longitude=$lonCsv',
    );

    final response = await _getWithBackoff(uri);
    if (response.statusCode != 200) {
      return values;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return values;
    }
    final elevations = decoded['elevation'];
    if (elevations is! List) {
      return values;
    }

    final indices = uncached.keys.toList();
    for (int i = 0; i < min(indices.length, elevations.length); i++) {
      final value = elevations[i];
      if (value is! num) continue;
      final index = indices[i];
      final elevation = value.toDouble();
      values[index] = elevation;
      _elevationCache[_cacheKey(points[index])] = _CachedElevation(
        value: elevation,
        expiresAt: DateTime.now().add(_cacheTtl),
      );
    }
    return values;
  }

  static const Duration _requestTimeout = Duration(seconds: 15);

  Future<http.Response> _getWithBackoff(Uri uri) async {
    var attempt = 0;
    Duration backoff = _initialBackoff;

    while (true) {
      attempt++;
      try {
        final response = await _httpClient.get(uri).timeout(_requestTimeout);
        if (!_shouldRetryStatus(response.statusCode) ||
            attempt >= _maxFetchAttempts) {
          return response;
        }
      } catch (_) {
        if (attempt >= _maxFetchAttempts) rethrow;
      }

      await Future.delayed(backoff);
      backoff *= 2;
    }
  }

  bool _shouldRetryStatus(int statusCode) {
    return statusCode == 429 || statusCode >= 500;
  }

  double? _readCachedValue(String key) {
    final cached = _elevationCache[key];
    if (cached == null) return null;
    if (DateTime.now().isAfter(cached.expiresAt)) {
      _elevationCache.remove(key);
      return null;
    }
    return cached.value;
  }

  String _cacheKey(LatLng point) {
    return '${point.latitude.toStringAsFixed(5)},${point.longitude.toStringAsFixed(5)}';
  }

  void dispose() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }
}

class _CachedElevation {
  final double value;
  final DateTime expiresAt;

  const _CachedElevation({required this.value, required this.expiresAt});
}
