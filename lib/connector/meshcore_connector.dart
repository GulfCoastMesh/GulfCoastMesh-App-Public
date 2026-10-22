import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/channel.dart';
import '../models/channel_message.dart';
import '../models/contact.dart';
import '../models/mesh_region.dart';
import '../models/message.dart';
import '../models/notifiable_message.dart';
import '../models/path_selection.dart';
import '../helpers/advert_signature.dart';
import '../helpers/blocked_node_filter.dart';
import '../helpers/atak_location_access.dart';
import '../helpers/contact_advert_uri.dart';
import '../helpers/contact_local_state.dart';
import '../helpers/demo_weather_api2.dart';
import '../helpers/edit_helper.dart';
import '../helpers/meshcore_channel_crypto.dart';
import '../helpers/message_list_merge.dart';
import '../helpers/reaction_helper.dart';
import '../helpers/region_scope_codes.dart';
import '../helpers/smaz.dart';
import '../helpers/channel_message_preview.dart';
import '../helpers/tactical_map_payload.dart';
import '../helpers/transport_reliability.dart';
import '../helpers/wardriving_packet.dart';
import '../services/app_debug_log_service.dart';
import '../services/blocked_nodes_service.dart';
import '../services/frame_debug_log_service.dart';
import '../services/message_retry_service.dart';
import '../services/notification_service.dart';
import '../services/path_history_service.dart';
import '../services/app_settings_service.dart';
import '../services/background_service.dart';
import '../services/demo_data.dart';
import '../storage/channel_message_store.dart';
import '../storage/channel_order_store.dart';
import '../storage/channel_settings_store.dart';
import '../storage/channel_store.dart';
import '../storage/contact_settings_store.dart';
import '../storage/contact_store.dart';
import '../storage/message_store.dart';
import '../storage/unread_store.dart';
import '../storage/prefs_manager.dart';
import '../utils/app_logger.dart';
import '../utils/battery_utils.dart';
import 'ble_meshcore_transport.dart';
import 'tcp_meshcore_transport.dart';
import 'usb_serial_meshcore_transport.dart';
import 'meshcore_device.dart';
import 'message_notification_dispatcher.dart';
import 'meshcore_protocol.dart';
import 'meshcore_transport.dart';

export 'meshcore_device.dart';
export 'meshcore_transport.dart';

class DirectRepeater {
  static const int maxAgeMinutes = 30; // Max age for direct repeater info
  final int pubkeyFirstByte;
  double snr;
  DateTime lastUpdated;

