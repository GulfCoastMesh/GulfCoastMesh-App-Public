import 'package:flutter/material.dart';

import '../connector/meshcore_device.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

/// A reusable tile widget for displaying a MeshCore device in a list.
class DeviceTile extends StatelessWidget {
  final MeshCoreDevice device;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const DeviceTile({
    super.key,
    required this.device,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeading(context),
      title: Text(
        device.displayName.isNotEmpty
            ? device.displayName
            : context.l10n.common_unknownDevice,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(device.subtitle ?? device.id),
      trailing: ElevatedButton(
        onPressed: onTap,
        child: Text(context.l10n.common_connect),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget _buildLeading(BuildContext context) {
    // Only radio transports report a signal level; USB and TCP fall back to an
    // icon naming the transport instead.
    if (device.rssi != null) {
      return _buildSignalIcon(device.rssi!);
    }

    return Icon(switch (device.transportKind) {
      MeshCoreTransportKind.ble => Icons.bluetooth,
      MeshCoreTransportKind.usb => Icons.usb,
      MeshCoreTransportKind.tcp => Icons.lan_outlined,
    });
  }

  Widget _buildSignalIcon(int rssi) {
    IconData icon;
    Color color;

    if (rssi >= -60) {
      icon = Icons.signal_cellular_4_bar;
      color = AppColors.signalExcellent;
    } else if (rssi >= -70) {
      icon = Icons.signal_cellular_alt;
      color = AppColors.signalGood;
    } else if (rssi >= -80) {
      icon = Icons.signal_cellular_alt_2_bar;
      color = AppColors.signalWeak;
    } else {
      icon = Icons.signal_cellular_alt_1_bar;
      color = AppColors.signalNone;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Text('$rssi dBm', style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }
}
