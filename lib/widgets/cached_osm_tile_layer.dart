import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../services/map_tile_cache_service.dart';

/// OSM tile layer that reads through [MapTileCacheService] (cache-first).
class CachedOsmTileLayer extends StatelessWidget {
  const CachedOsmTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final tileCache = context.read<MapTileCacheService>();
    return TileLayer(
      urlTemplate: kMapTileUrlTemplate,
      tileProvider: tileCache.tileProvider,
      userAgentPackageName: MapTileCacheService.userAgentPackageName,
      maxZoom: 19,
    );
  }
}
