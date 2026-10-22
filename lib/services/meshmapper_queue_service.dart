import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/wardriving_queue_item.dart';
import '../storage/prefs_manager.dart';
import 'meshmapper_api_service.dart';

class MeshMapperQueueService extends ChangeNotifier {
  static const String _queueKey = 'wardriving_upload_queue';
  static const int _maxBatchSize = 50;
  static const Duration _flushInterval = Duration(seconds: 15);

  final MeshMapperApiService _apiService;
  final Future<void> Function(String value) _writeQueue;
  final List<WardrivingQueueItem> _queue = [];
  Timer? _flushTimer;
  Future<void>? _activeFlush;
  Future<void> _persistTail = Future<void>.value();
  int _uploadedCount = 0;
  int _droppedCount = 0;
  bool _disposed = false;
  void Function(int droppedCount)? onItemsDropped;
  late final Future<void> _ready;

  MeshMapperQueueService({
    required MeshMapperApiService apiService,
    Future<void> Function(String value)? writeQueue,
  }) : _apiService = apiService,
       _writeQueue = writeQueue ?? _writeQueuePreference {
    _ready = _initialize();
  }

  static Future<void> _writeQueuePreference(String value) async {
    await PrefsManager.instance.setString(_queueKey, value);
  }

  Future<void> _initialize() async {
    await _loadQueue();
    if (_disposed) return;
    _flushTimer = Timer.periodic(
      _flushInterval,
      (_) => unawaited(flush().catchError((_) {})),
    );
    notifyListeners();
  }

  int get queueCount => _queue.length;
  int get uploadedCount => _uploadedCount;
  int get droppedCount => _droppedCount;

  Future<void> enqueue(WardrivingQueueItem item) async {
    await _ready;
    if (_disposed) return;
    _bindItemToCurrentSession(item);
    _queue.add(item);
    await _persistQueue();
    notifyListeners();
  }

  Future<void> enqueueAll(List<WardrivingQueueItem> items) async {
    await _ready;
    if (_disposed) return;
    if (items.isEmpty) return;
    for (final item in items) {
      _bindItemToCurrentSession(item);
    }
    _queue.addAll(items);
    await _persistQueue();
    notifyListeners();
  }

  Future<void> flush({String? contactPrefix, String? iata}) async {
    await _ready;
    // A disconnect waits for this Future before releasing the server session.
    // Returning early here used to let it close the session while the first
    // HTTP request was still in flight.
    final activeFlush = _activeFlush;
    if (activeFlush != null) {
      await activeFlush;
      // Include samples queued while that request was in flight before a
      // caller disconnects the session.
      return flush(contactPrefix: contactPrefix, iata: iata);
    }
    if (_disposed) return;
    if (_queue.isEmpty || !_apiService.hasSession) return;
    final operation = _drain(contactPrefix: contactPrefix, iata: iata);
    _activeFlush = operation;
    try {
      await operation;
    } finally {
      if (identical(_activeFlush, operation)) _activeFlush = null;
    }
  }

  Future<void> _drain({String? contactPrefix, String? iata}) async {
    while (!_disposed &&
        _queue.isNotEmpty &&
        _apiService.hasSession &&
        !_apiService.isWardriveHeld) {
      final before = _queue.length;
      await _flush(contactPrefix: contactPrefix, iata: iata);
      // A held, failed, or deferred batch stays queued. Wait for the next
      // scheduled attempt rather than spinning on it.
      if (_queue.length >= before) break;
    }
  }

