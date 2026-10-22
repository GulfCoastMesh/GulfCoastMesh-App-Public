import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/atak_location_access.dart';
import '../helpers/map_initial_location.dart';
import '../models/contact.dart';
import '../services/atak_location_broadcast_service.dart';
import '../widgets/cached_osm_tile_layer.dart';
import '../services/mesh_analyzer_state.dart';
import 'analyzer_map_overlays.dart';

class AnalyzerMap extends StatefulWidget {
  const AnalyzerMap({super.key});

  @override
  State<AnalyzerMap> createState() => _AnalyzerMapState();
}

class _AnalyzerMapState extends State<AnalyzerMap>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _showNodeLabels = false;
  String? _selectedNodeKey;
  bool _hasInitialized = false;
  AnimatedPath? _lastPath;
  LatLng? _savedCenter;
  double? _savedZoom;
  bool _returning = false;
  bool _motionEnabled = true;
  late AnimationController _hopAnim;
  LatLng? _hopStartCenter;
  double? _hopStartZoom;
  LatLng? _hopEndCenter;
  double? _hopEndZoom;
  List<LatLng> _currentHopPoints = [];
  int _currentHopIndex = 0;
  Timer? _hopTimer;

  static const Duration _hopAnimDuration = Duration(milliseconds: 500);
  static const Duration _hopPauseDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _hopAnim = AnimationController(vsync: this, duration: _hopAnimDuration);
    _hopAnim.addListener(_onHopAnimTick);
    _hopAnim.addStatusListener(_onHopAnimStatus);
  }

  void _onHopAnimTick() {
    if (_hopStartCenter == null || _hopEndCenter == null) return;
    if (_hopStartZoom == null || _hopEndZoom == null) return;
    final t = Curves.easeInOut.transform(_hopAnim.value);
    final lat =
        _hopStartCenter!.latitude +
        (_hopEndCenter!.latitude - _hopStartCenter!.latitude) * t;
    final lon =
        _hopStartCenter!.longitude +
        (_hopEndCenter!.longitude - _hopStartCenter!.longitude) * t;
    final zoom = _hopStartZoom! + (_hopEndZoom! - _hopStartZoom!) * t;
    _mapController.move(LatLng(lat, lon), zoom);
  }

  void _onHopAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _currentHopPoints.isNotEmpty) {
      if (_returning) {
        _resetHopState();
        return;
      }
      _hopTimer?.cancel();
      _hopTimer = Timer(_hopPauseDuration, () {
        if (!mounted) return;
        _advanceToNextHop();
      });
    }
  }

  void _startHopAnimation(List<LatLng> hopPoints) {
    _hopTimer?.cancel();
    _hopAnim.stop();
    _returning = false;
    _currentHopPoints = hopPoints;
    _currentHopIndex = 0;
    _savedCenter ??= _mapController.camera.center;
    _savedZoom ??= _mapController.camera.zoom;
    _animateToCurrentHop();
  }

  void _animateToCurrentHop() {
    if (_currentHopIndex >= _currentHopPoints.length) {
      _zoomBackToSaved();
      return;
    }
    final targetPoint = _currentHopPoints[_currentHopIndex];
    final currentCamera = _mapController.camera;
    final targetZoom = currentCamera.zoom < 12 ? 12.0 : currentCamera.zoom;

    _hopAnim.reset();
    _hopStartCenter = currentCamera.center;
    _hopStartZoom = currentCamera.zoom;
    _hopEndCenter = targetPoint;
    _hopEndZoom = targetZoom;
    _hopAnim.forward();
  }

  void _advanceToNextHop() {
    if (!mounted) return;
    _currentHopIndex++;
    _animateToCurrentHop();
  }

  void _zoomBackToSaved() {
    if (_savedCenter == null || _savedZoom == null) {
      _resetHopState();
      return;
    }
    _hopAnim.reset();
    _hopStartCenter = _mapController.camera.center;
    _hopStartZoom = _mapController.camera.zoom;
    _hopEndCenter = _savedCenter;
    _hopEndZoom = _savedZoom;
    _returning = true;
    _hopAnim.forward();
  }

  void _resetHopState() {
    _returning = false;
    _currentHopPoints = [];
    _currentHopIndex = 0;
    _savedCenter = null;
    _savedZoom = null;
  }

  void _cancelCameraMotion() {
    _hopTimer?.cancel();
    _hopAnim.stop();
    _resetHopState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motionEnabled =
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (!_motionEnabled) _cancelCameraMotion();
  }

  void _moveCamera(LatLng center, double zoom) {
    _cancelCameraMotion();
    if (!_motionEnabled) {
      _mapController.move(center, zoom);
      return;
    }
    _hopStartCenter = _mapController.camera.center;
    _hopStartZoom = _mapController.camera.zoom;
    _hopEndCenter = center;
    _hopEndZoom = zoom;
    _hopAnim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<
      MeshCoreConnector,
      MeshAnalyzerState,
      AtakLocationBroadcastService
    >(
      builder: (context, connector, analyzerState, broadcastService, child) {
        final contacts = connector.contacts;
        final contactsOnMap = contacts.where((c) => c.hasLocation).toList();
        final activePaths = analyzerState.activePaths;
        if (activePaths.isEmpty && _lastPath != null) _cancelCameraMotion();
        final selected = contactsOnMap
            .where((contact) => contact.publicKeyHex == _selectedNodeKey)
            .firstOrNull;
        if (selected == null) _selectedNodeKey = null;

        if (!_hasInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _hasInitialized) return;
            final phoneLat = broadcastService.phoneLat;
            final phoneLon = broadcastService.phoneLon;
            final center =
                phoneLat != null &&
                    phoneLon != null &&
                    isValidMapCoordinate(phoneLat, phoneLon)
                ? LatLng(phoneLat, phoneLon)
                : syncMapCenterFromConnector(connector);
            if (center != null) {
              _mapController.move(center, 10.0);
              _hasInitialized = true;
              return;
            }
            if (connector.isLoadingContacts) return;
            final points = connector.contacts
                .where((contact) => contact.hasLocation)
                .map((contact) => LatLng(contact.latitude!, contact.longitude!))
                .toList();
            // Keep waiting if contact locations have not arrived yet.
            if (points.isEmpty) return;
            if (points.every((point) => point == points.first)) {
              _mapController.move(points.first, 10.0);
            } else {
              _mapController.fitCamera(
                CameraFit.bounds(
                  bounds: LatLngBounds.fromPoints(points),
                  padding: const EdgeInsets.fromLTRB(72, 48, 112, 48),
                  maxZoom: 10,
                ),
              );
            }
            _hasInitialized = true;
          });
        }

        final selfLat = broadcastService.phoneLat ?? connector.selfLatitude;
        final selfLon = broadcastService.phoneLon ?? connector.selfLongitude;
        final selfPosition =
            (selfLat != null &&
                selfLon != null &&
                isValidMapCoordinate(selfLat, selfLon))
            ? LatLng(selfLat, selfLon)
            : null;

        final newestPath = activePaths.firstOrNull;
        if (!identical(newestPath, _lastPath)) {
          final shouldAnimate =
              newestPath != null &&
              _motionEnabled &&
              analyzerState.autoZoomEnabled &&
              activePaths.isNotEmpty;
          final newestPoints = shouldAnimate
              ? List<LatLng>.from(activePaths.first.points)
              : null;
          _lastPath = newestPath;
          if (newestPoints != null && newestPoints.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted ||
                  !_motionEnabled ||
                  !analyzerState.autoZoomEnabled) {
                return;
              }
              _startHopAnimation(newestPoints);
            });
          }
        }

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: kFallbackMapCenter,
                initialZoom: kWorldZoom,
                minZoom: 0,
                maxZoom: 18,
                onTap: (_, _) => setState(() => _selectedNodeKey = null),
                onPositionChanged: (_, hasGesture) {
                  if (hasGesture) _cancelCameraMotion();
                },
              ),
              children: [
                const CachedOsmTileLayer(),
                AnalyzerTrafficLayer(paths: activePaths),
                MarkerLayer(markers: _buildNodeMarkers(contactsOnMap, context)),
                if (selfPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selfPosition,
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                AnalyzerNodeCardLayer(
                  contact: selected,
                  color: selected == null
                      ? Colors.blue
                      : _nodeColor(selected.type),
                  onClose: () => setState(() => _selectedNodeKey = null),
                ),
              ],
            ),
            if (selected == null)
              Positioned(
                top: 8,
                right: 8,
                bottom: 40,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMapButton(
                        tooltip: context.l10n.analyzer_zoomIn,
                        icon: Icons.add,
                        onTap: () {
                          final camera = _mapController.camera;
                          _moveCamera(
                            camera.center,
                            (camera.zoom + 1).clamp(0.0, 18.0),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      _buildMapButton(
                        tooltip: context.l10n.analyzer_zoomOut,
                        icon: Icons.remove,
                        onTap: () {
                          final camera = _mapController.camera;
                          _moveCamera(
                            camera.center,
                            (camera.zoom - 1).clamp(0.0, 18.0),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      _buildMapButton(
                        tooltip: context.l10n.analyzer_fitMap,
                        icon: Icons.fit_screen,
                        onTap: () =>
                            _fitToActivePaths(activePaths, contactsOnMap),
                      ),
                      const SizedBox(height: 4),
                      _buildMapButton(
                        tooltip: context.l10n.analyzer_followTraffic,
                        icon: analyzerState.autoZoomEnabled
                            ? Icons.zoom_in_map
                            : Icons.zoom_out_map,
                        onTap: () {
                          _cancelCameraMotion();
                          analyzerState.toggleAutoZoom();
                        },
                        highlight: analyzerState.autoZoomEnabled,
                      ),
                      const SizedBox(height: 4),
                      _buildMapButton(
                        tooltip: _showNodeLabels
                            ? context.l10n.analyzer_hideLabels
                            : context.l10n.analyzer_showLabels,
                        icon: _showNodeLabels ? Icons.label : Icons.label_off,
                        onTap: () {
                          setState(() => _showNodeLabels = !_showNodeLabels);
                        },
                      ),
                      const SizedBox(height: 4),
                      _buildMapButton(
                        tooltip: context.l10n.analyzer_clear,
                        icon: Icons.clear_all,
                        onTap: () {
                          _cancelCameraMotion();
                          analyzerState.clearPaths();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (selected == null)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      context.l10n.analyzer_activePaths(activePaths.length),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Marker> _buildNodeMarkers(List<Contact> contacts, BuildContext context) {
    final markers = <Marker>[];
    for (final contact in contacts) {
      final color = _nodeColor(contact.type);
      markers.add(
        Marker(
          point: LatLng(contact.latitude!, contact.longitude!),
          width: _showNodeLabels ? 120 : 48,
          height: 48,
          child: Semantics(
            button: true,
            label: contact.displayName,
            selected: _selectedNodeKey == contact.publicKeyHex,
            child: GestureDetector(
              key: ValueKey('analyzer-node-${contact.publicKeyHex}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
                _selectedNodeKey = _selectedNodeKey == contact.publicKeyHex
                    ? null
                    : contact.publicKeyHex;
              }),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    width: _selectedNodeKey == contact.publicKeyHex ? 26 : 14,
                    height: _selectedNodeKey == contact.publicKeyHex ? 26 : 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: _selectedNodeKey == contact.publicKeyHex
                              ? 4
                              : 1,
                        ),
                      ],
                    ),
                  ),
                  if (_showNodeLabels)
                    Positioned(
                      top: 30,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          contact.displayName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  // intentionally fixed: node marker colors drawn on top of a raster map tile
  Color _nodeColor(int type) {
    switch (type) {
      case advTypeChat:
        return Colors.blue;
      case advTypeRepeater:
        return Colors.green;
      case advTypeRoom:
        return Colors.purple;
      case advTypeSensor:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _fitToActivePaths(
    List<AnimatedPath> activePaths,
    List<Contact> contacts,
  ) {
    final points = <LatLng>[];
    for (final path in activePaths) {
      points.addAll(path.points);
    }
    for (final contact in contacts) {
      if (contact.hasLocation) {
        points.add(LatLng(contact.latitude!, contact.longitude!));
      }
    }
    if (points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(points);
    final fitted = CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.all(48),
      maxZoom: 16,
    ).fit(_mapController.camera);
    _moveCamera(fitted.center, fitted.zoom);
  }

  Widget _buildMapButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: highlight
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: highlight
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hopTimer?.cancel();
    _hopAnim.dispose();
    _mapController.dispose();
    super.dispose();
  }
}
