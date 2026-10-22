import 'package:flutter/material.dart';

class RelativeTimestampText extends StatelessWidget {
  final DateTime timestamp;
  final TextStyle? style;
  final bool showAbsoluteTime;

  const RelativeTimestampText(
    this.timestamp, {
    super.key,
    this.style,
    this.showAbsoluteTime = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        style ?? Theme.of(context).textTheme.bodySmall ?? const TextStyle();

    if (!showAbsoluteTime) {
      return Text(_relativeTime(context), style: effectiveStyle);
    }

    final elements = [
      TextSpan(text: _relativeTime(context)),
      const TextSpan(text: ' · '),
      TextSpan(text: _formatAbsoluteTime(context)),
    ];

    return RichText(
      text: TextSpan(style: effectiveStyle, children: elements),
    );
  }

  String _relativeTime(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.isNegative) return 'Now';

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 2) return '1 min ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 2) return '1 hour ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 2) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return _formatAbsoluteTime(context);
  }

  String _formatAbsoluteTime(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(timestamp),
    );
    return '${localizations.formatShortDate(timestamp)} $time';
  }
}
