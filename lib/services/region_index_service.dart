import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../helpers/region_scope_codes.dart';
import '../models/mesh_region.dart';
import '../models/region_boundary.dart';

class RegionBoundaryCatalog {
  final String title;
  final int version;
  final String? source;
  final String? retrievedAt;
  final Map<String, dynamic> policy;
  final List<RegionBoundary> regions;

  const RegionBoundaryCatalog({
    required this.title,
    required this.version,
    required this.source,
    required this.retrievedAt,
    required this.policy,
    required this.regions,
  });

  int get uniqueGeometryCount =>
      regions.map((region) => region.geometryUrl).toSet().length;

  List<RegionBoundary> get initiallyVisible => regions
      .where((region) => region.initiallyVisible)
      .toList(growable: false);

  /// Resolves the short/local region aliases shipped in the source policy.
  String canonicalRegionId(String id) {
    final aliases = policy['aliases'];
    if (aliases is! Map) return RegionScopeCodes.canonicalize(id);
    final resolved = aliases[id];
    return RegionScopeCodes.canonicalize(resolved is String ? resolved : id);
  }

  /// The region-codes website's repeater policy, independent of visible layers.
  /// Optional/proposed boundaries are excluded; local areas add their
  /// MeshMapper and Louisiana scopes where specified by the source policy.
  List<String> repeaterCodesAt(LatLng point) {
    if (!point.latitude.isFinite ||
        !point.longitude.isFinite ||
        point.latitude.abs() > 90 ||
        point.longitude.abs() > 180) {
      throw const FormatException('Invalid repeater coordinates.');
    }
    final statuses = (policy['allowedStatuses'] as List).cast<String>();
    final areas = (policy['areas'] as List).cast<Map<String, dynamic>>();
    final approved = regions.where(
      (region) =>
          !region.optional &&
          statuses.contains(region.coordinationStatus) &&
          region.containsPoint(point),
    );
    final approvedIds = approved
        .map((region) => canonicalRegionId(region.id))
        .toSet();
    final localCodes = <String>{};
    for (final area in areas) {
      localCodes.add(area['id'] as String);
      localCodes.addAll((area['codes'] as List? ?? const []).cast<String>());
      if (area['meshmapper'] is String) {
        localCodes.add(area['meshmapper'] as String);
      }
    }
    final allowed = approvedIds.difference(localCodes);
    for (final area in areas) {
      if (!approvedIds.contains(area['id'])) continue;
      allowed.addAll((area['codes'] as List? ?? [area['id']]).cast<String>());
      if (area['meshmapper'] is String) {
        allowed.add(area['meshmapper'] as String);
      }
      if (area['louisiana'] == true) {
        allowed.addAll((policy['louisianaCodes'] as List).cast<String>());
      }
    }
    if (!allowed.every(MeshRegion.isValidRegionName)) {
      throw const FormatException('Invalid repeater code in region policy.');
    }
    return allowed.toList()..sort();
  }
}

/// Loads docs.gulfcoastmesh.org/regions.json from the bundled app asset.
/// Its GeometryCollections are embedded in that one file; runtime does not
/// fetch boundaries from either the docs site or the geometry URLs in entries.
class RegionIndexService {
  RegionIndexService._();

  static const String assetPath = 'assets/geo/regions.json';
  static Future<RegionBoundaryCatalog>? _cachedLoad;

  static Future<RegionBoundaryCatalog> load() {
    return _cachedLoad ??= _loadAndCache();
  }

  static Future<RegionBoundaryCatalog> _loadAndCache() async {
    try {
      return await _load(rootBundle);
    } catch (_) {
      _cachedLoad = null;
      rethrow;
    }
  }

