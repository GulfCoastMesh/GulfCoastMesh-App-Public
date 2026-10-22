import 'dart:convert';

import 'package:http/http.dart' as http;

import '../helpers/rich_link_safety.dart';

/// The kind of remote resource returned for a rich-link preview.
enum RichRemoteContentKind { webpage, image, unknown }

/// Metadata used by a rich-message preview card.
final class RichLinkPreview {
  final Uri uri;
  final String? title;
  final String? description;
  final Uri? imageUri;
  final String? contentType;
  final RichRemoteContentKind contentKind;
  final DateTime fetchedAt;

  const RichLinkPreview({
    required this.uri,
    this.title,
    this.description,
    this.imageUri,
    this.contentType,
    required this.contentKind,
    required this.fetchedAt,
  });

  bool get isInlineImage => contentKind == RichRemoteContentKind.image;
}

/// Storage abstraction for preview metadata. Applications can replace this
/// with a persistent store without coupling the preview service to a storage
/// package.
abstract interface class RichPreviewStore {
  Future<RichLinkPreview?> read(Uri uri);

  Future<void> write(RichLinkPreview preview);
}

/// Small in-memory store suitable for the default app cache and unit tests.
final class InMemoryRichPreviewStore implements RichPreviewStore {
  final Map<String, RichLinkPreview> _entries = <String, RichLinkPreview>{};

  @override
  Future<RichLinkPreview?> read(Uri uri) async => _entries[uri.toString()];

  @override
  Future<void> write(RichLinkPreview preview) async {
    _entries[preview.uri.toString()] = preview;
  }

  void clear() => _entries.clear();
}

/// Fetches safe HTTP metadata without making rich-message parsing networked.
///
/// `enabled` and `online` are intentionally evaluated before the HTTP client
/// is touched. A cached value may still be returned while offline; disabled
/// previews always return null. Redirect/DNS policy remains the responsibility
/// of the HTTP client and should apply [RichLinkSafety] to the final URI too.
final class RichLinkPreviewService {
  final http.Client _client;
  final RichPreviewStore _store;
  final bool enabled;
  final bool online;
  final Duration cacheTtl;
  final Duration requestTimeout;
  final int maxBodyBytes;
  final DateTime Function() _now;
  final bool _ownsClient;

  RichLinkPreviewService({
    http.Client? client,
    RichPreviewStore? store,
    this.enabled = true,
    this.online = true,
    this.cacheTtl = const Duration(hours: 12),
    this.requestTimeout = const Duration(seconds: 8),
    this.maxBodyBytes = 512 * 1024,
    DateTime Function()? now,
  }) : _client = client ?? http.Client(),
       _store = store ?? InMemoryRichPreviewStore(),
       _now = now ?? DateTime.now,
       _ownsClient = client == null;

