import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/chat_scroll_controller.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/link_handler.dart';
import '../helpers/reaction_helper.dart';
import '../helpers/rich_message_parser.dart';
import '../helpers/unread_scroll_helper.dart';
import '../helpers/utf8_length_limiter.dart';
import '../l10n/l10n.dart';
import '../models/channel.dart';
import '../helpers/channel_message_preview.dart';
import '../helpers/location_share_helper.dart';
import '../models/channel_message.dart';
import '../services/app_settings_service.dart';
import '../theme/app_colors.dart';
import '../utils/emoji_utils.dart';
import '../widgets/emoji_picker.dart';
import '../widgets/gif_message.dart';
import '../widgets/jump_to_bottom_button.dart';
import '../widgets/gif_picker.dart';
import '../widgets/message_status_icon.dart';
import '../widgets/notification_target_marker.dart';
import '../helpers/retired_media_message.dart';
import '../widgets/rich_message_widget.dart';
import 'channel_message_path_screen.dart';
import 'location_pick_screen.dart';
import 'map_screen.dart';
import '../helpers/channel_region_scope_prompt.dart';
import '../widgets/channel_chat_overflow_menu_button.dart';
import '../models/mesh_region.dart';

class ChannelChatScreen extends StatefulWidget {
  final Channel channel;
  final bool embedded;

  const ChannelChatScreen({
    super.key,
    required this.channel,
    this.embedded = false,
  });

  @override
  State<ChannelChatScreen> createState() => _ChannelChatScreenState();
}

