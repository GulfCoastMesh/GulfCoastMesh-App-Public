/// Parsers for repeater CLI replies used by the OTA update wizard.
library;

/// Parsed `ver` reply, e.g. `v1.16.0-07a3ca9 (Build: Apr 1 2026)`.
class OtaVersionInfo {
  final String version; // e.g. 'v1.16.0'
  final String raw;

  const OtaVersionInfo({required this.version, required this.raw});
}

OtaVersionInfo? parseVerReply(String reply) {
  final match = RegExp(r'v(\d+)\.(\d+)\.(\d+)').firstMatch(reply);
  if (match == null) return null;
  return OtaVersionInfo(version: match.group(0)!, raw: reply.trim());
}

/// Compares two `vX.Y.Z` strings. Returns negative when [a] is older than [b].
int compareVersions(String a, String b) {
  List<int> parse(String v) {
    final m = RegExp(r'v?(\d+)\.(\d+)\.(\d+)').firstMatch(v);
    if (m == null) return [0, 0, 0];
    return [
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    ];
  }

  final pa = parse(a);
  final pb = parse(b);
  for (var i = 0; i < 3; i++) {
    if (pa[i] != pb[i]) return pa[i] - pb[i];
  }
  return 0;
}

/// Parsed `start ota` reply.
///
/// ESP32 firmware replies `Started: http://192.168.4.1/update`.
/// nRF52 firmware replies `OK - mac: XX:XX:XX:XX:XX:XX`.
class StartOtaResult {
  final Uri? updateUrl; // ESP32 web OTA endpoint
  final String? dfuMac; // nRF52 DFU target MAC
  final String raw;

  const StartOtaResult({this.updateUrl, this.dfuMac, required this.raw});

  bool get isEsp32 => updateUrl != null;
  bool get isNrf => dfuMac != null;
}

StartOtaResult? parseStartOtaReply(String reply) {
  final urlMatch = RegExp(r'(https?://[^\s]+)').firstMatch(reply);
  if (urlMatch != null) {
    final url = Uri.tryParse(urlMatch.group(1)!);
    if (url != null) return StartOtaResult(updateUrl: url, raw: reply.trim());
  }
  final macMatch = RegExp(
    r'\b([0-9A-Fa-f]{2}(?::[0-9A-Fa-f]{2}){5})\b',
  ).firstMatch(reply);
  if (macMatch != null) {
    return StartOtaResult(
      dfuMac: macMatch.group(1)!.toUpperCase(),
      raw: reply.trim(),
    );
  }
  return null;
}

/// Whether a `get bootloader.ver` reply indicates the OTAFIX bootloader.
/// Reply format is `> <version>`; OTAFIX builds include 'OTAFIX' in the string.
bool bootloaderHasOtaFix(String reply) {
  return reply.toUpperCase().contains('OTAFIX');
}
