import 'package:flutter/material.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/widgets/battery_indicator.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_protocol.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import 'snr_indicator.dart';

class AppBarTitle extends StatelessWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  const AppBarTitle(this.title, {this.leading, this.trailing, super.key});

  @override
  Widget build(BuildContext context) {
    final connector = context.watch<MeshCoreConnector>();
    final selfName = connector.selfName;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final compact = availableWidth < 240;
        final showSubtitle =
            !compact && connector.isConnected && selfName != null;
        final showBattery = availableWidth >= 60;
        final showSnr = availableWidth >= 110;
        final showIndicators = showBattery || showSnr;

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            leading ?? const SizedBox.shrink(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(width: 8),
                        _ConnectionStatusPill(connector: connector),
                      ],
                    ],
                  ),
                  if (showSubtitle)
                    Text(
                      '($selfName)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (showSubtitle && connector.selfPublicKey != null)
                    Text(
                      pubKeyToHex(connector.selfPublicKey!).substring(0, 16),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (showIndicators) const SizedBox(width: 6),
            if (showIndicators)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBattery) BatteryIndicator(connector: connector),
                  if (showSnr) SNRIndicator(connector: connector),
                ],
              ),
            trailing ?? const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}

class _ConnectionStatusPill extends StatelessWidget {
  final MeshCoreConnector connector;

  const _ConnectionStatusPill({required this.connector});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isConnected = connector.isConnected;
    final isReconnecting = connector.isReconnecting;
    final isRepeating =
        connector.clientRepeat == true &&
        connector.selfName != null &&
        isConnected;

    final Color dotColor;
    final Color bgColor;
    final String label;

    if (isReconnecting) {
      dotColor = colors.connecting;
      bgColor = colors.connecting.withValues(alpha: 0.12);
      label = context.l10n.common_reconnecting;
    } else if (!isConnected) {
      dotColor = colors.disconnected;
      bgColor = colors.disconnected.withValues(alpha: 0.12);
      label = context.l10n.common_disconnected;
    } else if (isRepeating) {
      dotColor = colors.repeatMode;
      bgColor = colors.connectionRepeatBg;
      label = context.l10n.status_repeat;
    } else {
      dotColor = colors.connected;
      bgColor = colors.connectionReadyBg;
      label = context.l10n.common_connected;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}
