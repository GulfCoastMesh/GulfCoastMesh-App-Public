import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/atak_location_access.dart';
import '../helpers/map_initial_location.dart';
import '../helpers/tactical_map_payload.dart';
import '../helpers/user_map_center_mixin.dart';
import '../l10n/l10n.dart';
import '../services/map_tile_cache_service.dart';

class LocationPickScreen extends StatefulWidget {
  const LocationPickScreen({super.key});

  @override
  State<LocationPickScreen> createState() => _LocationPickScreenState();
}

class _LocationPickScreenState extends State<LocationPickScreen>
    with UserMapCenterMixin {
  // intentionally fixed: map marker on raster tile, not theme-relative
  static const Color _waypointColor = Color(0xFFE65100);

  final MapController _mapController = MapController();
  final TextEditingController _nameController = TextEditingController();

  LatLng? _selectedPosition;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    initUserMapCenter(mapController: _mapController);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  bool get _canSend {
    final name = _nameController.text.trim();
    return _selectedPosition != null && name.isNotEmpty;
  }

  Future<void> _useCurrentLocation() async {
    if (_locating) return;

    setState(() => _locating = true);
    try {
      final granted = await ensureAtakLocationPermission();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.chat_locationPermissionRequired)),
        );
        return;
      }

      final position = await readAtakPosition();
      if (!mounted) return;
      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.chat_locationPermissionRequired)),
        );
        return;
      }

      final latLng = LatLng(position.lat, position.lon);
      setState(() => _selectedPosition = latLng);
      _mapController.move(latLng, kUserLocationZoom);
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  void _sendWaypoint() {
    final position = _selectedPosition;
    final label = _nameController.text.trim();
    if (position == null || label.isEmpty) return;

    final payload = TacticalMapPayload.formatPoi(
      lat: position.latitude,
      lon: position.longitude,
      timestampSeconds: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      label: label,
      type: 'wp',
    );

    Navigator.pop(context, payload);
  }

  LatLng _initialCenter() {
    if (_selectedPosition != null) return _selectedPosition!;
    return userMapCenterOrFallback;
  }

  double _initialZoom() {
    if (_selectedPosition != null) return kUserLocationZoom;
    return userMapZoomOrFallback;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MeshCoreConnector>();
    final tileCache = context.read<MapTileCacheService>();
    final initialCenter = _initialCenter();
    final initialZoom = _initialZoom();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.chat_sendWaypoint),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_locating)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: context.l10n.chat_location,
              onPressed: _useCurrentLocation,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: initialZoom,
                minZoom: 2.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: ~InteractiveFlag.rotate,
                ),
                onTap: (_, latLng) {
                  setState(() => _selectedPosition = latLng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: kMapTileUrlTemplate,
                  tileProvider: tileCache.tileProvider,
                  userAgentPackageName:
                      MapTileCacheService.userAgentPackageName,
                  maxZoom: 19,
                ),
                if (_selectedPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPosition!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.trip_origin,
                          color: _waypointColor,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Material(
            elevation: 8,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.chat_pickLocationHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: context.l10n.map_label,
                        labelText: context.l10n.map_pinLabel,
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedPosition == null
                                ? '—'
                                : '${_selectedPosition!.latitude.toStringAsFixed(6)}, '
                                      '${_selectedPosition!.longitude.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _canSend ? _sendWaypoint : null,
                          child: Text(context.l10n.common_share),
                        ),
                      ],
                    ),
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
