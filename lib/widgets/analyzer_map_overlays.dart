import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../connector/meshcore_protocol.dart';
import '../l10n/l10n.dart';
import '../models/analyzer_packet.dart';
import '../models/contact.dart';
import '../services/mesh_analyzer_state.dart';

/// Only this layer repaints on animation frames; tiles and panels stay still.
class AnalyzerTrafficLayer extends StatefulWidget {
  const AnalyzerTrafficLayer({super.key, required this.paths});

  final List<AnimatedPath> paths;

  @override
  State<AnalyzerTrafficLayer> createState() => _AnalyzerTrafficLayerState();
}

class _AnalyzerTrafficLayerState extends State<AnalyzerTrafficLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  void _syncClock() {
    final enabled =
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context) &&
        widget.paths.isNotEmpty;
    if (enabled && !_clock.isAnimating) _clock.repeat();
    if (!enabled) _clock.stop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncClock();
  }

  @override
  void didUpdateWidget(AnalyzerTrafficLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncClock();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: AnalyzerTrafficPainter(
          camera: MapCamera.of(context),
          paths: widget.paths,
          clock: _clock,
          reducedMotion: MediaQuery.disableAnimationsOf(context),
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }
}

class AnalyzerTrafficPainter extends CustomPainter {
  AnalyzerTrafficPainter({
    required this.camera,
    required this.paths,
    required Listenable clock,
    required this.reducedMotion,
  }) : super(repaint: clock);

  final MapCamera camera;
  final List<AnimatedPath> paths;
  final bool reducedMotion;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final now = DateTime.now();
    for (final path in paths) {
      final opacity = path.opacityAt(now);
      if (opacity <= 0 || path.points.length < 2) continue;
      final color = switch (path.packetType) {
        AnalyzerPacketType.dm => Colors.blue,
        AnalyzerPacketType.channel => Colors.green,
        AnalyzerPacketType.advert => Colors.orange,
        AnalyzerPacketType.discovery => Colors.purple,
      };
      final points = path.points.map(camera.latLngToScreenOffset).toList();
      final route = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        route.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        route,
        Paint()
          ..color = color.withValues(alpha: opacity * .13)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        route,
        Paint()
          ..color = color.withValues(alpha: opacity * .65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      if (reducedMotion) continue;
      final progress = path.travelProgressAt(now);
      final segment = progress * (points.length - 1);
      final index = segment.floor().clamp(0, points.length - 2);
      final head = Offset.lerp(
        points[index],
        points[index + 1],
        segment - index,
      )!;
      canvas.drawCircle(
        head,
        9,
        Paint()..color = color.withValues(alpha: opacity * .2),
      );
      canvas.drawCircle(
        head,
        4,
        Paint()..color = color.withValues(alpha: opacity),
      );
      canvas.drawCircle(
        head,
        2,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
      for (var i = 0; i < points.length; i++) {
        final arrival =
            i /
            (points.length - 1) *
            AnimatedPath.travelDuration.inMilliseconds;
        final pulse =
            (now.difference(path.createdAt).inMilliseconds - arrival) / 650;
        if (pulse < 0 || pulse > 1) continue;
        canvas.drawCircle(
          points[i],
          6 + pulse * 15,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * (1 - pulse)
            ..color = color.withValues(alpha: (1 - pulse) * opacity),
        );
      }
    }
  }

  @override
  bool shouldRepaint(AnalyzerTrafficPainter oldDelegate) =>
      camera != oldDelegate.camera ||
      paths != oldDelegate.paths ||
      reducedMotion != oldDelegate.reducedMotion;
}

/// A screen-space card linked to a geographic marker, including when rotated.
class AnalyzerNodeCardLayer extends StatefulWidget {
  const AnalyzerNodeCardLayer({
    super.key,
    required this.contact,
    required this.color,
    required this.onClose,
  });

  final Contact? contact;
  final Color color;
  final VoidCallback onClose;

