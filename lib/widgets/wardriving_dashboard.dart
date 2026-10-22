import 'package:flutter/material.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/atak_location_access.dart';
import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../models/wardriving.dart';
import '../services/app_settings_service.dart';
import '../services/wardriving_service.dart';
import '../theme/app_colors.dart';

/// The map-facing wardriving control surface. It intentionally owns no map
/// state: the map remains responsible for tiles, markers, tracks and coverage.
class WardrivingDashboard extends StatefulWidget {
  final MeshCoreConnector connector;
  final AppSettingsService settingsService;
  final WardrivingService service;
  final VoidCallback? onOpenOfflineSessions;
  final VoidCallback? onRecenter;

  const WardrivingDashboard({
    super.key,
    required this.connector,
    required this.settingsService,
    required this.service,
    this.onOpenOfflineSessions,
    this.onRecenter,
  });

  @override
  State<WardrivingDashboard> createState() => _WardrivingDashboardState();
}

class _WardrivingDashboardState extends State<WardrivingDashboard> {
  WardrivingMode _selectedMode = WardrivingMode.passive;

  AppSettings get settings => widget.settingsService.settings;

  Future<bool> _prepare() async {
    if (!settings.wardrivingDisclosureAccepted) {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(dialogContext.l10n.wardriving_disclosureTitle),
          content: Text(dialogContext.l10n.wardriving_disclosureBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(dialogContext.l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(dialogContext.l10n.wardriving_disclosureAccept),
            ),
          ],
        ),
      );
      if (accepted != true) return false;
      await widget.settingsService.setWardrivingDisclosureAccepted(true);
    }
    if (!await ensureAtakLocationPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.wardriving_locationPermissionRequired),
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _startOrStop() async {
    if (widget.service.isRunning) {
      await widget.service.stop();
      return;
    }
    // Starting performs GPS acquisition and server checks. A missing cached
    // fix must not prevent the user from initiating that acquisition.
    if (!await _prepare()) return;
    final started = switch (_selectedMode) {
      WardrivingMode.passive => await widget.service.startPassive(),
      WardrivingMode.active => await widget.service.startActive(),
      WardrivingMode.hybrid => await widget.service.startHybrid(),
      WardrivingMode.targeted => await widget.service.startTargeted(
        settings.wardrivingTargetRepeaterId,
      ),
      WardrivingMode.off => false,
    };
    if (!started && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.service.statusMessage ?? 'Could not start wardriving',
          ),
        ),
      );
    }
  }

  Future<void> _manualPing() async {
    if (!await _prepare()) return;
    final sent = await widget.service.sendManualPing();
    if (!sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.service.statusMessage ?? 'Could not send ping'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 520;
          final content = _buildContent(context, wide);
          return AnimatedSize(
            duration: const Duration(milliseconds: 180),
            child: wide
                ? SizedBox(width: double.infinity, child: content)
                : content,
          );
        },
      ),
    );
  }

  static const double _metersToFeet = 3.28084;

  Widget _buildContent(BuildContext context, bool wide) {
    final colorScheme = Theme.of(context).colorScheme;
    final stats = widget.service.stats;
    final location = widget.service.currentLocation;
    final isImperial = settings.unitSystem == UnitSystem.imperial;
    final availability = widget.service.availabilityFor(_selectedMode);
    final status =
        widget.service.sessionState == WardrivingSessionState.stopping
        ? 'Stopping wardrive…'
        : widget.service.sessionState == WardrivingSessionState.pausedBackground
        ? 'Wardriving paused in background'
        : widget.service.isBusy
        ? 'Preparing wardrive…'
        : widget.service.statusMessage ??
              (widget.service.isRunning
                  ? '${_modeLabel(widget.service.mode)} running'
                  : widget.service.sessionState == WardrivingSessionState.ready
                  ? 'Session ready'
                  : 'Ready to wardrive');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              widget.service.isRunning
                  ? Icons.radio_button_checked
                  : Icons.explore_outlined,
              color: widget.service.isRunning
                  ? context.appColors.connected
                  : colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Wardriving',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: widget.service.refreshModeAvailability,
              icon: const Icon(Icons.refresh),
              tooltip: context.l10n.wardriving_refreshAvailability,
            ),
          ],
        ),
        Text(
          status,
          style: TextStyle(
            color: widget.service.statusMessage == null
                ? null
                : Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _stat(
              'GPS',
              location == null
                  ? '—'
                  : isImperial
                  ? '${(location.accuracyMeters * _metersToFeet).round()}ft'
                  : '${location.accuracyMeters.round()}m',
            ),
            _stat(
              'Noise',
              widget.service.currentNoiseFloor == null
                  ? '—'
                  : '${widget.service.currentNoiseFloor} dBm',
            ),
            _stat('TX', '${stats.txCount}'),
            _stat('RX', '${stats.rxCount}'),
            _stat('DISC', '${stats.discCount}'),
            _stat('TRACE', '${stats.traceCount}'),
            _stat('Queue', '${stats.queueCount}'),
            _stat('Upload', '${stats.uploadedCount}'),
          ],
        ),
        const SizedBox(height: 10),
        SegmentedButton<WardrivingMode>(
          segments: [
            for (final mode in const [
              WardrivingMode.passive,
              WardrivingMode.active,
              WardrivingMode.hybrid,
              WardrivingMode.targeted,
            ])
              ButtonSegment(value: mode, label: Text(_modeLabel(mode))),
          ],
          selected: {_selectedMode},
          onSelectionChanged: widget.service.isRunning || widget.service.isBusy
              ? null
              : (selection) => setState(() => _selectedMode = selection.first),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _modeDescription(_selectedMode),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (!availability.enabled)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              availability.reason,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        if (_selectedMode == WardrivingMode.targeted &&
            widget.service.repeaters.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue:
                widget.service.repeaters.any(
                  (r) => r.targetId == settings.wardrivingTargetRepeaterId,
                )
                ? settings.wardrivingTargetRepeaterId
                : null,
            decoration: InputDecoration(
              labelText: context.l10n.wardriving_targetRepeater,
              isDense: true,
            ),
            items: [
              for (final repeater in widget.service.repeaters)
                DropdownMenuItem(
                  value: repeater.targetId,
                  child: Text('${repeater.name} (${repeater.targetId})'),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.settingsService.setWardrivingTargetRepeaterId(value);
              }
            },
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: !widget.service.isBusy ? _startOrStop : null,
                icon: Icon(
                  widget.service.isRunning ? Icons.stop : Icons.play_arrow,
                ),
                label: Text(
                  widget.service.isRunning ? 'Stop wardrive' : 'Start wardrive',
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: widget.service.isRunning || widget.service.isBusy
                  ? null
                  : _manualPing,
              icon: const Icon(Icons.bolt, size: 18),
              label: const Text('Ping'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Coverage'),
                value: settings.wardrivingCoverageEnabled,
                onChanged: widget.settingsService.setWardrivingCoverageEnabled,
              ),
            ),
            if (widget.service.currentLocation != null)
              IconButton(
                onPressed: widget.onRecenter,
                icon: const Icon(Icons.my_location),
                tooltip: context.l10n.wardriving_recenterOnGps,
              ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: [
            _LegendDot(color: context.appColors.connected, label: 'covered'),
            // Colors.cyan: distinct "recent" legend swatch, not a themed
            // semantic role.
            const _LegendDot(color: Colors.cyan, label: 'recent'),
            _LegendDot(color: colorScheme.tertiary, label: 'partial'),
            _LegendDot(color: colorScheme.outlineVariant, label: 'unknown'),
          ],
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history),
          title: Text(context.l10n.wardriving_offlineSessionsHistory),
          subtitle: Text(
            context.l10n.wardriving_savedSessions(
              widget.service.offlineSessions.length,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: widget.onOpenOfflineSessions,
        ),
        if (!widget.connector.isConnected)
          _message(context, 'Connect a MeshCore device to begin.'),
        if (widget.service.isLoadingModeAvailability)
          const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }

  Widget _stat(String label, String value) => Chip(
    label: Text('$label $value', style: const TextStyle(fontSize: 11)),
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
  );
  Widget _message(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.error,
        fontSize: 12,
      ),
    ),
  );

  static String _modeLabel(WardrivingMode mode) => switch (mode) {
    WardrivingMode.passive => 'Passive',
    WardrivingMode.active => 'Active',
    WardrivingMode.hybrid => 'Hybrid',
    WardrivingMode.targeted => 'Targeted',
    _ => 'Off',
  };
  static String _modeDescription(WardrivingMode mode) => switch (mode) {
    WardrivingMode.passive =>
      'Listen for mesh traffic and discover nearby nodes.',
    WardrivingMode.active => 'Send coverage pings on #wardriving.',
    WardrivingMode.hybrid =>
      'Alternate discovery and coverage pings while listening.',
    WardrivingMode.targeted => 'Trace a selected repeater.',
    _ => '',
  };
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 3),
      Text(label, style: const TextStyle(fontSize: 10)),
    ],
  );
}
