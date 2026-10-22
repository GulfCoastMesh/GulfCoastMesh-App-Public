import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/region_boundary.dart';
import '../services/region_index_service.dart';
import '../widgets/cached_osm_tile_layer.dart';

class RegionIndexMapScreen extends StatefulWidget {
  final bool selectForRepeater;
  final LatLng? initialLocation;

  const RegionIndexMapScreen({
    super.key,
    this.selectForRepeater = false,
    this.initialLocation,
  });

  @override
  State<RegionIndexMapScreen> createState() => _RegionIndexMapScreenState();
}

class _RegionIndexMapScreenState extends State<RegionIndexMapScreen> {
  static const List<Color> _palette = [
    Color(0xFF0F766E),
    Color(0xFFB91C1C),
    Color(0xFF1D4ED8),
    Color(0xFFB45309),
    Color(0xFF6D28D9),
    Color(0xFF047857),
    Color(0xFFBE185D),
    Color(0xFF4338CA),
  ];

  RegionBoundaryCatalog? _catalog;
  Object? _loadError;
  final Set<String> _visibleRegionIds = {};
  LatLng? _selectedPoint;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialLocation;
    unawaited(_loadCatalog());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    setState(() => _loadError = null);
    try {
      final catalog = await RegionIndexService.load();
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _visibleRegionIds
          ..clear()
          ..addAll(catalog.initiallyVisible.map((region) => region.id));
        if (widget.selectForRepeater) {
          _visibleRegionIds.addAll(
            (catalog.policy['areas'] as List).map(
              (area) => area['id'] as String,
            ),
          );
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error);
    }
  }

  List<RegionBoundary> get _visibleRegions {
    final catalog = _catalog;
    if (catalog == null) return const [];
    return catalog.regions
        .where((region) => _visibleRegionIds.contains(region.id))
        .toList(growable: false);
  }

  List<Polygon> _buildPolygons() {
    final polygons = <Polygon>[];
    for (final region in _visibleRegions) {
      final color = _palette[region.indexPosition % _palette.length];
      final selected =
          widget.selectForRepeater &&
          _selectedPoint != null &&
          region.containsPoint(_selectedPoint!);
      for (final geometry in region.polygons) {
        if (geometry.rings.isEmpty) continue;
        polygons.add(
          Polygon(
            points: geometry.rings.first,
            holePointsList: geometry.rings.skip(1).toList(growable: false),
            color: color.withValues(
              alpha: selected
                  ? 0.2
                  : widget.selectForRepeater
                  ? 0.025
                  : 0.14,
            ),
            borderColor: color.withValues(alpha: 0.9),
            borderStrokeWidth: selected ? 3 : 1.5,
          ),
        );
      }
    }
    return polygons;
  }

  Future<void> _showLayerPicker() async {
    final catalog = _catalog;
    if (catalog == null) return;
    var query = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final normalizedQuery = query.trim().toLowerCase();
          final filteredRegions = catalog.regions
              .where((region) {
                if (normalizedQuery.isEmpty) return true;
                return region.name.toLowerCase().contains(normalizedQuery) ||
                    region.id.toLowerCase().contains(normalizedQuery) ||
                    region.displayCode.toLowerCase().contains(normalizedQuery);
              })
              .toList(growable: false);
          final height = MediaQuery.sizeOf(context).height * 0.82;

          return SafeArea(
            child: SizedBox(
              height: height,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Region layers',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '${_visibleRegionIds.length} of ${catalog.regions.length} shown · boundary data bundled in app',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _visibleRegionIds
                                ..clear()
                                ..addAll(
                                  catalog.regions.map((region) => region.id),
                                );
                            });
                            setSheetState(() {});
                          },
                          child: const Text('All'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(_visibleRegionIds.clear);
                            setSheetState(() {});
                          },
                          child: const Text('None'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      onChanged: (value) => setSheetState(() => query = value),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search regions or codes',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredRegions.length,
                      itemBuilder: (context, index) {
                        final region = filteredRegions[index];
                        final selected = _visibleRegionIds.contains(region.id);
                        return SwitchListTile(
                          dense: true,
                          value: selected,
                          onChanged: (value) {
                            setState(() {
                              if (value) {
                                _visibleRegionIds.add(region.id);
                              } else {
                                _visibleRegionIds.remove(region.id);
                              }
                            });
                            setSheetState(() {});
                          },
                          title: Text(
                            region.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${region.displayCode} · ${region.coordinationLabel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondary: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color:
                                  _palette[region.indexPosition %
                                      _palette.length],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showRegionsAt(LatLng point) async {
    if (widget.selectForRepeater) {
      await _showRepeaterRegionsAt(point);
      return;
    }
    final matches = _visibleRegions
        .where((region) => region.containsPoint(point))
        .toList(growable: false);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Regions at ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (matches.isEmpty)
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.info_outline),
                    title: Text('No enabled region boundary at this point'),
                  )
                else
                  for (final region in matches)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color:
                              _palette[region.indexPosition % _palette.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      title: Text(region.name),
                      subtitle: Text(
                        '${region.displayCode} · ${region.coordinationLabel}',
                      ),
                    ),
                const SizedBox(height: 4),
                Text(
                  'Region boundaries are bundled locally. Base map tiles use the app map cache.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showRepeaterRegionsAt(LatLng point) async {
    final catalog = _catalog;
    if (catalog == null) return;
    setState(() => _selectedPoint = point);
    final codes = catalog.repeaterCodesAt(point);
    final use = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Regions at ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (codes.isEmpty)
                  const Text(
                    'No approved regions found. Choose another location. '
                    'Optional and proposed regions are not added automatically.',
                  )
                else ...[
                  const Text(
                    'Allow these regions and unscoped traffic (*). '
                    'Save Regions in repeater settings to apply your changes.',
                  ),
                  const SizedBox(height: 8),
                  for (final code in codes)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.check,
                        color: Colors.greenAccent.shade700,
                      ),
                      title: Text(code),
                    ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.add),
                    label: const Text('Use these regions'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || use != true) return;
    Navigator.pop(context, codes);
  }

  Future<void> _enterCoordinates() async {
    final point = _selectedPoint;
    var latitude = point?.latitude.toStringAsFixed(6) ?? '';
    var longitude = point?.longitude.toStringAsFixed(6) ?? '';
    final formKey = GlobalKey<FormState>();
    final selected = await showDialog<LatLng>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Repeater coordinates'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final isLatitude in [true, false])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      initialValue: isLatitude ? latitude : longitude,
                      onChanged: (text) {
                        if (isLatitude) {
                          latitude = text;
                        } else {
                          longitude = text;
                        }
                      },
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: isLatitude ? 'Latitude' : 'Longitude',
                      ),
                      validator: (text) {
                        final value = double.tryParse(text?.trim() ?? '');
                        final limit = isLatitude ? 90 : 180;
                        return value == null ||
                                !value.isFinite ||
                                value.abs() > limit
                            ? 'Enter a number from -$limit to $limit'
                            : null;
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                context,
                LatLng(
                  double.parse(latitude.trim()),
                  double.parse(longitude.trim()),
                ),
              );
            },
            child: const Text('Find regions'),
          ),
        ],
      ),
    );
    if (!mounted || selected == null) return;
    _mapController.move(selected, _mapController.camera.zoom);
    await _showRepeaterRegionsAt(selected);
  }

  Widget _buildLoadState() {
    final error = _loadError;
    if (error == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Loading bundled region boundaries…'),
          ],
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 56),
            const SizedBox(height: 12),
            const Text('Could not load the bundled region data.'),
            const SizedBox(height: 6),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadCatalog,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _catalog;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectForRepeater
              ? 'Repeater regions'
              : catalog?.title ?? 'Region boundaries',
        ),
        actions: [
          if (catalog != null && widget.selectForRepeater)
            IconButton(
              tooltip: 'Enter coordinates',
              onPressed: _enterCoordinates,
              icon: const Icon(Icons.pin_drop_outlined),
            ),
          if (catalog != null)
            IconButton(
              tooltip: 'Choose region layers',
              onPressed: _showLayerPicker,
              icon: const Icon(Icons.layers_outlined),
            ),
        ],
      ),
      body: catalog == null
          ? _buildLoadState()
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        widget.initialLocation ?? const LatLng(31.5, -89.5),
                    initialZoom: widget.initialLocation == null ? 5.2 : 9,
                    minZoom: 2,
                    maxZoom: 18,
                    interactionOptions: const InteractionOptions(
                      flags: ~InteractiveFlag.rotate,
                    ),
                    onTap: (_, point) => _showRegionsAt(point),
                  ),
                  children: [
                    const CachedOsmTileLayer(),
                    PolygonLayer(polygons: _buildPolygons()),
                    if (_selectedPoint != null && widget.selectForRepeater)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPoint!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.redAccent,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: SafeArea(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: widget.selectForRepeater
                            ? _selectedPoint == null
                                  ? const Text(
                                      'Tap where the repeater is installed',
                                    )
                                  : TextButton.icon(
                                      onPressed: () =>
                                          _showRegionsAt(_selectedPoint!),
                                      icon: const Icon(
                                        Icons.location_on_outlined,
                                      ),
                                      label: const Text('Use this location'),
                                    )
                            : Text(
                                '${catalog.regions.length} local boundaries · ${_visibleRegionIds.length} shown',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
