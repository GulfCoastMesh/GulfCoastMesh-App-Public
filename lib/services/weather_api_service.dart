import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/atak_location_access.dart';
import '../helpers/channel_slot_helper.dart';
import '../models/channel.dart';
import '../models/channel_message.dart';
import '../models/contact.dart';
import '../helpers/weather_api2_codec.dart';
import '../models/weather_report.dart';

enum WeatherStatus { idle, discovering, ready, loading, unavailable, error }

/// Compact API2 client. Channel discovery pins the answering bot's identity;
/// DM tools explicitly use the contact selected by the user.
class WeatherApiService extends ChangeNotifier {
  WeatherApiService(this._connector) {
    _messages = _connector.receivedChannelMessages.listen(_onChannelMessage);
    _wasConnected = _connector.isConnected;
    _connector.addListener(_onConnectorChanged);
  }

  static const _apiChannelName = '#wx-bot-hidden';
  static const _responseTimeout = Duration(seconds: 60);

  final MeshCoreConnector _connector;
  late bool _wasConnected;
  late final StreamSubscription<ChannelMessage> _messages;
  final _fragments = <String, WeatherApi2Group>{};
  final _rejectedGroups = <String>{};
  final _seenDm = <String>{};
  bool _disposed = false;
  int _generation = 0;
  String? _botIdentity;
  String? get botIdentity => _botIdentity;
  Contact? _botContact;
  Contact? get botContact => _botContact;
  int capabilities = 0;
  bool supports(int bit) => capabilities & (1 << bit) != 0;
  int receivedParts = 0, totalParts = 0;
  bool floodWarning = false;
  Map<String, dynamic>? currentSummary;
  Map<String, dynamic>? radar;
  Map<String, dynamic>? toolResult;
  String? _requestZip;
  (double, double, int)? _radarRequest;
  bool _requestDm = false;
  String? _errorCommand;

  void selectBotContact(Contact? contact) {
    if (isBusy) return;
    _botContact = contact;
    toolResult = null;
    notifyListeners();
  }

  WeatherStatus _status = WeatherStatus.idle;
  WeatherStatus get status => _status;
  WeatherReport? _report;
  WeatherReport? get report => _report;
  String? _selectedZip;
  String? get selectedZip => _selectedZip;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  Channel? _apiChannel;
  Completer<Map<String, dynamic>>? _pendingResponse;
  String? _expectedKind;

  bool get isBusy =>
      _pendingResponse != null ||
      _status == WeatherStatus.discovering ||
      _status == WeatherStatus.loading;

  Future<void> discover() async {
    if (isBusy || _disposed) return;
    if (!_connector.isConnected) {
      _setUnavailable('Connect your radio to get weather.');
      return;
    }
    final generation = _generation;
    _botIdentity = null;
    capabilities = 0;
    _errorMessage = null;
    _setStatus(WeatherStatus.discovering);
    try {
      final channel = await _ensureApiChannel();
      if (_disposed || generation != _generation) return;
      _apiChannel = channel;
      final response = await _sendAndWait(channel, 'bot api2', 'b');
      if (_disposed || generation != _generation) return;
      if (response['k'] == 'e') {
        throw _WeatherUserError(
          _weatherErrorMessage(_readInt(response['error']) ?? 0),
        );
      }
      final capability = _readInt(response['cmd']) ?? 0;
      capabilities = capability;
      if ((capability & 6) == 0) {
        _setUnavailable('Weather is unavailable right now.');
        return;
      }
      _setStatus(WeatherStatus.ready);
    } on TimeoutException {
      if (_disposed || generation != _generation) return;
      _setUnavailable('No response yet. Try again.');
    } catch (error) {
      if (_disposed || generation != _generation) return;
      _setUnavailable(_safeError(error));
    }
  }

