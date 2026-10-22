import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../helpers/gulf_coast_region_geometry.dart';
import '../helpers/region_scope_codes.dart';
import '../helpers/user_map_center_mixin.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/gulf_coast_region_tree.dart';
import '../models/mesh_region.dart';
import '../services/map_tile_cache_service.dart';
import '../widgets/cached_osm_tile_layer.dart';

/// Hierarchical Gulf Coast map picker for a MeshCore flood region scope.
///
/// Returns the selected region code, `''` to clear, or `null` if cancelled.
class RegionScopePickerScreen extends StatefulWidget {
  final String? initialScope;
  final String? promptSubtitle;

  const RegionScopePickerScreen({
    super.key,
    this.initialScope,
    this.promptSubtitle,
  });

  @override
  State<RegionScopePickerScreen> createState() =>
      _RegionScopePickerScreenState();
}

class _RegionScopePickerScreenState extends State<RegionScopePickerScreen>
    with UserMapCenterMixin {
  final MapController _mapController = MapController();

  String _viewParentCode = GulfCoastRegionTree.simpleRootCode;
  GulfCoastRegionNode? _selected;
  bool _geoReady = GulfCoastRegionGeometry.cached != null;

  @override
  void initState() {
    super.initState();
    initUserMapCenter(mapController: _mapController);
    _applyInitialScope();
    _loadGeometry();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitVisibleRegions());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _applyInitialScope() {
    final initial = widget.initialScope == null
        ? null
        : RegionScopeCodes.canonicalize(widget.initialScope!);
    if (initial == null || initial.isEmpty) {
      _selected = GulfCoastRegionTree.find(GulfCoastRegionTree.simpleRootCode);
      return;
    }

    final node = GulfCoastRegionTree.find(initial);
    if (node != null && node.selectableForSend) {
      _selected = node;
      if (node.simplePicker) {
        if (node.code == GulfCoastRegionTree.simpleRootCode) {
          _viewParentCode = GulfCoastRegionTree.simpleRootCode;
        } else {
          final parent = node.parentCode;
          final parentNode = parent == null
              ? null
              : GulfCoastRegionTree.find(parent);
          _viewParentCode = (parentNode != null && parentNode.simplePicker)
              ? parent!
              : GulfCoastRegionTree.simpleRootCode;
        }
      }
      return;
    }

    if (MeshRegion.isValidRegionName(initial)) {
      _selected = GulfCoastRegionNode(
        code: initial,
        label: initial,
        simplePicker: false,
      );
    }
  }

  Future<void> _loadGeometry() async {
    await GulfCoastRegionGeometry.load();
    if (!mounted) return;
    setState(() => _geoReady = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitVisibleRegions());
  }

  /// Regions drawn / listed at the current level.
  List<GulfCoastRegionNode> get _visibleRegions =>
      GulfCoastRegionTree.simpleVisibleAt(_viewParentCode);

  /// Parent envelope drawn faintly behind children when drilled in.
  GulfCoastRegionNode? get _parentEnvelope {
    if (_viewParentCode == GulfCoastRegionTree.simpleRootCode) return null;
    return GulfCoastRegionTree.find(_viewParentCode);
  }

  /// List rows: when drilled, include the parent envelope so it stays selectable.
  List<GulfCoastRegionNode> get _listRegions {
    final visible = _visibleRegions;
    final parent = _parentEnvelope;
    if (parent == null) return visible;
    if (visible.any((n) => n.code == parent.code)) return visible;
    return [parent, ...visible];
  }

  List<GulfCoastRegionNode> get _simpleBreadcrumb {
    if (_viewParentCode == GulfCoastRegionTree.simpleRootCode) {
      return const [];
    }
    return GulfCoastRegionTree.ancestry(
      _viewParentCode,
    ).where((n) => n.simplePicker).toList();
  }

  void _fitVisibleRegions() {
    if (!mounted) return;
    final points = <LatLng>[];
    for (final region in _visibleRegions) {
      for (final ring in region.mapRings) {
        points.addAll(ring);
      }
    }
    final parent = _parentEnvelope;
    if (points.isEmpty && parent != null) {
      for (final ring in parent.mapRings) {
        points.addAll(ring);
      }
    }
    try {
      if (points.isEmpty) {
        _mapController.move(const LatLng(30.2, -90.5), 6.2);
        return;
      }
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(40),
        ),
      );
    } catch (_) {
      // Map may not have a size yet (first frame / layout race).
    }
  }

  void _select(GulfCoastRegionNode node) {
    setState(() => _selected = node);
  }

  void _drillInto(GulfCoastRegionNode node) {
    setState(() {
      _viewParentCode = node.code;
      _selected = node;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitVisibleRegions());
  }

  void _navigateTo(String parentCode) {
    setState(() {
      _viewParentCode = parentCode;
      if (parentCode == GulfCoastRegionTree.simpleRootCode) {
        _selected = GulfCoastRegionTree.find(
          GulfCoastRegionTree.simpleRootCode,
        );
      } else {
        _selected = GulfCoastRegionTree.find(parentCode);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitVisibleRegions());
  }

  Future<void> _enterCodeManually() async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: _selected?.code ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.channels_scopeEnterManually),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.channels_scopeManualHint,
              border: const OutlineInputBorder(),
              hintText: 'us-la-msy',
            ),
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.common_close),
            ),
            FilledButton(
              onPressed: () {
                final code = controller.text.trim().toLowerCase();
                if (!MeshRegion.isValidRegionName(code)) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(l10n.settings_defaultFloodScopeInvalid),
                    ),
                  );
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  RegionScopeCodes.canonicalize(code),
                );
              },
              child: Text(l10n.common_add),
            ),
          ],
        );
      },
    );
    if (result == null || !mounted) return;
    Navigator.pop(context, result);
  }

  List<Polygon> _buildPolygons(ThemeData theme) {
    final polygons = <Polygon>[];
    final parent = _parentEnvelope;
    if (parent != null) {
      final parentSelected = _selected?.code == parent.code;
      for (final ring in parent.mapRings) {
        polygons.add(
          Polygon(
            points: ring,
            color: parentSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.28)
                : theme.colorScheme.outline.withValues(alpha: 0.06),
            borderColor: parentSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            borderStrokeWidth: parentSelected ? 2.5 : 1.0,
          ),
        );
      }
    }

    final visible = [..._visibleRegions]
      ..sort((a, b) => b.mapArea.compareTo(a.mapArea)); // large first

    for (final region in visible) {
      final selected = _selected?.code == region.code;
      for (final ring in region.mapRings) {
        polygons.add(
          Polygon(
            points: ring,
            color:
                (selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.tertiary)
                    .withValues(alpha: selected ? 0.38 : 0.12),
            borderColor: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            borderStrokeWidth: selected ? 3 : 1.4,
          ),
        );
      }
    }
    return polygons;
  }

  List<Marker> _buildLabels(ThemeData theme) {
    final markers = <Marker>[];
    for (final region in _listRegions) {
      if (region.code == GulfCoastRegionTree.simpleRootCode &&
          _viewParentCode == GulfCoastRegionTree.simpleRootCode) {
        // Root envelope spans the whole map; skip crowded center label.
        continue;
      }
      final c = region.centroid;
      if (c == null) continue;
      final selected = _selected?.code == region.code;
      final shortLabel = region.label.split('/').first.trim();
      markers.add(
        Marker(
          point: c,
          width: 108,
          height: 32,
          child: GestureDetector(
            onTap: () => _select(region),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Center(
                  child: Text(
                    shortLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildBreadcrumb(ThemeData theme, AppLocalizations l10n) {
    if (_simpleBreadcrumb.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ActionChip(
            avatar: const Icon(Icons.public, size: 16),
            label: Text(l10n.channels_scopeGulfCoast),
            onPressed: () => _navigateTo(GulfCoastRegionTree.simpleRootCode),
          ),
          for (final node in _simpleBreadcrumb) ...[
            if (node.code != GulfCoastRegionTree.simpleRootCode) ...[
              Icon(
                Icons.chevron_right,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              ActionChip(
                label: Text(node.label),
                onPressed: () => _navigateTo(node.code),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSelectionCard(ThemeData theme, AppLocalizations l10n) {
    final selected = _selected;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selected == null ? l10n.channels_scopeUnscoped : selected.label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (selected != null) ...[
            const SizedBox(height: 6),
            Chip(
              label: Text(
                selected.code,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
          ],
          const SizedBox(height: 6),
          Text(
            widget.promptSubtitle ?? l10n.channels_scopeCoverageHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionList(ThemeData theme, AppLocalizations l10n) {
    final regions = _listRegions;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: regions.length,
      itemBuilder: (context, index) {
        final region = regions[index];
        final selected = _selected?.code == region.code;
        final canDrill =
            GulfCoastRegionTree.hasSimpleChildren(region) &&
            region.code != _viewParentCode;

        return ListTile(
          selected: selected,
          selectedTileColor: theme.colorScheme.primaryContainer.withValues(
            alpha: 0.45,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(
            region.label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          subtitle: Text(
            region.code,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: canDrill
              ? IconButton(
                  tooltip: l10n.channels_scopeMorePrecise,
                  icon: const Icon(Icons.unfold_more),
                  onPressed: () => _drillInto(region),
                )
              : null,
          onTap: () => _select(region),
        );
      },
    );
  }

  Widget _buildActions(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.channels_scopeClear,
            onPressed: () => Navigator.pop(context, ''),
            icon: const Icon(Icons.clear),
          ),
          IconButton(
            tooltip: l10n.channels_scopeEnterManually,
            onPressed: _enterCodeManually,
            icon: const Icon(Icons.edit_outlined),
          ),
          const Spacer(),
          FilledButton(
            onPressed: _selected == null
                ? null
                : () => Navigator.pop(context, _selected!.code),
            child: Text(l10n.channels_scopeSet),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MapTileCacheService>();
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hitOrder = [..._listRegions]
      ..sort((a, b) => a.mapArea.compareTo(b.mapArea));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.channels_scopeTitle),
            if (widget.promptSubtitle != null)
              Text(
                widget.promptSubtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_geoReady)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildBreadcrumb(theme, l10n),
          Expanded(
            flex: 5,
            child: SizedBox.expand(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(30.2, -90.5),
                  initialZoom: 6.2,
                  minZoom: 4,
                  maxZoom: 12,
                  interactionOptions: const InteractionOptions(
                    flags: ~InteractiveFlag.rotate,
                  ),
                  onTap: (_, latLng) {
                    for (final region in hitOrder) {
                      if (GulfCoastRegionTree.containsPoint(region, latLng)) {
                        _select(region);
                        return;
                      }
                    }
                  },
                ),
                children: [
                  const CachedOsmTileLayer(),
                  PolygonLayer(polygons: _buildPolygons(theme)),
                  MarkerLayer(markers: _buildLabels(theme)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Material(
              elevation: 8,
              color: theme.colorScheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              clipBehavior: Clip.antiAlias,
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    _buildSelectionCard(theme, l10n),
                    const Divider(height: 1),
                    Expanded(child: _buildRegionList(theme, l10n)),
                    _buildActions(l10n),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
