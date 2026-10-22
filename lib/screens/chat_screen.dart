import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gulf_coast_mesh_app/screens/path_trace_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

import '../services/app_settings_service.dart';
import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/channel_message_preview.dart';
import '../helpers/reaction_helper.dart';
import '../helpers/legacy_map_marker.dart';
import '../helpers/tactical_map_payload.dart';
import '../theme/app_colors.dart';
import '../widgets/message_status_icon.dart';
import '../helpers/rich_message_parser.dart';
import '../widgets/rich_message_widget.dart';
import '../helpers/chat_scroll_controller.dart';
import '../helpers/unread_scroll_helper.dart';
import '../helpers/link_handler.dart';
import '../helpers/utf8_length_limiter.dart';
import '../models/channel_message.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../models/path_history.dart';
import '../services/path_history_service.dart';
import '../helpers/retired_media_message.dart';
import '../widgets/elements_ui.dart';
import 'channel_message_path_screen.dart';
import 'location_pick_screen.dart';
import 'map_screen.dart';
import '../utils/emoji_utils.dart';
import 'notification_pref_screen.dart';
import '../widgets/connection_overflow_menu_button.dart';
import '../widgets/emoji_picker.dart';
import '../widgets/gif_message.dart';
import '../widgets/jump_to_bottom_button.dart';
import '../widgets/gif_picker.dart';
import '../widgets/notification_target_marker.dart';
import '../widgets/path_selection_dialog.dart';
import '../utils/app_logger.dart';
import '../l10n/l10n.dart';

class ChatScreen extends StatefulWidget {
  final Contact contact;
  final bool embedded;

