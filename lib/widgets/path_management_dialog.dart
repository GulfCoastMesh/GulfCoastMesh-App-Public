import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gulf_coast_mesh_app/models/path_history.dart';
import 'package:gulf_coast_mesh_app/screens/path_trace_map.dart';
import 'package:gulf_coast_mesh_app/widgets/elements_ui.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../services/path_history_service.dart';
import '../connector/meshcore_protocol.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../services/app_settings_service.dart';
import '../theme/app_colors.dart';
import 'path_selection_dialog.dart';

class PathManagementDialog {
  static Future<void> show(BuildContext context, {required Contact contact}) {
    return showDialog<void>(
      context: context,
      builder: (context) => _PathManagementDialog(contact: contact),
    );
  }
}

class _PathManagementDialog extends StatefulWidget {
  final Contact contact;

  const _PathManagementDialog({required this.contact});

  @override
  State<_PathManagementDialog> createState() => _PathManagementDialogState();
}

class _PathManagementDialogState extends State<_PathManagementDialog> {
  bool _showAllPaths = false;

  Contact _resolveContact(MeshCoreConnector connector) {
    return connector.contacts.firstWhere(
      (c) => c.publicKeyHex == widget.contact.publicKeyHex,
      orElse: () => widget.contact,
    );
  }

  String _formatRelativeTime(BuildContext context, DateTime time) {
    final l10n = context.l10n;
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return l10n.time_justNow;
    if (diff.inMinutes < 60) return l10n.time_minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.time_hoursAgo(diff.inHours);
    return l10n.time_daysAgo(diff.inDays);
  }

