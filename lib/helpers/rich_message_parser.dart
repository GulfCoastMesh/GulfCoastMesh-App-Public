import 'package:characters/characters.dart';

import '../models/rich_message.dart';

/// Parses MeshCore One-compatible message decorations locally.
///
/// No transformation is performed on the wire text. In particular, this is
/// not a Markdown parser: unknown syntax remains a plain-text token.
class RichMessageParser {
  RichMessageParser._();

  static final _mentionPattern = RegExp(r'@\[([^\]\r\n]+)\]');
  static final _replyPattern = RegExp(
    r'^@\[([^\]\r\n]+)\]\r?\n>([^\r\n]*)(?:\r?\n|$)',
  );
  static final _contactPattern = RegExp(r'<([0-9a-fA-F]{64}):(\d+):([^>]+)>');
  static final _urlPattern = RegExp(r'(?:https?|meshcore)://[^\s<>]+');
  // Mesh users drop the scheme to save airtime, so `gulfcoastmesh.com` has to
  // linkify too. Matching any dotted token would catch `Rcvd.Copy`, so the
  // last label must be a known TLD.
  static const _knownTlds =
      'com|net|org|edu|gov|mil|int|io|co|us|uk|ca|de|fr|nl|au|jp|eu|'
      'app|dev|xyz|info|biz|me|tv|cc|live|gg|news|site|online|tech|'
      'link|page|blog|shop|store|cloud|team|group|zone|radio|ham';
  static final _bareDomainPattern = RegExp(
    r'(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+'
    '(?:$_knownTlds)'
    r'(?![A-Za-z0-9-])(?::\d{1,5})?(?:/[^\s<>]*)?',
    caseSensitive: false,
  );
  static final _hashtagPattern = RegExp(r'#[A-Za-z0-9][A-Za-z0-9-]*');
  static final _coordinatePattern = RegExp(
    r'(-?\d{1,3}\.\d+)\s*,\s*(-?\d{1,3}\.\d+)',
  );

  /// Parses [text] into non-overlapping, source-order tokens.
  static RichMessage parse(String text) {
    if (text.isEmpty) {
      return RichMessage(text: text, tokens: const [RichPlainTextToken('')]);
    }

    final candidates = <_Candidate>[];
    final reply = _replyPattern.firstMatch(text);
    if (reply != null) {
      candidates.add(
        _Candidate(
          start: reply.start,
          end: reply.end,
          priority: 0,
          token: RichReplyQuoteToken(
            raw: text.substring(reply.start, reply.end),
            mentionName: reply.group(1)!,
            quotedText: reply.group(2)!,
          ),
        ),
      );
    }

    for (final match in _contactPattern.allMatches(text)) {
      final type = int.tryParse(match.group(2)!);
      // MeshCore contact types are one-byte values 1 (chat), 2 (repeater),
      // and 3 (room). Keep malformed/unknown types as ordinary text.
      if (type == null || type < 1 || type > 3) continue;
      candidates.add(
        _Candidate(
          start: match.start,
          end: match.end,
          priority: 1,
          token: RichContactShareToken(
            raw: match.group(0)!,
            publicKeyHex: match.group(1)!.toLowerCase(),
            type: type,
            name: match.group(3)!,
          ),
        ),
      );
    }

    for (final match in _mentionPattern.allMatches(text)) {
      candidates.add(
        _Candidate(
          start: match.start,
          end: match.end,
          priority: 2,
          token: RichMentionToken(raw: match.group(0)!, name: match.group(1)!),
        ),
      );
    }

    for (final match in _urlPattern.allMatches(text)) {
      final start = match.start;
      final raw = _trimUrlPunctuation(match.group(0)!);
      if (raw.isEmpty) continue;
      final uri = Uri.tryParse(raw);
      if (uri == null || uri.host.isEmpty) continue;
      final isMeshcore = uri.scheme.toLowerCase() == 'meshcore';
      candidates.add(
        _Candidate(
          start: start,
          end: start + raw.length,
          priority: isMeshcore ? 3 : 4,
          token: isMeshcore
              ? RichMeshcoreUrlToken(raw: raw, uri: uri)
              : RichUrlToken(raw: raw, uri: uri),
        ),
      );
    }

    for (final match in _bareDomainPattern.allMatches(text)) {
      if (!_bareDomainBoundaryIsValid(text, match.start)) continue;
      final raw = _trimUrlPunctuation(match.group(0)!);
      if (raw.isEmpty) continue;
      // The token keeps the text as typed; only the launch target gains a
      // scheme, because `Uri.parse('example.com')` has no host to open.
      final uri = Uri.tryParse('https://$raw');
      if (uri == null || uri.host.isEmpty) continue;
      candidates.add(
        _Candidate(
          start: match.start,
          end: match.start + raw.length,
          priority: 7,
          token: RichUrlToken(raw: raw, uri: uri, isInferred: true),
        ),
      );
    }

    for (final match in _hashtagPattern.allMatches(text)) {
      if (!_hashtagBoundaryIsValid(text, match.start)) continue;
      candidates.add(
        _Candidate(
          start: match.start,
          end: match.end,
          priority: 5,
          token: RichHashtagToken(
            raw: match.group(0)!,
            hashtag: match.group(0)!,
          ),
        ),
      );
    }

    for (final match in _coordinatePattern.allMatches(text)) {
      if (!_coordinateBoundaryIsValid(text, match.start, match.end)) continue;
      final latitude = double.tryParse(match.group(1)!);
      final longitude = double.tryParse(match.group(2)!);
      if (latitude == null ||
          longitude == null ||
          latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180) {
        continue;
      }
      // `1.0, 2.0, 3.0` is a number list, not a coordinate. This mirrors
      // MeshCore One's decimal-list guard.
      final remainder = text.substring(match.end);
      if (RegExp(r'^\s*,\s*-?\d').hasMatch(remainder)) continue;
      candidates.add(
        _Candidate(
          start: match.start,
          end: match.end,
          priority: 6,
          token: RichCoordinateToken(
            raw: match.group(0)!,
            latitude: latitude,
            longitude: longitude,
          ),
        ),
      );
    }

    candidates.sort((a, b) {
      final priority = a.priority.compareTo(b.priority);
      if (priority != 0) return priority;
      return a.start.compareTo(b.start);
    });

    final accepted = <_Candidate>[];
    for (final candidate in candidates) {
      if (accepted.any((existing) => existing.overlaps(candidate))) continue;
      accepted.add(candidate);
    }
    accepted.sort((a, b) => a.start.compareTo(b.start));

    final tokens = <RichMessageToken>[];
    var cursor = 0;
    for (final candidate in accepted) {
      if (candidate.start > cursor) {
        tokens.add(RichPlainTextToken(text.substring(cursor, candidate.start)));
      }
      tokens.add(candidate.token);
      cursor = candidate.end;
    }
    if (cursor < text.length) {
      tokens.add(RichPlainTextToken(text.substring(cursor)));
    }
    if (tokens.isEmpty) tokens.add(RichPlainTextToken(text));

    return RichMessage(text: text, tokens: tokens);
  }