  static Future<RegionBoundaryCatalog> _load(AssetBundle bundle) async {
    final document = _readObject(
      jsonDecode(await bundle.loadString(assetPath)),
      assetPath,
    );
    final rawRegions = document['regions'];
    final rawGeometries = document['geometries'];
    if (rawRegions is! List || rawRegions.isEmpty) {
      throw const FormatException('Region catalog has no regions array.');
    }
    final geometries = _readObject(rawGeometries, '$assetPath.geometries');
    if (geometries.isEmpty) {
      throw const FormatException('Region catalog has no embedded geometries.');
    }

    final entries = <Map<String, dynamic>>[];
    final ids = <String>{};
    final geometryUrls = <String>{};
    for (var i = 0; i < rawRegions.length; i++) {
      final entry = _readObject(rawRegions[i], 'regions[$i]');
      final id = entry['id'];
      final geometryUrl = entry['geometry'];
      if (id is! String || id.trim().isEmpty || !ids.add(id)) {
        throw FormatException('Invalid or duplicate region id at index $i.');
      }
      if (geometryUrl is! String ||
          geometryUrl.trim().isEmpty ||
          !geometries.containsKey(geometryUrl)) {
        throw FormatException(
          'Region $id does not have a locally embedded geometry.',
        );
      }
      entries.add(entry);
      geometryUrls.add(geometryUrl);
    }

    final polygonsByUrl = <String, List<GeoJsonPolygon>>{};
    for (final geometryUrl in geometryUrls) {
      final collection = _readObject(
        geometries[geometryUrl],
        'geometry $geometryUrl',
      );
      if (collection['type'] != 'GeometryCollection') {
        throw FormatException('$geometryUrl is not a GeometryCollection.');
      }
      final rawShapes = collection['geometries'];
      if (rawShapes is! List || rawShapes.isEmpty) {
        throw FormatException('$geometryUrl has no embedded shapes.');
      }
      final polygons = <GeoJsonPolygon>[];
      for (var i = 0; i < rawShapes.length; i++) {
        final shape = _readObject(rawShapes[i], '$geometryUrl.geometries[$i]');
        switch (shape['type']) {
          case 'Polygon':
            polygons.add(_parsePolygon(shape['coordinates'], geometryUrl));
          case 'MultiPolygon':
            polygons.addAll(
              _parseMultiPolygon(shape['coordinates'], geometryUrl),
            );
          default:
            throw FormatException(
              '$geometryUrl has unsupported shape type: ${shape['type']}',
            );
        }
      }
      polygonsByUrl[geometryUrl] = List.unmodifiable(polygons);
    }

    final policy = document['policy'] == null
        ? <String, dynamic>{}
        : _readObject(document['policy'], '$assetPath.policy');
    final regions = <RegionBoundary>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final id = entry['id'] as String;
      final geometryUrl = entry['geometry'] as String;
      final status = _readOptionalText(entry, 'status') ?? 'unknown';
      regions.add(
        RegionBoundary(
          indexPosition: i,
          id: id,
          name: _readRequiredText(entry, 'name', id),
          coordinationStatus: status,
          coordinationLabel: _statusLabel(status),
          initiallyVisible: entry['visible'] != false,
          optional: entry['optional'] == true,
          geometryUrl: geometryUrl,
          polygons: polygonsByUrl[geometryUrl]!,
        ),
      );
    }

    final rawVersion = document['version'];
    return RegionBoundaryCatalog(
      title: 'Emerald Coast Mesh Regions',
      version: rawVersion is num ? rawVersion.toInt() : 1,
      source: _readOptionalText(document, 'source'),
      retrievedAt: _readOptionalText(document, 'retrievedAt'),
      policy: Map.unmodifiable(policy),
      regions: List.unmodifiable(regions),
    );
  }

  static List<GeoJsonPolygon> _parseMultiPolygon(
    dynamic coordinates,
    String source,
  ) {
    if (coordinates is! List || coordinates.isEmpty) {
      throw FormatException('$source has invalid MultiPolygon coordinates.');
    }
    return List.unmodifiable(
      coordinates.map((polygon) => _parsePolygon(polygon, source)),
    );
  }

  static GeoJsonPolygon _parsePolygon(dynamic coordinates, String source) {
    if (coordinates is! List || coordinates.isEmpty) {
      throw FormatException('$source has invalid Polygon coordinates.');
    }
    final rings = <List<LatLng>>[];
    for (final rawRing in coordinates) {
      if (rawRing is! List || rawRing.length < 4) {
        throw FormatException('$source has an invalid polygon ring.');
      }
      final points = <LatLng>[];
      for (final coordinate in rawRing) {
        if (coordinate is! List ||
            coordinate.length < 2 ||
            coordinate[0] is! num ||
            coordinate[1] is! num) {
          throw FormatException('$source has an invalid GeoJSON coordinate.');
        }
        final longitude = (coordinate[0] as num).toDouble();
        final latitude = (coordinate[1] as num).toDouble();
        if (!latitude.isFinite || !longitude.isFinite) {
          throw FormatException('$source has a non-finite GeoJSON coordinate.');
        }
        points.add(LatLng(latitude, longitude));
      }
      rings.add(List.unmodifiable(points));
    }
    return GeoJsonPolygon(List.unmodifiable(rings));
  }

  static Map<String, dynamic> _readObject(dynamic value, String label) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw FormatException('$label must be a JSON object.');
  }

  static String _readRequiredText(
    Map<String, dynamic> object,
    String key,
    String fallback,
  ) {
    final value = object[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    throw FormatException('Region $fallback is missing its $key.');
  }

  static String? _readOptionalText(Map<String, dynamic> object, String key) {
    final value = object[key];
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }

  static String _statusLabel(String status) => switch (status) {
    'official_local' => 'Official Local',
    'official_ecmesh' => 'Official Emerald Coast Mesh',
    'coordinated_external' => 'Coordinated External',
    'political_boundaries' => 'Political Boundaries',
    'proposed' => 'Proposed',
    'extrapolated_external' => 'Extrapolated External',
    _ => 'Status: $status',
  };

  static void debugResetCache() => _cachedLoad = null;
}
