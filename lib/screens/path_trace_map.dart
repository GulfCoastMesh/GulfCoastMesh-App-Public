import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/helpers/map_initial_location.dart';
import 'package:gulf_coast_mesh_app/l10n/l10n.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/services/app_settings_service.dart';
import 'package:gulf_coast_mesh_app/services/atak_location_broadcast_service.dart';
import 'package:gulf_coast_mesh_app/services/map_tile_cache_service.dart';
import 'package:gulf_coast_mesh_app/utils/app_logger.dart';
import 'package:gulf_coast_mesh_app/widgets/snr_indicator.dart';
import 'package:provider/provider.dart';

double getPathDistanceMeters(List<LatLng> points) {
  if (points.length <= 1) return 0.0;

  double distanceMeters = 0.0;
  final distanceCalculator = Distance();

  for (int i = 0; i < points.length - 1; i++) {
    distanceMeters += distanceCalculator(points[i], points[i + 1]);
  }

  return distanceMeters;
}

String formatDistance(double distanceMeters, {required bool isImperial}) {
  if (isImperial) {
    return '(${(distanceMeters / 1609.34).toStringAsFixed(2)} mi)';
  }
  return '(${(distanceMeters / 1000).toStringAsFixed(2)} km)';
}

class PathTraceData {
  final Uint8List pathData;
  final List<double> snrData;
  final Map<int, Contact> pathContacts;

  PathTraceData({
    required this.pathData,
    required this.snrData,
    required this.pathContacts,
  });
}

class PathTraceMapScreen extends StatefulWidget {
  final String title;
  final Uint8List path;
  final int? repeaterId;
  final bool flipPathRound;
  final bool reversePathRound;

  const PathTraceMapScreen({
    super.key,
    required this.title,
    required this.path,
    this.repeaterId,
    this.flipPathRound = false,
    this.reversePathRound = false,
  });

  @override
  State<PathTraceMapScreen> createState() => _PathTraceMapScreenState();
}

class _PathTraceMapScreenState extends State<PathTraceMapScreen> {
  static const double _labelZoomThreshold = 8.5;

  StreamSubscription<Uint8List>? _frameSubscription;
  Timer? _timeoutTimer;

  bool _isLoading = false;
  bool _failed2Loaded = false;
  bool _hasData = false;
  PathTraceData? _traceData;
  List<LatLng> _points = <LatLng>[];
  List<Polyline> _polylines = [];
  LatLng? _initialCenter = kFallbackMapCenter;
  double _initialZoom = kWorldZoom;
  LatLng? _userMapCenter;
  LatLngBounds? _bounds;
  ValueKey<String> _mapKey = const ValueKey('initial');
  double _pathDistanceMeters = 0.0;
  bool _showNodeLabels = true;

  String _formatPathPrefixes(Uint8List pathBytes) {
    final hashSizeBytes = pathHashBytesForMode(
      context.read<AppSettingsService>().settings.companionPathHashMode,
    );
    return formatPathIdList(pathBytes, hashSizeBytes: hashSizeBytes);
  }

