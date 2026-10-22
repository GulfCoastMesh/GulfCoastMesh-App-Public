import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gulf_coast_mesh_app/utils/gpx_export.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/adaptive_layout.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../models/notification_pref.dart';
import '../models/wardriving.dart';
import '../services/app_settings_service.dart';
import '../services/blocked_nodes_service.dart';
import '../services/notification_service.dart';
import '../services/wardriving_service.dart';
import '../storage/debug_report_store.dart';
import '../widgets/adaptive_app_bar_title.dart';
import 'app_debug_log_screen.dart';
import 'blocked_nodes_screen.dart';
import 'frame_debug_log_screen.dart';
import 'map_cache_screen.dart';
import 'telemetry_monitor_screen.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(context.l10n.appSettings_title),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Consumer2<AppSettingsService, MeshCoreConnector>(
          builder: (context, settingsService, connector, child) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAppearanceCard(context, settingsService),
                const SizedBox(height: 16),
                _buildNotificationsCard(context, settingsService),
                const SizedBox(height: 16),
                _buildMessagingCard(context, settingsService, connector),
                const SizedBox(height: 16),
                _buildMediaCard(context, settingsService),
                const SizedBox(height: 16),
                _buildBatteryCard(context, settingsService, connector),
                const SizedBox(height: 16),
                _buildTelemetryCard(context, settingsService, connector),
                const SizedBox(height: 16),
                _buildMapSettingsCard(context, settingsService),
                const SizedBox(height: 16),
                _buildWardrivingSettingsCard(context, settingsService),
                const SizedBox(height: 16),
                _buildDebugCard(context, settingsService, connector),
                const SizedBox(height: 16),
                _buildExperimentalCard(context, settingsService),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              context.l10n.appSettings_appearance,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(context.l10n.appSettings_theme),
            subtitle: Text(
              _themeModeLabel(context, settingsService.settings.themeMode),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeModeDialog(context, settingsService),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(context.l10n.appSettings_language),
            subtitle: Text(
              _languageLabel(
                context,
                settingsService.settings.languageOverride,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context, settingsService),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.tablet_outlined),
            title: Text(context.l10n.appSettings_layoutMode),
            subtitle: Text(
              _layoutModeLabel(context, settingsService.settings.layoutMode),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLayoutModeDialog(context, settingsService),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.location_searching),
            title: Text(context.l10n.appSettings_enableMessageTracing),
            subtitle: Text(
              context.l10n.appSettings_enableMessageTracingSubtitle,
            ),
            value: settingsService.settings.enableMessageTracing,
            onChanged: (value) {
              settingsService.setEnableMessageTracing(value);
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.analytics_outlined),
            title: Text(context.l10n.appSettings_meshAnalyzer),
            subtitle: Text(context.l10n.appSettings_meshAnalyzerSubtitle),
            value: settingsService.settings.meshAnalyzerEnabled,
            onChanged: (value) async {
              if (value) {
                final width = MediaQuery.of(context).size.width;
                final isMobileLayout = !useWideAdaptiveLayout(
                  settingsService.settings.layoutMode,
                  width,
                );
                if (isMobileLayout) {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(
                        dialogContext
                            .l10n
                            .appSettings_meshAnalyzerMobileWarningTitle,
                      ),
                      content: Text(
                        dialogContext
                            .l10n
                            .appSettings_meshAnalyzerMobileWarningBody,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(dialogContext.l10n.common_cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text(dialogContext.l10n.common_continue),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  if (!context.mounted) return;
                }
              }
              await settingsService.setMeshAnalyzerEnabled(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              context.l10n.appSettings_notifications,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(context.l10n.appSettings_enableNotifications),
            subtitle: Text(
              context.l10n.appSettings_enableNotificationsSubtitle,
            ),
            value: settingsService.settings.notificationsEnabled,
            onChanged: (value) async {
              if (value) {
                // Request permission when enabling
                final granted = await NotificationService()
                    .requestPermissions();
                if (!granted) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n.appSettings_notificationPermissionDenied,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                  return;
                }
              }

              await settingsService.setNotificationsEnabled(value);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? context.l10n.appSettings_notificationsEnabled
                          : context.l10n.appSettings_notificationsDisabled,
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.message_outlined,
              color: settingsService.settings.notificationsEnabled
                  ? null
                  : colorScheme.outline,
            ),
            title: Text(
              context.l10n.appSettings_messageNotifications,
              style: TextStyle(
                color: settingsService.settings.notificationsEnabled
                    ? null
                    : colorScheme.outline,
              ),
            ),
            subtitle: Text(
              context.l10n.appSettings_messageNotificationsSubtitle,
              style: TextStyle(
                color: settingsService.settings.notificationsEnabled
                    ? null
                    : colorScheme.outline,
              ),
            ),
            value: settingsService.settings.notifyOnNewMessage,
            onChanged: settingsService.settings.notificationsEnabled
                ? (value) {
                    settingsService.setNotifyOnNewMessage(value);
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.forum_outlined,
              color: settingsService.settings.notificationsEnabled
                  ? null
                  : colorScheme.outline,
            ),
            title: Text(
              context.l10n.appSettings_channelMessageNotifications,
              style: TextStyle(
                color: settingsService.settings.notificationsEnabled
                    ? null
                    : colorScheme.outline,
              ),
            ),
            subtitle: Text(
              context.l10n.appSettings_channelMessageNotificationsSubtitle,
              style: TextStyle(
                color: settingsService.settings.notificationsEnabled
                    ? null
                    : colorScheme.outline,
              ),
            ),
            value: settingsService.settings.notifyOnNewChannelMessage,
            onChanged: settingsService.settings.notificationsEnabled
                ? (value) {
                    settingsService.setNotifyOnNewChannelMessage(value);
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.cell_tower,
              color: settingsService.settings.notificationsEnabled
                  ? null
                  : colorScheme.outline,
            ),
            title: Text(
              context.l10n.appSettings_advertisementNotifications,
              style: TextStyle(
                color: settingsService.settings.notificationsEnabled
                    ? null
                    : colorScheme.outline,
              ),
            ),
            subtitle: Text(
              context.l10n.appSettings_advertisementNotificationsSubtitle,
              style: TextStyle(
                color: settingsService.settings.notificationsEnabled
                    ? null
                    : colorScheme.outline,
              ),
            ),
            value: settingsService.settings.notifyOnNewAdvert,
            onChanged: settingsService.settings.notificationsEnabled
                ? (value) {
                    settingsService.setNotifyOnNewAdvert(value);
                  }
                : null,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.tune,
              color: settingsService.settings.notificationsEnabled
                  ? null
                  : colorScheme.outline,
            ),
            title: Text(
              context.l10n.appSettings_notificationDefaultLevel,
              style: TextStyle(
                color: settingsService.settings.notificationsEnabled
                    ? null
                    : colorScheme.outline,
              ),
            ),
            subtitle: Text(
              _notificationLevelLabel(
                context,
                settingsService.settings.notificationDefaultLevel,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DropdownButtonFormField<NotificationLevel>(
              initialValue: settingsService.settings.notificationDefaultLevel,
              isExpanded: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                isDense: true,
              ),
              onChanged: settingsService.settings.notificationsEnabled
                  ? (value) {
                      if (value != null) {
                        settingsService.setNotificationDefaultLevel(value);
                      }
                    }
                  : null,
              items: [
                DropdownMenuItem(
                  value: NotificationLevel.none,
                  child: Text(context.l10n.notificationPref_none),
                ),
                DropdownMenuItem(
                  value: NotificationLevel.all,
                  child: Text(context.l10n.notificationPref_all),
                ),
                DropdownMenuItem(
                  value: NotificationLevel.mentions,
                  child: Text(context.l10n.notificationPref_mentions),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _notificationLevelLabel(
    BuildContext context,
    NotificationLevel level,
  ) {
    switch (level) {
      case NotificationLevel.none:
        return context.l10n.notificationPref_none;
      case NotificationLevel.all:
        return context.l10n.notificationPref_all;
      case NotificationLevel.mentions:
        return context.l10n.notificationPref_mentions;
      case NotificationLevel.custom:
        return context.l10n.notificationPref_custom;
    }
  }

  Widget _buildMessagingCard(
    BuildContext context,
    AppSettingsService settingsService,
    MeshCoreConnector connector,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              context.l10n.appSettings_messaging,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.refresh_outlined),
            title: Text(context.l10n.appSettings_clearPathOnMaxRetry),
            subtitle: Text(
              context.l10n.appSettings_clearPathOnMaxRetrySubtitle,
            ),
            value: settingsService.settings.clearPathOnMaxRetry,
            onChanged: (value) {
              settingsService.setClearPathOnMaxRetry(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? context.l10n.appSettings_pathsWillBeCleared
                        : context.l10n.appSettings_pathsWillNotBeCleared,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.alt_route),
            title: Text(context.l10n.appSettings_autoRouteRotation),
            subtitle: Text(context.l10n.appSettings_autoRouteRotationSubtitle),
            value: settingsService.settings.autoRouteRotationEnabled,
            onChanged: (value) {
              settingsService.setAutoRouteRotationEnabled(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? context.l10n.appSettings_autoRouteRotationEnabled
                        : context.l10n.appSettings_autoRouteRotationDisabled,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.route_outlined),
            title: Text(context.l10n.appSettings_companionPathHashMode),
            subtitle: Text(
              _companionPathHashModeLabel(
                context,
                settingsService.settings.companionPathHashMode,
                connector,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCompanionPathHashModeDialog(
              context,
              settingsService,
              connector,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    final settings = settingsService.settings;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.link_outlined),
            title: Text(context.l10n.appSettings_linkPreviews),
            subtitle: Text(context.l10n.appSettings_linkPreviewsSubtitle),
            value: settings.richLinkPreviewsEnabled,
            onChanged: settingsService.setRichLinkPreviewsEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildExperimentalCard(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Experimental',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.cloud_outlined),
            title: Text(context.l10n.appSettings_weatherDisplay),
            subtitle: Text(context.l10n.appSettings_weatherDisplaySubtitle),
            value: settingsService.settings.experimentalWeatherEnabled,
            onChanged: settingsService.setExperimentalWeatherEnabled,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.block),
            title: Text(context.l10n.appSettings_nodeBlocking),
            subtitle: Text(context.l10n.appSettings_nodeBlockingSubtitle),
            value: settingsService.settings.experimentalNodeBlockingEnabled,
            onChanged: settingsService.setExperimentalNodeBlockingEnabled,
          ),
          if (settingsService.settings.experimentalNodeBlockingEnabled)
            ListTile(
              leading: const Icon(Icons.visibility_off_outlined),
              title: Text(context.l10n.appSettings_blockedNodes),
              subtitle: Text(
                context.l10n.appSettings_blockedNodesCount(
                  context.watch<BlockedNodesService>().count,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlockedNodesScreen(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _companionPathHashModeLabel(
    BuildContext context,
    int mode,
    MeshCoreConnector connector,
  ) {
    final l10n = context.l10n;
    final label = switch (mode) {
      0 => l10n.appSettings_companionPathHashMode1Byte,
      2 => l10n.appSettings_companionPathHashMode3Byte,
      _ => l10n.appSettings_companionPathHashMode2Byte,
    };
    if (connector.isConnected && !connector.supportsPathHashMode) {
      return '$label · ${l10n.appSettings_companionPathHashModeUnsupported}';
    }
    return label;
  }

  Future<void> _showCompanionPathHashModeDialog(
    BuildContext context,
    AppSettingsService settingsService,
    MeshCoreConnector connector,
  ) async {
    final l10n = context.l10n;
    final current = settingsService.settings.companionPathHashMode;
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.appSettings_companionPathHashMode),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              l10n.appSettings_companionPathHashModeWarning,
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 0),
            child: Text(l10n.appSettings_companionPathHashMode1Byte),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 1),
            child: Text(l10n.appSettings_companionPathHashMode2Byte),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 2),
            child: Text(l10n.appSettings_companionPathHashMode3Byte),
          ),
        ],
      ),
    );

    if (selected == null || selected == current || !context.mounted) return;

    await settingsService.setCompanionPathHashMode(selected);
    if (connector.isConnected) {
      final applied = await connector.setCompanionPathHashMode(selected);
      if (context.mounted && !applied && !connector.supportsPathHashMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appSettings_companionPathHashModeUnsupported),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.appSettings_companionPathHashModeApplied),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildMapSettingsCard(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              context.l10n.appSettings_mapDisplay,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.router_outlined),
            title: Text(context.l10n.appSettings_showRepeaters),
            subtitle: Text(context.l10n.appSettings_showRepeatersSubtitle),
            value: settingsService.settings.mapShowRepeaters,
            onChanged: (value) {
              settingsService.setMapShowRepeaters(value);
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.chat_outlined),
            title: Text(context.l10n.appSettings_showChatNodes),
            subtitle: Text(context.l10n.appSettings_showChatNodesSubtitle),
            value: settingsService.settings.mapShowChatNodes,
            onChanged: (value) {
              settingsService.setMapShowChatNodes(value);
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.people_outline),
            title: Text(context.l10n.appSettings_showOtherNodes),
            subtitle: Text(context.l10n.appSettings_showOtherNodesSubtitle),
            value: settingsService.settings.mapShowOtherNodes,
            onChanged: (value) {
              settingsService.setMapShowOtherNodes(value);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(context.l10n.appSettings_timeFilter),
            subtitle: Text(
              settingsService.settings.mapTimeFilterHours == 0
                  ? context.l10n.appSettings_timeFilterShowAll
                  : context.l10n.appSettings_timeFilterShowLast(
                      settingsService.settings.mapTimeFilterHours.toInt(),
                    ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimeFilterDialog(context, settingsService),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: Text(context.l10n.appSettings_unitsTitle),
            subtitle: Text(
              settingsService.settings.unitSystem == UnitSystem.imperial
                  ? context.l10n.appSettings_unitsImperial
                  : context.l10n.appSettings_unitsMetric,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showUnitsDialog(context, settingsService),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(context.l10n.appSettings_offlineMapCache),
            subtitle: Text(
              _mapCacheSettingsSubtitle(settingsService.settings, context.l10n),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapCacheScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Fixed rendering issues
  Widget _buildWardrivingSettingsCard(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    final settings = settingsService.settings;
    final wardriving = context.watch<WardrivingService>();
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Wardriving',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(context.l10n.wardriving_operationInterval),
            subtitle: Text(
              context.l10n.wardriving_intervalSummary(
                settings.wardrivingIntervalSec,
                settings.wardrivingMinDistanceMeters.round(),
              ),
            ),
            trailing: DropdownButton<int>(
              value: [15, 30, 60].contains(settings.wardrivingIntervalSec)
                  ? settings.wardrivingIntervalSec
                  : 15,
              items: const [15, 30, 60]
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text('${value}s'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  settingsService.setWardrivingIntervalSec(value);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextFormField(
              initialValue: settings.wardrivingMinDistanceMeters
                  .toStringAsFixed(0),
              decoration: InputDecoration(
                labelText: context.l10n.wardriving_minDistanceLabel,
                helperText: context.l10n.wardriving_minDistanceHelper,
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onFieldSubmitted: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null && parsed >= kWardrivingMinDistanceMeters) {
                  settingsService.setWardrivingMinDistanceMeters(parsed);
                }
              },
            ),
          ),
          SwitchListTile(
            title: Text(context.l10n.wardriving_externalAntenna),
            value: settings.wardrivingExternalAntenna,
            onChanged: settingsService.setWardrivingExternalAntenna,
          ),
          SwitchListTile(
            title: Text(context.l10n.wardriving_continueInBackground),
            subtitle: Text(
              context.l10n.wardriving_continueInBackgroundSubtitle,
            ),
            value: settings.wardrivingBackgroundEnabled,
            onChanged: settingsService.setWardrivingBackgroundEnabled,
          ),
          SwitchListTile(
            title: Text(context.l10n.wardriving_offlineSessionMode),
            subtitle: Text(
              wardriving.canChangeOfflineMode
                  ? context.l10n.wardriving_offlineSessionModeSubtitle
                  : context.l10n.wardriving_offlineSessionModeLocked,
            ),
            value: wardriving.isOfflineMode,
            onChanged: wardriving.canChangeOfflineMode
                ? settingsService.setWardrivingOfflineMode
                : null,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              context.l10n.wardriving_privacyAndUpload,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SwitchListTile(
            title: Text(context.l10n.wardriving_broadcastCoordinates),
            value: settings.wardrivingBroadcastCoordinates,
            onChanged: settingsService.setWardrivingBroadcastCoordinates,
          ),
          SwitchListTile(
            title: Text(context.l10n.wardriving_includeContactKeyPrefix),
            value: settings.wardrivingIncludeContactKey,
            onChanged: settingsService.setWardrivingIncludeContactKey,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              context.l10n.wardriving_advancedFiltering,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SwitchListTile(
            title: Text(context.l10n.wardriving_disableRssiFilter),
            value: settings.wardrivingDisableRssiFilter,
            onChanged: settingsService.setWardrivingDisableRssiFilter,
          ),
          SwitchListTile(
            title: Text(context.l10n.wardriving_allowDiscoveryDrops),
            subtitle: Text(context.l10n.wardriving_allowDiscoveryDropsSubtitle),
            value: settings.wardrivingDiscDropEnabled,
            onChanged: settingsService.setWardrivingDiscDropEnabled,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextFormField(
              initialValue: settings.wardrivingCarpeaterPrefix,
              decoration: InputDecoration(
                labelText: context.l10n.wardriving_carpeaterPrefixLabel,
              ),
              onFieldSubmitted: settingsService.setWardrivingCarpeaterPrefix,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              context.l10n.wardriving_coverageAppearance,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SwitchListTile(
            title: Text(context.l10n.wardriving_showCoverageOverlay),
            value: settings.wardrivingCoverageEnabled,
            onChanged: settingsService.setWardrivingCoverageEnabled,
          ),
          SegmentedButton<int>(
            style: const ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            segments: const [
              ButtonSegment(value: 300, label: Text('300 m grid')),
              ButtonSegment(value: 100, label: Text('100 m grid')),
            ],
            selected: {settings.wardrivingCoverageGridSize},
            onSelectionChanged: (selection) =>
                settingsService.setWardrivingCoverageGridSize(selection.first),
          ),
          Row(
            children: [
              const SizedBox(width: 16),
              const Text('Opacity'),
              Expanded(
                child: Slider(
                  value: settings.wardrivingCoverageOpacity,
                  min: .1,
                  max: 1,
                  onChanged: settingsService.setWardrivingCoverageOpacity,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard(
    BuildContext context,
    AppSettingsService settingsService,
    MeshCoreConnector connector,
  ) {
    final l10n = context.l10n;
    final settings = settingsService.settings;
    final repeaters = connector.contacts
        .where(
          (contact) =>
              contact.type == advTypeRepeater &&
              settingsService.hasRecentRepeaterLogin(contact.publicKeyHex),
        )
        .toList();
    final eligibleSelectedRepeaterCount = settings.telemetryRemoteNodeKeys
        .where(settingsService.hasRecentRepeaterLogin)
        .length;

    // One request plus one reply per node per interval; the user is choosing
    // how much airtime to spend, so show the rate rather than hiding it.
    final perHour = settings.telemetryRemoteEnabled
        ? (3600 / settings.telemetryRemoteIntervalSec) *
              eligibleSelectedRepeaterCount
        : 0.0;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.telemetrySettings_title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.monitor_heart_outlined),
            title: Text(l10n.telemetrySettings_enable),
            subtitle: Text(l10n.telemetrySettings_enableSubtitle),
            value: settings.telemetryMonitorEnabled,
            onChanged: settingsService.setTelemetryMonitorEnabled,
          ),
          if (settings.telemetryMonitorEnabled) ...[
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(l10n.telemetrySettings_interval),
              trailing: DropdownButton<int>(
                value:
                    const [
                      30,
                      60,
                      300,
                      900,
                    ].contains(settings.telemetryIntervalSec)
                    ? settings.telemetryIntervalSec
                    : 60,
                items: const [30, 60, 300, 900]
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(_intervalLabel(value)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    settingsService.setTelemetryIntervalSec(value);
                  }
                },
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.cell_tower),
              title: Text(l10n.telemetrySettings_remoteEnable),
              subtitle: Text(l10n.telemetrySettings_remoteSubtitle),
              value: settings.telemetryRemoteEnabled,
              onChanged: settingsService.setTelemetryRemoteEnabled,
            ),
            if (settings.telemetryRemoteEnabled) ...[
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l10n.telemetrySettings_remoteInterval),
                subtitle: Text(
                  l10n.telemetrySettings_airtimeEstimate(
                    perHour.toStringAsFixed(perHour < 10 ? 1 : 0),
                  ),
                ),
                trailing: DropdownButton<int>(
                  value:
                      kTelemetryRemoteIntervalOptionsSec.contains(
                        settings.telemetryRemoteIntervalSec,
                      )
                      ? settings.telemetryRemoteIntervalSec
                      : kTelemetryRemoteDefaultIntervalSec,
                  items: kTelemetryRemoteIntervalOptionsSec
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(_intervalLabel(value)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      settingsService.setTelemetryRemoteIntervalSec(value);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  l10n.telemetrySettings_remoteNodes,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              if (repeaters.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    l10n.telemetrySettings_remoteNodesNone,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...repeaters.map(
                  (repeater) => CheckboxListTile(
                    dense: true,
                    title: Text(repeater.displayName),
                    value: settings.telemetryRemoteNodeKeys.contains(
                      repeater.publicKeyHex,
                    ),
                    onChanged: (value) =>
                        settingsService.setTelemetryRemoteNode(
                          repeater.publicKeyHex,
                          value ?? false,
                        ),
                  ),
                ),
            ],
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: Text(l10n.telemetrySettings_alerts),
              subtitle: Text(l10n.telemetrySettings_alertsSubtitle),
              value: settings.telemetryAlertsEnabled,
              onChanged: settingsService.setTelemetryAlertsEnabled,
            ),
            if (settings.telemetryAlertsEnabled) ...[
              ListTile(
                leading: const Icon(Icons.battery_alert_outlined),
                title: Text(l10n.telemetrySettings_lowBattery),
                trailing: DropdownButton<int>(
                  value:
                      const [
                        3200,
                        3400,
                        3600,
                        3800,
                      ].contains(settings.telemetryLowBatteryMillivolts)
                      ? settings.telemetryLowBatteryMillivolts
                      : 3400,
                  items: const [3200, 3400, 3600, 3800]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text('${(value / 1000).toStringAsFixed(1)} V'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      settingsService.setTelemetryLowBatteryMillivolts(value);
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.graphic_eq),
                title: Text(l10n.telemetrySettings_noiseFloor),
                trailing: DropdownButton<int>(
                  value:
                      const [
                        -100,
                        -95,
                        -90,
                        -85,
                        -80,
                      ].contains(settings.telemetryNoiseFloorAlertDbm)
                      ? settings.telemetryNoiseFloorAlertDbm
                      : -90,
                  items: const [-100, -95, -90, -85, -80]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text('$value dBm'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      settingsService.setTelemetryNoiseFloorAlertDbm(value);
                    }
                  },
                ),
              ),
            ],
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: Text(l10n.telemetryMonitor_title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TelemetryMonitorScreen(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _intervalLabel(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    return '${seconds ~/ 3600}h';
  }

  Widget _buildBatteryCard(
    BuildContext context,
    AppSettingsService settingsService,
    MeshCoreConnector connector,
  ) {
    final deviceId = connector.deviceId;
    final isConnected = connector.isConnected && deviceId != null;
    final selection = isConnected
        ? settingsService.batteryChemistryForDevice(deviceId)
        : 'nmc';
    final cellCountSelection = isConnected
        ? settingsService.batteryCellCountForDevice(deviceId)
        : 1;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              context.l10n.appSettings_battery,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Main tile (icon + text only)
          ListTile(
            leading: const Icon(Icons.battery_full),
            title: Text(context.l10n.appSettings_batteryChemistry),
            subtitle: Text(
              isConnected
                  ? context.l10n.appSettings_batteryChemistryPerDevice(
                      connector.deviceDisplayName,
                    )
                  : context.l10n.appSettings_batteryChemistryConnectFirst,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Dropdown (separate full-width row)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DropdownButtonFormField<String>(
              initialValue: selection,
              isExpanded: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                isDense: true,
              ),
              onChanged: isConnected
                  ? (value) {
                      if (value != null) {
                        settingsService.setBatteryChemistryForDevice(
                          deviceId,
                          value,
                        );
                      }
                    }
                  : null,
              items: [
                DropdownMenuItem(
                  value: 'nmc',
                  child: Text(context.l10n.appSettings_batteryNmc),
                ),
                DropdownMenuItem(
                  value: 'lifepo4',
                  child: Text(context.l10n.appSettings_batteryLifepo4),
                ),
                DropdownMenuItem(
                  value: 'lipo',
                  child: Text(context.l10n.appSettings_batteryLipo),
                ),
              ],
            ),
          ),

          // Cell count dropdown (separate full-width row)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DropdownButtonFormField<int>(
              initialValue: cellCountSelection,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.l10n.appSettings_batteryCellCount,
                border: const UnderlineInputBorder(),
                isDense: true,
              ),
              onChanged: isConnected
                  ? (value) {
                      if (value != null) {
                        settingsService.setBatteryCellCountForDevice(
                          deviceId,
                          value,
                        );
                      }
                    }
                  : null,
              items: [
                DropdownMenuItem(
                  value: 1,
                  child: Text(context.l10n.appSettings_batteryCellCount1S),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text(context.l10n.appSettings_batteryCellCount2S),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text(context.l10n.appSettings_batteryCellCount3S),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Text(context.l10n.appSettings_batteryCellCount4S),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLayoutModeDialog(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.appSettings_layoutMode),
        content: RadioGroup<AppLayoutMode>(
          groupValue: settingsService.settings.layoutMode,
          onChanged: (value) {
            if (value != null) {
              settingsService.setLayoutMode(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AppLayoutMode>(
                title: Text(context.l10n.appSettings_layoutModeAuto),
                subtitle: Text(context.l10n.appSettings_layoutModeAutoSubtitle),
                value: AppLayoutMode.auto,
              ),
              RadioListTile<AppLayoutMode>(
                title: Text(context.l10n.appSettings_layoutModeMobile),
                subtitle: Text(
                  context.l10n.appSettings_layoutModeMobileSubtitle,
                ),
                value: AppLayoutMode.mobile,
              ),
              RadioListTile<AppLayoutMode>(
                title: Text(context.l10n.appSettings_layoutModeTablet),
                subtitle: Text(
                  context.l10n.appSettings_layoutModeTabletSubtitle,
                ),
                value: AppLayoutMode.tablet,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.common_close),
          ),
        ],
      ),
    );
  }

  String _layoutModeLabel(BuildContext context, AppLayoutMode value) {
    switch (value) {
      case AppLayoutMode.mobile:
        return context.l10n.appSettings_layoutModeMobile;
      case AppLayoutMode.tablet:
        return context.l10n.appSettings_layoutModeTablet;
      case AppLayoutMode.auto:
        return context.l10n.appSettings_layoutModeAuto;
    }
  }

  void _showThemeModeDialog(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.appSettings_theme),
        content: RadioGroup<String>(
          groupValue: settingsService.settings.themeMode,
          onChanged: (value) {
            if (value != null) {
              settingsService.setThemeMode(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(context.l10n.appSettings_themeSystem),
                value: 'system',
              ),
              RadioListTile<String>(
                title: Text(context.l10n.appSettings_themeLight),
                value: 'light',
              ),
              RadioListTile<String>(
                title: Text(context.l10n.appSettings_themeDark),
                value: 'dark',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.common_close),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(BuildContext context, String value) {
    switch (value) {
      case 'light':
        return context.l10n.appSettings_themeLight;
      case 'dark':
        return context.l10n.appSettings_themeDark;
      default:
        return context.l10n.appSettings_themeSystem;
    }
  }

  String _languageLabel(BuildContext context, String? languageCode) {
    switch (languageCode) {
      case 'en':
        return context.l10n.appSettings_languageEn;
      case 'fr':
        return context.l10n.appSettings_languageFr;
      case 'es':
        return context.l10n.appSettings_languageEs;
      case 'de':
        return context.l10n.appSettings_languageDe;
      case 'pl':
        return context.l10n.appSettings_languagePl;
      case 'sl':
        return context.l10n.appSettings_languageSl;
      case 'pt':
        return context.l10n.appSettings_languagePt;
      case 'it':
        return context.l10n.appSettings_languageIt;
      case 'zh':
        return context.l10n.appSettings_languageZh;
      case 'sv':
        return context.l10n.appSettings_languageSv;
      case 'nl':
        return context.l10n.appSettings_languageNl;
      case 'sk':
        return context.l10n.appSettings_languageSk;
      case 'bg':
        return context.l10n.appSettings_languageBg;
      case 'ru':
        return context.l10n.appSettings_languageRu;
      case 'uk':
        return context.l10n.appSettings_languageUk;
      default:
        return context.l10n.appSettings_languageSystem;
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.appSettings_language),
        content: SingleChildScrollView(
          child: RadioGroup<String?>(
            groupValue: settingsService.settings.languageOverride,
            onChanged: (value) {
              settingsService.setLanguageOverride(value);
              Navigator.pop(context);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageSystem),
                  value: null,
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageEn),
                  value: 'en',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageFr),
                  value: 'fr',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageEs),
                  value: 'es',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageDe),
                  value: 'de',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languagePl),
                  value: 'pl',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageSl),
                  value: 'sl',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languagePt),
                  value: 'pt',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageIt),
                  value: 'it',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageZh),
                  value: 'zh',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageSv),
                  value: 'sv',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageNl),
                  value: 'nl',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageSk),
                  value: 'sk',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageBg),
                  value: 'bg',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageRu),
                  value: 'ru',
                ),
                RadioListTile<String?>(
                  title: Text(context.l10n.appSettings_languageUk),
                  value: 'uk',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.common_close),
          ),
        ],
      ),
    );
  }

  void _showTimeFilterDialog(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.appSettings_mapTimeFilter),
        content: RadioGroup<double>(
          groupValue: settingsService.settings.mapTimeFilterHours,
          onChanged: (value) {
            if (value != null) {
              settingsService.setMapTimeFilterHours(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.appSettings_showNodesDiscoveredWithin),
              const SizedBox(height: 16),
              ListTile(
                title: Text(context.l10n.appSettings_allTime),
                leading: Radio<double>(value: 0),
              ),
              ListTile(
                title: Text(context.l10n.appSettings_lastHour),
                leading: Radio<double>(value: 1),
              ),
              ListTile(
                title: Text(context.l10n.appSettings_last6Hours),
                leading: Radio<double>(value: 6),
              ),
              ListTile(
                title: Text(context.l10n.appSettings_last24Hours),
                leading: Radio<double>(value: 24),
              ),
              ListTile(
                title: Text(context.l10n.appSettings_lastWeek),
                leading: Radio<double>(value: 168),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.common_close),
          ),
        ],
      ),
    );
  }

  void _showUnitsDialog(
    BuildContext context,
    AppSettingsService settingsService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.appSettings_unitsTitle),
        content: RadioGroup<UnitSystem>(
          groupValue: settingsService.settings.unitSystem,
          onChanged: (value) {
            if (value != null) {
              settingsService.setUnitSystem(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(context.l10n.appSettings_unitsMetric),
                leading: const Radio<UnitSystem>(value: UnitSystem.metric),
              ),
              ListTile(
                title: Text(context.l10n.appSettings_unitsImperial),
                leading: const Radio<UnitSystem>(value: UnitSystem.imperial),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.common_close),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugCard(
    BuildContext context,
    AppSettingsService settingsService,
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
              l10n.appSettings_debugCard,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.bug_report_outlined),
            title: Text(l10n.appSettings_appDebugLogging),
            subtitle: Text(l10n.appSettings_appDebugLoggingSubtitle),
            value: settingsService.settings.appDebugLogEnabled,
            onChanged: (value) async {
              await settingsService.setAppDebugLogEnabled(value);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? l10n.appSettings_appDebugLoggingEnabled
                        : l10n.appSettings_appDebugLoggingDisabled,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.bluetooth_outlined),
            title: Text(l10n.settings_bleDebugLog),
            subtitle: Text(l10n.settings_bleDebugLogSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FrameDebugLogScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: Text(l10n.settings_appDebugLog),
            subtitle: Text(l10n.settings_appDebugLogSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppDebugLogScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l10n.debugLog_recentCodesTitle),
            subtitle: Text(l10n.debugLog_recentCodesSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRecentCodesDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l10n.settings_gpxExportRepeaters),
            subtitle: Text(l10n.settings_gpxExportRepeatersSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final exporter = GpxExport(connector);
              exporter.addRepeaters();
              await _gpxExportFromAppSettings(
                context,
                exporter,
                l10n.map_repeater,
                l10n.settings_gpxExportRepeatersRoom,
                'meshcore_repeaters_',
                l10n.settings_gpxExportShareText,
                l10n.settings_gpxExportShareSubject,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l10n.settings_gpxExportContacts),
            subtitle: Text(l10n.settings_gpxExportContactsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final exporter = GpxExport(connector);
              exporter.addContacts();
              await _gpxExportFromAppSettings(
                context,
                exporter,
                l10n.map_repeater,
                l10n.settings_gpxExportChat,
                'meshcore_contacts_',
                l10n.settings_gpxExportShareText,
                l10n.settings_gpxExportShareSubject,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l10n.settings_gpxExportAll),
            subtitle: Text(l10n.settings_gpxExportAllSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final exporter = GpxExport(connector);
              exporter.addAll();
              await _gpxExportFromAppSettings(
                context,
                exporter,
                l10n.map_repeater,
                l10n.settings_gpxExportAllContacts,
                'meshcore_all_',
                l10n.settings_gpxExportShareText,
                l10n.settings_gpxExportShareSubject,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRecentCodesDialog(BuildContext context) {
    final l10n = context.l10n;
    final records = DebugReportStore().loadRecent();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.debugLog_recentCodesTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: records.isEmpty
              ? Text(l10n.debugLog_recentCodesEmpty)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final record in records)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(record.code),
                        subtitle: Text(record.sentAt.toLocal().toString()),
                        trailing: IconButton(
                          tooltip: l10n.common_copy,
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: record.code),
                            );
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(l10n.debugLog_reportCodeCopied),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_close),
          ),
        ],
      ),
    );
  }
}

Future<void> _gpxExportFromAppSettings(
  BuildContext context,
  GpxExport exporter,
  String name,
  String description,
  String filename,
  String shareText,
  String subject,
) async {
  final l10n = context.l10n;
  final result = await exporter.exportGPX(
    name,
    description,
    filename,
    shareText,
    subject,
  );
  if (!context.mounted) return;
  switch (result) {
    case gpxExportSuccess:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settings_gpxExportSuccess)));
    case gpxExportNoContacts:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settings_gpxExportNoContacts)),
      );
      break;
    case gpxExportNotAvailable:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settings_gpxExportNotAvailable)),
      );
      break;
    case gpxExportFailed:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settings_gpxExportError)));
      break;
  }
}

String _mapCacheSettingsSubtitle(AppSettings settings, AppLocalizations l10n) {
  final parts = <String>[
    l10n.appSettings_mapCacheSummaryWorld(
      settings.mapCacheWorldMinZoom,
      settings.mapCacheWorldMaxZoom,
    ),
    l10n.mapCache_presetGulfCoast,
  ];
  if (settings.mapCacheBounds != null) {
    parts.add(
      l10n.appSettings_mapCacheSummaryCustom(
        settings.mapCacheMinZoom,
        settings.mapCacheMaxZoom,
      ),
    );
  }
  return parts.join(' · ');
}