  const ChatScreen({super.key, required this.contact, this.embedded = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ChatScrollController();
  final _textFieldFocusNode = FocusNode();
  bool _isLoadingOlder = false;
  MeshCoreConnector? _connector;

  // Jump-to-first-unread-on-open. Index is into the newest-first message
  // list built by _buildMessageList; the key is attached to that same item
  // so the estimated jump below can be corrected once it's actually laid out.
  int? _firstUnreadIndex;
  int? _unreadDividerCount;
  bool _suppressAutoScrollToBottom = false;
  final GlobalKey _firstUnreadKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.addListener(_onTextFieldFocusChange);
    _scrollController.onScrollNearTop = _loadOlderMessages;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _connector = context.read<MeshCoreConnector>();
      // Read the unread count before setActiveContact marks it read below.
      final unreadCount = _connector!.getUnreadCountForContactKey(
        widget.contact.publicKeyHex,
      );
      final newestFirst = _connector!
          .getMessages(widget.contact)
          .reversed
          .toList();
      _firstUnreadIndex = findFirstUnreadIndex(
        newestFirst,
        unreadCount,
        (m) => !m.isOutgoing && !m.isCli,
      );
      if (_firstUnreadIndex != null) {
        _unreadDividerCount = unreadCount;
        _suppressAutoScrollToBottom = true;
        _jumpToFirstUnread();
      }
      _connector?.setActiveContact(widget.contact.publicKeyHex);
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
    // key attached to the actual target item, if it made it into that range.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetContext = _firstUnreadKey.currentContext;
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
      await connector.loadOlderMessages(widget.contact.publicKeyHex);
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
    _connector?.setActiveContact(null);
    _textFieldFocusNode.removeListener(_onTextFieldFocusChange);
    _textFieldFocusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationTargetMarker(
      target: NotificationTarget.message(widget.contact.publicKeyHex),
      child: _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: Consumer2<PathHistoryService, MeshCoreConnector>(
          builder: (context, pathService, connector, _) {
            final contact = _resolveContact(connector);
            final unreadCount = connector.getUnreadCountForContactKey(
              widget.contact.publicKeyHex,
            );
            final unreadLabel = context.l10n.chat_unread(unreadCount);
            final pathLabel = _currentPathLabel(contact);

            // Show path details if we have path data (from device or override)
            final hasPathData =
                contact.path.isNotEmpty || contact.pathOverrideBytes != null;
            final effectivePath = contact.pathOverrideBytes ?? contact.path;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(contact.displayName),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: hasPathData
                      ? () => _showFullPathDialog(context, effectivePath)
                      : null,
                  child: Text(
                    '$pathLabel • $unreadLabel',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      decoration: hasPathData ? TextDecoration.underline : null,
                      decorationStyle: TextDecorationStyle.dotted,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: false,
        actions: [
          Consumer<MeshCoreConnector>(
            builder: (context, connector, _) {
              final contact = _resolveContact(connector);
              final isFloodMode = contact.pathOverride == -1;

              return PopupMenuButton<String>(
                icon: Icon(isFloodMode ? Icons.waves : Icons.route),
                tooltip: context.l10n.chat_routingMode,
                onSelected: (mode) async {
                  if (mode == 'flood') {
                    await connector.setPathOverride(contact, pathLen: -1);
                  } else {
                    await connector.setPathOverride(contact, pathLen: null);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'auto',
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_mode,
                          size: 20,
                          color: !isFloodMode
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.chat_autoUseSavedPath,
                          style: TextStyle(
                            fontWeight: !isFloodMode
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'flood',
                    child: Row(
                      children: [
                        Icon(
                          Icons.waves,
                          size: 20,
                          color: isFloodMode
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.chat_forceFloodMode,
                          style: TextStyle(
                            fontWeight: isFloodMode
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.timeline),
            tooltip: context.l10n.chat_pathManagement,
            onPressed: () => _showPathHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showContactInfo(context),
          ),
          ConnectionOverflowMenuButton(
            extraItemsBeforeSettings: [
              PopupMenuItem(
                value: 'notifications',
                child: Row(
                  children: [
                    const Icon(Icons.notifications_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(context.l10n.notificationPref_title),
                  ],
                ),
              ),
            ],
            onExtraSelected: (value) async {
              if (value != 'notifications') return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPrefScreen(
                    contactKeyHex: widget.contact.publicKeyHex,
                    itemName: widget.contact.displayName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MeshCoreConnector>(
        builder: (context, connector, child) {
          final messages = connector.getMessages(widget.contact);
          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    messages.isEmpty
                        ? _buildEmptyState()
                        : _buildMessageList(messages, connector),
                    JumpToBottomButton(scrollController: _scrollController),
                  ],
                ),
              ),
              _buildInputBar(connector),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            context.l10n.chat_noMessages,
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.chat_sendMessageTo(widget.contact.displayName),
            style: TextStyle(fontSize: 14, color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    List<Message> messages,
    MeshCoreConnector connector,
  ) {
    // Reverse messages so newest appear at bottom with reverse: true
    final reversedMessages = messages.reversed.toList();
    final itemCount = reversedMessages.length + (_isLoadingOlder ? 1 : 0);

    // Auto-scroll to bottom if user is already at bottom. Suppressed while
    // the initial jump-to-first-unread is still in progress, since it would
    // otherwise stomp on that jump (the button starts in its "at bottom"
    // state until the first real scroll event corrects it).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_suppressAutoScrollToBottom) {
        _scrollController.scrollToBottomIfAtBottom();
      }
    });

    return ListView.builder(
      reverse: true, // List grows from bottom up
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final messageIndex = index;
        Contact contact = widget.contact;
        final message = reversedMessages[messageIndex];
        String fourByteHex = '';
        if (widget.contact.type == advTypeRoom) {
          contact = _resolveContactFrom4Bytes(
            connector,
            message.fourByteRoomContactKey.isEmpty
                ? Uint8List.fromList([0, 0, 0, 0])
                : message.fourByteRoomContactKey,
          );
          fourByteHex = message.fourByteRoomContactKey
              .map((b) => b.toRadixString(16).padLeft(2, '0'))
              .join()
              .toUpperCase();
        }

        Widget bubble = _MessageBubble(
          message: message,
          senderName: widget.contact.type == advTypeRoom
              ? "${contact.displayName} [$fourByteHex]"
              : contact.displayName,
          isRoomServer: widget.contact.type == advTypeRoom,
          onTap: () => _openMessagePath(message, contact),
          onLongPress: () => _showMessageActions(message, contact),
        );
        if (messageIndex == _firstUnreadIndex) {
          bubble = KeyedSubtree(
            key: _firstUnreadKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildUnreadDivider(context, _unreadDividerCount!),
                bubble,
              ],
            ),
          );
        }

        return Dismissible(
          key: ObjectKey(message),
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
          onDismissed: (_) => _deleteMessage(message),
          child: bubble,
        );
      },
    );
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

  Widget _buildInputBar(MeshCoreConnector connector) {
    final maxBytes = maxContactMessageBytes();
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
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
                  final gifId = _parseGifId(value.text);
                  if (gifId != null) {
                    return Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GifMessage(
                              url:
                                  'https://media.giphy.com/media/$gifId/giphy.gif',
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              fallbackTextColor: colorScheme.onSurface
                                  .withValues(alpha: 0.6),
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
                    return _buildPoiComposerPreview(context, poi, colorScheme);
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
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(connector),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.send),
              onPressed: () => _sendMessage(connector),
            ),
          ],
        ),
      ),
    );
  }

  String? _parseGifId(String text) {
    final trimmed = text.trim();
    final match = RegExp(r'^g:([A-Za-z0-9_-]+)$').firstMatch(trimmed);
    return match?.group(1);
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

  Future<void> _sendMessage(MeshCoreConnector connector) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final maxBytes = maxContactMessageBytes();
    if (utf8.encode(text).length > maxBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chat_messageTooLong(maxBytes))),
      );
      return;
    }

    if (!connector.isConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.common_disconnected)));
      return;
    }

    try {
      await connector.sendMessage(widget.contact, text);
      _textController.clear();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chat_sendFailed(error.toString()))),
      );
    }
  }

