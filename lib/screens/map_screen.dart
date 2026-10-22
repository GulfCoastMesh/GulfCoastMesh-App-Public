import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gulf_coast_mesh_app/screens/path_trace_map.dart';
import 'package:gulf_coast_mesh_app/widgets/app_bar.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/atak_channel_helper.dart';
import '../helpers/atak_location_access.dart';
import '../helpers/atak_map_markers.dart';
import '../helpers/map_initial_location.dart';
import '../helpers/meshmapper_coverage.dart';
import '../helpers/user_map_center_mixin.dart';
import '../helpers/location_share_helper.dart';
import '../helpers/legacy_map_marker.dart';
import '../helpers/tactical_map_payload.dart';
import '../models/app_settings.dart';
import '../models/channel.dart';
import '../models/channel_message.dart';
import '../models/contact.dart';
import '../models/wardriving.dart';
import '../helpers/blocked_node_filter.dart';
import '../services/app_settings_service.dart';
import '../services/atak_location_broadcast_service.dart';
import '../services/map_marker_service.dart';
import '../services/meshmapper_coverage_service.dart';
import '../services/meshmapper_api_service.dart';
import '../services/map_tile_cache_service.dart';
import '../services/wardriving_service.dart';
import '../widgets/wardriving_dashboard.dart';
import '../storage/atak_map_state_store.dart';
import 'chat_screen.dart';
import '../widgets/block_node_dialog.dart';
import '../widgets/connection_overflow_menu_button.dart';
import '../widgets/repeater_login_dialog.dart';
import '../widgets/room_login_dialog.dart';
import 'repeater_hub_screen.dart';
import 'line_of_sight_map_screen.dart';
import 'map_cache_screen.dart';
import 'region_index_map_screen.dart';

bool mapScreenAllowsBack({required bool hideBackButton}) => !hideBackButton;

class MapScreen extends StatefulWidget {
  final LatLng? highlightPosition;
  final String? highlightLabel;
  final double highlightZoom;
  final bool hideBackButton;

  const MapScreen({
    super.key,
    this.highlightPosition,
    this.highlightLabel,
    this.highlightZoom = 15.0,
    this.hideBackButton = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with UserMapCenterMixin {
  static const double _labelZoomThreshold = 8.5;

  final MapController _mapController = MapController();
  final MapMarkerService _markerService = MapMarkerService();
  final AtakMapStateStore _atakMapStateStore = AtakMapStateStore();
  final Set<String> _hiddenMarkerIds = {};
  Set<String> _removedMarkerIds = {};
  Set<String> _atakHiddenMarkerIds = {};
  Set<String> _atakRemovedMarkerIds = {};
  List<ChannelMessage> _tacticalMessages = [];
  int? _tacticalChannelIndex;
  bool _tacticalMessagesLoaded = false;
  int? _tacticalSyncPendingChannelIndex;
  bool _tacticalSyncPostScheduled = false;
  bool _isBuildingPathTrace = false;
  bool _hasInitializedMap = false;
  bool _emptyMapUserCenterApplied = false;
  bool _atakMapStateLoaded = false;
  final List<int> _pathTrace = [];
  final List<LatLng> _points = [];
  final List<Polyline> _polylines = [];
  bool _mapControlsExpanded = false;
  int _mapControlsTabIndex = 0;
  bool _showNodeLabels = true;
  bool _atakAutoSelectAttempted = false;
  final TextEditingController _atakCustomChannelController =
      TextEditingController();
  Timer? _coverageLoadDebounce;
  MeshMapperCoverageService? _coverageService;
  int _lastWardrivingUploadedCount = 0;
  final LayerHitNotifier<MeshMapperCoverageCell> _coverageHitNotifier =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _coverageService = context.read<MeshMapperCoverageService>();
    _loadAtakMapState();
    initUserMapCenter(mapController: _mapController, applyMove: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MeshCoreConnector>().getChannels();
        if (widget.highlightPosition != null) {
          _mapController.move(widget.highlightPosition!, widget.highlightZoom);
        }
      }
    });
  }

