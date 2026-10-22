import 'package:connectivity_plus/connectivity_plus.dart';

typedef MapConnectivityCheck = Future<List<ConnectivityResult>> Function();

/// Returns true when map tile bulk downloads are allowed (Wi‑Fi or Ethernet).
Future<bool> isOnWifiForMapDownload({
  MapConnectivityCheck? connectivityCheck,
}) async {
  final check = connectivityCheck ?? () => Connectivity().checkConnectivity();
  final results = await check();
  return results.any(_isAllowedForMapDownload);
}

bool _isAllowedForMapDownload(ConnectivityResult result) {
  switch (result) {
    case ConnectivityResult.wifi:
    case ConnectivityResult.ethernet:
    case ConnectivityResult.vpn:
      return true;
    case ConnectivityResult.mobile:
    case ConnectivityResult.bluetooth:
    case ConnectivityResult.satellite:
    case ConnectivityResult.other:
    case ConnectivityResult.none:
      return false;
  }
}
