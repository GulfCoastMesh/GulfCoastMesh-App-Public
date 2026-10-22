import 'package:flutter/material.dart';

/// A compact line chart for one telemetry series.
///
/// Hand-drawn rather than pulling in a charting package: the app needs a
/// trend line, not an interactive chart, and this matches the existing
/// hand-rolled indicators (signal_bars, snr_indicator).
class TelemetrySparkline extends StatelessWidget {
  const TelemetrySparkline({
    super.key,
    required this.values,
    this.color,
    this.height = 48,
  });

  /// Oldest first. Nulls are gaps — a sample that lacked this metric — and
  /// break the line rather than being drawn as zero.
  final List<double?> values;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: lineColor,
          fillColor: lineColor.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.fillColor,
  });

  final List<double?> values;
  final Color color;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final present = values.whereType<double>().toList();
    if (present.length < 2) return;

    var min = present.first;
    var max = present.first;
    for (final value in present) {
      if (value < min) min = value;
      if (value > max) max = value;
    }
    // A flat series would divide by zero; centre it instead.
    final range = (max - min).abs() < 1e-9 ? 1.0 : max - min;
    final flat = (max - min).abs() < 1e-9;

    final dx = values.length > 1
        ? size.width / (values.length - 1)
        : size.width;

    Offset pointAt(int index, double value) {
      final normalized = flat ? 0.5 : (value - min) / range;
      return Offset(dx * index, size.height - normalized * size.height);
    }

    final stroke = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Each run of consecutive non-null values is its own path, so gaps in the
    // history read as gaps instead of a straight line across missing time.
    var index = 0;
    while (index < values.length) {
      if (values[index] == null) {
        index++;
        continue;
      }
      final runStart = index;
      final path = Path();
      var first = true;
      while (index < values.length && values[index] != null) {
        final point = pointAt(index, values[index]!);
        if (first) {
          path.moveTo(point.dx, point.dy);
          first = false;
        } else {
          path.lineTo(point.dx, point.dy);
        }
        index++;
      }
      final runEnd = index - 1;

      if (runEnd > runStart) {
        canvas.drawPath(path, stroke);
        final fill = Path.from(path)
          ..lineTo(dx * runEnd, size.height)
          ..lineTo(dx * runStart, size.height)
          ..close();
        canvas.drawPath(fill, Paint()..color = fillColor);
      } else {
        // A lone point still deserves to be visible.
        canvas.drawCircle(
          pointAt(runStart, values[runStart]!),
          2,
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.color != color || !_sameValues(oldDelegate.values, values);

  static bool _sameValues(List<double?> a, List<double?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