  Future<void> _flush({String? contactPrefix, String? iata}) async {
    await _dropTaggedItemsForDifferentSession(_apiService.sessionId!);
    if (_queue.isEmpty) return;
    final ready = _queue
        .where((item) => item.isReadyForRetry)
        .take(_maxBatchSize)
        .toList();
    if (ready.isEmpty) return;

    final payload = ready
        .map((item) => item.toApiJson(contactPrefix: contactPrefix, iata: iata))
        .toList();
    final response = await _apiService.submitWardriveData(payload);
    final result = classifyUploadResponse(response);

    switch (result) {
      case MeshMapperUploadResult.success:
        _queue.removeWhere(ready.contains);
        _uploadedCount += ready.length;
        await _persistQueue();
        notifyListeners();
      case MeshMapperUploadResult.retryable:
        for (final item in ready) {
          item.markRetried();
        }
        // Transient network/server failures must never destroy samples.
        // They remain in the durable queue and retry with capped backoff.
        await _persistQueue();
        notifyListeners();
      case MeshMapperUploadResult.unreachable:
      case MeshMapperUploadResult.held:
        // A lost route and an explicit server hold both say nothing about
        // the data. The periodic flush is pacing enough; spending retries
        // here can permanently strand a healthy backlog after a drive out
        // of coverage.
        break;
      case MeshMapperUploadResult.nonRetryable:
        _queue.removeWhere(ready.contains);
        _droppedCount += ready.length;
        await _persistQueue();
        onItemsDropped?.call(ready.length);
        notifyListeners();
    }
  }

  void _bindItemToCurrentSession(WardrivingQueueItem item) {
    item.bindWireTagSession(_apiService.sessionId);
  }

  Future<void> _dropTaggedItemsForDifferentSession(String sessionId) async {
    final stale = _queue
        .where((item) => item.hasWireTag && item.wireTagSessionId != sessionId)
        .toList();
    if (stale.isEmpty) return;
    _queue.removeWhere(stale.contains);
    _droppedCount += stale.length;
    await _persistQueue();
    onItemsDropped?.call(stale.length);
    notifyListeners();
  }

  Future<void> _loadQueue() async {
    final prefs = PrefsManager.instance;
    final raw = prefs.getString(_queueKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      final dynamic rawItems = decoded is Map<String, dynamic>
          ? decoded['items']
          : decoded; // legacy unversioned format
      if (rawItems is! List) {
        throw const FormatException('Invalid wardriving queue');
      }
      final restored = <WardrivingQueueItem>[];
      var skippedCorruptItem = false;
      for (final entry in rawItems) {
        if (entry is! Map<String, dynamic>) {
          skippedCorruptItem = true;
          continue;
        }
        try {
          restored.add(WardrivingQueueItem.fromJson(entry));
        } catch (_) {
          skippedCorruptItem = true;
        }
      }
      _queue
        ..clear()
        ..addAll(restored);
      if (skippedCorruptItem) {
        await prefs.setString('${_queueKey}_corrupt', raw);
      }
      await _persistQueue();
    } catch (_) {
      _queue.clear();
      // Preserve evidence of corrupt data for diagnostics/recovery.
      await prefs.setString('${_queueKey}_corrupt', raw);
      await _persistQueue();
    }
  }

  Future<void> _persistQueue() {
    // Enqueue, upload completion, and session cleanup can all persist. Keep
    // writes ordered so an older snapshot cannot overwrite a newer queue.
    final operation = _persistTail.then((_) async {
      final encoded = jsonEncode({
        'version': 1,
        'items': _queue.map((item) => item.toJson()).toList(),
      });
      await _writeQueue(encoded);
    });
    _persistTail = operation.catchError((Object _) {});
    return operation;
  }

  /// Remove TX rows whose wire tags were minted under a replaced session.
  /// Such tags cannot validate under the new session and the server may still
  /// acknowledge the batch, making the loss otherwise silent.
  Future<void> dropStaleTaggedItems() async {
    await _ready;
    if (_disposed) return;
    final stale = _queue.where((item) => item.hasWireTag).toList();
    if (stale.isEmpty) return;
    _queue.removeWhere(stale.contains);
    _droppedCount += stale.length;
    await _persistQueue();
    onItemsDropped?.call(stale.length);
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _flushTimer?.cancel();
    super.dispose();
  }
}

String formatHeardRepeats(Map<String, double> repeaters) {
  if (repeaters.isEmpty) return 'None';
  return repeaters.entries
      .map((e) => '${e.key}(${e.value.toStringAsFixed(2)})')
      .join(',');
}