  @override
  void initState() {
    super.initState();
    _setupFrameListener();
    _doPathTrace();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserMapCenter();
    });
  }

  Future<void> _loadUserMapCenter() async {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    final sync = syncMapCenterFromConnector(connector);
    if (sync != null && mounted) {
      setState(() {
        _userMapCenter = sync;
        if (_points.isEmpty) {
          _initialCenter = sync;
          _initialZoom = kUserLocationZoom;
        }
      });
    }

    final center = await resolveUserMapCenter(connector: connector);
    if (!mounted || center == null) return;
    setState(() {
      _userMapCenter = center;
      if (_points.isEmpty) {
        _initialCenter = center;
        _initialZoom = kUserLocationZoom;
      }
    });
  }

  @override
  void dispose() {
    _frameSubscription?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Uint8List addReturnPath(Uint8List pathBytes) {
    Uint8List? traceBytes;
    final len = (pathBytes.length + pathBytes.length - 1);
    traceBytes = Uint8List(len);
    for (int i = 0; i < pathBytes.length; i++) {
      traceBytes[i] = pathBytes[i];
      if (i < pathBytes.length - 1) {
        traceBytes[len - 1 - i] = pathBytes[i];
      }
    }
    return traceBytes;
  }

  Future<void> _doPathTrace() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _failed2Loaded = false;
      });
    }

    final Uint8List path;

    Uint8List pathTmp = widget.reversePathRound
        ? Uint8List.fromList(widget.path.reversed.toList())
        : widget.path;

    if (widget.flipPathRound) {
      path = addReturnPath(pathTmp);
    } else {
      path = pathTmp;
    }

    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    final frame = buildTraceReq(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      0, //flags
      0, //auth
      payload: path,
    );
    try {
      await connector.sendFrame(frame);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _failed2Loaded = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.pathTrace_failed)));
    }
  }

  void _setupFrameListener() {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    Uint8List tagData = Uint8List(4);
    // Listen for incoming text messages from the repeater
    _frameSubscription = connector.receivedFrames.listen((frame) {
      if (frame.isEmpty) return;
      final frameBuffer = BufferReader(frame);
      try {
        final code = frameBuffer.readUInt8();

        if (code == respCodeSent) {
          frameBuffer.skipBytes(1); //reserved
          tagData = frameBuffer.readBytes(4);
          final timeoutMilliseconds = frameBuffer.readUInt32LE();

          // Start timeout timer for trace response
          _timeoutTimer?.cancel();
          _timeoutTimer = Timer(
            Duration(milliseconds: timeoutMilliseconds),
            () {
              if (!mounted) return;
              setState(() {
                _isLoading = false;
                _failed2Loaded = true;
              });
            },
          );
        }

        if (code == respCodeErr) {
          _timeoutTimer?.cancel();
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _failed2Loaded = true;
          });
        }

        // Check if it's a binary response
        if (frame.length > 8 &&
            code == pushCodeTraceData &&
            listEquals(frame.sublist(4, 8), tagData)) {
          _timeoutTimer?.cancel();
          if (!mounted) return;
          frameBuffer.skipBytes(3); //reserved + path length + flag
          if (listEquals(frameBuffer.readBytes(4), tagData)) {
            _handleTraceResponse(frame);
          }
        }
      } catch (e) {
        _timeoutTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _failed2Loaded = true;
        });
        // Handle any parsing errors gracefully
        appLogger.error('Error parsing frame: $e', tag: 'PathTraceMapScreen');
      }
    });
  }

  Future<void> _handleTraceResponse(Uint8List frame) async {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);

    final buffer = BufferReader(frame);
    try {
      buffer.skipBytes(2); // Skip push code and reserved byte
      int pathLength = buffer.readUInt8();
      buffer.skipBytes(5); // Skip Flag byte and tag data
      buffer.skipBytes(4); // Skip auth code
      Uint8List pathData = buffer.readBytes(pathLength);
      List<double> snrData = buffer
          .readRemainingBytes()
          .map((snr) => snr.toSigned(8).toDouble() / 4)
          .toList();

      Map<int, Contact> pathContacts = {};

      connector.contacts.where((c) => c.type != advTypeChat).forEach((
        repeater,
      ) {
        for (var repeaterData in pathData) {
          if (listEquals(
            repeater.publicKey.sublist(0, 1),
            Uint8List.fromList([repeaterData]),
          )) {
            pathContacts[repeaterData] = repeater;
          }
        }
      });

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasData = true;
        _traceData = PathTraceData(
          pathData: pathData,
          snrData: snrData,
          pathContacts: pathContacts,
        );
        _points = <LatLng>[];
        final broadcastService = context.read<AtakLocationBroadcastService>();
        final selfLat = broadcastService.phoneLat ?? connector.selfLatitude;
        final selfLon = broadcastService.phoneLon ?? connector.selfLongitude;
        if (selfLat != null && selfLon != null) {
          _points.add(LatLng(selfLat, selfLon));
        }
        for (final hop in _traceData!.pathData) {
          final contact = _traceData!.pathContacts[hop];
          if (contact != null &&
              contact.hasLocation &&
              contact.latitude != null &&
              contact.longitude != null) {
            _points.add(LatLng(contact.latitude!, contact.longitude!));
          }
        }
        _polylines = _points.length > 1
            ? [
                Polyline(
                  points: _points,
                  strokeWidth: 4,
                  color: Colors.blueAccent,
                ),
              ]
            : <Polyline>[];

        _initialCenter = _points.isNotEmpty
            ? _points.first
            : (_userMapCenter ?? kFallbackMapCenter);
        _initialZoom = _points.isNotEmpty
            ? 13.0
            : (_userMapCenter != null ? kUserLocationZoom : kWorldZoom);
        _bounds = _points.length > 1 ? LatLngBounds.fromPoints(_points) : null;
        _mapKey = ValueKey(
          '${context.l10n.pathTrace_you},${_formatPathPrefixes(_traceData!.pathData)}',
        );
        _pathDistanceMeters = getPathDistanceMeters(_points);
      });
    } catch (e) {
      appLogger.error(
        'Error handling trace response: $e',
        tag: 'PathTraceMapScreen',
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _failed2Loaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MeshCoreConnector>(
      builder: (context, connector, _) {
        final settings = context.watch<AppSettingsService>().settings;
        final isImperial = settings.unitSystem == UnitSystem.imperial;
        final tileCache = context.read<MapTileCacheService>();

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: _isLoading ? null : _doPathTrace,
                tooltip: context.l10n.pathTrace_refreshTooltip,
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Stack(
              children: [
                if (!_hasData)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoading) const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        if (!_isLoading && _failed2Loaded)
                          Text(context.l10n.pathTrace_notAvailable),
                      ],
                    ),
                  ),
                if (_hasData) _buildMapPathTrace(context, tileCache),
                if (_points.isEmpty &&
                    !_hasData &&
                    !_isLoading &&
                    !_failed2Loaded)
                  Center(
                    child: Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.9),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          context.l10n.channelPath_noRepeaterLocations,
                        ),
                      ),
                    ),
                  ),
                if (_hasData)
                  _buildLegendCard(context, _traceData!, isImperial),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Marker> _buildHopMarkers(
    List<int> pathData, {
    required bool showLabels,
  }) {
    final markers = <Marker>[];
    for (final hop in pathData) {
      final contact = _traceData!.pathContacts[hop];
      if (contact == null || !contact.hasLocation) continue;
      final point = LatLng(contact.latitude!, contact.longitude!);
      markers.add(
        Marker(
          point: point,
          width: 35,
          height: 35,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green,
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
            child: Text(
              contact.publicKey
                  .sublist(0, 1)
                  .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
                  .join(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
      if (showLabels) {
        markers.add(_buildNodeLabelMarker(point: point, label: contact.name));
      }
    }

    final connector = context.read<MeshCoreConnector>();
    final broadcastService = context.read<AtakLocationBroadcastService>();
    final selfLat = broadcastService.phoneLat ?? connector.selfLatitude;
    final selfLon = broadcastService.phoneLon ?? connector.selfLongitude;
    if (selfLat != null && selfLon != null) {
      final selfPoint = LatLng(selfLat, selfLon);
      markers.add(
        Marker(
          point: selfPoint,
          width: 35,
          height: 35,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue,
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
            child: Text(
              context.l10n.pathTrace_you,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
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

  String formatDirectionText(PathTraceData pathTraceData, int index) {
    if (index == 0 || index == pathTraceData.snrData.length - 1) {
      if (index == 0) {
        return context.l10n.pathTrace_you;
      } else {
        final contactName = pathTraceData
            .pathContacts[pathTraceData.pathData[pathTraceData.pathData.length -
                1]]
            ?.name;
        final hex = pathTraceData.pathData[pathTraceData.pathData.length - 1]
            .toRadixString(16)
            .padLeft(2, '0')
            .toUpperCase();
        return contactName != null
            ? "$hex: $contactName"
            : "$hex: ${context.l10n.channelPath_unknownRepeater}";
      }
    } else {
      final contactName =
          pathTraceData.pathContacts[pathTraceData.pathData[index - 1]]?.name;
      final hex = pathTraceData.pathData[index - 1]
          .toRadixString(16)
          .padLeft(2, '0')
          .toUpperCase();
      return contactName != null
          ? "$hex: $contactName"
          : "$hex: ${context.l10n.channelPath_unknownRepeater}";
    }
  }

  String formatDirectionSubText(PathTraceData pathTraceData, int index) {
    if (index == 0 || index == pathTraceData.snrData.length - 1) {
      if (index == 0) {
        final contactName =
            pathTraceData.pathContacts[pathTraceData.pathData[0]]?.name;
        final hex = pathTraceData.pathData[0]
            .toRadixString(16)
            .padLeft(2, '0')
            .toUpperCase();
        return contactName != null
            ? "$hex: $contactName"
            : "$hex: ${context.l10n.channelPath_unknownRepeater}";
      } else {
        return context.l10n.pathTrace_you;
      }
    } else {
      final contactName =
          pathTraceData.pathContacts[pathTraceData.pathData[index]]?.name;
      final hex = pathTraceData.pathData[index]
          .toRadixString(16)
          .padLeft(2, '0')
          .toUpperCase();
      return contactName != null
          ? "$hex: $contactName"
          : "$hex: ${context.l10n.channelPath_unknownRepeater}";
    }
  }

  Widget _buildMapPathTrace(
    BuildContext context,
    MapTileCacheService tileCache,
  ) {
    return FlutterMap(
      key: _mapKey,
      options: MapOptions(
        interactionOptions: InteractionOptions(flags: ~InteractiveFlag.rotate),
        initialCenter: _initialCenter!,
        initialZoom: _initialZoom,
        initialCameraFit: _bounds == null
            ? null
            : CameraFit.bounds(
                bounds: _bounds!,
                padding: const EdgeInsets.all(64),
                maxZoom: 16,
              ),
        minZoom: 2.0,
        maxZoom: 18.0,
        onPositionChanged: (camera, hasGesture) {
          final shouldShow = camera.zoom >= _labelZoomThreshold;
          if (shouldShow != _showNodeLabels && mounted) {
            setState(() {
              _showNodeLabels = shouldShow;
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: kMapTileUrlTemplate,
          tileProvider: tileCache.tileProvider,
          userAgentPackageName: MapTileCacheService.userAgentPackageName,
          maxZoom: 19,
        ),
        if (_polylines.isNotEmpty) PolylineLayer(polylines: _polylines),
        if (_traceData!.pathData.isNotEmpty)
          MarkerLayer(
            markers: _buildHopMarkers(
              _traceData!.pathData,
              showLabels: _showNodeLabels,
            ),
          ),
      ],
    );
  }

  Widget _buildLegendCard(
    BuildContext context,
    PathTraceData pathTraceData,
    bool isImperial,
  ) {
    final l10n = context.l10n;
    final maxHeight = MediaQuery.of(context).size.height * 0.35;
    final estimatedHeight = 72.0 + (pathTraceData.pathData.length * 56.0);
    final cardHeight = max(96.0, min(maxHeight, estimatedHeight));

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SizedBox(
        height: cardHeight,
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${l10n.channelPath_repeaterHops} ${formatDistance(_pathDistanceMeters, isImperial: isImperial)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: pathTraceData.pathData.isEmpty
                    ? Center(
                        child: Text(l10n.channelPath_noHopDetailsAvailable),
                      )
                    : Scrollbar(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: pathTraceData.pathData.length + 1,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final snrUi = snrUiFromSNR(
                              context,
                              index < pathTraceData.snrData.length
                                  ? pathTraceData.snrData[index]
                                  : null,
                              context.read<MeshCoreConnector>().currentSf,
                            );
                            return Column(
                              children: [
                                ListTile(
                                  leading:
                                      index >= pathTraceData.snrData.length / 2
                                      ? Icon(Icons.call_received)
                                      : Icon(Icons.call_made),
                                  title: Text(
                                    formatDirectionText(pathTraceData, index),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    formatDirectionSubText(
                                      pathTraceData,
                                      index,
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        snrUi.icon,
                                        color: snrUi.color,
                                        size: 18.0,
                                      ),
                                      Text(
                                        snrUi.text,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: snrUi.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Handle item tap
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
