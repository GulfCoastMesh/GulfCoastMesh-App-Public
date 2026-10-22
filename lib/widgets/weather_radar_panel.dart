import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../helpers/atak_location_access.dart';
import '../helpers/weather_api2_codec.dart';
import '../services/weather_api_service.dart';
import 'cached_osm_tile_layer.dart';

const weatherRadarColors = [
  Color(0x00000000),
  Color(0x9948b8ee),
  Color(0xaa36ad48),
  Color(0xbbeecc22),
  Color(0xccee8822),
  Color(0xccee3333),
  Color(0xccbb33cc),
  Color(0x66777777),
];
const weatherRadarLabels = [
  'No shading · Little or no rain or snow',
  'Blue · Very light',
  'Green · Light',
  'Yellow · Moderate',
  'Orange · Heavy',
  'Red · Very heavy',
  'Purple · Strongest',
  'Gray · No data available',
];

class WeatherRadarPanel extends StatefulWidget {
  const WeatherRadarPanel({super.key});
  @override
  State<WeatherRadarPanel> createState() => _WeatherRadarPanelState();
}

class _WeatherRadarPanelState extends State<WeatherRadarPanel>
    with AutomaticKeepAliveClientMixin {
  final _map = MapController();
  LatLng? _selected;
  int _hour = 0;
  bool _selectionChanged = false;
  bool _locating = false;
  String? _inputError;
  Map<String, dynamic>? _drawnRadar;
  List<Polygon> _polygons = [];
  @override
  bool get wantKeepAlive => true;

  void _select(LatLng point) {
    setState(() {
      _selected = point;
      _selectionChanged = true;
      _inputError = null;
    });
  }

  Future<void> _gps() async {
    setState(() {
      _locating = true;
      _inputError = null;
    });
    try {
      final granted = await ensureAtakLocationPermission();
      final position = granted ? await readAtakPosition() : null;
      if (!mounted) return;
      if (position == null) {
        setState(
          () => _inputError =
              'Location unavailable. Tap the map to choose a place.',
        );
      } else {
        final point = LatLng(position.lat, position.lon);
        _select(point);
        _map.move(point, 8);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _inputError = 'Could not read your location.');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _load() {
    final point = _selected;
    if (point == null) {
      setState(() => _inputError = 'Tap the map to choose a place first.');
      return;
    }
    final lat = point.latitude;
    final lon = point.longitude;
    _map.move(_selected!, 8);
    context.read<WeatherApiService>().requestRadar(lat, lon, _hour);
  }

  void _changeHour(int hour) {
    setState(() {
      _hour = hour;
      _selectionChanged = true;
    });
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final weather = context.watch<WeatherApiService>();
    final radar = weather.radar;
    if (!identical(radar, _drawnRadar)) {
      _drawnRadar = radar;
      if (radar != null) _selectionChanged = false;
      _polygons = radar == null ? [] : weatherRadarPolygons(radar);
    }
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = weather.supports(7) && !weather.isBusy && !_locating;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rain & snow',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A closer look at weather around you',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).width >= 700 ? 440 : 340,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: FlutterMap(
                        mapController: _map,
                        options: MapOptions(
                          initialCenter: const LatLng(30.45, -91.18),
                          initialZoom: 6,
                          onTap: enabled ? (_, point) => _select(point) : null,
                        ),
                        children: [
                          const CachedOsmTileLayer(),
                          PolygonLayer(polygons: _polygons),
                          if (radar != null)
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: LatLng(
                                    (radar['lat'] as num).toDouble(),
                                    (radar['lon'] as num).toDouble(),
                                  ),
                                  radius: 80467.2,
                                  useRadiusInMeter: true,
                                  color: Colors.transparent,
                                  borderColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  borderStrokeWidth: 2,
                                ),
                              ],
                            ),
                          if (_selected != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selected!,
                                  child: Icon(
                                    Icons.location_on,
                                    color: colors.onPrimaryContainer,
                                    shadows: [
                                      Shadow(
                                        color: colors.primaryContainer,
                                        blurRadius: 6,
                                      ),
                                    ],
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Material(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(12),
                                child: IconButton(
                                  tooltip: 'Back to selected place',
                                  onPressed: _selected == null
                                      ? null
                                      : () => _map.move(_selected!, 8),
                                  icon: const Icon(Icons.center_focus_strong),
                                ),
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.bottomRight,
                            child: Material(
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  '© OpenStreetMap contributors',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          radar == null
                              ? Icons.touch_app_outlined
                              : Icons.schedule,
                          size: 20,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            radar == null
                                ? 'Tap the map to choose a place. The circle will cover 50 miles around it.'
                                : weatherRadarCaption(radar),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          'Choose a time',
                          style: theme.textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          onPressed: enabled ? _gps : null,
                          icon: const Icon(Icons.my_location, size: 18),
                          label: Text(
                            _locating ? 'Locating…' : 'Use current location',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Previous hour',
                            onPressed: enabled && _hour > -5
                                ? () => _changeHour(_hour - 1)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                children: [
                                  Text(
                                    _hourLabel(_hour),
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _hour > 0
                                        ? 'Expected weather'
                                        : _hour < 0
                                        ? 'Earlier weather'
                                        : 'Latest available',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Next hour',
                            onPressed: enabled && _hour < 5
                                ? () => _changeHour(_hour + 1)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                    if (_hour != 0)
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: enabled ? () => _changeHour(0) : null,
                          child: const Text('Back to now'),
                        ),
                      ),
                    if (_selectionChanged && radar != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Place or time changed. Load radar to see your selection.',
                        ),
                      ),
                    if (!weather.supports(7))
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text('Radar is unavailable right now.'),
                      ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onPressed: enabled ? _load : null,
                      icon: const Icon(Icons.radar),
                      label: const Text('Load radar'),
                    ),
                    if (_inputError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _inputError!,
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const _RadarColorGuide(),
          ],
        ),
      ),
    );
  }
}

