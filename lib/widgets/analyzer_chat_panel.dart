import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../models/channel.dart';
import '../models/contact.dart';
import '../services/mesh_analyzer_state.dart';

class AnalyzerChatPanel extends StatelessWidget {
  const AnalyzerChatPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MeshCoreConnector, MeshAnalyzerState>(
      builder: (context, connector, analyzerState, child) {
        final selectedChatId = analyzerState.selectedChatId;

        return AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey(selectedChatId),
            child: selectedChatId != null
                ? _ChatDetailView(
                    chatId: selectedChatId,
                    onBack: () => analyzerState.selectChat(null),
                  )
                : _ConversationListView(
                    onSelect: (id) => analyzerState.selectChat(id),
                  ),
          ),
        );
      },
    );
  }
}

class _ConversationListView extends StatelessWidget {
  final void Function(String id) onSelect;

  const _ConversationListView({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final connector = context.watch<MeshCoreConnector>();
    final l10n = context.l10n;
    final conversations = _buildConversations(connector);

    final dms = conversations.where((c) => !c.isChannel).toList();
    final channels = conversations.where((c) => c.isChannel).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.forum,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.analyzer_chats,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: conversations.isEmpty
              ? Center(
                  child: Text(
                    l10n.analyzer_noChats,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                )
              : ListView(
                  children: [
                    if (dms.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Direct Messages',
                        count: dms.length,
                      ),
                      ...dms.map(
                        (conv) => _ConversationTile(
                          conv: conv,
                          onTap: () => onSelect(conv.id),
                        ),
                      ),
                    ],
                    if (channels.isNotEmpty) ...[
                      _SectionHeader(title: 'Channels', count: channels.length),
                      ...channels.map(
                        (conv) => _ConversationTile(
                          conv: conv,
                          onTap: () => onSelect(conv.id),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  List<_AnalyzerConversation> _buildConversations(MeshCoreConnector connector) {
    final conversations = <_AnalyzerConversation>[];

    for (final contact in connector.contacts) {
      final messages = connector.getMessages(contact);
      if (messages.isEmpty) continue;
      conversations.add(
        _AnalyzerConversation(
          id: 'contact_${contact.publicKeyHex}',
          name: contact.name,
          isChannel: false,
          lastMessage: messages.last.text,
          lastActivity: messages.last.timestamp,
          unreadCount: connector.getUnreadCountForContact(contact),
          contact: contact,
        ),
      );
    }

    for (final channel in connector.channels) {
      final messages = connector.getChannelMessages(channel);
      final name = channel.name.isEmpty
          ? 'Channel ${channel.index}'
          : channel.name;
      conversations.add(
        _AnalyzerConversation(
          id: 'channel_${channel.index}',
          name: name,
          isChannel: true,
          lastMessage: messages.isNotEmpty ? messages.last.text : null,
          lastActivity: messages.isNotEmpty
              ? messages.last.timestamp
              : DateTime.now(),
          unreadCount: connector.getUnreadCountForChannel(channel),
          channel: channel,
        ),
      );
    }

    conversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    return conversations;
  }
}

class _AnalyzerConversation {
  final String id;
  final String name;
  final bool isChannel;
  final String? lastMessage;
  final DateTime lastActivity;
  final int unreadCount;
  final Contact? contact;
  final Channel? channel;

  const _AnalyzerConversation({
    required this.id,
    required this.name,
    required this.isChannel,
    this.lastMessage,
    required this.lastActivity,
    this.unreadCount = 0,
    this.contact,
    this.channel,
  });
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final _AnalyzerConversation conv;
  final VoidCallback onTap;

  const _ConversationTile({required this.conv, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeStr = _formatTime(conv.lastActivity);
    final lastMessage = conv.lastMessage;
    final preview = lastMessage == null
        ? ''
        : lastMessage.characters.length > 40
        ? '${lastMessage.characters.take(40)}...'
        : lastMessage;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: conv.isChannel
                      ? colorScheme.tertiary.withValues(alpha: 0.15)
                      : colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  conv.isChannel ? Icons.forum : Icons.person,
                  size: 18,
                  color: conv.isChannel
                      ? colorScheme.tertiary
                      : colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conv.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    if (preview.isNotEmpty)
                      Text(
                        preview,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (conv.unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${conv.unreadCount}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.month}/${time.day}';
  }
}

class _ChatDetailView extends StatelessWidget {
  final String chatId;
  final VoidCallback onBack;

  const _ChatDetailView({required this.chatId, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final connector = context.watch<MeshCoreConnector>();
    final l10n = context.l10n;

    if (chatId.startsWith('contact_')) {
      final pubKeyHex = chatId.substring('contact_'.length);
      final contact = connector.contacts.cast<Contact?>().firstWhere(
        (c) => c != null && c.publicKeyHex == pubKeyHex,
        orElse: () => null,
      );
      if (contact == null) {
        return _buildEmpty(context, l10n);
      }
      final messages = connector.getMessages(contact);
      return _buildChatView(
        context,
        title: contact.name,
        messages: messages
            .map(
              (m) => _ChatMessage(
                text: m.text,
                timestamp: m.timestamp,
                isOutgoing: m.isOutgoing,
                senderName: m.isOutgoing
                    ? (connector.selfName ?? 'You')
                    : contact.name,
              ),
            )
            .toList(),
      );
    } else if (chatId.startsWith('channel_')) {
      final indexStr = chatId.substring('channel_'.length);
      final index = int.tryParse(indexStr);
      if (index == null) return _buildEmpty(context, l10n);
      final channel = connector.channels.cast<Channel?>().firstWhere(
        (c) => c != null && c.index == index,
        orElse: () => null,
      );
      if (channel == null) return _buildEmpty(context, l10n);
      final name = channel.name.isEmpty
          ? 'Channel ${channel.index}'
          : channel.name;
      final messages = connector.getChannelMessages(channel);
      return _buildChatView(
        context,
        title: name,
        messages: messages
            .map(
              (m) => _ChatMessage(
                text: m.text,
                timestamp: m.timestamp,
                isOutgoing: m.isOutgoing,
                senderName: m.isOutgoing
                    ? (connector.selfName ?? 'You')
                    : m.senderName,
              ),
            )
            .toList(),
      );
    }

    return _buildEmpty(context, l10n);
  }

  Widget _buildEmpty(BuildContext context, dynamic l10n) {
    return Column(
      children: [
        _buildHeader(context, l10n.analyzer_back, 'Chat'),
        Expanded(
          child: Center(child: Text(context.l10n.analyzer_chatNotFound)),
        ),
      ],
    );
  }

  Widget _buildChatView(
    BuildContext context, {
    required String title,
    required List<_ChatMessage> messages,
  }) {
    return Column(
      children: [
        _buildHeader(context, title, ''),
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    'No messages',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                )
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    return _MessageBubble(message: msg);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: onBack,
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final DateTime timestamp;
  final bool isOutgoing;
  final String senderName;

  const _ChatMessage({
    required this.text,
    required this.timestamp,
    required this.isOutgoing,
    required this.senderName,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isOutgoing = message.isOutgoing;
    final bubbleColor = isOutgoing
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.35,
        ),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isOutgoing ? 12 : 4),
            bottomRight: Radius.circular(isOutgoing ? 4 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOutgoing)
              Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            Text(
              message.text,
              style: TextStyle(fontSize: 12, color: textColor),
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 9,
                  color: textColor.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}
