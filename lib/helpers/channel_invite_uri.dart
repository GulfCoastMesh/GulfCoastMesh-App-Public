import 'dart:typed_data';

import 'region_scope_codes.dart';

/// Parsed MeshCore channel invite (`meshcore://channel/add?...`).
class ChannelInvite {
  final String name;
  final String secretHex;
  final String? regionScope;

  const ChannelInvite({
    required this.name,
    required this.secretHex,
    this.regionScope,
  });

  Uint8List get secretBytes {
    final cleaned = secretHex.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (cleaned.length != 32) {
      throw const FormatException('PSK must be 32 hex characters');
    }
    final bytes = Uint8List(16);
    for (var i = 0; i < 16; i++) {
      final start = i * 2;
      bytes[i] = int.parse(cleaned.substring(start, start + 2), radix: 16);
    }
    return bytes;
  }
}

/// Build / parse official MeshCore channel QR URIs.
///
/// Format: `meshcore://channel/add?name=NAME&secret=HEX32[&region_scope=CODE]`
class ChannelInviteUri {
  static const String scheme = 'meshcore';
  static const String host = 'channel';
  static const String path = '/add';

  static String build({
    required String name,
    required String secretHex,
    String? regionScope,
  }) {
    final cleanedSecret = secretHex
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '')
        .toLowerCase();
    if (cleanedSecret.length != 32) {
      throw ArgumentError.value(
        secretHex,
        'secretHex',
        'must be 32 hex characters',
      );
    }

    final params = <String, String>{'name': name, 'secret': cleanedSecret};
    final scope = regionScope == null
        ? null
        : RegionScopeCodes.canonicalize(regionScope);
    if (scope != null && scope.isNotEmpty) {
      params['region_scope'] = scope;
    }

    return Uri(
      scheme: scheme,
      host: host,
      path: path,
      queryParameters: params,
    ).toString();
  }

  static ChannelInvite? tryParse(String raw) {
    try {
      return parse(raw);
    } catch (_) {
      return null;
    }
  }

  static ChannelInvite parse(String raw) {
    final trimmed = raw.trim();
    final uri = Uri.parse(trimmed);

    if (uri.scheme != scheme) {
      throw const FormatException('Not a meshcore:// URI');
    }

    // Accept meshcore://channel/add?... and meshcore:channel/add?...
    final isChannelAdd =
        (uri.host == host && (uri.path == path || uri.path == 'add')) ||
        (uri.host.isEmpty &&
            (uri.path == '$host$path' || uri.path == '$host/add'));
    if (!isChannelAdd) {
      throw const FormatException('Not a channel/add URI');
    }

    final name = uri.queryParameters['name']?.trim() ?? '';
    final secret = uri.queryParameters['secret']?.trim() ?? '';
    final regionScope = uri.queryParameters['region_scope']?.trim();

    if (name.isEmpty) {
      throw const FormatException('Missing channel name');
    }
    final cleanedSecret = secret.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (cleanedSecret.length != 32) {
      throw const FormatException('Invalid channel secret');
    }

    return ChannelInvite(
      name: name,
      secretHex: cleanedSecret.toLowerCase(),
      regionScope: (regionScope == null || regionScope.isEmpty)
          ? null
          : RegionScopeCodes.canonicalize(regionScope),
    );
  }

  static bool isChannelInvite(String raw) => tryParse(raw) != null;
}
