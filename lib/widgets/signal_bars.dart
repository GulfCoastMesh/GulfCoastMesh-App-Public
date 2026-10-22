import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SignalBars extends StatelessWidget {
  final double? snr;
  final double size;

  const SignalBars({super.key, this.snr, this.size = 16});

  static int _barsForSnr(double snr) {
    if (snr >= 15) return 4;
    if (snr >= 7) return 3;
    if (snr >= 0) return 2;
    if (snr >= -10) return 1;
    return 0;
  }

  static Color _colorForSnr(double snr) {
    if (snr >= 7) return AppColors.signalExcellent;
    if (snr >= 0) return AppColors.signalGood;
    if (snr >= -10) return AppColors.signalWeak;
    return AppColors.signalNone;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (snr == null) {
      return Icon(
        Icons.signal_cellular_alt,
        size: size,
        color: colorScheme.outline,
      );
    }

    final bars = _barsForSnr(snr!);
    final color = _colorForSnr(snr!);
    final barWidth = size * 0.22;

    return SizedBox(
      width: size,
      height: size,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final active = index < bars;
          final barHeight = size * (0.3 + index * 0.22);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: barWidth * 0.2),
            child: Container(
              width: barWidth,
              height: barHeight,
              decoration: BoxDecoration(
                color: active ? color : colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }),
      ),
    );
  }
}