  Future<void> requestWeather(String zip) async {
    if (isBusy || !supports(2)) return;
    final generation = _generation;
    final normalized = normalizeUsZip(zip);
    if (normalized == null) {
      _errorMessage = 'Enter a valid five-digit U.S. ZIP code.';
      _setStatus(WeatherStatus.error);
      return;
    }
    final channel = _apiChannel;
    if (channel == null) {
      _setUnavailable('Weather is unavailable right now. Try again.');
      return;
    }
    _selectedZip = normalized;
    _requestZip = normalized;
    _errorMessage = null;
    _setStatus(WeatherStatus.loading);
    try {
      final response = await _sendAndWait(
        channel,
        'wx $normalized all api2',
        'w',
      );
      if (_disposed || generation != _generation) return;
      if (response['k'] == 'e') {
        _errorMessage = _weatherErrorMessage(_readInt(response['error']) ?? 0);
        _setStatus(WeatherStatus.error);
        return;
      }
      final report = _parseReport(response);
      if (report == null) {
        throw const FormatException('Weather could not be read. Try again.');
      }
      _report = report;
      if (currentSummary?['z'] != normalized) currentSummary = null;
      _setStatus(WeatherStatus.ready);
    } on TimeoutException {
      if (_disposed || generation != _generation) return;
      _errorMessage = 'No response yet. Try again.';
      _setStatus(WeatherStatus.error);
    } catch (error) {
      if (_disposed || generation != _generation) return;
      _errorMessage = _safeError(error);
      _setStatus(WeatherStatus.error);
    } finally {
      _requestZip = null;
    }
  }

  Future<void> requestCurrent(String zip) async {
    final normalized = normalizeUsZip(zip);
    if (isBusy) return;
    if (normalized == null) {
      _errorMessage = 'Enter a valid five-digit U.S. ZIP code.';
      _setStatus(WeatherStatus.error);
      return;
    }
    _requestZip = normalized;
    try {
      await _operation('wx $normalized api2', 'current', 1, (value) {
        currentSummary = value;
        _selectedZip = normalized;
        if (_report?.zipCode != normalized) _report = null;
      });
    } finally {
      _requestZip = null;
    }
  }

  Future<void> requestRadar(double lat, double lon, int offset) async {
    if (isBusy) return;
    if (!lat.isFinite ||
        !lon.isFinite ||
        lat.abs() > 90 ||
        lon.abs() > 180 ||
        offset.abs() > 5) {
      _errorMessage = 'Enter valid coordinates and an hour between -5 and +5.';
      _setStatus(WeatherStatus.error);
      return;
    }
    _radarRequest = (lat, lon, offset);
    final time = offset == 0 ? 'now' : '${offset > 0 ? '+' : ''}${offset}h';
    try {
      await _operation(
        'wx radar ${lat.toStringAsFixed(5)} ${lon.toStringAsFixed(5)} $time api2',
        'r',
        7,
        (value) => radar = value,
      );
    } finally {
      _radarRequest = null;
    }
  }

  Future<void> requestVersion() =>
      _operation('wx version api2', 'version', 3, (v) => toolResult = v);
  Future<void> requestHelp() => _operation('wx help api2', 'b', 0, (v) {
    capabilities = _readInt(v['cmd']) ?? capabilities;
    toolResult = v;
  });
  Future<void> ping() =>
      _operation('ping api2', 'pong', 4, (v) => toolResult = v, dm: true);
  Future<void> subscribe(String zip) async {
    if (isBusy) return;
    final normalized = normalizeUsZip(zip);
    if (normalized == null) {
      _errorMessage = 'Enter a valid five-digit U.S. ZIP code.';
      _setStatus(WeatherStatus.error);
      return;
    }
    _requestZip = normalized;
    try {
      await _operation(
        'wx report $normalized api2',
        'report',
        5,
        (v) => toolResult = v,
        dm: true,
      );
    } finally {
      _requestZip = null;
    }
  }

