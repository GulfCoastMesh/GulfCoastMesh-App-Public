import 'package:flutter/material.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../services/app_settings_service.dart';
import 'repeater_status_screen.dart';
import 'repeater_cli_screen.dart';
import 'repeater_ota_wizard_screen.dart';
import 'repeater_prefix_wizard_screen.dart';
import 'repeater_settings_screen.dart';
import 'telemetry_screen.dart';
import 'telemetry_monitor_screen.dart';
import 'neighbors_screen.dart';

class RepeaterHubScreen extends StatelessWidget {
  final Contact repeater;
  final String password;

  const RepeaterHubScreen({
    super.key,
    required this.repeater,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final settingsService = context.watch<AppSettingsService>();
    final chemistry = settingsService.batteryChemistryForRepeater(
      repeater.publicKeyHex,
    );
    final cellCount = settingsService.batteryCellCountForRepeater(
      repeater.publicKeyHex,
    );
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              repeater.type == advTypeRepeater
                  ? l10n.repeater_management
                  : l10n.room_management,
            ),
            Text(
              repeater.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Repeater info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: colorScheme.tertiary,
                      child: Icon(
                        Icons.cell_tower,
                        size: 40,
                        color: colorScheme.onTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      repeater.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      repeater.shortPubKeyHex,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      repeater.pathLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (repeater.hasLocation) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${repeater.latitude?.toStringAsFixed(4)}, ${repeater.longitude?.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.battery_full),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.appSettings_batteryChemistry,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: chemistry,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        settingsService.setBatteryChemistryForRepeater(
                          repeater.publicKeyHex,
                          value,
                        );
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'nmc',
                          child: Text(l10n.appSettings_batteryNmc),
                        ),
                        DropdownMenuItem(
                          value: 'lifepo4',
                          child: Text(l10n.appSettings_batteryLifepo4),
                        ),
                        DropdownMenuItem(
                          value: 'lipo',
                          child: Text(l10n.appSettings_batteryLipo),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.appSettings_batteryCellCount,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      initialValue: cellCount,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        settingsService.setBatteryCellCountForRepeater(
                          repeater.publicKeyHex,
                          value,
                        );
                      },
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text(l10n.appSettings_batteryCellCount1S),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(l10n.appSettings_batteryCellCount2S),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text(l10n.appSettings_batteryCellCount3S),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text(l10n.appSettings_batteryCellCount4S),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.repeater_managementTools,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Status button
            _buildManagementCard(
              context,
              icon: Icons.analytics,
              title: l10n.repeater_status,
              subtitle: l10n.repeater_statusSubtitle,
              color: colorScheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RepeaterStatusScreen(
                      repeater: repeater,
                      password: password,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Send advert button
            _buildManagementCard(
              context,
              icon: Icons.campaign,
              title: l10n.repeater_sendAdvert,
              subtitle: l10n.repeater_sendAdvertSubtitle,
              color: colorScheme.primary,
              onTap: () => _sendAdvert(context, repeater),
            ),
            const SizedBox(height: 16),
            // Telemetry button
            _buildManagementCard(
              context,
              icon: Icons.bar_chart_sharp,
              title: l10n.repeater_telemetry,
              subtitle: l10n.repeater_telemetrySubtitle,
              color: colorScheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TelemetryScreen(repeater: repeater, password: password),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Recorded telemetry history for this repeater
            _buildManagementCard(
              context,
              icon: Icons.show_chart,
              title: l10n.telemetryMonitor_title,
              subtitle: l10n.telemetrySettings_enableSubtitle,
              color: colorScheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelemetryMonitorScreen(
                      nodeId: repeater.publicKeyHex,
                      nodeName: repeater.displayName,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // CLI button
            _buildManagementCard(
              context,
              icon: Icons.terminal,
              title: l10n.repeater_cli,
              subtitle: l10n.repeater_cliSubtitle,
              color: colorScheme.tertiary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RepeaterCliScreen(
                      repeater: repeater,
                      password: password,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Neighbors button
            _buildManagementCard(
              context,
              icon: Icons.group,
              title: l10n.repeater_neighbors,
              subtitle: l10n.repeater_neighborsSubtitle,
              color: colorScheme.tertiary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NeighborsScreen(repeater: repeater, password: password),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Settings button
            _buildManagementCard(
              context,
              icon: Icons.settings,
              title: l10n.repeater_settings,
              subtitle: l10n.repeater_settingsSubtitle,
              color: colorScheme.secondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RepeaterSettingsScreen(
                      repeater: repeater,
                      password: password,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              context,
              icon: Icons.system_update,
              title: l10n.ota_title,
              subtitle: l10n.ota_cardSubtitle,
              color: colorScheme.secondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RepeaterOtaWizardScreen(
                      repeater: repeater,
                      password: password,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              context,
              icon: Icons.tag,
              title: l10n.repeater_prefixTitle,
              subtitle: l10n.repeater_prefixCardSubtitle,
              color: colorScheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RepeaterPrefixWizardScreen(
                      repeater: repeater,
                      password: password,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendAdvert(BuildContext context, Contact repeater) async {
    final l10n = context.l10n;
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    try {
      final selection = await connector.preparePathForContactSend(repeater);
      final timestampSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      connector.trackRepeaterAck(
        contact: repeater,
        selection: selection,
        text: 'advert',
        timestampSeconds: timestampSeconds,
      );
      final frame = buildSendCliCommandFrame(
        repeater.publicKey,
        'advert',
        timestampSeconds: timestampSeconds,
      );
      await connector.sendFrame(frame);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.repeater_commandSent('advert'))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.repeater_errorSendingCommand(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
