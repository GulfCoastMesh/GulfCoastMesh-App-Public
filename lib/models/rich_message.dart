/// Token kinds understood by the MeshCore rich-message renderer.
///
/// Rich messages intentionally remain plain text on the wire. These tokens are
/// only a local representation of the source text, so an older MeshCore client
/// can still display the exact same message body.
enum RichMessageTokenKind {
  plainText,
  mention,
  replyQuote,
  contactShare,
  hashtag,
  url,
  meshcoreUrl,
  coordinate,
}

/// A non-overlapping span of a message. `raw` is always the exact source text
/// for the span; concatenating all token raws reproduces the original message.
sealed class RichMessageToken {
  final String raw;

  const RichMessageToken(this.raw);

  RichMessageTokenKind get kind;
}

final class RichPlainTextToken extends RichMessageToken {
  const RichPlainTextToken(super.raw);

  @override
  RichMessageTokenKind get kind => RichMessageTokenKind.plainText;
}

final class RichMentionToken extends RichMessageToken {
  final String name;

  const RichMentionToken({required String raw, required this.name})
    : super(raw);

  @override
  RichMessageTokenKind get kind => RichMessageTokenKind.mention;
}

/// MeshCore One's reply-with-quote convention is:
/// `@[sender]\n>message preview..\n`.
final class RichReplyQuoteToken extends RichMessageToken {
  final String mentionName;
  final String quotedText;

  const RichReplyQuoteToken({
    required String raw,
    required this.mentionName,
    required this.quotedText,
  }) : super(raw);

  @override
  RichMessageTokenKind get kind => RichMessageTokenKind.replyQuote;
}

final class RichContactShareToken extends RichMessageToken {
  final String publicKeyHex;
  final int type;
  final String name;

  const RichContactShareToken({
    required String raw,
    required this.publicKeyHex,
    required this.type,
    required this.name,
  }) : super(raw);

  @override
  RichMessageTokenKind get kind => RichMessageTokenKind.contactShare;
}

final class RichHashtagToken extends RichMessageToken {
  /// The complete hashtag, including `#`, preserving the source spelling.
  final String hashtag;

  const RichHashtagToken({required String raw, required this.hashtag})
    : super(raw);

  /// Lowercase channel name without the leading `#`.
  String get normalizedName => hashtag.substring(1).toLowerCase();

  @override
  RichMessageTokenKind get kind => RichMessageTokenKind.hashtag;
}

final class RichUrlToken extends RichMessageToken {
  final Uri uri;

  /// True when this was recognized from a bare domain (no `http(s)://`)
  /// rather than an explicit URL. Still tap-to-open, but callers should
  /// avoid auto-fetching a link preview for it: a schemeless word.tld match
  /// is more likely to be coincidental than a deliberate link.
  final bool isInferred;

  const RichUrlToken({
    required String raw,
    required this.uri,
    this.isInferred = false,
  }) : super(raw);

  @override
  RichMessageTokenKind get kind => RichMessageTokenKind.url;
}

final class RichMeshcoreUrlToken extends RichMessageToken {
  final Uri uri;

  const RichMeshcoreUrlToken({required String raw, required this.uri})
    : super(raw);

  @override
  RichMessageTokenKind get kind => RichMessageTokenKind.meshcoreUrl;
}

final class RichCoordinateToken extends RichMessageToken {
  final double latitude;
  final double longitude;

  const RichCoordinateToken({
    required String raw,
    required this.latitude,
    required this.longitude,
  }) : super(raw);

  @override
  RichMessageTokenKind get kind => RichMessageTokenKind.coordinate;
}

/// Parsed local view of an on-air plain-text message.
final class RichMessage {
  final String text;
  final List<RichMessageToken> tokens;

  RichMessage({required this.text, required List<RichMessageToken> tokens})
    : tokens = List.unmodifiable(tokens);

  /// The original body. This is deliberately not a Markdown-rendered string.
  String get plainText => text;

  Iterable<RichMessageToken> whereKind(RichMessageTokenKind kind) =>
      tokens.where((token) => token.kind == kind);

  bool get containsInteractiveContent =>
      tokens.any((token) => token.kind != RichMessageTokenKind.plainText);
}