class _ChannelChatScreenState extends State<ChannelChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ChatScrollController _scrollController = ChatScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();
  ChannelMessage? _replyingToMessage;
  final Map<String, GlobalKey> _messageKeys = {};
  bool _isLoadingOlder = false;

  MeshCoreConnector? _connector;

  // Jump-to-first-unread-on-open. Tracked by message ID rather than index
  // since _messageKeys is already keyed that way for the reply-jump feature.
  int? _firstUnreadIndex;
  String? _firstUnreadMessageId;
  int? _unreadDividerCount;
  bool _suppressAutoScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.addListener(_onTextFieldFocusChange);
    _scrollController.onScrollNearTop = _loadOlderMessages;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _connector = context.read<MeshCoreConnector>();
      // Read the unread count before setActiveChannel marks it read below.
      final unreadCount = widget.channel.unreadCount;
      final newestFirst = _connector!
          .getChannelMessages(widget.channel)
          .where((m) => !ChannelMessagePreview.isTacticalPosition(m.text))
          .toList()
          .reversed
          .toList();
      _firstUnreadIndex = findFirstUnreadIndex(
        newestFirst,
        unreadCount,
        (m) => !m.isOutgoing && ChannelMessagePreview.shouldNotify(m.text),
      );
      if (_firstUnreadIndex != null) {
        _firstUnreadMessageId = newestFirst[_firstUnreadIndex!].messageId;
        _unreadDividerCount = unreadCount;
        _suppressAutoScrollToBottom = true;
        _jumpToFirstUnread();
      }
      _connector?.setActiveChannel(widget.channel.index);
    });
  }

  void _jumpToFirstUnread() {
    if (!_scrollController.hasClients) return;
    const estimatedItemExtent = 76.0;
    final target = (_firstUnreadIndex! * estimatedItemExtent).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.jumpTo(target);
    // The jump above is an estimate (messages have variable heights); once
    // the next frame has laid out items near it, snap precisely using the
    // key for the actual target message, if it made it into that range.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetContext = _messageKeys[_firstUnreadMessageId]?.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0.2,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
      _suppressAutoScrollToBottom = false;
    });
  }

  Widget _buildUnreadDivider(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: colorScheme.primary)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              context.l10n.chat_unread(count),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Divider(color: colorScheme.primary)),
        ],
      ),
    );
  }

  void _onTextFieldFocusChange() {
    if (_textFieldFocusNode.hasFocus && mounted) {
      _scrollController.handleKeyboardOpen();
    }
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingOlder) return;
    setState(() => _isLoadingOlder = true);

    final connector = context.read<MeshCoreConnector>();
    try {
      await connector.loadOlderChannelMessages(widget.channel.index);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.chat_historyLoadFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingOlder = false);
    }
  }

  @override
  void dispose() {
    _connector?.setActiveChannel(null);
    _textFieldFocusNode.removeListener(_onTextFieldFocusChange);
    _textFieldFocusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setReplyingTo(ChannelMessage message) {
    setState(() {
      _replyingToMessage = message;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToMessage = null;
    });
  }

  Future<void> _scrollToMessage(String messageId) async {
    final key = _messageKeys[messageId];
    if (key == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.chat_originalMessageNotFound),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final targetContext = key.currentContext;
    if (targetContext == null) return;

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.3,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationTargetMarker(
      target: NotificationTarget.channel(widget.channel.index),
      child: _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: Row(
          children: [
            Icon(
              widget.channel.isPublicChannel ? Icons.public : Icons.tag,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.channel.name.isEmpty
                        ? context.l10n.channels_channelIndex(
                            widget.channel.index,
                          )
                        : widget.channel.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Consumer<MeshCoreConnector>(
                    builder: (context, connector, _) {
                      final unreadCount = connector
                          .getUnreadCountForChannelIndex(widget.channel.index);
                      final privacy = widget.channel.isPublicChannel
                          ? context.l10n.channels_public
                          : context.l10n.channels_private;
                      final scope = connector.getChannelRegionScope(
                        widget.channel.index,
                      );
                      final scopeLabel = scope == null || scope.isEmpty
                          ? context.l10n.channels_scopeUnscoped
                          : MeshRegion.displayLabel(scope);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => promptChannelRegionScope(
                          context,
                          channelIndex: widget.channel.index,
                          showPromptSubtitle: false,
                        ),
                        child: Text(
                          '$privacy · $scopeLabel · ${context.l10n.chat_unread(unreadCount)}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [ChannelChatOverflowMenuButton(channel: widget.channel)],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Consumer<MeshCoreConnector>(
                builder: (context, connector, child) {
                  final messages = connector.getChannelMessages(widget.channel);

                  if (messages.isEmpty) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.channel.isPublicChannel
                                ? Icons.public
                                : Icons.tag,
                            size: 64,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.chat_noMessages,
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.chat_sendMessageToStart,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Reverse messages so newest appear at bottom with reverse: true
                  final visibleMessages = messages
                      .where(
                        (m) =>
                            !ChannelMessagePreview.isTacticalPosition(m.text),
                      )
                      .toList();
                  final reversedMessages = visibleMessages.reversed.toList();
                  final itemCount =
                      reversedMessages.length + (_isLoadingOlder ? 1 : 0);

                  // Assign stable keys once per build rather than mutating the
                  // map inside itemBuilder (a side effect during item layout).
                  for (final m in reversedMessages) {
                    _messageKeys.putIfAbsent(m.messageId, () => GlobalKey());
                  }

                  // Auto-scroll to bottom if user is already at bottom.
                  // Suppressed while the initial jump-to-first-unread is
                  // still in progress, since it would otherwise stomp on
                  // that jump (the button starts in its "at bottom" state
                  // until the first real scroll event corrects it).
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_suppressAutoScrollToBottom) {
                      _scrollController.scrollToBottomIfAtBottom();
                    }
                  });

                  return Stack(
                    children: [
                      ListView.builder(
                        reverse: true, // List grows from bottom up
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          // Loading indicator now appears at end (bottom) of reversed list
                          if (_isLoadingOlder && index == itemCount - 1) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          final messageIndex = index;
                          final message = reversedMessages[messageIndex];
                          final dismissible = Dismissible(
                            key: ValueKey(message.messageId),
                            direction: DismissDirection.startToEnd,
                            background: Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: Icon(
                                Icons.delete_outline,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                            onDismissed: (_) => _deleteMessage(message),
                            child: _buildMessageBubble(message),
                          );
                          return Container(
                            key: _messageKeys[message.messageId]!,
                            child: messageIndex == _firstUnreadIndex
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildUnreadDivider(
                                        context,
                                        _unreadDividerCount!,
                                      ),
                                      dismissible,
                                    ],
                                  )
                                : dismissible,
                          );
                        },
                      ),
                      JumpToBottomButton(scrollController: _scrollController),
                    ],
                  );
                },
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChannelMessage message) {
    final settingsService = context.watch<AppSettingsService>();
    final enableTracing = settingsService.settings.enableMessageTracing;
    final isOutgoing = message.isOutgoing;
    final colorScheme = Theme.of(context).colorScheme;
    final gifId = ChannelMessagePreview.parseGifId(message.text);
    final poi = ChannelMessagePreview.parsePoi(message.text);
    if (isRetiredMediaMessage(message.text)) {
      return const SizedBox.shrink();
    }
    final displayPath = message.pathBytes.isNotEmpty
        ? message.pathBytes
        : (message.pathVariants.isNotEmpty
              ? message.pathVariants.first
              : Uint8List(0));

    const maxSwipeOffset = 64.0;
    const replySwipeThreshold = 64.0;
    final messageBody = Column(
      crossAxisAlignment: isOutgoing
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isOutgoing
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOutgoing) ...[
              _buildAvatar(message.senderName),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: GestureDetector(
                onTap: () => _showMessagePathInfo(message),
                onLongPress: () => _showMessageActions(message),
                child: Container(
                  padding: gifId != null
                      ? const EdgeInsets.all(4)
                      : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  decoration: BoxDecoration(
                    color: isOutgoing
                        ? context.appColors.outgoingBubble
                        : context.appColors.incomingBubble,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isOutgoing) ...[
                        Padding(
                          padding: gifId != null
                              ? const EdgeInsets.only(
                                  left: 8,
                                  top: 4,
                                  bottom: 4,
                                )
                              : EdgeInsets.zero,
                          child: Text(
                            message.senderName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        if (gifId == null) const SizedBox(height: 4),
                      ],
                      if (message.replyToMessageId != null) ...[
                        _buildReplyPreview(message),
                        const SizedBox(height: 8),
                      ],
                      if (poi != null)
                        _buildPoiMessage(
                          context,
                          poi,
                          isOutgoing,
                          trailing: (!enableTracing && isOutgoing)
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: MessageStatusIcon(
                                    isAcked:
                                        message.status ==
                                            ChannelMessageStatus.sent &&
                                        displayPath.isNotEmpty,
                                    isFailed:
                                        message.status ==
                                        ChannelMessageStatus.failed,
                                  ),
                                )
                              : null,
                        )
                      else if (gifId != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: GifMessage(
                                url:
                                    'https://media.giphy.com/media/$gifId/giphy.gif',
                                backgroundColor: Colors.transparent,
                                // intentionally fixed on outgoing: contrasts
                                // against the fixed-tint outgoingBubble fill
                                fallbackTextColor: isOutgoing
                                    ? Colors.white70
                                    : colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                              ),
                            ),
                            if (!enableTracing && isOutgoing)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: isOutgoing
                                        ? context.appColors.outgoingBubble
                                        : context.appColors.incomingBubble,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: MessageStatusIcon(
                                    isAcked:
                                        message.status ==
                                            ChannelMessageStatus.sent &&
                                        displayPath.isNotEmpty,
                                    isFailed:
                                        message.status ==
                                        ChannelMessageStatus.failed,
                                  ),
                                ),
                              ),
                          ],
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: RichMessageWidget(
                                message: RichMessageParser.parse(message.text),
                                style: TextStyle(
                                  fontSize: 14,
                                  // intentionally fixed on outgoing:
                                  // contrasts against the fixed-tint
                                  // outgoingBubble fill
                                  color: isOutgoing ? Colors.white : null,
                                ),
                                accentColor: isOutgoing
                                    ? Colors.white70
                                    : colorScheme.tertiary,
                                onUrlTap: (uri) => LinkHandler.handleLinkTap(
                                  context,
                                  uri.toString(),
                                ),
                              ),
                            ),
                            if (!enableTracing && isOutgoing) ...[
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: MessageStatusIcon(
                                  isAcked:
                                      message.status ==
                                          ChannelMessageStatus.sent &&
                                      displayPath.isNotEmpty,
                                  isFailed:
                                      message.status ==
                                      ChannelMessageStatus.failed,
                                ),
                              ),
                            ],
                          ],
                        ),
                      if (message.edited) ...[
                        const SizedBox(height: 2),
                        Padding(
                          padding: gifId != null
                              ? const EdgeInsets.only(left: 8, right: 8)
                              : EdgeInsets.zero,
                          child: Text(
                            context.l10n.chat_editedLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                      if (enableTracing) ...[
                        if (displayPath.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: gifId != null
                                ? const EdgeInsets.symmetric(horizontal: 8)
                                : EdgeInsets.zero,
                            child: Text(
                              'via ${_formatPathPrefixes(displayPath)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Padding(
                          padding: gifId != null
                              ? const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 4,
                                )
                              : EdgeInsets.zero,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(message.timestamp),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (message.repeatCount > 0) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.repeat,
                                  size: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${message.repeatCount}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              if (isOutgoing) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  message.status == ChannelMessageStatus.sent
                                      ? Icons.check
                                      : message.status ==
                                            ChannelMessageStatus.pending
                                      ? Icons.schedule
                                      : Icons.error_outline,
                                  size: 14,
                                  color:
                                      message.status ==
                                          ChannelMessageStatus.failed
                                      ? colorScheme.error
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (message.reactions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: isOutgoing ? 0 : 48),
            child: _buildReactionsDisplay(message),
          ),
        ],
      ],
    );

    if (!isOutgoing) {
      return _SwipeReplyBubble(
        maxSwipeOffset: maxSwipeOffset,
        replySwipeThreshold: replySwipeThreshold,
        onReplyTriggered: () => _setReplyingTo(message),
        hintBuilder: ({required isStart}) =>
            _buildReplySwipeHint(isStart: isStart),
        child: messageBody,
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: messageBody,
      );
    }
  }

  Widget _buildReplySwipeHint({required bool isStart}) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.reply, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          context.l10n.chat_reply,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Container(
      alignment: isStart ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: colorScheme.primary.withValues(alpha: 0.08),
      child: isStart
          ? content
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.chat_reply,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.reply, color: colorScheme.primary),
              ],
            ),
    );
  }

  Widget _buildReplyPreview(ChannelMessage message) {
    final connector = context.read<MeshCoreConnector>();
    final isOwnNode = message.replyToSenderName == connector.selfName;
    final replyText = message.replyToText ?? '';
    final colorScheme = Theme.of(context).colorScheme;
    final previewTextColor = colorScheme.onSurface.withValues(alpha: 0.7);

    final gifId = ChannelMessagePreview.parseGifId(replyText);
    final poi = ChannelMessagePreview.parsePoi(replyText);

    Widget contentPreview;
    if (gifId != null) {
      contentPreview = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: GifMessage(
          url: 'https://media.giphy.com/media/$gifId/giphy.gif',
          backgroundColor: colorScheme.surfaceContainerHighest,
          fallbackTextColor: previewTextColor,
          maxSize: 80,
        ),
      );
    } else if (poi != null) {
      contentPreview = Row(
        children: [
          Icon(Icons.location_on_outlined, size: 14, color: previewTextColor),
          const SizedBox(width: 4),
          Text(
            context.l10n.chat_location,
            style: TextStyle(fontSize: 12, color: previewTextColor),
          ),
        ],
      );
    } else {
      contentPreview = Text(
        replyText,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: previewTextColor,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _scrollToMessage(message.replyToMessageId!),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: colorScheme.primary, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.chat_replyTo(message.replyToSenderName ?? ''),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isOwnNode
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            contentPreview,
          ],
        ),
      ),
    );
  }

  Widget _buildReactionsDisplay(ChannelMessage message) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: message.reactions.entries.map((entry) {
        final emoji = entry.key;
        final count = entry.value;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              if (count > 1) ...[
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  void _openMapForPoi(PoiPreview poi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          highlightPosition: LatLng(poi.lat, poi.lon),
          highlightLabel: poi.label,
        ),
      ),
    );
  }

  String _formatMessagePreviewText(String text) {
    final gifId = ChannelMessagePreview.parseGifId(text);
    if (gifId != null) {
      return context.l10n.chat_sendGif;
    }

    final poi = ChannelMessagePreview.parsePoi(text);
    if (poi != null) {
      if (poi.label.isNotEmpty) {
        return '${context.l10n.chat_poiShared}: ${poi.label}';
      }
      if (poi.tacticalType != null && poi.tacticalType!.isNotEmpty) {
        return '${context.l10n.chat_poiShared}: ${poi.tacticalType}';
      }
      return context.l10n.chat_poiShared;
    }

    if (ChannelMessagePreview.isTacticalPosition(text)) {
      return context.l10n.chat_location;
    }

    return text;
  }

  Widget _buildPoiMessage(
    BuildContext context,
    PoiPreview poi,
    bool isOutgoing, {
    Widget? trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    // intentionally fixed on outgoing: contrasts against the fixed-tint
    // outgoingBubble fill
    final textColor = isOutgoing ? Colors.white : colorScheme.onSurface;
    final metaColor = textColor.withValues(alpha: 0.7);
    final channelColor = widget.channel.isPublicChannel
        ? colorScheme.tertiary
        : colorScheme.primary;
    final subtitle = poi.label.isNotEmpty
        ? poi.label
        : (poi.tacticalType ?? '');

    return InkWell(
      onTap: () => _openMapForPoi(poi),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, color: channelColor, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poi.tacticalType == 'wp'
                      ? context.l10n.chat_waypointShared
                      : context.l10n.chat_poiShared,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(color: metaColor, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing],
        ],
      ),
    );
  }

  void _showGifPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GifPicker(
        onGifSelected: (gifId) {
          _textController.text = 'g:$gifId';
        },
      ),
    );
  }

  Future<void> _showLocationPicker(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickScreen()),
    );
    if (result != null && mounted) {
      _textController.text = result;
    }
  }

  Widget _buildPoiComposerPreview(
    BuildContext context,
    PoiPreview poi,
    ColorScheme colorScheme,
  ) {
    final title = poi.tacticalType == 'wp'
        ? context.l10n.chat_waypointShared
        : context.l10n.chat_poiShared;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.trip_origin, color: colorScheme.primary, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (poi.label.isNotEmpty)
                        Text(
                          poi.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _textController.clear(),
        ),
      ],
    );
  }

  Widget _buildAvatar(String senderName) {
    final initial = _getFirstCharacterOrEmoji(senderName);
    final color = _getColorForName(senderName);

    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withValues(alpha: 0.2),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _getFirstCharacterOrEmoji(String name) {
    if (name.isEmpty) return '?';

    final emoji = firstEmoji(name);
    if (emoji != null) return emoji;

    final runes = name.runes.toList();
    if (runes.isEmpty) return '?';
    return String.fromCharCode(runes[0]).toUpperCase();
  }

  Color _getColorForName(String name) {
    // Delegate to the shared, theme-defined name->color palette.
    return AppColors.colorForName(name);
  }

  Widget _buildReplyBanner() {
    final message = _replyingToMessage!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 18,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.chat_replyingTo(message.senderName),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                Text(
                  _formatMessagePreviewText(message.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: _cancelReply,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    final connector = context.watch<MeshCoreConnector>();
    final maxBytes = maxChannelMessageBytes(connector.selfName);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_replyingToMessage != null) _buildReplyBanner(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.gif_box),
                onPressed: GifPicker.isConfigured
                    ? () => _showGifPicker(context)
                    : null,
                tooltip: context.l10n.chat_sendGif,
              ),
              IconButton(
                icon: const Icon(Icons.add_location_alt),
                onPressed: () => _showLocationPicker(context),
                tooltip: context.l10n.chat_sendWaypoint,
              ),
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _textController,
                  builder: (context, value, child) {
                    final gifId = ChannelMessagePreview.parseGifId(value.text);
                    if (gifId != null) {
                      return Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: GifMessage(
                                url:
                                    'https://media.giphy.com/media/$gifId/giphy.gif',
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                fallbackTextColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                maxSize: 160,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _textController.clear(),
                          ),
                        ],
                      );
                    }

                    final poi = ChannelMessagePreview.parsePoi(value.text);
                    if (poi != null) {
                      return _buildPoiComposerPreview(
                        context,
                        poi,
                        Theme.of(context).colorScheme,
                      );
                    }

                    return TextField(
                      controller: _textController,
                      focusNode: _textFieldFocusNode,
                      inputFormatters: [
                        Utf8LengthLimitingTextInputFormatter(maxBytes),
                      ],
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: context.l10n.chat_typeMessage,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final connector = context.read<MeshCoreConnector>();

    String messageText = text;
    if (_replyingToMessage != null) {
      messageText = '@[${_replyingToMessage!.senderName}] $text';
    }

    final maxBytes = maxChannelMessageBytes(connector.selfName);
    if (utf8.encode(messageText).length > maxBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chat_messageTooLong(maxBytes))),
      );
      return;
    }

    if (widget.channel.isPublicChannel &&
        ChannelMessagePreview.parsePoi(text) != null) {
      final channelLabel = widget.channel.name.isEmpty
          ? 'Channel ${widget.channel.index}'
          : widget.channel.name;
      final canSend = await confirmPublicLocationShare(context, channelLabel);
      if (!canSend || !mounted) return;
    }

    if (!connector.isConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.common_disconnected)));
      return;
    }

    try {
      await connector.sendChannelMessage(widget.channel, messageText);
      _textController.clear();
      _cancelReply();
    } catch (error) {
      if (!mounted) return;
      // The connector retains the enqueued message as a failed bubble, so the
      // composer can clear without silently losing the user's text.
      _textController.clear();
      _cancelReply();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chat_sendFailed(error.toString()))),
      );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showMessagePathInfo(ChannelMessage message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChannelMessagePathScreen(message: message, channelMessage: true),
      ),
    );
  }

  void _showMessageActions(ChannelMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: Text(context.l10n.chat_reply),
              onTap: () {
                Navigator.pop(sheetContext);
                _setReplyingTo(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_reaction_outlined),
              title: Text(context.l10n.chat_addReaction),
              onTap: () {
                Navigator.pop(sheetContext);
                _showEmojiPicker(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(context.l10n.common_copy),
              onTap: () {
                Navigator.pop(sheetContext);
                _copyMessageText(message.text);
              },
            ),
            if (message.isOutgoing)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(context.l10n.chat_editMessage),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _editMessage(message);
                },
              ),
            ListTile(
              leading: const Icon(Icons.route_outlined),
              title: Text(context.l10n.channelPath_title),
              onTap: () {
                Navigator.pop(sheetContext);
                _showMessagePathInfo(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(context.l10n.common_delete),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _deleteMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(context.l10n.common_cancel),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(ChannelMessage message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EmojiPicker(
        onEmojiSelected: (emoji) {
          _sendReaction(message, emoji);
        },
      ),
    );
  }

  Future<void> _sendReaction(ChannelMessage message, String emoji) async {
    final connector = context.read<MeshCoreConnector>();
    final emojiIndex = ReactionHelper.emojiToIndex(emoji);
    if (emojiIndex == null) return; // Unknown emoji, skip
    final timestampSecs = message.timestamp.millisecondsSinceEpoch ~/ 1000;
    final hash = ReactionHelper.computeReactionHash(
      timestampSecs,
      message.senderName,
      message.text,
    );
    final reactionText = 'r:$hash:$emojiIndex';
    try {
      await connector.sendChannelMessage(widget.channel, reactionText);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chat_sendFailed(error.toString()))),
      );
    }
  }

  void _copyMessageText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.chat_messageCopied)));
  }

  Future<void> _deleteMessage(ChannelMessage message) async {
    await context.read<MeshCoreConnector>().deleteChannelMessage(message);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.chat_messageDeleted)));
  }

  Future<void> _editMessage(ChannelMessage message) async {
    final controller = TextEditingController(text: message.text);
    final newText = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.chat_editMessage),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(context.l10n.common_save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newText == null || newText.isEmpty || newText == message.text) return;
    if (!mounted) return;

    final connector = context.read<MeshCoreConnector>();
    try {
      await connector.editChannelMessage(widget.channel, message, newText);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.chat_messageEdited)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chat_sendFailed(error.toString()))),
      );
    }
  }

  String _formatPathPrefixes(Uint8List pathBytes) {
    return pathBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(',');
  }
}