  void _showFullPathDialog(BuildContext context, List<int> pathBytes) {
    final l10n = context.l10n;
    if (pathBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.chat_pathDetailsNotAvailable),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final formattedPath = pathBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(',');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chat_fullPath),
        content: SelectableText(formattedPath),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PathTraceMapScreen(
                  title: context.l10n.contacts_repeaterPathTrace,
                  path: Uint8List.fromList(pathBytes),
                  flipPathRound: true,
                ),
              ),
            ),
            child: Text(context.l10n.contacts_pathTrace),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_close),
          ),
        ],
      ),
    );
  }

  Future<void> _setCustomPath(
    BuildContext context,
    MeshCoreConnector connector,
    Contact currentContact,
  ) async {
    final l10n = context.l10n;
    final hashSizeBytes = pathHashBytesForMode(
      Provider.of<AppSettingsService>(
        context,
        listen: false,
      ).settings.companionPathHashMode,
    );
    if (currentContact.pathLength > 0 &&
        currentContact.path.isEmpty &&
        connector.isConnected) {
      unawaited(connector.refreshContactsBestEffort(tag: 'PathManagement'));
    }

    final pathForInput = currentContact.pathIdList;
    final availableContacts = connector.contacts
        .where((c) => c.publicKeyHex != currentContact.publicKeyHex)
        .toList();

    final result = await PathSelectionDialog.show(
      context,
      availableContacts: availableContacts,
      initialPath: pathForInput.isEmpty ? null : pathForInput,
      currentPathLabel: currentContact.pathLabel,
      onRefresh: connector.isConnected ? connector.getContacts : null,
      hashSizeBytes: hashSizeBytes,
    );

    if (result != null && context.mounted) {
      final hopCount = result.length ~/ hashSizeBytes;
      await connector.setPathOverride(
        currentContact,
        pathLen: hopCount,
        pathBytes: result,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.chat_hopsCount(hopCount)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Consumer2<MeshCoreConnector, PathHistoryService>(
      builder: (context, connector, pathService, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final currentContact = _resolveContact(connector);
        final paths = pathService.getRecentPaths(currentContact.publicKeyHex);

        final repeatersList = List.of(connector.directRepeaters)
          ..sort((a, b) => b.ranking.compareTo(a.ranking));

        if (repeatersList.isEmpty) {
          _showAllPaths = true;
        }

        final directRepeater = repeatersList.isEmpty
            ? null
            : repeatersList.first;
        final secondDirectRepeater = repeatersList.length < 2
            ? null
            : repeatersList.elementAt(1);
        final thirdDirectRepeater = repeatersList.length < 3
            ? null
            : repeatersList.elementAt(2);

        List<MapEntry<int, MapEntry<Color, PathRecord>>> pathsWithRepeaters =
            paths.map((path) {
              final isDirectRepeater =
                  directRepeater != null &&
                  path.pathBytes.isNotEmpty &&
                  directRepeater.pubkeyFirstByte == path.pathBytes.first;
              final isSecondDirectRepeater =
                  secondDirectRepeater != null &&
                  path.pathBytes.isNotEmpty &&
                  secondDirectRepeater.pubkeyFirstByte == path.pathBytes.first;
              final isThirdDirectRepeater =
                  thirdDirectRepeater != null &&
                  path.pathBytes.isNotEmpty &&
                  thirdDirectRepeater.pubkeyFirstByte == path.pathBytes.first;

              int ranking = -1;
              Color color = colorScheme.outlineVariant;
              if (isDirectRepeater) {
                color = context.appColors.connected;
                ranking = 3;
              } else if (isSecondDirectRepeater) {
                // Colors.yellow: 2nd-best-rank tier of a ranked legend, not
                // a themed semantic role.
                color = Colors.yellow;
                ranking = 2;
              } else if (isThirdDirectRepeater) {
                color = colorScheme.error;
                ranking = 1;
              } else if (path.wasFloodDiscovery) {
                color = colorScheme.primary;
                ranking = 0;
              }

              return MapEntry(ranking, MapEntry(color, path));
            }).toList();

        pathsWithRepeaters.sort((a, b) => b.key.compareTo(a.key));

        return AlertDialog(
          title: Text(l10n.chat_pathManagement),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.path_currentPath(currentContact.pathLabel),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (paths.isNotEmpty) ...[
                  if (repeatersList.isNotEmpty)
                    FeatureToggleRow(
                      title: l10n.chat_ShowAllPaths,
                      subtitle: "",
                      value: _showAllPaths,
                      onChanged: (val) {
                        setState(() {
                          _showAllPaths = val;
                        });
                      },
                    ),
                  Text(
                    l10n.chat_recentAckPaths,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  if (pathsWithRepeaters.length >= 100) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.chat_pathHistoryFull,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  ...pathsWithRepeaters.map((entry) {
                    final path = entry.value.value;
                    final color = entry.value.key;

                    if (!_showAllPaths && entry.key < 1) {
                      return const SizedBox.shrink();
                    } else {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: color,
                            child: Text(
                              '${path.hopCount}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          title: Text(
                            l10n.chat_hopsCount(path.hopCount),
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            '${(path.tripTimeMs / 1000).toStringAsFixed(2)}s • ${_formatRelativeTime(context, path.timestamp)} • ${path.successCount} ${l10n.chat_successes}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                tooltip: l10n.chat_removePath,
                                onPressed: () async {
                                  await pathService.removePathRecord(
                                    currentContact.publicKeyHex,
                                    path.pathBytes,
                                  );
                                },
                              ),
                              path.wasFloodDiscovery
                                  ? Icon(
                                      Icons.waves,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    )
                                  : Icon(
                                      Icons.route,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                            ],
                          ),
                          onLongPress: () =>
                              _showFullPathDialog(context, path.pathBytes),
                          onTap: () async {
                            if (path.pathBytes.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.chat_pathDetailsNotAvailable,
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            final pathBytes = Uint8List.fromList(
                              path.pathBytes,
                            );

                            await connector.setPathOverride(
                              currentContact,
                              pathLen: path.hopCount,
                              pathBytes: pathBytes,
                            );

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.path_usingHopsPath(path.hopCount),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  }),
                  const Divider(),
                ] else ...[
                  Text(l10n.chat_noPathHistoryYet),
                  const Divider(),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.chat_pathActions,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    // Colors.purple: distinct action-icon color, not a
                    // themed semantic role.
                    backgroundColor: Colors.purple,
                    child: const Icon(Icons.edit_road, size: 16),
                  ),
                  title: Text(
                    l10n.chat_setCustomPath,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    l10n.chat_setCustomPathSubtitle,
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () async {
                    await _setCustomPath(context, connector, currentContact);
                  },
                ),
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.tertiary,
                    child: const Icon(Icons.clear_all, size: 16),
                  ),
                  title: Text(
                    l10n.chat_clearPath,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    l10n.chat_clearPathSubtitle,
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () async {
                    await connector.clearContactPath(currentContact);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.chat_pathCleared),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.primary,
                    child: const Icon(Icons.waves, size: 16),
                  ),
                  title: Text(
                    l10n.chat_forceFloodMode,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    l10n.chat_floodModeSubtitle,
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () async {
                    await connector.setPathOverride(
                      currentContact,
                      pathLen: -1,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.chat_floodModeEnabled),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.common_close),
            ),
          ],
        );
      },
    );
  }
}