  void _showPathHistory(BuildContext context) {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    bool showAllPaths = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Consumer<PathHistoryService>(
          builder: (context, pathService, _) {
            final paths = pathService.getRecentPaths(
              widget.contact.publicKeyHex,
            );
            final colorScheme = Theme.of(context).colorScheme;

            final repeatersList = List.of(connector.directRepeaters)
              ..sort((a, b) => b.ranking.compareTo(a.ranking));

            if (repeatersList.isEmpty) {
              showAllPaths = true;
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

            List<MapEntry<int, MapEntry<Color, PathRecord>>>
            pathsWithRepeaters = paths.map((path) {
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
                color = colorScheme.tertiary;
                ranking = 3;
              } else if (isSecondDirectRepeater) {
                color = colorScheme.secondary;
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
              title: Row(
                children: [
                  const Icon(Icons.timeline),
                  const SizedBox(width: 8),
                  Text(context.l10n.chat_pathManagement),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pathsWithRepeaters.isNotEmpty) ...[
                      if (repeatersList.isNotEmpty)
                        FeatureToggleRow(
                          title: context.l10n.chat_ShowAllPaths,
                          subtitle: "",
                          value: showAllPaths,
                          onChanged: (val) {
                            setDialogState(() {
                              showAllPaths = val;
                            });
                          },
                        ),
                      Text(
                        context.l10n.chat_recentAckPaths,
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
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.chat_pathHistoryFull,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      ...pathsWithRepeaters.map((entry) {
                        final path = entry.value.value;
                        final color = entry.value.key;
                        if (!showAllPaths && entry.key < 1) {
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
                                '${path.hopCount} ${path.hopCount == 1 ? context.l10n.chat_hopSingular : context.l10n.chat_hopPlural}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                '${(path.tripTimeMs / 1000).toStringAsFixed(2)}s • ${_formatRelativeTime(path.timestamp)} • ${path.successCount} ${context.l10n.chat_successes}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    tooltip: context.l10n.chat_removePath,
                                    onPressed: () async {
                                      await pathService.removePathRecord(
                                        widget.contact.publicKeyHex,
                                        path.pathBytes,
                                      );
                                    },
                                  ),
                                  path.wasFloodDiscovery
                                      ? Icon(
                                          Icons.waves,
                                          size: 16,
                                          color: colorScheme.outlineVariant,
                                        )
                                      : Icon(
                                          Icons.route,
                                          size: 16,
                                          color: colorScheme.outlineVariant,
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
                                        context
                                            .l10n
                                            .chat_pathDetailsNotAvailable,
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                final pathBytes = Uint8List.fromList(
                                  path.pathBytes,
                                );

                                // Set the path override to persist user's choice
                                await connector.setPathOverride(
                                  widget.contact,
                                  pathLen: path.hopCount,
                                  pathBytes: pathBytes,
                                );

                                if (!context.mounted) return;
                                Navigator.pop(context);
                                await _notifyPathSet(
                                  connector,
                                  widget.contact,
                                  pathBytes,
                                  path.hopCount,
                                );
                              },
                            ),
                          );
                        }
                      }),
                      const Divider(),
                    ] else ...[
                      Text(context.l10n.chat_noPathHistoryYet),
                      const Divider(),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.chat_pathActions,
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
                        backgroundColor: colorScheme.secondaryContainer,
                        child: const Icon(Icons.edit_road, size: 16),
                      ),
                      title: Text(
                        context.l10n.chat_setCustomPath,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        context.l10n.chat_setCustomPathSubtitle,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showCustomPathDialog(context);
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
                        context.l10n.chat_clearPath,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        context.l10n.chat_clearPathSubtitle,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () async {
                        await connector.clearContactPath(widget.contact);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.chat_pathCleared),
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
                        context.l10n.chat_forceFloodMode,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        context.l10n.chat_floodModeSubtitle,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () async {
                        await connector.setPathOverride(
                          widget.contact,
                          pathLen: -1,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.chat_floodModeEnabled),
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
                  child: Text(context.l10n.common_close),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return context.l10n.time_justNow;
    if (diff.inMinutes < 60) {
      return context.l10n.time_minutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) return context.l10n.time_hoursAgo(diff.inHours);
    return context.l10n.time_daysAgo(diff.inDays);
  }

  void _showFullPathDialog(BuildContext context, List<int> pathBytes) {
    if (pathBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.chat_pathDetailsNotAvailable),
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
        title: Text(context.l10n.chat_fullPath),
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
            child: Text(context.l10n.common_close),
          ),
        ],
      ),
    );
  }

  Contact _resolveContact(MeshCoreConnector connector) {
    return connector.contacts.firstWhere(
      (c) => c.publicKeyHex == widget.contact.publicKeyHex,
      orElse: () => widget.contact,
    );
  }

  Contact _resolveContactFrom4Bytes(
    MeshCoreConnector connector,
    Uint8List key4Bytes,
  ) {
    return connector.contacts.firstWhere(
      (c) => listEquals(c.publicKey.sublist(0, 4), key4Bytes.sublist(0, 4)),
      orElse: () => widget.contact,
    );
  }

  String _currentPathLabel(Contact contact) {
    // Check if user has set a path override
    if (contact.pathOverride != null) {
      if (contact.pathOverride! < 0) return context.l10n.chat_floodForced;
      if (contact.pathOverride == 0) return context.l10n.chat_directForced;
      return context.l10n.chat_hopsForced(contact.pathOverride!);
    }

    // Use device's path
    if (contact.pathLength < 0) return context.l10n.chat_floodAuto;
    if (contact.pathLength == 0) return context.l10n.chat_direct;
    return context.l10n.chat_hopsCount(contact.pathLength);
  }

  Future<void> _notifyPathSet(
    MeshCoreConnector connector,
    Contact contact,
    Uint8List pathBytes,
    int hopCount,
  ) async {
    final verified = connector.isConnected
        ? await connector.verifyContactPathOnDevice(contact, pathBytes)
        : false;
    if (!mounted) return;

    final status = !connector.isConnected
        ? context.l10n.chat_pathSavedLocally
        : (verified
              ? context.l10n.chat_pathDeviceConfirmed
              : context.l10n.chat_pathDeviceNotConfirmed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.chat_pathSetHops(hopCount, status)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showContactInfo(BuildContext context) {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    connector.ensureContactSmazSettingLoaded(widget.contact.publicKeyHex);

    showDialog(
      context: context,
      builder: (context) => Consumer<MeshCoreConnector>(
        builder: (context, connector, _) {
          final contact = _resolveContact(connector);
          final smazEnabled = connector.isContactSmazEnabled(
            contact.publicKeyHex,
          );

          return AlertDialog(
            title: Text(contact.displayName),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(context.l10n.chat_type, contact.typeLabel),
                  _buildInfoRow(context.l10n.chat_path, contact.pathLabel),
                  if (contact.hasLocation)
                    _buildInfoRow(
                      context.l10n.chat_location,
                      '${contact.latitude?.toStringAsFixed(4)}, ${contact.longitude?.toStringAsFixed(4)}',
                    ),
                  _buildInfoRow(
                    context.l10n.chat_publicKey,
                    '${contact.publicKeyHex.substring(0, 16)}...',
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.channels_smazCompression),
                    subtitle: Text(context.l10n.chat_compressOutgoingMessages),
                    value: smazEnabled,
                    onChanged: (value) {
                      connector.setContactSmazEnabled(
                        contact.publicKeyHex,
                        value,
                      );
                    },
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
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, Contact contact) {
    // Check if this is a repeater
    context.read<MeshCoreConnector>().markContactRead(contact.publicKeyHex);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(contact: contact)),
    );
  }

  Future<void> _showCustomPathDialog(BuildContext context) async {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    final settingsService = Provider.of<AppSettingsService>(
      context,
      listen: false,
    );
    final hashSizeBytes = pathHashBytesForMode(
      settingsService.settings.companionPathHashMode,
    );

    final currentContact = _resolveContact(connector);
    if (currentContact.pathLength > 0 &&
        currentContact.path.isEmpty &&
        connector.isConnected) {
      unawaited(connector.refreshContactsBestEffort(tag: 'Chat'));
    }

    final pathForInput = currentContact.pathIdList;
    final currentPathLabel = _currentPathLabel(currentContact);

    // Filter out the current contact from available contacts
    final availableContacts = connector.contacts
        .where((c) => c != widget.contact)
        .toList();

    final result = await PathSelectionDialog.show(
      context,
      availableContacts: availableContacts,
      initialPath: pathForInput.isEmpty ? null : pathForInput,
      title: context.l10n.chat_setCustomPath,
      currentPathLabel: currentPathLabel,
      onRefresh: connector.isConnected ? connector.getContacts : null,
      hashSizeBytes: hashSizeBytes,
    );

    appLogger.info(
      'PathSelectionDialog returned: ${result?.length ?? 0} bytes, mounted: $mounted',
      tag: 'ChatScreen',
    );

    if (result == null) {
      appLogger.info(
        'PathSelectionDialog was cancelled or returned null',
        tag: 'ChatScreen',
      );
      return;
    }

    if (!mounted) {
      appLogger.warn(
        'Widget not mounted after dialog, cannot set path',
        tag: 'ChatScreen',
      );
      return;
    }

    appLogger.info(
      'Calling setPathOverride for ${widget.contact.name}',
      tag: 'ChatScreen',
    );
    final hopCount = result.length ~/ hashSizeBytes;
    await connector.setPathOverride(
      widget.contact,
      pathLen: hopCount,
      pathBytes: result,
    );
    appLogger.info('setPathOverride completed', tag: 'ChatScreen');

    if (!mounted) return;
    await _notifyPathSet(connector, widget.contact, result, hopCount);
  }

  void _openMessagePath(Message message, Contact contact) {
    final connector = context.read<MeshCoreConnector>();
    final fourByteHex = message.fourByteRoomContactKey
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
    final String senderName;
    if (message.isOutgoing) {
      senderName = connector.selfName ?? context.l10n.chat_me;
    } else if (widget.contact.type == advTypeRoom) {
      senderName = "${contact.displayName} [$fourByteHex]";
    } else {
      senderName = widget.contact.displayName;
    }
    final pathMessage = ChannelMessage(
      senderKey: null,
      senderName: senderName,
      text: message.text,
      timestamp: message.timestamp,
      isOutgoing: message.isOutgoing,
      status: ChannelMessageStatus.sent,
      repeatCount: 0,
      pathLength: message.pathLength,
      pathBytes: message.pathBytes,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChannelMessagePathScreen(message: pathMessage),
      ),
    );
  }

  void _showMessageActions(Message message, Contact contact) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_reaction_outlined),
              title: Text(context.l10n.chat_addReaction),
              onTap: () {
                Navigator.pop(sheetContext);
                _showEmojiPicker(message, contact);
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
                _openMessagePath(message, contact);
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
            if (message.isOutgoing && message.status == MessageStatus.failed)
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(context.l10n.common_retry),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _retryMessage(message);
                },
              ),
            if (widget.contact.type == advTypeRoom)
              ListTile(
                leading: const Icon(Icons.chat),
                title: Text(context.l10n.contacts_openChat),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openChat(context, contact);
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

  void _copyMessageText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.chat_messageCopied)));
  }

