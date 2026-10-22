import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/list_filters.dart';
import '../l10n/l10n.dart';
import '../services/app_settings_service.dart';
import 'add_channel_dialog.dart';
import 'connection_overflow_menu_button.dart';

/// Chats screen overflow (⋮): add channel, sort mode, then settings / disconnect.
class ChatsOverflowMenuButton extends StatelessWidget {
  static const String valueAddChannel = 'add_channel';
  static const String valueSortRecent = 'sort_recent';
  static const String valueSortAlphabetical = 'sort_alphabetical';

  const ChatsOverflowMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final sortMode = chatSortModeFromString(
      context.watch<AppSettingsService>().settings.chatSortMode,
    );
    return ConnectionOverflowMenuButton(
      extraItemsBeforeSettings: [
        PopupMenuItem(
          value: valueAddChannel,
          child: Row(
            children: [
              const Icon(Icons.add, size: 20),
              const SizedBox(width: 12),
              Text(context.l10n.channels_addChannel),
            ],
          ),
        ),
        CheckedPopupMenuItem(
          value: valueSortRecent,
          checked: sortMode == ChatSortMode.recent,
          child: Text(context.l10n.chats_sortMostRecent),
        ),
        CheckedPopupMenuItem(
          value: valueSortAlphabetical,
          checked: sortMode == ChatSortMode.alphabetical,
          child: Text(context.l10n.chats_sortAlphabetical),
        ),
      ],
      onExtraSelected: (value) async {
        if (value == valueAddChannel) {
          await showAddChannelDialog(context);
          return;
        }
        if (value == valueSortRecent) {
          await context.read<AppSettingsService>().setChatSortMode(
            chatSortModeToString(ChatSortMode.recent),
          );
          return;
        }
        if (value == valueSortAlphabetical) {
          await context.read<AppSettingsService>().setChatSortMode(
            chatSortModeToString(ChatSortMode.alphabetical),
          );
        }
      },
    );
  }
}
