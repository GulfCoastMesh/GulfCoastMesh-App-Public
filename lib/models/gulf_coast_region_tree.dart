import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../helpers/gulf_coast_region_geometry.dart';
import '../helpers/region_scope_codes.dart';
import 'mesh_region.dart';

/// One node in the Gulf Coast Mesh flood-scope hierarchy.
class GulfCoastRegionNode {
  final String code;
  final String label;
  final String? parentCode;

  /// Fallback single-ring outline when GeoJSON is not loaded yet.
  final List<LatLng> outline;

  /// When false, code is repeater/MeshMapper-only (e.g. `-mm` suffix).
  final bool selectableForSend;

  /// When false, hidden from the simple Gulf Coast map (e.g. `us`).
  /// Still valid for manual entry / QR.
  final bool simplePicker;

  const GulfCoastRegionNode({
    required this.code,
    required this.label,
    this.parentCode,
    this.outline = const [],
    this.selectableForSend = true,
    this.simplePicker = true,
  });

  /// Prefer loaded dissolved outer rings; else fallback [outline].
  List<List<LatLng>> get mapRings {
    final loaded = GulfCoastRegionGeometry.ringsFor(code);
    if (loaded.isNotEmpty) return loaded;
    if (outline.length >= 3) return [outline];
    return const [];
  }

  bool get hasOutline => mapRings.isNotEmpty;

  LatLngBounds? get bounds {
    final rings = mapRings;
    if (rings.isEmpty) return null;
    final points = <LatLng>[for (final r in rings) ...r];
    if (points.isEmpty) return null;
    return LatLngBounds.fromPoints(points);
  }

  double get mapArea => GulfCoastRegionGeometry.totalArea(mapRings);

  LatLng? get centroid {
    final rings = mapRings;
    if (rings.isEmpty) return null;
    // Use largest ring centroid.
    var best = rings.first;
    var bestArea = GulfCoastRegionGeometry.ringArea(best);
    for (final ring in rings.skip(1)) {
      final a = GulfCoastRegionGeometry.ringArea(ring);
      if (a > bestArea) {
        best = ring;
        bestArea = a;
      }
    }
    var lat = 0.0;
    var lon = 0.0;
    for (final p in best) {
      lat += p.latitude;
      lon += p.longitude;
    }
    return LatLng(lat / best.length, lon / best.length);
  }

  MeshRegion toMeshRegion() => MeshRegion(label: label, code: code);
}

/// Hierarchical Gulf Coast region catalog for map scope picking.
class GulfCoastRegionTree {
  GulfCoastRegionTree._();

  static const String simpleRootCode = 'us-gc';

  /// Full tree including `-mm` MeshMapper codes (not shown in send picker).
  static final List<GulfCoastRegionNode> all = [
    // Broad scopes — manual entry only (not on simple map).
    const GulfCoastRegionNode(
      code: 'us',
      label: 'United States',
      simplePicker: false,
    ),
    const GulfCoastRegionNode(
      code: 'us-southeast',
      label: 'US Southeast',
      parentCode: 'us',
      simplePicker: false,
    ),
    const GulfCoastRegionNode(
      code: 'us-south',
      label: 'US South',
      parentCode: 'us',
      simplePicker: false,
    ),
    const GulfCoastRegionNode(
      code: 'us-east',
      label: 'US East',
      parentCode: 'us',
      simplePicker: false,
    ),

    // Gulf Coast envelope + children (simple picker root).
    GulfCoastRegionNode(
      code: 'us-gc',
      label: 'Gulf Coast',
      parentCode: 'us-southeast',
      outline: _gcOutline,
    ),
    GulfCoastRegionNode(
      code: 'us-la',
      label: 'Louisiana',
      parentCode: 'us-gc',
      outline: _gcLaOutline,
    ),
    GulfCoastRegionNode(
      code: 'us-ms',
      label: 'Mississippi',
      parentCode: 'us-gc',
      outline: _gcMsOutline,
    ),
    GulfCoastRegionNode(
      code: 'us-ms-gpt',
      label: 'Gulfport / Biloxi',
      parentCode: 'us-gc',
      outline: _usCmOutline,
    ),
    GulfCoastRegionNode(
      code: 'us-pns',
      label: 'Pensacola',
      parentCode: 'us-gc',
      outline: _gcFlPnsOutline,
    ),
    GulfCoastRegionNode(
      code: 'us-la-msy',
      label: 'Baton Rouge / New Orleans',
      parentCode: 'us-la',
      outline: _gcLaMsyOutline,
    ),
    GulfCoastRegionNode(
      code: 'us-la-lft',
      label: 'Acadiana / Lafayette',
      parentCode: 'us-la',
      outline: _gcLaLftOutline,
    ),
    GulfCoastRegionNode(
      code: 'us-la-lc',
      label: 'Lake Charles',
      parentCode: 'us-la',
      outline: _gcLaLcOutline,
    ),

    // MeshMapper-only
    const GulfCoastRegionNode(
      code: 'gc-la-lft-mm',
      label: 'LFT MeshMapper',
      parentCode: 'us-la-lft',
      selectableForSend: false,
      simplePicker: false,
    ),
    const GulfCoastRegionNode(
      code: 'us-la-lc-mm',
      label: 'LC MeshMapper',
      parentCode: 'us-la-lc',
      selectableForSend: false,
      simplePicker: false,
    ),
    const GulfCoastRegionNode(
      code: 'us-ms-gpt-mm',
      label: 'GPT MeshMapper',
      parentCode: 'us-ms-gpt',
      selectableForSend: false,
      simplePicker: false,
    ),
    const GulfCoastRegionNode(
      code: 'gc-fl-pns-mm',
      label: 'PNS MeshMapper',
      parentCode: 'us-pns',
      selectableForSend: false,
      simplePicker: false,
    ),
  ];

