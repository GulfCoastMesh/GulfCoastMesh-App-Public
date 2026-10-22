import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../helpers/user_map_center_mixin.dart';
import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../services/app_settings_service.dart';
import '../services/line_of_sight_service.dart';
import '../services/map_tile_cache_service.dart';
import '../widgets/app_bar.dart';

class LineOfSightEndpoint {
  final String label;
  final LatLng point;
  final Color color;
  final IconData icon;
  final bool isCustom;

  const LineOfSightEndpoint({
    required this.label,
    required this.point,
    // intentionally fixed: map marker on raster tile, not theme-relative
    this.color = Colors.green,
    this.icon = Icons.location_on,
    this.isCustom = false,
  });
}

class LineOfSightMapScreen extends StatefulWidget {
  final String title;
  final List<LineOfSightEndpoint> candidates;

  const LineOfSightMapScreen({
    super.key,
    required this.title,
    required this.candidates,
  });

  @override
  State<LineOfSightMapScreen> createState() => _LineOfSightMapScreenState();
}

class _LineOfSightMapScreenState extends State<LineOfSightMapScreen>
    with UserMapCenterMixin {
  static const String _errorSelectStartEnd = 'los_error_select_start_end';
  static const double _metersToFeet = 3.28084;
  static const double _kmToMiles = 0.621371;
  static const double _maxAntennaFeet = 400.0;
  static const double _maxAntennaMeters = _maxAntennaFeet / _metersToFeet;
  static const double _labelZoomThreshold = 8.5;

  final LineOfSightService _lineOfSightService = LineOfSightService();

  bool _loading = false;
  String? _error;
  LineOfSightPathResult? _result;
  LineOfSightEndpoint? _start;
  LineOfSightEndpoint? _end;
  final List<LineOfSightEndpoint> _customEndpoints = [];
  double _startAntennaHeight = 5.0;
  double _endAntennaHeight = 5.0;
  bool _showHud = true;
  bool _menuExpanded = true;
  bool _showDisplayNodes = true;
  bool _showMarkerLabels = true;
  bool _didReceivePositionUpdate = false;
  int _losRequestNonce = 0;

  @override
  void initState() {
    super.initState();
    initUserMapCenter(applyMove: false);
    if (widget.candidates.isNotEmpty) {
      _start = widget.candidates.first;
      if (widget.candidates.length > 1) {
        _end = widget.candidates[1];
      }
    }
    _runLos();
  }

  @override
  void dispose() {
    _lineOfSightService.dispose();
    super.dispose();
  }

  Future<void> _runLos() async {
    final start = _start;
    final end = _end;
    final startAntenna = _startAntennaHeight;
    final endAntenna = _endAntennaHeight;
    final requestId = ++_losRequestNonce;
    if (start == null || end == null) {
      setState(() {
        _result = null;
        _error = _errorSelectStartEnd;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _lineOfSightService.analyzePath(
        [start.point, end.point],
        startAntennaHeightMeters: startAntenna,
        endAntennaHeightMeters: endAntenna,
      );
      if (!mounted) return;
      if (!_isRunRequestCurrent(
        requestId: requestId,
        start: start,
        end: end,
        startAntenna: startAntenna,
        endAntenna: endAntenna,
      )) {
        return;
      }
      setState(() {
        _result = result;
      });
    } catch (e) {
      if (!mounted) return;
      if (!_isRunRequestCurrent(
        requestId: requestId,
        start: start,
        end: end,
        startAntenna: startAntenna,
        endAntenna: endAntenna,
      )) {
        return;
      }
      setState(() {
        _result = null;
        _error = context.l10n.losRunFailed(e.toString());
      });
    } finally {
      if (mounted && requestId == _losRequestNonce) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool _isRunRequestCurrent({
    required int requestId,
    required LineOfSightEndpoint start,
    required LineOfSightEndpoint end,
    required double startAntenna,
    required double endAntenna,
  }) {
    return requestId == _losRequestNonce &&
        identical(_start, start) &&
        identical(_end, end) &&
        _startAntennaHeight == startAntenna &&
        _endAntennaHeight == endAntenna;
  }

  void _selectFromMap(LineOfSightEndpoint endpoint) {
    setState(() {
      _result = null;
      _error = null;
      if (_start == null || (_start != null && _end != null)) {
        _start = endpoint;
        if (_end == endpoint) _end = null;
      } else {
        _end = endpoint;
        if (_start == endpoint) _start = null;
      }
    });

    if (_start != null && _end != null) {
      _runLos();
    }
  }

  void _addCustomPoint(LatLng point) {
    final endpoint = LineOfSightEndpoint(
      label: context.l10n.losCustomPointLabel(_customEndpoints.length + 1),
      point: point,
      // intentionally fixed: map marker on raster tile, not theme-relative
      color: Colors.orange,
      icon: Icons.push_pin,
      isCustom: true,
    );
    setState(() {
      _customEndpoints.add(endpoint);
    });
    _selectFromMap(endpoint);
  }

  List<LineOfSightEndpoint> _visibleEndpoints() {
    return [if (_showDisplayNodes) ...widget.candidates, ..._customEndpoints];
  }

  bool _hasEndpoint(
    List<LineOfSightEndpoint> endpoints,
    LineOfSightEndpoint? e,
  ) {
    if (e == null) return false;
    return endpoints.any((item) => identical(item, e));
  }

  void _sanitizeSelection() {
    final visible = _visibleEndpoints();
    if (!_hasEndpoint(visible, _start)) {
      _start = null;
    }
    if (!_hasEndpoint(visible, _end)) {
      _end = null;
    }
  }

  void _clearAllPoints() {
    setState(() {
      _customEndpoints.clear();
      _start = null;
      _end = null;
      _result = null;
      _error = _errorSelectStartEnd;
    });
  }

  void _deleteCustomPoint(LineOfSightEndpoint endpoint) {
    setState(() {
      _customEndpoints.removeWhere((e) => identical(e, endpoint));
      if (identical(_start, endpoint)) _start = null;
      if (identical(_end, endpoint)) _end = null;
      _result = null;
    });
  }

  Future<void> _renameCustomPoint(LineOfSightEndpoint endpoint) async {
    final controller = TextEditingController(text: endpoint.label);
    final newLabel = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.losRenameCustomPoint),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: context.l10n.losPointName,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              Navigator.pop(dialogContext, value);
            },
            child: Text(context.l10n.common_save),
          ),
        ],
      ),
    );

    if (!mounted || newLabel == null || newLabel.isEmpty) return;
    final index = _customEndpoints.indexWhere((e) => identical(e, endpoint));
    if (index < 0) return;
    final renamed = LineOfSightEndpoint(
      label: newLabel,
      point: endpoint.point,
      color: endpoint.color,
      icon: endpoint.icon,
      isCustom: endpoint.isCustom,
    );
    setState(() {
      _customEndpoints[index] = renamed;
      if (identical(_start, endpoint)) _start = renamed;
      if (identical(_end, endpoint)) _end = renamed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsService>().settings;
    final isImperial = settings.unitSystem == UnitSystem.imperial;
    final tileCache = context.read<MapTileCacheService>();
    final endpoints = _visibleEndpoints();
    final mapPoints = [
      if (_start != null) _start!.point,
      if (_end != null) _end!.point,
    ];
    final initialCenter = mapPoints.isNotEmpty
        ? mapPoints.first
        : userMapCenterOrFallback;
    final bounds = mapPoints.length > 1
        ? LatLngBounds.fromPoints(mapPoints)
        : null;
    final initialZoom = mapPoints.length > 1 ? 13.0 : userMapZoomOrFallback;
    if (!_didReceivePositionUpdate) {
      _showMarkerLabels = initialZoom >= _labelZoomThreshold;
    }

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            onPressed: _loading ? null : _clearAllPoints,
            tooltip: context.l10n.losClearAllPoints,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: initialZoom,
              initialCameraFit: bounds == null
                  ? null
                  : CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(64),
                      maxZoom: 16,
                    ),
              interactionOptions: InteractionOptions(
                flags: ~InteractiveFlag.rotate,
              ),
              onLongPress: (_, point) => _addCustomPoint(point),
              onPositionChanged: (camera, hasGesture) {
                final shouldShow = camera.zoom >= _labelZoomThreshold;
                if (!_didReceivePositionUpdate ||
                    shouldShow != _showMarkerLabels) {
                  setState(() {
                    _didReceivePositionUpdate = true;
                    _showMarkerLabels = shouldShow;
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
              if (_result != null && _result!.segments.isNotEmpty)
                PolylineLayer(polylines: _buildSegmentPolylines(_result!)),
              MarkerLayer(markers: _buildMarkers(endpoints)),
            ],
          ),
          if (_showHud)
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.52,
                ),
                child: _buildControlPanel(isImperial),
              ),
            ),
          if (!_showHud && _result != null && _result!.segments.isNotEmpty)
            Positioned(
              left: 12,
              bottom: 12 + MediaQuery.paddingOf(context).bottom,
              child: DecoratedBox(
                // intentionally fixed: floating badge over raster map tile, not theme-relative
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    context.l10n.losElevationAttribution,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showHud = !_showHud;
          });
        },
        tooltip: _showHud
            ? context.l10n.losHidePanelTooltip
            : context.l10n.losShowPanelTooltip,
        child: Icon(_showHud ? Icons.visibility_off : Icons.tune),
      ),
    );
  }

  Widget _buildControlPanel(bool isImperial) {
    final colorScheme = Theme.of(context).colorScheme;
    _sanitizeSelection();
    final segment = _primarySegmentResult();
    final endpoints = _visibleEndpoints();
    final distanceUnit = isImperial ? 'mi' : 'km';
    final heightUnit = isImperial ? 'ft' : 'm';
    final antennaAMeters = _startAntennaHeight;
    final antennaBMeters = _endAntennaHeight;
    final antennaADisplay = _toDisplayHeight(antennaAMeters, isImperial);
    final antennaBDisplay = _toDisplayHeight(antennaBMeters, isImperial);
    final antennaSliderMax = isImperial ? _maxAntennaFeet : _maxAntennaMeters;
    final antennaSliderDivisions = isImperial ? 400 : 122;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (segment != null)
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _LosProfilePainter(
                      samples: segment.samples,
                      distanceUnit: distanceUnit,
                      heightUnit: heightUnit,
                      // intentionally fixed: label drawn over the fixed-palette
                      // elevation profile canvas below, not theme-relative
                      badgeTextStyle:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ) ??
                          const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(
                      context.l10n.losRunToViewElevationProfile,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                segment != null
                    ? _profileStats(segment, isImperial)
                    : _statusText(),
                style: TextStyle(
                  fontSize: 12,
                  color: segment != null
                      ? (segment.isClear
                            ? colorScheme.tertiary
                            : colorScheme.error)
                      : _statusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.losElevationAttribution,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              ExpansionTile(
                initiallyExpanded: _menuExpanded,
                onExpansionChanged: (value) {
                  setState(() {
                    _menuExpanded = value;
                  });
                },
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  context.l10n.losMenuTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  context.l10n.losMenuSubtitle,
                  style: const TextStyle(fontSize: 11),
                ),
                children: [
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      context.l10n.losShowDisplayNodes,
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _showDisplayNodes,
                    onChanged: (value) {
                      setState(() {
                        _showDisplayNodes = value;
                        _sanitizeSelection();
                        _result = null;
                      });
                    },
                  ),
                  if (_customEndpoints.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.losCustomPoints,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    for (final point in _customEndpoints)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          point.label,
                          style: const TextStyle(fontSize: 12),
                        ),
                        subtitle: Text(
                          '${point.point.latitude.toStringAsFixed(5)}, ${point.point.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () => _renameCustomPoint(point),
                              tooltip: context.l10n.common_edit,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () => _deleteCustomPoint(point),
                              tooltip: context.l10n.common_delete,
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 8),
                  _buildEndpointRow(
                    label: context.l10n.losPointA,
                    value: _start,
                    candidates: endpoints,
                    onChanged: (value) {
                      setState(() {
                        _start = value;
                        _result = null;
                      });
                      if (_start != null && _end != null) {
                        _runLos();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildEndpointRow(
                    label: context.l10n.losPointB,
                    value: _end,
                    candidates: endpoints,
                    onChanged: (value) {
                      setState(() {
                        _end = value;
                        _result = null;
                      });
                      if (_start != null && _end != null) {
                        _runLos();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.losAntennaA(
                      antennaADisplay.toStringAsFixed(1),
                      heightUnit,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Slider(
                    value: antennaADisplay,
                    min: 0,
                    max: antennaSliderMax,
                    divisions: antennaSliderDivisions,
                    onChanged: (value) {
                      setState(() {
                        _startAntennaHeight = _toMetersHeight(
                          value,
                          isImperial,
                        );
                      });
                    },
                  ),
                  Text(
                    context.l10n.losAntennaB(
                      antennaBDisplay.toStringAsFixed(1),
                      heightUnit,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Slider(
                    value: antennaBDisplay,
                    min: 0,
                    max: antennaSliderMax,
                    divisions: antennaSliderDivisions,
                    onChanged: (value) {
                      setState(() {
                        _endAntennaHeight = _toMetersHeight(value, isImperial);
                      });
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _runLos,
                      icon: const Icon(Icons.visibility),
                      label: Text(context.l10n.losRun),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndpointRow({
    required String label,
    required LineOfSightEndpoint? value,
    required List<LineOfSightEndpoint> candidates,
    required ValueChanged<LineOfSightEndpoint?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: DropdownButton<LineOfSightEndpoint>(
            value: value,
            isExpanded: true,
            items: candidates
                .map(
                  (e) => DropdownMenuItem<LineOfSightEndpoint>(
                    value: e,
                    child: Text(e.label, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  LineOfSightResult? _primarySegmentResult() {
    if (_result == null || _result!.segments.isEmpty) return null;
    return _result!.segments.first.result;
  }

  String _profileStats(LineOfSightResult result, bool isImperial) {
    final distance = isImperial
        ? (result.totalDistanceMeters / 1000.0) * _kmToMiles
        : result.totalDistanceMeters / 1000.0;
    final distanceUnit = isImperial ? 'mi' : 'km';
    final heightUnit = isImperial ? 'ft' : 'm';
    final minClearance = result.samples.isEmpty
        ? 0.0
        : result.samples.map((s) => s.clearanceMeters).reduce(math.min);
    final minClearanceDisplay = isImperial
        ? minClearance * _metersToFeet
        : minClearance;
    final maxObstructionDisplay = isImperial
        ? result.maxObstructionMeters * _metersToFeet
        : result.maxObstructionMeters;
    if (!result.hasData) {
      return _localizedLosError(result.errorMessage);
    }
    if (result.isClear) {
      return context.l10n.losProfileClear(
        distance.toStringAsFixed(1),
        distanceUnit,
        minClearanceDisplay.toStringAsFixed(1),
        heightUnit,
      );
    }
    return context.l10n.losProfileBlocked(
      distance.toStringAsFixed(1),
      distanceUnit,
      maxObstructionDisplay.toStringAsFixed(1),
      heightUnit,
    );
  }

  List<Polyline> _buildSegmentPolylines(LineOfSightPathResult result) {
    final polylines = <Polyline>[];
    for (final segment in result.segments) {
      final color = !segment.result.hasData
          ? Colors.grey
          : (segment.result.isClear ? Colors.green : Colors.red);
      polylines.add(
        Polyline(
          points: [segment.start, segment.end],
          strokeWidth: 4,
          color: color,
        ),
      );
    }
    return polylines;
  }

  List<Marker> _buildMarkers(List<LineOfSightEndpoint> endpoints) {
    return [
      for (final endpoint in endpoints)
        Marker(
          point: endpoint.point,
          width: 36,
          height: 36,
          child: GestureDetector(
            onTap: () => _selectFromMap(endpoint),
            child: Container(
              decoration: BoxDecoration(
                color: endpoint.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(endpoint.icon, color: Colors.white, size: 16),
                  ),
                  if (endpoint == _start || endpoint == _end)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          endpoint == _start ? 'A' : 'B',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      for (final endpoint in endpoints)
        if (_showMarkerLabels)
          Marker(
            point: endpoint.point,
            width: 120,
            height: 24,
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      endpoint.label,
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
          ),
    ];
  }

  String _statusText() {
    if (_loading) return context.l10n.losStatusChecking;
    if (_error == _errorSelectStartEnd) {
      return context.l10n.losSelectStartEnd;
    }
    if (_error != null) return _error!;
    if (_result == null) return context.l10n.losStatusNoData;
    final total = _result!.segments.length;
    return context.l10n.losStatusSummary(
      _result!.clearSegments,
      total,
      _result!.blockedSegments,
      _result!.unknownSegments,
    );
  }

  Color _statusColor() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_error != null) return colorScheme.error;
    if (_loading) return colorScheme.tertiary;
    if (_result == null) return colorScheme.outline;
    if (_result!.blockedSegments > 0) return colorScheme.error;
    if (_result!.clearSegments > 0) return colorScheme.tertiary;
    return colorScheme.outline;
  }

  double _toDisplayHeight(double meters, bool isImperial) {
    return isImperial ? meters * _metersToFeet : meters;
  }

  double _toMetersHeight(double displayHeight, bool isImperial) {
    return isImperial ? displayHeight / _metersToFeet : displayHeight;
  }

  String _localizedLosError(String? message) {
    if (message == LineOfSightService.errorElevationUnavailable) {
      return context.l10n.losErrorElevationUnavailable;
    }
    if (message == LineOfSightService.errorInvalidInput) {
      return context.l10n.losErrorInvalidInput;
    }
    return context.l10n.losNoElevationData;
  }
}

class _LosProfilePainter extends CustomPainter {
  final List<LineOfSightSample> samples;
  final String distanceUnit;
  final String heightUnit;
  final TextStyle badgeTextStyle;

  const _LosProfilePainter({
    required this.samples,
    required this.distanceUnit,
    required this.heightUnit,
    required this.badgeTextStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // intentionally fixed: terrain-profile chart uses a fixed sky/terrain/line
    // palette for physical realism, not theme-relative
    final bg = Paint()..color = const Color(0xFF243A63);
    canvas.drawRect(Offset.zero & size, bg);
    _drawUnitBadge(canvas, size);

    if (samples.length < 2) return;

    final minY = samples
        .map((s) => math.min(s.terrainMeters, s.lineHeightMeters))
        .reduce(math.min);
    final maxY = samples
        .map((s) => math.max(s.terrainMeters, s.lineHeightMeters))
        .reduce(math.max);
    final ySpan = math.max(1.0, maxY - minY);
    final maxDist = math.max(1.0, samples.last.distanceMeters);

    Offset mapPoint(double x, double y) {
      final px = (x / maxDist) * size.width;
      final py = size.height - ((y - minY) / ySpan) * size.height;
      return Offset(px, py);
    }

    final terrainPath = ui.Path();
    terrainPath.moveTo(0, size.height);
    for (final s in samples) {
      final p = mapPoint(s.distanceMeters, s.terrainMeters);
      terrainPath.lineTo(p.dx, p.dy);
    }
    terrainPath.lineTo(size.width, size.height);
    terrainPath.close();

    canvas.drawPath(terrainPath, Paint()..color = const Color(0xCC7C6F5D));

    final terrainLine = ui.Path();
    for (int i = 0; i < samples.length; i++) {
      final p = mapPoint(samples[i].distanceMeters, samples[i].terrainMeters);
      if (i == 0) {
        terrainLine.moveTo(p.dx, p.dy);
      } else {
        terrainLine.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      terrainLine,
      Paint()
        ..color = const Color(0xFF9FE870)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final losLine = ui.Path();
    for (int i = 0; i < samples.length; i++) {
      final p = mapPoint(
        samples[i].distanceMeters,
        samples[i].lineHeightMeters,
      );
      if (i == 0) {
        losLine.moveTo(p.dx, p.dy);
      } else {
        losLine.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      losLine,
      Paint()
        ..color = const Color(0xFFE0E7FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _LosProfilePainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.distanceUnit != distanceUnit ||
        oldDelegate.heightUnit != heightUnit ||
        oldDelegate.badgeTextStyle != badgeTextStyle;
  }

  void _drawUnitBadge(Canvas canvas, Size size) {
    final span = TextSpan(
      text: '$heightUnit / $distanceUnit',
      style: badgeTextStyle,
    );
    final painter = TextPainter(text: span, textDirection: TextDirection.ltr)
      ..layout();
    painter.paint(canvas, Offset(size.width - painter.width - 8, 8));
  }
}
