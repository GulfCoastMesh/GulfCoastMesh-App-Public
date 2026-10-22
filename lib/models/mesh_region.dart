import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

import '../helpers/region_scope_codes.dart';
import 'gulf_coast_region_tree.dart';

/// A known MeshCore flood-scope region (transport code name).
class MeshRegion {
  final String label;
  final String code;

  const MeshRegion({required this.label, required this.code});

  /// Repeater presets from the docs policy (MSY has no separate `-mm` scope).
  static const List<MeshRegion> gulfCoastPresets = [
    MeshRegion(label: 'PNS', code: 'gc-fl-pns-mm'),
    MeshRegion(label: 'LFT', code: 'gc-la-lft-mm'),
    MeshRegion(label: 'MSY', code: 'us-la-msy'),
    MeshRegion(label: 'GPT', code: 'us-ms-gpt-mm'),
  ];

  /// Operational companion send-scope codes (excludes `-mm`).
  static List<String> get gulfCoastSendScopeCodes =>
      GulfCoastRegionTree.sendSelectableCodes;

  /// Max UTF-8 bytes accepted by firmware for a default flood-scope name
  /// (`0 < strlen(name) < 31`).
  static const int maxScopeNameBytes = 30;

  /// Derive the 16-byte flood-scope key for a public region name.
  ///
  /// Matches firmware / MeshCore One: `SHA256("#" + name).prefix(16)`.
  static Uint8List deriveFloodScopeKey(String name) {
    final prefixed = name.startsWith('#') ? name : '#$name';
    final hash = crypto.sha256.convert(utf8.encode(prefixed)).bytes;
    return Uint8List.fromList(hash.sublist(0, 16));
  }

  /// Whether [name] is a valid public region code (ASCII letters/digits/`-`).
  static bool isValidRegionName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    if (utf8.encode(trimmed).length > maxScopeNameBytes) return false;
    return RegExp(r'^[A-Za-z0-9-]+$').hasMatch(trimmed);
  }

  /// Display label for a region code, preferring the Gulf Coast tree / presets.
  static String displayLabel(String code) {
    final node = GulfCoastRegionTree.find(code);
    if (node != null) return '${node.label} ($code)';
    for (final preset in gulfCoastPresets) {
      if (preset.code == code) return '${preset.label} ($code)';
    }
    return code;
  }
}

/// One entry from a repeater `region` CLI dump.
class RepeaterRegionEntry {
  final String name;
  final bool floodAllowed;
  final bool isHome;

  const RepeaterRegionEntry({
    required this.name,
    required this.floodAllowed,
    required this.isHome,
  });

  bool get isWildcard => name == '*';

  RepeaterRegionEntry copyWith({
    String? name,
    bool? floodAllowed,
    bool? isHome,
  }) {
    return RepeaterRegionEntry(
      name: name ?? this.name,
      floodAllowed: floodAllowed ?? this.floodAllowed,
      isHome: isHome ?? this.isHome,
    );
  }

  /// Parse a multi-line `region` dump.
  ///
  /// Lines look like:
  /// - `* F` (wildcard, flood allowed)
  /// - `  us-la-msy^ F` (home + flood allowed)
  /// - `  gc-fl-pns-mm` (denied / no flood flag)
  static List<RepeaterRegionEntry> parseRegionTree(String response) {
    var text = response.trim();
    if (text.startsWith('> ')) {
      text = text.substring(2);
    } else if (text == '>') {
      text = '';
    }

    final entries = <RepeaterRegionEntry>[];
    for (final rawLine in text.split('\n')) {
      var line = rawLine.replaceFirst(RegExp(r'^ +'), '');
      if (line.isEmpty) continue;

      // Strip an accidental CLI prompt on the first line.
      if (line.startsWith('> ')) {
        line = line.substring(2);
      }

      var floodAllowed = false;
      if (line.endsWith(' F')) {
        floodAllowed = true;
        line = line.substring(0, line.length - 2);
      }

      var isHome = false;
      if (line.endsWith('^')) {
        isHome = true;
        line = line.substring(0, line.length - 1);
      }

      if (line.isEmpty) continue;
      entries.add(
        RepeaterRegionEntry(
          name: line,
          floodAllowed: floodAllowed,
          isHome: isHome,
        ),
      );
    }
    return entries;
  }

  /// A migrated draft, leaving the baseline names intact for CLI removals.
  /// Aliases can converge on one scope; retain its flood and home flags.
  static List<RepeaterRegionEntry> migrateScopes(
    Iterable<RepeaterRegionEntry> entries,
  ) {
    final byName = <String, RepeaterRegionEntry>{};
    for (final entry in entries) {
      final name = RegionScopeCodes.canonicalize(entry.name);
      final existing = byName[name];
      byName[name] = entry.copyWith(
        name: name,
        floodAllowed: entry.floodAllowed || (existing?.floodAllowed ?? false),
        isHome: entry.isHome || (existing?.isHome ?? false),
      );
    }
    return byName.values.toList();
  }