  // --- Organic outlines (clockwise, closed by renderer) ---

  /// TX line → FL panhandle coastal band.
  static final List<LatLng> _gcOutline = [
    const LatLng(29.2, -94.1),
    const LatLng(30.0, -93.9),
    const LatLng(31.0, -93.5),
    const LatLng(31.4, -91.8),
    const LatLng(31.6, -90.2),
    const LatLng(31.2, -88.6),
    const LatLng(30.9, -87.2),
    const LatLng(30.6, -86.3),
    const LatLng(30.2, -86.4),
    const LatLng(29.9, -87.5),
    const LatLng(30.0, -88.5),
    const LatLng(29.8, -89.3),
    const LatLng(29.1, -89.6),
    const LatLng(28.9, -90.5),
    const LatLng(29.0, -91.8),
    const LatLng(29.3, -93.0),
  ];

  /// Louisiana: TX border through boot to MS line (coastal + south-central).
  static final List<LatLng> _gcLaOutline = [
    const LatLng(29.6, -93.9),
    const LatLng(30.4, -93.7),
    const LatLng(31.1, -93.5),
    const LatLng(31.2, -92.5),
    const LatLng(31.1, -91.5),
    const LatLng(31.0, -90.5),
    const LatLng(30.9, -89.7),
    const LatLng(30.3, -89.6),
    const LatLng(29.9, -89.5),
    const LatLng(29.4, -89.5),
    const LatLng(29.1, -89.8),
    const LatLng(29.0, -90.6),
    const LatLng(29.2, -91.5),
    const LatLng(29.4, -92.4),
    const LatLng(29.5, -93.3),
  ];

  /// I-59 corridor Picayune → north Mississippi (elongated).
  static final List<LatLng> _gcMsOutline = [
    const LatLng(30.4, -89.8),
    const LatLng(30.8, -89.7),
    const LatLng(31.4, -89.5),
    const LatLng(32.2, -89.4),
    const LatLng(33.0, -89.3),
    const LatLng(34.0, -89.2),
    const LatLng(34.3, -88.6),
    const LatLng(33.8, -88.3),
    const LatLng(32.8, -88.4),
    const LatLng(31.8, -88.5),
    const LatLng(31.0, -88.7),
    const LatLng(30.5, -89.0),
  ];

  /// MS Gulf Coast / Coastal Mississippi strip.
  static final List<LatLng> _usCmOutline = [
    const LatLng(30.15, -89.65),
    const LatLng(30.55, -89.55),
    const LatLng(30.65, -89.10),
    const LatLng(30.60, -88.55),
    const LatLng(30.45, -88.20),
    const LatLng(30.25, -88.15),
    const LatLng(30.15, -88.40),
    const LatLng(30.20, -88.90),
    const LatLng(30.18, -89.35),
  ];

  /// Pensacola bay area.
  static final List<LatLng> _gcFlPnsOutline = [
    const LatLng(30.25, -87.55),
    const LatLng(30.55, -87.45),
    const LatLng(30.65, -87.10),
    const LatLng(30.55, -86.55),
    const LatLng(30.35, -86.50),
    const LatLng(30.20, -86.70),
    const LatLng(30.22, -87.15),
  ];

  /// BR → New Orleans / Northshore corridor.
  static final List<LatLng> _gcLaMsyOutline = [
    const LatLng(29.70, -91.35),
    const LatLng(30.20, -91.30),
    const LatLng(30.55, -91.15),
    const LatLng(30.70, -90.70),
    const LatLng(30.65, -90.10),
    const LatLng(30.40, -89.70),
    const LatLng(30.05, -89.65),
    const LatLng(29.75, -89.75),
    const LatLng(29.55, -90.00),
    const LatLng(29.50, -90.50),
    const LatLng(29.55, -91.00),
  ];

