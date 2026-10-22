import 'package:latlong2/latlong.dart';

import '../connector/meshcore_connector.dart';
import 'atak_location_access.dart';

const kFallbackMapCenter = LatLng(20.0, 0.0);
const kUserLocationZoom = 15.0;
const kWorldZoom = 3.0;

LatLng? syncMapCenterFromConnector(MeshCoreConnector connector) {
  final lat = connector.selfLatitude;
  final lon = connector.selfLongitude;
  if (lat == null || lon == null) return null;
  if (!isValidMapCoordinate(lat, lon)) return null;
  return LatLng(lat, lon);
}

Future<LatLng?> resolveUserMapCenter({MeshCoreConnector? connector}) async {
  final gps = await readAtakPosition();
  if (gps != null && isValidMapCoordinate(gps.lat, gps.lon)) {
    return LatLng(gps.lat, gps.lon);
  }
  if (connector != null) {
    return syncMapCenterFromConnector(connector);
  }
  return null;
}
