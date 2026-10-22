import 'package:flutter/material.dart';

/// Shared visual treatment for the analyzer's map and information panels.
class AnalyzerSurface extends StatelessWidget {
  const AnalyzerSurface({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 3)),
      ],
    ),
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: .6),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    ),
  );
}

class AnalyzerArrival extends StatelessWidget {
  const AnalyzerArrival({
    super.key,
    required this.child,
    required this.animate,
  });
  final Widget child;
  final bool animate;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: animate ? 0 : 1, end: 1),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 240),
    curve: Curves.easeOutCubic,
    child: child,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(12 * (1 - value), 0),
        child: child,
      ),
    ),
  );
}