class _SwipeReplyBubble extends StatefulWidget {
  final double maxSwipeOffset;
  final double replySwipeThreshold;
  final VoidCallback onReplyTriggered;
  final Widget Function({required bool isStart}) hintBuilder;
  final Widget child;

  const _SwipeReplyBubble({
    required this.maxSwipeOffset,
    required this.replySwipeThreshold,
    required this.onReplyTriggered,
    required this.hintBuilder,
    required this.child,
  });

  @override
  State<_SwipeReplyBubble> createState() => _SwipeReplyBubbleState();
}

class _SwipeReplyBubbleState extends State<_SwipeReplyBubble> {
  Offset? _swipeStartPosition;
  double _swipeOffset = 0;
  double _maxSwipeDistance = 0;
  int? _swipePointerId;
  bool _swipeLockedToHorizontal = false;

  /// Pointer events keep arriving on the retained render object after the
  /// bubble leaves the tree mid-swipe, so `setState` would dereference a null
  /// element. Keep the value in sync without scheduling a build in that case.
  void _setSwipeOffset(double value) {
    if (_swipeOffset == value) return;
    if (!mounted) {
      _swipeOffset = value;
      return;
    }
    setState(() => _swipeOffset = value);
  }

  void _handleSwipeStart(Offset position) {
    _swipeStartPosition = position;
    _maxSwipeDistance = 0;
    _setSwipeOffset(0);
  }

