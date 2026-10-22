import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/analyzer_packet.dart';
import '../models/contact.dart';

enum AnalyzerPacketFilter { all, dm, channel, advert, discovery }

class AnimatedPath {
  static const travelDuration = Duration(seconds: 3);

  double travelProgressAt(DateTime now) =>
      (now.difference(createdAt).inMilliseconds / travelDuration.inMilliseconds)
          .clamp(0.0, 1.0);

  final List<LatLng> points;
  final DateTime createdAt;
  final AnalyzerPacketType packetType;
  final String label;

  const AnimatedPath({
    required this.points,
    required this.createdAt,
    required this.packetType,
    required this.label,
  });

  double opacityAt(
    DateTime now, {
    Duration fadeDelay = const Duration(seconds: 5),
    Duration fadeDuration = const Duration(seconds: 2),
  }) {
    final age = now.difference(createdAt);
    if (age < fadeDelay) return 1.0;
    final fadeAge = age - fadeDelay;
    if (fadeAge >= fadeDuration) return 0.0;
    return 1.0 - (fadeAge.inMilliseconds / fadeDuration.inMilliseconds);
  }

  bool isExpired(
    DateTime now, {
    Duration fadeDelay = const Duration(seconds: 5),
    Duration fadeDuration = const Duration(seconds: 2),
  }) {
    return opacityAt(now, fadeDelay: fadeDelay, fadeDuration: fadeDuration) <=
        0.0;
  }
}

class MeshAnalyzerState extends ChangeNotifier {
  static const int _maxPackets = 500;
  static const int _maxActivePaths = 20;
  static const Duration _pathFadeDelay = Duration(seconds: 5);
  static const Duration _pathFadeDuration = Duration(seconds: 2);

  final List<AnalyzerPacket> _packets = [];
  final List<AnimatedPath> _activePaths = [];
  bool _isPaused = false;
  bool _isFullScreen = false;
  bool _autoZoomEnabled = false;
  AnalyzerPacketFilter _filter = AnalyzerPacketFilter.all;
  String? _selectedChatId;
  Timer? _pruneTimer;

  MeshAnalyzerState() {
    _pruneTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _pruneExpiredPaths();
    });
  }

  List<AnalyzerPacket> get packets {
    if (_filter == AnalyzerPacketFilter.all) {
      return List.unmodifiable(_packets);
    }
    return List.unmodifiable(_packets.where((p) => _matchesFilter(p, _filter)));
  }

  List<AnalyzerPacket> get allPackets => List.unmodifiable(_packets);

  List<AnimatedPath> get activePaths => List.unmodifiable(_activePaths);

  bool get isPaused => _isPaused;

  bool get isFullScreen => _isFullScreen;

  bool get autoZoomEnabled => _autoZoomEnabled;

  AnalyzerPacketFilter get filter => _filter;

  String? get selectedChatId => _selectedChatId;

  int get totalPacketCount => _packets.length;

  void addPacket(AnalyzerPacket packet) {
    if (_isPaused) return;

    _packets.insert(0, packet);
    while (_packets.length > _maxPackets) {
      _packets.removeLast();
    }
    notifyListeners();
  }

  void addAnimatedPath(AnimatedPath path) {
    if (_isPaused) return;

    _activePaths.insert(0, path);
    while (_activePaths.length > _maxActivePaths) {
      _activePaths.removeLast();
    }
    notifyListeners();
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;
    notifyListeners();
  }

  void toggleAutoZoom() {
    _autoZoomEnabled = !_autoZoomEnabled;
    notifyListeners();
  }

  void setFullScreen(bool value) {
    if (_isFullScreen == value) return;
    _isFullScreen = value;
    notifyListeners();
  }

  void setFilter(AnalyzerPacketFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void selectChat(String? chatId) {
    _selectedChatId = chatId;
    notifyListeners();
  }

  void clearPackets() {
    _packets.clear();
    _activePaths.clear();
    notifyListeners();
  }

  void clearPaths() {
    _activePaths.clear();
    notifyListeners();
  }

  void _pruneExpiredPaths() {
    final now = DateTime.now();
    final before = _activePaths.length;
    final wasFading = _activePaths.any((p) {
      final opacity = p.opacityAt(
        now,
        fadeDelay: _pathFadeDelay,
        fadeDuration: _pathFadeDuration,
      );
      return opacity > 0.0 && opacity < 1.0;
    });
    _activePaths.removeWhere(
      (p) => p.isExpired(
        now,
        fadeDelay: _pathFadeDelay,
        fadeDuration: _pathFadeDuration,
      ),
    );
    final removed = _activePaths.length != before;
    final stillFading = _activePaths.any((p) {
      final opacity = p.opacityAt(
        now,
        fadeDelay: _pathFadeDelay,
        fadeDuration: _pathFadeDuration,
      );
      return opacity > 0.0 && opacity < 1.0;
    });
    if (removed || wasFading || stillFading) {
      notifyListeners();
    }
  }

  static bool _matchesFilter(
    AnalyzerPacket packet,
    AnalyzerPacketFilter filter,
  ) {
    switch (filter) {
      case AnalyzerPacketFilter.all:
        return true;
      case AnalyzerPacketFilter.dm:
        return packet.type == AnalyzerPacketType.dm;
      case AnalyzerPacketFilter.channel:
        return packet.type == AnalyzerPacketType.channel;
      case AnalyzerPacketFilter.advert:
        return packet.type == AnalyzerPacketType.advert;
      case AnalyzerPacketFilter.discovery:
        return packet.type == AnalyzerPacketType.discovery;
    }
  }

  /// Flood path hashes are appended by each hop; the origin is the first hash.
  static String resolveSenderFromPath(
    Uint8List pathBytes,
    List<Contact> contacts,
    int hashSize,
  ) {
    if (pathBytes.isEmpty || hashSize <= 0) return 'Unknown';
    if (pathBytes.length < hashSize) return 'Unknown';
    final originHop = pathBytes.sublist(0, hashSize);
    for (final contact in contacts) {
      if (_prefixMatches(contact.publicKey, originHop)) {
        return contact.name;
      }
    }
    return 'Unknown';
  }

  static List<Contact> resolvePathContacts(
    Uint8List pathBytes,
    List<Contact> contacts,
    int hashSize,
  ) {
    if (pathBytes.isEmpty || hashSize <= 0) return [];
    final resolved = <Contact>[];
    for (int i = 0; i + hashSize <= pathBytes.length; i += hashSize) {
      final hopBytes = pathBytes.sublist(i, i + hashSize);
      for (final contact in contacts) {
        if (_prefixMatches(contact.publicKey, hopBytes)) {
          resolved.add(contact);
          break;
        }
      }
    }
    return resolved;
  }

  static bool _prefixMatches(Uint8List fullKey, Uint8List prefix) {
    if (fullKey.length < prefix.length) return false;
    for (int i = 0; i < prefix.length; i++) {
      if (fullKey[i] != prefix[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _pruneTimer?.cancel();
    super.dispose();
  }
}
