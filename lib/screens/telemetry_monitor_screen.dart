import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../models/telemetry_sample.dart';
import '../services/app_settings_service.dart';
import '../services/telemetry_monitor_service.dart';
import '../storage/telemetry_store.dart';
import '../widgets/adaptive_app_bar_title.dart';
import '../widgets/telemetry_sparkline.dart';

/// Recorded telemetry history for one node, with a sparkline per metric.
class TelemetryMonitorScreen extends StatefulWidget {
  const TelemetryMonitorScreen({super.key, this.nodeId, this.nodeName});

  /// Defaults to the connected companion.
  final String? nodeId;
  final String? nodeName;

  @override
  State<TelemetryMonitorScreen> createState() => _TelemetryMonitorScreenState();
}

class _TelemetryMonitorScreenState extends State<TelemetryMonitorScreen> {
  late final String _nodeId;

  @override
  void initState() {
    super.initState();
    _nodeId = widget.nodeId ?? TelemetryStore.localNodeId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TelemetryMonitorService>().loadHistory(_nodeId);
    });
  }

  bool get _isLocal => _nodeId == TelemetryStore.localNodeId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(
          widget.nodeName ?? l10n.telemetryMonitor_title,
        ),
        actions: [
          IconButton(
            tooltip: l10n.telemetryMonitor_clearHistory,
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmClear,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Consumer2<TelemetryMonitorService, AppSettingsService>(
          builder: (context, monitor, settingsService, _) {
            final history = monitor.historyFor(_nodeId);
            final enabled = settingsService.settings.telemetryMonitorEnabled;

            if (history.isEmpty) {
              return _buildEmpty(context, enabled);
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(context, monitor, history),
                const SizedBox(height: 16),
                ..._metricCards(context, history),
                ..._sensorCards(context, history),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<MeshCoreConnector>(
        builder: (context, connector, _) => FloatingActionButton.extended(
          onPressed: connector.isConnected ? _sampleNow : null,
          icon: const Icon(Icons.refresh),
          label: Text(
            _isLocal
                ? l10n.telemetryMonitor_sampleNow
                : l10n.telemetryMonitor_pollRemoteNow,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, bool monitoringEnabled) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: colors.outline),
            const SizedBox(height: 16),
            Text(
              monitoringEnabled
                  ? l10n.telemetryMonitor_noHistory
                  : l10n.telemetryMonitor_disabled,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
            ),
            if (!monitoringEnabled) ...[
              const SizedBox(height: 8),
              Text(
                l10n.telemetryMonitor_enableHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    TelemetryMonitorService monitor,
    List<TelemetrySample> history,
  ) {
    final l10n = context.l10n;
    final last = history.last.timestamp.toLocal();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.telemetryMonitor_samples(history.length),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(
          l10n.telemetryMonitor_lastSample(_formatTime(last)),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  List<Widget> _metricCards(
    BuildContext context,
    List<TelemetrySample> history,
  ) {
    final l10n = context.l10n;
    final specs = <(TelemetryMetric, String, String Function(double))>[
      (
        TelemetryMetric.batteryMillivolts,
        l10n.telemetryMonitor_battery,
        (v) => '${(v / 1000).toStringAsFixed(2)} V',
      ),
      (
        TelemetryMetric.noiseFloor,
        l10n.telemetryMonitor_noiseFloor,
        (v) => '${v.toStringAsFixed(0)} dBm',
      ),
      (
        TelemetryMetric.rssi,
        l10n.telemetryMonitor_rssi,
        (v) => '${v.toStringAsFixed(0)} dBm',
      ),
      (
        TelemetryMetric.snr,
        l10n.telemetryMonitor_snr,
        (v) => '${v.toStringAsFixed(0)} dB',
      ),
      (
        TelemetryMetric.txAirSeconds,
        l10n.telemetryMonitor_txAirtime,
        _formatDuration,
      ),
      (
        TelemetryMetric.rxAirSeconds,
        l10n.telemetryMonitor_rxAirtime,
        _formatDuration,
      ),
      (
        TelemetryMetric.uptimeSeconds,
        l10n.telemetryMonitor_uptime,
        _formatDuration,
      ),
    ];

    final cards = <Widget>[];
    for (final (metric, label, format) in specs) {
      final series = history.map((s) => s.value(metric)).toList();
      // A metric this node never reports gets no card at all, rather than an
      // empty chart.
      if (!series.any((v) => v != null)) continue;
      cards.add(_MetricCard(label: label, series: series, format: format));
    }
    return cards;
  }

  List<Widget> _sensorCards(
    BuildContext context,
    List<TelemetrySample> history,
  ) {
    final keys = <String>{};
    for (final sample in history) {
      keys.addAll(sample.sensors.keys);
    }
    if (keys.isEmpty) return const [];

    final sorted = keys.toList()..sort();
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          context.l10n.telemetryMonitor_sensors,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      ...sorted.map(
        (key) => _MetricCard(
          label: key,
          series: history.map((s) => s.sensors[key]).toList(),
          format: (v) => v.toStringAsFixed(2),
        ),
      ),
    ];
  }

  Future<void> _sampleNow() async {
    final monitor = context.read<TelemetryMonitorService>();
    if (_isLocal) {
      await monitor.sampleLocalNow();
    } else {
      await monitor.pollRemoteNow();
    }
  }

  Future<void> _confirmClear() async {
    final l10n = context.l10n;
    final monitor = context.read<TelemetryMonitorService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.telemetryMonitor_clearHistory),
        content: Text(l10n.telemetryMonitor_clearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.telemetryMonitor_clearHistory),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await monitor.clearHistory(_nodeId);
      if (mounted) setState(() {});
    }
  }

  static String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _formatDuration(double seconds) {
    final total = seconds.round();
    if (total < 60) return '${total}s';
    if (total < 3600) return '${(total / 60).floor()}m';
    if (total < 86400) return '${(total / 3600).floor()}h';
    return '${(total / 86400).floor()}d';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.series,
    required this.format,
  });

  final String label;
  final List<double?> series;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    final present = series.whereType<double>().toList();
    if (present.isEmpty) return const SizedBox.shrink();

    final latest = present.last;
    var min = present.first;
    var max = present.first;
    for (final value in present) {
      if (value < min) min = value;
      if (value > max) max = value;
    }

    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: theme.textTheme.titleSmall),
                Text(
                  format(latest),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TelemetrySparkline(values: series),
            const SizedBox(height: 4),
            Text(
              '${format(min)} – ${format(max)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