String _hourLabel(int hour) => hour == 0
    ? 'Now'
    : hour > 0
    ? 'In $hour ${hour == 1 ? 'hour' : 'hours'}'
    : '${hour.abs()} ${hour == -1 ? 'hour' : 'hours'} ago';

class _RadarColorGuide extends StatelessWidget {
  const _RadarColorGuide();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What the colors mean', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'How strong rain or snow may be',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  for (var i = 1; i <= 6; i++)
                    Expanded(
                      child: Container(
                        height: 10,
                        color: weatherRadarColors[i],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('Very light', style: theme.textTheme.labelSmall),
                ),
                Expanded(
                  child: Text(
                    'Strongest',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns =
                    constraints.maxWidth >= 300 &&
                    MediaQuery.textScalerOf(context).scale(1) <= 1.3;
                final width = twoColumns
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    for (final i in [1, 2, 3, 4, 5, 6, 0, 7])
                      SizedBox(
                        width: i == 0 || i == 7 ? constraints.maxWidth : width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(top: 3),
                              decoration: BoxDecoration(
                                color: weatherRadarColors[i],
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: colors.outlineVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                weatherRadarLabels[i],
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: 12),
            Text(
              'Weather is shown inside the circle only. Gray means no data is available. Covers the lower 48 U.S. states.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String weatherRadarCaption(Map<String, dynamic> radar) {
  String time(int value) => DateFormat('MMM d, h:mm a').format(
    DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true).toLocal(),
  );
  final forecast = radar['s'] == 'forecast';
  return '${forecast ? 'Expected weather' : 'Recorded weather'} • ${time(radar['v'] as int)} (local time)'
      '${forecast ? '\nAn estimate of what may happen. Updated ${time(radar['i'] as int)}.' : ''}';
}

/// Great-circle placement on the API's 6371.0088 km sphere.
LatLng weatherRadarPoint(double lat, double lon, double east, double north) {
  final distance = math.sqrt(east * east + north * north) / 6371.0088;
  final bearing = math.atan2(east, north);
  final latitude = lat * math.pi / 180;
  final longitude = lon * math.pi / 180;
  final phi = math.asin(
    math.sin(latitude) * math.cos(distance) +
        math.cos(latitude) * math.sin(distance) * math.cos(bearing),
  );
  final lambda =
      longitude +
      math.atan2(
        math.sin(bearing) * math.sin(distance) * math.cos(latitude),
        math.cos(distance) - math.sin(latitude) * math.sin(phi),
      );
  return LatLng(
    phi * 180 / math.pi,
    (lambda * 180 / math.pi + 540) % 360 - 180,
  );
}

List<Polygon> weatherRadarPolygons(Map<String, dynamic> radar) {
  final width = radar['n'] as int;
  final cells = radar['c'] as List;
  final lat = (radar['lat'] as num).toDouble();
  final lon = (radar['lon'] as num).toDouble();
  LatLng corner(int x, int y) => weatherRadarPoint(
    lat,
    lon,
    (x / width * 2 - 1) * 80.4672,
    (1 - y / width * 2) * 80.4672,
  );
  final polygons = <Polygon>[];
  var index = 0;
  for (var y = 0; y < width; y++) {
    for (var x = 0; x < width; x++) {
      if (!weatherRadarIncludesCell(x, y, width)) continue;
      final code = cells[index++] as int;
      if (code == 0) continue;
      polygons.add(
        Polygon(
          points: [
            corner(x, y),
            corner(x + 1, y),
            corner(x + 1, y + 1),
            corner(x, y + 1),
          ],
          color: weatherRadarColors[code],
          borderStrokeWidth: 0,
        ),
      );
    }
  }
  return polygons;
}
