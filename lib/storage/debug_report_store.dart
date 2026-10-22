import 'prefs_manager.dart';

class DebugReportRecord {
  final String code;
  final DateTime sentAt;

  const DebugReportRecord({required this.code, required this.sentAt});
}

/// Remembers the last few debug report reference codes so a user who closes
/// the result dialog without noting theirs down can still find it again.
class DebugReportStore {
  static const String _key = 'debug_report_recent_codes';
  static const int _maxEntries = 5;

  Future<void> addRecent(String code) async {
    final prefs = PrefsManager.instance;
    final entries = prefs.getStringList(_key) ?? [];
    entries.insert(0, '$code|${DateTime.now().millisecondsSinceEpoch}');
    await prefs.setStringList(_key, entries.take(_maxEntries).toList());
  }

  List<DebugReportRecord> loadRecent() {
    final entries = PrefsManager.instance.getStringList(_key) ?? [];
    final records = <DebugReportRecord>[];
    for (final entry in entries) {
      final parts = entry.split('|');
      if (parts.length != 2) continue;
      final ms = int.tryParse(parts[1]);
      if (ms == null) continue;
      records.add(
        DebugReportRecord(
          code: parts[0],
          sentAt: DateTime.fromMillisecondsSinceEpoch(ms),
        ),
      );
    }
    return records;
  }
}
