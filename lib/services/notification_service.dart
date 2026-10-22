import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

import '../helpers/channel_message_preview.dart';
import '../l10n/app_localizations.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Monotonic counter used when a notification has no stable identity to
  /// derive an ID from (e.g. anonymous adverts). Kept inside int32 because
  /// Android's notification id is a Java `int`.
  static int _uniqueIdCounter = 1;

  /// Convert an identifier to a stable, deterministic, int32-safe id so
  /// repeated notifications for the same key replace each other instead of
  /// stacking. Falls back to a monotonic counter when [key] is null so we
  /// don't collapse every anonymous notification onto id 0.
  static int _stableNotificationId(String? key) {
    if (key == null || key.isEmpty) {
      // Wrap into int31 to stay safe on Android's signed int.
      _uniqueIdCounter = (_uniqueIdCounter + 1) & 0x7FFFFFFF;
      return _uniqueIdCounter;
    }
    return key.hashCode & 0x7FFFFFFF;
  }

  /// Invoked with the tapped notification's payload (e.g. `message:<hex>`,
  /// `channel:<index>`, `advert:<hex>`). Set by the app shell, which has the
  /// navigator and connector needed to open the right screen.
  void Function(String payload)? onNotificationTapped;

  /// Payload of the notification that launched the app from a terminated
  /// state, if any.
  Future<String?> getLaunchPayload() async {
    // flutter_local_notifications does not implement launch details on Linux.
    // Notification responses received while the app is running still flow
    // through _onNotificationTapped.
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.linux) return null;

    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }

  // Locale for localized notification strings
  Locale _locale = const Locale('en');

  /// Set the locale for notification strings (call when app locale changes)
  void setLocale(Locale locale) {
    _locale = locale;
  }

  AppLocalizations get _l10n => lookupAppLocalizations(_locale);

  String _formatChannelMessageBody(String raw) {
    final preview = raw.trim();
    if (preview.isEmpty) {
      return _l10n.notification_receivedNewMessage;
    }

    final poi = ChannelMessagePreview.parsePoi(preview);
    if (poi != null) {
      final label = poi.label.isNotEmpty
          ? poi.label
          : (poi.tacticalType?.isNotEmpty == true
                ? poi.tacticalType!
                : _l10n.chat_poiShared);
      return _l10n.notification_channelPoiShared(label);
    }

    if (ChannelMessagePreview.parseGifId(preview) != null) {
      return _l10n.chat_sendGif;
    }

    return preview;
  }

  // Rate limiting to prevent notification storms
  // (Added after getting notification-flooded while evaluating RF flood management. The irony.)
  static const _minNotificationInterval = Duration(seconds: 3);
  static const _batchWindow = Duration(seconds: 5);

  DateTime? _lastNotificationTime;
  final List<_PendingNotification> _pendingNotifications = [];
  bool _isBatchingActive = false;
  bool _suppressNotifications = false;

  /// Temporarily suppress all notifications (e.g., during sync)
  void suppressNotifications(bool suppress) {
    _suppressNotifications = suppress;
    if (suppress) {
      _pendingNotifications.clear();
    }
  }

  Future<void> initialize() async {
    if (kIsWeb || _isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const macSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Gulf Coast Mesh App',
      appUserModelId: 'org.meshcore.open.app',
      guid: 'e7ea8f85-72f5-4f36-91f6-038f740ccf86',
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    try {
      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<bool> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _isInitialized;
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    if (!_isInitialized) {
      await initialize();
    }

    // Request Android 13+ notification permission
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS permissions are requested during initialization
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> _showMessageNotificationImpl({
    required String contactName,
    required String message,
    String? contactId,
    int? badgeCount,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool bannerEnabled = true,
  }) async {
    if (!await _ensureInitialized()) return;

    final androidDetails = AndroidNotificationDetails(
      'messages',
      'Messages',
      channelDescription: 'New message notifications',
      importance: bannerEnabled ? Importance.high : Importance.low,
      priority: bannerEnabled ? Priority.high : Priority.low,
      icon: '@mipmap/ic_launcher',
      number: badgeCount,
      playSound: soundEnabled,
      enableVibration: vibrationEnabled,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: bannerEnabled,
      presentBadge: true,
      presentSound: soundEnabled,
      badgeNumber: badgeCount,
    );

    final macDetails = DarwinNotificationDetails(
      presentAlert: bannerEnabled,
      presentBadge: true,
      presentSound: soundEnabled,
      badgeNumber: badgeCount,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macDetails,
    );

    try {
      await _notifications.show(
        id: _stableNotificationId(contactId),
        title: contactName,
        body: message,
        notificationDetails: notificationDetails,
        payload: 'message:$contactId',
      );
    } catch (e) {
      debugPrint('Failed to show message notification: $e');
    }
  }

  Future<void> _showAdvertNotificationImpl({
    required String contactName,
    required String contactType,
    String? contactId,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool bannerEnabled = true,
  }) async {
    if (!await _ensureInitialized()) return;

    final androidDetails = AndroidNotificationDetails(
      'adverts',
      'Advertisements',
      channelDescription: 'New node advertisement notifications',
      importance: bannerEnabled ? Importance.defaultImportance : Importance.low,
      priority: bannerEnabled ? Priority.defaultPriority : Priority.low,
      icon: '@mipmap/ic_launcher',
      playSound: soundEnabled,
      enableVibration: vibrationEnabled,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: bannerEnabled,
      presentBadge: true,
      presentSound: soundEnabled,
    );

    final macDetails = DarwinNotificationDetails(
      presentAlert: bannerEnabled,
      presentBadge: true,
      presentSound: soundEnabled,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macDetails,
    );

    try {
      await _notifications.show(
        id: _stableNotificationId(contactId),
        title: _l10n.notification_newTypeDiscovered(contactType),
        body: contactName,
        notificationDetails: notificationDetails,
        payload: 'advert:$contactId',
      );
    } catch (e) {
      debugPrint('Failed to show advert notification: $e');
    }
  }

  /// Threshold alerts from the telemetry monitor.
  ///
  /// Deliberately on its own channel rather than reusing `messages`: these are
  /// low-frequency device-health notices, and a user who silences them should
  /// not also silence mesh traffic. They bypass the message batching queue for
  /// the same reason — the monitor already fires each alert only once per
  /// threshold crossing.
  Future<void> showTelemetryAlert({
    required String title,
    required String body,
    String? nodeId,
  }) async {
    if (!await _ensureInitialized()) return;

    const androidDetails = AndroidNotificationDetails(
      'telemetry',
      'Telemetry alerts',
      channelDescription: 'Battery and radio health alerts',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    try {
      await _notifications.show(
        // Keyed on the alert text so a repeat replaces rather than stacks.
        id: _stableNotificationId('telemetry:${nodeId ?? ''}:$title'),
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: 'telemetry',
      );
    } catch (e) {
      debugPrint('Failed to show telemetry notification: $e');
    }
  }

  Future<void> _showChannelMessageNotificationImpl({
    required String channelName,
    required String message,
    int? channelIndex,
    int? badgeCount,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool bannerEnabled = true,
  }) async {
    if (!await _ensureInitialized()) return;

    final androidDetails = AndroidNotificationDetails(
      'channel_messages',
      'Channel Messages',
      channelDescription: 'New channel message notifications',
      importance: bannerEnabled ? Importance.high : Importance.low,
      priority: bannerEnabled ? Priority.high : Priority.low,
      icon: '@mipmap/ic_launcher',
      number: badgeCount,
      playSound: soundEnabled,
      enableVibration: vibrationEnabled,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: bannerEnabled,
      presentBadge: true,
      presentSound: soundEnabled,
      badgeNumber: badgeCount,
    );

    final macDetails = DarwinNotificationDetails(
      presentAlert: bannerEnabled,
      presentBadge: true,
      presentSound: soundEnabled,
      badgeNumber: badgeCount,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macDetails,
    );

    final body = _formatChannelMessageBody(message);

    try {
      await _notifications.show(
        id: _stableNotificationId(channelIndex?.toString()),
        title: channelName,
        body: body,
        notificationDetails: notificationDetails,
        payload: 'channel:$channelIndex',
      );
    } catch (e) {
      debugPrint('Failed to show channel notification: $e');
    }
  }

  /// Returns a privacy-safe identifier for debug logging.
  /// - advert: shows device name (body contains contactName)
  /// - message: shows "from: sender" (avoids logging message content)
  /// - channelMessage: shows "in: channel" (avoids logging message content)
  String _getNotificationIdentifier(_PendingNotification n) {
    switch (n.type) {
      case _NotificationType.advert:
        return n.body;
      case _NotificationType.message:
        return 'from: ${n.title}';
      case _NotificationType.channelMessage:
        return 'in: ${n.title}';
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      debugPrint('Notification tapped: $payload');
      onNotificationTapped?.call(payload);
    }
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _notifications.cancel(id: id);
  }

  // ─────────────────────────────────────────────────────────────────
  // Public notification methods (rate limiting is enforced automatically)
  // ─────────────────────────────────────────────────────────────────

  Future<void> showMessageNotification({
    required String contactName,
    required String message,
    String? contactId,
    int? badgeCount,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool bannerEnabled = true,
  }) async {
    if (_suppressNotifications) return;

    _queueNotification(
      _PendingNotification(
        type: _NotificationType.message,
        title: contactName,
        body: message,
        id: contactId,
        badgeCount: badgeCount,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        bannerEnabled: bannerEnabled,
      ),
    );
  }

  Future<void> showAdvertNotification({
    required String contactName,
    required String contactType,
    String? contactId,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool bannerEnabled = true,
  }) async {
    if (_suppressNotifications) return;

    _queueNotification(
      _PendingNotification(
        type: _NotificationType.advert,
        title: contactType,
        body: contactName,
        id: contactId,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        bannerEnabled: bannerEnabled,
      ),
    );
  }

  Future<void> showChannelMessageNotification({
    required String channelName,
    required String message,
    int? channelIndex,
    int? badgeCount,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool bannerEnabled = true,
  }) async {
    if (_suppressNotifications) return;

    _queueNotification(
      _PendingNotification(
        type: _NotificationType.channelMessage,
        title: channelName,
        body: message,
        id: channelIndex?.toString(),
        badgeCount: badgeCount,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        bannerEnabled: bannerEnabled,
      ),
    );
  }

  void _queueNotification(_PendingNotification notification) {
    final now = DateTime.now();

    // If we recently showed a notification, start batching
    if (_lastNotificationTime != null &&
        now.difference(_lastNotificationTime!) < _minNotificationInterval) {
      _pendingNotifications.add(notification);
      debugPrint(
        '[Notification] queued: ${notification.type.name} (${_getNotificationIdentifier(notification)})',
      );

      // Start batch timer if not already running
      if (!_isBatchingActive) {
        _isBatchingActive = true;
        Future.delayed(_batchWindow, _processBatch);
      }
      return;
    }

    // Show immediately if enough time has passed
    debugPrint(
      '[Notification] sent immediately: ${notification.type.name} (${_getNotificationIdentifier(notification)})',
    );
    _showNotificationImmediately(notification);
    _lastNotificationTime = now;
  }

  Future<void> _processBatch() async {
    _isBatchingActive = false;

    if (_pendingNotifications.isEmpty) return;

    final batch = List<_PendingNotification>.from(_pendingNotifications);
    _pendingNotifications.clear();

    if (batch.length == 1) {
      // Single notification, show normally
      _showNotificationImmediately(batch.first);
    } else {
      // Multiple notifications, show summary
      await _showBatchSummary(batch);
    }

    _lastNotificationTime = DateTime.now();
  }

  Future<void> _showNotificationImmediately(
    _PendingNotification notification,
  ) async {
    try {
      switch (notification.type) {
        case _NotificationType.message:
          await _showMessageNotificationImpl(
            contactName: notification.title,
            message: notification.body,
            contactId: notification.id,
            badgeCount: notification.badgeCount,
            soundEnabled: notification.soundEnabled,
            vibrationEnabled: notification.vibrationEnabled,
            bannerEnabled: notification.bannerEnabled,
          );
          break;
        case _NotificationType.advert:
          await _showAdvertNotificationImpl(
            contactName: notification.body,
            contactType: notification.title,
            contactId: notification.id,
            soundEnabled: notification.soundEnabled,
            vibrationEnabled: notification.vibrationEnabled,
            bannerEnabled: notification.bannerEnabled,
          );
          break;
        case _NotificationType.channelMessage:
          await _showChannelMessageNotificationImpl(
            channelName: notification.title,
            message: notification.body,
            channelIndex: int.tryParse(notification.id ?? ''),
            badgeCount: notification.badgeCount,
            soundEnabled: notification.soundEnabled,
            vibrationEnabled: notification.vibrationEnabled,
            bannerEnabled: notification.bannerEnabled,
          );
          break;
      }
    } catch (e) {
      debugPrint('Failed to show immediate notification: $e');
    }
  }

  Future<void> _showBatchSummary(List<_PendingNotification> batch) async {
    if (!await _ensureInitialized()) return;

    // Group by type
    final messages = batch
        .where((n) => n.type == _NotificationType.message)
        .toList();
    final adverts = batch
        .where((n) => n.type == _NotificationType.advert)
        .toList();
    final channelMsgs = batch
        .where((n) => n.type == _NotificationType.channelMessage)
        .toList();

    // Build summary text using localized plurals
    final parts = <String>[];
    if (messages.isNotEmpty) {
      parts.add(_l10n.notification_messagesCount(messages.length));
    }
    if (channelMsgs.isNotEmpty) {
      parts.add(_l10n.notification_channelMessagesCount(channelMsgs.length));
    }
    if (adverts.isNotEmpty) {
      parts.add(_l10n.notification_newNodesCount(adverts.length));
    }

    if (parts.isEmpty) return;

    // Show first few device names in batch summary for debugging (only if adverts exist)
    final deviceInfo = adverts.isNotEmpty
        ? ' (${adverts.take(5).map((n) => n.body).join(', ')}${adverts.length > 5 ? ', ...' : ''})'
        : '';
    debugPrint('[Notification] batch summary: ${parts.join(", ")}$deviceInfo');

    const androidDetails = AndroidNotificationDetails(
      'batch_summary',
      'Activity Summary',
      channelDescription: 'Batched notification summaries',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _notifications.show(
        id: _stableNotificationId('batch_summary'),
        title: _l10n.notification_activityTitle,
        body: parts.join(', '),
        notificationDetails: notificationDetails,
        payload: 'batch',
      );
    } catch (e) {
      debugPrint('Failed to show batch summary notification: $e');
    }
  }
}

// Helper class for pending notifications
enum _NotificationType { message, advert, channelMessage }

class _PendingNotification {
  final _NotificationType type;
  final String title;
  final String body;
  final String? id;
  final int? badgeCount;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool bannerEnabled;

  _PendingNotification({
    required this.type,
    required this.title,
    required this.body,
    this.id,
    this.badgeCount,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.bannerEnabled = true,
  });
}