  DirectRepeater({
    required this.pubkeyFirstByte,
    required this.snr,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  void update(double newSNR) {
    snr = newSNR;
    lastUpdated = DateTime.now();
  }

  int get ranking {
    if (isStale()) {
      return -1; // Stale repeaters get lowest rank
    }
    // Higher SNR gets higher rank and recency within maxAgeMinutes breaks ties.
    final ageMs =
        DateTime.now().millisecondsSinceEpoch -
        lastUpdated.millisecondsSinceEpoch;
    final maxAgeMs = maxAgeMinutes * 60 * 1000;
    final recencyScore = (maxAgeMs - ageMs).clamp(0, maxAgeMs);
    return ((snr - 31.75) * 1000).round() + recencyScore;
  }

  bool isStale() {
    return DateTime.now().difference(lastUpdated) >
        const Duration(minutes: maxAgeMinutes);
  }
}

class RepeaterBatterySnapshot {
  final int millivolts;
  final DateTime updatedAt;
  final String source;

  const RepeaterBatterySnapshot({
    required this.millivolts,
    required this.updatedAt,
    required this.source,
  });
}

class MeshCoreConnector extends ChangeNotifier with WidgetsBindingObserver {
  // Message windowing to limit memory usage
  static const int _messageWindowSize = 200;
  bool _disposed = false;
  bool _isDemoMode = false;
  Map<String, ContactLocalState>? _preDemoContactLocalByKey;
  Set<String>? _preDemoKnownContactKeys;
  Map<String, int>? _preDemoContactUnreadCount;
  Map<int, bool>? _preDemoChannelSmazEnabled;
  Map<int, String?>? _preDemoChannelRegionScope;
  Map<String, bool>? _preDemoContactSmazEnabled;
  List<int>? _preDemoChannelOrder;

  MeshCoreConnectionState _state = MeshCoreConnectionState.disconnected;

  /// One long-lived transport per kind; `connect()` picks by
  /// [MeshCoreDevice.transportKind].
  ///
  /// [transportOverrides] exists so tests can substitute a fake radio for a
  /// kind without touching real hardware; production always gets the defaults.
  MeshCoreConnector({
    @visibleForTesting
    Map<MeshCoreTransportKind, MeshCoreTransport>? transportOverrides,
    @visibleForTesting NotificationService? notificationService,
  }) : _notificationServiceOverride = notificationService {
    if (transportOverrides != null) {
      for (final entry in transportOverrides.entries) {
        _transports[entry.key]?.dispose();
        _transports[entry.key] = entry.value;
      }
    }
  }

  final Map<MeshCoreTransportKind, MeshCoreTransport> _transports = {
    MeshCoreTransportKind.ble: BleMeshCoreTransport(),
    MeshCoreTransportKind.usb: UsbSerialMeshCoreTransport(),
    MeshCoreTransportKind.tcp: TcpMeshCoreTransport(),
  };
  MeshCoreTransport? _activeTransport;
  MeshCoreTransportKind? _activeTransportKind;
  String? _deviceDisplayName;
  String? _deviceId;
  MeshCoreDevice? _lastDevice;
  bool _manualDisconnect = false;

  /// True after a session reached self-info; enables auto-reconnect on drop.
  bool _hadHealthySession = false;
  bool _handlingUnexpectedDisconnect = false;
  bool _reconnectGaveUp = false;
  bool _backgroundKeepAliveFailed = false;
  bool _observingLifecycle = false;
  int _connectGeneration = 0;
  int _lastSelfInfoGeneration = 0;
  static const int _maxReconnectAttempts = 6;
  static const String _batteryOptPrefKey = 'ble_ignore_battery_opt_prompted';

  StreamSubscription<MeshCoreConnectionState>? _transportStateSubscription;
  StreamSubscription<Uint8List>? _transportFrameSubscription;
  StreamSubscription<void>? _discoveryUpdatesSubscription;
  StreamSubscription<MeshCoreConnectionState>? _discoveryStateSubscription;
  MeshCoreTransport? _discoveryTransport;
  int _discoveryGeneration = 0;
  final List<Contact> _contacts = [];
  final List<Channel> _channels = [];
  final Map<String, List<Message>> _conversations = {};
  final Map<int, List<ChannelMessage>> _channelMessages = {};
  final List<String> _pendingChannelSentQueue = [];
  final List<_PendingCommandAck> _pendingGenericAckQueue = [];
  // Per-message send-phase timeouts for visible channel messages: if neither an
  // OK/SENT nor an ERR arrives, mark the message failed instead of leaving it
  // stuck as pending forever.
  final Map<String, Timer> _channelSendTimeouts = {};
  static const int _channelSendTimeoutMs = 8000;
  static const String _reactionSendQueuePrefix = '__reaction_send__';
  int _reactionSendQueueSequence = 0;
  final Set<String> _loadedConversationKeys = {};
  final Set<String> _loadingConversationKeys = {};
  final Set<int> _loadedChannelIndexes = {};
  final Set<int> _loadingChannelIndexes = {};
  // History before the loaded window stays on disk. Saves replace only the
  // loaded tail, including edits/deletions of messages without legacy IDs.
  final Map<String, int> _olderConversationCounts = {};
  final Map<int, int> _olderChannelCounts = {};
  Future<void> _historyPersistChain = Future.value();
  final Map<int, Set<String>> _processedChannelReactions =
      {}; // channelIndex -> Set of "targetHash_emoji"
  final Map<String, Set<String>> _processedContactReactions =
      {}; // contactPubKeyHex -> Set of "targetHash_emoji"
  /// Favorites / path overrides / firstSeenAt that survive full contact sync.
  final Map<String, ContactLocalState> _contactLocalByKey = {};

  /// Serializes contact-store writes so concurrent unawaited persists cannot
  /// last-writer-win a favorite or path toggle.
  Future<void> _contactPersistChain = Future.value();

  Timer? _selfInfoRetryTimer;
  Timer? _reconnectTimer;
  Timer? _batteryPollTimer;
  Completer<void>? _disconnectOp;
  int _reconnectAttempts = 0;

  final StreamController<Uint8List> _receivedFramesController =
      StreamController<Uint8List>.broadcast();
  final StreamController<ChannelMessage> _channelMessagesController =
      StreamController<ChannelMessage>.broadcast();

  Uint8List? _selfPublicKey;
  String? _selfName;
  int? _currentTxPower;
  int? _maxTxPower;
  int? _currentFreqHz;
  int? _currentBwHz;
  int? _currentSf;
  int? _currentCr;
  bool? _clientRepeat;
  int? _firmwareVerCode;
  int? _devicePathHashMode;
  bool _supportsPathHashMode = false;
  String? _defaultFloodScopeName;
  Completer<String?>? _defaultFloodScopeCompleter;
  Completer<int?>? _noiseFloorCompleter;
  int? _lastNoiseFloor;
  RadioStats? _lastRadioStats;
  int? _storageUsedKb;
  int? _storageTotalKb;
  final StreamController<RadioStats> _radioStatsController =
      StreamController<RadioStats>.broadcast();
  int? _batteryMillivolts;
  double? _selfLatitude;
  double? _selfLongitude;
  final List<DirectRepeater> _directRepeaters = List.empty(growable: true);
  bool _isLoadingContacts = false;
  bool _isLoadingChannels = false;
  bool _hasLoadedChannels = false;
  bool _batteryRequested = false;
  bool _awaitingSelfInfo = false;
  bool _preserveContactsOnRefresh = false;
  static const int _defaultMaxContacts = 32;
  static const int _defaultMaxChannels = 8;
  int _maxContacts = _defaultMaxContacts;
  int _maxChannels = _defaultMaxChannels;
  bool _isSyncingQueuedMessages = false;
  bool _queuedMessageSyncInFlight = false;
  bool _didInitialQueueSync = false;
  bool _pendingQueueSync = false;
  Timer? _queueSyncTimeout;
  int _queueSyncRetries = 0;
  static const int _maxQueueSyncRetries = 3;
  static const int _queueSyncTimeoutMs = 5000; // 5 second timeout
  Map<String, String>? _currentCustomVars;

  // Channel syncing state (sequential pattern)
  bool _isSyncingChannels = false;
  bool _channelSyncInFlight = false;
  Timer? _channelSyncTimeout;
  int _channelSyncRetries = 0;
  int _nextChannelIndexToRequest = 0;
  int _totalChannelsToRequest = 0;
  List<Channel> _previousChannelsCache = [];
  static const int _maxChannelSyncRetries = 3;
  static const int _channelSyncTimeoutMs = 2000; // 2 second timeout per channel
  static const Duration _batteryPollInterval = Duration(seconds: 120);

  // Services
  MessageRetryService? _retryService;
  PathHistoryService? _pathHistoryService;
  AppSettingsService? _appSettingsService;
  BlockedNodesService? _blockedNodes;
  final NotificationService? _notificationServiceOverride;
  bool _nodeBlockingWasEnabled = false;
  BackgroundService? _backgroundService;
  late final MessageNotificationDispatcher _notifications =
      MessageNotificationDispatcher(
        readSettings: () => _appSettingsService?.settings,
        readSelfName: () => selfName,
        readBadgeCount: getTotalUnreadCount,
        isNodeHidden: isNodeHidden,
        notificationService: _notificationServiceOverride,
      );
  FrameDebugLogService? _frameDebugLogService;
  AppDebugLogService? _appDebugLogService;
  final ChannelMessageStore _channelMessageStore = ChannelMessageStore();
  final MessageStore _messageStore = MessageStore();
  final ChannelOrderStore _channelOrderStore = ChannelOrderStore();
  final ChannelSettingsStore _channelSettingsStore = ChannelSettingsStore();
  final ContactSettingsStore _contactSettingsStore = ContactSettingsStore();
  final ContactStore _contactStore = ContactStore();
  final ChannelStore _channelStore = ChannelStore();
  final UnreadStore _unreadStore = UnreadStore();

  List<Channel> _cachedChannels = [];
  final Map<int, bool> _channelSmazEnabled = {};
  final Map<int, String?> _channelRegionScope = {};

  /// Last session flood-scope applied via CMD_SET_FLOOD_SCOPE_KEY.
  /// Null means cleared / following device default.
  String? _sessionFloodScopeName;

  /// Companion local CLI (`sendCliCommand`) may emit RESP_CODE_SENT with no
  /// hash we track. Count pending ones so they cannot advance the channel
  /// send FIFO.
  int _pendingCompanionCliSents = 0;
  final Map<String, bool> _contactSmazEnabled = {};
  final Set<String> _knownContactKeys = {};
  final Map<String, int> _contactUnreadCount = {};
  static const int _maxPendingReactions = 128;
  final Map<String, List<_PendingReaction>> _pendingContactReactions = {};
  final Map<int, List<_PendingReaction>> _pendingChannelReactions = {};
  final Map<String, _PendingOutgoingChannelReaction>
  _pendingOutgoingChannelReactions = {};
  final Map<int, Set<String>> _processedChannelEdits =
      {}; // channelIndex -> Set of "targetHash_editor"
  final Map<String, Set<String>> _processedContactEdits =
      {}; // contactPubKeyHex -> Set of "targetHash_editor"
  final Map<String, List<_PendingEdit>> _pendingContactEdits = {};
  final Map<int, List<_PendingEdit>> _pendingChannelEdits = {};
  final Map<String, RepeaterBatterySnapshot> _repeaterBatterySnapshots = {};
  bool _unreadStateLoaded = false;
  final Map<String, _RepeaterAckContext> _pendingRepeaterAcks = {};
  String? _activeContactKey;
  int? _activeChannelIndex;
  List<int> _channelOrder = [];

  // Getters
  MeshCoreConnectionState get state => _state;
  bool get isDemoMode => _isDemoMode;
  MeshCoreTransportKind? get activeTransportKind => _activeTransportKind;
  String? get deviceId => _deviceId;
  String get deviceIdLabel => _deviceId ?? 'Unknown';

  String get deviceDisplayName {
    if (_selfName != null && _selfName!.isNotEmpty) {
      return _selfName!;
    }
    if (_deviceDisplayName != null && _deviceDisplayName!.isNotEmpty) {
      return _deviceDisplayName!;
    }
    return 'Unknown Device';
  }

  MeshCoreTransport _transportFor(MeshCoreTransportKind kind) =>
      _transports[kind]!;

  /// Devices found by the most recent discovery on [kind].
  List<MeshCoreDevice> discoveredDevicesFor(MeshCoreTransportKind kind) =>
      _transportFor(kind).discoveredDevices;

  List<Contact> get contacts {
    final selfKey = _selfPublicKey;
    if (selfKey == null) {
      return List.unmodifiable(_contacts);
    }
    return List.unmodifiable(
      _contacts.where((contact) => !listEquals(contact.publicKey, selfKey)),
    );
  }

  List<Channel> get channels => List.unmodifiable(_channels);
  bool get isConnected => _state == MeshCoreConnectionState.connected;
  // Not gated on `_reconnectGaveUp` — background retries continue
  // indefinitely past that point (see _shouldAutoReconnect), so the app bar
  // should keep reading "reconnecting" the whole time rather than settling
  // on a plain "disconnected" that gives no hint recovery is still happening.
  bool get isReconnecting =>
      !isConnected &&
      !_manualDisconnect &&
      _hadHealthySession &&
      _lastDevice != null;
  bool get shouldKeepHub => !shouldLeaveHub(
    isConnected: isConnected,
    isConnecting: _state == MeshCoreConnectionState.connecting,
    manualDisconnect: _manualDisconnect,
    hadHealthySession: _hadHealthySession,
    hasLastDevice: _lastDevice != null,
  );
  bool get backgroundKeepAliveFailed => _backgroundKeepAliveFailed;
  bool get isLoadingContacts => _isLoadingContacts;
  bool get isLoadingChannels => _isLoadingChannels;
  Stream<Uint8List> get receivedFrames => _receivedFramesController.stream;

  /// Newly accepted channel messages, emitted once per on-air message.
  Stream<ChannelMessage> get receivedChannelMessages =>
      _channelMessagesController.stream;
  Uint8List? get selfPublicKey => _selfPublicKey;
  String? get selfName => _selfName;
  double? get selfLatitude => _selfLatitude;
  double? get selfLongitude => _selfLongitude;
  List<DirectRepeater> get directRepeaters => _directRepeaters;
  int? get currentTxPower => _currentTxPower;
  int? get maxTxPower => _maxTxPower;
  int? get currentFreqHz => _currentFreqHz;
  int? get currentBwHz => _currentBwHz;
  int? get currentSf => _currentSf;
  int? get currentCr => _currentCr;
  bool? get clientRepeat => _clientRepeat;
  int? get firmwareVerCode => _firmwareVerCode;
  int? get devicePathHashMode => _devicePathHashMode;
  bool get supportsPathHashMode => _supportsPathHashMode;
  String? get defaultFloodScopeName => _defaultFloodScopeName;
  Map<String, String>? get currentCustomVars => _currentCustomVars;
  int? get batteryMillivolts => _batteryMillivolts;
  int get maxContacts => _maxContacts;
  int get maxChannels => _maxChannels;
  bool get isSyncingQueuedMessages => _isSyncingQueuedMessages;
  bool get isSyncingChannels => _isSyncingChannels;
  int get channelSyncProgress =>
      _isSyncingChannels && _totalChannelsToRequest > 0
      ? ((_nextChannelIndexToRequest / _totalChannelsToRequest) * 100).round()
      : 0;
  int? get batteryPercent => _batteryMillivolts == null
      ? null
      : estimateBatteryPercentFromMillivolts(
          _batteryMillivolts!,
          _batteryChemistryForDevice(),
          cellCount: _batteryCellCountForDevice(),
        );
  RepeaterBatterySnapshot? getRepeaterBatterySnapshot(String contactKeyHex) =>
      _repeaterBatterySnapshots[contactKeyHex];
  int? getRepeaterBatteryMillivolts(String contactKeyHex) =>
      _repeaterBatterySnapshots[contactKeyHex]?.millivolts;

  void updateRepeaterBatterySnapshot(
    String contactKeyHex,
    int millivolts, {
    String source = 'unknown',
  }) {
    if (contactKeyHex.isEmpty || millivolts <= 0) return;
    final previous = _repeaterBatterySnapshots[contactKeyHex];
    final snapshot = RepeaterBatterySnapshot(
      millivolts: millivolts,
      updatedAt: DateTime.now(),
      source: source,
    );
    _repeaterBatterySnapshots[contactKeyHex] = snapshot;
    if (previous?.millivolts != millivolts) {
      notifyListeners();
    }
  }

  String _batteryChemistryForDevice() {
    if (_deviceId == null || _appSettingsService == null) return 'nmc';
    return _appSettingsService!.batteryChemistryForDevice(_deviceId!);
  }

  int _batteryCellCountForDevice() {
    if (_deviceId == null || _appSettingsService == null) return 1;
    return _appSettingsService!.batteryCellCountForDevice(_deviceId!);
  }

  List<Message> getMessages(Contact contact) {
    return _conversations[contact.publicKeyHex] ?? [];
  }

  Future<void> deleteMessage(Message message) async {
    final contactKeyHex = message.senderKeyHex;
    final messages = _conversations[contactKeyHex];
    if (messages == null) return;
    final removed = messages.remove(message);
    if (!removed) return;
    await _saveConversationMessages(contactKeyHex, messages);
    notifyListeners();
  }

  Future<void> _loadMessagesForContact(String contactKeyHex) async {
    if (_loadedConversationKeys.contains(contactKeyHex) ||
        _loadingConversationKeys.contains(contactKeyHex)) {
      return;
    }
    _loadingConversationKeys.add(contactKeyHex);

    try {
      await _historyPersistChain;
      final diskMessages = await _messageStore.loadMessages(contactKeyHex);
      final liveMessages = _conversations[contactKeyHex] ?? [];
      final merged = mergeConversationMessages(diskMessages, liveMessages);
      if (merged.isNotEmpty) {
        final windowedMessages = windowNewest(merged, _messageWindowSize);
        final olderCount = merged.length - windowedMessages.length;
        _olderConversationCounts[contactKeyHex] = olderCount;
        _conversations[contactKeyHex] = windowedMessages;
        _resolvePendingContactReactions(contactKeyHex);
        _resolvePendingContactEdits(contactKeyHex);
        // Mark loaded before any await so concurrent _addMessage persists safely.
        _loadedConversationKeys.add(contactKeyHex);
        final history = [...merged.take(olderCount), ...windowedMessages];
        await _queueHistoryWrite(
          () => _messageStore.saveMessages(contactKeyHex, history),
        );
      } else {
        _loadedConversationKeys.add(contactKeyHex);
      }
      notifyListeners();
    } finally {
      _loadingConversationKeys.remove(contactKeyHex);
    }
  }

  /// Load older messages for a contact (pagination)
  Future<List<Message>> loadOlderMessages(
    String contactKeyHex, {
    int count = 50,
  }) async {
    if (_isDemoMode) return const [];
    await _historyPersistChain;
    final allMessages = await _messageStore.loadMessages(contactKeyHex);
    final currentMessages = _conversations[contactKeyHex] ?? [];
    final olderCount = _olderConversationCounts[contactKeyHex] ?? 0;

    final olderMessages = olderMessagePage(
      allMessages,
      allMessages.length - olderCount,
      count: count,
    );
    if (olderMessages.isEmpty) return const [];

    // Prepend to current conversation
    _olderConversationCounts[contactKeyHex] = olderCount - olderMessages.length;
    _conversations[contactKeyHex] = [...olderMessages, ...currentMessages];
    notifyListeners();

    return olderMessages;
  }

  List<ChannelMessage> getChannelMessages(Channel channel) {
    return _channelMessages[channel.index] ?? [];
  }

  Future<List<ChannelMessage>> loadTacticalChannelMessages(
    int channelIndex,
  ) async {
    if (_isDemoMode) {
      return (_channelMessages[channelIndex] ?? const [])
          .where((message) => TacticalMapPayload.tryParse(message.text) != null)
          .toList();
    }
    await _historyPersistChain;
    final allMessages = await _channelMessageStore.loadChannelMessages(
      channelIndex,
    );
    return allMessages
        .where((message) => TacticalMapPayload.tryParse(message.text) != null)
        .toList();
  }

  Future<void> deleteChannelMessage(ChannelMessage message) async {
    final channelIndex = message.channelIndex;
    if (channelIndex == null) return;
    final messages = _channelMessages[channelIndex];
    if (messages == null) return;
    final removed = messages.remove(message);
    if (!removed) return;
    await _saveChannelMessages(channelIndex, messages);
    notifyListeners();
  }

  void _attachAppSettingsService(AppSettingsService? service) {
    _appSettingsService?.removeListener(_onAppSettingsChanged);
    _appSettingsService = service;
    _nodeBlockingWasEnabled =
        service?.settings.experimentalNodeBlockingEnabled ?? false;
    service?.addListener(_onAppSettingsChanged);
  }

  // Unread totals and badges depend on the blocking switch, so refresh only
  // when it flips, not on every unrelated settings change.
  void _onAppSettingsChanged() {
    final enabled =
        _appSettingsService?.settings.experimentalNodeBlockingEnabled ?? false;
    if (enabled == _nodeBlockingWasEnabled) return;
    _nodeBlockingWasEnabled = enabled;
    notifyListeners();
  }

  /// Rebuilds listeners whenever the block list changes.
  void attachBlockedNodesService(BlockedNodesService? service) {
    _blockedNodes?.removeListener(notifyListeners);
    _blockedNodes = service?..addListener(notifyListeners);
  }

  /// Whether the user blocked this node and the blocking feature is on.
  /// The single predicate behind every hidden surface and muted alert.
  bool isNodeHidden(String publicKeyHex) =>
      _appSettingsService?.settings.experimentalNodeBlockingEnabled == true &&
      _blockedNodes?.isBlocked(publicKeyHex) == true;

  /// [contacts] minus blocked nodes. Use for display only: path resolution,
  /// routing and persistence need the full [contacts] list.
  List<Contact> get visibleContacts =>
      withoutHiddenNodes(contacts, isNodeHidden);

  int getUnreadCountForContact(Contact contact) {
    if (contact.type == advTypeRepeater) return 0;
    return getUnreadCountForContactKey(contact.publicKeyHex);
  }

  int getUnreadCountForContactKey(String contactKeyHex) {
    if (!_unreadStateLoaded) return 0;
    if (!_shouldTrackUnreadForContactKey(contactKeyHex)) return 0;
    if (isNodeHidden(contactKeyHex)) return 0;
    return _contactUnreadCount[contactKeyHex] ?? 0;
  }

  int getUnreadCountForChannel(Channel channel) {
    return getUnreadCountForChannelIndex(channel.index);
  }

  int getUnreadCountForChannelIndex(int channelIndex) {
    if (!_unreadStateLoaded) return 0;
    final channel = _findChannelByIndex(channelIndex);
    return channel == null || channel.isWeatherChannel
        ? 0
        : channel.unreadCount;
  }

  int getTotalUnreadCount() {
    if (!_unreadStateLoaded) return 0;
    var total = 0;
    // Count unread contact messages
    for (final contact in _contacts) {
      total += getUnreadCountForContact(contact);
    }
    // Count unread channel messages
    for (final channelIndex in _channelMessages.keys) {
      total += getUnreadCountForChannelIndex(channelIndex);
    }
    return total;
  }

  bool isChannelSmazEnabled(int channelIndex) {
    return _channelSmazEnabled[channelIndex] ?? false;
  }

  /// Per-channel flood region scope, or null for unscoped / device default.
  String? getChannelRegionScope(int channelIndex) {
    return _channelRegionScope[channelIndex];
  }

  Future<void> setChannelRegionScope(int channelIndex, String? scope) async {
    final trimmed = scope == null ? null : RegionScopeCodes.canonicalize(scope);
    final value = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    if (value != null && !MeshRegion.isValidRegionName(value)) {
      throw ArgumentError.value(scope, 'scope', 'invalid region name');
    }
    _channelRegionScope[channelIndex] = value;
    if (!_isDemoMode) {
      await _channelSettingsStore.saveRegionScope(channelIndex, value);
    }
    notifyListeners();
  }

  bool isContactSmazEnabled(String contactKeyHex) {
    return _contactSmazEnabled[contactKeyHex] ?? false;
  }

  void ensureContactSmazSettingLoaded(String contactKeyHex) {
    _ensureContactSmazSettingLoaded(contactKeyHex);
  }

  Future<void> loadUnreadState() async {
    _contactUnreadCount
      ..clear()
      ..addAll(await _unreadStore.loadContactUnreadCount());
    _unreadStateLoaded = true;
    notifyListeners();
  }

  Future<void> loadCachedChannels() async {
    _cachedChannels = await _channelStore.loadChannels();
  }

  /// The conversation currently open on the phone, if any. Used to avoid
  /// announcing a message the user is already looking at.
  String? get activeContactKey => _activeContactKey;
  int? get activeChannelIndex => _activeChannelIndex;

  void setActiveContact(String? contactKeyHex) {
    if (contactKeyHex != null &&
        !_shouldTrackUnreadForContactKey(contactKeyHex)) {
      _activeContactKey = null;
      return;
    }
    _activeContactKey = contactKeyHex;
    if (contactKeyHex != null) {
      markContactRead(contactKeyHex);
    }
  }

  void setActiveChannel(int? channelIndex) {
    _activeChannelIndex = channelIndex;
    if (channelIndex != null) {
      markChannelRead(channelIndex);
    }
  }

  /// Starts a fully in-memory session that exercises the normal connected UI.
  /// Demo state is deliberately never persisted.
  Future<void> enterDemoMode() async {
    if (_isDemoMode) return;
    if (_state != MeshCoreConnectionState.disconnected) {
      throw StateError('Disconnect from the radio before starting demo mode.');
    }
    _blockedNodes?.enterDemoMode();
    _preDemoContactLocalByKey = Map.of(_contactLocalByKey);
    _preDemoKnownContactKeys = Set.of(_knownContactKeys);
    _preDemoContactUnreadCount = Map.of(_contactUnreadCount);
    _preDemoChannelSmazEnabled = Map.of(_channelSmazEnabled);
    _preDemoChannelRegionScope = Map.of(_channelRegionScope);
    _preDemoContactSmazEnabled = Map.of(_contactSmazEnabled);
    _preDemoChannelOrder = List.of(_channelOrder);
    _clearSessionForManualDisconnect();
    final now = DateTime.now();
    final demoContacts = DemoData.contacts(now);
    final demoChannels = DemoData.channels();
    _isDemoMode = true;
    _manualDisconnect = false;
    _hadHealthySession = true;
    _deviceId = 'demo-session';
    _deviceDisplayName = 'Demo Companion';
    _selfName = 'Demo Operator';
    _selfPublicKey = DemoData.key(99);
    _selfLatitude = 30.3674;
    _selfLongitude = -89.0928;
    _currentTxPower = 20;
    _maxTxPower = 22;
    _currentFreqHz = 910525000;
    _currentBwHz = 62500;
    _currentSf = 7;
    _currentCr = 5;
    _clientRepeat = false;
    _firmwareVerCode = 12;
    _devicePathHashMode = defaultPathHashMode;
    _supportsPathHashMode = true;
    _batteryMillivolts = 4010;
    _maxContacts = 64;
    _maxChannels = 8;
    _contacts.addAll(demoContacts);
    _channels.addAll(demoChannels);
    _conversations.addAll(DemoData.conversations(demoContacts, now));
    _channelMessages.addAll(DemoData.channelMessages(now));
    // Empty demo conversations (including DeltaWX) are already fully loaded;
    // sending their first DM must not pull real history from disk.
    _loadedConversationKeys.addAll(demoContacts.map((c) => c.publicKeyHex));
    _loadedChannelIndexes.addAll(_channelMessages.keys);
    _knownContactKeys.addAll(
      demoContacts.map((contact) => contact.publicKeyHex),
    );
    updateRepeaterBatterySnapshot(
      demoContacts[1].publicKeyHex,
      4210,
      source: 'demo',
    );
    _hasLoadedChannels = true;
    _setState(MeshCoreConnectionState.connected);
    notifyListeners();
  }

  /// Ends the in-memory session and returns to a clean disconnected state.
  Future<void> exitDemoMode() async {
    if (!_isDemoMode) return;
    _isDemoMode = false;
    _blockedNodes?.exitDemoMode();
    _manualDisconnect = true;
    _hadHealthySession = false;
    _cancelReconnectTimer(resetAttempts: true);
    _failAllPendingChannelMessages();
    _pendingGenericAckQueue.clear();
    _pendingCompanionCliSents = 0;
    for (final entry in _pendingRepeaterAcks.values) {
      entry.timeout?.cancel();
    }
    _pendingRepeaterAcks.clear();
    _completePendingDeviceQueries();
    _clearSessionForManualDisconnect();
    _contactLocalByKey
      ..clear()
      ..addAll(_preDemoContactLocalByKey ?? const {});
    _knownContactKeys
      ..clear()
      ..addAll(_preDemoKnownContactKeys ?? const {});
    _contactUnreadCount
      ..clear()
      ..addAll(_preDemoContactUnreadCount ?? const {});
    _channelSmazEnabled
      ..clear()
      ..addAll(_preDemoChannelSmazEnabled ?? const {});
    _channelRegionScope
      ..clear()
      ..addAll(_preDemoChannelRegionScope ?? const {});
    _contactSmazEnabled
      ..clear()
      ..addAll(_preDemoContactSmazEnabled ?? const {});
    _channelOrder = List.of(_preDemoChannelOrder ?? const []);
    _preDemoContactLocalByKey = null;
    _preDemoKnownContactKeys = null;
    _preDemoContactUnreadCount = null;
    _preDemoChannelSmazEnabled = null;
    _preDemoChannelRegionScope = null;
    _preDemoContactSmazEnabled = null;
    _preDemoChannelOrder = null;
    _setState(MeshCoreConnectionState.disconnected);
    notifyListeners();
  }

  void markContactRead(String contactKeyHex) {
    if (!_shouldTrackUnreadForContactKey(contactKeyHex)) return;
    final previousCount = _contactUnreadCount[contactKeyHex] ?? 0;
    if (previousCount > 0) {
      _contactUnreadCount[contactKeyHex] = 0;
      _appDebugLogService?.info(
        'Contact $contactKeyHex marked as read (was $previousCount unread)',
        tag: 'Unread',
      );
      if (!_isDemoMode) {
        _unreadStore.saveContactUnreadCount(
          Map<String, int>.from(_contactUnreadCount),
        );
      }
      notifyListeners();
    }
  }

  void markChannelRead(int channelIndex) {
    final channel = _findChannelByIndex(channelIndex);
    if (channel != null && channel.unreadCount > 0) {
      final previousCount = channel.unreadCount;
      channel.unreadCount = 0;
      _appDebugLogService?.info(
        'Channel ${channel.name.isNotEmpty ? channel.name : channelIndex} marked as read (was $previousCount unread)',
        tag: 'Unread',
      );
      if (!_isDemoMode) {
        unawaited(
          _channelStore.saveChannels(
            _channels.isNotEmpty ? _channels : _cachedChannels,
          ),
        );
      }
      notifyListeners();
    }
  }

  Future<void> setChannelSmazEnabled(int channelIndex, bool enabled) async {
    _channelSmazEnabled[channelIndex] = enabled;
    if (!_isDemoMode) {
      await _channelSettingsStore.saveSmazEnabled(channelIndex, enabled);
    }
    notifyListeners();
  }

  Future<void> setContactSmazEnabled(String contactKeyHex, bool enabled) async {
    _contactSmazEnabled[contactKeyHex] = enabled;
    if (!_isDemoMode) {
      await _contactSettingsStore.saveSmazEnabled(contactKeyHex, enabled);
    }
    notifyListeners();
  }

  Future<void> _loadChannelOrder() async {
    _channelOrder = await _channelOrderStore.loadChannelOrder();
    _applyChannelOrder();
    notifyListeners();
  }

  /// Load persisted channel messages for a specific channel
  Future<void> _loadChannelMessages(int channelIndex) async {
    if (_loadedChannelIndexes.contains(channelIndex) ||
        _loadingChannelIndexes.contains(channelIndex)) {
      return;
    }
    _loadingChannelIndexes.add(channelIndex);

    try {
      await _historyPersistChain;
      final diskMessages = await _channelMessageStore.loadChannelMessages(
        channelIndex,
      );
      final liveMessages = _channelMessages[channelIndex] ?? [];
      final merged = mergeChannelMessages(diskMessages, liveMessages);
      if (merged.isNotEmpty) {
        final windowedMessages = windowNewest(merged, _messageWindowSize);
        final olderCount = merged.length - windowedMessages.length;
        _olderChannelCounts[channelIndex] = olderCount;
        _channelMessages[channelIndex] = windowedMessages;
        _resolvePendingChannelReactions(channelIndex);
        _resolvePendingChannelEdits(channelIndex);
        _loadedChannelIndexes.add(channelIndex);
        final history = [...merged.take(olderCount), ...windowedMessages];
        await _queueHistoryWrite(
          () => _channelMessageStore.saveChannelMessages(channelIndex, history),
        );
      } else {
        _loadedChannelIndexes.add(channelIndex);
      }
      notifyListeners();
    } finally {
      _loadingChannelIndexes.remove(channelIndex);
    }
  }

  /// Load older channel messages (pagination)
  Future<List<ChannelMessage>> loadOlderChannelMessages(
    int channelIndex, {
    int count = 50,
  }) async {
    if (_isDemoMode) return const [];
    await _historyPersistChain;
    final allMessages = await _channelMessageStore.loadChannelMessages(
      channelIndex,
    );
    final currentMessages = _channelMessages[channelIndex] ?? [];
    final olderCount = _olderChannelCounts[channelIndex] ?? 0;

    final olderMessages = olderMessagePage(
      allMessages,
      allMessages.length - olderCount,
      count: count,
    );
    if (olderMessages.isEmpty) return const [];

    // Prepend to current conversation
    _olderChannelCounts[channelIndex] = olderCount - olderMessages.length;
    _channelMessages[channelIndex] = [...olderMessages, ...currentMessages];
    notifyListeners();

    return olderMessages;
  }

  /// Load all persisted channel messages on startup
  Future<void> loadAllChannelMessages({int? maxChannels}) async {
    await _removePersistedDemoHistory();
    final channelCount = maxChannels ?? _maxChannels;
    // Load messages for all known channels (0-7 by default)
    for (int i = 0; i < channelCount; i++) {
      await _loadChannelMessages(i);
    }
  }

  static const String _demoHistoryCleanupKey = 'demo_history_cleanup_v1';

  /// Removes sample history that older builds could accidentally save when a
  /// demo session interacted with a channel. A channel must contain several
  /// known sample messages before anything is removed, so a real on-air
  /// message that happens to match one phrase is retained.
  Future<void> _removePersistedDemoHistory() async {
    final prefs = PrefsManager.instance;
    if (prefs.getBool(_demoHistoryCleanupKey) == true) return;

    const demoChannelTexts = <String>{
      'Good evening from Gulfport harbor.',
      'Copy in Gulf Breeze, FL — 4 hops.',
      'Hi from Pearl River, LA.',
      'Lots of traffic tonight.',
      'Heard Baton Rouge, LA.',
      'Good morning from Panama City!',
      'Mega ducting. Florida to Texas.',
      'Gulf County Meshcore uses 3 byte routing and regions us-fl-gulf for local traffic.',
      'Popular local channels can be found by sending /info.',
      'Good evening from Port St. Joe, FL.',
      'Happy Sunday Mesh!',
      'The shelter is open; volunteers are on site this evening.',
      'Test from Navasota TX.',
      'Received in North San Antonio.',
      'Hello Texas.',
      'Ping — propagation test.',
      'Test from St. Helena, Louisiana.',
      'Got you in Gulf Breeze, FL.',
      'PONG! path=2cc1,d480 hops=2 region=none Port Saint Joe, FL.',
      'Test from Mandeville.',
      'G:cSfkdR9w2CSI3atokL',
      'Got you 7 hops into 70817.',
      'WX ALERT: Rip Current Statement Coastal Gulf.',
      'Radar is showing a line of thunderstorms moving south.',
      'WX 70763',
      '☀️ New Orleans, LA 70131 — Clear, humid, and hot.',
      'Extreme heat warning for southeast Louisiana and south Mississippi.',
      'OWX 32456 Port Saint Joe: 90F broken clouds.',
      'Weather 70583',
      'The rain has come to Picayune.',
      'NWS just put out a severe thunderstorm warning north of Baton Rouge.',
      'WX CLEAR: Heat Advisory.',
      'Downtown NOLA.',
      'Anyone getting me?',
      'Got you in Napoleonville.',
      'Yep, in Picayune, MS.',
      'Test from the south side of Slidell.',
      'Covington.',
      'Test test test.',
      'Received in Picayune.',
      'Testing for local observer.',
      'Test 15:49.',
      'Good morning everyone! Conditions are clear along the coast today.',
      'Anyone heading out to the delta? Could use a relay check.',
      'Storm system moving in tomorrow, everyone stay safe.',
      'BayouRelay_1 is back online after maintenance.',
      'Water levels are normal at the monitoring station.',
      'Heading out for a supply run, will be off-grid for 2 hours.',
      'Copy that, let us know when you are back.',
      'New repeater installed near Baton Rouge, signal is strong.',
      'Weather update: winds shifting to 20mph from the south.',
      'Thanks for the update CoastalNode!',
      'Fishing boats reporting good conditions off the coast.',
      'Emergency test scheduled for tomorrow at noon.',
      'All nodes check in please.',
      'RidgeRelay reporting in, all systems nominal.',
      'DeltaRepeater here, solar panels charging well.',
    };

    for (final key in prefs.getKeys()) {
      if (!key.startsWith('channel_messages_')) continue;
      final index = int.tryParse(key.substring('channel_messages_'.length));
      if (index == null) continue;
      final messages = await _channelMessageStore.loadChannelMessages(index);
      final matchCount = messages
          .where((message) => demoChannelTexts.contains(message.text))
          .length;
      if (matchCount < 3) continue;

      final retained = messages
          .where((message) => !demoChannelTexts.contains(message.text))
          .toList();
      if (retained.isEmpty) {
        await _channelMessageStore.clearChannelMessages(index);
      } else {
        await _channelMessageStore.saveChannelMessages(index, retained);
      }
    }

    // Demo contacts use deterministic public keys, so their cached contacts
    // and direct-message histories can be discarded without affecting a real
    // device's contact list.
    final demoContactKeys = _demoContactKeyHexes();
    final cachedContacts = await _contactStore.loadContacts();
    final retainedContacts = cachedContacts
        .where((contact) => !demoContactKeys.contains(contact.publicKeyHex))
        .toList();
    if (retainedContacts.length != cachedContacts.length) {
      await _contactStore.saveContacts(retainedContacts);
    }
    for (final key in demoContactKeys) {
      await _messageStore.clearMessages(key);
    }

    final cachedChannels = await _channelStore.loadChannels();
    final cachedNames = cachedChannels
        .where((channel) => channel.name.isNotEmpty)
        .map((channel) => channel.name)
        .toSet();
    const currentDemoChannels = {
      'Public',
      '#test',
      '#weather',
      '#repeater-testing',
    };
    const legacyDemoChannels = {
      'Public',
      '#emergency',
      '#weather',
      '#gulfcoast',
    };
    if (cachedNames.containsAll(currentDemoChannels) ||
        cachedNames.containsAll(legacyDemoChannels)) {
      await _channelStore.saveChannels(const []);
    }

    await prefs.setBool(_demoHistoryCleanupKey, true);
  }

  Set<String> _demoContactKeyHexes() {
    return {
      for (var i = 0; i < 10; i++)
        pubKeyToHex(
          Uint8List.fromList(
            List<int>.generate(32, (j) => ((i + 1) * 11 + j * 3) & 0xFF),
          ),
        ),
    };
  }

  void initialize({
    required MessageRetryService retryService,
    required PathHistoryService pathHistoryService,
    AppSettingsService? appSettingsService,
    FrameDebugLogService? frameDebugLogService,
    AppDebugLogService? appDebugLogService,
    BackgroundService? backgroundService,
    BlockedNodesService? blockedNodesService,
  }) {
    attachBlockedNodesService(blockedNodesService);
    _retryService = retryService;
    _pathHistoryService = pathHistoryService;
    _attachAppSettingsService(appSettingsService);
    _frameDebugLogService = frameDebugLogService;
    _appDebugLogService = appDebugLogService;
    _backgroundService = backgroundService;

    // Initialize notification service
    _notifications.initialize();
    _loadChannelOrder();
    WidgetsBinding.instance.addObserver(this);
    _observingLifecycle = true;

    // Initialize retry service callbacks
    _retryService?.initialize(
      sendMessageCallback: _sendMessageDirect,
      addMessageCallback: _addMessage,
      updateMessageCallback: _updateMessage,
      clearContactPathCallback: clearContactPath,
      setContactPathCallback: setContactPath,
      calculateTimeoutCallback: (pathLength, messageBytes) =>
          calculateTimeout(pathLength: pathLength, messageBytes: messageBytes),
      getSelfPublicKeyCallback: () => _selfPublicKey,
      prepareContactOutboundTextCallback: prepareContactOutboundText,
      appSettingsService: appSettingsService,
      debugLogService: _appDebugLogService,
      recordPathResultCallback: _recordPathResult,
    );
  }

  Future<void> loadContactCache() async {
    await _removePersistedDemoHistory();
    final cached = await _contactStore.loadContacts();
    _contactLocalByKey
      ..clear()
      ..addEntries(
        cached.map(
          (c) => MapEntry(c.publicKeyHex, ContactLocalState.fromContact(c)),
        ),
      );
    _knownContactKeys
      ..clear()
      ..addAll(cached.map((c) => c.publicKeyHex));
    for (final contact in cached) {
      _ensureContactSmazSettingLoaded(contact.publicKeyHex);
    }
  }

  void _rememberContactLocal(Contact contact) {
    _contactLocalByKey[contact.publicKeyHex] = ContactLocalState.fromContact(
      contact,
    );
  }

  Contact _mergeWithLocalContactFields(Contact device, {Contact? existing}) {
    final merged = mergeContactLocalFields(
      device,
      existing: existing,
      local: _contactLocalByKey[device.publicKeyHex],
    );
    _rememberContactLocal(merged);
    return merged;
  }

  Future<void> _queueHistoryWrite(Future<void> Function() write) {
    final result = _historyPersistChain.then((_) => write());
    // A failed write must not prevent subsequent saves or loads.
    _historyPersistChain = result.catchError((Object _) {});
    return result;
  }

  Future<void> _saveConversationMessages(
    String contactKeyHex,
    List<Message> messages,
  ) async {
    if (_isDemoMode) return;
    if (!_loadedConversationKeys.contains(contactKeyHex)) {
      await _loadMessagesForContact(contactKeyHex);
      return;
    }
    final window = List<Message>.of(messages);
    final olderCount = _olderConversationCounts[contactKeyHex] ?? 0;
    await _queueHistoryWrite(() async {
      final older = olderCount == 0
          ? <Message>[]
          : (await _messageStore.loadMessages(contactKeyHex)).take(olderCount);
      await _messageStore.saveMessages(contactKeyHex, [...older, ...window]);
    });
  }

  Future<void> _saveChannelMessages(
    int channelIndex,
    List<ChannelMessage> messages,
  ) async {
    if (_isDemoMode) return;
    if (!_loadedChannelIndexes.contains(channelIndex)) {
      await _loadChannelMessages(channelIndex);
      return;
    }
    final window = List<ChannelMessage>.of(messages);
    final olderCount = _olderChannelCounts[channelIndex] ?? 0;
    await _queueHistoryWrite(() async {
      final older = olderCount == 0
          ? <ChannelMessage>[]
          : (await _channelMessageStore.loadChannelMessages(
              channelIndex,
            )).take(olderCount);
      await _channelMessageStore.saveChannelMessages(channelIndex, [
        ...older,
        ...window,
      ]);
    });
  }

  Future<void> loadChannelSettings({int? maxChannels}) async {
    _channelSmazEnabled.clear();
    _channelRegionScope.clear();
    final channelCount = maxChannels ?? _maxChannels;
    for (int i = 0; i < channelCount; i++) {
      _channelSmazEnabled[i] = await _channelSettingsStore.loadSmazEnabled(i);
      _channelRegionScope[i] = await _channelSettingsStore.loadRegionScope(i);
    }
    notifyListeners();
  }

  /// Ensure session flood-scope override matches [channel]'s saved scope.
  Future<void> _applyChannelFloodScope(Channel channel) async {
    if (!isConnected || _activeTransport == null) return;

    final scope = _channelRegionScope[channel.index];
    if (scope == null || scope.isEmpty) {
      if (_sessionFloodScopeName == null) return;
      await sendFrame(buildClearFloodScopeKeyFrame());
      _sessionFloodScopeName = null;
      return;
    }

    if (_sessionFloodScopeName == scope) return;
    final key = MeshRegion.deriveFloodScopeKey(scope);
    await sendFrame(buildSetFloodScopeKeyFrame(key));
    _sessionFloodScopeName = scope;
  }

  Future<void> _sendMessageDirect(
    Contact contact,
    String text,
    int attempt,
    int timestampSeconds,
  ) async {
    if (text.isEmpty) return;
    if (!isConnected) {
      throw StateError('Not connected to a MeshCore device');
    }
    final outboundText = prepareContactOutboundText(contact, text);
    await sendFrame(
      buildSendTextMsgFrame(
        contact.publicKey,
        outboundText,
        attempt: attempt,
        timestampSeconds: timestampSeconds,
      ),
    );
  }

  void _updateMessage(Message message) {
    final contactKey = pubKeyToHex(message.senderKey);
    final isControlMessage =
        ReactionHelper.parseAnyReaction(message.text) != null ||
        EditHelper.parseEditText(message.text) != null;
    if (isControlMessage &&
        message.isOutgoing &&
        (message.status == MessageStatus.sent ||
            message.status == MessageStatus.delivered)) {
      _addMessage(contactKey, message);
      return;
    }
    final messages = _conversations[contactKey];
    if (messages != null) {
      final index = messages.indexWhere(
        (m) => m.messageId == message.messageId,
      );
      if (index != -1) {
        messages[index] = message;
        _saveConversationMessages(contactKey, messages);
        notifyListeners();
      }
    }
  }

  void _recordPathResult(
    String contactPubKeyHex,
    PathSelection selection,
    bool success,
    int? tripTimeMs,
  ) {
    if (_isDemoMode) return;
    if (_pathHistoryService == null) return;
    _pathHistoryService!.recordPathResult(
      contactPubKeyHex,
      selection,
      success: success,
      tripTimeMs: tripTimeMs,
    );
  }

  Contact _applyAutoSelection(Contact contact, PathSelection? selection) {
    if (selection == null ||
        selection.useFlood ||
        selection.pathBytes.isEmpty) {
      return contact;
    }

    return Contact(
      publicKey: contact.publicKey,
      name: contact.name,
      type: contact.type,
      pathLength: selection.hopCount >= 0
          ? selection.hopCount
          : contact.pathLength,
      path: Uint8List.fromList(selection.pathBytes),
      latitude: contact.latitude,
      longitude: contact.longitude,
      lastSeen: contact.lastSeen,
      lastMessageAt: contact.lastMessageAt,
      isFavorite: contact.isFavorite,
      firstSeenAt: contact.firstSeenAt,
    );
  }

  int _beginDiscoveryMirror(MeshCoreTransport transport) {
    final generation = ++_discoveryGeneration;
    _discoveryTransport = transport;
    unawaited(_discoveryStateSubscription?.cancel());
    unawaited(_discoveryUpdatesSubscription?.cancel());
    _discoveryStateSubscription = transport.stateChanges.listen((state) {
      if (generation != _discoveryGeneration) return;
      if (_activeTransport != null &&
          (_state == MeshCoreConnectionState.connected ||
              _state == MeshCoreConnectionState.connecting ||
              _state == MeshCoreConnectionState.disconnecting)) {
        return;
      }
      _setState(state);
    });
    _discoveryUpdatesSubscription = transport.discoveryUpdates.listen((_) {
      if (generation == _discoveryGeneration) notifyListeners();
    });
    _setState(transport.state);
    return generation;
  }

  void _endDiscoveryMirror(MeshCoreTransport transport, int generation) {
    // An old enumeration can finish after the user has selected another
    // transport, or even restarted discovery on the same transport.
    if (generation != _discoveryGeneration ||
        _discoveryTransport != transport) {
      return;
    }
    _discoveryGeneration++;
    unawaited(_discoveryStateSubscription?.cancel());
    _discoveryStateSubscription = null;
    unawaited(_discoveryUpdatesSubscription?.cancel());
    _discoveryUpdatesSubscription = null;
    _discoveryTransport = null;
    if (_activeTransport == null &&
        _state != MeshCoreConnectionState.connected &&
        _state != MeshCoreConnectionState.connecting) {
      _setState(transport.state);
    }
  }

  Future<void> startDiscovery(
    MeshCoreTransportKind kind, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_disposed || _isDemoMode) return;
    final transport = _transportFor(kind);
    if (transport.state == MeshCoreConnectionState.scanning) return;
    if (isConnected || _state == MeshCoreConnectionState.connecting) return;

    final generation = _beginDiscoveryMirror(transport);

    try {
      await transport.startDiscovery(timeout: timeout);
    } finally {
      _endDiscoveryMirror(transport, generation);
    }
  }

  Future<void> stopDiscovery(MeshCoreTransportKind kind) async {
    final transport = _transportFor(kind);
    final ownsDiscovery = _discoveryTransport == transport;
    if (ownsDiscovery) {
      // Invalidate before awaiting stop so a pending start cannot reattach
      // listeners while this transport is being left behind.
      _endDiscoveryMirror(transport, _discoveryGeneration);
    }
    final generation = _discoveryGeneration;
    try {
      await transport.stopDiscovery();
    } finally {
      if (ownsDiscovery &&
          generation == _discoveryGeneration &&
          _activeTransport == null &&
          _state != MeshCoreConnectionState.connecting) {
        _setState(transport.state);
      }
    }
  }

  /// Used before connecting: whichever transport the user was browsing, its
  /// scan must not keep running underneath the new session.
  Future<void> stopAllDiscovery() async {
    for (final kind in _transports.keys) {
      await stopDiscovery(kind);
    }
  }

  Future<void> connect(
    MeshCoreDevice device, {
    String? displayName,
    bool isReconnect = false,
  }) async {
    // A tap while a teardown is finishing should wait, not error out.
    final pendingDisconnect = _disconnectOp;
    if (pendingDisconnect != null) {
      await pendingDisconnect.future;
    }
    if (_state == MeshCoreConnectionState.connecting ||
        _state == MeshCoreConnectionState.connected) {
      throw StateError('connect() called while already ${_state.name}');
    }

    await stopAllDiscovery();

    final transport = _transportFor(device.transportKind);

    _deviceId = device.id;
    _deviceDisplayName = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : device.displayName;
    _lastDevice = device;
    _activeTransportKind = device.transportKind;
    _manualDisconnect = false;
    _handlingUnexpectedDisconnect = false;
    // User-initiated connects must prove themselves healthy again; a stale
    // flag from an older session would let a failed first connect
    // background-retry against the plan. An automatic background retry must
    // NOT clear the give-up flag here — otherwise the foreground UI (the
    // reconnecting pill, hub-vs-scanner navigation) flips back and forth on
    // every backoff cycle instead of staying stably "gave up" until a retry
    // actually succeeds (see the success path that clears it below).
    if (!isReconnect) {
      _hadHealthySession = false;
      _reconnectGaveUp = false;
    }
    _connectGeneration++;
    _awaitingSelfInfo = false;
    _didInitialQueueSync = false;
    _pendingQueueSync = false;
    _hasLoadedChannels = false;
    // Reconnect must keep backoff; user-initiated connects reset it.
    _cancelReconnectTimer(resetAttempts: !isReconnect);
    // Surface connecting immediately so double-taps hit the StateError guard.
    _setState(MeshCoreConnectionState.connecting);
    // Every transport needs the isolate alive in the background, not just
    // BLE — a USB stream or TCP socket dies with the process just the same.
    await _ensureBackgroundKeepAlive(isReconnect: isReconnect);
    notifyListeners();

    _bindTransport(transport);

    try {
      await transport.connect(device, isReconnect: isReconnect);

      await _requestDeviceInfo();
      _startBatteryPolling();
      final gotSelfInfo = await _waitForSelfInfo(
        timeout: const Duration(seconds: 3),
      );
      if (!gotSelfInfo) {
        await refreshDeviceInfo();
        final retried = await _waitForSelfInfo(
          timeout: const Duration(seconds: 5),
        );
        if (!retried) {
          throw Exception('MeshCore device did not send self-info');
        }
      }

      await syncTime();
      unawaited(getChannels(force: true).catchError((_) {}));
    } catch (e) {
      debugPrint('Connection error: $e');
      // Only auto-retry after a previously healthy session (link drop recovery).
      // Failed first connects must not background-hammer the radio.
      final allowAutoReconnect = _hadHealthySession;
      await disconnect(manual: !allowAutoReconnect, immediate: true);
      rethrow;
    }
  }

  void _bindTransport(MeshCoreTransport transport) {
    _transportFrameSubscription?.cancel();
    _transportStateSubscription?.cancel();
    _activeTransport = transport;
    // Preserve connector `connecting` if we already set it; otherwise mirror.
    if (_state != MeshCoreConnectionState.connecting) {
      _setState(transport.state);
    }
    _transportFrameSubscription = transport.incomingFrames.listen(_handleFrame);
    _transportStateSubscription = transport.stateChanges.listen((state) {
      if (_activeTransport != transport) return;

      if (shouldHandleUnexpectedDisconnect(
        manualDisconnect: _manualDisconnect,
        alreadyHandling: _handlingUnexpectedDisconnect,
        connectorStateName: _state.name,
        transportStateName: state.name,
      )) {
        _handlingUnexpectedDisconnect = true;
        unawaited(_handleDisconnection());
        return;
      }

      // Ignore redundant disconnecting/disconnected after we've torn down.
      if (_handlingUnexpectedDisconnect &&
          (state == MeshCoreConnectionState.disconnecting ||
              state == MeshCoreConnectionState.disconnected)) {
        return;
      }

      _setState(state);
    });
  }

  Future<bool> _waitForSelfInfo({required Duration timeout}) async {
    final generation = _connectGeneration;
    bool isFresh() => isSelfInfoFresh(
      connectGeneration: generation,
      lastSelfInfoGeneration: _lastSelfInfoGeneration,
    );
    if (isFresh()) return true;
    if (!isConnected) return false;

    final completer = Completer<bool>();
    late final VoidCallback listener;
    listener = () {
      if (isFresh()) {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      } else if (!isConnected) {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      }
    };
    addListener(listener);

    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    final result = await completer.future;
    timer.cancel();
    removeListener(listener);
    return result;
  }

  // Note: intentionally not gated on `_reconnectGaveUp` — that flag only
  // controls foreground UI (reconnecting pill, hub-vs-scanner navigation).
  // Background retries must keep going after it flips, or an overnight BLE
  // drop that outlasts the give-up window would silently kill the
  // foreground service and never reconnect until the app is reopened.
  bool get _shouldAutoReconnect =>
      !_manualDisconnect && _lastDevice != null && _hadHealthySession;

  void _cancelReconnectTimer({bool resetAttempts = true}) {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (resetAttempts) {
      _reconnectAttempts = 0;
    }
  }

  int _nextReconnectDelayMs() {
    final attempt = _reconnectAttempts < 6 ? _reconnectAttempts : 6;
    _reconnectAttempts += 1;
    final delayMs = 1000 * (1 << attempt);
    return delayMs > 30000 ? 30000 : delayMs;
  }

  void _scheduleReconnect({bool immediate = false}) {
    if (!_shouldAutoReconnect) return;
    if (_reconnectTimer?.isActive == true) return;
    // Past the give-up threshold, keep retrying at the capped backoff
    // forever instead of stopping — see _giveUpReconnect.
    if (!immediate &&
        _reconnectAttempts >= _maxReconnectAttempts &&
        !_reconnectGaveUp) {
      _giveUpReconnect();
    }

    final delayMs = immediate ? 0 : _nextReconnectDelayMs();
    debugPrint(
      'BLE reconnect: scheduling attempt $_reconnectAttempts in ${delayMs}ms',
    );
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () async {
      if (!_shouldAutoReconnect) return;
      if (_state == MeshCoreConnectionState.connecting ||
          _state == MeshCoreConnectionState.connected) {
        return;
      }

      final device = _lastDevice;
      if (device == null) return;

      try {
        await connect(
          device,
          displayName: _deviceDisplayName,
          isReconnect: true,
        );
      } catch (_) {
        _scheduleReconnect();
      }
    });
  }

