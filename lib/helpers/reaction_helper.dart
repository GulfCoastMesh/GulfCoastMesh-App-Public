import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;

import '../widgets/emoji_picker.dart';

/// The wire format used by a reaction.
///
/// `meshCoreOne*` is the current interoperable format.  The two
/// `gulfCoastMeshApp*` formats are retained for compatibility with existing
/// Gulf Coast Mesh App installations; v1 is receive-only.
enum ReactionWireFormat {
  meshCoreOneDm,
  meshCoreOneChannel,
  gulfCoastMeshAppV3,
  gulfCoastMeshAppV1,
}

/// A reaction after parsing its wire representation.
///
/// [targetHash] is the original hash as received (lower-case for v3 and
/// Crockford formats).  For v1 it is the opaque
/// `timestampMillis_senderHash_textHash` identifier, which is useful for
/// deduplication while the individual numeric fields allow matching.
class ReactionInfo {
  final String targetHash;
  final String emoji;
  final ReactionWireFormat format;
  final String? targetSender;
  final int? timestampSeconds;
  final int? senderNameHash;
  final int? textHash;

  ReactionInfo({
    required this.targetHash,
    required this.emoji,
    this.format = ReactionWireFormat.gulfCoastMeshAppV3,
    this.targetSender,
    this.timestampSeconds,
    this.senderNameHash,
    this.textHash,
  });

  /// Whether this reaction uses the canonical MeshCore One hash.
  bool get isMeshCoreOne =>
      format == ReactionWireFormat.meshCoreOneDm ||
      format == ReactionWireFormat.meshCoreOneChannel;

  /// Whether this is the pre-v3 Gulf Coast Mesh App representation.
  bool get isLegacyV1 => format == ReactionWireFormat.gulfCoastMeshAppV1;
}

/// Hashing and wire-format helpers for emoji reactions.
class ReactionHelper {
  ReactionHelper._();

  static List<String>? _cachedEmojis;

  /// Combined Gulf Coast Mesh App emoji table in its protocol-defined order.
  ///
  /// The table intentionally retains duplicate entries between categories.
  /// Those duplicates are part of the on-air index contract (for example,
  /// `👍` occurs at both 0x00 and 0x46), so do not de-duplicate this list.
  static List<String> get reactionEmojis {
    return _cachedEmojis ??= List.unmodifiable([
      ...EmojiPicker.quickEmojis,
      ...EmojiPicker.smileys,
      ...EmojiPicker.gestures,
      ...EmojiPicker.hearts,
      ...EmojiPicker.objects,
    ]);
  }

  /// Convert an emoji to its two-character lower-case v3 hex index.
  static String? emojiToIndex(String emoji) {
    final idx = reactionEmojis.indexOf(emoji);
    if (idx < 0 || idx > 0xff) return null;
    return idx.toRadixString(16).padLeft(2, '0');
  }

  /// Convert a two-character hex index to the protocol emoji.
  static String? indexToEmoji(String hexIndex) {
    if (!RegExp(r'^[0-9a-fA-F]{2}$').hasMatch(hexIndex)) return null;
    final idx = int.tryParse(hexIndex, radix: 16);
    if (idx == null || idx >= reactionEmojis.length) return null;
    return reactionEmojis[idx];
  }

  /// Reimplementation of Dart's UTF-16 string hash algorithm used by the
  /// legacy Gulf Coast Mesh App reaction protocol.
  ///
  /// Keeping this explicit is important: `String.hashCode` is not a stable
  /// wire primitive across Dart runtimes, and iterating Unicode code points
  /// instead of UTF-16 units breaks emoji and astral-character compatibility.
  static int dartStringHash(String value) =>
      dartStringHashCodeUnits(value.codeUnits);

  /// Hash UTF-16 code units using the Dart VM algorithm (30-bit result).
  static int dartStringHashCodeUnits(Iterable<int> codeUnits) {
    var hash = 0;
    for (final unit in codeUnits) {
      hash = _u32(hash + unit);
      hash = _u32(hash + _u32(hash << 10));
      hash ^= hash >>> 6;
    }
    hash = _u32(hash + _u32(hash << 3));
    hash ^= hash >>> 11;
    hash = _u32(hash + _u32(hash << 15));
    hash &= 0x3fffffff;
    return hash == 0 ? 1 : hash;
  }

  /// Compute the four-character hash used by Gulf Coast Mesh App v3.
  ///
  /// The input is the decimal timestamp, optional sender name, and the first
  /// five UTF-16 code units of the message.  The result is the lower 16 bits
  /// of the explicit Dart-compatible hash.
  static String computeReactionHash(
    int timestampSeconds,
    String? senderName,
    String text,
  ) {
    final units = <int>[
      ...timestampSeconds.toString().codeUnits,
      ...(senderName?.codeUnits ?? const <int>[]),
      ...text.codeUnits.take(5),
    ];
    final hash = dartStringHashCodeUnits(units) & 0xffff;
    return hash.toRadixString(16).padLeft(4, '0');
  }