  /// Returns cached metadata or fetches a new preview when allowed.
  Future<RichLinkPreview?> fetch(
    Uri uri, {
    bool? enabledOverride,
    bool? onlineOverride,
  }) async {
    final isEnabled = enabledOverride ?? enabled;
    final isOnline = onlineOverride ?? online;
    if (!isEnabled) return null;

    final eligibility = RichLinkSafety.previewEligibility(
      uri.toString(),
      online: isOnline,
    );
    if (eligibility == RichPreviewEligibility.malformed ||
        eligibility == RichPreviewEligibility.unsupportedScheme ||
        eligibility == RichPreviewEligibility.unsafe) {
      return null;
    }

    final cached = await _store.read(uri);
    if (!isOnline) return cached;
    if (cached != null && _now().difference(cached.fetchedAt) <= cacheTtl) {
      return cached;
    }

    // An offline eligibility result must never reach the HTTP client. This
    // guard also protects callers that pass a stale service configuration.
    if (eligibility != RichPreviewEligibility.eligible) return cached;

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'text/html,image/*'})
          .timeout(requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return cached;
      }
      if (response.bodyBytes.length > maxBodyBytes) return cached;

      final contentType = _header(response.headers, 'content-type');
      final preview = _buildPreview(
        uri: uri,
        contentType: contentType,
        body: response.bodyBytes,
      );
      await _store.write(preview);
      return preview;
    } on Object {
      return cached;
    }
  }

  /// Alias that reads naturally at call sites which use preview terminology.
  Future<RichLinkPreview?> getPreview(
    Uri uri, {
    bool? enabledOverride,
    bool? onlineOverride,
  }) => fetch(
    uri,
    enabledOverride: enabledOverride,
    onlineOverride: onlineOverride,
  );

  /// Classifies a response before deciding whether to display it inline.
  static RichRemoteContentKind classifyRemoteContent(
    Uri uri, {
    String? contentType,
  }) {
    final mime = contentType?.split(';').first.trim().toLowerCase();
    if (mime != null && mime.startsWith('image/')) {
      return RichRemoteContentKind.image;
    }
    final path = uri.path.toLowerCase();
    if (RegExp(r'\.(avif|bmp|gif|jpe?g|png|webp)$').hasMatch(path)) {
      return RichRemoteContentKind.image;
    }
    if (mime == null ||
        mime.isEmpty ||
        mime == 'text/html' ||
        mime == 'text/plain') {
      return RichRemoteContentKind.webpage;
    }
    return RichRemoteContentKind.unknown;
  }

  static bool isRemoteInlineImage(Uri uri, {String? contentType}) =>
      classifyRemoteContent(uri, contentType: contentType) ==
      RichRemoteContentKind.image;

  void close() {
    if (_ownsClient) _client.close();
  }

  RichLinkPreview _buildPreview({
    required Uri uri,
    required String? contentType,
    required List<int> body,
  }) {
    final contentKind = classifyRemoteContent(uri, contentType: contentType);
    if (contentKind == RichRemoteContentKind.image) {
      return RichLinkPreview(
        uri: uri,
        imageUri: uri,
        contentType: contentType,
        contentKind: contentKind,
        fetchedAt: _now(),
      );
    }

    final source = utf8.decode(body, allowMalformed: true);
    final title =
        _firstMetadata(source, const [
          _MetadataSelector('property', 'og:title'),
          _MetadataSelector('name', 'twitter:title'),
          _MetadataSelector('name', 'title'),
        ]) ??
        _firstMatch(
          source,
          RegExp(
            r'<title[^>]*>(.*?)</title>',
            caseSensitive: false,
            dotAll: true,
          ),
        );
    final description = _firstMetadata(source, const [
      _MetadataSelector('property', 'og:description'),
      _MetadataSelector('name', 'description'),
      _MetadataSelector('name', 'twitter:description'),
    ]);
    final imageRaw = _firstMetadata(source, const [
      _MetadataSelector('property', 'og:image'),
      _MetadataSelector('name', 'twitter:image'),
    ]);
    final imageUri = _safeResolvedUri(uri, imageRaw);
    return RichLinkPreview(
      uri: uri,
      title: _cleanText(title, maxLength: 240),
      description: _cleanText(description, maxLength: 1000),
      imageUri: imageUri,
      contentType: contentType,
      contentKind: contentKind,
      fetchedAt: _now(),
    );
  }

  static String? _firstMetadata(
    String source,
    List<_MetadataSelector> selectors,
  ) {
    final tags = RegExp(
      r'<meta\b[^>]*>',
      caseSensitive: false,
    ).allMatches(source);
    for (final selector in selectors) {
      for (final tag in tags) {
        final value = tag.group(0)!;
        final attribute = RegExp(
          "${selector.attribute}\\s*=\\s*[\"']${RegExp.escape(selector.value)}[\"']",
          caseSensitive: false,
        );
        if (!attribute.hasMatch(value)) continue;
        final content = RegExp(
          r'''content\s*=\s*["'](.*?)["']''',
          caseSensitive: false,
          dotAll: true,
        ).firstMatch(value)?.group(1);
        if (content != null && content.trim().isNotEmpty) {
          return _decodeHtml(content);
        }
      }
    }
    return null;
  }

  static String? _firstMatch(String source, RegExp pattern) {
    final value = pattern.firstMatch(source)?.group(1);
    return value == null ? null : _decodeHtml(value);
  }

  static Uri? _safeResolvedUri(Uri base, String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final resolved = Uri.tryParse(raw.trim());
    final absolute = resolved == null
        ? null
        : (resolved.hasScheme ? resolved : base.resolveUri(resolved));
    if (absolute == null || !RichLinkSafety.isSafeHttpUri(absolute)) {
      return null;
    }
    return absolute;
  }

  static String? _cleanText(String? value, {required int maxLength}) {
    if (value == null) return null;
    final result = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (result.isEmpty) return null;
    return result.length <= maxLength
        ? result
        : '${result.substring(0, maxLength - 1)}…';
  }

  static String _decodeHtml(String value) => value
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');

  static String? _header(Map<String, String> headers, String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name) return entry.value;
    }
    return null;
  }
}

final class _MetadataSelector {
  final String attribute;
  final String value;

  const _MetadataSelector(this.attribute, this.value);
}
