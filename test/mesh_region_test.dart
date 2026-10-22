import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/models/mesh_region.dart';

void main() {
  group('MeshRegion.deriveFloodScopeKey', () {
    test('matches SHA256("#name").prefix(16)', () {
      const name = 'us-la-msy';
      final expected = Uint8List.fromList(
        crypto.sha256.convert(utf8.encode('#$name')).bytes.sublist(0, 16),
      );
      final key = MeshRegion.deriveFloodScopeKey(name);
      expect(key.length, 16);
      expect(key, expected);
      expect(MeshRegion.deriveFloodScopeKey('#$name'), key);
    });

    test('Gulf Coast codes are valid region names', () {
      for (final preset in MeshRegion.gulfCoastPresets) {
        expect(MeshRegion.isValidRegionName(preset.code), isTrue);
      }
    });
  });

  group('RepeaterRegionEntry.parseRegionTree', () {
    test('parses wildcard, home, allow and deny markers', () {
      const dump = '''
* F
  us-la-msy^ F
  gc-fl-pns-mm
  us-ms-gpt-mm F
''';
      final entries = RepeaterRegionEntry.parseRegionTree(dump);
      expect(entries.length, 4);
      expect(entries[0].name, '*');
      expect(entries[0].floodAllowed, isTrue);
      expect(entries[0].isHome, isFalse);
      expect(entries[0].isWildcard, isTrue);

      expect(entries[1].name, 'us-la-msy');
      expect(entries[1].isHome, isTrue);
      expect(entries[1].floodAllowed, isTrue);

      expect(entries[2].name, 'gc-fl-pns-mm');
      expect(entries[2].floodAllowed, isFalse);
      expect(entries[2].isHome, isFalse);

      expect(entries[3].name, 'us-ms-gpt-mm');
      expect(entries[3].floodAllowed, isTrue);
    });

    test('strips CLI prompt prefix', () {
      final entries = RepeaterRegionEntry.parseRegionTree('> * F\n  a^');
      expect(entries.length, 2);
      expect(entries[0].name, '*');
      expect(entries[1].name, 'a');
      expect(entries[1].isHome, isTrue);
    });
  });

  group('RepeaterRegionEntry.regionNamesToBlockForIsolate', () {
    test('includes Gulf Coast presets and on-device regions except target', () {
      const regions = [
        RepeaterRegionEntry(name: '*', floodAllowed: true, isHome: false),
        RepeaterRegionEntry(
          name: 'us-la-msy',
          floodAllowed: true,
          isHome: true,
        ),
        RepeaterRegionEntry(
          name: 'gc-fl-pns-mm',
          floodAllowed: false,
          isHome: false,
        ),
        RepeaterRegionEntry(
          name: 'custom-region',
          floodAllowed: true,
          isHome: false,
        ),
      ];
      expect(
        RepeaterRegionEntry.regionNamesToBlockForIsolate(
          targetName: 'us-la-msy',
          onDevice: regions,
          additionalCodes: const [],
        ),
        ['custom-region', 'gc-fl-pns-mm', 'gc-la-lft-mm', 'us-ms-gpt-mm'],
      );
    });
  });

  group('RepeaterRegionEntry.commandsToSyncDevice', () {
    test('emits put, flood, home, and remove commands', () {
      const baseline = [
        RepeaterRegionEntry(name: '*', floodAllowed: true, isHome: false),
        RepeaterRegionEntry(
          name: 'gc-fl-pns-mm',
          floodAllowed: true,
          isHome: true,
        ),
        RepeaterRegionEntry(
          name: 'old-region',
          floodAllowed: false,
          isHome: false,
        ),
      ];
      const draft = [
        RepeaterRegionEntry(name: '*', floodAllowed: true, isHome: false),
        RepeaterRegionEntry(
          name: 'gc-fl-pns-mm',
          floodAllowed: false,
          isHome: false,
        ),
        RepeaterRegionEntry(
          name: 'us-la-msy',
          floodAllowed: true,
          isHome: true,
        ),
      ];
      expect(
        RepeaterRegionEntry.commandsToSyncDevice(
          baseline: baseline,
          draft: draft,
        ),
        [
          'region put us-la-msy',
          'region denyf gc-fl-pns-mm',
          'region allowf us-la-msy',
          'region home us-la-msy',
          'region remove old-region',
        ],
      );
    });
  });

  group('RepeaterRegionEntry.applyIsolateToDraft', () {
    test('adds presets and blocks flood except target', () {
      const current = [
        RepeaterRegionEntry(name: '*', floodAllowed: true, isHome: false),
      ];
      final draft = RepeaterRegionEntry.applyIsolateToDraft(
        current: current,
        targetName: 'us-la-msy',
        additionalCodes: const [],
      );
      final byName = {for (final r in draft) r.name: r.floodAllowed};
      expect(byName['us-la-msy'], isTrue);
      expect(byName['gc-fl-pns-mm'], isFalse);
      expect(byName['gc-la-lft-mm'], isFalse);
      expect(byName['us-ms-gpt-mm'], isFalse);
    });
  });

  group('RepeaterRegionEntry.isCliOk', () {
    test('accepts OK variants', () {
      expect(RepeaterRegionEntry.isCliOk('OK'), isTrue);
      expect(RepeaterRegionEntry.isCliOk('> OK'), isTrue);
      expect(RepeaterRegionEntry.isCliOk('OK - saved'), isTrue);
      expect(RepeaterRegionEntry.isCliOk('Err - no'), isFalse);
    });
  });

  group('default flood scope frames', () {
    test('clear is single-byte 0x3F', () {
      expect(
        buildSetDefaultFloodScopeFrame(name: '', scopeKey: Uint8List(16)),
        Uint8List.fromList([0x3F]),
      );
    });

    test('set is 1 + 31 + 16 bytes', () {
      final key = MeshRegion.deriveFloodScopeKey('us-la-msy');
      final frame = buildSetDefaultFloodScopeFrame(
        name: 'us-la-msy',
        scopeKey: key,
      );
      expect(frame.length, 1 + 31 + 16);
      expect(frame[0], 0x3F);
      final nameBytes = utf8.encode('us-la-msy');
      expect(frame.sublist(1, 1 + nameBytes.length), nameBytes);
      expect(frame[1 + 30], 0); // null terminator inside 31-byte field
      expect(frame.sublist(1 + 31), key);
    });

    test('get is single-byte 0x40', () {
      expect(buildGetDefaultFloodScopeFrame(), Uint8List.fromList([0x40]));
    });

    test('parses response payload', () {
      final key = MeshRegion.deriveFloodScopeKey('us-ms-gpt-mm');
      final payload = Uint8List(31 + 16);
      final nameBytes = utf8.encode('us-ms-gpt-mm');
      for (var i = 0; i < nameBytes.length; i++) {
        payload[i] = nameBytes[i];
      }
      for (var i = 0; i < 16; i++) {
        payload[31 + i] = key[i];
      }

      final info = DefaultFloodScopeInfo.fromPayload(payload);
      expect(info, isNotNull);
      expect(info!.name, 'us-ms-gpt-mm');
      expect(info.key, key);
      expect(DefaultFloodScopeInfo.fromPayload(Uint8List(0)), isNull);
    });
  });

  group('session flood scope key frames (0x36)', () {
    test('set is [0x36][0x00][key x16]', () {
      final key = MeshRegion.deriveFloodScopeKey('us-la');
      final frame = buildSetFloodScopeKeyFrame(key);
      expect(frame.length, 18);
      expect(frame[0], 0x36);
      expect(frame[1], 0x00);
      expect(frame.sublist(2), key);
    });

    test('clear is [0x36][0x00]', () {
      expect(buildClearFloodScopeKeyFrame(), Uint8List.fromList([0x36, 0x00]));
    });

    test('unscoped is [0x36][0x01]', () {
      expect(buildUnscopedFloodScopeFrame(), Uint8List.fromList([0x36, 0x01]));
    });
  });
}
