import 'dart:convert';
import 'dart:typed_data';

import '../connector/meshcore_protocol.dart';

/// CLI commands whose arguments must not appear in debug logs.
const List<String> _sensitiveCliPrefixes = [
  'password ',
  'set guest.password ',
  'set prv.key ',
  'set bridge.secret ',
];

/// Optional `XX|` correlation prefix used by [RepeaterCommandService].
final RegExp _cliCorrelationPrefix = RegExp(r'^[0-9a-fA-F]{2}\|');

/// Returns the CLI text with an optional `XX|` framing prefix stripped.
String stripCliCorrelationPrefix(String command) {
  final trimmed = command.trimLeft();
  final match = _cliCorrelationPrefix.firstMatch(trimmed);
  if (match == null) return trimmed;
  return trimmed.substring(match.end);
}

/// Returns true when [command] is a CLI string that carries a password.
bool isSensitiveCliCommand(String command) {
  final lower = stripCliCorrelationPrefix(command).toLowerCase();
  for (final prefix in _sensitiveCliPrefixes) {
    if (lower.startsWith(prefix)) return true;
  }
  return false;
}

/// Redacts the password argument from a CLI command string.
String redactSensitiveCliText(String command) {
  final leadingWs = command.length - command.trimLeft().length;
  final body = command.substring(leadingWs);
  final corrMatch = _cliCorrelationPrefix.firstMatch(body);
  final corrLen = corrMatch?.end ?? 0;
  final afterCorr = body.substring(corrLen);
  final lower = afterCorr.toLowerCase();
  for (final prefix in _sensitiveCliPrefixes) {
    if (lower.startsWith(prefix)) {
      return '${command.substring(0, leadingWs + corrLen + prefix.length)}***';
    }
  }
  return command;
}

/// Copy of [frame] with login passwords, channel PSKs, flood-scope keys, and
/// CLI password arguments zeroed/redacted for BLE debug storage and viewers.
Uint8List redactSensitiveFrame(Uint8List frame) {
  if (frame.isEmpty) return frame;

  // Local companion CLI: [0x01][utf8 text][0x00] (docs/BLE_PROTOCOL.md).
  // This shares its lead byte with CMD_APP_START, whose second byte is a small
  // protocol version rather than printable text, so the two are separable.
  if (frame[0] == cmdAppStart && frame.length > 2 && frame[1] >= 0x20) {
    final redacted = _redactLocalCliFrame(frame);
    if (redacted != null) return redacted;
  }

  if (frame[0] == cmdSendLogin && frame.length > 1) {
    final redacted = Uint8List(frame.length);
    redacted[0] = frame[0];
    final keep = frame.length < 33 ? 1 : 33;
    redacted.setRange(1, keep, frame.sublist(1, keep));
    return redacted;
  }

  // Format: [cmd][idx][name x32][psk x16]
  if (frame[0] == cmdSetChannel && frame.length >= 50) {
    final redacted = Uint8List.fromList(frame);
    redacted.fillRange(34, 50, 0);
    return redacted;
  }

  // Inbound CHANNEL_INFO carries the 16-byte PSK at bytes 34-49.
  // Format: [code][idx][name x32][psk x16]
  if (frame[0] == respCodeChannelInfo && frame.length >= 50) {
    final redacted = Uint8List.fromList(frame);
    redacted.fillRange(34, 50, 0);
    return redacted;
  }

  // Format: [cmd][0x00][key x16] (set); shorter clear/unscoped frames carry
  // no key material.
  if (frame[0] == cmdSetFloodScopeKey &&
      frame.length >= 2 + defaultFloodScopeKeyBytes) {
    final redacted = Uint8List.fromList(frame);
    redacted.fillRange(2, 2 + defaultFloodScopeKeyBytes, 0);
    return redacted;
  }

  // Format: [cmd][name x31][scope_key x16] (or [cmd] alone to clear)
  if (frame[0] == cmdSetDefaultFloodScope &&
      frame.length >=
          1 + defaultFloodScopeNameField + defaultFloodScopeKeyBytes) {
    final redacted = Uint8List.fromList(frame);
    final keyStart = 1 + defaultFloodScopeNameField;
    redacted.fillRange(keyStart, keyStart + defaultFloodScopeKeyBytes, 0);
    return redacted;
  }

  // Format: [code][name x31][scope_key x16]
  if (frame[0] == respCodeDefaultFloodScope &&
      frame.length >=
          1 + defaultFloodScopeNameField + defaultFloodScopeKeyBytes) {
    final redacted = Uint8List.fromList(frame);
    final keyStart = 1 + defaultFloodScopeNameField;
    redacted.fillRange(keyStart, keyStart + defaultFloodScopeKeyBytes, 0);
    return redacted;
  }

  if (frame[0] == cmdSendTxtMsg && frame.length > 13) {
    final txtType = frame[1];
    if (txtType == txtTypeCliData) {
      final textStart = 13;
      final textBytes = frame.sublist(textStart);
      final nullIdx = textBytes.indexOf(0);
      final end = nullIdx >= 0 ? nullIdx : textBytes.length;
      final text = utf8.decode(textBytes.sublist(0, end), allowMalformed: true);
      if (isSensitiveCliCommand(text)) {
        final redactedText = redactSensitiveCliText(text);
        final redactedUtf8 = utf8.encode(redactedText);
        final outLen = textStart + redactedUtf8.length + (nullIdx >= 0 ? 1 : 0);
        final redacted = Uint8List(outLen);
        redacted.setRange(0, textStart, frame.sublist(0, textStart));
        redacted.setRange(
          textStart,
          textStart + redactedUtf8.length,
          redactedUtf8,
        );
        if (nullIdx >= 0) {
          redacted[textStart + redactedUtf8.length] = 0;
        }
        return redacted;
      }
    }
  }

  return Uint8List.fromList(frame);
}

/// Redacts a `[0x01][text][0x00]` local CLI frame, or returns null when it
/// carries nothing sensitive.
Uint8List? _redactLocalCliFrame(Uint8List frame) {
  final body = frame.sublist(1);
  final nullIdx = body.indexOf(0);
  final end = nullIdx >= 0 ? nullIdx : body.length;
  final text = utf8.decode(body.sublist(0, end), allowMalformed: true);
  if (!isSensitiveCliCommand(text)) return null;
  final redactedUtf8 = utf8.encode(redactSensitiveCliText(text));
  return Uint8List.fromList([frame[0], ...redactedUtf8, if (nullIdx >= 0) 0]);
}
