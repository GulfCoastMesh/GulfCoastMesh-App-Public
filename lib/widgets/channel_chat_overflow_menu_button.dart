import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/channel_invite_uri.dart';
import '../helpers/channel_region_scope_prompt.dart';
import '../l10n/l10n.dart';
import '../models/channel.dart';
import '../screens/notification_pref_screen.dart';
import 'connection_overflow_menu_button.dart';
import 'qr_code_display.dart';

/// Channel chat overflow: set scope, share QR, notifications, then settings / disconnect.
class ChannelChatOverflowMenuButton extends StatelessWidget {
  static const String valueSetScope = 'set_scope';
  static const String valueShareChannel = 'share_channel';
  static const String valueNotifications = 'notifications';

  final Channel channel;

  const ChannelChatOverflowMenuButton({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ConnectionOverflowMenuButton(
      extraItemsBeforeSettings: [
        PopupMenuItem(
          value: valueSetScope,
          child: Row(
            children: [
              const Icon(Icons.map_outlined, size: 20),
              const SizedBox(width: 12),
              Text(l10n.channels_setScope),
            ],
          ),
        ),
        PopupMenuItem(
          value: valueShareChannel,
          child: Row(
            children: [
              const Icon(Icons.qr_code, size: 20),
              const SizedBox(width: 12),
              Text(l10n.channels_shareChannel),
            ],
          ),
        ),
        PopupMenuItem(
          value: valueNotifications,
          child: Row(
            children: [
              const Icon(Icons.notifications_outlined, size: 20),
              const SizedBox(width: 12),
              Text(l10n.notificationPref_title),
            ],
          ),
        ),
      ],
      onExtraSelected: (value) async {
        if (value == valueSetScope) {
          await promptChannelRegionScope(
            context,
            channelIndex: channel.index,
            showPromptSubtitle: false,
          );
        } else if (value == valueShareChannel) {
          await _shareChannel(context);
        } else if (value == valueNotifications) {
          final name = channel.name.isEmpty
              ? context.l10n.channels_channelIndex(channel.index)
              : channel.name;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationPrefScreen(
                channelIndex: channel.index,
                itemName: name,
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _shareChannel(BuildContext context) async {
    final connector = context.read<MeshCoreConnector>();
    final name = channel.name.isEmpty
        ? context.l10n.channels_channelIndex(channel.index)
        : channel.name;
    final scope = connector.getChannelRegionScope(channel.index);
    final uri = ChannelInviteUri.build(
      name: name,
      secretHex: channel.pskHex,
      regionScope: scope,
    );

    await QrCodeShareDialog.show(
      context: context,
      data: uri,
      title: context.l10n.channels_shareChannelTitle,
      instructions: context.l10n.channels_shareChannelInstructions(name),
      embeddedImage: Image.asset(
        'assets/images/gulf_coast_mesh_logo.png',
        width: 40,
        height: 40,
      ),
    );
  }
}