  /// Builds the MeshCore One reply-with-quote body.
  static String buildReplyText({
    required String mentionName,
    required String messageText,
  }) {
    final source = messageText.replaceFirst(RegExp(r'^@\[[^\]\r\n]+\]\s*'), '');
    final preview = source.characters.take(10).toString();
    final suffix = source.characters.length > 10 ? '..' : '';
    return '@[$mentionName]\n>$preview$suffix\n';
  }

  /// Link detectors commonly include sentence punctuation. Keep balanced
  /// parentheses, but do not make `example.com).` part of the URL.
  static String _trimUrlPunctuation(String value) {
    var raw = value;
    while (raw.isNotEmpty && '.,;:!?'.contains(raw[raw.length - 1])) {
      raw = raw.substring(0, raw.length - 1);
    }
    while (raw.endsWith(')') && _unbalancedClosingParenthesis(raw)) {
      raw = raw.substring(0, raw.length - 1);
    }
    return raw;
  }

  /// Rejects a schemeless domain that is really part of a larger token, such
  /// as the host inside `https://example.com` or the domain in an email
  /// address. Scheme URLs are matched separately and win on overlap.
  static bool _bareDomainBoundaryIsValid(String text, int start) {
    if (start == 0) return true;
    return !RegExp(r'[A-Za-z0-9_@./\\:-]').hasMatch(text[start - 1]);
  }

  static bool _hashtagBoundaryIsValid(String text, int start) {
    if (start == 0) return true;
    final previous = text[start - 1];
    return !RegExp(r'[A-Za-z0-9_#]').hasMatch(previous);
  }

  static bool _coordinateBoundaryIsValid(String text, int start, int end) {
    if (start > 0 && RegExp(r'[A-Za-z0-9_.]').hasMatch(text[start - 1])) {
      return false;
    }
    if (end < text.length && RegExp(r'[A-Za-z0-9_]').hasMatch(text[end])) {
      return false;
    }
    // A version prefix such as `v1.2, 3.4` must not be recognized.
    if (start > 0 && text[start - 1] == 'v') return false;
    return true;
  }

  static bool _unbalancedClosingParenthesis(String value) {
    var open = 0;
    for (final character in value.characters) {
      if (character == '(') open++;
      if (character == ')') open--;
    }
    return open < 0;
  }
}

class _Candidate {
  final int start;
  final int end;
  final int priority;
  final RichMessageToken token;

  const _Candidate({
    required this.start,
    required this.end,
    required this.priority,
    required this.token,
  });

  bool overlaps(_Candidate other) => start < other.end && other.start < end;
}