  /// SHA-256/Crockford message hash used by MeshCore One.
  ///
  /// Hash input is exactly UTF-8 message text followed by the sender's
  /// original timestamp as an unsigned 32-bit little-endian integer.
  static String generateMessageHash(String text, int timestampSeconds) {
    if (timestampSeconds < 0 || timestampSeconds > 0xffffffff) {
      throw ArgumentError.value(
        timestampSeconds,
        'timestampSeconds',
        'must fit in an unsigned 32-bit integer',
      );
    }

    final bytes = <int>[...utf8.encode(text)];
    final timestamp = timestampSeconds;
    bytes
      ..add(timestamp & 0xff)
      ..add((timestamp >> 8) & 0xff)
      ..add((timestamp >> 16) & 0xff)
      ..add((timestamp >> 24) & 0xff);

    return _encodeCrockford(crypto.sha256.convert(bytes).bytes.take(5));
  }

  /// Alias matching the name used by MeshCore One's implementation.
  static String computeMeshCoreOneHash(String text, int timestampSeconds) =>
      generateMessageHash(text, timestampSeconds);

  /// Build a canonical MeshCore One DM reaction: `{emoji}\n{hash}`.
  static String buildDMReactionText({
    required String emoji,
    required String targetText,
    required int targetTimestamp,
  }) {
    _validateOutgoingEmoji(emoji);
    return '$emoji\n${generateMessageHash(targetText, targetTimestamp)}';
  }

  /// Build a canonical MeshCore One channel reaction:
  /// `{emoji}@[targetSender]\n{hash}`.
  static String buildReactionText({
    required String emoji,
    required String targetSender,
    required String targetText,
    required int targetTimestamp,
  }) {
    _validateOutgoingEmoji(emoji);
    if (targetSender.isEmpty || targetSender.contains(RegExp(r'[\r\n\[\]]'))) {
      throw ArgumentError.value(targetSender, 'targetSender');
    }
    return '$emoji@[$targetSender]\n${generateMessageHash(targetText, targetTimestamp)}';
  }

  /// More explicit aliases for callers that send both protocol families.
  static String buildMeshCoreOneDMReaction({
    required String emoji,
    required String targetText,
    required int targetTimestamp,
  }) => buildDMReactionText(
    emoji: emoji,
    targetText: targetText,
    targetTimestamp: targetTimestamp,
  );

  static String buildMeshCoreOneChannelReaction({
    required String emoji,
    required String targetSender,
    required String targetText,
    required int targetTimestamp,
  }) => buildReactionText(
    emoji: emoji,
    targetSender: targetSender,
    targetText: targetText,
    targetTimestamp: targetTimestamp,
  );

  /// Build the legacy receive-compatible v1 representation.
  ///
  /// This is provided for fixture generation and migration tooling; new
  /// messages should use MeshCore One or v3.
  static String buildV1ReactionText({
    required String emoji,
    required int timestampMillis,
    required String targetText,
    String? targetSender,
  }) {
    if (timestampMillis < 0) {
      throw ArgumentError.value(timestampMillis, 'timestampMillis');
    }
    _validateOutgoingEmoji(emoji);
    final senderHash = dartStringHash(targetSender ?? '');
    final textHash = dartStringHash(targetText);
    return 'r:${timestampMillis}_${senderHash}_$textHash:$emoji';
  }

  /// Parse a v3 reaction. This preserves the original public API semantics.
  static ReactionInfo? parseV3Reaction(String text) {
    final match = RegExp(r'^r:([0-9a-f]{4}):([0-9a-f]{2})$').firstMatch(text);
    if (match == null) return null;
    final emoji = indexToEmoji(match.group(2)!);
    if (emoji == null) return null;
    return ReactionInfo(
      targetHash: match.group(1)!,
      emoji: emoji,
      format: ReactionWireFormat.gulfCoastMeshAppV3,
    );
  }

  /// Parse a MeshCore One channel reaction.
  static ReactionInfo? parseChannelReaction(String text) {
    final newline = text.lastIndexOf('\n');
    if (newline <= 0 || newline == text.length - 1) return null;
    final hash = _normalizeCrockford(text.substring(newline + 1));
    if (hash == null) return null;

    final prefix = text.substring(0, newline);
    final atBracket = prefix.indexOf('@[');
    if (atBracket <= 0 || !prefix.endsWith(']')) return null;
    final emoji = prefix.substring(0, atBracket);
    final sender = prefix.substring(atBracket + 2, prefix.length - 1);
    if (!_isWireEmoji(emoji) || sender.isEmpty) return null;

    return ReactionInfo(
      targetHash: hash,
      emoji: emoji,
      format: ReactionWireFormat.meshCoreOneChannel,
      targetSender: sender,
    );
  }

