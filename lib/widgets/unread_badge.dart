import 'package:flutter/material.dart';

class UnreadBadge extends StatelessWidget {
  final int count;
  final Color? color;

  const UnreadBadge({super.key, required this.count, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final display = count > 99 ? '99+' : count.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? colorScheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        display,
        style: TextStyle(
          color: colorScheme.onError,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
