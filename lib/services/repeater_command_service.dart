import 'dart:async';
import '../models/contact.dart';
import '../models/path_selection.dart';
import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';

class RepeaterCommandService {
  final MeshCoreConnector _connector;
  final Map<String, Completer<String>> _pendingCommands = {};
  final Map<String, Timer> _commandTimeouts = {};
  final Map<String, String> _commandPrefixes = {};
  final Map<String, String> _pendingByPrefix = {};
  bool _disposed = false;

  /// Process-wide counter shared across every RepeaterCommandService
  /// instance. Each screen creates its own service today (status, telemetry,
  /// neighbors, settings, CLI, OTA), and if they each started this counter
  /// at zero they'd all hand out `00|` / `01|` / ... for their first few
  /// commands. With strict-prefix matching that means two simultaneous
  /// services talking to the same repeater could collide on the same prefix
  /// token. Sharing the counter pushes that collision out to a full 8-bit
  /// rollover (256 outstanding commands across all screens) which is
  /// effectively unreachable in practice.
  ///
  /// NOTE: this is a mitigation, not a complete fix. Two simultaneous
  /// services for the same repeater each still maintain their own
  /// `_pendingByPrefix` map, so on a 256-command wrap a collision could
  /// resurface. The structural fix is to make this service a singleton on
  /// MeshCoreConnector so there is one global prefix space.
  static int _sharedPrefixCounter = 0;

  static const int maxRetries = 5;

  RepeaterCommandService(this._connector);

  /// Send a CLI command to a repeater with automatic retries
  /// Returns a future that completes when a response is received or after max retries
  Future<String> sendCommand(
    Contact repeater,
    String command, {
    Function(String)? onResponse,
    Function(int)? onAttempt,
    int retries = maxRetries,
  }) async {
    if (_disposed) {
      throw StateError('RepeaterCommandService has been disposed.');
    }
    final repeaterKey = repeater.publicKeyHex;
    final hasPending = _pendingCommands.keys.any(
      (id) => id.startsWith(repeaterKey),
    );
    if (hasPending) {
      throw Exception('Another command is still awaiting a response.');
    }

    final attemptCount = retries < 1 ? 1 : retries;
    final selection = await _connector.preparePathForContactSend(repeater);

    for (int attempt = 0; attempt < attemptCount; attempt++) {
      onAttempt?.call(attempt + 1);
      try {
        final response = await _sendCommandAttempt(
          repeater,
          command,
          selection,
          attempt,
        );
        onResponse?.call(response);
        return response;
      } catch (e) {
        if (_disposed || attempt == attemptCount - 1) rethrow;
      }
    }

    throw Exception('Command failed after $attemptCount attempts');
  }

  Future<String> _sendCommandAttempt(
    Contact repeater,
    String command,
    PathSelection selection,
    int attempt,
  ) async {
    if (_disposed) {
      throw StateError('RepeaterCommandService has been disposed.');
    }
    final repeaterKey = repeater.publicKeyHex;
    final commandId = '${repeaterKey}_${DateTime.now().millisecondsSinceEpoch}';
    final completer = Completer<String>();
    _pendingCommands[commandId] = completer;

    try {
      final prefix = _nextPrefixToken();
      _commandPrefixes[commandId] = prefix;
      _pendingByPrefix[prefix] = commandId;
      final framedCommand = '$prefix$command';
      final pathLengthValue = selection.useFlood ? -1 : selection.hopCount;
      final timestampSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      _connector.trackRepeaterAck(
        contact: repeater,
        selection: selection,
        text: framedCommand,
        timestampSeconds: timestampSeconds,
        attempt: attempt,
      );
      final frame = buildSendCliCommandFrame(
        repeater.publicKey,
        framedCommand,
        attempt: attempt,
        timestampSeconds: timestampSeconds,
      );
      final responseBytes = frame.length > maxFrameSize
          ? frame.length
          : maxFrameSize;
      final timeoutMs = _connector.calculateTimeout(
        pathLength: pathLengthValue,
        messageBytes: responseBytes,
      );
      final timeoutSeconds = (timeoutMs / 1000).ceil();
      await _connector.sendFrame(frame);
      _commandTimeouts[commandId]?.cancel();
      _commandTimeouts[commandId] = Timer(
        Duration(milliseconds: timeoutMs),
        () {
          final completer = _pendingCommands[commandId];
          if (completer != null && !completer.isCompleted) {
            completer.completeError(
              'Command timeout after $timeoutSeconds seconds',
            );
            _cleanup(commandId);
          }
        },
      );
    } catch (e) {
      _cleanup(commandId);
      throw Exception('Failed to send command: $e');
    }

    try {
      return await completer.future;
    } finally {
      _cleanup(commandId);
    }
  }

  /// Call this when a text message response is received from a repeater.
  ///
  /// We strictly require the `XX|` prefix that the client prepended to the
  /// outgoing command to be echoed back on the reply, and only complete the
  /// pending command that owns that prefix. Earlier code fell back to "the
  /// first pending command for this repeater" when the prefix was missing,
  /// which silently misrouted async broadcasts, stale replies from a
  /// previously timed-out command, and other unsolicited text messages into
  /// the current command's future (and presented them as command results).
  /// If a reply genuinely lacks a prefix it is not a response to one of our
  /// pending commands and should not complete one — let the command time out
  /// instead so the failure is visible.
  void handleResponse(Contact repeater, String responseText) {
    if (responseText.length < 3 || responseText[2] != '|') {
      return;
    }
    final prefix = responseText.substring(0, 3);
    final commandId = _pendingByPrefix[prefix];
    if (commandId == null) return;

    // Defensive: confirm the prefix actually belongs to a command we sent to
    // *this* repeater. Prefix tokens are only 8 bits, so on heavy concurrent
    // use across multiple repeaters two pending commands could in theory
    // collide on the same byte; pinning by repeaterKey eliminates the cross
    // talk.
    if (!commandId.startsWith(repeater.publicKeyHex)) return;

    final responsePayload = responseText.substring(3).trimLeft();
    final completer = _pendingCommands[commandId];
    if (completer != null && !completer.isCompleted) {
      completer.complete(responsePayload);
      _cleanup(commandId);
    }
  }

  void _cleanup(String commandId) {
    _commandTimeouts[commandId]?.cancel();
    _commandTimeouts.remove(commandId);
    _pendingCommands.remove(commandId);
    final prefix = _commandPrefixes.remove(commandId);
    if (prefix != null) {
      _pendingByPrefix.remove(prefix);
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final timer in _commandTimeouts.values) {
      timer.cancel();
    }
    _commandTimeouts.clear();
    for (final completer in _pendingCommands.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('Repeater command cancelled because the service closed.'),
        );
      }
    }
    _pendingCommands.clear();
    _commandPrefixes.clear();
    _pendingByPrefix.clear();
  }

  String _nextPrefixToken() {
    for (var i = 0; i < 256; i++) {
      final value = _sharedPrefixCounter++ & 0xFF;
      final token = '${value.toRadixString(16).padLeft(2, '0').toUpperCase()}|';
      if (!_pendingByPrefix.containsKey(token)) {
        return token;
      }
    }
    return '00|';
  }
}
