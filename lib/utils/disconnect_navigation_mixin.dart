import 'package:flutter/material.dart';
import '../connector/meshcore_connector.dart';

/// Mixin that navigates back to scanner when the BLE session is truly over.
/// Unexpected drops and in-progress reconnect keep the hub on screen.
mixin DisconnectNavigationMixin<T extends StatefulWidget> on State<T> {
  /// Call this in your Widget build method to enable auto-navigation.
  /// Returns true if the hub should stay, false if navigation was triggered.
  bool checkConnectionAndNavigate(MeshCoreConnector connector) {
    if (connector.shouldKeepHub) return true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
    return false;
  }
}