  @override
  void dispose() {
    _coverageLoadDebounce?.cancel();
    _coverageService?.setActive(false);
    _coverageHitNotifier.dispose();
    _atakCustomChannelController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _scheduleCoverageLoad(
    MeshMapperCoverageService coverage,
    WardrivingService wardriving,
    AppSettings settings, {
    bool fresh = false,
  }) {
    if (!coverage.isActive || !settings.wardrivingCoverageEnabled) return;
    final zone = wardriving.coverageZone;
    if (zone == null || zone.isEmpty) return;
    _coverageLoadDebounce?.cancel();
    _coverageLoadDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted || !coverage.isActive) return;
      final camera = _mapController.camera;
      final bounds = camera.visibleBounds;
      unawaited(
        coverage.loadVisible(
          zone: zone,
          north: bounds.north,
          south: bounds.south,
          east: bounds.east,
          west: bounds.west,
          zoom: camera.zoom,
          gridSize: settings.wardrivingCoverageGridSize,
          fresh: fresh,
        ),
      );
    });
  }

  List<Polygon<MeshMapperCoverageCell>> _buildMeshMapperCoveragePolygons(
    List<MeshMapperCoverageCell> cells,
    AppSettings settings,
  ) {
    final steps =
        meshMapperCoverageGridSteps[settings.wardrivingCoverageGridSize] ??
        meshMapperCoverageGridSteps[300]!;
    // intentionally fixed: coverage status colors drawn on top of a raster map tile
    Color colorForStatus(int status) => switch (status) {
      1 => Colors.green,
      2 => Colors.cyan,
      3 => Colors.orange,
      4 => Colors.purple,
      6 => Colors.red,
      _ => Colors.grey,
    };
    return cells
        .map((cell) {
          final lat = cell.latitudeIndex * steps.$1;
          final lon = cell.longitudeIndex * steps.$2;
          final color = colorForStatus(
            cell.status,
          ).withValues(alpha: settings.wardrivingCoverageOpacity);
          return Polygon(
            points: [
              LatLng(lat, lon),
              LatLng(lat + steps.$1, lon),
              LatLng(lat + steps.$1, lon + steps.$2),
              LatLng(lat, lon + steps.$2),
            ],
            color: color,
            borderColor: color.withValues(alpha: 0.8),
            borderStrokeWidth: 0.5,
            hitValue: cell,
          );
        })
        .toList(growable: false);
  }

  Marker _buildWardrivingEventMarker(
    BuildContext context,
    WardrivingMapEvent event,
    WardrivingService service,
  ) {
    // intentionally fixed: event marker colors drawn on top of a raster map tile
    final color = switch (event.type) {
      WardrivingEventType.tx => Colors.green,
      WardrivingEventType.rx => Colors.blue,
      WardrivingEventType.discovery => Colors.orange,
      WardrivingEventType.trace => Colors.purple,
    };
    return Marker(
      point: LatLng(event.latitude, event.longitude),
      width: 20,
      height: 20,
      child: GestureDetector(
        onTap: event.repeaterId == null
            ? null
            : () => _showRepeaterCoverageDetails(
                context,
                service,
                event.repeaterId!,
              ),
        child: Icon(
          event.successful ? Icons.circle : Icons.cancel,
          color: event.successful ? color : Colors.red,
          size: 14,
        ),
      ),
    );
  }

  Marker _buildMeshMapperRepeaterMarker(
    BuildContext context,
    WardrivingService service,
    MeshMapperRepeater repeater,
  ) {
    return Marker(
      point: LatLng(repeater.latitude!, repeater.longitude!),
      width: 34,
      height: 34,
      child: Tooltip(
        message: repeater.name,
        child: GestureDetector(
          onTap: () =>
              _showRepeaterCoverageDetails(context, service, repeater.targetId),
          child: const Icon(Icons.router, color: Colors.deepPurple, size: 26),
        ),
      ),
    );
  }

  void _showCoverageCellDetails(
    BuildContext context,
    WardrivingService service,
    MeshMapperCoverageCell cell,
    int gridSize,
  ) {
    _showMeshMapperPointsSheet(
      context,
      title: 'Coverage cell',
      future: service.inspectCoverageCell(cell, gridSize),
      status: cell.status,
    );
  }

  void _showRepeaterCoverageDetails(
    BuildContext context,
    WardrivingService service,
    String repeaterId,
  ) {
    _showMeshMapperPointsSheet(
      context,
      title: 'Repeater $repeaterId',
      future: service.inspectRepeaterCoverage(repeaterId),
    );
  }

  void _showMeshMapperPointsSheet(
    BuildContext context, {
    required String title,
    required Future<List<Map<String, dynamic>>> future,
    int? status,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final points = snapshot.data!;
            final counts = <String, int>{};
            final repeaters = <String>{};
            for (final point in points) {
              final type = (point['type'] ?? 'sample').toString().toUpperCase();
              counts[type] = (counts[type] ?? 0) + 1;
              final repeater = point['repeater_id'] ?? point['repeater'];
              if (repeater != null && repeater.toString().isNotEmpty) {
                repeaters.add(repeater.toString().toUpperCase());
              }
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '${context.l10n.map_coverageSamples(points.length)}'
                    '${status == null ? '' : context.l10n.map_coverageStatusSuffix(status)}',
                  ),
                  if (counts.isNotEmpty)
                    Text(
                      counts.entries
                          .map((entry) => '${entry.key} ${entry.value}')
                          .join(' · '),
                    ),
                  if (repeaters.isNotEmpty)
                    Text(
                      context.l10n.map_repeatersList(
                        repeaters.take(12).join(', '),
                      ),
                    ),
                  if (points.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(context.l10n.map_noDetailedServerData),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ({double lat, double lon})? _selfMapPosition({
    required AppSettings settings,
    required MeshCoreConnector connector,
    required AtakLocationBroadcastService broadcastService,
  }) {
    final phoneLat = broadcastService.phoneLat ?? broadcastService.broadcastLat;
    final phoneLon = broadcastService.phoneLon ?? broadcastService.broadcastLon;
    if (phoneLat != null &&
        phoneLon != null &&
        isValidMapCoordinate(phoneLat, phoneLon)) {
      return (lat: phoneLat, lon: phoneLon);
    }
    final deviceLat = connector.selfLatitude;
    final deviceLon = connector.selfLongitude;
    if (deviceLat != null &&
        deviceLon != null &&
        isValidMapCoordinate(deviceLat, deviceLon)) {
      return (lat: deviceLat, lon: deviceLon);
    }
    return null;
  }

  Future<void> _loadAtakMapState() async {
    final removedMarkerIds = await _markerService.loadRemovedIds();
    final hidden = await _atakMapStateStore.loadHiddenIds();
    final removed = await _atakMapStateStore.loadRemovedIds();
    final sharedHidden = await _atakMapStateStore.loadSharedHiddenIds();
    if (!mounted) return;
    setState(() {
      _removedMarkerIds = removedMarkerIds;
      _atakHiddenMarkerIds = hidden;
      _atakRemovedMarkerIds = removed;
      _hiddenMarkerIds
        ..clear()
        ..addAll(sharedHidden);
      _atakMapStateLoaded = true;
    });
  }

  Future<void> _reloadTacticalMessages(
    MeshCoreConnector connector,
    Channel channel,
  ) async {
    final messages = await connector.loadTacticalChannelMessages(channel.index);
    if (!mounted) return;
    setState(() {
      _tacticalMessages = messages;
      _tacticalChannelIndex = channel.index;
      _tacticalMessagesLoaded = true;
    });
  }

  void _mergeLiveTacticalMessages(
    MeshCoreConnector connector,
    Channel channel,
  ) {
    final liveMessages = connector.getChannelMessages(channel);
    final knownIds = _tacticalMessages.map((m) => m.messageId).toSet();
    var changed = false;
    final merged = List<ChannelMessage>.from(_tacticalMessages);

    for (final message in liveMessages) {
      if (TacticalMapPayload.tryParse(message.text) == null) continue;
      if (knownIds.contains(message.messageId)) continue;
      merged.add(message);
      knownIds.add(message.messageId);
      changed = true;
    }

    if (changed) {
      setState(() => _tacticalMessages = merged);
    }
  }

  void _scheduleTacticalMessageSync(
    MeshCoreConnector connector,
    Channel? channel,
  ) {
    _tacticalSyncPendingChannelIndex = channel?.index;
    if (_tacticalSyncPostScheduled) return;
    _tacticalSyncPostScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _tacticalSyncPostScheduled = false;
      if (!mounted) return;
      final pendingIndex = _tacticalSyncPendingChannelIndex;
      if (pendingIndex == null) {
        if (_tacticalChannelIndex != null) {
          setState(() {
            _tacticalMessages = [];
            _tacticalChannelIndex = null;
            _tacticalMessagesLoaded = true;
          });
        }
        return;
      }

      Channel? resolvedChannel;
      for (final c in connector.channels) {
        if (c.index == pendingIndex) {
          resolvedChannel = c;
          break;
        }
      }
      if (resolvedChannel == null) return;

      if (_tacticalChannelIndex != resolvedChannel.index ||
          !_tacticalMessagesLoaded) {
        await _reloadTacticalMessages(connector, resolvedChannel);
        return;
      }

      _mergeLiveTacticalMessages(connector, resolvedChannel);
    });
  }

  List<ChannelMessage> _tacticalMessagesForChannel(
    MeshCoreConnector connector,
    Channel channel,
  ) {
    if (_tacticalMessagesLoaded && _tacticalChannelIndex == channel.index) {
      return _tacticalMessages;
    }

    return connector
        .getChannelMessages(channel)
        .where((message) => TacticalMapPayload.tryParse(message.text) != null)
        .toList();
  }

  Future<void> _hideAtakMarker(String markerId) async {
    setState(() {
      _atakHiddenMarkerIds.add(markerId);
    });
    await _atakMapStateStore.saveHiddenIds(_atakHiddenMarkerIds);
  }

  Future<void> _removeAtakMarker(String markerId) async {
    setState(() {
      _atakHiddenMarkerIds.add(markerId);
      _atakRemovedMarkerIds.add(markerId);
    });
    await _atakMapStateStore.saveHiddenIds(_atakHiddenMarkerIds);
    await _atakMapStateStore.saveRemovedIds(_atakRemovedMarkerIds);
  }

  Future<void> _showRemoveMarkerDialog(
    String markerId,
    String markerName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.map_removeMarker),
        content: Text(context.l10n.map_removeMarkerConfirm(markerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.common_remove),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _removedMarkerIds.add(markerId);
      });
      await _markerService.saveRemovedIds(_removedMarkerIds);
    }
  }

  Future<void> _showRemoveAtakMarkerDialog(
    String markerId,
    String markerName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.map_removeMarker),
        content: Text(context.l10n.map_removeMarkerConfirm(markerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.common_remove),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _removeAtakMarker(markerId);
    }
  }

  Future<void> _showRemoveSharedMarkerDialog(
    String markerId,
    String markerName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.map_removeMarker),
        content: Text(context.l10n.map_removeMarkerConfirm(markerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.common_remove),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _hiddenMarkerIds.add(markerId);
        _removedMarkerIds.add(markerId);
      });
      await _markerService.saveRemovedIds(_removedMarkerIds);
    }
  }

  double _standardDeviation(List<double> values) {
    if (values.length <= 1) {
      return 0.0;
    }

    final mean = values.reduce((a, b) => a + b) / values.length;

    double sumSquaredDiff = 0.0;
    for (final value in values) {
      final diff = value - mean;
      sumSquaredDiff += diff * diff;
    }

    // Sample standard deviation (n-1) — most appropriate here
    final variance = sumSquaredDiff / (values.length - 1);

    return sqrt(variance);
  }

  // Calculate zoom level based on the spread of points (std deviation in degrees)
  double _zoomFromStdDev(double latStdDev, double lonStdDev) {
    final maxSpread = max(latStdDev, lonStdDev);
    if (maxSpread <= 0) return 13.0;
    // Approximate: each zoom level halves the visible area
    // ~0.01 degrees spread -> zoom 13, ~0.1 -> zoom 10, ~1.0 -> zoom 7
    final zoom = 10.0 - log(maxSpread * 10 + 1) / ln10 * 3;
    return zoom.clamp(4.0, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MeshCoreConnector, AppSettingsService>(
      builder: (context, connector, settingsService, child) {
        final broadcastService = context.watch<AtakLocationBroadcastService>();
        final wardrivingService = context.watch<WardrivingService>();
        final coverageService = context.watch<MeshMapperCoverageService>();
        final tileCache = context.read<MapTileCacheService>();
        final settings = settingsService.settings;
        // Coverage is a map layer, not a panel tab: keep it alive while a
        // session runs, including when the controls are collapsed or ATAK is
        // selected.
        final meshMapperModeActive =
            wardrivingService.isRunning || _mapControlsTabIndex == 1;
        final uploadedCount = wardrivingService.stats.uploadedCount;
        if (meshMapperModeActive &&
            uploadedCount > _lastWardrivingUploadedCount) {
          _lastWardrivingUploadedCount = uploadedCount;
          Timer(const Duration(seconds: 7), () {
            if (!mounted || !coverageService.isActive) return;
            coverageService.invalidate();
            _scheduleCoverageLoad(
              coverageService,
              wardrivingService,
              settings,
              fresh: true,
            );
          });
        }
        if (coverageService.isActive != meshMapperModeActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            coverageService.setActive(meshMapperModeActive);
            if (meshMapperModeActive) {
              _scheduleCoverageLoad(
                coverageService,
                wardrivingService,
                settings,
              );
            }
          });
        }
        if (meshMapperModeActive &&
            coverageService.isActive &&
            wardrivingService.coverageZone == null &&
            coverageService.cells.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) coverageService.invalidate();
          });
        }
        if (meshMapperModeActive &&
            coverageService.isActive &&
            settings.wardrivingCoverageEnabled &&
            wardrivingService.coverageZone != null &&
            coverageService.cells.isEmpty &&
            !coverageService.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _scheduleCoverageLoad(coverageService, wardrivingService, settings);
          });
        }
        final selfPosition = _selfMapPosition(
          settings: settings,
          connector: connector,
          broadcastService: broadcastService,
        );
        final contacts = connector.visibleContacts;
        final highlightPosition = widget.highlightPosition;
        _maybeAutoSelectAtakChannel(connector, settingsService);
        final atakChannel = resolveAtakChannel(
          connector.channels,
          index: settings.atakChannelIndex,
          name: settings.atakChannelName,
        );
        final atakChannelLabel = atakChannel == null
            ? ''
            : (atakChannel.name.isEmpty
                  ? 'Channel ${atakChannel.index}'
                  : atakChannel.name);
        _scheduleTacticalMessageSync(connector, atakChannel);
        final atakMessages = atakChannel != null
            ? _tacticalMessagesForChannel(connector, atakChannel)
            : <ChannelMessage>[];
        final sharedMarkers = settings.mapShowMarkers
            ? _collectSharedMarkers(
                    connector,
                    excludeChannelIndex: atakChannel?.index,
                  )
                  .where(
                    (marker) =>
                        !_hiddenMarkerIds.contains(marker.id) &&
                        !_removedMarkerIds.contains(marker.id),
                  )
                  .toList()
            : <_SharedMarker>[];
        final collectedParticipants =
            settings.mapShowMarkers && atakChannel != null
            ? collectAtakParticipants(
                atakMessages,
                channelLabel: atakChannelLabel,
                channelIndex: atakChannel.index,
              )
            : <AtakParticipant>[];
        final collectedPois = settings.mapShowMarkers && atakChannel != null
            ? collectAtakPois(
                atakMessages,
                channelLabel: atakChannelLabel,
                channelIndex: atakChannel.index,
              )
            : <AtakPoi>[];
        final atakParticipants = _atakMapStateLoaded
            ? filterDismissedAtakMarkers(
                collectedParticipants,
                _atakHiddenMarkerIds,
                _atakRemovedMarkerIds,
                idFor: (participant) => participant.id,
              )
            : const <AtakParticipant>[];
        final atakPois = _atakMapStateLoaded
            ? filterDismissedAtakMarkers(
                collectedPois,
                _atakHiddenMarkerIds,
                _atakRemovedMarkerIds,
                idFor: (poi) => poi.id,
              )
            : const <AtakPoi>[];

        // Filter by time
        final now = DateTime.now();
        final filteredByTime = settings.mapTimeFilterHours == 0
            ? contacts
            : contacts.where((c) {
                final hoursSinceLastSeen = now.difference(c.lastSeen).inHours;
                return hoursSinceLastSeen <= settings.mapTimeFilterHours;
              }).toList();

        // Filter by key prefix
        final keyPrefix = settings.mapKeyPrefix.trim();
        final filteredByKeyPrefix =
            (settings.mapKeyPrefixEnabled && keyPrefix.isNotEmpty)
            ? filteredByTime.where((c) {
                return c.publicKeyHex.toLowerCase().startsWith(
                  keyPrefix.toLowerCase(),
                );
              }).toList()
            : filteredByTime;

        // Filter by location
        final contactsWithLocation = filteredByKeyPrefix
            .where((c) => c.hasLocation)
            .toList();

        _polylines.clear();
        _polylines.addAll(
          _points.length > 1
              ? [
                  Polyline(
                    points: _points,
                    strokeWidth: 4,
                    color: Colors.blueAccent,
                  ),
                ]
              : <Polyline>[],
        );

        // Calculate center and zoom of all nodes, or default to user location
        LatLng center = userMapCenterOrFallback;
        double initialZoom = userMapZoomOrFallback;
        if (selfPosition != null) {
          center = LatLng(selfPosition.lat, selfPosition.lon);
          initialZoom = kUserLocationZoom;
        }
        final hasMapContent =
            contactsWithLocation.isNotEmpty ||
            sharedMarkers.isNotEmpty ||
            atakParticipants.isNotEmpty ||
            atakPois.isNotEmpty ||
            highlightPosition != null;
        if (contactsWithLocation.isNotEmpty ||
            sharedMarkers.isNotEmpty ||
            atakParticipants.isNotEmpty ||
            atakPois.isNotEmpty) {
          final allPoints = [
            ...contactsWithLocation.map(
              (c) => LatLng(c.latitude!, c.longitude!),
            ),
            ...sharedMarkers.map((m) => m.position),
            ...atakParticipants.map((p) => LatLng(p.lat, p.lon)),
            ...atakPois.map((p) => LatLng(p.lat, p.lon)),
          ];
          if (allPoints.length >= 3) {
            final latValues = allPoints.map((p) => p.latitude).toList();
            final lonValues = allPoints.map((p) => p.longitude).toList();

            final meanLat =
                latValues.reduce((a, b) => a + b) / latValues.length;
            final meanLon =
                lonValues.reduce((a, b) => a + b) / lonValues.length;
            final latStdDev = _standardDeviation(latValues);
            final lonStdDev = _standardDeviation(lonValues);

            final filteredPoints = allPoints
                .where(
                  (p) =>
                      (p.latitude - meanLat).abs() <= latStdDev * 2 &&
                      (p.longitude - meanLon).abs() <= lonStdDev * 2,
                )
                .toList();

            if (filteredPoints.isNotEmpty) {
              final filteredLatValues = filteredPoints
                  .map((p) => p.latitude)
                  .toList();
              final filteredLonValues = filteredPoints
                  .map((p) => p.longitude)
                  .toList();
              final avgLat = filteredLatValues.reduce((a, b) => a + b);
              final avgLon = filteredLonValues.reduce((a, b) => a + b);
              center = LatLng(
                avgLat / filteredPoints.length,
                avgLon / filteredPoints.length,
              );
              // Use std deviation of filtered points for zoom
              final filteredLatStdDev = _standardDeviation(filteredLatValues);
              final filteredLonStdDev = _standardDeviation(filteredLonValues);
              initialZoom = _zoomFromStdDev(
                filteredLatStdDev,
                filteredLonStdDev,
              );
            } else {
              center = LatLng(meanLat, meanLon);
              initialZoom = _zoomFromStdDev(latStdDev, lonStdDev);
            }
          } else {
            double avgLat = 0.0;
            double avgLon = 0.0;
            for (final point in allPoints) {
              avgLat += point.latitude;
              avgLon += point.longitude;
            }
            center = LatLng(
              avgLat / allPoints.length,
              avgLon / allPoints.length,
            );
            initialZoom = 12.0;
          }
        }
        if (highlightPosition != null) {
          center = highlightPosition;
          initialZoom = widget.highlightZoom;
        }

        // Re center map after ATAK map state has loaded
        if (!_hasInitializedMap && _atakMapStateLoaded) {
          _hasInitializedMap = true;
          _showNodeLabels = initialZoom >= _labelZoomThreshold;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _mapController.move(center, initialZoom);
            }
          });
        } else if (_hasInitializedMap &&
            !hasMapContent &&
            highlightPosition == null &&
            center != kFallbackMapCenter &&
            !_emptyMapUserCenterApplied) {
          _emptyMapUserCenterApplied = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _mapController.move(center, initialZoom);
            }
          });
        }

        final allowBack = mapScreenAllowsBack(
          hideBackButton: widget.hideBackButton,
        );

        return PopScope(
          canPop: allowBack,
          child: Scaffold(
            appBar: AppBar(
              title: AppBarTitle(context.l10n.map_title),
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading:
                  mapScreenAllowsBack(hideBackButton: widget.hideBackButton)
                  ? const BackButton()
                  : null,
              actions: [
                if (!_isBuildingPathTrace)
                  IconButton(
                    icon: const Icon(Icons.radar),
                    onPressed: () => _startPath(),
                    tooltip: context.l10n.contacts_pathTrace,
                  ),
                if (!_isBuildingPathTrace)
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      final candidates = <LineOfSightEndpoint>[];
                      if (selfPosition != null) {
                        candidates.add(
                          LineOfSightEndpoint(
                            label: context.l10n.pathTrace_you,
                            point: LatLng(selfPosition.lat, selfPosition.lon),
                            color: Colors.teal,
                            icon: Icons.person_pin_circle,
                          ),
                        );
                      }
                      for (final c in contactsWithLocation) {
                        candidates.add(
                          LineOfSightEndpoint(
                            label: c.name,
                            point: LatLng(c.latitude!, c.longitude!),
                            color: _getNodeColor(c.type),
                            icon: _getNodeIcon(c.type),
                          ),
                        );
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LineOfSightMapScreen(
                            title: context.l10n.map_losScreenTitle,
                            candidates: candidates,
                          ),
                        ),
                      );
                    },
                    tooltip: context.l10n.map_lineOfSight,
                  ),
                if (!_isBuildingPathTrace)
                  IconButton(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapCacheScreen(),
                        ),
                      );
                    },
                    tooltip: context.l10n.mapCache_title,
                  ),
                if (!_isBuildingPathTrace)
                  IconButton(
                    icon: const Icon(Icons.public_outlined),
                    tooltip: 'Region boundaries',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegionIndexMapScreen(),
                      ),
                    ),
                  ),
                const ConnectionOverflowMenuButton(),
              ],
            ),
            body: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: initialZoom,
                    minZoom: 2.0,
                    maxZoom: 18.0,
                    interactionOptions: InteractionOptions(
                      flags: ~InteractiveFlag.rotate,
                    ),
                    onLongPress: (_, latLng) {
                      _showMarkOnMapSheet(
                        context: context,
                        connector: connector,
                        settings: settings,
                        position: latLng,
                      );
                    },
                    onPositionChanged: (camera, hasGesture) {
                      final shouldShow = camera.zoom >= _labelZoomThreshold;
                      if (shouldShow != _showNodeLabels && mounted) {
                        setState(() {
                          _showNodeLabels = shouldShow;
                        });
                      }
                      if (meshMapperModeActive) {
                        _scheduleCoverageLoad(
                          coverageService,
                          wardrivingService,
                          settings,
                        );
                      }
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
                    if (meshMapperModeActive &&
                        settings.wardrivingCoverageEnabled &&
                        coverageService.cells.isNotEmpty)
                      GestureDetector(
                        behavior: HitTestBehavior.deferToChild,
                        onTap: () {
                          final hit = _coverageHitNotifier.value;
                          if (hit == null || hit.hitValues.isEmpty) return;
                          _showCoverageCellDetails(
                            context,
                            wardrivingService,
                            hit.hitValues.first,
                            settings.wardrivingCoverageGridSize,
                          );
                        },
                        child: PolygonLayer<MeshMapperCoverageCell>(
                          hitNotifier: _coverageHitNotifier,
                          polygons: _buildMeshMapperCoveragePolygons(
                            coverageService.cells,
                            settings,
                          ),
                        ),
                      ),
                    if (meshMapperModeActive &&
                        wardrivingService.mapEvents.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: wardrivingService.mapEvents
                                .map(
                                  (event) =>
                                      LatLng(event.latitude, event.longitude),
                                )
                                .toList(growable: false),
                            color: Colors.orange.withValues(alpha: 0.75),
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                    if (_polylines.isNotEmpty && _isBuildingPathTrace)
                      PolylineLayer(polylines: _polylines),
                    MarkerLayer(
                      markers: [
                        if (highlightPosition != null)
                          Marker(
                            point: highlightPosition,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on_outlined,
                              color: Colors.red[600],
                              size: 34,
                            ),
                          ),
                        ..._buildMarkers(
                          contactsWithLocation,
                          settings,
                          showLabels: _showNodeLabels,
                        ),
                        ...sharedMarkers.map(_buildSharedMarker),
                        ...atakPois.map(_buildAtakPoiMarker),
                        ...atakParticipants.map(_buildAtakParticipantMarker),
                        if (meshMapperModeActive)
                          ...wardrivingService.mapEvents.map(
                            (event) => _buildWardrivingEventMarker(
                              context,
                              event,
                              wardrivingService,
                            ),
                          ),
                        if (meshMapperModeActive)
                          ...wardrivingService.repeaters
                              .where(
                                (repeater) =>
                                    repeater.latitude != null &&
                                    repeater.longitude != null &&
                                    repeater.latitude!.isFinite &&
                                    repeater.longitude!.isFinite,
                              )
                              .map(
                                (repeater) => _buildMeshMapperRepeaterMarker(
                                  context,
                                  wardrivingService,
                                  repeater,
                                ),
                              ),
                        if (selfPosition != null)
                          Marker(
                            point: LatLng(selfPosition.lat, selfPosition.lon),
                            width: 40,
                            height: 40,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.person_pin_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        if (_showNodeLabels && selfPosition != null)
                          _buildNodeLabelMarker(
                            point: LatLng(selfPosition.lat, selfPosition.lon),
                            label: context.l10n.pathTrace_you,
                          ),
                      ],
                    ),
                  ],
                ),
                if (!_isBuildingPathTrace)
                  _buildMapControlsPanel(
                    context,
                    connector,
                    settingsService,
                    wardrivingService,
                    contactsWithLocation,
                    settings,
                    sharedMarkers.length,
                    atakParticipants.length,
                    atakPois.length,
                    atakChannel != null,
                  ),
                if (_isBuildingPathTrace) _buildPathTraceOverlay(),
                if (meshMapperModeActive && coverageService.error != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Material(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(coverageService.error!),
                      ),
                    ),
                  ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showFilterDialog(context, settingsService),
              tooltip: context.l10n.map_filterNodes,
              child: const Icon(Icons.filter_list),
            ),
          ),
        );
      },
    );
  }

  List<Marker> _buildMarkers(
    List<Contact> contacts,
    settings, {
    required bool showLabels,
  }) {
    final markers = <Marker>[];

    for (final contact in contacts) {
      if (!contact.hasLocation) continue;

      // Apply node type filters
      if (contact.type == advTypeRepeater &&
          (!settings.mapShowRepeaters && !_isBuildingPathTrace)) {
        continue;
      }
      if (contact.type == advTypeChat &&
          !(settings.mapShowChatNodes && !_isBuildingPathTrace)) {
        continue;
      }
      if (contact.type != advTypeChat &&
          contact.type != advTypeRepeater &&
          (!settings.mapShowOtherNodes && !_isBuildingPathTrace)) {
        continue;
      }

      final marker = Marker(
        point: LatLng(contact.latitude!, contact.longitude!),
        width: 35,
        height: 35,
        child: GestureDetector(
          onLongPress: () {
            switch (nodeMarkerLongPress(
              isBuildingPathTrace: _isBuildingPathTrace,
              blockingEnabled: settings.experimentalNodeBlockingEnabled,
            )) {
              case NodeMarkerLongPress.none:
                break;
              case NodeMarkerLongPress.confirmBlock:
                confirmBlockNode(context, contact);
              case NodeMarkerLongPress.removeMarker:
                _showRemoveMarkerDialog(
                  contact.publicKeyHex,
                  contact.displayName,
                );
            }
          },
          onTap: () => _isBuildingPathTrace
              ? _addToPath(context, contact)
              : _showNodeInfo(context, contact),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getNodeColor(contact.type),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getNodeIcon(contact.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      );

      markers.add(marker);
      if (showLabels) {
        markers.add(
          _buildNodeLabelMarker(
            point: LatLng(contact.latitude!, contact.longitude!),
            label: contact.displayName,
          ),
        );
      }
    }

    return markers;
  }

  Marker _buildNodeLabelMarker({required LatLng point, required String label}) {
    return Marker(
      point: point,
      width: 120,
      height: 24,
      alignment: Alignment.topCenter,
      child: IgnorePointer(
        child: Transform.translate(
          offset: const Offset(0, -20),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // intentionally fixed: node marker colors drawn on top of a raster map tile
  Color _getNodeColor(int type) {
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

  IconData _getNodeIcon(int type) {
    switch (type) {
      case advTypeChat:
        return Icons.person;
      case advTypeRepeater:
        return Icons.router;
      case advTypeRoom:
        return Icons.meeting_room;
      case advTypeSensor:
        return Icons.sensors;
      default:
        return Icons.device_unknown;
    }
  }

  int _visibleNodeCount(List<Contact> contactsWithLocation, settings) {
    var nodeCount = 0;
    for (final contact in contactsWithLocation) {
      if (contact.type == advTypeRepeater && !settings.mapShowRepeaters) {
        continue;
      }
      if (contact.type == advTypeChat && !settings.mapShowChatNodes) continue;
      if (contact.type != advTypeChat &&
          contact.type != advTypeRepeater &&
          !settings.mapShowOtherNodes) {
        continue;
      }
      nodeCount++;
    }
    return nodeCount;
  }

  Widget _buildMapControlsPanel(
    BuildContext context,
    MeshCoreConnector connector,
    AppSettingsService settingsService,
    WardrivingService wardrivingService,
    List<Contact> contactsWithLocation,
    settings,
    int markerCount,
    int atakParticipantCount,
    int atakPoiCount,
    bool hasAtakChannel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final nodeCount = _visibleNodeCount(contactsWithLocation, settings);
    final atakSettings = settingsService.settings;
    final selectedAtakChannel = resolveAtakChannel(
      connector.channels,
      index: atakSettings.atakChannelIndex,
      name: atakSettings.atakChannelName,
    );
    final isAtakBroadcasting =
        atakSettings.atakLocationBroadcastEnabled &&
        selectedAtakChannel != null;
    final isWardrivingRunning = wardrivingService.isRunning;

    final panel = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  const Icon(Icons.layers_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.map_controls,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildStatusChip(
                              label: isAtakBroadcasting
                                  ? 'ATAK on'
                                  : 'ATAK off',
                              color: isAtakBroadcasting
                                  ? colorScheme.tertiary
                                  : colorScheme.outlineVariant,
                            ),
                            _buildStatusChip(
                              label: isWardrivingRunning
                                  ? 'Wardriving'
                                  : 'Wardrive off',
                              color: isWardrivingRunning
                                  ? colorScheme.tertiary
                                  : colorScheme.outlineVariant,
                            ),
                            _buildStatusChip(
                              label: context.l10n.map_nodesCount(nodeCount),
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _mapControlsExpanded = false),
                    icon: const Icon(Icons.close),
                    tooltip: context.l10n.map_closeControls,
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('ATAK')),
                        ButtonSegment(value: 1, label: Text('Wardrive')),
                      ],
                      selected: {_mapControlsTabIndex},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _mapControlsTabIndex = selection.first;
                        });
                      },
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: switch (_mapControlsTabIndex) {
                        0 => _buildAtakTabContent(
                          context,
                          connector,
                          settingsService,
                        ),
                        1 => WardrivingDashboard(
                          connector: connector,
                          settingsService: settingsService,
                          service: wardrivingService,
                          onOpenOfflineSessions: () =>
                              _showOfflineWardriveSessions(
                                context,
                                wardrivingService,
                              ),
                          onRecenter: () {
                            final location = wardrivingService.currentLocation;
                            if (location != null) {
                              _mapController.move(
                                LatLng(location.latitude, location.longitude),
                                15,
                              );
                            }
                          },
                        ),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ],
              ),
              crossFadeState: _mapControlsExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 700;
    final panelWidth = wide ? 360.0 : min(360.0, max(0.0, size.width - 24));
    final top = wide ? 16.0 : 8.0;
    final bottom = wide ? 16.0 : 8.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_mapControlsExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _mapControlsExpanded = false),
              child: ColoredBox(
                color: colorScheme.onSurface.withValues(alpha: 0.16),
              ),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          left: _mapControlsExpanded ? (wide ? 16 : 8) : -panelWidth - 24,
          top: top,
          bottom: bottom,
          width: panelWidth,
          child: Material(
            elevation: _mapControlsExpanded ? 8 : 0,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: panel,
          ),
        ),
        if (!_mapControlsExpanded)
          Positioned(
            left: wide ? 16 : 8,
            top: top,
            child: FloatingActionButton.small(
              heroTag: 'map-controls',
              onPressed: () => setState(() => _mapControlsExpanded = true),
              tooltip: context.l10n.map_openControls,
              child: const Icon(Icons.tune),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAtakTabContent(
    BuildContext context,
    MeshCoreConnector connector,
    AppSettingsService settingsService,
  ) {
    final settings = settingsService.settings;
    final selectedChannel = resolveAtakChannel(
      connector.channels,
      index: settings.atakChannelIndex,
      name: settings.atakChannelName,
    );
    final atakChannel = findAtakChannel(connector.channels);
    final isAtakSelected =
        atakChannel != null && selectedChannel?.index == atakChannel.index;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!connector.isConnected)
          Text(
            context.l10n.map_atakConnectToJoin,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          )
        else ...[
          if (atakChannel != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(
                isAtakSelected ? Icons.check_circle : Icons.tag,
                size: 20,
                color: isAtakSelected ? colorScheme.tertiary : null,
              ),
              title: Text(atakChannelDisplayName),
              trailing: isAtakSelected
                  ? null
                  : const Icon(Icons.chevron_right, size: 20),
              onTap: isAtakSelected
                  ? null
                  : () => settingsService.setAtakChannel(
                      index: atakChannel.index,
                      name: atakChannel.name,
                    ),
            )
          else
            FilledButton.icon(
              onPressed: connector.isLoadingChannels
                  ? null
                  : () => _joinAtakChannel(context, connector, settingsService),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.map_atakJoinChannel),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _atakCustomChannelController,
            decoration: InputDecoration(
              labelText: context.l10n.map_atakCustomChannel,
              hintText: context.l10n.map_atakCustomChannelHint,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) =>
                _joinCustomAtakChannel(context, connector, settingsService),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: connector.isLoadingChannels
                ? null
                : () => _joinCustomAtakChannel(
                    context,
                    connector,
                    settingsService,
                  ),
            child: Text(context.l10n.map_atakUseCustomChannel),
          ),
          if (selectedChannel != null) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => settingsService.clearAtakChannel(),
              child: Text(context.l10n.map_atakClearSelection),
            ),
          ],
          const Divider(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.map_atakBroadcastEnabled),
            subtitle: Text(context.l10n.map_atakBroadcastEnabledSubtitle),
            value: settings.atakLocationBroadcastEnabled,
            onChanged: selectedChannel != null && connector.isConnected
                ? (value) async {
                    if (value) {
                      final granted = await ensureAtakLocationPermission();
                      if (!context.mounted) return;
                      if (!granted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n.map_atakLocationPermissionDenied,
                            ),
                          ),
                        );
                        return;
                      }
                    }
                    await settingsService.setAtakLocationBroadcastEnabled(
                      value,
                    );
                  }
                : null,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.tune, size: 20),
            title: Text(context.l10n.map_atakAdvancedSettings),
            subtitle: Text(
              '${settings.atakMovementDistanceMeters.toStringAsFixed(0)} m, '
              '${settings.atakMinSendIntervalSec} s',
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () =>
                _showAtakBroadcastSettingsDialog(context, settingsService),
          ),
        ],
      ],
    );
  }

  Future<void> _showOfflineWardriveSessions(
    BuildContext context,
    WardrivingService service,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final sessions = service.offlineSessions;
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.65,
              child: Column(
                children: [
                  ListTile(
                    title: Text(context.l10n.map_offlineWardriveSessions),
                    subtitle: Text(
                      context.l10n.map_offlineWardriveSessionsSubtitle,
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: sessions.isEmpty
                        ? Center(
                            child: Text(context.l10n.map_noOfflineSessions),
                          )
                        : ListView.builder(
                            itemCount: sessions.length,
                            itemBuilder: (context, index) {
                              final session = sessions[index];
                              return ListTile(
                                leading: Icon(
                                  session.uploaded
                                      ? Icons.cloud_done_outlined
                                      : Icons.cloud_off_outlined,
                                ),
                                title: Text(
                                  '${session.samples.length} sample(s)',
                                ),
                                subtitle: Text(
                                  '${session.createdAt.toLocal()}'
                                  '${session.uploaded ? context.l10n.map_sessionUploadedSuffix : ''}',
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (action) async {
                                    if (action == 'export') {
                                      final data = service.exportOfflineSession(
                                        session.id,
                                      );
                                      if (data != null) {
                                        await Clipboard.setData(
                                          ClipboardData(text: data),
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                context
                                                    .l10n
                                                    .map_sessionJsonCopied,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    } else if (action == 'upload') {
                                      final uploaded = await service
                                          .uploadOfflineSession(session.id);
                                      if (context.mounted) {
                                        setSheetState(() {});
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              uploaded
                                                  ? 'Offline session uploaded'
                                                  : service.statusMessage ??
                                                        'Upload failed',
                                            ),
                                          ),
                                        );
                                      }
                                    } else if (action == 'delete') {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: Text(
                                            context.l10n.map_deleteSessionTitle,
                                          ),
                                          content: Text(
                                            context.l10n.map_deleteSessionBody(
                                              session.samples.length,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                dialogContext,
                                                false,
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.pop(
                                                dialogContext,
                                                true,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await service.deleteOfflineSession(
                                          session.id,
                                        );
                                        if (context.mounted) {
                                          setSheetState(() {});
                                        }
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'export',
                                      child: Text(context.l10n.map_copyJson),
                                    ),
                                    if (!session.uploaded)
                                      PopupMenuItem(
                                        value: 'upload',
                                        child: Text(context.l10n.map_uploadNow),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
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

  void _maybeAutoSelectAtakChannel(
    MeshCoreConnector connector,
    AppSettingsService settingsService,
  ) {
    if (_atakAutoSelectAttempted || !connector.isConnected) return;
    final settings = settingsService.settings;
    if (settings.atakChannelIndex != null) return;

    final atak = findAtakChannel(connector.channels);
    if (atak == null) return;

    _atakAutoSelectAttempted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      settingsService.setAtakChannel(index: atak.index, name: atak.name);
    });
  }

  Future<void> _selectAtakChannel(
    BuildContext context,
    AppSettingsService settingsService,
    Channel channel,
  ) async {
    await settingsService.setAtakChannel(
      index: channel.index,
      name: channel.name,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.map_atakChannelJoined(channel.name))),
    );
  }

  Future<void> _joinAtakChannel(
    BuildContext context,
    MeshCoreConnector connector,
    AppSettingsService settingsService,
  ) async {
    final channel = await joinAtakChannel(connector);
    if (!context.mounted) return;
    if (channel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.map_atakConnectToJoin)),
      );
      return;
    }
    await _selectAtakChannel(context, settingsService, channel);
  }

  Future<void> _joinCustomAtakChannel(
    BuildContext context,
    MeshCoreConnector connector,
    AppSettingsService settingsService,
  ) async {
    final input = _atakCustomChannelController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.map_atakEnterChannelName)),
      );
      return;
    }

    final channel = await joinHashtagChannel(connector, input);
    if (!context.mounted) return;
    if (channel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.map_atakConnectToJoin)),
      );
      return;
    }
    if (!isAtakEligibleChannel(channel)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.map_atakChannelNotEligible)),
      );
      return;
    }

    await _selectAtakChannel(context, settingsService, channel);
  }

  void _showAtakBroadcastSettingsDialog(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    final settings = settingsService.settings;
    final movementController = TextEditingController(
      text: settings.atakMovementDistanceMeters.toStringAsFixed(0),
    );
    final intervalController = TextEditingController(
      text: settings.atakMinSendIntervalSec.toString(),
    );
    var syncNodeAdvert = settings.atakSyncNodeAdvertLocation;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.map_atakAdvancedSettings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: movementController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.map_atakMovementMeters,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: intervalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.map_atakMinIntervalSec,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.map_atakSyncNodeAdvert),
                subtitle: Text(context.l10n.map_atakSyncNodeAdvertSubtitle),
                value: syncNodeAdvert,
                onChanged: (value) => setState(() => syncNodeAdvert = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () async {
                final movement = double.tryParse(
                  movementController.text.trim(),
                );
                final interval = int.tryParse(intervalController.text.trim());
                if (movement == null || movement <= 0) {
                  return;
                }
                if (interval == null || interval < 60 || interval >= 86400) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.l10n.settings_locationIntervalInvalid,
                      ),
                    ),
                  );
                  return;
                }
                await settingsService.setAtakMovementDistanceMeters(movement);
                await settingsService.setAtakMinSendIntervalSec(interval);
                await settingsService.setAtakSyncNodeAdvertLocation(
                  syncNodeAdvert,
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(context.l10n.common_save),
            ),
          ],
        ),
      ),
    );
  }

  List<_SharedMarker> _collectSharedMarkers(
    MeshCoreConnector connector, {
    int? excludeChannelIndex,
  }) {
    final markers = <_SharedMarker>[];
    final selfName = connector.selfName ?? 'Me';

    for (final contact in connector.visibleContacts) {
      final messages = connector.getMessages(contact);
      for (final message in messages) {
        final legacy = LegacyMapMarker.tryParse(message.text);
        if (legacy != null) {
          final fromName = message.isOutgoing ? selfName : contact.displayName;
          markers.add(
            _sharedMarkerFromLegacy(
              legacy: legacy,
              sourceId: contact.publicKeyHex,
              timestamp: message.timestamp,
              text: message.text,
              fromName: fromName,
              sourceLabel: contact.displayName,
              isChannel: false,
              isPublicChannel: false,
            ),
          );
          continue;
        }

        final tactical = TacticalMapPayload.tryParse(message.text);
        if (tactical is TacticalPoiMarker) {
          final fromName = message.isOutgoing ? selfName : contact.displayName;
          markers.add(
            _sharedMarkerFromTacticalPoi(
              poi: tactical,
              sourceId: contact.publicKeyHex,
              timestamp: message.timestamp,
              text: message.text,
              fromName: fromName,
              sourceLabel: contact.displayName,
              isChannel: false,
              isPublicChannel: false,
            ),
          );
        }
      }
    }

    for (final channel in connector.channels.where((c) => !c.isEmpty)) {
      if (channel.index == excludeChannelIndex) continue;
      final isPublic = _isPublicChannel(channel);
      final messages = connector.getChannelMessages(channel);
      for (final message in messages) {
        final legacy = LegacyMapMarker.tryParse(message.text);
        if (legacy != null) {
          markers.add(
            _sharedMarkerFromLegacy(
              legacy: legacy,
              sourceId: 'channel:${channel.index}',
              timestamp: message.timestamp,
              text: message.text,
              fromName: message.senderName,
              sourceLabel: channel.name.isEmpty
                  ? 'Channel ${channel.index}'
                  : channel.name,
              isChannel: true,
              isPublicChannel: isPublic,
            ),
          );
          continue;
        }

        final tactical = TacticalMapPayload.tryParse(message.text);
        if (tactical is TacticalPoiMarker) {
          markers.add(
            _sharedMarkerFromTacticalPoi(
              poi: tactical,
              sourceId: 'channel:${channel.index}',
              timestamp: message.timestamp,
              text: message.text,
              fromName: message.senderName,
              sourceLabel: channel.name.isEmpty
                  ? 'Channel ${channel.index}'
                  : channel.name,
              isChannel: true,
              isPublicChannel: isPublic,
            ),
          );
        }
      }
    }

    return markers;
  }

  _SharedMarker _sharedMarkerFromLegacy({
    required LegacyMapMarker legacy,
    required String sourceId,
    required DateTime timestamp,
    required String text,
    required String fromName,
    required String sourceLabel,
    required bool isChannel,
    required bool isPublicChannel,
  }) {
    return _SharedMarker(
      id: _buildMarkerId(sourceId: sourceId, timestamp: timestamp, text: text),
      position: LatLng(legacy.lat, legacy.lon),
      label: legacy.label,
      flags: legacy.flags,
      fromName: fromName,
      sourceLabel: sourceLabel,
      isChannel: isChannel,
      isPublicChannel: isPublicChannel,
    );
  }

  _SharedMarker _sharedMarkerFromTacticalPoi({
    required TacticalPoiMarker poi,
    required String sourceId,
    required DateTime timestamp,
    required String text,
    required String fromName,
    required String sourceLabel,
    required bool isChannel,
    required bool isPublicChannel,
  }) {
    return _SharedMarker(
      id: _buildMarkerId(sourceId: sourceId, timestamp: timestamp, text: text),
      position: LatLng(poi.lat, poi.lon),
      label: poi.label,
      flags: poi.type,
      fromName: fromName,
      sourceLabel: sourceLabel,
      isChannel: isChannel,
      isPublicChannel: isPublicChannel,
    );
  }

  String _buildMarkerId({
    required String sourceId,
    required DateTime timestamp,
    required String text,
  }) {
    return '$sourceId|${timestamp.millisecondsSinceEpoch}|$text';
  }

  // intentionally fixed: ATAK marker colors drawn on top of a raster map tile
  static const Color _atakParticipantColor = Color(0xFF4A5D23);
  static const Color _atakPoiColor = Color(0xFFE65100);

  IconData _atakPoiIcon(String type) {
    switch (type) {
      case 'wp':
        return Icons.trip_origin;
      case 'tgt':
        return Icons.gps_fixed;
      case 'hz':
        return Icons.warning;
      default:
        return Icons.place;
    }
  }

  Marker _buildAtakParticipantMarker(AtakParticipant participant) {
    return Marker(
      point: LatLng(participant.lat, participant.lon),
      width: 40,
      height: 40,
      child: GestureDetector(
        onLongPress: () =>
            _showRemoveAtakMarkerDialog(participant.id, participant.name),
        onTap: () => _showAtakParticipantInfo(participant),
        child: Opacity(
          opacity: atakMarkerOpacity(
            participant.timestampSeconds,
            isParticipant: true,
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _atakParticipantColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.groups, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Marker _buildAtakPoiMarker(AtakPoi poi) {
    return Marker(
      point: LatLng(poi.lat, poi.lon),
      width: 40,
      height: 40,
      child: GestureDetector(
        onLongPress: () => _showRemoveAtakMarkerDialog(poi.id, poi.label),
        onTap: () => _showAtakPoiInfo(poi),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _atakPoiColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(_atakPoiIcon(poi.type), color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Marker _buildSharedMarker(_SharedMarker marker) {
    final markerColor = marker.isChannel
        ? (marker.isPublicChannel ? Colors.orange : Colors.purple)
        : Colors.blue;
    return Marker(
      point: marker.position,
      width: 60,
      height: 60,
      child: GestureDetector(
        onLongPress: () =>
            _showRemoveSharedMarkerDialog(marker.id, marker.label),
        onTap: () => _showMarkerInfo(marker),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.flag, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showRepeaterLogin(BuildContext context, Contact repeater) {
    RepeaterLoginDialog.show(
      context,
      repeater: repeater,
      onLogin: (password) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RepeaterHubScreen(repeater: repeater, password: password),
          ),
        );
      },
    );
  }

  void _showRoomLogin(BuildContext context, Contact room) {
    showDialog(
      context: context,
      builder: (context) => RoomLoginDialog(
        room: room,
        onLogin: (password) {
          // Navigate to chat screen after successful login
          context.read<MeshCoreConnector>().markContactRead(room.publicKeyHex);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen(contact: room)),
          );
        },
      ),
    );
  }

  void _showNodeInfo(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getNodeIcon(contact.type),
              color: _getNodeColor(contact.type),
            ),
            const SizedBox(width: 8),
            Expanded(child: SelectableText(contact.displayName)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Type', contact.typeLabel),
            _buildInfoRow('Path', contact.pathLabel),
            _buildInfoRow(
              'Location',
              '${contact.latitude!.toStringAsFixed(6)}, ${contact.longitude!.toStringAsFixed(6)}',
            ),
            _buildInfoRow(
              context.l10n.map_lastSeen,
              _formatLastSeen(contact.lastSeen),
            ),
            _buildInfoRow('Public Key', contact.publicKeyHex),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_close),
          ),
          if (contact.type ==
              advTypeChat) // Only show chat button for chat nodes
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(contact: contact),
                  ),
                );
              },
              child: Text(context.l10n.contacts_openChat),
            ),
          if (contact.type == advTypeRepeater)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showRepeaterLogin(context, contact);
              },
              child: Text(context.l10n.map_manageRepeater),
            ),
          if (contact.type == advTypeRoom)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showRoomLogin(context, contact);
              },
              child: Text(context.l10n.map_joinRoom),
            ),
          if (context
              .read<AppSettingsService>()
              .settings
              .experimentalNodeBlockingEnabled)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                confirmBlockNode(context, contact);
              },
              child: Text(
                context.l10n.blockedNodes_blockAction,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  void _showAtakParticipantInfo(AtakParticipant participant) {
    final updateTime = DateTime.fromMillisecondsSinceEpoch(
      participant.timestampSeconds * 1000,
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(participant.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(context.l10n.map_from, participant.senderName),
            _buildInfoRow(context.l10n.map_source, participant.channelLabel),
            _buildInfoRow(
              'Location',
              '${participant.lat.toStringAsFixed(6)}, ${participant.lon.toStringAsFixed(6)}',
            ),
            _buildInfoRow(
              context.l10n.map_lastUpdate,
              _formatLastSeen(updateTime),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _hideAtakMarker(participant.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: Text(context.l10n.common_hide),
          ),
          TextButton(
            onPressed: () async {
              await _removeAtakMarker(participant.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: Text(context.l10n.common_remove),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_close),
          ),
        ],
      ),
    );
  }

  void _showAtakPoiInfo(AtakPoi poi) {
    final updateTime = DateTime.fromMillisecondsSinceEpoch(
      poi.timestampSeconds * 1000,
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(poi.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(context.l10n.map_from, poi.senderName),
            _buildInfoRow(context.l10n.map_source, poi.channelLabel),
            _buildInfoRow(
              'Location',
              '${poi.lat.toStringAsFixed(6)}, ${poi.lon.toStringAsFixed(6)}',
            ),
            _buildInfoRow(context.l10n.map_markerType, poi.type),
            _buildInfoRow(
              context.l10n.map_lastUpdate,
              _formatLastSeen(updateTime),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _hideAtakMarker(poi.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: Text(context.l10n.common_hide),
          ),
          TextButton(
            onPressed: () async {
              await _removeAtakMarker(poi.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: Text(context.l10n.common_remove),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_close),
          ),
        ],
      ),
    );
  }

  void _showMarkerInfo(_SharedMarker marker) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(marker.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(context.l10n.map_from, marker.fromName),
            _buildInfoRow(context.l10n.map_source, marker.sourceLabel),
            _buildInfoRow(
              'Location',
              '${marker.position.latitude.toStringAsFixed(6)}, ${marker.position.longitude.toStringAsFixed(6)}',
            ),
            if (marker.flags.isNotEmpty)
              _buildInfoRow(context.l10n.map_flags, marker.flags),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              setState(() {
                _hiddenMarkerIds.add(marker.id);
              });
              await _atakMapStateStore.saveSharedHiddenIds(_hiddenMarkerIds);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: Text(context.l10n.common_hide),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _hiddenMarkerIds.add(marker.id);
                _removedMarkerIds.add(marker.id);
              });
              await _markerService.saveRemovedIds(_removedMarkerIds);
              await _atakMapStateStore.saveSharedHiddenIds(_hiddenMarkerIds);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: Text(context.l10n.common_remove),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) {
      return context.l10n.time_justNow;
    } else if (difference.inMinutes < 60) {
      return context.l10n.time_minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return context.l10n.time_hoursAgo(difference.inHours);
    } else {
      return context.l10n.time_daysAgo(difference.inDays);
    }
  }

  void _showMarkOnMapSheet({
    required BuildContext context,
    required MeshCoreConnector connector,
    required AppSettings settings,
    required LatLng position,
  }) {
    final atakChannel = resolveAtakChannel(
      connector.channels,
      index: settings.atakChannelIndex,
      name: settings.atakChannelName,
    );
    final atakTypes = [
      ('poi', Icons.place, context.l10n.map_markerTypePoi),
      ('wp', Icons.trip_origin, context.l10n.map_markerTypeWaypoint),
      ('tgt', Icons.gps_fixed, context.l10n.map_markerTypeTarget),
      ('hz', Icons.warning, context.l10n.map_markerTypeHazard),
    ];

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                context.l10n.map_markOnMap,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (atakChannel == null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  context.l10n.map_atakSelectChannelToMark,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ...atakTypes.map((entry) {
              final (type, icon, label) = entry;
              return ListTile(
                leading: Icon(icon),
                title: Text(label),
                enabled: atakChannel != null && connector.isConnected,
                onTap: atakChannel == null || !connector.isConnected
                    ? null
                    : () {
                        final selectedChannel = atakChannel;
                        Navigator.pop(sheetContext);
                        _sendAtakPoiMarker(
                          context: context,
                          connector: connector,
                          channel: selectedChannel,
                          position: position,
                          type: type,
                          defaultLabel: label,
                        );
                      },
              );
            }),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(context.l10n.common_cancel),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendAtakPoiMarker({
    required BuildContext context,
    required MeshCoreConnector connector,
    required Channel channel,
    required LatLng position,
    required String type,
    required String defaultLabel,
  }) async {
    if (!connector.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.map_connectToShareMarkers)),
      );
      return;
    }

    if (channel.isPublicChannel) {
      final label = channel.name.isEmpty
          ? 'Channel ${channel.index}'
          : channel.name;
      final canSend = await confirmPublicLocationShare(context, label);
      if (!canSend || !context.mounted) return;
    }

    final label = await _promptForLabel(context, defaultLabel);
    if (label == null || !context.mounted) return;

    final markerText = TacticalMapPayload.formatPoi(
      lat: position.latitude,
      lon: position.longitude,
      timestampSeconds: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      label: label,
      type: type,
    );

    try {
      await connector.sendChannelMessage(channel, markerText);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chat_sendFailed(error.toString()))),
      );
      return;
    }

    if (!context.mounted) return;
    final channelLabel = channel.name.isEmpty
        ? 'Channel ${channel.index}'
        : channel.name;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.map_atakMarkerSent(channelLabel))),
    );
  }

  Future<String?> _promptForLabel(
    BuildContext context,
    String defaultLabel,
  ) async {
    final controller = TextEditingController(text: defaultLabel);
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.map_pinLabel),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: context.l10n.map_label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              final label = controller.text.trim().replaceAll('|', '/');
              Navigator.pop(
                dialogContext,
                label.isEmpty ? defaultLabel : label,
              );
            },
            child: Text(context.l10n.common_continue),
          ),
        ],
      ),
    );
  }

  bool _isPublicChannel(Channel channel) {
    return channel.isPublicChannel;
  }

  void _showFilterDialog(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.map_filterNodes),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: SingleChildScrollView(
          child: Consumer<AppSettingsService>(
            builder: (consumerContext, service, child) {
              final settings = service.settings;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.map_nodeTypes,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: Text(context.l10n.map_chatNodes),
                    value: settings.mapShowChatNodes,
                    onChanged: (value) {
                      service.setMapShowChatNodes(value ?? true);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: Text(context.l10n.map_repeaters),
                    value: settings.mapShowRepeaters,
                    onChanged: (value) {
                      service.setMapShowRepeaters(value ?? true);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: Text(context.l10n.map_otherNodes),
                    value: settings.mapShowOtherNodes,
                    onChanged: (value) {
                      service.setMapShowOtherNodes(value ?? true);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.map_keyPrefix,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: Text(context.l10n.map_filterByKeyPrefix),
                    value: settings.mapKeyPrefixEnabled,
                    onChanged: (value) {
                      service.setMapKeyPrefixEnabled(value ?? false);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  TextFormField(
                    initialValue: settings.mapKeyPrefix,
                    enabled: settings.mapKeyPrefixEnabled,
                    decoration: InputDecoration(
                      labelText: context.l10n.map_publicKeyPrefix,
                      hintText: 'e.g. ab12',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      service.setMapKeyPrefix(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.map_markers,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: Text(context.l10n.map_showSharedMarkers),
                    value: settings.mapShowMarkers,
                    onChanged: (value) {
                      service.setMapShowMarkers(value ?? true);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.map_lastSeenTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTimeFilterLabel(settings.mapTimeFilterHours),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Slider(
                    value: _hoursToSliderValue(settings.mapTimeFilterHours),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: (value) {
                      final hours = _sliderValueToHours(value);
                      service.setMapTimeFilterHours(hours);
                    },
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_close),
          ),
        ],
      ),
    );
  }

  // Convert hours to slider value (0-100) with exponential scaling
  double _hoursToSliderValue(double hours) {
    if (hours == 0) return 100; // All time

    // Map hours exponentially
    // 0-24h: 0-40
    // 24h-7d: 40-60
    // 7d-30d: 60-80
    // 30d-6mo: 80-99
    // All time: 100

    if (hours <= 24) {
      return (hours / 24) * 40;
    } else if (hours <= 168) {
      // 7 days
      return 40 + ((hours - 24) / (168 - 24)) * 20;
    } else if (hours <= 720) {
      // 30 days
      return 60 + ((hours - 168) / (720 - 168)) * 20;
    } else if (hours <= 4380) {
      // 6 months
      return 80 + ((hours - 720) / (4380 - 720)) * 19;
    } else {
      return 100;
    }
  }

  // Convert slider value (0-100) to hours with exponential scaling
  double _sliderValueToHours(double value) {
    if (value >= 99.5) return 0; // All time

    if (value <= 40) {
      return (value / 40) * 24; // 0-24 hours
    } else if (value <= 60) {
      return 24 + ((value - 40) / 20) * (168 - 24); // 1-7 days
    } else if (value <= 80) {
      return 168 + ((value - 60) / 20) * (720 - 168); // 7-30 days
    } else {
      return 720 + ((value - 80) / 19) * (4380 - 720); // 30 days - 6 months
    }
  }

  String _getTimeFilterLabel(double hours) {
    if (hours == 0) return context.l10n.time_allTime;

    if (hours < 1) {
      return '${(hours * 60).round()} ${context.l10n.time_minutes}';
    } else if (hours < 24) {
      final h = hours.round();
      return '$h ${h == 1 ? context.l10n.time_hour : context.l10n.time_hours}';
    } else if (hours < 168) {
      final days = (hours / 24).round();
      return '$days ${days == 1 ? context.l10n.time_day : context.l10n.time_days}';
    } else if (hours < 720) {
      final weeks = (hours / 168).round();
      return '$weeks ${weeks == 1 ? context.l10n.time_week : context.l10n.time_weeks}';
    } else if (hours < 4380) {
      final months = (hours / 730).round();
      return '$months ${months == 1 ? context.l10n.time_month : context.l10n.time_months}';
    } else {
      return context.l10n.time_allTime;
    }
  }

  void _addToPath(BuildContext context, Contact contact) {
    setState(() {
      _pathTrace.add(
        contact.publicKey[0],
      ); // Add first 16 bytes of public key to path trace
      _points.add(LatLng(contact.latitude!, contact.longitude!));
    });
  }

  void _startPath() {
    setState(() {
      _isBuildingPathTrace = true;
      _pathTrace.clear();
      _points.clear();
      _polylines.clear();
    });
  }

  void _removePath() {
    setState(() {
      _pathTrace.removeLast(); // Remove last node from path trace
      _points.removeLast(); // Remove last point from points list
      _polylines.clear(); // Clear polylines
    });
  }

  Widget _buildPathTraceOverlay() {
    final l10n = context.l10n;
    final isImperial =
        context.read<AppSettingsService>().settings.unitSystem ==
        UnitSystem.imperial;
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.contacts_pathTrace,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_pathTrace.isEmpty) const SizedBox(height: 8),
              if (_pathTrace.isEmpty)
                Text(l10n.map_tapToAdd, style: TextStyle(fontSize: 12)),
              const SizedBox(height: 6),
              if (_pathTrace.isNotEmpty)
                Text(
                  "${l10n.path_currentPathLabel} ${formatDistance(getPathDistanceMeters(_points), isImperial: isImperial)}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              SelectableText(
                _pathTrace
                    .map((b) => b.toRadixString(16).padLeft(2, '0'))
                    .join(','),
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_pathTrace.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PathTraceMapScreen(
                              title: l10n.contacts_pathTrace,
                              path: Uint8List.fromList(_pathTrace),
                            ),
                          ),
                        );
                        setState(() {
                          _isBuildingPathTrace = false;
                        });
                      },
                      child: Text(l10n.map_runTrace),
                    ),
                  if (_pathTrace.isNotEmpty)
                    ElevatedButton(
                      onPressed: _removePath,
                      child: Text(l10n.map_removeLast),
                    ),
                  if (_pathTrace.isEmpty)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isBuildingPathTrace = false;
                          _pathTrace.clear();
                          _points.clear();
                          _polylines.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.map_pathTraceCancelled)),
                        );
                      },
                      child: Text(l10n.common_cancel),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SharedMarker {
  final String id;
  final LatLng position;
  final String label;
  final String flags;
  final String fromName;
  final String sourceLabel;
  final bool isChannel;
  final bool isPublicChannel;

  _SharedMarker({
    required this.id,
    required this.position,
    required this.label,
    required this.flags,
    required this.fromName,
    required this.sourceLabel,
    required this.isChannel,
    required this.isPublicChannel,
  });
}
