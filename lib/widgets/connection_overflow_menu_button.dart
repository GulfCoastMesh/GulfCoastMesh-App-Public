import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../screens/settings_screen.dart';
import '../utils/dialog_utils.dart';

/// Overflow (⋮) menu shared across connected screens: Settings and Disconnect,
/// plus optional per-screen entries before Settings.
class ConnectionOverflowMenuButton extends StatelessWidget {
  static const String valueSettings = 'settings';
  static const String valueDisconnect = 'disconnect';

  /// Custom menu values (must not be [valueSettings] or [valueDisconnect]).
  final List<PopupMenuEntry<String>> extraItemsBeforeSettings;

  /// Called for menu [value] not handled by this widget.
  final Future<void> Function(String value)? onExtraSelected;

  final IconData icon;
  final String? tooltip;

  const ConnectionOverflowMenuButton({
    super.key,
    this.extraItemsBeforeSettings = const [],
    this.onExtraSelected,
    this.icon = Icons.more_vert,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopupMenuButton<String>(
      icon: Icon(icon),
      tooltip: tooltip ?? l10n.settings_title,
      onSelected: (value) => _handleSelected(context, value),
      itemBuilder: (context) => [
        ...extraItemsBeforeSettings,
        PopupMenuItem(
          value: valueSettings,
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 20),
              const SizedBox(width: 12),
              Text(l10n.settings_title),
            ],
          ),
        ),
        if (extraItemsBeforeSettings.isNotEmpty) const PopupMenuDivider(),
        PopupMenuItem(
          value: valueDisconnect,
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(l10n.common_disconnect),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSelected(BuildContext context, String value) async {
    if (value == valueSettings) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
      return;
    }
    if (value == valueDisconnect) {
      final connector = context.read<MeshCoreConnector>();
      await showDisconnectDialog(context, connector);
      return;
    }
    if (onExtraSelected != null) {
      await onExtraSelected!(value);
    }
  }
}
