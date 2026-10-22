import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/atak_location_access.dart';
import '../helpers/wardriving_packet.dart';
import '../models/analyzer_packet.dart';
import '../l10n/l10n.dart';
import '../widgets/analyzer_surface.dart';
import '../models/contact.dart';
import '../services/atak_location_broadcast_service.dart';
import '../services/mesh_analyzer_state.dart';
import '../widgets/analyzer_chat_panel.dart';
import '../widgets/analyzer_map.dart';
import '../widgets/analyzer_packet_log.dart';
import '../widgets/connection_overflow_menu_button.dart';

class MeshAnalyzerScreen extends StatefulWidget {
  const MeshAnalyzerScreen({super.key, this.isTabActive = true});

  /// When false, the analyzer stays mounted (IndexedStack) but is not visible.
  final bool isTabActive;

  @override
  State<MeshAnalyzerScreen> createState() => _MeshAnalyzerScreenState();
}

class _MeshAnalyzerScreenState extends State<MeshAnalyzerScreen>
    with WidgetsBindingObserver {
  StreamSubscription<Uint8List>? _frameSubscription;
  bool _isForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_syncWakeLock());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeToFrames();
    });
  }

  @override
  void didUpdateWidget(covariant MeshAnalyzerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isTabActive != widget.isTabActive) {
      unawaited(_syncWakeLock());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _isForeground = state == AppLifecycleState.resumed);
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncWakeLock());
    } else {
      unawaited(WakelockPlus.disable());
    }
  }

  Future<void> _syncWakeLock() async {
    if (widget.isTabActive) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }

  void _subscribeToFrames() {
    final connector = context.read<MeshCoreConnector>();
    final analyzerState = context.read<MeshAnalyzerState>();

    connector.addListener(_onConnectorChanged);

    _frameSubscription = connector.receivedFrames.listen((frame) {
      if (!mounted) return;
      _processFrame(frame, connector, analyzerState);
    });
  }

  void _onConnectorChanged() {
    if (!mounted) return;
    final connector = context.read<MeshCoreConnector>();
    final analyzerState = context.read<MeshAnalyzerState>();

    _frameSubscription ??= connector.receivedFrames.listen((frame) {
      if (!mounted) return;
      _processFrame(frame, connector, analyzerState);
    });
  }

  void _processFrame(
    Uint8List frame,
    MeshCoreConnector connector,
    MeshAnalyzerState analyzerState,
  ) {
    if (frame.isEmpty) return;
    final code = frame[0];
    final rawHex = frame
        .take(frame.length.clamp(0, 64))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' ');

    switch (code) {
      case pushCodeLogRxData:
        // LOG_RX is the RF source of truth (SNR/RSSI/path). Decoded companion
        // frames omit airtime metadata and would duplicate the same packet.
        _handleRxData(frame, connector, analyzerState, rawHex);
        break;
    }
  }

  void _handleRxData(
    Uint8List frame,
    MeshCoreConnector connector,
    MeshAnalyzerState analyzerState,
    String rawHex,
  ) {
    final packet = parseLogRxDataFrame(frame);
    if (packet == null) return;

    final contacts = connector.contacts;
    final hashSize = packet.pathHashSize;
    final resolvedContacts = MeshAnalyzerState.resolvePathContacts(
      packet.pathBytes,
      contacts,
      hashSize,
    );

    final analyzerPacket = AnalyzerPacket(
      timestamp: DateTime.now(),
      type: analyzerPacketTypeFromPayload(packet.payloadType),
      senderName: MeshAnalyzerState.resolveSenderFromPath(
        packet.pathBytes,
        contacts,
        hashSize,
      ),
      snr: packet.snr,
      rssi: packet.rssi,
      hopCount: packet.pathHashCount,
      pathBytes: packet.pathBytes,
      routeType: decodeAnalyzerRouteType(packet.routeType),
      payloadType: packet.payloadType,
      rawHex: rawHex,
    );

    analyzerState.addPacket(analyzerPacket);
    _addAnimatedPath(
      analyzerState,
      analyzerPacket,
      resolvedContacts,
      connector,
    );
  }

  void _addAnimatedPath(
    MeshAnalyzerState analyzerState,
    AnalyzerPacket packet,
    List<Contact> resolvedContacts,
    MeshCoreConnector connector,
  ) {
    final points = <LatLng>[];

    // Path order is origin → hops → self (receiver).
    for (final contact in resolvedContacts) {
      if (contact.hasLocation) {
        points.add(LatLng(contact.latitude!, contact.longitude!));
      }
    }

    final broadcastService = context.read<AtakLocationBroadcastService>();
    final selfLat = broadcastService.phoneLat ?? connector.selfLatitude;
    final selfLon = broadcastService.phoneLon ?? connector.selfLongitude;
    if (selfLat != null &&
        selfLon != null &&
        isValidMapCoordinate(selfLat, selfLon)) {
      points.add(LatLng(selfLat, selfLon));
    }

    if (points.length < 2) return;

    analyzerState.addAnimatedPath(
      AnimatedPath(
        points: points,
        createdAt: DateTime.now(),
        packetType: packet.type,
        label: packet.senderName,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(WakelockPlus.disable());
    try {
      context.read<MeshCoreConnector>().removeListener(_onConnectorChanged);
    } catch (_) {}
    _frameSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFullScreen = context.select<MeshAnalyzerState, bool>(
      (state) => state.isFullScreen,
    );
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surfaceContainerLow,
      body: SafeArea(
        child: TickerMode(
          enabled: widget.isTabActive && _isForeground,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Icon(Icons.hub_outlined, size: 20, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.nav_analyzer,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: isFullScreen
                          ? context.l10n.analyzer_exitFullScreen
                          : context.l10n.analyzer_fullScreen,
                      onPressed: context
                          .read<MeshAnalyzerState>()
                          .toggleFullScreen,
                      icon: Icon(
                        isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      ),
                    ),
                    const ConnectionOverflowMenuButton(),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) =>
                        constraints.maxWidth >= 840
                        ? _buildWideLayout(context)
                        : _buildCompactLayout(context, constraints),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) => Row(
    children: [
      const SizedBox(
        width: 280,
        child: AnalyzerSurface(child: AnalyzerPacketLog()),
      ),
      const SizedBox(width: 8),
      const Expanded(child: AnalyzerSurface(child: AnalyzerMap())),
      const SizedBox(width: 8),
      const SizedBox(
        width: 280,
        child: AnalyzerSurface(child: AnalyzerChatPanel()),
      ),
    ],
  );

  Widget _buildCompactLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) => Column(
    children: [
      Expanded(
        child: Row(
          children: [
            const Expanded(child: AnalyzerSurface(child: AnalyzerMap())),
            const SizedBox(width: 8),
            SizedBox(
              width: (constraints.maxWidth * .42).clamp(120.0, 220.0),
              child: const AnalyzerSurface(child: AnalyzerChatPanel()),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: (constraints.maxHeight * .32).clamp(120.0, 200.0),
        child: const AnalyzerSurface(child: AnalyzerPacketLog()),
      ),
    ],
  );
}