  @override
  State<AnalyzerNodeCardLayer> createState() => _AnalyzerNodeCardLayerState();
}

class _AnalyzerNodeCardLayerState extends State<AnalyzerNodeCardLayer> {
  Contact? _lastContact;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    _lastContact = widget.contact ?? _lastContact;
    final node = _lastContact;
    final color = widget.color;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final point = node == null
            ? Offset.zero
            : camera.latLngToScreenOffset(
                LatLng(node.latitude!, node.longitude!),
              );
        final visible =
            widget.contact != null &&
            node != null &&
            (Offset.zero & size).contains(point);
        final width = math.min(264.0, math.max(0.0, size.width - 16));
        final height = math.min(216.0, math.max(0.0, size.height - 16));
        final left = (point.dx - width / 2).clamp(
          8.0,
          math.max(8.0, size.width - width - 8),
        );
        final above = point.dy - height - 24;
        final top = (above >= 8 ? above : point.dy + 24).clamp(
          8.0,
          math.max(8.0, size.height - height - 8),
        );
        final rect = Rect.fromLTWH(
          left.toDouble(),
          top.toDouble(),
          width,
          height,
        );
        return Stack(
          children: [
            if (visible)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CardLinkPainter(point, rect, color),
                  ),
                ),
              ),
            Positioned(
              left: left.toDouble(),
              top: top.toDouble(),
              width: width,
              child: IgnorePointer(
                ignoring: !visible,
                child: AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: .96, end: 1).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                  child: !visible
                      ? const SizedBox.shrink()
                      : SizedBox(
                          key: ValueKey(node.publicKeyHex),
                          height: height,
                          child: Material(
                            key: const ValueKey('analyzer-node-card'),
                            elevation: 8,
                            shadowColor: Colors.black26,
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: .97),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: color.withValues(alpha: .4),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _NodeInfo(
                              contact: node,
                              color: color,
                              onClose: widget.onClose,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NodeInfo extends StatelessWidget {
  const _NodeInfo({
    required this.contact,
    required this.color,
    required this.onClose,
  });
  final Contact contact;
  final Color color;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final material = MaterialLocalizations.of(context);
    final seen = contact.lastSeen.toLocal();
    final type = switch (contact.type) {
      advTypeChat => l10n.map_chat,
      advTypeRepeater => l10n.map_repeater,
      advTypeRoom => l10n.map_room,
      advTypeSensor => l10n.map_sensor,
      _ => l10n.common_unknownDevice,
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  contact.displayName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: l10n.common_close,
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
          Text(
            type,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 10),
          _detail(
            context,
            Icons.route,
            contact.pathOverride != null
                ? (contact.pathOverride! < 0
                      ? l10n.chat_floodForced
                      : contact.pathOverride == 0
                      ? l10n.chat_directForced
                      : l10n.chat_hopsForced(contact.pathOverride!))
                : contact.pathLength < 0
                ? l10n.chat_floodAuto
                : contact.pathLength == 0
                ? l10n.chat_direct
                : l10n.chat_hopsCount(contact.displayHopCount),
          ),
          const SizedBox(height: 8),
          _detail(
            context,
            Icons.schedule,
            '${l10n.map_lastSeen}: ${material.formatShortDate(seen)} ${material.formatTimeOfDay(TimeOfDay.fromDateTime(seen))}',
          ),
          const SizedBox(height: 8),
          _detail(
            context,
            Icons.location_on_outlined,
            '${contact.latitude!.toStringAsFixed(5)}, ${contact.longitude!.toStringAsFixed(5)}',
          ),
        ],
      ),
    );
  }

  Widget _detail(BuildContext context, IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
    ],
  );
}

class _CardLinkPainter extends CustomPainter {
  _CardLinkPainter(this.point, this.rect, this.color);
  final Offset point;
  final Rect rect;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final end = Offset(
      point.dx.clamp(rect.left + 12, rect.right - 12),
      point.dy < rect.top ? rect.top : rect.bottom,
    );
    canvas.drawLine(
      point,
      end,
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );
    canvas.drawCircle(point, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CardLinkPainter oldDelegate) =>
      point != oldDelegate.point ||
      rect != oldDelegate.rect ||
      color != oldDelegate.color;
}
