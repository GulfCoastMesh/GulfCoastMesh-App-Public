import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import 'map_initial_location.dart';

mixin UserMapCenterMixin<T extends StatefulWidget> on State<T> {
  LatLng? _userMapCenter;
  bool _userCenterApplied = false;

  LatLng get userMapCenterOrFallback => _userMapCenter ?? kFallbackMapCenter;

  double get userMapZoomOrFallback =>
      _userMapCenter != null ? kUserLocationZoom : kWorldZoom;

  void initUserMapCenter({
    MeshCoreConnector? connector,
    MapController? mapController,
    double zoom = kUserLocationZoom,
    bool applyMove = true,
  }) {
    if (connector != null) {
      final sync = syncMapCenterFromConnector(connector);
      if (sync != null) {
        _userMapCenter = sync;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final resolvedConnector = connector ?? context.read<MeshCoreConnector>();
      _resolveUserMapCenter(
        connector: resolvedConnector,
        mapController: mapController,
        zoom: zoom,
        applyMove: applyMove,
      );
    });
  }

  Future<void> _resolveUserMapCenter({
    required MeshCoreConnector connector,
    MapController? mapController,
    required double zoom,
    required bool applyMove,
  }) async {
    final center = await resolveUserMapCenter(connector: connector);
    if (!mounted || center == null) return;

    final shouldMove =
        applyMove && mapController != null && !_userCenterApplied;
    setState(() {
      _userMapCenter = center;
      if (shouldMove) {
        _userCenterApplied = true;
      }
    });

    if (shouldMove) {
      mapController.move(center, zoom);
    }
  }
}
