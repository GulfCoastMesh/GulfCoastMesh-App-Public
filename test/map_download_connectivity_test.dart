import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/services/map_download_connectivity.dart';

void main() {
  test('allows Wi-Fi and ethernet', () async {
    expect(
      await isOnWifiForMapDownload(
        connectivityCheck: () async => [ConnectivityResult.wifi],
      ),
      isTrue,
    );
    expect(
      await isOnWifiForMapDownload(
        connectivityCheck: () async => [ConnectivityResult.ethernet],
      ),
      isTrue,
    );
  });

  test('blocks cellular', () async {
    expect(
      await isOnWifiForMapDownload(
        connectivityCheck: () async => [ConnectivityResult.mobile],
      ),
      isFalse,
    );
  });
}
