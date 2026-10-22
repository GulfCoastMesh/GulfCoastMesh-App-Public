/// Current scope names plus compatibility aliases for earlier app releases.
///
/// Keep the docs catalog's policy aliases intact: some `-mm` scopes still have
/// distinct MeshMapper keys, while the retired MSY scopes now use `us-la-msy`.
class RegionScopeCodes {
  RegionScopeCodes._();

  static const Map<String, String> aliases = {
    'gc': 'us-gc',
    'gc-la': 'us-la',
    'gc-ms': 'us-ms',
    'gc-la-msy': 'us-la-msy',
    'gc-la-lft': 'us-la-lft',
    'gc-la-lc': 'us-la-lc',
    'gc-fl-pns': 'us-pns',
    'us-cm': 'us-ms-gpt',
    'us-cm-mm': 'us-ms-gpt-mm',
    'gc-la-lc-mm': 'us-la-lc-mm',
    'us-msy': 'us-la-msy',
    'us-lft': 'us-la-lft',
    'us-lch': 'us-la-lc',
    'us-la-msy-mm': 'us-la-msy',
    'gc-la-msy-mm': 'us-la-msy',
    'us-la-lft-mm': 'gc-la-lft-mm',
    'us-gpt': 'us-ms-gpt',
  };

  /// Migrate only known aliases; custom scopes retain their exact spelling.
  static String canonicalize(String code) {
    final trimmed = code.trim();
    return aliases[trimmed.toLowerCase()] ?? trimmed;
  }
}
