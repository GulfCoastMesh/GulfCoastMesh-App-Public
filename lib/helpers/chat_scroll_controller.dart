import 'package:flutter/material.dart';

class ChatScrollController extends ScrollController {
  final ValueNotifier<bool> showJumpToBottom = ValueNotifier(false);
  VoidCallback? onScrollNearTop;

  static const _bottomThreshold = 100.0;
  static const _topThreshold = 50.0;

  bool _wasNearTop = false;

  ChatScrollController() {
    addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!hasClients) return;
    final pos = position;

    // With reverse: true, position 0 is bottom, maxScrollExtent is top
    // Show jump button when scrolled away from bottom (position > threshold)
    final isAtBottom = pos.pixels <= _bottomThreshold;
    if (showJumpToBottom.value == isAtBottom) {
      showJumpToBottom.value = !isAtBottom;
    }

    // Pagination trigger fires only on the leading edge (scroll past the
    // threshold), not on every frame while held there, to avoid hammering
    // the loader with redundant calls.
    final isNearTop = pos.pixels >= pos.maxScrollExtent - _topThreshold;
    if (isNearTop && !_wasNearTop) {
      onScrollNearTop?.call();
    }
    _wasNearTop = isNearTop;
  }

  void jumpToBottom() {
    if (hasClients && position.maxScrollExtent > 0) {
      animateTo(
        0, // With reverse: true, position 0 is bottom
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void handleKeyboardOpen() {
    // Simple: just scroll to bottom when keyboard opens
    if (hasClients) {
      animateTo(
        0, // With reverse: true, position 0 is bottom
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void scrollToBottomIfAtBottom() {
    // Only scroll if jump button is NOT showing (i.e., already at bottom)
    if (!showJumpToBottom.value && hasClients && position.maxScrollExtent > 0) {
      animateTo(
        0, // With reverse: true, position 0 is bottom
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    showJumpToBottom.dispose();
    super.dispose();
  }
}
