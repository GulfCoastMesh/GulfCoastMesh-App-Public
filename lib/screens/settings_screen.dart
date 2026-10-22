import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gulf_coast_mesh_app/widgets/elements_ui.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/atak_location_access.dart';
import '../helpers/debug_log_export.dart';
import '../l10n/l10n.dart';
import '../models/mesh_region.dart';
import '../helpers/region_scope_codes.dart';
import '../models/radio_settings.dart';
import '../storage/known_regions_store.dart';
import '../widgets/adaptive_app_bar_title.dart';
import 'app_settings_screen.dart';
import 'discover_nodes_screen.dart';
import 'flasher_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _showBatteryVoltage = false;
  bool _deviceInfoExpanded = false;
  String _appVersion = '';
  bool? _ignoringBatteryOpt;
  int _batteryOptStatusGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadVersionInfo();
    if (!kIsWeb && Platform.isAndroid) {
      _loadBatteryOptStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The only way to notice the user changed the OS battery-optimization
    // setting from outside the app is to re-check when they come back.
    if (state == AppLifecycleState.resumed && !kIsWeb && Platform.isAndroid) {
      _loadBatteryOptStatus();
    }
  }

  Future<void> _loadVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _loadBatteryOptStatus() async {
    final generation = ++_batteryOptStatusGeneration;
    bool ignoring;
    try {
      ignoring = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
    } catch (_) {
      return;
    }
    // Discard a stale result from an overlapping call (e.g. rapid
    // background/foreground cycling) that resolved out of order.
    if (!mounted || generation != _batteryOptStatusGeneration) return;
    setState(() {
      _ignoringBatteryOpt = ignoring;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(l10n.settings_title),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Consumer<MeshCoreConnector>(
          builder: (context, connector, child) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDeviceInfoCard(context, connector),
                if (!kIsWeb && Platform.isAndroid) ...[
                  const SizedBox(height: 16),
                  _buildBackgroundReliabilityCard(context),
                ],
                const SizedBox(height: 16),
                _buildReportProblemCard(context),
                const SizedBox(height: 16),
                _buildAppSettingsCard(context),
                const SizedBox(height: 16),
                _buildNodeSettingsCard(context, connector),
                const SizedBox(height: 16),
                _buildActionsCard(context, connector),
                const SizedBox(height: 16),
                _buildAboutCard(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(
    BuildContext context,
    MeshCoreConnector connector,
  ) {
    final l10n = context.l10n;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _deviceInfoExpanded = !_deviceInfoExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.settings_deviceInfo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _deviceInfoExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    l10n.settings_infoName,
                    connector.deviceDisplayName,
                  ),
                  _buildInfoRow(l10n.settings_infoId, connector.deviceIdLabel),
                  _buildInfoRow(
                    l10n.settings_infoStatus,
                    connector.isConnected
                        ? l10n.common_connected
                        : l10n.common_disconnected,
                  ),
                  _buildBatteryInfoRow(context, connector),
                  if (connector.selfName != null)
                    _buildInfoRow(l10n.settings_nodeName, connector.selfName!),
                  if (connector.selfPublicKey != null)
                    _buildInfoRow(
                      l10n.settings_infoPublicKey,
                      '${pubKeyToHex(connector.selfPublicKey!).substring(0, 16)}...',
                    ),
                  _buildInfoRow(
                    l10n.settings_infoContactsCount,
                    '${connector.contacts.length}',
                  ),
                  _buildInfoRow(
                    l10n.settings_infoChannelCount,
                    '${connector.channels.length}',
                  ),
                ],
              ),
            ),
            crossFadeState: _deviceInfoExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryInfoRow(
    BuildContext context,
    MeshCoreConnector connector,
  ) {
    final l10n = context.l10n;
    final percent = connector.batteryPercent;
    final millivolts = connector.batteryMillivolts;

    // figure out display value
    final String displayValue;
    if (millivolts == null) {
      displayValue = l10n.common_notAvailable;
    } else if (_showBatteryVoltage) {
      displayValue = l10n.common_voltageValue(
        (millivolts / 1000.0).toStringAsFixed(2),
      );
    } else {
      displayValue = percent != null
          ? l10n.common_percentValue(percent)
          : l10n.common_notAvailable;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final IconData icon;
    final Color? iconColor;
    final Color? valueColor;

    if (percent == null) {
      icon = Icons.battery_unknown;
      iconColor = colorScheme.outline;
      valueColor = null;
    } else if (percent <= 15) {
      icon = Icons.battery_alert;
      iconColor = colorScheme.error;
      valueColor = colorScheme.error;
    } else {
      icon = Icons.battery_full;
      iconColor = null;
      valueColor = null;
    }

    return _buildInfoRow(
      l10n.settings_infoBattery,
      displayValue,
      leading: Icon(icon, size: 18, color: iconColor),
      valueColor: valueColor,
      onTap: millivolts != null
          ? () {
              setState(() {
                _showBatteryVoltage = !_showBatteryVoltage;
              });
            }
          : null,
    );
  }

  Widget _buildBackgroundReliabilityCard(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final ignoring = _ignoringBatteryOpt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settings_backgroundReliability,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (ignoring != null)
              _buildInfoRow(
                l10n.settings_backgroundReliabilityStatus,
                ignoring
                    ? l10n.settings_backgroundReliabilityExempt
                    : l10n.settings_backgroundReliabilityRestricted,
                leading: Icon(
                  ignoring ? Icons.battery_charging_full : Icons.battery_alert,
                  size: 20,
                  color: ignoring ? colorScheme.tertiary : colorScheme.error,
                ),
                valueColor: ignoring ? colorScheme.tertiary : colorScheme.error,
              ),
            const SizedBox(height: 4),
            Text(
              l10n.settings_backgroundReliabilityExplainer,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () async {
                      try {
                        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
                      } catch (_) {
                        // Some OEM/emulator builds can't resolve this intent;
                        // the open-settings fallback button covers that case.
                      }
                      await _loadBatteryOptStatus();
                    },
                    child: Text(
                      l10n.settings_backgroundReliabilityRequestButton,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    try {
                      await FlutterForegroundTask.openIgnoreBatteryOptimizationSettings();
                    } catch (_) {
                      // Nothing more to fall back to; leave status as-is.
                    }
                    await _loadBatteryOptStatus();
                  },
                  child: Text(
                    l10n.settings_backgroundReliabilityOpenSettingsButton,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportProblemCard(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.support_agent),
        title: Text(l10n.settings_reportProblem),
        subtitle: Text(l10n.settings_reportProblemSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showDebugReportDialog(context),
      ),
    );
  }

  Widget _buildAppSettingsCard(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.settings_outlined),
        title: Text(l10n.settings_appSettings),
        subtitle: Text(l10n.settings_appSettingsSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
          );
        },
      ),
    );
  }

  Widget _buildNodeSettingsCard(
    BuildContext context,
    MeshCoreConnector connector,
  ) {
    final l10n = context.l10n;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.settings_nodeSettings,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.settings_nodeName),
            subtitle: Text(connector.selfName ?? l10n.settings_nodeNameNotSet),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editNodeName(context, connector),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.radio),
            title: Text(l10n.settings_radioSettings),
            subtitle: Text(l10n.settings_radioSettingsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRadioSettings(context, connector),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(l10n.settings_location),
            subtitle: Text(l10n.settings_locationSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editLocation(context, connector),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.visibility_off_outlined),
            title: Text(l10n.settings_privacyMode),
            subtitle: Text(l10n.settings_privacyModeSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _togglePrivacy(context, connector),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.public_outlined),
            title: Text(l10n.settings_defaultFloodScope),
            subtitle: Text(
              connector.defaultFloodScopeName == null ||
                      connector.defaultFloodScopeName!.isEmpty
                  ? l10n.settings_defaultFloodScopeSubtitle
                  : MeshRegion.displayLabel(connector.defaultFloodScopeName!),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDefaultFloodScope(context, connector),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, MeshCoreConnector connector) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.settings_actions,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cell_tower),
            title: Text(l10n.settings_sendAdvertisement),
            subtitle: Text(l10n.settings_sendAdvertisementSubtitle),
            onTap: () => _sendAdvert(context, connector),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(l10n.settings_syncTime),
            subtitle: Text(l10n.settings_syncTimeSubtitle),
            onTap: () => _syncTime(context, connector),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(l10n.settings_refreshContacts),
            subtitle: Text(l10n.settings_refreshContactsSubtitle),
            onTap: () =>
                unawaited(connector.refreshContactsBestEffort(tag: 'Settings')),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.travel_explore),
            title: Text(l10n.discoverNodes_title),
            subtitle: Text(l10n.discoverNodes_subtitle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiscoverNodesScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.usb_rounded),
            title: Text(l10n.settings_flashFirmware),
            subtitle: Text(l10n.settings_flashFirmwareSubtitle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FlasherScreen()),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.restart_alt, color: colorScheme.tertiary),
            title: Text(l10n.settings_rebootDevice),
            subtitle: Text(l10n.settings_rebootDeviceSubtitle),
            onTap: () => _confirmReboot(context, connector),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(l10n.settings_about),
        subtitle: Text(
          l10n.settings_aboutVersion(
            _appVersion.isEmpty ? l10n.common_loading : _appVersion,
          ),
        ),
        onTap: () => _showAbout(context),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Widget? leading,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading, const SizedBox(width: 8)],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: row,
      );
    }

    return row;
  }

  Future<void> _editNodeName(
    BuildContext context,
    MeshCoreConnector connector,
  ) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: connector.selfName ?? '');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settings_nodeName),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.settings_nodeNameHint,
            border: const OutlineInputBorder(),
          ),
          maxLength: 31,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text;
              Navigator.pop(dialogContext);
              try {
                await connector.setNodeName(name);
                await connector.refreshDeviceInfo();
                if (!mounted || !context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.settings_nodeNameUpdated)),
                );
              } catch (error) {
                if (!mounted || !context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.settings_error(error.toString())),
                  ),
                );
              }
            },
            child: Text(l10n.common_save),
          ),
        ],
      ),
    );
  }

  void _showRadioSettings(BuildContext context, MeshCoreConnector connector) {
    showDialog(
      context: context,
      builder: (context) => _RadioSettingsDialog(connector: connector),
    );
  }

  void _showDefaultFloodScope(
    BuildContext context,
    MeshCoreConnector connector,
  ) {
    showDialog(
      context: context,
      builder: (context) => _DefaultFloodScopeDialog(connector: connector),
    );
  }

  Future<void> _editLocation(
    BuildContext context,
    MeshCoreConnector connector,
  ) async {
    final l10n = context.l10n;
    final latController = TextEditingController();
    final lonController = TextEditingController();
    final intervalController = TextEditingController();
    latController.text = connector.selfLatitude?.toStringAsFixed(6) ?? '';
    lonController.text = connector.selfLongitude?.toStringAsFixed(6) ?? '';

    // Safe access to custom vars - may be null before device responds
    final customVars = connector.currentCustomVars ?? {};
    final bool hasGPS = customVars.containsKey("gps");
    bool isGPSEnabled = customVars["gps"] == "1";

    // Read current interval or default to 900 (15 minutes)
    final currentInterval =
        int.tryParse(customVars["gps_interval"] ?? "") ?? 900;
    intervalController.text = currentInterval.toString();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.settings_location),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                decoration: InputDecoration(
                  labelText: l10n.settings_latitude,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lonController,
                decoration: InputDecoration(
                  labelText: l10n.settings_longitude,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    final granted = await ensureAtakLocationPermission();
                    if (!granted) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.chat_locationPermissionRequired),
                        ),
                      );
                      return;
                    }
                    final position = await readAtakPosition();
                    if (!context.mounted) return;
                    if (position == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.chat_locationPermissionRequired),
                        ),
                      );
                      return;
                    }
                    setDialogState(() {
                      latController.text = position.lat.toStringAsFixed(6);
                      lonController.text = position.lon.toStringAsFixed(6);
                    });
                  },
                  icon: const Icon(Icons.my_location, size: 18),
                  label: Text(l10n.settings_usePhoneGps),
                ),
              ),
              if (hasGPS) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: intervalController,
                  decoration: InputDecoration(
                    labelText: l10n.settings_locationIntervalSec,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                ),
                const SizedBox(height: 16),
                FeatureToggleRow(
                  title: l10n.settings_locationGPSEnable,
                  subtitle: l10n.settings_locationGPSEnableSubtitle,
                  value: isGPSEnabled,
                  onChanged: (value) async {
                    final previous = isGPSEnabled;
                    setDialogState(() => isGPSEnabled = value);
                    try {
                      await connector.setCustomVar(value ? "gps:1" : "gps:0");
                    } catch (error) {
                      if (!context.mounted) return;
                      setDialogState(() => isGPSEnabled = previous);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.settings_error(error.toString())),
                        ),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.common_cancel),
            ),
            TextButton(
              onPressed: () async {
                int? interval;
                if (hasGPS) {
                  final intervalText = intervalController.text.trim();
                  if (intervalText.isEmpty) {
                    return;
                  }

                  interval = int.tryParse(intervalText);
                  if (interval == null || interval < 60 || interval >= 86400) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.settings_locationIntervalInvalid),
                      ),
                    );
                    return;
                  }
                }

                final latText = latController.text.trim();
                final lonText = lonController.text.trim();
                final hasLocationInput =
                    latText.isNotEmpty || lonText.isNotEmpty;

                final currentLat = connector.selfLatitude;
                final currentLon = connector.selfLongitude;
                final lat = latText.isNotEmpty
                    ? double.tryParse(latText)
                    : currentLat;
                final lon = lonText.isNotEmpty
                    ? double.tryParse(lonText)
                    : currentLon;
                if (hasLocationInput && (lat == null || lon == null)) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settings_locationBothRequired)),
                  );
                  return;
                }
                if (hasLocationInput &&
                    (lat! < -90 || lat > 90 || lon! < -180 || lon > 180)) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settings_locationInvalid)),
                  );
                  return;
                }

                if (!hasGPS && !hasLocationInput) return;

                try {
                  if (interval != null) {
                    await connector.setCustomVar("gps_interval:$interval");
                  }
                  if (hasLocationInput) {
                    await connector.setNodeLocation(lat: lat!, lon: lon!);
                  }
                  await connector.refreshDeviceInfo();
                  if (!context.mounted) return;
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.settings_locationUpdated)),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.settings_error(error.toString())),
                    ),
                  );
                }
              },
              child: Text(l10n.common_save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePrivacy(
    BuildContext context,
    MeshCoreConnector connector,
  ) async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settings_privacyMode),
        content: Text(l10n.settings_privacyModeToggle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _setPrivacyMode(
                context,
                connector,
                enabled: true,
                successMessage: l10n.settings_privacyModeEnabled,
              );
            },
            child: Text(l10n.common_enable),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _setPrivacyMode(
                context,
                connector,
                enabled: false,
                successMessage: l10n.settings_privacyModeDisabled,
              );
            },
            child: Text(l10n.common_disable),
          ),
        ],
      ),
    );
  }

  Future<void> _setPrivacyMode(
    BuildContext context,
    MeshCoreConnector connector, {
    required bool enabled,
    required String successMessage,
  }) async {
    try {
      await connector.setPrivacyMode(enabled);
      await connector.refreshDeviceInfo();
      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settings_error(error.toString()))),
      );
    }
  }

  Future<void> _sendAdvert(
    BuildContext context,
    MeshCoreConnector connector,
  ) async {
    final l10n = context.l10n;
    try {
      await connector.sendSelfAdvert(flood: true);
      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settings_advertisementSent)));
    } catch (error) {
      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settings_error(error.toString()))),
      );
    }
  }

  Future<void> _syncTime(
    BuildContext context,
    MeshCoreConnector connector,
  ) async {
    final l10n = context.l10n;
    try {
      await connector.syncTime();
      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settings_timeSynchronized)));
    } catch (error) {
      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settings_error(error.toString()))),
      );
    }
  }

  void _confirmReboot(BuildContext context, MeshCoreConnector connector) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settings_rebootDevice),
        content: Text(l10n.settings_rebootDeviceConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await connector.rebootDevice();
              } catch (error) {
                if (!mounted || !context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.settings_error(error.toString())),
                  ),
                );
              }
            },
            child: Text(
              l10n.common_reboot,
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final l10n = context.l10n;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: _appVersion.isEmpty
          ? l10n.common_loading
          : _appVersion,
      applicationLegalese: l10n.settings_aboutLegalese,
      children: [
        const SizedBox(height: 16),
        Linkify(
          text:
              "Gulf Coast mesh community app.\n\nVisit https://gulfcoastmesh.org/",
          onOpen: (link) async {
            final uri = Uri.parse(link.url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Developed by '),
            TextButton(
              onPressed: () async {
                await launchUrl(
                  Uri.parse('https://lenleyngo.com'),
                  mode: LaunchMode.externalApplication,
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('ScarlettOSA'),
            ),
            const Text(' and J'),
          ],
        ),
      ],
    );
  }
}

class _RadioSettingsDialog extends StatefulWidget {
  final MeshCoreConnector connector;

  const _RadioSettingsDialog({required this.connector});

  @override
  State<_RadioSettingsDialog> createState() => _RadioSettingsDialogState();
}

class _RadioSettingsDialogState extends State<_RadioSettingsDialog> {
  final _frequencyController = TextEditingController();
  LoRaBandwidth _bandwidth = LoRaBandwidth.bw125;
  LoRaSpreadingFactor _spreadingFactor = LoRaSpreadingFactor.sf7;
  LoRaCodingRate _codingRate = LoRaCodingRate.cr4_5;
  final _txPowerController = TextEditingController(text: '20');
  bool _clientRepeat = false;

  @override
  void initState() {
    super.initState();

    // Populate with current settings if available
    if (widget.connector.currentFreqHz != null) {
      _frequencyController.text = (widget.connector.currentFreqHz! / 1000.0)
          .toStringAsFixed(3);
    } else {
      _frequencyController.text = '915.0';
    }

    if (widget.connector.currentBwHz != null) {
      // Find matching bandwidth enum
      final bwValue = widget.connector.currentBwHz!;
      for (var bw in LoRaBandwidth.values) {
        if (bw.hz == bwValue) {
          _bandwidth = bw;
          break;
        }
      }
    }

    if (widget.connector.currentSf != null) {
      // Find matching spreading factor enum
      final sfValue = widget.connector.currentSf!;
      for (var sf in LoRaSpreadingFactor.values) {
        if (sf.value == sfValue) {
          _spreadingFactor = sf;
          break;
        }
      }
    }

    if (widget.connector.currentCr != null) {
      // Find matching coding rate enum
      final crValue = _toUiCodingRate(widget.connector.currentCr!);
      for (var cr in LoRaCodingRate.values) {
        if (cr.value == crValue) {
          _codingRate = cr;
          break;
        }
      }
    }

    if (widget.connector.currentTxPower != null) {
      _txPowerController.text = widget.connector.currentTxPower.toString();
    }

    _clientRepeat = widget.connector.clientRepeat ?? false;
  }

  @override
  void dispose() {
    _frequencyController.dispose();
    _txPowerController.dispose();
    super.dispose();
  }

  void _applyPreset(RadioSettings preset) {
    setState(() {
      _frequencyController.text = preset.frequencyMHz.toString();
      _bandwidth = preset.bandwidth;
      _spreadingFactor = preset.spreadingFactor;
      _codingRate = preset.codingRate;
      _txPowerController.text = preset.txPowerDbm.toString();
    });
  }

  Future<void> _saveSettings() async {
    final l10n = context.l10n;
    final freqMHz = double.tryParse(_frequencyController.text);
    final txPower = int.tryParse(_txPowerController.text);

    if (freqMHz == null || freqMHz < 300 || freqMHz > 2500) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settings_frequencyInvalid)));
      return;
    }

    final maxTxPower = widget.connector.maxTxPower ?? 22;
    if (txPower == null || txPower < 0 || txPower > maxTxPower) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.settings_txPowerInvalid} (0-$maxTxPower dBm)'),
        ),
      );
      return;
    }

    final freqHz = (freqMHz * 1000).round();
    final bwHz = _bandwidth.hz;
    final sf = _spreadingFactor.value;
    final cr = _toDeviceCodingRate(
      _codingRate.value,
      widget.connector.currentCr,
    );

    // if the client repeat isnt null then we know its supported
    //otherwise we leave it out of the frame to avoid accidentally enabling
    final knownRepeat = widget.connector.clientRepeat != null;

    if (knownRepeat) {
      const validRepeatFreqsKHz = {433000, 869000, 918000};
      if (_clientRepeat && !validRepeatFreqsKHz.contains(freqHz)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settings_clientRepeatFreqWarning)),
        );
        return;
      }
    }

    try {
      await widget.connector.sendFrame(
        buildSetRadioParamsFrame(
          freqHz,
          bwHz,
          sf,
          cr,
          clientRepeat: knownRepeat ? _clientRepeat : null,
        ),
      );
      await widget.connector.sendFrame(buildSetRadioTxPowerFrame(txPower));
      await widget.connector.refreshDeviceInfo();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settings_radioSettingsUpdated)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settings_error(e.toString()))),
      );
    }
  }

  int _toUiCodingRate(int deviceCr) {
    return deviceCr <= 4 ? deviceCr + 4 : deviceCr;
  }

  int _toDeviceCodingRate(int uiCr, int? deviceCr) {
    if (deviceCr != null && deviceCr <= 4) {
      return uiCr - 4;
    }
    return uiCr;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.settings_radioSettings),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: l10n.settings_presets,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (var i = 0; i < RadioSettings.presets.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(RadioSettings.presets[i].$1),
                  ),
              ],
              onChanged: (index) {
                if (index != null) {
                  _applyPreset(RadioSettings.presets[index].$2);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _frequencyController,
              decoration: InputDecoration(
                labelText: l10n.settings_frequency,
                border: const OutlineInputBorder(),
                helperText: l10n.settings_frequencyHelper,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LoRaBandwidth>(
              initialValue: _bandwidth,
              decoration: InputDecoration(
                labelText: l10n.settings_bandwidth,
                border: const OutlineInputBorder(),
              ),
              items: LoRaBandwidth.values
                  .map(
                    (bw) => DropdownMenuItem(value: bw, child: Text(bw.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _bandwidth = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LoRaSpreadingFactor>(
              initialValue: _spreadingFactor,
              decoration: InputDecoration(
                labelText: l10n.settings_spreadingFactor,
                border: const OutlineInputBorder(),
              ),
              items: LoRaSpreadingFactor.values
                  .map(
                    (sf) => DropdownMenuItem(value: sf, child: Text(sf.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _spreadingFactor = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LoRaCodingRate>(
              initialValue: _codingRate,
              decoration: InputDecoration(
                labelText: l10n.settings_codingRate,
                border: const OutlineInputBorder(),
              ),
              items: LoRaCodingRate.values
                  .map(
                    (cr) => DropdownMenuItem(value: cr, child: Text(cr.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _codingRate = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _txPowerController,
              decoration: InputDecoration(
                labelText: l10n.settings_txPower,
                border: const OutlineInputBorder(),
                helperText: widget.connector.maxTxPower != null
                    ? '${l10n.settings_txPowerHelper} (max: ${widget.connector.maxTxPower} dBm)'
                    : l10n.settings_txPowerHelper,
              ),
              keyboardType: TextInputType.number,
            ),
            if (widget.connector.clientRepeat != null) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.settings_clientRepeat),
                subtitle: Text(l10n.settings_clientRepeatSubtitle),
                value: _clientRepeat,
                onChanged: (value) => setState(() => _clientRepeat = value),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(onPressed: _saveSettings, child: Text(l10n.common_save)),
      ],
    );
  }
}

class _DefaultFloodScopeDialog extends StatefulWidget {
  final MeshCoreConnector connector;

  const _DefaultFloodScopeDialog({required this.connector});

  @override
  State<_DefaultFloodScopeDialog> createState() =>
      _DefaultFloodScopeDialogState();
}

class _DefaultFloodScopeDialogState extends State<_DefaultFloodScopeDialog> {
  final _customController = TextEditingController();
  final _knownRegionsStore = KnownRegionsStore();

  bool _loading = true;
  bool _saving = false;
  String? _selected; // null means disabled / none
  List<String> _knownRegions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final known = await _knownRegionsStore.load();
    String? current = widget.connector.defaultFloodScopeName;
    try {
      current = await widget.connector.getDefaultFloodScope();
    } catch (_) {
      // Older firmware / timeout — keep cached value.
    }
    if (!mounted) return;
    setState(() {
      _knownRegions = known;
      _selected = (current == null || current.isEmpty)
          ? null
          : RegionScopeCodes.canonicalize(current);
      if (_selected != null && !_knownRegions.contains(_selected)) {
        _knownRegions = [..._knownRegions, _selected!];
      }
      _loading = false;
    });
  }

  Future<void> _apply(String? name) async {
    if (_saving) return;
    final l10n = context.l10n;
    setState(() => _saving = true);
    try {
      final ok = await widget.connector.setDefaultFloodScope(name);
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settings_defaultFloodScopeUnsupported)),
        );
        setState(() => _saving = false);
        return;
      }
      if (name != null && name.isNotEmpty) {
        await _knownRegionsStore.add(name);
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            name == null || name.isEmpty
                ? l10n.settings_defaultFloodScopeCleared
                : l10n.settings_defaultFloodScopeUpdated,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settings_error(e.toString()))),
      );
    }
  }

  Future<void> _applyCustom() async {
    final l10n = context.l10n;
    final name = _customController.text.trim();
    if (!MeshRegion.isValidRegionName(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settings_defaultFloodScopeInvalid)),
      );
      return;
    }
    await _apply(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.settings_defaultFloodScope),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settings_defaultFloodScopeFooter,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settings_defaultFloodScopeDisabled),
                      trailing: Icon(
                        _selected == null
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                      ),
                      onTap: _saving
                          ? null
                          : () => setState(() => _selected = null),
                    ),
                    for (final code in _knownRegions)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(MeshRegion.displayLabel(code)),
                        trailing: Icon(
                          _selected == code
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                        ),
                        onTap: _saving
                            ? null
                            : () => setState(() => _selected = code),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.settings_defaultFloodScopeCustom,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customController,
                      enabled: !_saving,
                      decoration: InputDecoration(
                        hintText: l10n.settings_defaultFloodScopeCustomHint,
                        border: const OutlineInputBorder(),
                      ),
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.none,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _saving ? null : _applyCustom,
                        child: Text(l10n.settings_defaultFloodScopeAddKnown),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: _saving || _loading ? null : () => _apply(_selected),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.common_save),
        ),
      ],
    );
  }
}