  void _handleSwipePointerDown(PointerDownEvent event) {
    _swipePointerId = event.pointer;
    _swipeLockedToHorizontal = false;
    _handleSwipeStart(event.position);
  }

  void _handleSwipePointerMove(PointerMoveEvent event) {
    if (_swipePointerId != event.pointer || _swipeStartPosition == null) {
      return;
    }

    final dx = event.position.dx - _swipeStartPosition!.dx;

    const axisLockThreshold = 12.0;
    if (!_swipeLockedToHorizontal) {
      if (-dx < axisLockThreshold) {
        return;
      }
      _swipeLockedToHorizontal = true;
    }

    _handleSwipeUpdate(event.position);
  }

  void _handleSwipeUpdate(Offset position) {
    if (_swipeStartPosition == null) return;

    final dx = position.dx - _swipeStartPosition!.dx;
    if (dx >= 0) return;

    if (-dx < 6) return;

    if (-dx > _maxSwipeDistance) {
      _maxSwipeDistance = -dx;
    }

    final double clamped = dx.clamp(-widget.maxSwipeOffset, 0.0).toDouble();
    _setSwipeOffset(_applySwipeResistance(clamped, widget.maxSwipeOffset));
  }

  void _handleSwipePointerUp(Offset position) {
    if (_swipeLockedToHorizontal && _swipeStartPosition != null) {
      final dx = position.dx - _swipeStartPosition!.dx;
      final peak = math.max(
        _maxSwipeDistance,
        (-dx).clamp(0.0, double.infinity),
      );
      if (peak >= widget.replySwipeThreshold) {
        widget.onReplyTriggered();
        HapticFeedback.selectionClick();
      }
    }
    _resetSwipe();
  }