  /// Parse a MeshCore One direct-message reaction.
  static ReactionInfo? parseDMReaction(String text) {
    if (text.contains('@[')) return null;
    final newline = text.lastIndexOf('\n');
    if (newline <= 0 || newline == text.length - 1) return null;
    final emoji = text.substring(0, newline);
    final hash = _normalizeCrockford(text.substring(newline + 1));
    if (hash == null || !_isWireEmoji(emoji)) return null;
    return ReactionInfo(
      targetHash: hash,
      emoji: emoji,
      format: ReactionWireFormat.meshCoreOneDm,
    );
  }

  /// Parse a Gulf Coast Mesh App v1 reaction.
  ///
  /// Format: `r:{timestampMillis}_{senderNameHash}_{textHash}:{emoji}`.
  static ReactionInfo? parseV1Reaction(String text) {
    if (!text.startsWith('r:')) return null;
    final colon = text.lastIndexOf(':');
    if (colon <= 2 || colon == text.length - 1) return null;
    final parts = text.substring(2, colon).split('_');
    if (parts.length != 3) return null;
    final timestampMillis = int.tryParse(parts[0]);
    final senderHash = int.tryParse(parts[1]);
    final textHash = int.tryParse(parts[2]);
    final emoji = text.substring(colon + 1);
    if (timestampMillis == null ||
        senderHash == null ||
        textHash == null ||
        timestampMillis < 0 ||
        senderHash < 0 ||
        senderHash > 0x3fffffff ||
        textHash < 0 ||
        textHash > 0x3fffffff ||
        timestampMillis ~/ 1000 > 0xffffffff ||
        !_isWireEmoji(emoji)) {
      return null;
    }

    return ReactionInfo(
      targetHash: '${parts[0]}_${parts[1]}_${parts[2]}',
      emoji: emoji,
      format: ReactionWireFormat.gulfCoastMeshAppV1,
      timestampSeconds: timestampMillis ~/ 1000,
      senderNameHash: senderHash,
      textHash: textHash,
    );
  }

  /// Parse every supported reaction format, preferring canonical formats.
  static ReactionInfo? parseAnyReaction(String text) {
    return parseChannelReaction(text) ??
        parseDMReaction(text) ??
        parseV3Reaction(text) ??
        parseV1Reaction(text);
  }

  /// Parse supported formats while retaining the long-standing v3 API.
  ///
  /// Existing callers used this method as their reaction discriminator, so it
  /// now accepts all receive formats.  Use [parseV3Reaction] when a caller
  /// specifically needs the old `r:hash:index` representation.
  static ReactionInfo? parseReaction(String text) => parseAnyReaction(text);

  /// Returns true when [text] is any supported reaction representation.
  static bool isReactionText(String text) => parseAnyReaction(text) != null;

  /// Normalize an 8-character Crockford hash, tolerating case and the
  /// O/I/L confusables the same way reaction hashes do. Exposed for other
  /// wire formats (e.g. message edits) built on the same message hash.
  static String? normalizeHash(String value) => _normalizeCrockford(value);

  static String _encodeCrockford(Iterable<int> input) {
    const alphabet = '0123456789abcdefghjkmnpqrstvwxyz';
    final bytes = input.toList(growable: false);
    if (bytes.length != 5) throw StateError('Crockford input must be 5 bytes');
    var value = 0;
    for (final byte in bytes) {
      value = (value << 8) | byte;
    }
    final out = StringBuffer();
    for (var shift = 35; shift >= 0; shift -= 5) {
      out.write(alphabet[(value >> shift) & 0x1f]);
    }
    return out.toString();
  }

  static String? _normalizeCrockford(String value) {
    if (value.length != 8) return null;
    const alphabet = '0123456789abcdefghjkmnpqrstvwxyz';
    final out = StringBuffer();
    for (final character in value.codeUnits) {
      final lower = character | 0x20;
      var index = -1;
      if (lower >= 0x30 && lower <= 0x39) {
        index = lower - 0x30;
      } else if (lower >= 0x61 && lower <= 0x7a) {
        index = alphabet.indexOf(String.fromCharCode(lower));
      }
      if (index < 0) {
        if (character == 0x4f || character == 0x6f) {
          index = 0;
        } else if (character == 0x49 ||
            character == 0x69 ||
            character == 0x4c ||
            character == 0x6c) {
          index = 1;
        }
      }
      if (index < 0) return null;
      out.write(alphabet[index]);
    }
    return out.toString();
  }

  static bool _isWireEmoji(String value) {
    if (value.isEmpty || value.contains(RegExp(r'[\r\n@\[\]]'))) return false;
    // A reaction may be an emoji outside the picker table. Reject plain text
    // while allowing variation selectors, ZWJ sequences and regional flags.
    return value.runes.any(
      (rune) =>
          (rune >= 0x1f000 && rune <= 0x1faff) ||
          (rune >= 0x2600 && rune <= 0x27bf) ||
          rune == 0xfe0f ||
          rune == 0x200d,
    );
  }

  static void _validateOutgoingEmoji(String emoji) {
    if (!_isWireEmoji(emoji)) {
      throw ArgumentError.value(emoji, 'emoji', 'must contain an emoji');
    }
  }

  static int _u32(int value) => value & 0xffffffff;
}