  Future<void> unsubscribe() => _operation(
    'wx report stop api2',
    'report',
    6,
    (v) => toolResult = v,
    dm: true,
  );

  Future<void> _operation(
    String command,
    String kind,
    int bit,
    void Function(Map<String, dynamic>) accept, {
    bool dm = false,
  }) async {
    if (isBusy) return;
    if (!supports(bit) || _apiChannel == null || (dm && _botContact == null)) {
      _errorMessage = dm && _botContact == null
          ? 'Select the weather bot contact to use direct-message tools.'
          : 'This feature is unavailable right now.';
      _setStatus(WeatherStatus.error);
      return;
    }
    final generation = _generation;
    _errorMessage = null;
    _setStatus(WeatherStatus.loading);
    try {
      final value = await _sendAndWait(_apiChannel!, command, kind, dm: dm);
      if (_disposed || generation != _generation) return;
      if (value['k'] == 'e') {
        throw _WeatherUserError(
          _weatherErrorMessage(_readInt(value['error']) ?? 0),
        );
      }
      accept(value);
      _setStatus(WeatherStatus.ready);
    } on TimeoutException {
      if (_disposed || generation != _generation) return;
      _errorMessage = 'No response yet. Try again.';
      if (generation == _generation) _setStatus(WeatherStatus.error);
    } catch (error) {
      if (_disposed || generation != _generation) return;
      _errorMessage = _safeError(error);
      if (generation == _generation) _setStatus(WeatherStatus.error);
    }
  }