  void _resetSwipe() {
    _setSwipeOffset(0);
    _swipeStartPosition = null;
    _maxSwipeDistance = 0;
    _swipePointerId = null;
    _swipeLockedToHorizontal = false;
  }

  double _applySwipeResistance(double rawOffset, double maxOffset) {
    final abs = rawOffset.abs();
    if (abs <= 0) return 0;
    final norm = (abs / maxOffset).clamp(0.0, 1.0);
    const deadZone = 0.18;
    if (norm <= deadZone) {
      return rawOffset.sign * maxOffset * (norm * 0.08);
    }
    final t = ((norm - deadZone) / (1 - deadZone)).clamp(0.0, 1.0);
    final curved = t < 0.5
        ? 16 * math.pow(t, 5)
        : 1 - math.pow(-2 * t + 2, 5) / 2;
    const deadZoneEnd = 0.0144;
    return rawOffset.sign *
        maxOffset *
        (deadZoneEnd + curved * (1 - deadZoneEnd));
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handleSwipePointerDown,
      onPointerMove: _handleSwipePointerMove,
      onPointerUp: (event) => _handleSwipePointerUp(event.position),
      onPointerCancel: (_) => _resetSwipe(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: _swipeOffset.abs() / widget.maxSwipeOffset,
                child: widget.hintBuilder(isStart: false),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.translationValues(_swipeOffset, 0, 0),
              curve: Curves.easeOut,
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
