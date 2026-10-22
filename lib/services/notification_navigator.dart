import 'dart:async';

import 'package:flutter/material.dart';

import '../connector/meshcore_connector.dart';
import '../screens/channel_chat_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/contacts_screen.dart';
import '../widgets/notification_target_marker.dart';

/// Opens the page a tapped notification points at.
///
/// Pages open on top of whatever is showing, and each one can be left with
/// the back button or the system back gesture. When the page for the tapped
/// notification is already in front of the user, nothing new is pushed,
/// because an identical copy on top makes back look broken.
class NotificationNavigator {
  NotificationNavigator({
    required GlobalKey<NavigatorState> navigatorKey,
    required MeshCoreConnector connector,
    this.connectTimeout = const Duration(seconds: 30),
    this.homeSettleDelay = const Duration(milliseconds: 300),
  }) : _navigatorKey = navigatorKey,
       _connector = connector;

  final GlobalKey<NavigatorState> _navigatorKey;
  final MeshCoreConnector _connector;

  /// How long [openOnceConnected] waits for auto-reconnect before giving up
  /// and leaving the user on the scanner.
  final Duration connectTimeout;

  /// How long [openOnceConnected] waits after reconnecting. ScannerScreen
  /// pushes HomeScreen from its own connection listener, and the page has to
  /// land on top of it, not underneath.
  final Duration homeSettleDelay;

  /// Opens the page for [payload]: `message:<contact key>`,
  /// `channel:<index>` or `advert:<contact key>`.
  ///
  /// Returns false when there is nothing to show: no navigator yet, a kind
  /// with no page (such as `telemetry` or `batch`), or a contact or channel
  /// that is not known.
  bool open(String payload) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return false;

    final separator = payload.indexOf(':');
    final kind = separator == -1 ? payload : payload.substring(0, separator);
    final id = separator == -1 ? '' : payload.substring(separator + 1);

    switch (kind) {
      case 'message':
        for (final contact in _connector.contacts) {
          if (contact.publicKeyHex == id) {
            _show(
              navigator,
              NotificationTarget.message(id),
              (_) => ChatScreen(contact: contact),
            );
            return true;
          }
        }
        return false;
      case 'channel':
        final channelIndex = int.tryParse(id);
        if (channelIndex == null) return false;
        for (final channel in _connector.channels) {
          if (channel.index == channelIndex) {
            _show(
              navigator,
              NotificationTarget.channel(channelIndex),
              (_) => ChannelChatScreen(channel: channel),
            );
            return true;
          }
        }
        return false;
      case 'advert':
        // A pushed copy of the node list, so it needs its own way back. The
        // hub's copy (hideBackButton: true) has no back button and blocks the
        // back gesture while connected, which left users stuck here until
        // they disconnected from the device.
        _show(
          navigator,
          NotificationTarget.contacts,
          (_) => const ContactsScreen(hideBackButton: false),
        );
        return true;
    }
    return false;
  }

  /// Opens [payload] for the notification that launched the app.
  ///
  /// Waits for auto-reconnect first. ScannerScreen pushes HomeScreen on top
  /// of the stack the moment it reconnects, so opening straight away on a
  /// cold start would race that push or land underneath it. Gives up after
  /// [connectTimeout] and leaves the user on the scanner.
  void openOnceConnected(String payload) {
    void openAfterHomePushed() {
      // Defer past ScannerScreen's own (synchronous) reconnect listener so
      // the page lands on top of the HomeScreen it just pushed.
      unawaited(
        Future<void>.delayed(homeSettleDelay, () {
          open(payload);
        }),
      );
    }

    if (_connector.isConnected) {
      openAfterHomePushed();
      return;
    }
    late final VoidCallback listener;
    final giveUp = Timer(connectTimeout, () {
      _connector.removeListener(listener);
    });
    listener = () {
      if (!_connector.isConnected) return;
      giveUp.cancel();
      _connector.removeListener(listener);
      openAfterHomePushed();
    };
    _connector.addListener(listener);
  }

  void _show(NavigatorState navigator, String target, WidgetBuilder builder) {
    if (NotificationTargetMarker.isInFront(target)) return;
    navigator.push(MaterialPageRoute<void>(builder: builder));
  }
}
