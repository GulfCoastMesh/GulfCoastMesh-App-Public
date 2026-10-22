/// Safety checks used before a message URL is fetched for a preview.
///
/// This helper is synchronous and has no DNS or network side effects, which
/// keeps parsing safe to use while offline and on every Flutter target. Hosts
/// that resolve to private addresses must still be checked by the networking
/// layer after DNS resolution before following redirects.
enum RichPreviewEligibility {
  eligible,
  offline,
  malformed,
  unsupportedScheme,
  unsafe,
}

class RichLinkSafety {
  RichLinkSafety._();

  static const _httpSchemes = {'http', 'https'};

  /// Returns whether [uri] is suitable for a remote HTTP preview request.
  /// This checks the URI itself only; DNS answers and redirects need the same
  /// check at request time.
  static bool isSafeHttpUri(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (!_httpSchemes.contains(scheme) || uri.host.isEmpty) return false;
    if (uri.userInfo.isNotEmpty) return false;
    if (uri.host.contains('%') || uri.host.contains(RegExp(r'[\x00-\x20]'))) {
      return false;
    }
    return !isPrivateOrReservedHost(uri.host);
  }

  /// Classifies a raw URL without attempting a network request.
  ///
  /// A safe URL can be retained and rendered as a normal link when offline;
  /// it simply must not trigger a preview fetch until connectivity returns.
  static RichPreviewEligibility previewEligibility(
    String raw, {
    bool online = true,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return RichPreviewEligibility.malformed;

    final Uri uri;
    try {
      uri = Uri.parse(trimmed);
    } on FormatException {
      return RichPreviewEligibility.malformed;
    }

    final scheme = uri.scheme.toLowerCase();
    if (!_httpSchemes.contains(scheme)) {
      return RichPreviewEligibility.unsupportedScheme;
    }
    if (!isSafeHttpUri(uri)) return RichPreviewEligibility.unsafe;
    return online
        ? RichPreviewEligibility.eligible
        : RichPreviewEligibility.offline;
  }

  /// Checks IPv4, IPv6 and common local host names without importing dart:io.
  /// DNS resolution is intentionally left to the HTTP client/service.
  static bool isPrivateOrReservedHost(String host) {
    var normalized = host.toLowerCase().trim();
    if (normalized.startsWith('[') && normalized.endsWith(']')) {
      normalized = normalized.substring(1, normalized.length - 1);
    }
    if (normalized.isEmpty ||
        normalized == 'localhost' ||
        normalized.endsWith('.localhost') ||
        normalized.endsWith('.local') ||
        normalized.endsWith('.internal') ||
        normalized == 'metadata.google.internal' ||
        normalized == 'ip6-loopback') {
      return true;
    }

    final ipv4 = _parseIpv4(normalized);
    if (ipv4 != null) {
      final a = ipv4[0];
      final b = ipv4[1];
      if (a == 0 || a == 10 || a == 127 || a >= 224) return true;
      if (a == 172 && b >= 16 && b <= 31) return true;
      if (a == 192 && b == 168) return true;
      if (a == 169 && b == 254) return true;
      return false;
    }

    if (normalized.contains(':')) return _isPrivateIpv6(normalized);
    return false;
  }

  static List<int>? _parseIpv4(String host) {
    final parts = host.split('.');
    if (parts.length != 4 || parts.any((part) => part.isEmpty)) return null;
    final values = <int>[];
    for (final part in parts) {
      if (!RegExp(r'^\d{1,3}$').hasMatch(part)) return null;
      final value = int.tryParse(part);
      if (value == null || value > 255) return null;
      values.add(value);
    }
    return values;
  }

  static bool _isPrivateIpv6(String host) {
    final normalized = host.toLowerCase();
    if (normalized == '::' || normalized == '::1') return true;
    if (normalized.startsWith('fe8') ||
        normalized.startsWith('fe9') ||
        normalized.startsWith('fea') ||
        normalized.startsWith('feb') ||
        normalized.startsWith('fc') ||
        normalized.startsWith('fd') ||
        normalized.startsWith('ff')) {
      return true;
    }

    // IPv4-mapped IPv6 forms, including ::ffff:127.0.0.1.
    final lastColon = normalized.lastIndexOf(':');
    if (lastColon >= 0) {
      final mapped = _parseIpv4(normalized.substring(lastColon + 1));
      if (mapped != null) {
        return isPrivateOrReservedHost(mapped.join('.'));
      }
    }
    return false;
  }
}