  Future<String?> zipFromCurrentLocation() async {
    try {
      final granted = await ensureAtakLocationPermission();
      if (!granted) return null;
      final position = await readAtakPosition();
      if (position == null) return null;
      final places = await placemarkFromCoordinates(position.lat, position.lon);
      if (places.isEmpty || places.first.isoCountryCode != 'US') return null;
      return normalizeUsZip(places.first.postalCode ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<Channel> _ensureApiChannel() async {
    for (final channel in _connector.channels) {
      if (channel.isWeatherChannel) {
        return channel;
      }
    }
    final index = firstAvailableChannelIndex(
      _connector.channels,
      _connector.maxChannels,
    );
    if (index == null) {
      throw const _WeatherUserError(
        'Your radio has no room for weather. Remove an unused channel and try again.',
      );
    }
    await _connector.setChannel(
      index,
      _apiChannelName,
      Channel.derivePskFromHashtag(_apiChannelName),
    );
    for (final channel in _connector.channels) {
      if (channel.index == index) {
        return channel;
      }
    }
    throw const _WeatherUserError('Weather could not be set up. Try again.');
  }

  Future<Map<String, dynamic>> _sendAndWait(
    Channel channel,
    String request,
    String? expectedKind, {
    bool dm = false,
  }) async {
    if (_pendingResponse != null) {
      throw StateError('A weather request is already active.');
    }
    _fragments.clear();
    _rejectedGroups.clear();
    _errorCommand = request.startsWith('wx radar')
        ? 'radar'
        : request.startsWith('wx report')
        ? 'wx report'
        : request.startsWith('wx')
        ? 'wx'
        : 'api2';
    _requestDm = dm;
    receivedParts = totalParts = 0;
    floodWarning = false;
    _seenDm.clear();
    if (dm) {
      for (final message in _connector.getMessages(_botContact!)) {
        _seenDm.add(
          '${message.timestamp.microsecondsSinceEpoch}:${message.text}',
        );
      }
    }
    _expectedKind = expectedKind;
    final completer = Completer<Map<String, dynamic>>();
    _pendingResponse = completer;
    try {
      // Attach the timeout/error handler before sending: disconnects can occur
      // while the transport is still awaiting its send acknowledgement.
      final response = completer.future.timeout(_responseTimeout);
      unawaited(() async {
        try {
          if (dm) {
            await _connector.sendMessage(_botContact!, request);
          } else {
            await _connector.sendChannelMessage(
              channel,
              request,
              addToLocalHistory: false,
            );
          }
        } catch (error, stack) {
          if (!completer.isCompleted) completer.completeError(error, stack);
        }
      }());
      return await response;
    } finally {
      if (identical(_pendingResponse, completer)) {
        _pendingResponse = null;
      }
      _expectedKind = null;
      _fragments.clear();
      _rejectedGroups.clear();
      _seenDm.clear();
      if (!_disposed && _status == WeatherStatus.idle) notifyListeners();
    }
  }

  void _onChannelMessage(ChannelMessage message) {
    if (_requestDm ||
        message.isOutgoing ||
        message.channelIndex != _apiChannel?.index) {
      return;
    }
    _receive(
      message.text,
      message.senderKeyHex ?? 'name:${message.senderName}',
    );
  }

  void _receive(String text, String sender) {
    final pending = _pendingResponse;
    if (pending == null || pending.isCompleted || !text.startsWith('~W2')) {
      return;
    }
    if (!_requestDm && _botIdentity != null && sender != _botIdentity) return;
    String? key;
    try {
      final frame = WeatherApi2Frame(text);
      const kinds = {
        1: 'w',
        2: 'b',
        3: 'version',
        4: 'report',
        5: 'pong',
        6: 'e',
        7: 'current',
        8: 'r',
      };
      if (kinds[frame.type] != _expectedKind && frame.type != 6) return;
      key = '${_requestDm ? 'dm' : 'channel'}:$sender:${frame.id}';
      if (_rejectedGroups.contains(key)) return;
      if (!_fragments.containsKey(key) &&
          _fragments.length + _rejectedGroups.length >= 8) {
        return;
      }
      final group = _fragments.putIfAbsent(key, () => WeatherApi2Group(frame));
      final merged = group.add(frame);
      receivedParts = group.received;
      totalParts = group.total;
      notifyListeners();
      if (merged == null) return;
      if (merged['k'] == 'e' &&
          merged['command'] != _errorCommand &&
          merged['command'] != 'api2') {
        return;
      }
      if (merged['k'] == 'b' && merged['cmd'] is! int) return;
      if (merged['k'] == 'report' &&
          merged['status'] != (_requestZip == null ? 'stopped' : 'enabled')) {
        return;
      }
      final zip = merged['z'] ?? merged['zip_code'];
      if (_requestZip != null && zip != null && zip != _requestZip) return;
      final radarRequest = _radarRequest;
      if (merged['k'] == 'r' &&
          radarRequest != null &&
          (((merged['lat'] as num) - radarRequest.$1).abs() > 0.00002 ||
              ((merged['lon'] as num) - radarRequest.$2).abs() > 0.00002 ||
              merged['o'] != radarRequest.$3)) {
        return;
      }
      if (!_requestDm && merged['k'] == 'b' && merged['cmd'] is int) {
        _botIdentity = sender;
      }
      floodWarning = merged['flood_warning'] == true;
      pending.complete(merged);
    } on FormatException {
      // A malformed group must never produce a partial result.
      if (key != null) {
        _fragments.remove(key);
        _rejectedGroups.add(key);
      }
    }
  }

  void _onConnectorChanged() {
    final connected = _connector.isConnected;
    if (_requestDm && _botContact != null && _pendingResponse != null) {
      for (final message in _connector.getMessages(_botContact!)) {
        final key =
            '${message.timestamp.microsecondsSinceEpoch}:${message.text}';
        if (!message.isOutgoing && _seenDm.add(key)) {
          _receive(message.text, _botContact!.publicKeyHex);
        }
      }
    }
    if (_wasConnected && !connected) {
      _generation++;
      final pending = _pendingResponse;
      if (pending != null && !pending.isCompleted) {
        pending.completeError(StateError('The mesh connection ended.'));
      }
      _apiChannel = null;
      _botIdentity = null;
      _botContact = null;
      capabilities = 0;
      radar = currentSummary = toolResult = null;
      _report = null;
      _selectedZip = null;
      _errorMessage = null;
      _status = WeatherStatus.idle;
      notifyListeners();
    }
    _wasConnected = connected;
  }

  WeatherReport? _parseReport(Map<String, dynamic> data) {
    if (data['k'] != 'w' ||
        data['z'] is! String ||
        _readInt(data['g']) == null ||
        data['n'] is! List) {
      return null;
    }
    final current = _parseCurrent(data['n'] as List);
    if (current == null) return null;
    final hourly = <WeatherHourly>[];
    if (data['h'] is List) {
      for (final row in data['h'] as List) {
        if (row is List) {
          final parsed = _parseHourly(row);
          if (parsed != null) hourly.add(parsed);
        }
      }
    }
    final alerts = <WeatherAlert>[];
    if (data['a'] is List) {
      for (final row in data['a'] as List) {
        if (row is List && row.length >= 2) {
          alerts.add(
            WeatherAlert(
              alertCode: _readInt(row[0]) ?? 0,
              severityCode: _readInt(row[1]) ?? 0,
            ),
          );
        }
      }
    }
    return WeatherReport(
      zipCode: data['z'] as String,
      generatedAt: DateTime.fromMillisecondsSinceEpoch(
        _readInt(data['g'])! * 1000,
      ).toLocal(),
      current: current,
      hourly: hourly.take(5).toList(),
      alerts: alerts.take(5).toList(),
      hasMoreAlerts: data['x'] == true,
    );
  }

  WeatherCurrent? _parseCurrent(List row) {
    if (row.length < 5) return null;
    return WeatherCurrent(
      temperatureF: _readInt(row[0]),
      weatherCode: _readInt(row[1]) ?? 0,
      humidityPercent: _readInt(row[2]),
      windDirectionDegrees: _readInt(row[3]),
      windMph: _readInt(row[4]),
      apparentTemperatureF: row.length > 5 ? _readInt(row[5]) : null,
    );
  }

  WeatherHourly? _parseHourly(List row) {
    if (row.length < 6) return null;
    return WeatherHourly(
      minutesAfterGenerated: _readInt(row[0]),
      temperatureF: _readInt(row[1]),
      weatherCode: _readInt(row[2]) ?? 0,
      windDirectionDegrees: _readInt(row[3]),
      windMph: _readInt(row[4]),
      precipitationPercent: _readInt(row[5]),
    );
  }

  void _setStatus(WeatherStatus value) {
    if (_disposed) return;
    _status = value;
    notifyListeners();
  }

  void _setUnavailable(String value) {
    _errorMessage = value;
    _setStatus(WeatherStatus.unavailable);
  }

  static int? _readInt(Object? value) => value is num ? value.toInt() : null;
  static String _safeError(Object error) => error is _WeatherUserError
      ? error.message
      : 'Weather could not be loaded. Try again.';
  static String _weatherErrorMessage(int code) => switch (code) {
    1 => 'That ZIP code was not found.',
    2 => 'Current weather data is temporarily unavailable.',
    3 => 'Weather could not be read. Try again.',
    4 => 'Subscriptions require a direct message to the bot.',
    5 => 'This feature is unavailable right now.',
    6 => 'Radar is available only in the contiguous United States.',
    7 => 'Weather is unavailable for that time. Try a different hour.',
    _ => 'Weather is unavailable right now. Try again.',
  };

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    final pending = _pendingResponse;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(StateError('Weather closed.'));
    }
    _connector.removeListener(_onConnectorChanged);
    _messages.cancel();
    super.dispose();
  }
}

String? normalizeUsZip(String value) {
  final match = RegExp(r'^\s*(\d{5})(?:-\d{4})?\s*$').firstMatch(value);
  return match?.group(1);
}

class _WeatherUserError implements Exception {
  const _WeatherUserError(this.message);
  final String message;
}
