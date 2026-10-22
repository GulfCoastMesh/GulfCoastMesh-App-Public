import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../helpers/meshmapper_coverage.dart';
import 'meshmapper_api_service.dart';

class MeshMapperCoverageService extends ChangeNotifier {
  static const int maxVisibleTiles = 16;
  static const int maxCells = 5000;
  static const int maxCachedTiles = 64;

  final MeshMapperApiService _api;
  final Map<String, List<MeshMapperCoverageCell>> _tileCache = {};
  List<MeshMapperCoverageCell> _cells = const [];
  bool _active = false;
  bool _loading = false;
  String? _error;
  int _generation = 0;

  MeshMapperCoverageService({required MeshMapperApiService api}) : _api = api;

  List<MeshMapperCoverageCell> get cells => List.unmodifiable(_cells);
  bool get isActive => _active;
  bool get isLoading => _loading;
  String? get error => _error;

  void setActive(bool value) {
    if (_active == value) return;
    _active = value;
    _generation++;
    if (!value) {
      _cells = const [];
      _error = null;
      _loading = false;
    }
    notifyListeners();
  }

  Future<void> loadVisible({
    required String zone,
    required double north,
    required double south,
    required double east,
    required double west,
    required double zoom,
    required int gridSize,
    bool fresh = false,
  }) async {
    if (!_active || zone.isEmpty) return;
    final generation = _generation;
    final tileZoom = zoom.floor().clamp(7, 14);
    final minX = _longitudeToTileX(west, tileZoom);
    final maxX = _longitudeToTileX(east, tileZoom);
    final minY = _latitudeToTileY(north, tileZoom);
    final maxY = _latitudeToTileY(south, tileZoom);
    final requested = <(int, int)>[];
    for (var x = minX; x <= maxX; x++) {
      for (var y = minY; y <= maxY; y++) {
        requested.add((x, y));
      }
    }
    if (requested.length > maxVisibleTiles) {
      requested
        ..sort((a, b) {
          final centerX = (minX + maxX) / 2;
          final centerY = (minY + maxY) / 2;
          final da = math.pow(a.$1 - centerX, 2) + math.pow(a.$2 - centerY, 2);
          final db = math.pow(b.$1 - centerX, 2) + math.pow(b.$2 - centerY, 2);
          return da.compareTo(db);
        })
        ..removeRange(maxVisibleTiles, requested.length);
    }

    _loading = true;
    _error = null;
    notifyListeners();
    try {
      for (final tile in requested) {
        if (!_active || generation != _generation) return;
        final key = '$zone/$tileZoom/${tile.$1}/${tile.$2}/$gridSize';
        if (!fresh && _tileCache.containsKey(key)) {
          final cached = _tileCache.remove(key)!;
          _tileCache[key] = cached;
          continue;
        }
        final body = await _api.fetchCoverageTile(
          zone: zone,
          zoom: tileZoom,
          x: tile.$1,
          y: tile.$2,
          gridSize: gridSize,
          fresh: fresh,
        );
        if (body == null) {
          _error = 'MeshMapper coverage temporarily unavailable';
          continue;
        }
        _tileCache[key] = decodeMeshMapperCoverageCells(body);
        while (_tileCache.length > maxCachedTiles) {
          _tileCache.remove(_tileCache.keys.first);
        }
      }
      if (!_active || generation != _generation) return;
      final visible = <MeshMapperCoverageCell>[];
      for (final tile in requested) {
        final key = '$zone/$tileZoom/${tile.$1}/${tile.$2}/$gridSize';
        visible.addAll(_tileCache[key] ?? const []);
        if (visible.length >= maxCells) break;
      }
      _cells = visible.take(maxCells).toList(growable: false);
    } finally {
      if (_active && generation == _generation) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  void invalidate() {
    _tileCache.clear();
    _cells = const [];
    _generation++;
    notifyListeners();
  }

  int _longitudeToTileX(double longitude, int zoom) {
    final count = 1 << zoom;
    return (((longitude + 180) / 360 * count).floor())
        .clamp(0, count - 1)
        .toInt();
  }

  int _latitudeToTileY(double latitude, int zoom) {
    final count = 1 << zoom;
    final clamped = latitude.clamp(-85.05112878, 85.05112878);
    final radians = clamped * math.pi / 180;
    final value =
        (1 - math.log(math.tan(radians) + 1 / math.cos(radians)) / math.pi) / 2;
    return (value * count).floor().clamp(0, count - 1).toInt();
  }
}