  /// Acadiana / Lafayette (Atchafalaya → Jennings).
  static final List<LatLng> _gcLaLftOutline = [
    const LatLng(29.85, -92.70),
    const LatLng(30.25, -92.65),
    const LatLng(30.45, -92.30),
    const LatLng(30.40, -91.50),
    const LatLng(30.15, -91.20),
    const LatLng(29.90, -91.25),
    const LatLng(29.75, -91.60),
    const LatLng(29.80, -92.20),
  ];

  /// Lake Charles (Jennings → TX line).
  static final List<LatLng> _gcLaLcOutline = [
    const LatLng(29.75, -93.85),
    const LatLng(30.20, -93.75),
    const LatLng(30.40, -93.40),
    const LatLng(30.35, -92.85),
    const LatLng(30.10, -92.70),
    const LatLng(29.80, -92.80),
    const LatLng(29.70, -93.20),
    const LatLng(29.72, -93.60),
  ];

  static final Map<String, GulfCoastRegionNode> _byCode = {
    for (final node in all) node.code: node,
  };

  static GulfCoastRegionNode? find(String code) =>
      _byCode[RegionScopeCodes.canonicalize(code)];

  static List<GulfCoastRegionNode> childrenOf(String? parentCode) {
    return all
        .where(
          (n) =>
              n.parentCode ==
              (parentCode == null
                  ? null
                  : RegionScopeCodes.canonicalize(parentCode)),
        )
        .toList();
  }

  /// Regions shown on the simple Gulf Coast map at [parentCode].
  ///
  /// At the root (`parentCode == simpleRootCode` or null treated as root),
  /// returns `us-gc` itself plus its direct simple children.
  static List<GulfCoastRegionNode> simpleVisibleAt(String? parentCode) {
    final parent = parentCode == null
        ? simpleRootCode
        : RegionScopeCodes.canonicalize(parentCode);
    if (parent == simpleRootCode) {
      final root = find(simpleRootCode);
      final kids = childrenOf(simpleRootCode).where(_isSimpleMapNode);
      return [if (root != null && _isSimpleMapNode(root)) root, ...kids];
    }
    return childrenOf(parent).where(_isSimpleMapNode).toList();
  }

  static bool _isSimpleMapNode(GulfCoastRegionNode n) =>
      n.selectableForSend && n.simplePicker && n.hasOutline;

  /// Whether [node] has drillable simple-picker children.
  static bool hasSimpleChildren(GulfCoastRegionNode node) {
    return childrenOf(node.code).any(_isSimpleMapNode);
  }

  /// Direct simple-picker children (excludes the node itself).
  static List<GulfCoastRegionNode> simpleChildrenOf(String code) {
    return childrenOf(code).where(_isSimpleMapNode).toList();
  }

  /// Codes offered in companion send-scope UI (excludes `-mm`).
  static List<GulfCoastRegionNode> get sendSelectable =>
      all.where((n) => n.selectableForSend).toList();

  static List<String> get sendSelectableCodes =>
      sendSelectable.map((n) => n.code).toList();

  static List<GulfCoastRegionNode> get simplePickerNodes =>
      all.where((n) => n.simplePicker && n.selectableForSend).toList();

  /// Ancestry from root to [code] inclusive.
  static List<GulfCoastRegionNode> ancestry(String code) {
    final path = <GulfCoastRegionNode>[];
    GulfCoastRegionNode? current = find(code);
    while (current != null) {
      path.insert(0, current);
      current = current.parentCode != null ? find(current.parentCode!) : null;
    }
    return path;
  }

  /// Breadcrumb for simple UI (starts at `us-gc`, skips `us` / `us-southeast`).
  static String simpleBreadcrumb(String code) {
    return ancestry(
      code,
    ).where((n) => n.simplePicker).map((n) => n.code).join(' > ');
  }

  static String breadcrumb(String code) {
    return ancestry(code).map((n) => n.code).join(' > ');
  }

  static String displayLabel(String code) {
    final node = find(code);
    if (node != null) return '${node.label} ($code)';
    return MeshRegion.displayLabel(code);
  }

  static List<LatLng> outlineOf(GulfCoastRegionNode node) {
    final rings = node.mapRings;
    if (rings.isEmpty) return const [];
    return rings.first;
  }

  /// Point-in-polygon using GeoJSON rings when loaded.
  static bool containsPoint(GulfCoastRegionNode node, LatLng point) {
    final rings = node.mapRings;
    if (rings.isNotEmpty) {
      return GulfCoastRegionGeometry.containsPoint(rings, point);
    }
    return false;
  }
}
