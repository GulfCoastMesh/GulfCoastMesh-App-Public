import 'package:latlong2/latlong.dart';

bool shouldBroadcastAtakPosition({
  required double? lat,
  required double? lon,
  required double? lastLat,
  required double? lastLon,
  required DateTime? lastSentAt,
  required int minIntervalSec,
  required double movementMeters,
  required DateTime now,
}) {
  if (lat == null || lon == null) return false;

  if (lastSentAt != null) {
    final elapsed = now.difference(lastSentAt).inSeconds;
    if (elapsed < minIntervalSec) return false;
  }

  if (lastLat == null || lastLon == null || lastSentAt == null) {
    return true;
  }

  const distance = Distance();
  final moved = distance(LatLng(lastLat, lastLon), LatLng(lat, lon));
  return moved >= movementMeters;
}