  /// All region names that should exist and be flood-denied when isolating
  /// [targetName] (Gulf Coast presets, known codes, and repeater config).
  static List<String> regionNamesToBlockForIsolate({
    required String targetName,
    required Iterable<RepeaterRegionEntry> onDevice,
    required Iterable<String> additionalCodes,
  }) {
    final seen = <String>{};
    final result = <String>[];

    void consider(String raw) {
      final name = RegionScopeCodes.canonicalize(raw);
      if (name.isEmpty ||
          name == RegionScopeCodes.canonicalize(targetName) ||
          name == '*') {
        return;
      }
      if (seen.add(name)) result.add(name);
    }

    for (final preset in MeshRegion.gulfCoastPresets) {
      consider(preset.code);
    }
    for (final code in additionalCodes) {
      consider(code);
    }
    for (final region in onDevice) {
      consider(region.name);
    }

    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }

  /// Whether two region lists describe the same repeater config (order ignored).
  static bool regionsEqual(
    List<RepeaterRegionEntry> a,
    List<RepeaterRegionEntry> b,
  ) {
    if (a.length != b.length) return false;
    final byName = {for (final r in b) r.name: r};
    for (final entry in a) {
      final other = byName[entry.name];
      if (other == null) return false;
      if (entry.floodAllowed != other.floodAllowed ||
          entry.isHome != other.isHome) {
        return false;
      }
    }
    return true;
  }

  /// CLI commands to move the repeater from [baseline] to [draft].
  static List<String> commandsToSyncDevice({
    required List<RepeaterRegionEntry> baseline,
    required List<RepeaterRegionEntry> draft,
  }) {
    final baselineByName = {for (final r in baseline) r.name: r};
    final migratedDraft = migrateScopes(draft);
    final draftByName = {for (final r in migratedDraft) r.name: r};
    final commands = <String>[];

    for (final name in draftByName.keys) {
      if (name == '*' || baselineByName.containsKey(name)) continue;
      commands.add('region put $name');
    }

    for (final entry in migratedDraft) {
      final prev = baselineByName[entry.name];
      if (prev == null) {
        if (entry.floodAllowed) {
          commands.add('region allowf ${entry.name}');
        }
      } else if (prev.floodAllowed != entry.floodAllowed) {
        commands.add(
          entry.floodAllowed
              ? 'region allowf ${entry.name}'
              : 'region denyf ${entry.name}',
        );
      }
    }

    String? baselineHome;
    String? draftHome;
    for (final r in baseline) {
      if (r.isHome) baselineHome = r.name;
    }
    for (final r in migratedDraft) {
      if (r.isHome) draftHome = r.name;
    }
    if (draftHome != null && draftHome != baselineHome) {
      commands.add('region home $draftHome');
    }

    for (final name in baselineByName.keys) {
      if (name == '*' || draftByName.containsKey(name)) continue;
      commands.add('region remove $name');
    }

    return commands;
  }

  /// Local draft: allow flood for [targetName], add/deny peers for isolate.
  static List<RepeaterRegionEntry> applyIsolateToDraft({
    required List<RepeaterRegionEntry> current,
    required String targetName,
    required Iterable<String> additionalCodes,
  }) {
    final draft = migrateScopes(current);
    targetName = RegionScopeCodes.canonicalize(targetName);

    void setFlood(String name, bool floodAllowed) {
      final index = draft.indexWhere((r) => r.name == name);
      if (index >= 0) {
        draft[index] = draft[index].copyWith(floodAllowed: floodAllowed);
      } else {
        draft.add(
          RepeaterRegionEntry(
            name: name,
            floodAllowed: floodAllowed,
            isHome: false,
          ),
        );
      }
    }

    setFlood(targetName, true);

    final toBlock = regionNamesToBlockForIsolate(
      targetName: targetName,
      onDevice: draft,
      additionalCodes: additionalCodes,
    );
    for (final name in toBlock) {
      setFlood(name, false);
    }

    return draft;
  }

  /// Local draft: add [targetName] and allow flood without changing others.
  static List<RepeaterRegionEntry> applyAddOnlyToDraft({
    required List<RepeaterRegionEntry> current,
    required String targetName,
  }) {
    final draft = migrateScopes(current);
    targetName = RegionScopeCodes.canonicalize(targetName);
    final index = draft.indexWhere((r) => r.name == targetName);
    if (index >= 0) {
      draft[index] = draft[index].copyWith(floodAllowed: true);
    } else {
      draft.add(
        RepeaterRegionEntry(
          name: targetName,
          floodAllowed: true,
          isHome: false,
        ),
      );
    }
    return draft;
  }

  /// Stage the website's location recommendation. `region def` adds/allows
  /// these scopes and leaves other entries alone; unscoped traffic stays allowed.
  static List<RepeaterRegionEntry> applyLocationToDraft({
    required List<RepeaterRegionEntry> current,
    required Iterable<String> allowedCodes,
  }) {
    var draft = migrateScopes(current);
    for (final code in ['*', ...allowedCodes]) {
      draft = applyAddOnlyToDraft(current: draft, targetName: code);
    }
    return draft;
  }

  /// True when a CLI reply indicates success (`OK` / `OK - ...`).
  static bool isCliOk(String response) {
    var text = response.trim();
    if (text.startsWith('> ')) {
      text = text.substring(2).trim();
    }
    return text == 'OK' || text.startsWith('OK - ');
  }
}
