import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

class MessageStatusIcon extends StatelessWidget {
  final bool isAcked;
  final bool isFailed;
  final double size;

  const MessageStatusIcon({
    super.key,
    required this.isAcked,
    this.isFailed = false,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    if (isFailed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cancel,
            size: size,
            color: colorScheme.error.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 4),
          Text(
            l10n.messageStatus_failed,
            style: TextStyle(
              fontSize: size * 0.75,
              color: colorScheme.error.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (isAcked) {
      return Tooltip(
        message: l10n.messageStatus_deliveredTooltip,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: size, color: colorScheme.tertiary),
            const SizedBox(width: 4),
            Text(
              l10n.messageStatus_delivered,
              style: TextStyle(
                fontSize: size * 0.75,
                color: colorScheme.tertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check, size: size, color: colorScheme.outlineVariant),
        const SizedBox(width: 4),
        Text(
          l10n.messageStatus_sent,
          style: TextStyle(
            fontSize: size * 0.75,
            color: colorScheme.outlineVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
