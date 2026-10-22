import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../helpers/user_map_center_mixin.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/map_offline_region.dart';
import '../services/app_settings_service.dart';
import '../services/map_download_connectivity.dart';
import '../services/map_tile_cache_service.dart';
import '../widgets/adaptive_app_bar_title.dart';
import '../widgets/cached_osm_tile_layer.dart';

class MapCacheScreen extends StatefulWidget {
  const MapCacheScreen({super.key});

  @override
  State<MapCacheScreen> createState() => _MapCacheScreenState();
}

class _MapCacheScreenState extends State<MapCacheScreen>
    with UserMapCenterMixin {
  final MapController _mapController = MapController();

  LatLngBounds? _selectedBounds;
  int _minZoom = MapTileCacheService.defaultMinZoom;
  int _maxZoom = MapTileCacheService.defaultMaxZoom;
  int _worldMinZoom = kMapWorldOverviewDefaultMinZoom;
  int _worldMaxZoom = kMapWorldOverviewDefaultMaxZoom;
  final Map<String, int> _presetMinZoom = {};
  final Map<String, int> _presetMaxZoom = {};

  int _estimatedTiles = 0;
  int _downloadTotalTiles = 0;
  bool _isDownloading = false;
  int _completedTiles = 0;
  int _failedTiles = 0;

  @override
  void initState() {
    super.initState();
    for (final preset in kMapOfflinePresets) {
      _presetMinZoom[preset.id] = preset.defaultMinZoom;
      _presetMaxZoom[preset.id] = preset.defaultMaxZoom;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final settings = context.read<AppSettingsService>().settings;
    final bounds = MapTileCacheService.boundsFromJson(settings.mapCacheBounds);
    final minZoom = settings.mapCacheMinZoom.clamp(3, 18);
    final maxZoom = settings.mapCacheMaxZoom.clamp(3, 18);
    final worldMin = settings.mapCacheWorldMinZoom.clamp(2, 6);
    final worldMax = settings.mapCacheWorldMaxZoom.clamp(2, 6);
    final safeMin = minZoom <= maxZoom ? minZoom : maxZoom;
    final safeMax = minZoom <= maxZoom ? maxZoom : minZoom;
    final safeWorldMin = worldMin <= worldMax ? worldMin : worldMax;
    final safeWorldMax = worldMin <= worldMax ? worldMax : worldMin;
    setState(() {
      _minZoom = safeMin;
      _maxZoom = safeMax;
      _worldMinZoom = safeWorldMin;
      _worldMaxZoom = safeWorldMax;
      _selectedBounds = bounds;
    });
    _updateCustomEstimate();
    if (bounds != null) {
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
      );
    } else {
      initUserMapCenter(mapController: _mapController);
    }
  }

  void _updateCustomEstimate() {
    if (_selectedBounds == null) {
      setState(() {
        _estimatedTiles = 0;
      });
      return;
    }
    final cacheService = context.read<MapTileCacheService>();
    final count = cacheService.estimateTileCount(
      _selectedBounds!,
      _minZoom,
      _maxZoom,
    );
    setState(() {
      _estimatedTiles = count;
    });
  }

  int _estimateForSpec(MapOfflineDownloadSpec spec) {
    return context.read<MapTileCacheService>().estimateTileCount(
      spec.bounds,
      spec.minZoom,
      spec.maxZoom,
    );
  }

  List<MapOfflineDownloadSpec> _allDownloadSpecs() {
    final specs = <MapOfflineDownloadSpec>[
      MapOfflineDownloadSpec(
        bounds: kWorldOverviewBounds,
        minZoom: _worldMinZoom,
        maxZoom: _worldMaxZoom,
      ),
      ...kMapOfflinePresets.map(
        (preset) => preset.toDownloadSpec(
          minZoom: _presetMinZoom[preset.id],
          maxZoom: _presetMaxZoom[preset.id],
        ),
      ),
    ];
    final custom = _selectedBounds;
    if (custom != null) {
      specs.add(
        MapOfflineDownloadSpec(
          bounds: custom,
          minZoom: _minZoom,
          maxZoom: _maxZoom,
        ),
      );
    }
    return specs;
  }

  Future<bool> _ensureWifi() async {
    if (await isOnWifiForMapDownload()) return true;
    if (!mounted) return false;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.mapCache_wifiRequired)));
    return false;
  }

  Future<void> _setBoundsFromView() async {
    final bounds = _mapController.camera.visibleBounds;
    await _saveBounds(bounds);
  }

  Future<void> _saveBounds(LatLngBounds bounds) async {
    setState(() {
      _selectedBounds = bounds;
    });
    final settings = context.read<AppSettingsService>();
    await settings.setMapCacheBounds(MapTileCacheService.boundsToJson(bounds));
    if (!mounted) return;
    _updateCustomEstimate();
  }

  Future<void> _clearBounds() async {
    setState(() {
      _selectedBounds = null;
      _estimatedTiles = 0;
    });
    final settings = context.read<AppSettingsService>();
    await settings.setMapCacheBounds(null);
  }

  Future<void> _saveZoomRange() async {
    final settings = context.read<AppSettingsService>();
    await settings.setMapCacheZoomRange(_minZoom, _maxZoom);
    if (!mounted) return;
    _updateCustomEstimate();
  }

  Future<void> _saveWorldZoomRange() async {
    final settings = context.read<AppSettingsService>();
    await settings.setMapCacheWorldZoomRange(_worldMinZoom, _worldMaxZoom);
  }

  Future<bool> _confirmDownload(int tileCount) async {
    if (tileCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.mapCache_noTilesToDownload)),
      );
      return false;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.mapCache_downloadTilesTitle),
        content: Text(context.l10n.mapCache_downloadTilesPrompt(tileCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.mapCache_downloadAction),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _runDownload(List<MapOfflineDownloadSpec> specs) async {
    if (!await _ensureWifi()) return;
    if (!mounted) return;

    final cacheService = context.read<MapTileCacheService>();
    final total = cacheService.estimateTileCountForRegions(specs);
    if (!await _confirmDownload(total)) return;
    if (!mounted) return;

    setState(() {
      _isDownloading = true;
      _downloadTotalTiles = total;
      _completedTiles = 0;
      _failedTiles = 0;
    });

    try {
      final result = await cacheService.downloadRegions(
        regions: specs,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _completedTiles = progress.completed;
            _failedTiles = progress.failed;
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _completedTiles = result.downloaded + result.failed;
        _failedTiles = result.failed;
        _downloadTotalTiles = result.total;
      });

      final message = result.failed > 0
          ? context.l10n.mapCache_cachedTilesWithFailed(
              result.downloaded,
              result.failed,
            )
          : context.l10n.mapCache_cachedTiles(result.downloaded);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settings_error(error.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _downloadWorld() async {
    await _runDownload([
      MapOfflineDownloadSpec(
        bounds: kWorldOverviewBounds,
        minZoom: _worldMinZoom,
        maxZoom: _worldMaxZoom,
      ),
    ]);
  }

  Future<void> _downloadPreset(MapOfflinePreset preset) async {
    await _runDownload([
      preset.toDownloadSpec(
        minZoom: _presetMinZoom[preset.id],
        maxZoom: _presetMaxZoom[preset.id],
      ),
    ]);
  }

  Future<void> _downloadCustom() async {
    final bounds = _selectedBounds;
    if (bounds == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.mapCache_selectAreaFirst)),
      );
      return;
    }
    await _runDownload([
      MapOfflineDownloadSpec(
        bounds: bounds,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
      ),
    ]);
  }

  Future<void> _downloadAll() async {
    await _runDownload(_allDownloadSpecs());
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.mapCache_clearOfflineCacheTitle),
        content: Text(context.l10n.mapCache_clearOfflineCachePrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.common_clear),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final cacheService = context.read<MapTileCacheService>();
    await cacheService.clearCache();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.mapCache_offlineCacheCleared)),
    );
  }

  String _presetLabel(String id, AppLocalizations l10n) {
    switch (id) {
      case 'gulf_coast':
        return l10n.mapCache_presetGulfCoast;
      default:
        return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedBounds = _selectedBounds;
    final l10n = context.l10n;
    final progressTotal = _isDownloading && _downloadTotalTiles > 0
        ? _downloadTotalTiles
        : _estimatedTiles;
    final progressValue = progressTotal == 0
        ? 0.0
        : (_completedTiles / progressTotal).clamp(0.0, 1.0).toDouble();
    final worldTileEstimate = _estimateForSpec(
      MapOfflineDownloadSpec(
        bounds: kWorldOverviewBounds,
        minZoom: _worldMinZoom,
        maxZoom: _worldMaxZoom,
      ),
    );
    final allTilesEstimate = context
        .read<MapTileCacheService>()
        .estimateTileCountForRegions(_allDownloadSpecs());

    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(l10n.mapCache_title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: userMapCenterOrFallback,
                    initialZoom: userMapZoomOrFallback,
                    minZoom: 2.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    const CachedOsmTileLayer(),
                    if (selectedBounds != null)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _boundsToPolygon(selectedBounds),
                            borderStrokeWidth: 2,
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderColor: Colors.blue,
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        selectedBounds == null
                            ? l10n.mapCache_noAreaSelected
                            : _formatBounds(selectedBounds, l10n),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.mapCache_worldOverview,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.mapCache_worldOverviewHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    RangeSlider(
                      values: RangeValues(
                        _worldMinZoom.toDouble(),
                        _worldMaxZoom.toDouble(),
                      ),
                      min: 2,
                      max: 6,
                      divisions: 4,
                      labels: RangeLabels('$_worldMinZoom', '$_worldMaxZoom'),
                      onChanged: _isDownloading
                          ? null
                          : (values) {
                              setState(() {
                                _worldMinZoom = values.start.round();
                                _worldMaxZoom = values.end.round();
                              });
                            },
                      onChangeEnd: _isDownloading
                          ? null
                          : (_) {
                              _saveWorldZoomRange();
                            },
                    ),
                    Text(l10n.mapCache_estimatedTiles(worldTileEstimate)),
                    if (_worldMaxZoom > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.mapCache_worldZoomHighWarning,
                          style: TextStyle(
                            color: colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.public),
                        label: Text(l10n.mapCache_downloadWorldButton),
                        onPressed: _isDownloading ? null : _downloadWorld,
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      l10n.mapCache_presetAreas,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...kMapOfflinePresets.map((preset) {
                      final minZ = _presetMinZoom[preset.id]!;
                      final maxZ = _presetMaxZoom[preset.id]!;
                      final estimate = _estimateForSpec(
                        preset.toDownloadSpec(minZoom: minZ, maxZoom: maxZ),
                      );
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _presetLabel(preset.id, l10n),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              RangeSlider(
                                values: RangeValues(
                                  minZ.toDouble(),
                                  maxZ.toDouble(),
                                ),
                                min: 3,
                                max: 18,
                                divisions: 15,
                                labels: RangeLabels('$minZ', '$maxZ'),
                                onChanged: _isDownloading
                                    ? null
                                    : (values) {
                                        setState(() {
                                          _presetMinZoom[preset.id] = values
                                              .start
                                              .round();
                                          _presetMaxZoom[preset.id] = values.end
                                              .round();
                                        });
                                      },
                              ),
                              Text(l10n.mapCache_estimatedTiles(estimate)),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.download),
                                  label: Text(l10n.mapCache_downloadAction),
                                  onPressed: _isDownloading
                                      ? null
                                      : () => _downloadPreset(preset),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const Divider(height: 24),
                    Text(
                      l10n.mapCache_customArea,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.crop_free),
                            label: Text(l10n.mapCache_useCurrentView),
                            onPressed: _isDownloading
                                ? null
                                : _setBoundsFromView,
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _isDownloading || selectedBounds == null
                              ? null
                              : _clearBounds,
                          child: Text(l10n.common_clear),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.mapCache_zoomRange,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    RangeSlider(
                      values: RangeValues(
                        _minZoom.toDouble(),
                        _maxZoom.toDouble(),
                      ),
                      min: 3,
                      max: 18,
                      divisions: 15,
                      labels: RangeLabels('$_minZoom', '$_maxZoom'),
                      onChanged: _isDownloading
                          ? null
                          : (values) {
                              setState(() {
                                _minZoom = values.start.round();
                                _maxZoom = values.end.round();
                              });
                            },
                      onChangeEnd: _isDownloading
                          ? null
                          : (_) {
                              _saveZoomRange();
                            },
                    ),
                    Text(l10n.mapCache_estimatedTiles(_estimatedTiles)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.download),
                        label: Text(l10n.mapCache_downloadTilesButton),
                        onPressed: _isDownloading || selectedBounds == null
                            ? null
                            : _downloadCustom,
                      ),
                    ),
                    const Divider(height: 24),
                    if (_isDownloading) ...[
                      LinearProgressIndicator(value: progressValue),
                      const SizedBox(height: 4),
                      Text(
                        l10n.mapCache_downloadedTiles(
                          _completedTiles,
                          progressTotal,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      l10n.mapCache_downloadAllSummary(allTilesEstimate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_download),
                            label: Text(l10n.mapCache_downloadAllButton),
                            onPressed: _isDownloading ? null : _downloadAll,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _isDownloading ? null : _clearCache,
                          child: Text(l10n.mapCache_clearCacheButton),
                        ),
                      ],
                    ),
                    if (_failedTiles > 0 && !_isDownloading)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.mapCache_failedDownloads(_failedTiles),
                          style: TextStyle(color: colorScheme.error),
                        ),
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

  List<LatLng> _boundsToPolygon(LatLngBounds bounds) {
    return [
      bounds.northWest,
      bounds.northEast,
      bounds.southEast,
      bounds.southWest,
    ];
  }

  String _formatBounds(LatLngBounds bounds, AppLocalizations l10n) {
    return l10n.mapCache_boundsLabel(
      bounds.north.toStringAsFixed(4),
      bounds.south.toStringAsFixed(4),
      bounds.east.toStringAsFixed(4),
      bounds.west.toStringAsFixed(4),
    );
  }
}