  Future<void> _deleteMessage(Message message) async {
    await context.read<MeshCoreConnector>().deleteMessage(message);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.chat_messageDeleted)));
  }

  Future<void> _editMessage(Message message) async {
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
      await connector.editMessage(widget.contact, message, newText);
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

  Future<void> _retryMessage(Message message) async {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    if (!connector.isConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.common_disconnected)));
      return;
    }
    final text = message.text;
    try {
      await connector.sendMessage(widget.contact, text);
      await connector.deleteMessage(message);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chat_retryingMessage)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chat_sendFailed(error.toString()))),
      );
    }
  }

  void _showEmojiPicker(Message message, Contact senderContact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EmojiPicker(
        onEmojiSelected: (emoji) {
          _sendReaction(message, senderContact, emoji);
        },
      ),
    );
  }

  Future<void> _sendReaction(
    Message message,
    Contact senderContact,
    String emoji,
  ) async {
    final connector = context.read<MeshCoreConnector>();
    final emojiIndex = ReactionHelper.emojiToIndex(emoji);
    if (emojiIndex == null) return; // Unknown emoji, skip
    final timestampSecs = message.timestamp.millisecondsSinceEpoch ~/ 1000;

    // For room servers, include sender name (like channels) since multiple users
    // For 1:1 chats, sender is implicit (null)
    final senderName = widget.contact.type == advTypeRoom
        ? senderContact.name
        : null;
    final hash = ReactionHelper.computeReactionHash(
      timestampSecs,
      senderName,
      message.text,
    );
    final reactionText = 'r:$hash:$emojiIndex';
    try {
      await connector.sendMessage(widget.contact, reactionText);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chat_sendFailed(error.toString()))),
      );
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final String senderName;
  final bool isRoomServer;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _MessageBubble({
    required this.message,
    required this.senderName,
    required this.isRoomServer,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final settingsService = context.watch<AppSettingsService>();
    final enableTracing = settingsService.settings.enableMessageTracing;
    final isOutgoing = message.isOutgoing;
    final colorScheme = Theme.of(context).colorScheme;
    final gifId = _parseGifId(message.text);
    final poi = _parsePoiMessage(message.text);
    final isFailed = message.status == MessageStatus.failed;
    final appColors = context.appColors;
    final bubbleColor = isFailed
        ? AppColors.failedBubble
        : (isOutgoing ? appColors.outgoingBubble : appColors.incomingBubble);
    final textColor = isFailed
        // intentionally fixed: contrasts against the fixed-tint failedBubble
        // fill, not a theme surface color
        ? Colors.white
        : (isOutgoing
              ? AppColors.textColorForBackground(appColors.outgoingBubble)
              : colorScheme.onSurface);
    final metaColor = textColor.withValues(alpha: 0.7);
    String messageText = message.text;
    if (isRoomServer && !isOutgoing) {
      messageText = message.text.substring(4.clamp(0, message.text.length));
    }
    if (isRetiredMediaMessage(messageText) || messageText.startsWith('!A')) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isOutgoing
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Row(
              mainAxisAlignment: isOutgoing
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isOutgoing) ...[
                  _buildAvatar(senderName, colorScheme),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Container(
                    padding: gifId != null
                        ? const EdgeInsets.all(4)
                        : const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
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
                              senderName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          if (gifId == null) const SizedBox(height: 4),
                        ],
                        if (poi != null)
                          _buildPoiMessage(
                            context,
                            poi,
                            textColor,
                            metaColor,
                            trailing: (!enableTracing && isOutgoing)
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: MessageStatusIcon(
                                      isAcked:
                                          message.status ==
                                              MessageStatus.delivered &&
                                          message.pathBytes.isNotEmpty,
                                      isFailed:
                                          message.status ==
                                          MessageStatus.failed,
                                    ),
                                  )
                                : null,
                          )
                        else if (gifId != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GifMessage(
                                  url:
                                      'https://media.giphy.com/media/$gifId/giphy.gif',
                                  backgroundColor: Colors.transparent,
                                  fallbackTextColor: textColor.withValues(
                                    alpha: 0.7,
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
                                      color: bubbleColor,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: MessageStatusIcon(
                                      isAcked:
                                          message.status ==
                                              MessageStatus.delivered &&
                                          message.pathBytes.isNotEmpty,
                                      isFailed:
                                          message.status ==
                                          MessageStatus.failed,
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
                                  message: RichMessageParser.parse(messageText),
                                  style: TextStyle(color: textColor),
                                  accentColor: isOutgoing
                                      // intentionally fixed: contrasts
                                      // against the fixed-tint outgoingBubble
                                      // fill, not a theme surface color
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
                                            MessageStatus.delivered &&
                                        message.pathBytes.isNotEmpty,
                                    isFailed:
                                        message.status == MessageStatus.failed,
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
                                color: metaColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                        if (enableTracing) ...[
                          if (isOutgoing && message.retryCount > 0) ...[
                            const SizedBox(height: 4),
                            Padding(
                              padding: gifId != null
                                  ? const EdgeInsets.symmetric(horizontal: 8)
                                  : EdgeInsets.zero,
                              child: Text(
                                context.l10n.chat_retryCount(
                                  message.retryCount,
                                  4,
                                ),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: metaColor,
                                  fontWeight: FontWeight.w500,
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
                            child: Wrap(
                              spacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: metaColor,
                                  ),
                                ),
                                if (isOutgoing) ...[
                                  const SizedBox(width: 4),
                                  _buildStatusIcon(metaColor),
                                ],
                                if (message.tripTimeMs != null &&
                                    message.status ==
                                        MessageStatus.delivered) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.speed,
                                    size: 10,
                                    color: isOutgoing
                                        ? metaColor
                                        : colorScheme.tertiary,
                                  ),
                                  Text(
                                    '${(message.tripTimeMs! / 1000).toStringAsFixed(1)}s',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isOutgoing
                                          ? metaColor
                                          : colorScheme.tertiary,
                                    ),
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
              ],
            ),
          ),
          if (message.reactions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(left: isOutgoing ? 0 : 48),
              child: _buildReactionsDisplay(context, message, colorScheme),
            ),
          ],
        ],
      ),
    );
  }

  String? _parseGifId(String text) {
    final trimmed = text.trim();
    final match = RegExp(r'^g:([A-Za-z0-9_-]+)$').firstMatch(trimmed);
    return match?.group(1);
  }

  _PoiInfo? _parsePoiMessage(String text) {
    final legacy = LegacyMapMarker.tryParse(text);
    if (legacy != null) {
      return _PoiInfo(lat: legacy.lat, lon: legacy.lon, label: legacy.label);
    }

    final tactical = TacticalMapPayload.tryParse(text);
    if (tactical is TacticalPoiMarker) {
      return _PoiInfo(
        lat: tactical.lat,
        lon: tactical.lon,
        label: tactical.label,
        tacticalType: tactical.type,
      );
    }

    return null;
  }

  Widget _buildPoiMessage(
    BuildContext context,
    _PoiInfo poi,
    Color textColor,
    Color metaColor, {
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.location_on_outlined, color: textColor),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapScreen(
                  highlightPosition: LatLng(poi.lat, poi.lon),
                  highlightLabel: poi.label,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poi.tacticalType == 'wp'
                    ? context.l10n.chat_waypointShared
                    : context.l10n.chat_poiShared,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
              if (poi.label.isNotEmpty)
                Text(
                  poi.label,
                  style: TextStyle(color: metaColor, fontSize: 12),
                ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 4), trailing],
      ],
    );
  }

  Widget _buildReactionsDisplay(
    BuildContext context,
    Message message,
    ColorScheme colorScheme,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: message.reactions.entries.map((entry) {
        final emoji = entry.key;
        final count = entry.value;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
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
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvatar(String senderName, ColorScheme colorScheme) {
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

  Widget _buildStatusIcon(Color color) {
    IconData icon;
    switch (message.status) {
      case MessageStatus.pending:
        icon = Icons.access_time;
        break;
      case MessageStatus.sent:
        icon = Icons.schedule;
        break;
      case MessageStatus.delivered:
        icon = Icons.check;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        break;
    }

    return Icon(icon, size: 12, color: color);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _PoiInfo {
  final double lat;
  final double lon;
  final String label;
  final String? tacticalType;

  const _PoiInfo({
    required this.lat,
    required this.lon,
    required this.label,
    this.tacticalType,
  });
}