  void _giveUpReconnect() {
    debugPrint(
      'BLE reconnect: UI giving up after $_maxReconnectAttempts attempts '
      '(background retries continue at capped backoff)',
    );
    _reconnectGaveUp = true;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!shouldReconnectOnResume(
      manualDisconnect: _manualDisconnect,
      hadHealthySession: _hadHealthySession,
      hasLastDevice: _lastDevice != null,
      connectorStateName: _state.name,
    )) {
      return;
    }
    _reconnectGaveUp = false;
    _cancelReconnectTimer(resetAttempts: true);
    _scheduleReconnect(immediate: true);
  }

  Future<void> disconnect({bool manual = true, bool immediate = false}) async {
    if (_isDemoMode) {
      await exitDemoMode();
      return;
    }
    final inFlight = _disconnectOp;
    if (inFlight != null) {
      if (manual) {
        _manualDisconnect = true;
        _hadHealthySession = false;
        _reconnectGaveUp = false;
        _cancelReconnectTimer(resetAttempts: true);
        unawaited(_backgroundService?.stop());
      }
      await inFlight.future;
      if (manual) {
        _clearSessionForManualDisconnect();
        if (_state != MeshCoreConnectionState.disconnected) {
          _setState(MeshCoreConnectionState.disconnected);
        }
        notifyListeners();
      }
      return;
    }

    if (_state == MeshCoreConnectionState.disconnected &&
        _activeTransport == null) {
      if (manual) {
        _manualDisconnect = true;
        _hadHealthySession = false;
        _reconnectGaveUp = false;
        _cancelReconnectTimer(resetAttempts: true);
        unawaited(_backgroundService?.stop());
        _clearSessionForManualDisconnect();
        notifyListeners();
      }
      return;
    }

    final op = Completer<void>();
    _disconnectOp = op;
    try {
      if (manual) {
        _manualDisconnect = true;
        _hadHealthySession = false;
        _reconnectGaveUp = false;
        _handlingUnexpectedDisconnect = false;
        _cancelReconnectTimer(resetAttempts: true);
        unawaited(_backgroundService?.stop());
      } else {
        _manualDisconnect = false;
        _didInitialQueueSync = false;
        _pendingQueueSync = false;
        _hasLoadedChannels = false;
      }
      if (_state != MeshCoreConnectionState.disconnecting) {
        _setState(MeshCoreConnectionState.disconnecting);
      }
      _stopBatteryPolling();

      for (final entry in _pendingRepeaterAcks.values) {
        entry.timeout?.cancel();
      }
      _pendingRepeaterAcks.clear();

      await _transportFrameSubscription?.cancel();
      _transportFrameSubscription = null;
      await _transportStateSubscription?.cancel();
      _transportStateSubscription = null;

      try {
        await _activeTransport?.disconnect(immediate: immediate);
      } catch (e) {
        debugPrint('Transport disconnect error: $e');
      }
      _activeTransport = null;

      _selfInfoRetryTimer?.cancel();
      _selfInfoRetryTimer = null;
      _queueSyncTimeout?.cancel();
      _queueSyncTimeout = null;
      _queueSyncRetries = 0;
      _channelSyncTimeout?.cancel();
      _channelSyncTimeout = null;
      _channelSyncRetries = 0;

      _sessionFloodScopeName = null;
      _batteryRequested = false;
      _awaitingSelfInfo = false;
      _maxContacts = _defaultMaxContacts;
      _maxChannels = _defaultMaxChannels;
      _isSyncingQueuedMessages = false;
      _queuedMessageSyncInFlight = false;
      _pendingQueueSync = false;
      _isSyncingChannels = false;
      _channelSyncInFlight = false;
      _failAllPendingChannelMessages();
      _pendingGenericAckQueue.clear();
      _pendingCompanionCliSents = 0;
      _completePendingDeviceQueries();
      _reactionSendQueueSequence = 0;

      if (_manualDisconnect) {
        _clearSessionForManualDisconnect();
      }

      _setState(MeshCoreConnectionState.disconnected);
      if (!_manualDisconnect) {
        _scheduleReconnect();
      }
    } finally {
      if (!op.isCompleted) op.complete();
      if (identical(_disconnectOp, op)) {
        _disconnectOp = null;
      }
    }
  }

  void _clearSessionForManualDisconnect() {
    _activeTransportKind = null;
    _deviceDisplayName = null;
    _deviceId = null;
    _lastDevice = null;
    _contacts.clear();
    _conversations.clear();
    _olderConversationCounts.clear();
    _loadedConversationKeys.clear();
    _loadingConversationKeys.clear();
    _channels.clear();
    _channelMessages.clear();
    _olderChannelCounts.clear();
    _pendingContactReactions.clear();
    _pendingChannelReactions.clear();
    _processedContactReactions.clear();
    _processedChannelReactions.clear();
    _pendingContactEdits.clear();
    _pendingChannelEdits.clear();
    _processedContactEdits.clear();
    _processedChannelEdits.clear();
    _loadedChannelIndexes.clear();
    _loadingChannelIndexes.clear();
    _selfPublicKey = null;
    _selfName = null;
    _selfLatitude = null;
    _selfLongitude = null;
    _clientRepeat = null;
    _firmwareVerCode = null;
    _devicePathHashMode = null;
    _supportsPathHashMode = false;
    _defaultFloodScopeName = null;
    _batteryMillivolts = null;
    _repeaterBatterySnapshots.clear();
    _hasLoadedChannels = false;
    _didInitialQueueSync = false;
  }

  void _cancelAllChannelSendTimeouts() {
    for (final timer in _channelSendTimeouts.values) {
      timer.cancel();
    }
    _channelSendTimeouts.clear();
  }

  void _failAllPendingChannelMessages() {
    final pending = List<String>.from(_pendingChannelSentQueue);
    _pendingChannelSentQueue.clear();
    for (final queueId in pending) {
      if (!_isReactionSendQueueId(queueId)) {
        _markPendingChannelMessageFailedById(queueId);
      }
    }
    _pendingOutgoingChannelReactions.clear();
    _cancelAllChannelSendTimeouts();
  }

  void _completePendingDeviceQueries() {
    final noiseFloor = _noiseFloorCompleter;
    if (noiseFloor != null && !noiseFloor.isCompleted) {
      noiseFloor.complete(null);
    }
    _noiseFloorCompleter = null;

    final floodScope = _defaultFloodScopeCompleter;
    if (floodScope != null && !floodScope.isCompleted) {
      floodScope.complete(_defaultFloodScopeName);
    }
    _defaultFloodScopeCompleter = null;
  }

  Future<void> sendFrame(
    Uint8List data, {
    String? channelSendQueueId,
    bool expectsGenericAck = false,
    void Function(bool success)? completion,
  }) async {
    if (_disposed) {
      throw StateError('MeshCoreConnector has been disposed');
    }
    if (!isConnected || (!_isDemoMode && _activeTransport == null)) {
      throw Exception('Not connected to a MeshCore device');
    }
    // The companion rejects anything larger, and only the byte-stream
    // transports framed it themselves, so BLE silently wrote oversized frames
    // while USB/TCP threw. Enforce it once here so every transport agrees.
    if (data.length > maxFrameSize) {
      throw StateError(
        'Frame of ${data.length} bytes exceeds the $maxFrameSize byte limit',
      );
    }

    _frameDebugLogService?.logFrame(data, outgoing: true);
    if (_isDemoMode) {
      // In demo mode the frame is emulated on a timer, so the ACK must be
      // tracked before we return, or the pending-ACK FIFO never sees it.
      _trackPendingGenericAck(
        data,
        channelSendQueueId: channelSendQueueId,
        expectsGenericAck: expectsGenericAck,
        completion: completion,
      );
      await _emulateDemoFrame(data);
      return;
    }
    // Notifications can arrive before the transport's write future completes.
    // Reserve the slot in send order before handing the frame to the transport.
    final pendingAck = _trackPendingGenericAck(
      data,
      channelSendQueueId: channelSendQueueId,
      expectsGenericAck: expectsGenericAck,
      completion: completion,
    );
    try {
      await _activeTransport!.sendFrame(data);
    } catch (_) {
      // An actual radio reply takes precedence over a late write error.
      if (pendingAck?.responseReceived == true) return;
      if (pendingAck != null && !pendingAck.cancelled) {
        _pendingGenericAckQueue.remove(pendingAck);
      }
      rethrow;
    }
  }

  Future<void> _emulateDemoFrame(Uint8List data) async {
    if (data.isEmpty) return;
    final frame = Uint8List.fromList(data);
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (_isDemoMode) _dispatchDemoFrame(frame);
      }),
    );
  }

  void _dispatchDemoFrame(Uint8List data) {
    switch (data[0]) {
      case cmdAppStart:
        if (data.length > 1 && data[1] >= 0x20) {
          _handleFrame(
            Uint8List.fromList([respCodeSent, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
          );
        } else {
          _handleFrame(Uint8List.fromList([respCodeOk]));
        }
      case cmdSendLogin:
        if (data.length >= 33) {
          _emitDemoFrame(
            Uint8List.fromList([
              pushCodeLoginSuccess,
              0,
              ...data.sublist(1, 7),
            ]),
          );
        }
      case cmdSendStatusReq:
        if (data.length >= 33) {
          _emitDemoFrame(_demoStatusFrame(data.sublist(1, 7)));
        }
      case cmdSendTxtMsg:
        if (data.length > 13 && data[1] == txtTypeCliData) {
          _emitDemoFrame(
            _demoCliResponse(
              data.sublist(7, 13),
              readCString(data, 13, data.length - 13),
            ),
          );
        }
      case cmdSendBinaryReq:
        if (data.length > 33) {
          _emulateDemoBinaryRequest(data[33]);
        }
      case cmdSendChannelTxtMsg:
        _handleFrame(Uint8List.fromList([respCodeOk]));
        if (data.length > 7) {
          final channelIndex = data[2];
          final isWeatherApiChannel = _channels.any(
            (channel) =>
                channel.index == channelIndex &&
                channel.name
                        .trim()
                        .replaceFirst(RegExp(r'^#'), '')
                        .toLowerCase() ==
                    'wx-bot-hidden',
          );
          if (isWeatherApiChannel) {
            _emulateDemoWeather(
              readCString(data, 7, data.length - 7),
              channelIndex: channelIndex,
            );
          }
        }
      case cmdGetStats:
        _lastNoiseFloor = -112;
        final pending = _noiseFloorCompleter;
        if (pending != null && !pending.isCompleted) pending.complete(-112);
        notifyListeners();
      case cmdSetAdvertName:
        _selfName = readCString(data, 1, data.length - 1);
        _handleFrame(Uint8List.fromList([respCodeOk]));
        notifyListeners();
      default:
        _handleFrame(Uint8List.fromList([respCodeOk]));
    }
  }

  void _emulateDemoBinaryRequest(int requestType) {
    const tag = <int>[0x44, 0x45, 0x4d, 0x4f];
    _emitDemoFrame(Uint8List.fromList([respCodeSent, 0, ...tag]));
    late final Uint8List payload;
    if (requestType == reqTypeGetTelemetry) {
      payload = Uint8List.fromList([
        1, 116, 0x01, 0xa5, // 4.21 V
        1, 103, 0x00, 0xfa, // 25.0 C
        1, 104, 130, // 65% humidity
      ]);
    } else if (requestType == reqTypeGetNeighbors) {
      final neighbor = DemoData.key(2);
      final writer = BufferWriter()
        ..writeUInt16LE(1)
        ..writeUInt16LE(1)
        ..writeBytes(neighbor.sublist(0, 4))
        ..writeUInt32LE(DateTime.now().millisecondsSinceEpoch ~/ 1000)
        ..writeByte((-72) & 0xff);
      payload = writer.toBytes();
    } else {
      payload = Uint8List(0);
    }
    _emitDemoFrame(
      Uint8List.fromList([pushCodeBinaryResponse, 0, ...tag, ...payload]),
    );
  }

  void _emitDemoFrame(Uint8List frame) {
    if (!_receivedFramesController.isClosed) {
      _receivedFramesController.add(frame);
    }
    _frameDebugLogService?.logFrame(frame, outgoing: false);
  }

  Uint8List _demoStatusFrame(Uint8List prefix) {
    final frame = Uint8List(60);
    frame[0] = pushCodeStatusResponse;
    frame.setRange(2, 8, prefix);
    final data = ByteData.sublistView(frame, 8);
    data.setUint16(0, 4210, Endian.little);
    data.setUint16(2, 2, Endian.little);
    data.setInt16(4, -112, Endian.little);
    data.setInt16(6, -76, Endian.little);
    data.setUint32(8, 18432, Endian.little);
    data.setUint32(12, 17690, Endian.little);
    data.setUint32(16, 4218, Endian.little);
    data.setUint32(20, 345678, Endian.little);
    data.setUint32(24, 9102, Endian.little);
    data.setUint32(28, 8588, Endian.little);
    data.setUint32(32, 9521, Endian.little);
    data.setUint32(36, 8911, Endian.little);
    data.setInt16(42, 31, Endian.little);
    data.setUint16(44, 19, Endian.little);
    data.setUint16(46, 27, Endian.little);
    data.setUint32(48, 3980, Endian.little);
    return frame;
  }

  Uint8List _demoCliResponse(Uint8List prefix, String framedCommand) {
    final token = framedCommand.length >= 3
        ? framedCommand.substring(0, 3)
        : '';
    final command = framedCommand.length >= 3
        ? framedCommand.substring(3).trim().toLowerCase()
        : framedCommand.trim().toLowerCase();
    final response = switch (command) {
      'ver' => '$token MeshCore Repeater v1.12.0-demo',
      'get telemetry' || 'telemetry' =>
        '$token{"battery_mv":4210,"uptime_secs":345678,"queue_len":2,"errors":0}',
      'neighbors' ||
      'get neighbors' => '$token CoastalNode,-72,8.5\nDeltaWX,-89,4.0',
      _ => '$token OK (demo): $command',
    };
    final encoded = utf8.encode(response);
    final frame = Uint8List(14 + encoded.length);
    frame[0] = respCodeContactMsgRecv;
    frame.setRange(1, 7, prefix);
    frame[7] = 0;
    frame[8] = txtTypeCliData;
    final stamp = ByteData(4)
      ..setUint32(
        0,
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        Endian.little,
      );
    frame.setRange(9, 13, stamp.buffer.asUint8List());
    frame.setRange(13, 13 + encoded.length, encoded);
    return frame;
  }

  void _emulateDemoWeather(
    String request, {
    Contact? dmContact,
    int? channelIndex,
  }) {
    if (request.trim().toLowerCase().endsWith(' api2')) {
      final replies = demoWeatherApi2Replies(request, dm: dmContact != null);
      for (var i = 0; i < replies.length; i++) {
        Future<void>.delayed(Duration(milliseconds: 180 * (i + 1)), () {
          if (!_isDemoMode) return;
          if (dmContact != null) {
            _addMessage(
              dmContact.publicKeyHex,
              Message(
                senderKey: dmContact.publicKey,
                text: replies[i],
                timestamp: DateTime.now(),
                isOutgoing: false,
              ),
            );
          } else {
            _addChannelMessage(
              channelIndex!,
              ChannelMessage(
                senderKey: DemoData.key(4),
                senderName: 'DeltaWX',
                text: replies[i],
                timestamp: DateTime.now(),
                isOutgoing: false,
                status: ChannelMessageStatus.sent,
                channelIndex: channelIndex,
              ),
            );
          }
          notifyListeners();
        });
      }
      return;
    }
    final lower = request.trim().toLowerCase();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final data = lower == 'bot json api'
        ? <String, dynamic>{'k': 'b', 'cmd': 2}
        : <String, dynamic>{
            'k': 'w',
            'z': RegExp(r'\b\d{5}\b').firstMatch(request)?.group(0) ?? '39501',
            'g': now,
            'n': [84, 2, 71, 165, 12],
            'h': [
              [60, 83, 2, 170, 13, 20],
              [120, 82, 61, 175, 14, 45],
              [180, 80, 61, 180, 12, 60],
              [240, 78, 3, 185, 9, 35],
            ],
            'a': [
              [1, 2],
            ],
            'x': false,
          };
    final envelope = jsonEncode({
      'v': 1,
      'i': 'demo-weather',
      'p': 1,
      'n': 1,
      'd': data,
    });
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (!_isDemoMode) return;
      final message = ChannelMessage(
        senderKey: DemoData.key(4),
        senderName: 'DeltaWX',
        text: envelope,
        timestamp: DateTime.now(),
        isOutgoing: false,
        status: ChannelMessageStatus.sent,
        channelIndex: 1,
      );
      _addChannelMessage(1, message);
      notifyListeners();
    });
  }

  int? get lastNoiseFloor => _lastNoiseFloor;

  /// Full radio statistics from the last CMD_GET_STATS reply: noise floor,
  /// last RSSI/SNR, and cumulative TX/RX airtime.
  RadioStats? get lastRadioStats => _lastRadioStats;

  /// Fires on every radio-stats reply, so a sampler can record history without
  /// polling the getter.
  Stream<RadioStats> get radioStats => _radioStatsController.stream;

  /// Incoming messages that passed every notification gate. Fires alongside the
  /// in-app notification, so subscribers inherit the user's mute settings.
  Stream<NotifiableMessage> get notifiableMessages =>
      _notifications.notifiableMessages;

  int? get storageUsedKb => _storageUsedKb;
  int? get storageTotalKb => _storageTotalKb;

  /// Requests a radio-stats frame without waiting for the reply. The answer
  /// arrives on [radioStats]; use [getNoiseFloor] when a value is needed inline.
  Future<void> requestRadioStats() async {
    if (!isConnected) return;
    await sendFrame(buildGetStatsFrame());
  }

  /// Reads the companion's current radio noise floor. Older firmware may not
  /// implement CMD_GET_STATS; in that case this returns null after timeout and
  /// wardriving continues without a noise-floor value.
  Future<int?> getNoiseFloor() async {
    if (!isConnected) return null;
    final pending = _noiseFloorCompleter;
    if (pending != null) return pending.future;
    final completer = Completer<int?>();
    _noiseFloorCompleter = completer;
    try {
      await sendFrame(buildGetStatsFrame());
      return await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
    } finally {
      if (identical(_noiseFloorCompleter, completer)) {
        _noiseFloorCompleter = null;
      }
    }
  }

  /// Send one SAR/custom raw payload through the companion's direct-route
  /// command.  The protocol builder performs all frame-size and path checks.
  Future<void> sendRawData({
    required Uint8List path,
    required Uint8List payload,
  }) async {
    await sendFrame(buildSendRawDataFrame(path: path, payload: payload));
  }

  /// Convenience path for media fetch/fragment packets addressed to a known
  /// contact.  Raw payloads are only sent on a concrete route; flooding these
  /// packets would create duplicate transfers and is not SAR-compatible.
  Future<bool> sendRawDataToContact(Contact contact, Uint8List payload) async {
    if (!isConnected || contact.pathLength < 0 || contact.pathLength > 3) {
      return false;
    }
    // CMD_SEND_RAW_DATA takes a literal byte count and one byte per hop. A
    // contact's discovered route may instead contain 2- or 3-byte path hashes
    // (the normal text/channel path representation), so down-sample it to the
    // SAR-compatible raw route before building the frame.
    final rawPath = rawDataPathForRoute(
      hopCount: contact.pathLength,
      path: contact.path,
      hashSizeBytes: contact.effectivePathHashSize,
    );
    await sendRawData(path: rawPath, payload: payload);
    return true;
  }

  Future<void> requestBatteryStatus({bool force = false}) async {
    if (!isConnected) return;
    if (_batteryRequested && !force) return;
    _batteryRequested = true;
    await sendFrame(buildGetBattAndStorageFrame());
  }

  void _startBatteryPolling() {
    _batteryPollTimer?.cancel();
    _batteryPollTimer = Timer.periodic(_batteryPollInterval, (timer) {
      if (!isConnected) {
        timer.cancel();
        return;
      }
      unawaited(requestBatteryStatus(force: true).catchError((_) {}));
    });
  }

  void _stopBatteryPolling() {
    _batteryPollTimer?.cancel();
    _batteryPollTimer = null;
  }

  Future<void> refreshDeviceInfo() async {
    if (!isConnected) return;
    _awaitingSelfInfo = true;
    try {
      await sendFrame(buildDeviceQueryFrame());
      await sendFrame(buildAppStartFrame());
      await requestBatteryStatus(force: true);
      await sendFrame(buildGetRadioSettingsFrame());
      await sendFrame(buildGetCustomVarsFrame());
    } catch (_) {
      // A send never reached the device, so the reply that would normally
      // clear this flag will never arrive - clear it here or it wedges
      // syncQueuedMessages() indefinitely.
      _awaitingSelfInfo = false;
      rethrow;
    }
    _scheduleSelfInfoRetry();
  }

  Future<void> _requestDeviceInfo() async {
    if (!isConnected || _awaitingSelfInfo) return;
    _awaitingSelfInfo = true;
    try {
      await sendFrame(buildDeviceQueryFrame());
      await sendFrame(buildAppStartFrame());
      await sendFrame(buildGetCustomVarsFrame());
      await requestBatteryStatus();
    } catch (_) {
      _awaitingSelfInfo = false;
      rethrow;
    }

    _scheduleSelfInfoRetry();
  }

  void _scheduleSelfInfoRetry() {
    _selfInfoRetryTimer?.cancel();
    _selfInfoRetryTimer = Timer.periodic(const Duration(milliseconds: 3500), (
      timer,
    ) {
      if (!isConnected) {
        timer.cancel();
        return;
      }
      if (!_awaitingSelfInfo) {
        timer.cancel();
        return;
      }
      unawaited(sendFrame(buildAppStartFrame()).catchError((_) {}));
    });
  }

  Future<void> getContacts({int? since, bool preserveExisting = false}) async {
    if (!isConnected) return;
    if (_isDemoMode) {
      notifyListeners();
      return;
    }

    _isLoadingContacts = true;
    _preserveContactsOnRefresh = preserveExisting;
    List<Contact>? previousContacts;
    if (!preserveExisting) {
      previousContacts = List<Contact>.of(_contacts);
      _contacts.clear();
      notifyListeners();
    }

    try {
      await sendFrame(buildGetContactsFrame(since: since));
    } catch (_) {
      // The request never reached the device, so END_OF_CONTACTS will never
      // clear the flag. Leaving it set wedges queued-message sync and blocks
      // every later contact write from being persisted.
      _isLoadingContacts = false;
      _preserveContactsOnRefresh = false;
      // Only restore if nothing else has repopulated the list in the
      // meantime (e.g. an overlapping getContacts() call that succeeded) -
      // otherwise this would clobber fresher data with our stale snapshot.
      if (previousContacts != null && _contacts.isEmpty) {
        _contacts.addAll(previousContacts);
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshContacts() async {
    await getContacts(preserveExisting: true);
  }

  Future<void> refreshContactsSinceLastmod() async {
    await getContacts(since: _latestContactLastmod(), preserveExisting: true);
  }

  /// Fire-and-forget contact refresh for opportunistic UI call sites
  /// (pull-to-refresh, "path missing" prompts) that don't want a failure to
  /// surface as an exception, but still want it visible in the debug log.
  Future<void> refreshContactsBestEffort({String tag = 'Connector'}) {
    return getContacts().catchError(
      (e) => appLogger.warn('Contact refresh failed: $e', tag: tag),
    );
  }

  Future<void> getContactByKey(Uint8List pubKey) async {
    if (!isConnected) return;
    await sendFrame(buildGetContactByKeyFrame(pubKey));
  }

  Future<void> sendMessage(Contact contact, String text) async {
    if (text.isEmpty) return;
    if (!isConnected) {
      throw StateError('Not connected to a MeshCore device');
    }

    if (_isDemoMode) {
      _addMessage(
        contact.publicKeyHex,
        Message(
          senderKey: contact.publicKey,
          text: text,
          timestamp: DateTime.now(),
          isOutgoing: true,
          status: MessageStatus.delivered,
          messageId: 'demo_${DateTime.now().microsecondsSinceEpoch}',
          pathLength: contact.pathLength,
          pathBytes: contact.path,
          deliveredAt: DateTime.now(),
          tripTimeMs: 420,
        ),
      );
      if (contact.name == 'DeltaWX') {
        _emulateDemoWeather(text, dmContact: contact);
      }
      return;
    }

    // The current UI still supplies the legacy v3 reaction token.  Resolve
    // that token against the stored target so the on-air representation is
    // MeshCore One (and, importantly, uses the target's original timestamp).
    text = _canonicalizeContactReaction(contact, text);

    // Handle auto-rotation if enabled
    PathSelection? autoSelection;
    if (_appSettingsService?.settings.autoRouteRotationEnabled == true) {
      autoSelection = _pathHistoryService?.getNextAutoPathSelection(
        contact.publicKeyHex,
      );
      if (autoSelection != null) {
        _pathHistoryService?.recordPathAttempt(
          contact.publicKeyHex,
          autoSelection,
        );
        if (!autoSelection.useFlood && autoSelection.pathBytes.isNotEmpty) {
          await setContactPath(
            contact,
            Uint8List.fromList(autoSelection.pathBytes),
            autoSelection.pathBytes.length,
          );
        }
      }
    }

    if (_retryService != null) {
      final pathBytes = _resolveOutgoingPathBytes(contact, autoSelection);
      final pathLength = _resolveOutgoingPathLength(contact, autoSelection);
      final selectedContact = _applyAutoSelection(contact, autoSelection);
      await _retryService!.sendMessageWithRetry(
        contact: selectedContact,
        text: text,
        pathSelection: autoSelection,
        pathBytes: pathBytes,
        pathLength: pathLength,
      );
    } else {
      // Fallback to old behavior if retry service not initialized
      final pathBytes = _resolveOutgoingPathBytes(contact, autoSelection);
      final pathLength = _resolveOutgoingPathLength(contact, autoSelection);
      final message = Message.outgoing(
        contact.publicKey,
        text,
        pathLength: pathLength,
        pathBytes: pathBytes,
      );
      _addMessage(contact.publicKeyHex, message);
      notifyListeners();
      final outboundText = prepareContactOutboundText(contact, text);
      await sendFrame(buildSendTextMsgFrame(contact.publicKey, outboundText));
      if (ReactionHelper.parseAnyReaction(text) != null) {
        _addMessage(
          contact.publicKeyHex,
          message.copyWith(status: MessageStatus.sent),
        );
      }
    }
  }

  /// Edit a previously sent DM message. Applies the new text locally right
  /// away, then sends an `ed:` control message so other MeshCore-compatible
  /// clients can apply the same edit. See [EditHelper].
  Future<void> editMessage(
    Contact contact,
    Message target,
    String newText,
  ) async {
    if (newText.isEmpty || !target.isOutgoing) return;
    if (!isConnected) {
      throw StateError('Not connected to a MeshCore device');
    }

    final targetTimestamp = target.timestamp.millisecondsSinceEpoch ~/ 1000;
    final editText = EditHelper.buildEditText(
      newText: newText,
      targetText: target.text,
      targetTimestamp: targetTimestamp,
    );
    final editInfo = EditHelper.parseEditText(editText)!;
    final contactKey = contact.publicKeyHex;

    final messages = _conversations[contactKey];
    if (messages != null) {
      final index = messages.indexOf(target);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          text: newText,
          edited: true,
          editedAt: DateTime.now(),
        );
        _saveConversationMessages(contactKey, messages);
        notifyListeners();
      }
    }
    // Mark this edit as already applied so the eventual send-confirmation
    // echo (routed back through _addMessage/_updateMessage) does not try to
    // match it again against the now-updated text.
    _processedContactEdits
        .putIfAbsent(contactKey, () => {})
        .add('${editInfo.targetHash}_self');

    await sendMessage(contact, editText);
  }

  void setOutgoingMessageStatus(
    Contact contact,
    Message message,
    MessageStatus status,
  ) {
    final messages = _conversations[contact.publicKeyHex];
    if (messages == null) return;
    final index = messages.indexOf(message);
    if (index == -1) return;
    messages[index] = messages[index].copyWith(status: status);
    _saveConversationMessages(contact.publicKeyHex, messages);
    notifyListeners();
  }

  Future<void> setContactPath(
    Contact contact,
    Uint8List customPath,
    int pathLen,
  ) async {
    if (!isConnected) return;

    final hashMode =
        _appSettingsService?.settings.companionPathHashMode ??
        defaultPathHashMode;
    final hashSizeBytes = pathHashBytesForMode(hashMode);
    final devicePathLen = customPath.isEmpty
        ? pathLen
        : _devicePathLengthField(customPath, hashSizeBytes, pathLen);

    await sendFrame(
      buildUpdateContactPathFrame(
        contact.publicKey,
        customPath,
        devicePathLen,
        type: contact.type,
        name: contact.name,
      ),
    );
  }

  int _devicePathLengthField(
    Uint8List pathBytes,
    int hashSizeBytes,
    int hopCount,
  ) {
    if (pathBytes.isEmpty) return hopCount;
    final hops = hopCount > 0 ? hopCount : pathBytes.length ~/ hashSizeBytes;
    if (hashSizeBytes > 1) {
      return encodePathLength(hopCount: hops, hashSizeBytes: hashSizeBytes);
    }
    return hops;
  }

  /// Set path override for a contact (persists across contact refreshes)
  /// pathLen: -1 = force flood, null = auto (use device path), >= 0 = specific path
  Future<void> setPathOverride(
    Contact contact, {
    int? pathLen,
    Uint8List? pathBytes,
  }) async {
    appLogger.info(
      'setPathOverride called for ${contact.name}: pathLen=$pathLen, bytesLen=${pathBytes?.length ?? 0}',
      tag: 'Connector',
    );

    // Find contact in list
    final index = _contacts.indexWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );
    if (index == -1) {
      appLogger.warn(
        'setPathOverride: Contact not found in list: ${contact.name}',
        tag: 'Connector',
      );
      return;
    }

    appLogger.info(
      'Found contact at index $index. Current override: ${_contacts[index].pathOverride}',
      tag: 'Connector',
    );

    // Update contact with new path override
    _contacts[index] = _contacts[index].copyWith(
      pathOverride: pathLen,
      pathOverrideBytes: pathBytes,
      clearPathOverride: pathLen == null, // Clear if pathLen is null
    );
    _rememberContactLocal(_contacts[index]);

    appLogger.info(
      'Updated contact. New override: ${_contacts[index].pathOverride}, bytesLen: ${_contacts[index].pathOverrideBytes?.length}',
      tag: 'Connector',
    );

    // Save to storage
    await _persistContacts();
    appLogger.info('Saved contacts to storage', tag: 'Connector');

    // If setting a specific path (not flood, not auto), also sync with device
    if (pathLen != null && pathLen >= 0 && pathBytes != null) {
      appLogger.info('Sending path to device...', tag: 'Connector');
      await setContactPath(contact, pathBytes, pathLen);
      appLogger.info('Path sent to device', tag: 'Connector');
    }

    debugPrint(
      'Set path override for ${contact.name}: pathLen=$pathLen, bytes=${pathBytes?.length ?? 0}',
    );
    notifyListeners();
  }

  Future<PathSelection> preparePathForContactSend(Contact contact) async {
    PathSelection? autoSelection;
    final autoRotationEnabled =
        _appSettingsService?.settings.autoRouteRotationEnabled == true;
    if (autoRotationEnabled && contact.pathOverride == null) {
      autoSelection = _pathHistoryService?.getNextAutoPathSelection(
        contact.publicKeyHex,
      );
      if (autoSelection != null) {
        _pathHistoryService?.recordPathAttempt(
          contact.publicKeyHex,
          autoSelection,
        );
      }
    }

    final pathBytes = _resolveOutgoingPathBytes(contact, autoSelection);
    final pathLength = _resolveOutgoingPathLength(contact, autoSelection) ?? -1;

    if (pathLength < 0) {
      await clearContactPath(contact);
    } else {
      await setContactPath(contact, pathBytes, pathLength);
    }

    return _selectionFromPath(pathLength, pathBytes);
  }

  void trackRepeaterAck({
    required Contact contact,
    required PathSelection selection,
    required String text,
    required int timestampSeconds,
    int attempt = 0,
  }) {
    final selfKey = _selfPublicKey;
    if (selfKey == null) return;
    // Use transformed text to match device's ACK hash computation
    final outboundText = prepareContactOutboundText(contact, text);
    final ackHash = MessageRetryService.computeExpectedAckHash(
      timestampSeconds,
      attempt,
      outboundText,
      selfKey,
    );
    final ackHashHex = ackHash
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final messageBytes = utf8.encode(outboundText).length;
    _pendingRepeaterAcks[ackHashHex]?.timeout?.cancel();
    _pendingRepeaterAcks[ackHashHex] = _RepeaterAckContext(
      contactKeyHex: contact.publicKeyHex,
      selection: selection,
      pathLength: selection.useFlood ? -1 : selection.hopCount,
      messageBytes: messageBytes,
    );
  }

  void recordRepeaterPathResult(
    Contact contact,
    PathSelection selection,
    bool success,
    int? tripTimeMs,
  ) {
    _recordPathResult(contact.publicKeyHex, selection, success, tripTimeMs);
  }

  Future<bool> verifyContactPathOnDevice(
    Contact contact,
    Uint8List expectedPath, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (!isConnected) return false;

    final expectedLength = expectedPath.length;
    final completer = Completer<bool>();

    void finish(bool result) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    }

    final subscription = receivedFrames.listen((frame) {
      if (frame.isEmpty || frame[0] != respCodeContact) return;
      final updated = Contact.fromFrame(
        frame,
        fallbackHashSizeBytes: _currentPathHashSizeBytes(),
      );
      if (updated == null) return;
      if (updated.publicKeyHex != contact.publicKeyHex) return;
      final matchesLength = updated.pathLength == expectedLength;
      final matchesBytes = _pathsEqual(updated.path, expectedPath);
      if (matchesLength && matchesBytes) {
        finish(true);
      }
    });

    final timer = Timer(timeout, () => finish(false));
    try {
      await getContactByKey(contact.publicKey);
      return await completer.future;
    } finally {
      await subscription.cancel();
      timer.cancel();
    }
  }

  Future<void> sendChannelMessage(
    Channel channel,
    String text, {
    bool addToLocalHistory = true,
  }) async {
    if (text.isEmpty) return;
    if (!isConnected) {
      throw StateError('Not connected to a MeshCore device');
    }

    text = _canonicalizeChannelReaction(channel.index, text);

    // Check if this is a reaction - if so, process it immediately instead of adding as a message
    final reactionInfo = ReactionHelper.parseReaction(text);
    if (reactionInfo != null) {
      // Check if we've already processed this reaction
      _processedChannelReactions.putIfAbsent(channel.index, () => {});
      final reactor = _selfName ?? 'self';
      final reactionIdentifier = _reactionIdentifier(reactionInfo, reactor);

      if (_processedChannelReactions[channel.index]!.contains(
        reactionIdentifier,
      )) {
        // Already processed, don't process again
        return;
      }

      final alreadyPending = _pendingOutgoingChannelReactions.values.any(
        (pending) =>
            pending.channelIndex == channel.index &&
            _reactionIdentifier(pending.info, pending.reactor) ==
                reactionIdentifier,
      );
      if (alreadyPending) return;

      await _applyChannelFloodScope(channel);

      // Keep the reaction pending until OK/SENT. Applying it before the device
      // accepts the frame can leave a local-only reaction after an error.
      final reactionQueueId = _nextReactionSendQueueId();
      _pendingChannelSentQueue.add(reactionQueueId);
      _pendingOutgoingChannelReactions[reactionQueueId] =
          _PendingOutgoingChannelReaction(
            channelIndex: channel.index,
            info: reactionInfo,
            reactor: reactor,
          );
      _startChannelSendTimeout(reactionQueueId);
      try {
        await sendFrame(
          buildSendChannelTextMsgFrame(channel.index, text),
          channelSendQueueId: reactionQueueId,
          expectsGenericAck: true,
        );
      } catch (_) {
        _pendingChannelSentQueue.remove(reactionQueueId);
        _pendingOutgoingChannelReactions.remove(reactionQueueId);
        _cancelChannelSendTimeout(reactionQueueId);
        rethrow;
      }
      return;
    }

    final trimmed = text.trim();
    final isStructuredPayload =
        trimmed.startsWith('g:') || trimmed.startsWith('a:');
    final outboundText =
        (isChannelSmazEnabled(channel.index) && !isStructuredPayload)
        ? Smaz.encodeIfSmaller(text)
        : text;

    if (addToLocalHistory) {
      final message = ChannelMessage.outgoing(
        text,
        _selfName ?? 'Me',
        channel.index,
      );
      _addChannelMessage(channel.index, message);
      _pendingChannelSentQueue.add(message.messageId);
      _startChannelSendTimeout(message.messageId);
      notifyListeners();
      try {
        await _applyChannelFloodScope(channel);
        await sendFrame(
          buildSendChannelTextMsgFrame(channel.index, outboundText),
          channelSendQueueId: message.messageId,
          expectsGenericAck: true,
        );
      } catch (_) {
        _pendingChannelSentQueue.remove(message.messageId);
        _markPendingChannelMessageFailedById(message.messageId);
        rethrow;
      }
      return;
    }

    await _applyChannelFloodScope(channel);
    final silentQueueId = _nextReactionSendQueueId();
    _pendingChannelSentQueue.add(silentQueueId);
    try {
      await sendFrame(
        buildSendChannelTextMsgFrame(channel.index, outboundText),
        channelSendQueueId: silentQueueId,
        expectsGenericAck: true,
      );
    } catch (_) {
      _pendingChannelSentQueue.remove(silentQueueId);
      rethrow;
    }
  }

  /// Edit a previously sent channel message. Applies the new text locally
  /// right away, then sends an `ed:` control message so other
  /// MeshCore-compatible clients can apply the same edit. See [EditHelper].
  Future<void> editChannelMessage(
    Channel channel,
    ChannelMessage target,
    String newText,
  ) async {
    if (newText.isEmpty || !target.isOutgoing) return;
    if (!isConnected) {
      throw StateError('Not connected to a MeshCore device');
    }

    final targetTimestamp = target.timestamp.millisecondsSinceEpoch ~/ 1000;
    final editText = EditHelper.buildChannelEditText(
      newText: newText,
      targetSender: target.senderName,
      targetText: target.text,
      targetTimestamp: targetTimestamp,
    );
    final editInfo = EditHelper.parseEditText(editText)!;

    final messages = _channelMessages[channel.index];
    if (messages != null) {
      final index = messages.indexOf(target);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          text: newText,
          edited: true,
          editedAt: DateTime.now(),
        );
        _saveChannelMessages(channel.index, messages);
        notifyListeners();
      }
    }
    // Mark this edit as already applied so the eventual send-confirmation
    // does not try to match it again against the now-updated text.
    _processedChannelEdits
        .putIfAbsent(channel.index, () => {})
        .add('${editInfo.targetHash}_${_selfName ?? 'self'}');

    await _applyChannelFloodScope(channel);
    final queueId = _nextReactionSendQueueId();
    _pendingChannelSentQueue.add(queueId);
    try {
      await sendFrame(
        buildSendChannelTextMsgFrame(channel.index, editText),
        channelSendQueueId: queueId,
        expectsGenericAck: true,
      );
    } catch (_) {
      _pendingChannelSentQueue.remove(queueId);
      rethrow;
    }
  }

  /// Send a binary channel datagram. Datagrams intentionally bypass the
  /// text-message queue and are not added to chat history.
  Future<void> sendChannelData(
    Channel channel,
    Uint8List payload, {
    int dataType = dataTypeDev,
    int pathLength = floodPathSentinel,
    Uint8List? pathBytes,
  }) async {
    if (!isConnected || payload.isEmpty) return;
    await _applyChannelFloodScope(channel);
    await sendFrame(
      buildSendChannelDataFrame(
        channelIndex: channel.index,
        dataType: dataType,
        payload: payload,
        pathLength: pathLength,
        pathBytes: pathBytes,
      ),
    );
  }

  Future<void> removeContact(Contact contact) async {
    if (!isConnected) {
      throw StateError('Cannot remove a contact while disconnected');
    }

    await sendFrame(buildRemoveContactFrame(contact.publicKey));
    _contacts.removeWhere((c) => c.publicKeyHex == contact.publicKeyHex);
    _knownContactKeys.remove(contact.publicKeyHex);
    _contactLocalByKey.remove(contact.publicKeyHex);
    unawaited(_persistContacts());
    _conversations.remove(contact.publicKeyHex);
    _olderConversationCounts.remove(contact.publicKeyHex);
    _loadedConversationKeys.remove(contact.publicKeyHex);
    _contactUnreadCount.remove(contact.publicKeyHex);
    if (!_isDemoMode) {
      _unreadStore.saveContactUnreadCount(
        Map<String, int>.from(_contactUnreadCount),
      );
      await _queueHistoryWrite(
        () => _messageStore.clearMessages(contact.publicKeyHex),
      );
    }
    notifyListeners();
  }

  Future<void> toggleContactFavorite(Contact contact) async {
    final index = _contacts.indexWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );
    if (index < 0) return;
    _contacts[index] = _contacts[index].copyWith(
      isFavorite: !_contacts[index].isFavorite,
    );
    _rememberContactLocal(_contacts[index]);
    await _persistContacts();
    notifyListeners();
  }

  Future<void> setContactFavorite(Contact contact, bool isFavorite) async {
    final index = _contacts.indexWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );
    if (index < 0) return;
    if (_contacts[index].isFavorite == isFavorite) return;
    _contacts[index] = _contacts[index].copyWith(isFavorite: isFavorite);
    _rememberContactLocal(_contacts[index]);
    await _persistContacts();
    notifyListeners();
  }

  /// Sets a local-only nickname for [contact], or clears it when [nickname]
  /// is null/blank. Never sent over the mesh.
  Future<void> setContactNickname(Contact contact, String? nickname) async {
    final index = _contacts.indexWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );
    if (index < 0) return;
    final trimmed = nickname?.trim();
    final normalized = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    if (_contacts[index].nickname == normalized) return;
    _contacts[index] = _contacts[index].copyWith(
      nickname: normalized,
      clearNickname: normalized == null,
    );
    _rememberContactLocal(_contacts[index]);
    await _persistContacts();
    notifyListeners();
  }

  Future<void> clearContactPath(Contact contact) async {
    if (isConnected) {
      await sendFrame(buildResetPathFrame(contact.publicKey));
    }

    final existingIndex = _contacts.indexWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );
    if (existingIndex >= 0) {
      final existing = _contacts[existingIndex];
      _contacts[existingIndex] = existing.copyWith(
        pathLength: -1,
        path: Uint8List(0),
        clearPathOverride: true,
      );
      _rememberContactLocal(_contacts[existingIndex]);
      await _persistContacts();
      notifyListeners();
    }
    // The device will send updated contact info with path_len = -1
  }

  void updateContactInMemory(
    String publicKeyHex, {
    Uint8List? pathBytes,
    int? pathLength,
  }) {
    final existingIndex = _contacts.indexWhere(
      (c) => c.publicKeyHex == publicKeyHex,
    );
    if (existingIndex >= 0) {
      final existing = _contacts[existingIndex];
      _contacts[existingIndex] = existing.copyWith(
        pathLength: pathLength,
        path: pathBytes,
      );
      notifyListeners();
      unawaited(_persistContacts());
    }
  }

  Future<void> syncTime() async {
    if (!isConnected) {
      throw StateError('Cannot synchronize time while disconnected');
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await sendFrame(buildSetDeviceTimeFrame(now));
  }

  Future<void> syncQueuedMessages({bool force = false}) async {
    if (!isConnected) return;
    if (!force && _isSyncingQueuedMessages) return;
    if (_awaitingSelfInfo || _isLoadingContacts) {
      _pendingQueueSync = true;
      return;
    }
    _isSyncingQueuedMessages = true;
    await _requestNextQueuedMessage();
  }

  Future<void> _requestNextQueuedMessage() async {
    if (!isConnected) {
      _isSyncingQueuedMessages = false;
      _queuedMessageSyncInFlight = false;
      _queueSyncRetries = 0;
      return;
    }
    if (_queuedMessageSyncInFlight) return;
    _queuedMessageSyncInFlight = true;

    // Cancel any existing timeout
    _queueSyncTimeout?.cancel();

    // Set up timeout for this request
    _queueSyncTimeout = Timer(Duration(milliseconds: _queueSyncTimeoutMs), () {
      _handleQueueSyncTimeout();
    });

    debugPrint(
      '[QueueSync] Requesting next message (retry: $_queueSyncRetries/$_maxQueueSyncRetries)',
    );

    try {
      await sendFrame(buildSyncNextMessageFrame());
    } catch (e) {
      debugPrint('[QueueSync] Error sending sync request: $e');
      _queuedMessageSyncInFlight = false;
      _isSyncingQueuedMessages = false;
      _queueSyncTimeout?.cancel();
      _queueSyncRetries = 0;
    }
  }

  void _handleQueueSyncTimeout() {
    debugPrint(
      '[QueueSync] Timeout waiting for message (retry: $_queueSyncRetries/$_maxQueueSyncRetries)',
    );

    if (_queueSyncRetries < _maxQueueSyncRetries) {
      // Retry
      _queueSyncRetries++;
      _queuedMessageSyncInFlight = false;
      _requestNextQueuedMessage();
    } else {
      // Max retries reached, give up
      debugPrint('[QueueSync] Max retries reached, stopping sync');
      _queuedMessageSyncInFlight = false;
      _isSyncingQueuedMessages = false;
      _queueSyncRetries = 0;
    }
  }

  Future<void> sendCliCommand(String command) async {
    if (!isConnected) {
      throw StateError('Cannot send a CLI command while disconnected');
    }

    // CLI commands are sent as UTF-8 text with a special prefix.
    // Companion local CLI is not hash-tracked like DMs/repeater ACKs; count
    // pending SENTs so they cannot steal the channel send FIFO.
    final commandBytes = utf8.encode(command);
    final bytes = Uint8List.fromList([0x01, ...commandBytes, 0x00]);
    _pendingCompanionCliSents++;
    try {
      await sendFrame(bytes);
    } catch (_) {
      if (_pendingCompanionCliSents > 0) _pendingCompanionCliSents--;
      rethrow;
    }
  }

  Future<void> setNodeName(String name) async {
    if (!isConnected) {
      throw StateError('Cannot set the node name while disconnected');
    }
    await sendFrame(buildSetAdvertNameFrame(name));
  }

  Future<void> setNodeLocation({
    required double lat,
    required double lon,
  }) async {
    if (!isConnected) {
      throw StateError('Cannot set the node location while disconnected');
    }
    await sendFrame(buildSetAdvertLatLonFrame(lat, lon));
  }

  Future<void> setCustomVar(String value) async {
    if (!isConnected) {
      throw StateError('Cannot set a device variable while disconnected');
    }
    await sendFrame(buildSetCustomVarFrame(value));
  }

  Future<void> sendSelfAdvert({bool flood = true}) async {
    if (!isConnected) {
      throw StateError('Cannot send an advertisement while disconnected');
    }
    await sendFrame(buildSendSelfAdvertFrame(flood: flood));
  }

  /// Export signed self contact URI (`meshcore://...`) for MeshMapper registration.
  Future<String> exportSelfContactUri({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (!isConnected) {
      throw StateError('Not connected to a MeshCore device');
    }

    final completer = Completer<String>();

    void finishWithError(Object error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    final subscription = receivedFrames.listen((frame) {
      if (frame.isEmpty) return;
      final code = frame[0];
      if (code == respCodeExportContact) {
        final advertPacket = frame.sublist(1);
        if (advertPacket.length < 98) {
          finishWithError(StateError('Invalid advert packet from device'));
          return;
        }
        if (!completer.isCompleted) {
          completer.complete('meshcore://${pubKeyToHex(advertPacket)}');
        }
        return;
      }
      if (code == respCodeErr) {
        finishWithError(StateError('Device rejected contact export'));
      }
    });

    final timer = Timer(timeout, () {
      finishWithError(TimeoutException('Contact export timed out'));
    });

    try {
      await sendFrame(
        buildExportContactFrame(Uint8List.fromList([])),
        expectsGenericAck: true,
      );
      return await completer.future;
    } finally {
      await subscription.cancel();
      timer.cancel();
    }
  }

  /// Import a signed contact advert (`meshcore://<hex>`) into the device's
  /// contact list.
  ///
  /// Returns `true` when the device acknowledges with [respCodeOk], `false`
  /// when it replies [respCodeErr], and throws a [FormatException] for an
  /// invalid URI or a [TimeoutException] when no acknowledgement arrives.
  ///
  /// Unlike [exportSelfContactUri], the firmware acknowledges a contact import
  /// with the GENERIC [respCodeOk]/[respCodeErr] codes (there is no unique
  /// `RESP_CODE_IMPORT_CONTACT`). Those same codes are also emitted for other
  /// in-flight requests — most notably `cmdSendChannelTxtMsg` channel sends,
  /// which the ATAK location broadcast service fires periodically while
  /// connected and foregrounded — so an import ACK cannot be attributed to a
  /// specific command on the wire.
  ///
  /// The import is therefore correlated via the shared FIFO
  /// `_pendingGenericAckQueue`, the same mechanism channel sends use: the
  /// `cmdImportContact` frame is enqueued when sent and the next generic
  /// [respCodeOk]/[respCodeErr] is dispatched to this import's completer. This
  /// assumes the device acknowledges generic-ack commands in send order, which
  /// matches the existing channel-send contract. Imports are serialized per
  /// user action, so a single in-flight import cannot be confused with another.
  Future<bool> importContactAdvert(
    String contactAdvertUri, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final hexString = ContactAdvertUri.contactHexFromUri(contactAdvertUri);
    if (hexString == null) {
      throw const FormatException('Invalid meshcore contact advert URI');
    }
    if (!isConnected) {
      throw StateError('Not connected to a MeshCore device');
    }

    final completer = Completer<bool>();

    void cancelPendingImport() {
      for (final pending in _pendingGenericAckQueue) {
        if (pending.commandCode == cmdImportContact) pending.cancelled = true;
      }
    }

    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        cancelPendingImport();
        completer.completeError(TimeoutException('Contact import timed out'));
      }
    });

    try {
      await sendFrame(
        buildImportContactFrame(hexString),
        expectsGenericAck: true,
        completion: (success) {
          if (!completer.isCompleted) completer.complete(success);
        },
      );
      return await completer.future;
    } finally {
      timer.cancel();
    }
  }

  Future<void> rebootDevice() async {
    if (!isConnected) {
      throw StateError('Cannot reboot the device while disconnected');
    }
    await sendFrame(buildRebootFrame());
  }

  Future<void> setPrivacyMode(bool enabled) async {
    await sendCliCommand('set privacy ${enabled ? 'on' : 'off'}');
  }

  Future<void> getChannels({int? maxChannels, bool force = false}) async {
    if (!isConnected) return;
    if (_isDemoMode) {
      notifyListeners();
      return;
    }
    if (_isSyncingChannels) {
      debugPrint('[ChannelSync] Already syncing channels, ignoring request');
      return;
    }

    // Skip fetching if already loaded and not forced
    if (_hasLoadedChannels && !force) {
      debugPrint(
        '[ChannelSync] Channels already loaded, skipping fetch (use force=true to reload)',
      );
      return;
    }

    _isLoadingChannels = true;
    _isSyncingChannels = true;
    _previousChannelsCache = List<Channel>.from(_channels);
    _channels.clear();
    _nextChannelIndexToRequest = 0;
    _totalChannelsToRequest = maxChannels ?? _maxChannels;
    _channelSyncRetries = 0;
    notifyListeners();

    debugPrint(
      '[ChannelSync] Starting sync for $_totalChannelsToRequest channels',
    );

    // Start sequential sync
    await _requestNextChannel();
  }

  Future<void> _requestNextChannel() async {
    if (!isConnected) {
      _cleanupChannelSync(completed: false);
      return;
    }

    if (_channelSyncInFlight) return;

    // Check if we've requested all channels
    if (_nextChannelIndexToRequest >= _totalChannelsToRequest) {
      _completeChannelSync();
      return;
    }

    _channelSyncInFlight = true;
    final channelIndex = _nextChannelIndexToRequest;

    // Cancel any existing timeout
    _channelSyncTimeout?.cancel();

    // Set up timeout for this channel request
    _channelSyncTimeout = Timer(
      Duration(milliseconds: _channelSyncTimeoutMs),
      () => _handleChannelSyncTimeout(channelIndex),
    );

    debugPrint(
      '[ChannelSync] Requesting channel $channelIndex/$_totalChannelsToRequest (retry: $_channelSyncRetries/$_maxChannelSyncRetries)',
    );

    try {
      await sendFrame(buildGetChannelFrame(channelIndex));
    } catch (e) {
      debugPrint('[ChannelSync] Error sending channel request: $e');
      _channelSyncInFlight = false;
      _cleanupChannelSync(completed: false);
    }
  }

  void _handleChannelSyncTimeout(int channelIndex) {
    debugPrint(
      '[ChannelSync] Timeout waiting for channel $channelIndex (retry: $_channelSyncRetries/$_maxChannelSyncRetries)',
    );

    if (_channelSyncRetries < _maxChannelSyncRetries) {
      // Retry the same channel
      _channelSyncRetries++;
      _channelSyncInFlight = false;
      unawaited(_requestNextChannel());
    } else {
      // Max retries reached for this channel, restore from cache and move to next
      debugPrint(
        '[ChannelSync] Max retries reached for channel $channelIndex, attempting cache restore',
      );

      // Try to restore this channel from cache
      try {
        final cachedChannel = _previousChannelsCache.firstWhere(
          (c) => c.index == channelIndex,
        );
        if (!cachedChannel.isEmpty) {
          _channels.add(cachedChannel);
          debugPrint(
            '[ChannelSync] Restored channel $channelIndex (${cachedChannel.name}) from cache',
          );
        }
      } catch (e) {
        // No cached channel found, that's okay
      }

      // Move to next channel
      _nextChannelIndexToRequest++;
      _channelSyncRetries = 0;
      _channelSyncInFlight = false;
      unawaited(_requestNextChannel());
    }
  }

  void _completeChannelSync() {
    _channelSyncTimeout?.cancel();

    debugPrint(
      '[ChannelSync] Sync complete: received ${_channels.length}/$_totalChannelsToRequest channels',
    );

    _cleanupChannelSync(completed: true);

    // Cache channels for offline use
    _cachedChannels = List<Channel>.from(_channels);
    unawaited(_channelStore.saveChannels(_channels));

    // Apply ordering and notify UI
    _applyChannelOrder();
    notifyListeners();
  }

  void _cleanupChannelSync({required bool completed}) {
    _isSyncingChannels = false;
    _channelSyncInFlight = false;
    _isLoadingChannels = false;
    _channelSyncTimeout?.cancel();
    _channelSyncRetries = 0;
    _nextChannelIndexToRequest = 0;
    _totalChannelsToRequest = 0;

    if (completed) {
      _hasLoadedChannels = true;
      _previousChannelsCache.clear();
      // Manual disconnect clears in-memory channel history; reload from disk
      // once channel slots are known again.
      unawaited(loadAllChannelMessages());
    }
    // Keep cache on failure/disconnection for future attempts
  }

  Future<void> setChannel(int index, String name, Uint8List psk) async {
    if (!isConnected) {
      throw StateError('Cannot set a channel while disconnected');
    }

    if (_isDemoMode) {
      _channels.removeWhere((channel) => channel.index == index);
      if (name.isNotEmpty) {
        _channels.add(Channel(index: index, name: name, psk: psk));
        _channels.sort((a, b) => a.index.compareTo(b.index));
      }
      notifyListeners();
      return;
    }
    await sendFrame(buildSetChannelFrame(index, name, psk));
    // Refresh channels after setting
    await getChannels(force: true);
  }

  Future<void> deleteChannel(int index) async {
    if (!isConnected) {
      throw StateError('Cannot delete a channel while disconnected');
    }

    if (_isDemoMode) {
      _channels.removeWhere((channel) => channel.index == index);
      _channelMessages.remove(index);
      notifyListeners();
      return;
    }
    // Delete by setting empty name and zero PSK
    await sendFrame(buildSetChannelFrame(index, '', Uint8List(16)));
    // Clear stored messages for this channel
    await _queueHistoryWrite(
      () => _channelMessageStore.clearChannelMessages(index),
    );
    // Clear in-memory messages for this channel
    _channelMessages.remove(index);
    _olderChannelCounts.remove(index);
    _loadedChannelIndexes.remove(index);
    _loadingChannelIndexes.remove(index);
    // Refresh channels after deleting
    await getChannels(force: true);
  }

  Future<void> toggleChannelFavorite(Channel channel) async {
    final index = _channels.indexWhere((c) => c.index == channel.index);
    if (index < 0) return;
    _channels[index].isFavorite = !_channels[index].isFavorite;
    if (!_isDemoMode) await _channelStore.saveChannels(_channels);
    notifyListeners();
  }

  void _handleFrame(List<int> data) {
    if (data.isEmpty) return;

    final frame = Uint8List.fromList(data);
    if (!_receivedFramesController.isClosed) {
      _receivedFramesController.add(frame);
    }
    _frameDebugLogService?.logFrame(frame, outgoing: false);

    final code = frame[0];
    debugPrint('RX frame: code=$code len=${frame.length}');

    try {
      _dispatchFrame(code, frame);
    } catch (e, stack) {
      _dropMalformedFrame(code, frame, e, stack);
    }
  }

  /// A malformed/truncated frame must never break the RX stream; drop it.
  void _dropMalformedFrame(
    int code,
    Uint8List frame,
    Object error,
    StackTrace stack,
  ) {
    debugPrint(
      'Dropped malformed frame code=$code len=${frame.length}: $error',
    );
    _appDebugLogService?.warn(
      'Dropped malformed frame code=$code len=${frame.length}: $error',
      tag: 'Protocol',
    );
    assert(() {
      debugPrint('$stack');
      return true;
    }());
  }

  /// Gives an asynchronous frame handler the same drop-and-log protection
  /// [_handleFrame] gives synchronous ones.
  ///
  /// An `async` function never throws synchronously to its caller — every
  /// error it raises, before or after its first `await`, is delivered through
  /// its Future. Calling one bare from [_dispatchFrame] therefore bypasses
  /// that try/catch completely and escapes to the zone handler instead.
  Future<void> _dispatchAsync(
    int code,
    Uint8List frame,
    Future<void> Function() handler,
  ) async {
    try {
      await handler();
    } catch (e, stack) {
      _dropMalformedFrame(code, frame, e, stack);
    }
  }

  @visibleForTesting
  void handleFrameForTest(Uint8List frame) => _handleFrame(frame);

  @visibleForTesting
  int get pendingGenericAckCountForTest => _pendingGenericAckQueue.length;

  @visibleForTesting
  void trackPendingGenericAckForTest(
    Uint8List frame, {
    String? channelSendQueueId,
    void Function(bool success)? completion,
  }) => _trackPendingGenericAck(
    frame,
    channelSendQueueId: channelSendQueueId,
    expectsGenericAck: true,
    completion: completion,
  );

  @visibleForTesting
  void cancelPendingGenericAckForTest(String queueId) =>
      _cancelPendingGenericAckForQueueId(queueId);

  @visibleForTesting
  void attachAppSettingsServiceForTest(AppSettingsService service) {
    _attachAppSettingsService(service);
  }

  @visibleForTesting
  void addContactForTest(Contact contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  @visibleForTesting
  void addChannelForTest(Channel channel) {
    _channels.add(channel);
    notifyListeners();
  }

  void _dispatchFrame(int code, Uint8List frame) {
    switch (code) {
      case respCodeOk:
        _handleOk();
        break;
      case respCodeDeviceInfo:
        _handleDeviceInfo(frame);
        break;
      case respCodeSelfInfo:
        debugPrint('Got SELF_INFO');
        _handleSelfInfo(frame);
        break;
      case respCodeContactsStart:
        debugPrint('Got CONTACTS_START');
        if (!_preserveContactsOnRefresh) {
          _contacts.clear();
        }
        _isLoadingContacts = true;
        notifyListeners();
        break;
      case pushCodeNewAdvert:
        debugPrint('Got New CONTACT');
        // It's the same format as respCodeContact, so we can reuse the handler
        _handleContact(frame);
        break;
      case respCodeContact:
        debugPrint('Got CONTACT');
        _handleContact(frame);
        break;
      case respCodeEndOfContacts:
        debugPrint('Got END_OF_CONTACTS');
        _isLoadingContacts = false;
        _preserveContactsOnRefresh = false;
        notifyListeners();
        unawaited(_persistContacts());
        if (!_didInitialQueueSync || _pendingQueueSync) {
          _didInitialQueueSync = true;
          _pendingQueueSync = false;
          unawaited(syncQueuedMessages(force: true));
        }
        break;
      case respCodeContactMsgRecv:
      case respCodeContactMsgRecvV3:
        unawaited(
          _dispatchAsync(code, frame, () => _handleIncomingMessage(frame)),
        );
        break;
      case respCodeChannelMsgRecv:
      case respCodeChannelMsgRecvV3:
        _handleIncomingChannelMessage(frame);
        break;
      case respCodeSent:
        _handleMessageSent(frame);
        break;
      case respCodeNoMoreMessages:
        _handleNoMoreMessages();
        break;
      case pushCodeMsgWaiting:
        unawaited(syncQueuedMessages(force: true));
        break;
      case pushCodeSendConfirmed:
        _handleSendConfirmed(frame);
        break;
      case pushCodePathUpdated:
        _handlePathUpdated(frame);
        break;
      case pushCodeLoginSuccess:
      case pushCodeLoginFail:
      case pushCodeStatusResponse:
        break;
      case pushCodeTelemetryResponse:
        // Reply to the deprecated CMD_SEND_TELEMETRY_REQ. Remote telemetry is
        // fetched over CMD_SEND_BINARY_REQ / PUSH_CODE_BINARY_RESPONSE instead,
        // and this frame's payload layout is not documented, so it is
        // acknowledged (rather than parsed on a guess) purely to keep it off
        // the unknown-frame path. Subscribers still see it on receivedFrames.
        _appDebugLogService?.info(
          'Ignored legacy telemetry response (${frame.length} bytes)',
          tag: 'Telemetry',
        );
        break;
      case pushCodeLogRxData:
        _handleRxData(frame);
        _handleLogRxData(frame);
        break;
      case respCodeChannelInfo:
        _handleChannelInfo(frame);
        break;
      case respCodeRadioSettings:
        _handleRadioSettings(frame);
        break;
      case respCodeStats:
        _handleRadioStats(frame);
        break;
      case respCodeBattAndStorage:
        _handleBatteryAndStorage(frame);
        break;
      case respCodeCustomVars:
        _handleCustomVars(frame);
        break;
      case respCodeDefaultFloodScope:
        _handleDefaultFloodScope(frame);
        break;
      // RESP_CODE_ERR is a defined firmware response (code 1), not an unknown frame.
      case respCodeErr:
        _handleErrorFrame(frame);
        break;
      default:
        debugPrint('Unknown frame code: $code');
    }
  }

  void _handleRadioStats(Uint8List frame) {
    final stats = parseRadioStatsFrame(frame);
    if (stats == null || stats.noiseFloor == 0) {
      return;
    }
    _lastNoiseFloor = stats.noiseFloor;
    _lastRadioStats = stats;
    if (!_radioStatsController.isClosed) {
      _radioStatsController.add(stats);
    }
    final completer = _noiseFloorCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(stats.noiseFloor);
    }
    notifyListeners();
  }

  void _handleErrorFrame(Uint8List frame) {
    if (frame.length < 2) {
      _appDebugLogService?.warn(
        'Ignored truncated firmware error frame',
        tag: 'Protocol',
      );
      return;
    }
    final errCode = frame[1];
    _appDebugLogService?.warn(
      'Firmware responded with error code: $errCode',
      tag: 'Protocol',
    );

    if (_pendingGenericAckQueue.isEmpty) {
      return;
    }

    final failedAck = _pendingGenericAckQueue.removeAt(0);
    failedAck.responseReceived = true;
    if (failedAck.cancelled) return;
    if (failedAck.commandCode == cmdImportContact) {
      failedAck.completion?.call(false);
      return;
    }
    if (failedAck.commandCode != cmdSendChannelTxtMsg ||
        failedAck.channelSendQueueId == null) {
      return;
    }
    final queueId = failedAck.channelSendQueueId!;
    _pendingChannelSentQueue.remove(queueId);
    _pendingOutgoingChannelReactions.remove(queueId);
    _cancelChannelSendTimeout(queueId);
    // Surface the failure to the UI instead of leaving the message pending.
    _markPendingChannelMessageFailedById(queueId);
  }

  void _startChannelSendTimeout(String messageId) {
    _channelSendTimeouts[messageId]?.cancel();
    _channelSendTimeouts[messageId] = Timer(
      const Duration(milliseconds: _channelSendTimeoutMs),
      () {
        _channelSendTimeouts.remove(messageId);
        _pendingChannelSentQueue.remove(messageId);
        _cancelPendingGenericAckForQueueId(messageId);
        _pendingOutgoingChannelReactions.remove(messageId);
        _markPendingChannelMessageFailedById(messageId);
      },
    );
  }

  void _cancelChannelSendTimeout(String messageId) {
    _channelSendTimeouts.remove(messageId)?.cancel();
  }

  /// Stops tracking [queueId] without breaking FIFO correlation.
  ///
  /// See [_PendingCommandAck.cancelled]: the slot is kept so the companion's
  /// still-outstanding OK/ERR consumes this entry rather than the next one.
  void _cancelPendingGenericAckForQueueId(String queueId) {
    for (final pending in _pendingGenericAckQueue) {
      if (pending.channelSendQueueId == queueId) pending.cancelled = true;
    }
  }

  bool _markPendingChannelMessageFailedById(String messageId) {
    _cancelChannelSendTimeout(messageId);
    for (final entry in _channelMessages.entries) {
      final channelMessages = entry.value;
      for (int i = channelMessages.length - 1; i >= 0; i--) {
        final message = channelMessages[i];
        if (message.messageId != messageId) {
          continue;
        }
        if (!message.isOutgoing ||
            message.status != ChannelMessageStatus.pending) {
          return false;
        }
        channelMessages[i] = message.copyWith(
          status: ChannelMessageStatus.failed,
        );
        unawaited(_saveChannelMessages(entry.key, channelMessages));
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void _handlePathUpdated(Uint8List frame) {
    // Frame format: [0]=code, [1-32]=pub_key
    if (frame.length >= 33 && _pathHistoryService != null) {
      final pubKey = Uint8List.fromList(frame.sublist(1, 33));
      final contact = _contacts.cast<Contact?>().firstWhere(
        (c) => c != null && listEquals(c.publicKey, pubKey),
        orElse: () => null,
      );

      if (contact != null) {
        _pathHistoryService!.handlePathUpdated(contact);
        // Refresh just this specific contact instead of all contacts.
        // This avoids race conditions with _preserveContactsOnRefresh flag
        // that can occur when using refreshContactsSinceLastmod().
        getContactByKey(pubKey);
      }
    }
  }

  void _handleSelfInfo(Uint8List frame) {
    // SELF_INFO format:
    // [0] = RESP_CODE_SELF_INFO
    // [1] = ADV_TYPE
    // [2] = tx_power_dbm
    // [3] = MAX_LORA_TX_POWER
    // [4-35] = pub_key (32 bytes)
    // [36-39] = lat (int32 LE)
    // [40-43] = lon (int32 LE)
    // [44] = multi_acks
    // [45] = advert_loc_policy
    // [46] = telemetry modes
    // [47] = manual_add_contacts
    // [48-51] = freq (uint32 LE, in Hz)
    // [52-55] = bw (uint32 LE, in Hz)
    // [56] = sf
    // [57] = cr
    // [58+] = node_name
    if (frame.length < 4 + pubKeySize) return;

    _currentTxPower = frame[2];
    _maxTxPower = frame[3];
    _selfPublicKey = Uint8List.fromList(frame.sublist(4, 4 + pubKeySize));
    if (frame.length >= 44) {
      final lat = readInt32LE(frame, 36) / 1000000.0;
      final lon = readInt32LE(frame, 40) / 1000000.0;
      if (lat == 0 && lon == 0) {
        _selfLatitude = null;
        _selfLongitude = null;
      } else {
        _selfLatitude = lat;
        _selfLongitude = lon;
      }
    } else {
      _selfLatitude = null;
      _selfLongitude = null;
    }

    // Radio settings (if frame is long enough)
    if (frame.length >= 58) {
      _currentFreqHz = readUint32LE(frame, 48);
      _currentBwHz = readUint32LE(frame, 52);
      _currentSf = frame[56];
      _currentCr = frame[57];
    }

    // Node name starts at offset 58 if frame is long enough
    if (frame.length > 58) {
      _selfName = readCString(frame, 58, frame.length - 58);
    }
    _awaitingSelfInfo = false;
    _selfInfoRetryTimer?.cancel();
    _selfInfoRetryTimer = null;
    // Healthy session: enable auto-reconnect and reset backoff.
    _lastSelfInfoGeneration = _connectGeneration;
    _hadHealthySession = true;
    _reconnectAttempts = 0;
    _reconnectGaveUp = false;
    notifyListeners();

    // Auto-fetch contacts after getting self info
    unawaited(refreshContactsBestEffort());
  }

  void _handleDeviceInfo(Uint8List frame) {
    if (frame.length < 4) return;
    _firmwareVerCode = frame[1];

    // Parse client_repeat from firmware v9+ (byte 80)
    if (frame.length >= 81) {
      _clientRepeat = frame[80] != 0;
    }

    // Path hash mode from firmware v10+ (byte 81)
    if (frame.length >= 82) {
      _supportsPathHashMode = true;
      final mode = frame[81];
      _devicePathHashMode = isValidPathHashMode(mode) ? mode : 0;
    } else {
      _supportsPathHashMode = false;
      _devicePathHashMode = null;
    }

    // Firmware reports MAX_CONTACTS / 2 for v3+ device info.
    final reportedContacts = frame[2];
    final reportedChannels = frame[3];
    final nextMaxContacts = reportedContacts > 0
        ? reportedContacts * 2
        : _maxContacts;
    final nextMaxChannels = reportedChannels > 0
        ? reportedChannels
        : _maxChannels;
    final previousMaxChannels = _maxChannels;
    if (nextMaxContacts != _maxContacts || nextMaxChannels != _maxChannels) {
      _maxContacts = nextMaxContacts;
      _maxChannels = nextMaxChannels;
      if (nextMaxChannels > previousMaxChannels) {
        unawaited(loadChannelSettings(maxChannels: nextMaxChannels));
        unawaited(loadAllChannelMessages(maxChannels: nextMaxChannels));
        if (isConnected) {
          unawaited(getChannels(maxChannels: nextMaxChannels));
        }
      }
    }
    notifyListeners();
    unawaited(_syncCompanionPathHashMode());
  }

  Future<void> _syncCompanionPathHashMode() async {
    if (!isConnected || !_supportsPathHashMode) return;
    final desired =
        _appSettingsService?.settings.companionPathHashMode ??
        defaultPathHashMode;
    if (!isValidPathHashMode(desired)) return;
    if (_devicePathHashMode == desired) return;
    await setCompanionPathHashMode(desired);
  }

  Future<bool> setCompanionPathHashMode(int mode) async {
    if (!isConnected || !isValidPathHashMode(mode)) return false;
    if (!_supportsPathHashMode) return false;
    await sendFrame(buildSetPathHashModeFrame(mode));
    _devicePathHashMode = mode;
    notifyListeners();
    return true;
  }

  /// Hash size (bytes) to assume when a path field doesn't self-describe it,
  /// preferring the mode confirmed synced with the device over the app's
  /// desired setting.
  int _currentPathHashSizeBytes() {
    final mode =
        _devicePathHashMode ??
        _appSettingsService?.settings.companionPathHashMode ??
        defaultPathHashMode;
    return pathHashBytesForMode(mode);
  }

  /// Query the companion's persisted default flood scope (firmware v11+).
  ///
  /// Returns the scope name, or `null` when unset / unsupported / timed out.
  Future<String?> getDefaultFloodScope({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (!isConnected) return null;

    final existing = _defaultFloodScopeCompleter;
    if (existing != null && !existing.isCompleted) {
      return existing.future;
    }

    final completer = Completer<String?>();
    _defaultFloodScopeCompleter = completer;

    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(_defaultFloodScopeName);
      }
      if (identical(_defaultFloodScopeCompleter, completer)) {
        _defaultFloodScopeCompleter = null;
      }
    });

    try {
      await sendFrame(buildGetDefaultFloodScopeFrame());
      return await completer.future;
    } catch (_) {
      if (!completer.isCompleted) {
        completer.complete(_defaultFloodScopeName);
      }
      return _defaultFloodScopeName;
    } finally {
      timer.cancel();
      if (identical(_defaultFloodScopeCompleter, completer)) {
        _defaultFloodScopeCompleter = null;
      }
    }
  }

  /// Persist the companion's default flood scope, or clear it when [name] is null/empty.
  Future<bool> setDefaultFloodScope(String? name) async {
    if (!isConnected) return false;

    final trimmed = name == null ? '' : RegionScopeCodes.canonicalize(name);
    if (trimmed.isEmpty) {
      await sendFrame(
        buildSetDefaultFloodScopeFrame(name: '', scopeKey: Uint8List(16)),
      );
      _defaultFloodScopeName = null;
      notifyListeners();
      return true;
    }

    final scopeKey = MeshRegion.deriveFloodScopeKey(trimmed);
    await sendFrame(
      buildSetDefaultFloodScopeFrame(name: trimmed, scopeKey: scopeKey),
    );
    _defaultFloodScopeName = trimmed;
    notifyListeners();
    return true;
  }

  Future<bool> clearDefaultFloodScope() => setDefaultFloodScope(null);

  void _handleDefaultFloodScope(Uint8List frame) {
    // A code-only response means "not configured". Any non-empty payload must
    // contain the complete fixed-width name and key; otherwise leave the last
    // known value and outstanding query untouched.
    if (frame.length > 1 &&
        frame.length <
            1 + defaultFloodScopeNameField + defaultFloodScopeKeyBytes) {
      _appDebugLogService?.warn(
        'Ignored truncated default flood scope frame (${frame.length} bytes)',
        tag: 'Protocol',
      );
      return;
    }
    final info = DefaultFloodScopeInfo.fromPayload(frame.sublist(1));
    _defaultFloodScopeName = info?.name;
    debugPrint('Default flood scope: ${_defaultFloodScopeName ?? '(none)'}');
    notifyListeners();

    final completer = _defaultFloodScopeCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(_defaultFloodScopeName);
    }
    _defaultFloodScopeCompleter = null;
  }

  void _handleNoMoreMessages() {
    debugPrint('[QueueSync] No more messages, sync complete');
    _queueSyncTimeout?.cancel();
    _isSyncingQueuedMessages = false;
    _queuedMessageSyncInFlight = false;
    _queueSyncRetries = 0; // Reset retry counter on successful completion
  }

  void _handleQueuedMessageReceived() {
    if (!_isSyncingQueuedMessages) return;
    debugPrint('[QueueSync] Message received, requesting next');
    _queueSyncTimeout?.cancel(); // Cancel timeout - message arrived
    _queuedMessageSyncInFlight = false;
    _queueSyncRetries = 0; // Reset retry counter on successful message
    unawaited(_requestNextQueuedMessage());
  }

  void _handleRadioSettings(Uint8List frame) {
    // Frame format from C++:
    // [0] = RESP_CODE_RADIO_SETTINGS
    // [1-4] = freq (uint32 LE, in Hz)
    // [5-8] = bw (uint32 LE, in Hz)
    // [9] = sf
    // [10] = cr
    if (frame.length >= 11) {
      _currentFreqHz = readUint32LE(frame, 1);
      _currentBwHz = readUint32LE(frame, 5);
      _currentSf = frame[9];
      _currentCr = frame[10];
      debugPrint(
        'Radio settings: freq=$_currentFreqHz bw=$_currentBwHz sf=$_currentSf cr=$_currentCr',
      );
      notifyListeners();
    }
  }

  void _handleBatteryAndStorage(Uint8List frame) {
    // Frame format from C++:
    // [0] = RESP_CODE_BATT_AND_STORAGE
    // [1-2] = battery_mv (uint16 LE)
    // [3-6] = storage_used_kb (uint32 LE)
    // [7-10] = storage_total_kb (uint32 LE)
    if (frame.length >= 3) {
      _batteryMillivolts = readUint16LE(frame, 1);
      if (frame.length >= 11) {
        _storageUsedKb = readUint32LE(frame, 3);
        _storageTotalKb = readUint32LE(frame, 7);
      }
      final volts = (_batteryMillivolts! / 1000.0).toStringAsFixed(2);
      _appDebugLogService?.info(
        'Pulled battery: $volts V ($_batteryMillivolts mV)',
        tag: 'Battery',
      );
      notifyListeners();
    }
  }

  /// Calculate timeout for a message based on radio settings and path length
  /// Returns timeout in milliseconds, considering number of hops
  int calculateTimeout({required int pathLength, int messageBytes = 100}) {
    // If we have radio settings, use them for accurate calculation
    if (_currentFreqHz != null &&
        _currentBwHz != null &&
        _currentSf != null &&
        _currentCr != null) {
      final cr = _currentCr! <= 4 ? _currentCr! : _currentCr! - 4;
      return calculateMessageTimeout(
        freqHz: _currentFreqHz!,
        bwHz: _currentBwHz!,
        sf: _currentSf!,
        cr: cr,
        pathLength: pathLength,
        messageBytes: messageBytes,
      );
    }

    // Fallback: Conservative estimates based on typical settings
    // Assume SF7, BW125, which gives ~50ms airtime for 100 bytes
    const estimatedAirtime = 50;

    if (pathLength < 0) {
      // Flood mode: Base delay + 16× airtime
      return 500 + (16 * estimatedAirtime);
    } else {
      // Direct path: Base delay + ((airtime×6 + 250ms)×(hops+1))
      return 500 + ((estimatedAirtime * 6 + 250) * (pathLength + 1));
    }
  }

  void _handleContact(Uint8List frame) {
    // pushCodeNewAdvert frames share the respCodeContact payload layout but
    // carry a different leading code, which Contact.fromFrame rejects. Normalize
    // the code so live new-advert pushes are parsed instead of silently dropped.
    final parseFrame = (frame.isNotEmpty && frame[0] == pushCodeNewAdvert)
        ? (Uint8List.fromList(frame)..[0] = respCodeContact)
        : frame;
    final contact = Contact.fromFrame(
      parseFrame,
      fallbackHashSizeBytes: _currentPathHashSizeBytes(),
    );
    if (contact != null) {
      if (contact.type == advTypeRepeater) {
        _contactUnreadCount.remove(contact.publicKeyHex);
        _unreadStore.saveContactUnreadCount(
          Map<String, int>.from(_contactUnreadCount),
        );
      }
      // Check if this is a new contact
      final isNewContact = !_knownContactKeys.contains(contact.publicKeyHex);
      final existingIndex = _contacts.indexWhere(
        (c) => c.publicKeyHex == contact.publicKeyHex,
      );

      if (existingIndex >= 0) {
        final existing = _contacts[existingIndex];

        appLogger.info(
          'Refreshing contact ${contact.name}: devicePath=${contact.pathLength}, existingOverride=${existing.pathOverride}',
          tag: 'Connector',
        );

        _contacts[existingIndex] = _mergeWithLocalContactFields(
          contact,
          existing: existing,
        );

        appLogger.info(
          'After merge: pathOverride=${_contacts[existingIndex].pathOverride}, devicePath=${_contacts[existingIndex].pathLength}',
          tag: 'Connector',
        );
      } else {
        _contacts.add(_mergeWithLocalContactFields(contact));
        appLogger.info(
          'Added new contact ${contact.name}: pathLen=${contact.pathLength}',
          tag: 'Connector',
        );
      }
      _knownContactKeys.add(contact.publicKeyHex);
      _loadMessagesForContact(contact.publicKeyHex);

      // Add path to history if we have a valid path
      if (_pathHistoryService != null && contact.pathLength >= 0) {
        _pathHistoryService!.handlePathUpdated(contact);
      }

      notifyListeners();

      // Show notification for new contact (advertisement)
      if (isNewContact) {
        _notifications.notifyAdvert(
          contactName: contact.name,
          contactType: contact.typeLabel,
          contactKeyHex: contact.publicKeyHex,
        );
      }

      if (!_isLoadingContacts) {
        unawaited(_persistContacts());
      }
    }
  }

  void _handleContactAdvert(Contact contact) {
    if (listEquals(contact.publicKey, _selfPublicKey)) {
      return;
    }

    if (contact.type == advTypeRepeater) {
      _contactUnreadCount.remove(contact.publicKeyHex);
      _unreadStore.saveContactUnreadCount(
        Map<String, int>.from(_contactUnreadCount),
      );
    }
    // Check if this is a new contact
    final isNewContact = !_knownContactKeys.contains(contact.publicKeyHex);
    final existingIndex = _contacts.indexWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );

    if (existingIndex >= 0) {
      final existing = _contacts[existingIndex];

      appLogger.info(
        'Refreshing contact ${contact.name}: devicePath=${contact.pathLength}, existingOverride=${existing.pathOverride}',
        tag: 'Connector',
      );

      _contacts[existingIndex] = _mergeWithLocalContactFields(
        contact,
        existing: existing,
      );

      appLogger.info(
        'After merge: pathOverride=${_contacts[existingIndex].pathOverride}, devicePath=${_contacts[existingIndex].pathLength}',
        tag: 'Connector',
      );
    } else {
      _contacts.add(_mergeWithLocalContactFields(contact));
      appLogger.info(
        'Added new contact ${contact.name}: pathLen=${contact.pathLength}',
        tag: 'Connector',
      );
    }
    _knownContactKeys.add(contact.publicKeyHex);
    _loadMessagesForContact(contact.publicKeyHex);

    // Add path to history if we have a valid path
    if (_pathHistoryService != null && contact.pathLength >= 0) {
      _pathHistoryService!.handlePathUpdated(contact);
    }

    notifyListeners();

    // Show notification for new contact (advertisement)
    if (isNewContact) {
      _notifications.notifyAdvert(
        contactName: contact.name,
        contactType: contact.typeLabel,
        contactKeyHex: contact.publicKeyHex,
      );
    }

    if (!_isLoadingContacts) {
      unawaited(_persistContacts());
    }
  }

  Future<void> _persistContacts() async {
    if (_isDemoMode) return;
    final prior = _contactPersistChain;
    final result = prior.then((_) => _contactStore.saveContacts(_contacts));
    _contactPersistChain = result.then((_) {}, onError: (_) {});
    await result;
  }

  int _latestContactLastmod() {
    if (_contacts.isEmpty) return 0;
    var latest = 0;
    for (final contact in _contacts) {
      final seconds = contact.lastSeen.millisecondsSinceEpoch ~/ 1000;
      if (seconds > latest) {
        latest = seconds;
      }
    }
    return latest;
  }

  bool _setContactLastMessageAt(int index, DateTime timestamp) {
    final contact = _contacts[index];
    if (contact.type != advTypeChat) return false;
    if (!timestamp.isAfter(contact.lastMessageAt)) return false;
    _contacts[index] = contact.copyWith(lastMessageAt: timestamp);
    return true;
  }

  void _updateContactLastMessageAt(
    String contactKeyHex,
    DateTime timestamp, {
    bool notify = false,
  }) {
    final index = _contacts.indexWhere((c) => c.publicKeyHex == contactKeyHex);
    if (index < 0) return;
    if (!_setContactLastMessageAt(index, timestamp)) return;
    unawaited(_persistContacts());
    if (notify) {
      notifyListeners();
    }
  }

  void _updateContactLastMessageAtByName(
    String senderName,
    DateTime timestamp, {
    Uint8List? pathBytes,
    bool notify = false,
  }) {
    final normalized = senderName.trim().toLowerCase();
    final hasName = normalized.isNotEmpty && normalized != 'unknown';
    var updated = false;
    var matchedByName = false;

    if (hasName) {
      for (var i = 0; i < _contacts.length; i++) {
        final contact = _contacts[i];
        if (contact.type != advTypeChat) continue;
        if (contact.name.trim().toLowerCase() == normalized) {
          matchedByName = true;
          updated = _setContactLastMessageAt(i, timestamp) || updated;
        }
      }
    }

    if (!matchedByName && pathBytes != null && pathBytes.isNotEmpty) {
      final matches = <int>[];
      for (var i = 0; i < _contacts.length; i++) {
        final contact = _contacts[i];
        if (contact.type != advTypeChat) continue;
        if (_pathMatchesContact(pathBytes, contact.publicKey)) {
          matches.add(i);
        }
      }
      if (matches.length == 1) {
        updated = _setContactLastMessageAt(matches.first, timestamp) || updated;
      }
    }

    if (updated) {
      unawaited(_persistContacts());
      if (notify) {
        notifyListeners();
      }
    }
  }

  bool _pathMatchesContact(Uint8List pathBytes, Uint8List publicKey) {
    if (pathBytes.isEmpty || publicKey.isEmpty) return false;
    for (final hashSize in [3, 2, 1]) {
      if (pathBytes.length % hashSize != 0) continue;
      if (pathBytesMatchPublicKey(
        pathBytes,
        publicKey,
        hashSizeBytes: hashSize,
      )) {
        return true;
      }
    }
    return false;
  }

  Future<void> _handleIncomingMessage(Uint8List frame) async {
    if (_selfPublicKey == null) return;

    var message = _parseContactMessage(frame);

    // If message parsing failed due to unknown contact, refresh contacts and retry
    if (message == null && !_isLoadingContacts) {
      final senderPrefix = _extractSenderPrefix(frame);
      if (senderPrefix != null) {
        final hasContact = _contacts.any(
          (c) => _matchesPrefix(c.publicKey, senderPrefix),
        );
        if (!hasContact) {
          debugPrint(
            'Received message from unknown contact, refreshing contacts...',
          );
          try {
            await refreshContactsSinceLastmod();
          } catch (e) {
            appLogger.warn(
              'Contact refresh failed, dropping message: $e',
              tag: 'Connector',
            );
          }
          // Retry parsing after refresh
          message = _parseContactMessage(frame);
          if (message != null) {
            debugPrint('Successfully parsed message after contact refresh');
          }
        }
      }
    }

    if (message != null) {
      // Ignore messages from self (device hearing its own broadcast)
      // BUT allow repeated messages (pathLength indicates it went through repeater)
      if (_selfPublicKey != null &&
          message.senderKeyHex == pubKeyToHex(_selfPublicKey!) &&
          (message.pathLength == null || message.pathLength == 0)) {
        debugPrint('Ignoring direct message from self');
        return;
      }

      final contact = _contacts.cast<Contact?>().firstWhere(
        (c) => c?.publicKeyHex == message!.senderKeyHex,
        orElse: () => null,
      );
      if (contact != null) {
        message = message.copyWith(
          pathLength: contact.pathLength < 0 ? -1 : contact.pathLength,
          pathBytes: contact.pathLength < 0 ? Uint8List(0) : contact.path,
        );
      }
      if (contact != null) {
        _updateContactLastMessageAt(contact.publicKeyHex, message.timestamp);
      }
      if (!message.isOutgoing) {
        final existing = _conversations[message.senderKeyHex];
        final incomingTimestamp = message.timestamp.millisecondsSinceEpoch;
        if (existing != null && existing.isNotEmpty) {
          final startIndex = existing.length > 10 ? existing.length - 10 : 0;
          for (int i = existing.length - 1; i >= startIndex; i--) {
            final recent = existing[i];
            if (!recent.isOutgoing &&
                recent.timestamp.millisecondsSinceEpoch == incomingTimestamp &&
                recent.text == message.text) {
              if (_isSyncingQueuedMessages) {
                _handleQueuedMessageReceived();
              }
              return;
            }
          }
        }
      }
      // VE3/IE4 are intentionally retained as visible envelope messages.  The
      // binary stream is registered here so fragments can arrive before or
      // after the user opens the conversation.
      _addMessage(message.senderKeyHex, message);
      _maybeIncrementContactUnread(message);
      notifyListeners();

      // Show notification for new incoming message
      if (!message.isOutgoing && !message.isCli) {
        if (contact?.type == advTypeChat) {
          _notifications.notifyDirectMessage(
            senderKeyHex: message.senderKeyHex,
            senderName: contact?.name ?? 'Unknown',
            text: message.text,
          );
        } else if (contact?.type == advTypeRoom) {
          // Room messages carry a four-character sender prefix the user
          // should not see in the notification.
          _notifications.notifyDirectMessage(
            senderKeyHex: message.senderKeyHex,
            senderName: contact?.name ?? 'Unknown Room',
            text: message.text.length > 4
                ? message.text.substring(4)
                : message.text,
            isRoom: true,
          );
        }
      }
      _handleQueuedMessageReceived();
    } else if (_isSyncingQueuedMessages) {
      _handleQueuedMessageReceived();
    }
  }

  @visibleForTesting
  Message? parseContactMessageForTest(Uint8List frame) =>
      _parseContactMessage(frame);

  Message? _parseContactMessage(Uint8List frame) {
    if (frame.isEmpty) return null;
    final code = frame[0];
    if (code != respCodeContactMsgRecv && code != respCodeContactMsgRecvV3) {
      return null;
    }

    // Companion radio layout:
    // [code][snr?][res?][res?][prefix x6][path_len][txt_type][timestamp x4][extra?][text...]
    final prefixOffset = code == respCodeContactMsgRecvV3 ? 4 : 1;
    const prefixLen = 6;
    final pathLenOffset = prefixOffset + prefixLen;
    final txtTypeOffset = pathLenOffset + 1;
    final timestampOffset = txtTypeOffset + 1;
    final baseTextOffset = timestampOffset + 4;

    if (frame.length < baseTextOffset + 4) return null;
    final fourBytePubMSG = frame.sublist(baseTextOffset, baseTextOffset + 4);
    final senderPrefix = frame.sublist(prefixOffset, prefixOffset + prefixLen);
    final flags = frame[txtTypeOffset];
    final shiftedType = flags >> 2;
    final rawType = flags;
    final isPlain = shiftedType == txtTypePlain || rawType == txtTypePlain;
    final isCli = shiftedType == txtTypeCliData || rawType == txtTypeCliData;
    if (!isPlain && !isCli) {
      return null;
    }

    // Try base text offset; if empty and there is room for the optional 4-byte extra
    // (used by signed/plain variants), try again skipping those bytes.
    var text = readCString(
      frame,
      baseTextOffset,
      frame.length - baseTextOffset,
    );
    if (text.isEmpty && frame.length > baseTextOffset + 4) {
      text = readCString(
        frame,
        baseTextOffset + 4,
        frame.length - (baseTextOffset + 4),
      );
    }
    if (text.isEmpty) return null;
    final decodedText = isCli ? text : (Smaz.tryDecodePrefixed(text) ?? text);

    final timestampRaw = readUint32LE(frame, timestampOffset);
    final pathLenByte = frame[pathLenOffset];

    final contact = _contacts.cast<Contact?>().firstWhere(
      (c) => c != null && _matchesPrefix(c.publicKey, senderPrefix),
      orElse: () => null,
    );
    if (contact == null) return null;

    final parsedPath = parsePathLengthField(
      pathLenByte,
      fallbackHashSizeBytes: _currentPathHashSizeBytes(),
    );

    return Message(
      senderKey: contact.publicKey,
      text: decodedText,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampRaw * 1000),
      isOutgoing: false,
      isCli: isCli,
      status: MessageStatus.delivered,
      pathLength: pathLenByte == 0xFF ? 0 : parsedPath.hopCount,
      pathBytes: Uint8List(0),
      fourByteRoomContactKey: fourBytePubMSG,
    );
  }

  bool _matchesPrefix(Uint8List fullKey, Uint8List prefix) {
    if (fullKey.length < prefix.length) return false;
    for (int i = 0; i < prefix.length; i++) {
      if (fullKey[i] != prefix[i]) return false;
    }
    return true;
  }

  Uint8List? _extractSenderPrefix(Uint8List frame) {
    if (frame.isEmpty) return null;
    final code = frame[0];
    if (code != respCodeContactMsgRecv && code != respCodeContactMsgRecvV3) {
      return null;
    }

    final prefixOffset = code == respCodeContactMsgRecvV3 ? 4 : 1;
    const prefixLen = 6;

    if (frame.length < prefixOffset + prefixLen) return null;

    return frame.sublist(prefixOffset, prefixOffset + prefixLen);
  }

  void _ensureContactSmazSettingLoaded(String contactKeyHex) {
    if (_contactSmazEnabled.containsKey(contactKeyHex)) return;
    _contactSettingsStore.loadSmazEnabled(contactKeyHex).then((enabled) {
      if (_contactSmazEnabled[contactKeyHex] == enabled) return;
      _contactSmazEnabled[contactKeyHex] = enabled;
      notifyListeners();
    });
  }

  /// Prepares contact outbound text by applying SMAZ encoding if enabled.
  /// This should be used to transform text before computing ACK hashes.
  String prepareContactOutboundText(Contact contact, String text) {
    final trimmed = text.trim();
    final isStructuredPayload =
        trimmed.startsWith('g:') ||
        trimmed.startsWith('a:') ||
        trimmed.startsWith('V1|');
    if (!isStructuredPayload && isContactSmazEnabled(contact.publicKeyHex)) {
      return Smaz.encodeIfSmaller(text);
    }
    return text;
  }

  String _channelDisplayName(int channelIndex) {
    for (final channel in _channels) {
      if (channel.index != channelIndex) continue;
      return channel.name.isEmpty ? 'Channel $channelIndex' : channel.name;
    }
    return 'Channel $channelIndex';
  }

  void _maybeNotifyChannelMessage(
    ChannelMessage message, {
    String? channelName,
  }) {
    if (message.isOutgoing) return;
    final channelIndex = message.channelIndex;
    if (channelIndex == null) return;

    if (_findChannelByIndex(channelIndex)?.isWeatherChannel == true ||
        Channel.isWeatherChannelName(channelName ?? '')) {
      return;
    }
    _notifications.notifyChannelMessage(
      channelIndex: channelIndex,
      channelName: channelName ?? _channelDisplayName(channelIndex),
      senderName: message.senderName,
      text: message.text,
    );
  }

  void _handleIncomingChannelMessage(Uint8List frame) {
    final message = ChannelMessage.fromFrame(
      frame,
      fallbackHashSizeBytes: _currentPathHashSizeBytes(),
    );
    if (message != null && message.channelIndex != null) {
      if (_shouldDropSelfChannelMessage(
        message.senderName,
        message.pathBytes,
      )) {
        return;
      }
      _updateContactLastMessageAtByName(
        message.senderName,
        message.timestamp,
        pathBytes: message.pathBytes,
      );
      final isNew = _addChannelMessage(message.channelIndex!, message);
      _maybeIncrementChannelUnread(message, isNew: isNew);
      notifyListeners();
      if (isNew) {
        _maybeNotifyChannelMessage(message);
      }
      _handleQueuedMessageReceived();
    } else if (_isSyncingQueuedMessages) {
      _handleQueuedMessageReceived();
    }
  }

  void _handleLogRxData(Uint8List frame) {
    if (frame.length < 4) return;
    final raw = Uint8List.fromList(frame.sublist(3));
    final packet = _parseRawPacket(raw);
    if (packet == null || packet.payloadType != _payloadTypeGroupText) return;

    final payload = packet.payload;
    if (payload.length <= meshcoreCipherMacSize) return;
    final channelHash = payload[0];
    final encrypted = Uint8List.fromList(payload.sublist(1));

    // Use cached channels as fallback if live channels not yet loaded
    final channelsToSearch = _channels.isNotEmpty ? _channels : _cachedChannels;
    for (final channel in channelsToSearch) {
      if (channel.isEmpty) continue;
      final hash = computeChannelHash(channel.psk);
      if (hash != channelHash) continue;

      final decrypted = decryptChannelPayload(channel.psk, encrypted);
      if (decrypted == null || decrypted.length < 6) continue;

      final txtType = decrypted[4];
      if ((txtType >> 2) != 0) {
        return;
      }

      final timestampRaw = readUint32LE(decrypted, 0);
      final text = readCString(decrypted, 5, decrypted.length - 5);
      final parsed = _splitSenderText(text);
      final decodedText = Smaz.tryDecodePrefixed(parsed.text) ?? parsed.text;
      if (_shouldDropSelfChannelMessage(parsed.senderName, packet.pathBytes)) {
        return;
      }

      final message = ChannelMessage(
        senderKey: null,
        senderName: parsed.senderName,
        text: decodedText,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestampRaw * 1000),
        isOutgoing: false,
        status: ChannelMessageStatus.sent,
        pathLength: packet.pathLenByte == 0
            ? 0
            : decodePathHopCount(packet.pathLenByte),
        pathBytes: packet.pathBytes,
        channelIndex: channel.index,
      );

      _updateContactLastMessageAtByName(
        parsed.senderName,
        message.timestamp,
        pathBytes: message.pathBytes,
      );
      final isNew = _addChannelMessage(channel.index, message);
      _maybeIncrementChannelUnread(message, isNew: isNew);
      notifyListeners();
      if (isNew) {
        final label = channel.name.isEmpty
            ? 'Channel ${channel.index}'
            : channel.name;
        _maybeNotifyChannelMessage(message, channelName: label);
      }
      return;
    }
  }

  void _handleMessageSent(Uint8List frame) {
    // Frame format from C++:
    // [0] = RESP_CODE_SENT
    // [1] = is_flood (1 or 0)
    // [2-5] = expected_ack_hash (uint32)
    // [6-9] = estimated_timeout_ms (uint32)

    if (frame.length >= 10) {
      final ackHash = Uint8List.fromList(frame.sublist(2, 6));
      final timeoutMs = readUint32LE(frame, 6);

      if (_handleRepeaterCommandSent(ackHash, timeoutMs)) {
        return;
      }

      final retryService = _retryService;
      if (retryService != null &&
          retryService.updateMessageFromSent(ackHash, timeoutMs)) {
        return;
      }

      if (_pendingCompanionCliSents > 0) {
        _pendingCompanionCliSents--;
        debugPrint('Ignoring companion CLI RESP_CODE_SENT (no hash track)');
        return;
      }

      if (_markNextPendingChannelMessageSent()) {
        return;
      }

      // No hash match and no queued channel send: fail closed rather than
      // guessing. Marking an arbitrary pending message "sent" here can attach
      // this ACK to the wrong DM. Unmatched SENT frames are dropped.
      debugPrint('Unmatched RESP_CODE_SENT; dropping (no hash correlation)');
    } else {
      // A SENT frame shorter than 10 bytes carries no ack hash, so it cannot be
      // correlated to a specific outgoing message. Drop it instead of guessing.
      debugPrint('Ignoring short RESP_CODE_SENT frame len=${frame.length}');
    }
  }

  bool _markNextPendingChannelMessageSent() {
    while (_pendingChannelSentQueue.isNotEmpty) {
      final queuedMessageId = _pendingChannelSentQueue.removeAt(0);
      _cancelPendingGenericAckForQueueId(queuedMessageId);
      if (_isReactionSendQueueId(queuedMessageId)) {
        _cancelChannelSendTimeout(queuedMessageId);
        _applyPendingOutgoingChannelReaction(queuedMessageId);
        return true;
      }
      if (_markPendingChannelMessageSentById(queuedMessageId)) {
        return true;
      }
    }
    return false;
  }

  bool _markPendingChannelMessageSentById(String messageId) {
    for (final entry in _channelMessages.entries) {
      final channelMessages = entry.value;
      for (int i = channelMessages.length - 1; i >= 0; i--) {
        final message = channelMessages[i];
        if (message.messageId != messageId) {
          continue;
        }
        if (!message.isOutgoing ||
            message.status != ChannelMessageStatus.pending) {
          return false;
        }
        channelMessages[i] = message.copyWith(
          status: ChannelMessageStatus.sent,
        );
        _pendingChannelSentQueue.remove(messageId);
        _cancelChannelSendTimeout(messageId);
        unawaited(_saveChannelMessages(entry.key, channelMessages));
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void _handleOk() {
    if (_pendingGenericAckQueue.isEmpty) {
      return;
    }

    final pendingAck = _pendingGenericAckQueue.removeAt(0);
    pendingAck.responseReceived = true;
    // This OK belongs to a command we already gave up on; consuming the slot
    // is the whole point, so stop rather than stealing the next one's ACK.
    if (pendingAck.cancelled) return;
    if (pendingAck.commandCode == cmdImportContact) {
      pendingAck.completion?.call(true);
      return;
    }
    if (pendingAck.commandCode != cmdSendChannelTxtMsg ||
        pendingAck.channelSendQueueId == null) {
      return;
    }

    final queueId = pendingAck.channelSendQueueId!;
    _pendingChannelSentQueue.remove(queueId);
    if (_isReactionSendQueueId(queueId)) {
      _cancelChannelSendTimeout(queueId);
      _applyPendingOutgoingChannelReaction(queueId);
      return;
    }
    _markPendingChannelMessageSentById(queueId);
  }

  void _handleSendConfirmed(Uint8List frame) {
    // Frame format from C++:
    // [0] = PUSH_CODE_SEND_CONFIRMED
    // [1-4] = ack_hash (uint32)
    // [5-8] = trip_time_ms (uint32)

    if (frame.length >= 9) {
      final ackHash = Uint8List.fromList(frame.sublist(1, 5));
      final tripTimeMs = readUint32LE(frame, 5);

      // Companion local CLI SENTs are filtered in _handleMessageSent.
      if (_handleRepeaterCommandAck(ackHash, tripTimeMs)) {
        return;
      }

      // Handle ACK in retry service
      if (_retryService != null) {
        _retryService!.handleAckReceived(ackHash, tripTimeMs);
      }
    } else {
      // A CONFIRMED frame shorter than 9 bytes carries no ack hash, so it
      // cannot be correlated to a specific message. Marking an arbitrary "sent"
      // DM as delivered here would attach the confirmation to the wrong
      // message, so drop it (mirrors the RESP_CODE_SENT handling).
      debugPrint(
        'Ignoring short PUSH_CODE_SEND_CONFIRMED frame len=${frame.length}',
      );
    }
  }

  bool _handleRepeaterCommandSent(Uint8List ackHash, int timeoutMs) {
    final ackHashHex = ackHash
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final entry = _pendingRepeaterAcks[ackHashHex];
    if (entry == null) return false;

    entry.timeout?.cancel();
    final effectiveTimeoutMs = timeoutMs > 0
        ? timeoutMs
        : calculateTimeout(
            pathLength: entry.pathLength,
            messageBytes: entry.messageBytes,
          );
    entry.timeout = Timer(Duration(milliseconds: effectiveTimeoutMs), () {
      _recordPathResult(entry.contactKeyHex, entry.selection, false, null);
      _pendingRepeaterAcks.remove(ackHashHex);
    });
    return true;
  }

  bool _handleRepeaterCommandAck(Uint8List ackHash, int tripTimeMs) {
    final ackHashHex = ackHash
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final entry = _pendingRepeaterAcks.remove(ackHashHex);
    if (entry == null) return false;
    entry.timeout?.cancel();
    _recordPathResult(entry.contactKeyHex, entry.selection, true, tripTimeMs);
    return true;
  }

  void _handleChannelInfo(Uint8List frame) {
    final channel = Channel.fromFrame(frame);
    if (channel == null) return;

    debugPrint(
      '[ChannelSync] Received channel ${channel.index}: ${channel.isEmpty ? "empty" : channel.name}',
    );

    // Preserve unread count from cached channel
    final cachedChannel = _cachedChannels.cast<Channel?>().firstWhere(
      (c) => c?.index == channel.index,
      orElse: () => null,
    );
    if (cachedChannel != null) {
      channel.unreadCount = cachedChannel.unreadCount;
      channel.isFavorite = cachedChannel.isFavorite;
    }

    // If we're syncing and this is the channel we're waiting for
    if (_isSyncingChannels && _channelSyncInFlight) {
      if (channel.index == _nextChannelIndexToRequest) {
        // Expected channel arrived
        _channelSyncTimeout?.cancel();
        _channelSyncInFlight = false;
        _channelSyncRetries = 0; // Reset retry counter on success

        // Only add non-empty channels
        if (!channel.isEmpty) {
          _channels.add(channel);
        }

        // Move to next channel
        _nextChannelIndexToRequest++;
        unawaited(_requestNextChannel());
        return;
      } else {
        // Received a channel but not the one we're waiting for
        // This can happen if device sends unsolicited updates
        debugPrint(
          '[ChannelSync] Received unexpected channel ${channel.index}, expected $_nextChannelIndexToRequest',
        );
        // Add it anyway but don't advance sync
        if (!channel.isEmpty &&
            !_channels.any((c) => c.index == channel.index)) {
          _channels.add(channel);
        }
        return;
      }
    }

    // Not syncing, or received unsolicited update - handle normally
    if (!channel.isEmpty) {
      // Update or add channel
      final existingIndex = _channels.indexWhere(
        (c) => c.index == channel.index,
      );
      if (existingIndex >= 0) {
        // Preserve unread count and favorite state from existing channel
        channel.unreadCount = _channels[existingIndex].unreadCount;
        channel.isFavorite = _channels[existingIndex].isFavorite;
        _channels[existingIndex] = channel;
      } else {
        _channels.add(channel);
      }
    }

    // Only notify if not in loading state
    if (!_isLoadingChannels) {
      _applyChannelOrder();
      notifyListeners();
    }
  }

  void _applyChannelOrder() {
    if (_channelOrder.isEmpty) {
      _channels.sort((a, b) => a.index.compareTo(b.index));
      return;
    }

    final orderIndex = <int, int>{};
    for (int i = 0; i < _channelOrder.length; i++) {
      orderIndex[_channelOrder[i]] = i;
    }

    _channels.sort((a, b) {
      final aPos = orderIndex[a.index];
      final bPos = orderIndex[b.index];
      if (aPos != null && bPos != null) return aPos.compareTo(bPos);
      if (aPos != null) return -1;
      if (bPos != null) return 1;
      return a.index.compareTo(b.index);
    });
  }

  Future<void> setChannelOrder(List<int> order) async {
    _channelOrder = List<int>.from(order);
    _applyChannelOrder();
    notifyListeners();
    if (!_isDemoMode) {
      await _channelOrderStore.saveChannelOrder(_channelOrder);
    }
  }

  bool _shouldTrackUnreadForContactKey(String contactKeyHex) {
    final contact = _contacts.cast<Contact?>().firstWhere(
      (c) => c?.publicKeyHex == contactKeyHex,
      orElse: () => null,
    );
    if (contact == null) return true;
    return contact.type != advTypeRepeater;
  }

  Channel? _findChannelByIndex(int index) {
    return _channels.cast<Channel?>().firstWhere(
          (c) => c?.index == index,
          orElse: () => null,
        ) ??
        _cachedChannels.cast<Channel?>().firstWhere(
          (c) => c?.index == index,
          orElse: () => null,
        );
  }

  void _maybeIncrementChannelUnread(
    ChannelMessage message, {
    required bool isNew,
  }) {
    if (!isNew || message.isOutgoing) {
      _appDebugLogService?.info(
        'Skip unread increment: isNew=$isNew, isOutgoing=${message.isOutgoing}',
        tag: 'Unread',
      );
      return;
    }
    if (!ChannelMessagePreview.shouldNotify(message.text)) {
      _appDebugLogService?.info(
        'Skip unread increment: tactical position update',
        tag: 'Unread',
      );
      return;
    }
    final channelIndex = message.channelIndex;
    if (channelIndex == null) {
      _appDebugLogService?.info(
        'Skip unread increment: channelIndex is null',
        tag: 'Unread',
      );
      return;
    }
    if (_findChannelByIndex(channelIndex)?.isWeatherChannel == true) return;
    // Don't increment if user is viewing this channel
    if (_activeChannelIndex == channelIndex) {
      _appDebugLogService?.info(
        'Skip unread increment: channel $channelIndex is active',
        tag: 'Unread',
      );
      return;
    }

    final channel = _findChannelByIndex(channelIndex);
    if (channel != null) {
      channel.unreadCount++;
      _appDebugLogService?.info(
        'Channel ${channel.name.isNotEmpty ? channel.name : channelIndex} unread count incremented to ${channel.unreadCount}',
        tag: 'Unread',
      );
      if (!_isDemoMode) {
        unawaited(
          _channelStore.saveChannels(
            _channels.isNotEmpty ? _channels : _cachedChannels,
          ),
        );
      }
    } else {
      _appDebugLogService?.info(
        'Channel $channelIndex not found in _channels (${_channels.length}) or _cachedChannels (${_cachedChannels.length})',
        tag: 'Unread',
      );
    }
  }

  void _maybeIncrementContactUnread(Message message) {
    if (message.isOutgoing || message.isCli) {
      _appDebugLogService?.info(
        'Skip contact unread increment: isOutgoing=${message.isOutgoing}, isCli=${message.isCli}',
        tag: 'Unread',
      );
      return;
    }
    final contactKey = message.senderKeyHex;
    if (!_shouldTrackUnreadForContactKey(contactKey)) {
      _appDebugLogService?.info(
        'Skip contact unread increment: should not track for $contactKey',
        tag: 'Unread',
      );
      return;
    }
    // Don't increment if user is viewing this contact
    if (_activeContactKey == contactKey) {
      _appDebugLogService?.info(
        'Skip contact unread increment: contact $contactKey is active',
        tag: 'Unread',
      );
      return;
    }

    final currentCount = _contactUnreadCount[contactKey] ?? 0;
    _contactUnreadCount[contactKey] = currentCount + 1;
    _appDebugLogService?.info(
      'Contact $contactKey unread count incremented to ${currentCount + 1}',
      tag: 'Unread',
    );
    if (!_isDemoMode) {
      _unreadStore.saveContactUnreadCount(
        Map<String, int>.from(_contactUnreadCount),
      );
    }
  }

  void _addMessage(String pubKeyHex, Message message) {
    _conversations.putIfAbsent(pubKeyHex, () => []);
    final messages = _conversations[pubKeyHex]!;
    final conversationLoaded = _loadedConversationKeys.contains(pubKeyHex);

    // Parse edit info. Edits are control messages, never shown as bubbles.
    final editInfo = EditHelper.parseEditText(message.text);
    if (editInfo != null) {
      // Outgoing edits are applied locally as soon as the user requests them
      // (see editMessage); only wait here for the on-air confirmation before
      // matching the same edit again.
      if (message.isOutgoing && message.status == MessageStatus.pending) {
        return;
      }
      _processedContactEdits.putIfAbsent(pubKeyHex, () => {});
      final editorIsSelf = message.isOutgoing;
      final editIdentifier =
          '${editInfo.targetHash}_${editorIsSelf ? 'self' : pubKeyHex}';
      final isDuplicate = _processedContactEdits[pubKeyHex]!.contains(
        editIdentifier,
      );
      if (!isDuplicate) {
        final applied = _processContactEdit(
          messages,
          editInfo,
          editorIsSelf: editorIsSelf,
        );
        if (!applied) {
          _queuePendingContactEdit(pubKeyHex, editInfo, editorIsSelf);
        } else {
          _processedContactEdits[pubKeyHex]!.add(editIdentifier);
        }
        if (conversationLoaded) {
          _saveConversationMessages(pubKeyHex, messages);
        } else {
          unawaited(_loadMessagesForContact(pubKeyHex));
        }
        notifyListeners();
      }
      return; // Don't add the edit as a visible message
    }

    // Parse reaction info
    final reactionInfo = ReactionHelper.parseAnyReaction(message.text);
    if (reactionInfo != null) {
      // Outgoing reactions are optimistic protocol messages. Do not alter the
      // target until RESP_CODE_SENT confirms that the companion accepted the
      // frame; failed retries must not leave a reaction visible only locally.
      if (message.isOutgoing && message.status == MessageStatus.pending) {
        return;
      }
      // Check if we've already processed this exact reaction
      _processedContactReactions.putIfAbsent(pubKeyHex, () => {});
      final reactor = message.isOutgoing
          ? (_selfPublicKey == null ? 'self' : pubKeyToHex(_selfPublicKey!))
          : pubKeyHex;
      final reactionIdentifier = _reactionIdentifier(reactionInfo, reactor);

      final isDuplicate = _processedContactReactions[pubKeyHex]!.contains(
        reactionIdentifier,
      );

      if (!isDuplicate) {
        // New reaction - process it
        final applied = _processContactReaction(
          messages,
          reactionInfo,
          pubKeyHex,
          reactor: reactor,
        );
        if (!applied) {
          _queuePendingContactReaction(pubKeyHex, reactionInfo, reactor);
        } else {
          _processedContactReactions[pubKeyHex]!.add(reactionIdentifier);
        }
        if (conversationLoaded) {
          _saveConversationMessages(pubKeyHex, messages);
        } else {
          unawaited(_loadMessagesForContact(pubKeyHex));
        }

        notifyListeners();
      }
      return; // Don't add reaction as a visible message
    }

    messages.add(message);
    _resolvePendingContactReactions(pubKeyHex);
    _resolvePendingContactEdits(pubKeyHex);
    if (conversationLoaded) {
      _saveConversationMessages(pubKeyHex, messages);
    } else {
      // Avoid writing a partial list over full disk history while load is pending.
      unawaited(_loadMessagesForContact(pubKeyHex));
    }
    notifyListeners();
  }

  bool _processContactEdit(
    List<Message> messages,
    EditInfo editInfo, {
    required bool editorIsSelf,
  }) {
    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];
      if (msg.isOutgoing != editorIsSelf) continue;
      final timestamp = msg.timestamp.millisecondsSinceEpoch ~/ 1000;
      if (ReactionHelper.generateMessageHash(msg.text, timestamp) !=
          editInfo.targetHash) {
        continue;
      }
      messages[i] = msg.copyWith(
        text: editInfo.newText,
        edited: true,
        editedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  void _queuePendingContactEdit(
    String contactKey,
    EditInfo info,
    bool editorIsSelf,
  ) {
    _pendingContactEdits
        .putIfAbsent(contactKey, () => [])
        .add(_PendingEdit(info: info, editorIsSelf: editorIsSelf));
    _trimPendingEdits();
  }

  void _resolvePendingContactEdits(String contactKey) {
    final pending = _pendingContactEdits[contactKey];
    final messages = _conversations[contactKey];
    if (pending == null || pending.isEmpty || messages == null) return;
    pending.removeWhere((entry) {
      final id =
          '${entry.info.targetHash}_${entry.editorIsSelf ? 'self' : contactKey}';
      if (_processedContactEdits[contactKey]?.contains(id) == true) {
        return true;
      }
      final applied = _processContactEdit(
        messages,
        entry.info,
        editorIsSelf: entry.editorIsSelf,
      );
      if (applied) {
        _processedContactEdits.putIfAbsent(contactKey, () => {}).add(id);
      }
      return applied;
    });
    if (pending.isEmpty) _pendingContactEdits.remove(contactKey);
  }

  void _trimPendingEdits() {
    var count = _pendingContactEdits.values.fold<int>(
      0,
      (sum, values) => sum + values.length,
    );
    count += _pendingChannelEdits.values.fold<int>(
      0,
      (sum, values) => sum + values.length,
    );
    while (count > _maxPendingReactions) {
      final contact = _pendingContactEdits.entries.firstWhere(
        (entry) => entry.value.isNotEmpty,
        orElse: () => const MapEntry('', <_PendingEdit>[]),
      );
      if (contact.key.isNotEmpty) {
        contact.value.removeAt(0);
        if (contact.value.isEmpty) _pendingContactEdits.remove(contact.key);
        count--;
        continue;
      }
      final channel = _pendingChannelEdits.entries.firstWhere(
        (entry) => entry.value.isNotEmpty,
        orElse: () => const MapEntry(-1, <_PendingEdit>[]),
      );
      if (channel.key == -1) break;
      channel.value.removeAt(0);
      if (channel.value.isEmpty) _pendingChannelEdits.remove(channel.key);
      count--;
    }
  }

  bool _processContactReaction(
    List<Message> messages,
    ReactionInfo reactionInfo,
    String contactPubKeyHex, {
    required String reactor,
  }) {
    if (reactor.isEmpty) return false;
    // Find target message by computing hash and comparing
    final contact = _contacts.cast<Contact?>().firstWhere(
      (c) => c?.publicKeyHex == contactPubKeyHex,
      orElse: () => null,
    );
    final isRoomServer = contact?.type == advTypeRoom;

    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];

      // For 1:1 chats: contact reacts to my outgoing messages only
      // For room servers: any message can be reacted to (multi-user)
      if (!isRoomServer && !msg.isOutgoing) continue;
      if (_contactReactionMatches(msg, reactionInfo, isRoomServer)) {
        final currentReactions = Map<String, int>.from(msg.reactions);
        currentReactions[reactionInfo.emoji] =
            (currentReactions[reactionInfo.emoji] ?? 0) + 1;

        messages[i] = msg.copyWith(reactions: currentReactions);
        return true;
      }
    }
    return false;
  }

  String _reactionIdentifier(ReactionInfo info, String reactor) =>
      '${info.targetHash}_${info.emoji}_$reactor';

  bool _contactReactionMatches(
    Message message,
    ReactionInfo info,
    bool isRoomServer,
  ) {
    final timestamp = message.timestamp.millisecondsSinceEpoch ~/ 1000;
    if (info.isMeshCoreOne) {
      if (info.targetSender != null &&
          info.targetSender != _senderNameForMessage(message)) {
        return false;
      }
      return ReactionHelper.generateMessageHash(message.text, timestamp) ==
          info.targetHash;
    }
    if (info.isLegacyV1) {
      if (info.timestampSeconds != timestamp) return false;
      final senderName = isRoomServer ? _senderNameForMessage(message) : null;
      return ReactionHelper.dartStringHash(senderName ?? '') ==
              info.senderNameHash &&
          ReactionHelper.dartStringHash(message.text) == info.textHash;
    }
    final senderName = isRoomServer ? _senderNameForMessage(message) : null;
    return ReactionHelper.computeReactionHash(
          timestamp,
          senderName,
          message.text,
        ) ==
        info.targetHash;
  }

  String? _senderNameForMessage(Message message) {
    if (message.isOutgoing) return _selfName ?? selfName;
    if (message.fourByteRoomContactKey.isEmpty) return null;
    for (final contact in _contacts) {
      if (_matchesPrefix(contact.publicKey, message.fourByteRoomContactKey)) {
        return contact.name;
      }
    }
    return null;
  }

  void _queuePendingContactReaction(
    String contactKey,
    ReactionInfo info,
    String reactor,
  ) {
    final pending = _pendingContactReactions.putIfAbsent(contactKey, () => []);
    pending.add(_PendingReaction(info: info, reactor: reactor));
    _trimPendingReactions();
  }

  void _resolvePendingContactReactions(String contactKey) {
    final pending = _pendingContactReactions[contactKey];
    final messages = _conversations[contactKey];
    if (pending == null || pending.isEmpty || messages == null) return;
    pending.removeWhere((entry) {
      final id = _reactionIdentifier(entry.info, entry.reactor);
      if (_processedContactReactions[contactKey]?.contains(id) == true) {
        return true;
      }
      final applied = _processContactReaction(
        messages,
        entry.info,
        contactKey,
        reactor: entry.reactor,
      );
      if (applied) {
        _processedContactReactions.putIfAbsent(contactKey, () => {}).add(id);
      }
      return applied;
    });
    if (pending.isEmpty) _pendingContactReactions.remove(contactKey);
  }

  void _trimPendingReactions() {
    var count = _pendingContactReactions.values.fold<int>(
      0,
      (sum, values) => sum + values.length,
    );
    count += _pendingChannelReactions.values.fold<int>(
      0,
      (sum, values) => sum + values.length,
    );
    while (count > _maxPendingReactions) {
      final first = _pendingContactReactions.entries.firstWhere(
        (entry) => entry.value.isNotEmpty,
        orElse: () => const MapEntry('', <_PendingReaction>[]),
      );
      if (first.key.isNotEmpty) {
        first.value.removeAt(0);
        if (first.value.isEmpty) _pendingContactReactions.remove(first.key);
      } else {
        final channel = _pendingChannelReactions.entries.firstWhere(
          (entry) => entry.value.isNotEmpty,
          orElse: () => const MapEntry(-1, <_PendingReaction>[]),
        );
        if (channel.key == -1) break;
        channel.value.removeAt(0);
        if (channel.value.isEmpty) _pendingChannelReactions.remove(channel.key);
      }
      count--;
    }
  }

  String _canonicalizeContactReaction(Contact contact, String text) {
    final info = ReactionHelper.parseAnyReaction(text);
    if (info == null || info.isMeshCoreOne) return text;
    final messages = _conversations[contact.publicKeyHex] ?? const <Message>[];
    final isRoom = contact.type == advTypeRoom;
    for (final message in messages.reversed) {
      if (!message.isOutgoing && !isRoom) continue;
      if (!_contactReactionMatches(message, info, isRoom)) continue;
      final sender = _senderNameForMessage(message);
      if (isRoom && sender != null && sender.isNotEmpty) {
        return ReactionHelper.buildMeshCoreOneChannelReaction(
          emoji: info.emoji,
          targetSender: sender,
          targetText: message.text,
          targetTimestamp: message.timestamp.millisecondsSinceEpoch ~/ 1000,
        );
      }
      return ReactionHelper.buildMeshCoreOneDMReaction(
        emoji: info.emoji,
        targetText: message.text,
        targetTimestamp: message.timestamp.millisecondsSinceEpoch ~/ 1000,
      );
    }
    return text;
  }

  String _canonicalizeChannelReaction(int channelIndex, String text) {
    final info = ReactionHelper.parseAnyReaction(text);
    if (info == null || info.isMeshCoreOne) return text;
    final messages = _channelMessages[channelIndex] ?? const <ChannelMessage>[];
    for (final message in messages.reversed) {
      if (!_channelReactionMatches(message, info)) continue;
      return ReactionHelper.buildMeshCoreOneChannelReaction(
        emoji: info.emoji,
        targetSender: message.senderName,
        targetText: message.text,
        targetTimestamp: message.timestamp.millisecondsSinceEpoch ~/ 1000,
      );
    }
    return text;
  }

  bool _channelReactionMatches(ChannelMessage message, ReactionInfo info) {
    final timestamp = message.timestamp.millisecondsSinceEpoch ~/ 1000;
    if (info.isMeshCoreOne) {
      return info.targetSender == message.senderName &&
          ReactionHelper.generateMessageHash(message.text, timestamp) ==
              info.targetHash;
    }
    if (info.isLegacyV1) {
      return info.timestampSeconds == timestamp &&
          ReactionHelper.dartStringHash(message.senderName) ==
              info.senderNameHash &&
          ReactionHelper.dartStringHash(message.text) == info.textHash;
    }
    return ReactionHelper.computeReactionHash(
          timestamp,
          message.senderName,
          message.text,
        ) ==
        info.targetHash;
  }

  _RawPacket? _parseRawPacket(Uint8List raw) {
    if (raw.length < 3) return null;
    var index = 0;
    final header = raw[index++];
    final routeType = header & _phRouteMask;
    final hasTransport =
        routeType == _routeTransportFlood || routeType == _routeTransportDirect;
    if (hasTransport) {
      if (raw.length < index + 4) return null;
      index += 4;
    }
    if (raw.length <= index) return null;
    final pathLenByte = raw[index++];
    final int pathByteLen;
    if (pathLenByte == 0 || pathLenByte == 0xFF) {
      pathByteLen = 0;
    } else if ((pathLenByte & 0xC0) != 0) {
      pathByteLen =
          decodePathHopCount(pathLenByte) * decodePathHashSize(pathLenByte);
    } else {
      pathByteLen = pathLenByte * _currentPathHashSizeBytes();
    }
    if (raw.length < index + pathByteLen) return null;
    final pathBytes = Uint8List.fromList(
      raw.sublist(index, index + pathByteLen),
    );
    index += pathByteLen;
    if (raw.length <= index) return null;
    final payload = Uint8List.fromList(raw.sublist(index));

    return _RawPacket(
      header: header,
      routeType: routeType,
      payloadType: (header >> _phTypeShift) & _phTypeMask,
      payloadVer: (header >> _phVerShift) & _phVerMask,
      pathLenByte: pathLenByte,
      pathBytes: pathBytes,
      payload: payload,
    );
  }

  _ParsedText _splitSenderText(String text) {
    final colonIndex = text.indexOf(':');
    if (colonIndex > 0 && colonIndex < text.length - 1 && colonIndex < 50) {
      final potentialSender = text.substring(0, colonIndex);
      if (RegExp(r'[:\[\]]').hasMatch(potentialSender)) {
        return _ParsedText(senderName: 'Unknown', text: text);
      }
      final offset =
          (colonIndex + 1 < text.length && text[colonIndex + 1] == ' ')
          ? colonIndex + 2
          : colonIndex + 1;
      return _ParsedText(
        senderName: potentialSender,
        text: text.substring(offset),
      );
    }
    return _ParsedText(senderName: 'Unknown', text: text);
  }

  Uint8List _resolveOutgoingPathBytes(
    Contact contact,
    PathSelection? selection,
  ) {
    // Priority 1: Check user's path override
    if (contact.pathOverride != null) {
      if (contact.pathOverride! < 0) {
        return Uint8List(0); // Force flood
      }
      return contact.pathOverrideBytes ?? Uint8List(0);
    }

    // Priority 2: Check device flood mode or PathSelection flood
    if (contact.pathLength < 0 || selection?.useFlood == true) {
      return Uint8List(0);
    }

    // Priority 3: Check PathSelection (auto-rotation)
    if (selection != null && selection.pathBytes.isNotEmpty) {
      return Uint8List.fromList(selection.pathBytes);
    }

    // Priority 4: Use device's discovered path
    return contact.path;
  }

  int? _resolveOutgoingPathLength(Contact contact, PathSelection? selection) {
    // Priority 1: Check user's path override
    if (contact.pathOverride != null) {
      return contact.pathOverride;
    }

    // Priority 2: Check device flood mode or PathSelection flood
    if (contact.pathLength < 0 || selection?.useFlood == true) {
      return -1;
    }

    // Priority 3: Check PathSelection (auto-rotation)
    if (selection != null && selection.pathBytes.isNotEmpty) {
      return selection.hopCount;
    }

    // Priority 4: Use device's discovered path
    return contact.pathLength;
  }

  PathSelection _selectionFromPath(int pathLength, Uint8List pathBytes) {
    if (pathLength < 0) {
      return const PathSelection(pathBytes: [], hopCount: -1, useFlood: true);
    }
    return PathSelection(
      pathBytes: pathBytes,
      hopCount: pathLength,
      useFlood: false,
    );
  }

  bool _addChannelMessage(int channelIndex, ChannelMessage message) {
    _channelMessages.putIfAbsent(channelIndex, () => []);
    final messages = _channelMessages[channelIndex]!;
    final channelLoaded = _loadedChannelIndexes.contains(channelIndex);

    // Parse edit info. Edits are control messages, never shown as bubbles.
    final editInfo = EditHelper.parseEditText(message.text);
    if (editInfo != null) {
      _processedChannelEdits.putIfAbsent(channelIndex, () => {});
      final editor = message.isOutgoing
          ? (_selfName ?? 'self')
          : (message.senderKeyHex ?? message.senderName);
      final editIdentifier = '${editInfo.targetHash}_$editor';
      final isDuplicate = _processedChannelEdits[channelIndex]!.contains(
        editIdentifier,
      );
      if (!isDuplicate) {
        final applied = _processChannelEdit(messages, editInfo);
        if (!applied) {
          _queuePendingChannelEdit(channelIndex, editInfo);
        } else {
          _processedChannelEdits[channelIndex]!.add(editIdentifier);
        }
        if (channelLoaded) {
          _saveChannelMessages(channelIndex, messages);
        } else {
          unawaited(_loadChannelMessages(channelIndex));
        }
      }
      return false; // Don't add the edit as a visible message
    }

    // Parse reaction info
    final reactionInfo = ReactionHelper.parseAnyReaction(message.text);
    if (reactionInfo != null) {
      // Check if we've already processed this exact reaction
      _processedChannelReactions.putIfAbsent(channelIndex, () => {});
      final reactor = message.isOutgoing
          ? (_selfName ?? 'self')
          : (message.senderKeyHex ?? message.senderName);
      final reactionIdentifier = _reactionIdentifier(reactionInfo, reactor);

      final isDuplicate = _processedChannelReactions[channelIndex]!.contains(
        reactionIdentifier,
      );

      if (!isDuplicate) {
        // New reaction - process it
        final applied = _processReaction(
          messages,
          reactionInfo,
          reactor: reactor,
        );
        if (!applied) {
          _queuePendingChannelReaction(channelIndex, reactionInfo, reactor);
        }
        if (channelLoaded) {
          _saveChannelMessages(channelIndex, messages);
        } else {
          unawaited(_loadChannelMessages(channelIndex));
        }

        if (applied) {
          _processedChannelReactions[channelIndex]!.add(reactionIdentifier);
        }
      }
      return false; // Don't add reaction as a visible message
    }

    // Parse reply info from message text
    final replyInfo = ChannelMessage.parseReplyMention(message.text);
    ChannelMessage processedMessage = message;

    if (replyInfo != null) {
      // Find original message by sender name (most recent match)
      final originalMessage = _findMessageBySender(
        messages,
        replyInfo.mentionedNode,
      );

      if (originalMessage != null) {
        // Create new message with reply metadata
        processedMessage = ChannelMessage(
          senderKey: message.senderKey,
          senderName: message.senderName,
          text: replyInfo.actualMessage,
          timestamp: message.timestamp,
          isOutgoing: message.isOutgoing,
          status: message.status,
          repeats: message.repeats,
          repeatCount: message.repeatCount,
          pathLength: message.pathLength,
          pathBytes: message.pathBytes,
          pathVariants: message.pathVariants,
          channelIndex: message.channelIndex,
          messageId: message.messageId,
          replyToMessageId: originalMessage.messageId,
          replyToSenderName: originalMessage.senderName,
          replyToText: originalMessage.text,
        );
      }
    }

    final existingIndex = _findChannelRepeatIndex(messages, processedMessage);
    var isNew = true;
    if (existingIndex >= 0) {
      isNew = false;
      final existing = messages[existingIndex];
      final mergedPathBytes = _selectPreferredPathBytes(
        existing.pathBytes,
        processedMessage.pathBytes,
      );
      final mergedPathVariants = _mergePathVariants(
        existing.pathVariants,
        processedMessage.pathVariants,
      );
      final mergedPathLength = _mergePathLength(
        existing.pathLength,
        processedMessage.pathLength,
        mergedPathBytes.length,
      );
      final newRepeatCount = existing.repeatCount + 1;
      final promotedFromPending =
          newRepeatCount == 1 &&
          existing.status == ChannelMessageStatus.pending;
      messages[existingIndex] = existing.copyWith(
        repeatCount: newRepeatCount,
        pathLength: mergedPathLength,
        pathBytes: mergedPathBytes,
        pathVariants: mergedPathVariants,
        // Mark as sent when first repeat is heard
        status: promotedFromPending
            ? ChannelMessageStatus.sent
            : existing.status,
      );
      if (promotedFromPending) {
        _pendingChannelSentQueue.remove(existing.messageId);
        _cancelPendingGenericAckForQueueId(existing.messageId);
        _cancelChannelSendTimeout(existing.messageId);
      }
    } else {
      messages.add(processedMessage);
    }

    // Save only after channel history is loaded so a live message cannot
    // truncate the persisted list to a single entry.
    if (channelLoaded) {
      _saveChannelMessages(channelIndex, messages);
    } else {
      unawaited(_loadChannelMessages(channelIndex));
    }
    _resolvePendingChannelReactions(channelIndex);
    _resolvePendingChannelEdits(channelIndex);
    if (isNew &&
        !processedMessage.isOutgoing &&
        !_channelMessagesController.isClosed) {
      _channelMessagesController.add(processedMessage);
    }
    return isNew;
  }

  bool _processChannelEdit(List<ChannelMessage> messages, EditInfo editInfo) {
    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];
      if (editInfo.targetSender != null &&
          editInfo.targetSender != msg.senderName) {
        continue;
      }
      final timestamp = msg.timestamp.millisecondsSinceEpoch ~/ 1000;
      if (ReactionHelper.generateMessageHash(msg.text, timestamp) !=
          editInfo.targetHash) {
        continue;
      }
      messages[i] = msg.copyWith(
        text: editInfo.newText,
        edited: true,
        editedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  void _queuePendingChannelEdit(int channelIndex, EditInfo info) {
    _pendingChannelEdits
        .putIfAbsent(channelIndex, () => [])
        .add(_PendingEdit(info: info, editorIsSelf: false));
    _trimPendingEdits();
  }

  void _resolvePendingChannelEdits(int channelIndex) {
    final pending = _pendingChannelEdits[channelIndex];
    final messages = _channelMessages[channelIndex];
    if (pending == null || pending.isEmpty || messages == null) return;
    pending.removeWhere((entry) {
      final applied = _processChannelEdit(messages, entry.info);
      return applied;
    });
    if (pending.isEmpty) _pendingChannelEdits.remove(channelIndex);
  }

  ChannelMessage? _findMessageBySender(
    List<ChannelMessage> messages,
    String mentionedNode,
  ) {
    // Search backwards for most recent message from this sender
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].senderName == mentionedNode && !messages[i].isOutgoing) {
        return messages[i];
      }
    }
    return null;
  }

  bool _processReaction(
    List<ChannelMessage> messages,
    ReactionInfo reactionInfo, {
    required String reactor,
  }) {
    if (reactor.isEmpty) return false;
    // Find target message by computing hash and comparing
    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];
      if (_channelReactionMatches(msg, reactionInfo)) {
        final currentReactions = Map<String, int>.from(msg.reactions);
        currentReactions[reactionInfo.emoji] =
            (currentReactions[reactionInfo.emoji] ?? 0) + 1;

        messages[i] = msg.copyWith(reactions: currentReactions);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void _applyPendingOutgoingChannelReaction(String queueId) {
    final pending = _pendingOutgoingChannelReactions.remove(queueId);
    if (pending == null) return;
    _applyChannelReactionLocally(
      pending.channelIndex,
      pending.info,
      pending.reactor,
    );
  }

  void _applyChannelReactionLocally(
    int channelIndex,
    ReactionInfo reactionInfo,
    String reactor,
  ) {
    final reactionIdentifier = _reactionIdentifier(reactionInfo, reactor);
    final processed = _processedChannelReactions.putIfAbsent(
      channelIndex,
      () => {},
    );
    if (processed.contains(reactionIdentifier)) return;
    final messages = _channelMessages.putIfAbsent(channelIndex, () => []);
    final applied = _processReaction(messages, reactionInfo, reactor: reactor);
    if (applied) {
      processed.add(reactionIdentifier);
    } else {
      _queuePendingChannelReaction(channelIndex, reactionInfo, reactor);
    }
    unawaited(_saveChannelMessages(channelIndex, messages).catchError((_) {}));
    notifyListeners();
  }

  void _queuePendingChannelReaction(
    int channelIndex,
    ReactionInfo info,
    String reactor,
  ) {
    _pendingChannelReactions
        .putIfAbsent(channelIndex, () => [])
        .add(_PendingReaction(info: info, reactor: reactor));
    _trimPendingReactions();
  }

  void _resolvePendingChannelReactions(int channelIndex) {
    final pending = _pendingChannelReactions[channelIndex];
    final messages = _channelMessages[channelIndex];
    if (pending == null || pending.isEmpty || messages == null) return;
    pending.removeWhere((entry) {
      final id = _reactionIdentifier(entry.info, entry.reactor);
      if (_processedChannelReactions[channelIndex]?.contains(id) == true) {
        return true;
      }
      final applied = _processReaction(
        messages,
        entry.info,
        reactor: entry.reactor,
      );
      if (applied) {
        _processedChannelReactions.putIfAbsent(channelIndex, () => {}).add(id);
      }
      return applied;
    });
    if (pending.isEmpty) _pendingChannelReactions.remove(channelIndex);
  }

  int _findChannelRepeatIndex(
    List<ChannelMessage> messages,
    ChannelMessage incoming,
  ) {
    for (int i = messages.length - 1; i >= 0; i--) {
      final existing = messages[i];
      if (_isChannelRepeat(existing, incoming)) {
        return i;
      }
    }
    return -1;
  }

  bool _isChannelRepeat(ChannelMessage existing, ChannelMessage incoming) {
    if (existing.text != incoming.text) return false;

    final diffMs =
        (existing.timestamp.millisecondsSinceEpoch -
                incoming.timestamp.millisecondsSinceEpoch)
            .abs();
    if (diffMs > 5000) return false;

    if (existing.senderName == incoming.senderName) return true;

    if (existing.isOutgoing && !incoming.isOutgoing) {
      final selfName = _selfName ?? 'Me';
      if (incoming.senderName == selfName || existing.senderName == selfName) {
        return true;
      }
    }

    return false;
  }

  bool _shouldDropSelfChannelMessage(String senderName, Uint8List pathBytes) {
    final trimmed = senderName.trim();
    if (trimmed.isEmpty) return false;

    final selfName = _selfName?.trim();
    if (selfName == null || selfName.isEmpty) return false;

    // If sender name doesn't match, keep the message
    if (trimmed != selfName) return false;

    // Name matches - this is from self
    // Drop only if pathBytes is empty (direct broadcast)
    // Keep if pathBytes has data (repeated through another node)
    return pathBytes.isEmpty;
  }

  Uint8List _selectPreferredPathBytes(Uint8List existing, Uint8List incoming) {
    if (incoming.isEmpty) return existing;
    if (existing.isEmpty) return incoming;
    if (incoming.length > existing.length) return incoming;
    return existing;
  }

  int? _mergePathLength(int? existing, int? incoming, int observedLength) {
    if (existing == null) {
      if (incoming == null) return observedLength > 0 ? observedLength : null;
      return incoming >= observedLength ? incoming : observedLength;
    }
    if (incoming == null) {
      return existing >= observedLength ? existing : observedLength;
    }
    final merged = existing >= incoming ? existing : incoming;
    return merged >= observedLength ? merged : observedLength;
  }

  List<Uint8List> _mergePathVariants(
    List<Uint8List> existing,
    List<Uint8List> incoming,
  ) {
    if (incoming.isEmpty) return existing;
    if (existing.isEmpty) return incoming;

    final merged = <Uint8List>[...existing];
    for (final candidate in incoming) {
      var already = false;
      for (final current in merged) {
        if (_pathsEqual(current, candidate)) {
          already = true;
          break;
        }
      }
      if (!already && candidate.isNotEmpty) {
        merged.add(candidate);
      }
    }
    return merged;
  }

  bool _pathsEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _handleDisconnection() async {
    try {
      _awaitingSelfInfo = false;
      _didInitialQueueSync = false;
      _pendingQueueSync = false;
      _hasLoadedChannels = false;
      // First-connect drops must not look like a healthy-session reconnect.
      await disconnect(manual: !_hadHealthySession, immediate: true);
    } finally {
      _handlingUnexpectedDisconnect = false;
    }
  }

  static String _keepAliveTextFor(MeshCoreTransportKind? kind) {
    switch (kind) {
      case MeshCoreTransportKind.usb:
        return 'Keeping the USB connection alive';
      case MeshCoreTransportKind.tcp:
        return 'Keeping the network connection alive';
      case MeshCoreTransportKind.ble:
      case null:
        return 'Keeping BLE connected';
    }
  }

  Future<void> _ensureBackgroundKeepAlive({required bool isReconnect}) async {
    _backgroundService?.keepAliveText = _keepAliveTextFor(_activeTransportKind);
    final promptBatteryOpt = !isReconnect && !_batteryOptPrompted();
    final ok =
        await _backgroundService?.start(
          requestPermissions: !isReconnect,
          promptBatteryOptimization: promptBatteryOpt,
        ) ??
        true;
    if (promptBatteryOpt) {
      _markBatteryOptPrompted();
    }
    _backgroundKeepAliveFailed = !ok;
    if (_backgroundKeepAliveFailed) {
      _appDebugLogService?.warn(
        'Foreground keep-alive degraded; the connection may drop in the '
        'background',
      );
    }
  }

  bool _batteryOptPrompted() {
    try {
      return PrefsManager.instance.getBool(_batteryOptPrefKey) ?? false;
    } catch (_) {
      return true;
    }
  }

  void _markBatteryOptPrompted() {
    try {
      unawaited(PrefsManager.instance.setBool(_batteryOptPrefKey, true));
    } catch (_) {}
  }

  _PendingCommandAck? _trackPendingGenericAck(
    Uint8List data, {
    String? channelSendQueueId,
    required bool expectsGenericAck,
    void Function(bool success)? completion,
  }) {
    if (!expectsGenericAck || data.isEmpty) return null;
    final commandCode = data[0];
    // Only track command codes whose OK/ERR drives state: channel send
    // tracking and contact import. Other commands' ACKs are silent no-ops;
    // queuing them desyncs FIFO order when responses arrive interleaved with
    // other generic-ack senders.
    if (commandCode != cmdSendChannelTxtMsg &&
        commandCode != cmdImportContact) {
      return null;
    }
    final pending = _PendingCommandAck(
      commandCode: commandCode,
      channelSendQueueId: channelSendQueueId,
      completion: completion,
    );
    _pendingGenericAckQueue.add(pending);
    return pending;
  }

  String _nextReactionSendQueueId() {
    _reactionSendQueueSequence++;
    return '$_reactionSendQueuePrefix$_reactionSendQueueSequence';
  }

  bool _isReactionSendQueueId(String queueId) {
    return queueId.startsWith(_reactionSendQueuePrefix);
  }

  Map<String, String> _parseKeyValueString(String input) {
    final result = <String, String>{};

    // Split on commas first – empty entries are ignored.
    for (final pair in input.split(',')) {
      final trimmedPair = pair.trim();
      if (trimmedPair.isEmpty) continue;

      // Each pair must contain exactly one ':'.
      final separatorIndex = trimmedPair.indexOf(':');
      if (separatorIndex == -1) continue; // malformed, skip

      final key = trimmedPair.substring(0, separatorIndex).trim();
      final value = trimmedPair.substring(separatorIndex + 1).trim();

      if (key.isNotEmpty) {
        result[key] = value;
      }
    }

    return result;
  }

  void _handleCustomVars(Uint8List frame) {
    final buf = BufferReader(frame.sublist(1));
    try {
      _currentCustomVars = _parseKeyValueString(buf.readString());
    } catch (e) {
      appLogger.warn('Malformed custom vars frame: $e', tag: 'Connector');
    }
  }

  void _setState(MeshCoreConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _failAllPendingChannelMessages();
    _completePendingDeviceQueries();
    final disconnectOp = _disconnectOp;
    if (disconnectOp != null && !disconnectOp.isCompleted) {
      disconnectOp.complete();
    }
    _disconnectOp = null;
    _disposed = true;
    _blockedNodes?.removeListener(notifyListeners);
    _appSettingsService?.removeListener(_onAppSettingsChanged);
    _discoveryGeneration++;
    if (_observingLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
      _observingLifecycle = false;
    }
    _discoveryUpdatesSubscription?.cancel();
    _discoveryStateSubscription?.cancel();
    _transportFrameSubscription?.cancel();
    _transportStateSubscription?.cancel();
    for (final transport in _transports.values) {
      transport.dispose();
    }
    unawaited(_radioStatsController.close());
    _notifications.dispose();
    _activeTransport = null;
    _state = MeshCoreConnectionState.disconnected;

    // Cancel every timer so nothing fires after disposal.
    _reconnectTimer?.cancel();
    _batteryPollTimer?.cancel();
    _selfInfoRetryTimer?.cancel();
    _queueSyncTimeout?.cancel();
    _channelSyncTimeout?.cancel();
    for (final entry in _pendingRepeaterAcks.values) {
      entry.timeout?.cancel();
    }
    _pendingRepeaterAcks.clear();

    _receivedFramesController.close();
    _channelMessagesController.close();
    // Flush pending unread writes before disposal
    unawaited(_unreadStore.flush().catchError((_) {}));

    super.dispose();
  }

  void _handleRxData(Uint8List frame) {
    final packet = parseLogRxDataFrame(frame);
    if (packet == null) {
      appLogger.warn('Malformed RX frame', tag: 'Connector');
      return;
    }

    switch (packet.payloadType) {
      case payloadTypeADVERT:
        _handlePayloadAdvertReceived(
          packet.payload,
          packet.pathBytes,
          packet.routeType,
          packet.snr,
        );
        break;
      default:
    }
  }

  void _handlePayloadAdvertReceived(
    Uint8List frame,
    Uint8List path,
    int routeType,
    double snr,
  ) {
    final advert = BufferReader(frame);
    double latitude = 0.0;
    double longitude = 0.0;
    String name = '';
    String contactKeyHex = '';
    Uint8List publicKey = Uint8List(0);
    int type = 0;
    int timestamp = 0;
    bool hasLocation = false;
    bool hasName = false;
    try {
      publicKey = advert.readBytes(32);
      contactKeyHex = publicKey
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      timestamp = advert.readInt32LE();
      advert.skipBytes(64); // Signature bytes — verified against full frame
      if (!verifyAdvertSignature(frame)) {
        appLogger.warn(
          'Rejected advert with invalid Ed25519 signature for $contactKeyHex',
          tag: 'Connector',
        );
        return;
      }
      final flags = advert.readByte();
      type = flags & 0x0F;
      hasLocation = (flags & 0x10) != 0;
      // For future use:
      //final hasFeature1 = (flags & 0x20) != 0;
      //final hasFeature2 = (flags & 0x40) != 0;
      hasName = (flags & 0x80) != 0;
      if (hasLocation && advert.remaining >= 8) {
        latitude = advert.readInt32LE() / 1e6;
        longitude = advert.readInt32LE() / 1e6;
      }
      if (hasName && advert.remaining > 0) {
        name = advert.readString();
      }
    } catch (e) {
      appLogger.warn('Malformed advert frame: $e', tag: 'Connector');
      return;
    }

    if (listEquals(publicKey, _selfPublicKey)) {
      return;
    }

    double? contactLatitude;
    double? contactLongitude;
    if (hasLocation && isValidMapCoordinate(latitude, longitude)) {
      contactLatitude = latitude;
      contactLongitude = longitude;
    }

    // Check if this is a new contact
    final isNewContact = !_knownContactKeys.contains(contactKeyHex);

    if (isNewContact) {
      final newContact = Contact(
        publicKey: publicKey,
        name: name,
        type: type,
        pathLength: path.length,
        path: Uint8List.fromList(
          path.reversed.toList(),
        ), // Store path in reverse for easier use in outgoing messages
        latitude: contactLatitude,
        longitude: contactLongitude,
        lastSeen: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
        firstSeenAt: DateTime.now(),
      );
      _handleContactAdvert(newContact);
      _updateDirectRepeater(newContact, snr, path);
      return;
    }

    final existingIndex = _contacts.indexWhere(
      (c) => c.publicKeyHex == contactKeyHex,
    );

    if (existingIndex >= 0) {
      final existing = _contacts[existingIndex];
      final mergedLastMessageAt = existing.lastMessageAt.isAfter(DateTime.now())
          ? DateTime.now()
          : existing.lastMessageAt;

      appLogger.info(
        'Refreshing contact ${existing.name}: devicePath=${existing.pathLength}, existingOverride=${existing.pathOverride}',
        tag: 'Connector',
      );

      // CRITICAL: Preserve user's path override when contact is refreshed from device
      _contacts[existingIndex] = existing.copyWith(
        latitude: hasLocation ? contactLatitude : existing.latitude,
        longitude: hasLocation ? contactLongitude : existing.longitude,
        name: hasName ? name : existing.name,
        path: Uint8List.fromList(path.reversed.toList()),
        pathLength: path.length,
        lastMessageAt: mergedLastMessageAt,
        lastSeen: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
        pathOverride: existing.pathOverride, // Preserve user's path choice
        pathOverrideBytes: existing.pathOverrideBytes,
      );

      // Add path to history if we have a valid path
      if (_pathHistoryService != null &&
          _contacts[existingIndex].pathLength >= 0) {
        _pathHistoryService!.handlePathUpdated(_contacts[existingIndex]);
      }

      _updateDirectRepeater(_contacts[existingIndex], snr, path);

      appLogger.info(
        'After merge: pathOverride=${_contacts[existingIndex].pathOverride}, devicePath=${_contacts[existingIndex].pathLength}',
        tag: 'Connector',
      );
    }
  }

  void _updateDirectRepeater(Contact contact, double snr, Uint8List path) {
    final pubkeyFirstByte = path.isNotEmpty
        ? path.last
        : contact.publicKey.first;

    _directRepeaters.removeWhere((r) => r.isStale());

    //We can use adverts from chat and sensor nodes, but only if the advert has a path to get the last hop.
    if ((contact.type == advTypeChat || contact.type == advTypeSensor) &&
        path.isEmpty) {
      notifyListeners();
      return;
    }

    final isTracked = _directRepeaters.where(
      (r) => r.pubkeyFirstByte == pubkeyFirstByte,
    );

    final sortedRepeaters = List<DirectRepeater>.from(_directRepeaters)
      ..sort((a, b) => b.snr.compareTo(a.snr));
    final weakestRepeater = sortedRepeaters.isNotEmpty
        ? sortedRepeaters.last
        : null;

    if (_directRepeaters.length >= 5 &&
        weakestRepeater != null &&
        isTracked.isEmpty) {
      _directRepeaters.remove(weakestRepeater);
    }

    if (isTracked.isNotEmpty) {
      final repeater = isTracked.first;
      repeater.update(snr);
    } else if (_directRepeaters.length < 5) {
      _directRepeaters.add(
        DirectRepeater(pubkeyFirstByte: pubkeyFirstByte, snr: snr),
      );
    }
    notifyListeners();
  }
}

