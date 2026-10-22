import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/list_filters.dart';
import '../l10n/l10n.dart';
import '../models/channel.dart';
import '../models/contact.dart';
import '../services/app_settings_service.dart';
import '../utils/dialog_utils.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/chats_overflow_menu_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chips.dart';
import '../widgets/relative_timestamp_text.dart';
import '../widgets/room_login_dialog.dart';
import '../widgets/unread_badge.dart';
import 'channel_chat_screen.dart';
import 'chat_screen.dart';

enum ConvType { contact, channel }

class Conversation {
  final String id;
  final ConvType type;
  final String name;
  final String? subtitle;
  final String? lastMessage;
  final DateTime lastActivity;
  final int unreadCount;
  final Contact? contact;
  final Channel? channel;

  const Conversation({
    required this.id,
    required this.type,
    required this.name,
    this.subtitle,
    this.lastMessage,
    required this.lastActivity,
    this.unreadCount = 0,
    this.contact,
    this.channel,
  });

  bool get isFavorite =>
      contact?.isFavorite == true || channel?.isFavorite == true;
}

class ChatsScreen extends StatefulWidget {
  final String? selectedId;
  final ValueChanged<Conversation>? onSelected;
  final bool hideScaffold;

  const ChatsScreen({
    super.key,
    this.selectedId,
    this.onSelected,
    this.hideScaffold = false,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;
  ChatFilter _filter = ChatFilter.all;
  bool _filterLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_filterLoaded) {
      final settings = context.read<AppSettingsService>().settings;
      _filter = chatFilterFromString(settings.chatFilter);
      _filterLoaded = true;
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _setFilter(ChatFilter filter) async {
    setState(() => _filter = filter);
    await context.read<AppSettingsService>().setChatFilter(
      chatFilterToString(filter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connector = context.watch<MeshCoreConnector>();
    final sortMode = chatSortModeFromString(
      context.watch<AppSettingsService>().settings.chatSortMode,
    );
    final conversations = _buildConversations(connector, sortMode);

    if (conversations.isEmpty && connector.isLoadingContacts) {
      return _wrap(context, const Center(child: CircularProgressIndicator()));
    }

    if (conversations.isEmpty) {
      return _wrap(
        context,
        EmptyState(
          icon: Icons.chat_bubble_outline,
          title: context.l10n.chat_noMessages,
          subtitle: context.l10n.chat_sendMessageToStart,
        ),
      );
    }

    final filtered = conversations.where((c) {
      if (!_matchesFilter(c)) return false;
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery) ||
          (c.lastMessage?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: context.l10n.chats_searchConversations,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                setState(() => _searchQuery = value.toLowerCase());
              });
            },
          ),
        ),
        FilterChipRow<ChatFilter>(
          selected: _filter,
          onSelected: _setFilter,
          items: [
            FilterChipItem(
              value: ChatFilter.all,
              label: context.l10n.chats_filterAll,
            ),
            FilterChipItem(
              value: ChatFilter.unread,
              label: context.l10n.chats_filterUnread,
            ),
            FilterChipItem(
              value: ChatFilter.dms,
              label: context.l10n.chats_filterDMs,
            ),
            FilterChipItem(
              value: ChatFilter.channels,
              label: context.l10n.chats_filterChannels,
            ),
            FilterChipItem(
              value: ChatFilter.rooms,
              label: context.l10n.chats_filterRooms,
            ),
          ],
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(context.l10n.chats_noConversationsFound))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final conv = filtered[index];
                    final tile = _ConversationTile(
                      conversation: conv,
                      selected: widget.selectedId == conv.id,
                      onTap: () => _handleTap(context, conv),
                      onToggleFavorite: () {
                        final connector = context.read<MeshCoreConnector>();
                        if (conv.contact != null) {
                          connector.toggleContactFavorite(conv.contact!);
                        } else if (conv.channel != null) {
                          connector.toggleChannelFavorite(conv.channel!);
                        }
                      },
                    );
                    if (conv.type != ConvType.channel || conv.channel == null) {
                      return tile;
                    }
                    return Dismissible(
                      key: ValueKey(conv.id),
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        color: Theme.of(context).colorScheme.errorContainer,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                      confirmDismiss: (_) async {
                        final connector = context.read<MeshCoreConnector>();
                        if (!connector.isConnected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context
                                    .l10n
                                    .channels_deleteChannelRequiresConnection,
                              ),
                            ),
                          );
                          return false;
                        }
                        return showDeleteChannelDialog(context, conv.name);
                      },
                      onDismissed: (_) {
                        final name = conv.name;
                        context.read<MeshCoreConnector>().deleteChannel(
                          conv.channel!.index,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n.channels_channelDeleted(name),
                            ),
                          ),
                        );
                      },
                      child: tile,
                    );
                  },
                ),
        ),
      ],
    );

    return _wrap(context, body);
  }

  Widget _wrap(BuildContext context, Widget body) {
    if (widget.hideScaffold) return body;
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(top: false, child: body),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(context.l10n.nav_chats),
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: const [ChatsOverflowMenuButton()],
    );
  }

  bool _matchesFilter(Conversation c) {
    switch (_filter) {
      case ChatFilter.all:
        return true;
      case ChatFilter.unread:
        return c.unreadCount > 0;
      case ChatFilter.dms:
        return c.type == ConvType.contact &&
            c.contact != null &&
            c.contact!.type == advTypeChat;
      case ChatFilter.channels:
        return c.type == ConvType.channel;
      case ChatFilter.rooms:
        return c.type == ConvType.contact &&
            c.contact != null &&
            c.contact!.type == advTypeRoom;
    }
  }

  List<Conversation> _buildConversations(
    MeshCoreConnector connector,
    ChatSortMode sortMode,
  ) {
    final conversations = <Conversation>[];

    for (final contact in connector.visibleContacts) {
      if (contact.type != advTypeChat && contact.type != advTypeRoom) continue;
      final messages = connector.getMessages(contact);
      final preview = messages.isNotEmpty
          ? _truncatePreview(messages.last.text)
          : null;
      conversations.add(
        Conversation(
          id: 'contact_${contact.publicKeyHex}',
          type: ConvType.contact,
          name: contact.displayName,
          subtitle: contact.shortPubKeyHex,
          lastMessage: preview,
          lastActivity: messages.isNotEmpty
              ? messages.last.timestamp
              : contact.lastSeen,
          unreadCount: connector.getUnreadCountForContact(contact),
          contact: contact,
        ),
      );
    }

    for (final channel in connector.channels) {
      if (channel.isWeatherChannel) continue;
      final messages = connector.getChannelMessages(channel);
      final preview = messages.isNotEmpty
          ? _truncatePreview(messages.last.text)
          : null;
      final name = channel.name.isEmpty
          ? context.l10n.channels_channelIndex(channel.index)
          : channel.name;
      conversations.add(
        Conversation(
          id: 'channel_${channel.index}',
          type: ConvType.channel,
          name: name,
          subtitle: channel.isPublicChannel
              ? context.l10n.channels_public
              : context.l10n.channels_private,
          lastMessage: preview,
          // Channels with no messages sort to the bottom via an epoch sentinel
          // rather than DateTime.now() (which would float them to the top).
          lastActivity: messages.isNotEmpty
              ? messages.last.timestamp
              : DateTime.fromMillisecondsSinceEpoch(0),
          unreadCount: connector.getUnreadCountForChannel(channel),
          channel: channel,
        ),
      );
    }

    int Function(Conversation, Conversation) tieBreak;
    if (sortMode == ChatSortMode.alphabetical) {
      tieBreak = (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());
    } else {
      tieBreak = (a, b) {
        // Channels sort alphabetically among themselves; DMs (and any
        // DM/channel pairing) keep the existing most-recent-first order.
        if (a.type == ConvType.channel && b.type == ConvType.channel) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
        return b.lastActivity.compareTo(a.lastActivity);
      };
    }
    conversations.sort((a, b) {
      if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
      return tieBreak(a, b);
    });
    return conversations;
  }

  String _truncatePreview(String text) {
    final characters = text.characters;
    if (characters.length <= 50) return text;
    return '${characters.take(50)}...';
  }

  void _handleTap(BuildContext context, Conversation conv) {
    if (conv.type == ConvType.contact &&
        conv.contact != null &&
        conv.contact!.type == advTypeRoom) {
      _showRoomLogin(context, conv);
      return;
    }
    if (widget.onSelected != null) {
      widget.onSelected!(conv);
      return;
    }
    _openConversation(context, conv);
  }

  void _openConversation(BuildContext context, Conversation conv) {
    if (conv.type == ConvType.contact && conv.contact != null) {
      context.read<MeshCoreConnector>().markContactRead(
        conv.contact!.publicKeyHex,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(contact: conv.contact!),
        ),
      );
    } else if (conv.type == ConvType.channel && conv.channel != null) {
      context.read<MeshCoreConnector>().markChannelRead(conv.channel!.index);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChannelChatScreen(channel: conv.channel!),
        ),
      );
    }
  }

  void _showRoomLogin(BuildContext context, Conversation conv) {
    final room = conv.contact!;
    showDialog(
      context: context,
      builder: (context) => RoomLoginDialog(
        room: room,
        onLogin: (password) {
          context.read<MeshCoreConnector>().markContactRead(room.publicKeyHex);
          if (widget.onSelected != null) {
            widget.onSelected!(conv);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen(contact: room)),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;
  final bool selected;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    this.onToggleFavorite,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = conversation.unreadCount > 0;
    final isFavorite = conversation.isFavorite;
    final isChannel = conversation.type == ConvType.channel;
    final isPublic = conversation.channel?.isPublicChannel == true;

    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      child: ListTile(
        leading: isChannel
            ? CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  isPublic ? Icons.public : Icons.lock_outline,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : ContactAvatar(name: conversation.name, size: 44),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: onToggleFavorite,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  size: 14,
                  color: isFavorite
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.outline,
                ),
              ),
            ),
            Flexible(
              child: RelativeTimestampText(
                conversation.lastActivity,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            if (isChannel)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.tag,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            Expanded(
              child: Text(
                conversation.lastMessage ?? conversation.subtitle ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (hasUnread)
              UnreadBadge(
                count: conversation.unreadCount,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
