/// Parse / validate MeshCore contact advert URIs.
///
/// A contact advert is `meshcore://<hex>` where `<hex>` is the signed advert
/// packet rendered as hex (98+ bytes => 196+ hex characters). This is the
/// payload written to the clipboard on export and encoded in contact QR codes.
class ContactAdvertUri {
  static const String prefix = 'meshcore://';

  static final RegExp _hexPattern = RegExp(r'^[0-9a-fA-F]+$');

  /// True iff [data] starts with `meshcore://` and the remainder is a
  /// non-empty, even-length hex string.
  static bool isContactAdvert(String data) => contactHexFromUri(data) != null;

  /// Returns the hex payload after `meshcore://`, or null if [data] is not a
  /// valid contact advert URI.
  static String? contactHexFromUri(String data) {
    final trimmed = data.trim();
    if (!trimmed.startsWith(prefix)) return null;
    final hex = trimmed.substring(prefix.length);
    if (hex.isEmpty || hex.length.isOdd) return null;
    if (!_hexPattern.hasMatch(hex)) return null;
    return hex;
  }
}