const int _phRouteMask = 0x03;
const int _phTypeShift = 2;
const int _phTypeMask = 0x0F;
const int _phVerShift = 6;
const int _phVerMask = 0x03;

const int _routeTransportFlood = 0x00;
const int _routeFlood = 0x01;
const int _routeTransportDirect = 0x03;

const int _payloadTypeGroupText = 0x05;

class _RawPacket {
  final int header;
  final int routeType;
  final int payloadType;
  final int payloadVer;
  final int pathLenByte;
  final Uint8List pathBytes;
  final Uint8List payload;

  _RawPacket({
    required this.header,
    required this.routeType,
    required this.payloadType,
    required this.payloadVer,
    required this.pathLenByte,
    required this.pathBytes,
    required this.payload,
  });

  bool get isFlood =>
      routeType == _routeFlood || routeType == _routeTransportFlood;
}

class _PendingReaction {
  const _PendingReaction({required this.info, required this.reactor});

  final ReactionInfo info;
  final String reactor;
}

class _PendingEdit {
  const _PendingEdit({required this.info, required this.editorIsSelf});

  final EditInfo info;
  final bool editorIsSelf;
}

class _PendingOutgoingChannelReaction {
  const _PendingOutgoingChannelReaction({
    required this.channelIndex,
    required this.info,
    required this.reactor,
  });

  final int channelIndex;
  final ReactionInfo info;
  final String reactor;
}

class _ParsedText {
  final String senderName;
  final String text;

  _ParsedText({required this.senderName, required this.text});
}

class _RepeaterAckContext {
  final String contactKeyHex;
  final PathSelection selection;
  final int pathLength;
  final int messageBytes;
  Timer? timeout;

  _RepeaterAckContext({
    required this.contactKeyHex,
    required this.selection,
    required this.pathLength,
    required this.messageBytes,
  });
}

class _PendingCommandAck {
  final int commandCode;
  final String? channelSendQueueId;
  final void Function(bool success)? completion;
  bool responseReceived = false;

  /// Set when the app stopped caring about this command (send timeout, or the
  /// message was confirmed by another signal) but the companion still owes an
  /// OK/ERR for it.
  ///
  /// The entry must stay queued: the queue is correlated by position, because
  /// a generic OK carries no identifier. Dropping it would shift every later
  /// entry forward and hand this command's response to the next one.
  bool cancelled = false;

  _PendingCommandAck({
    required this.commandCode,
    this.channelSendQueueId,
    this.completion,
  });
}
