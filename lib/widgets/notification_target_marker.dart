import 'package:flutter/widgets.dart';

/// Keys for the pages a tapped notification can open.
///
/// They use the same `kind:id` shape as the payloads `NotificationService`
/// attaches, so a payload can be checked against what is already on screen.
abstract final class NotificationTarget {
  static String message(String contactKeyHex) => 'message:$contactKeyHex';

  static String channel(int channelIndex) => 'channel:$channelIndex';

  /// The node list. Every advert notification opens the same list, so the
  /// advertised node is not part of the key.
  static const String contacts = 'contacts';
}

/// Marks [child] as the page for [target] on the route it is shown on.
///
/// `NotificationNavigator` checks [isInFront] before opening a page, so
/// tapping a notification for the conversation the user is already looking at
/// does not stack an identical copy on top of it. Back on such a copy appears
/// to do nothing, which reads as being stuck on the page.
class NotificationTargetMarker extends StatefulWidget {
  const NotificationTargetMarker({
    super.key,
    required this.target,
    required this.child,
  });

  /// This page's key from [NotificationTarget], or null to leave it untracked.
  final String? target;

  final Widget child;

  static final Map<_NotificationTargetMarkerState, Route<Object?>> _routes = {};

  /// Whether a page marked [target] is on the top-most route right now.
  ///
  /// A dialog or bottom sheet over the page is its own route, so the page is
  /// not in front while one is open, and a tap pushes a fresh copy above it.
  /// Back still returns through the dialog to the original page.
  static bool isInFront(String target) => _routes.entries.any(
    (entry) => entry.key.widget.target == target && entry.value.isCurrent,
  );

  @override
  State<NotificationTargetMarker> createState() =>
      _NotificationTargetMarkerState();
}

class _NotificationTargetMarkerState extends State<NotificationTargetMarker> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only this marker depends on the route, so a route change rebuilds it
    // and hands back the same child instead of rebuilding the whole page.
    final route = ModalRoute.of(context);
    if (route == null) {
      NotificationTargetMarker._routes.remove(this);
    } else {
      NotificationTargetMarker._routes[this] = route;
    }
  }

  @override
  void deactivate() {
    // Out of the tree, so not in front of anyone. If the element is put back,
    // the framework calls didChangeDependencies again and it is re-added.
    NotificationTargetMarker._routes.remove(this);
    super.deactivate();
  }

  @override
  void dispose() {
    NotificationTargetMarker._routes.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
