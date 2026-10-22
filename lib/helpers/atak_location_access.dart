import 'package:geolocator/geolocator.dart';

bool _isGranted(LocationPermission permission) {
  return permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;
}

bool isValidMapCoordinate(double lat, double lon) {
  if (lat == 0 && lon == 0) return false;
  return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
}

({double lat, double lon, double? accuracyMeters})? _coordsFromPosition(
  Position position,
) {
  final lat = position.latitude;
  final lon = position.longitude;
  if (!isValidMapCoordinate(lat, lon)) return null;
  return (lat: lat, lon: lon, accuracyMeters: position.accuracy);
}

Future<bool> hasAtakLocationPermission() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return false;

  final permission = await Geolocator.checkPermission();
  return _isGranted(permission);
}

Future<bool> ensureAtakLocationPermission() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return false;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  return _isGranted(permission);
}

Future<({double lat, double lon, double? accuracyMeters})?>
readAtakPosition() async {
  if (!await hasAtakLocationPermission()) return null;

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    final coords = _coordsFromPosition(position);
    if (coords != null) return coords;
  } catch (_) {
    // Fall through to last known position.
  }

  try {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      return _coordsFromPosition(lastKnown);
    }
  } catch (_) {
    return null;
  }

  return null;
}
