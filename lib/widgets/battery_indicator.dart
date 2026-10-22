import 'package:flutter/material.dart';

import '../connector/meshcore_connector.dart';
import '../theme/app_colors.dart';

class BatteryUi {
  final IconData icon;
  final Color? color;
  const BatteryUi(this.icon, this.color);
}

BatteryUi batteryUiForPercent(BuildContext context, int? percent) {
  final colorScheme = Theme.of(context).colorScheme;
  if (percent == null) {
    return BatteryUi(Icons.battery_unknown, colorScheme.outline);
  }

  final p = percent.clamp(0, 100);

  return switch (p) {
    <= 5 => BatteryUi(Icons.battery_alert, colorScheme.error),
    <= 15 => BatteryUi(Icons.battery_0_bar, colorScheme.error),
    <= 30 => BatteryUi(Icons.battery_1_bar, colorScheme.tertiary),
    <= 45 => BatteryUi(Icons.battery_2_bar, colorScheme.tertiary),
    <= 60 => BatteryUi(Icons.battery_3_bar, context.appColors.connected),
    <= 80 => BatteryUi(Icons.battery_5_bar, context.appColors.connected),
    _ => BatteryUi(Icons.battery_full, context.appColors.connected),
  };
}

class BatteryIndicator extends StatefulWidget {
  final MeshCoreConnector connector;

  const BatteryIndicator({super.key, required this.connector});

  @override
  State<BatteryIndicator> createState() => _BatteryIndicatorState();
}

class _BatteryIndicatorState extends State<BatteryIndicator> {
  bool _showBatteryVoltage = false;

  @override
  Widget build(BuildContext context) {
    final percent = widget.connector.batteryPercent;
    final millivolts = widget.connector.batteryMillivolts;

    // A zero reading means the companion did not report a battery voltage.
    // Treat it as unavailable rather than showing a misleading 0% battery.
    if (millivolts == null || millivolts <= 0) {
      return const SizedBox.shrink();
    }

    final String displayText;
    if (_showBatteryVoltage) {
      displayText = '${(millivolts / 1000.0).toStringAsFixed(2)}V';
    } else {
      displayText = percent != null ? '$percent%' : '—';
    }

    final batteryUi = batteryUiForPercent(context, percent);

    return InkWell(
      onTap: () {
        setState(() {
          _showBatteryVoltage = !_showBatteryVoltage;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(batteryUi.icon, size: 18, color: batteryUi.color),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: batteryUi.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
