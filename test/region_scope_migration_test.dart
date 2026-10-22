import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/helpers/channel_invite_uri.dart';
import 'package:gulf_coast_mesh_app/helpers/region_scope_codes.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';
import 'package:gulf_coast_mesh_app/models/gulf_coast_region_tree.dart';
import 'package:gulf_coast_mesh_app/models/mesh_region.dart';
import 'package:gulf_coast_mesh_app/services/region_index_service.dart';
import 'package:gulf_coast_mesh_app/storage/channel_settings_store.dart';
import 'package:gulf_coast_mesh_app/storage/known_regions_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_meshcore_transport.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });
  tearDown(PrefsManager.reset);

  test(
    'scope choices and compatibility aliases agree with the docs policy',
    () async {
      final catalog = await RegionIndexService.load();
      final ids = catalog.regions.map((region) => region.id).toSet();
      for (final code in GulfCoastRegionTree.sendSelectableCodes) {
        expect(ids, contains(code), reason: code);
        expect(RegionScopeCodes.canonicalize(code), code);
      }
      final aliases = catalog.policy['aliases'] as Map;
      for (final alias in aliases.entries) {
        expect(RegionScopeCodes.canonicalize(alias.key as String), alias.value);
      }
      final areas = {
        for (final area in catalog.policy['areas'] as List) area['id']: area,
      };
      const presetAreas = {
        'PNS': 'us-pns',
        'LFT': 'us-la-lft',
        'MSY': 'us-la-msy',
        'GPT': 'us-ms-gpt',
      };
      for (final preset in MeshRegion.gulfCoastPresets) {
        final area = areas[presetAreas[preset.label]]!;
        expect(preset.code, area['meshmapper'] ?? area['id']);
      }
      expect(GulfCoastRegionTree.find('gc-la-msy-mm')!.code, 'us-la-msy');
      expect(
        GulfCoastRegionTree.simpleChildrenOf('gc-la').map((n) => n.code),
        contains('us-la-msy'),
      );
      expect(
        RegionScopeCodes.canonicalize(' My-Custom-Scope '),
        'My-Custom-Scope',
      );
    },
  );

  test('persisted legacy channel scopes migrate before use', () async {
    final prefs = PrefsManager.instance;
    final store = ChannelSettingsStore();
    var index = 0;
    for (final alias in RegionScopeCodes.aliases.entries) {
      final key = 'channel_region_scope_$index';
      await prefs.setString(key, alias.key);
      expect(await store.loadRegionScope(index), alias.value);
      expect(prefs.getString(key), alias.value);
      index++;
    }
    await store.saveRegionScope(index, 'gc-la-msy-mm');
    expect(await store.loadRegionScope(index), 'us-la-msy');
    await store.saveRegionScope(index, 'My-Custom-Scope');
    expect(await store.loadRegionScope(index), 'My-Custom-Scope');
    await store.saveRegionScope(index, null);
    expect(await store.loadRegionScope(index), isNull);
  });

  test(
    'known scopes migrate and deduplicate without losing custom scopes',
    () async {
      final prefs = PrefsManager.instance;
      await prefs.setString(
        'known_mesh_regions',
        jsonEncode([
          'gc-la-msy',
          'gc-la-msy-mm',
          'us-la-msy-mm',
          'us-la-msy',
          'us-cm',
          'us-cm-mm',
          'My-Custom-Scope',
        ]),
      );
      final store = KnownRegionsStore();
      final codes = await store.load();
      expect(codes.where((code) => code == 'us-la-msy'), hasLength(1));
      expect(
        codes,
        containsAll(['us-ms-gpt', 'us-ms-gpt-mm', 'My-Custom-Scope']),
      );
      expect(codes.any(RegionScopeCodes.aliases.containsKey), isFalse);
      expect(jsonDecode(prefs.getString('known_mesh_regions')!), codes);
      expect(await store.add('gc-la-msy-mm'), codes);
    },
  );

  test(
    'old invites resolve to current scopes and new invites advertise them',
    () {
      const secret = '0123456789abcdef0123456789abcdef';
      final invite = ChannelInviteUri.parse(
        'meshcore://channel/add?name=Local&secret=$secret&region_scope=gc-la-msy-mm',
      );
      expect(invite.regionScope, 'us-la-msy');
      final built = ChannelInviteUri.build(
        name: 'Local',
        secretHex: secret,
        regionScope: 'gc-la-msy',
      );
      expect(Uri.parse(built).queryParameters['region_scope'], 'us-la-msy');
    },
  );

  test(
    'repeater migration merges alias flags and replaces retired device names',
    () {
      final baseline = RepeaterRegionEntry.parseRegionTree(
        '* F\n  gc-la-msy-mm^ F\n  us-la-msy\n  My-Custom-Scope F',
      );
      final draft = RepeaterRegionEntry.migrateScopes(baseline);
      expect(baseline[1].name, 'gc-la-msy-mm');
      expect(draft, hasLength(3));
      final msy = draft.singleWhere((region) => region.name == 'us-la-msy');
      expect(msy.floodAllowed, isTrue);
      expect(msy.isHome, isTrue);
      expect(
        RepeaterRegionEntry.commandsToSyncDevice(
          baseline: baseline,
          draft: draft,
        ),
        [
          'region allowf us-la-msy',
          'region home us-la-msy',
          'region remove gc-la-msy-mm',
        ],
      );
      final isolated = RepeaterRegionEntry.applyIsolateToDraft(
        current: baseline,
        targetName: 'gc-la-msy',
        additionalCodes: ['us-la-msy-mm'],
      );
      expect(
        isolated.singleWhere((r) => r.name == 'us-la-msy').floodAllowed,
        isTrue,
      );
      expect(
        isolated
            .where((r) => r.name != 'us-la-msy' && !r.isWildcard)
            .every((r) => !r.floodAllowed),
        isTrue,
      );
    },
  );

  test(
    'connector sends canonical scope names and keys to the companion',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
            (call) async =>
                call.method == 'readAll' ? <String, String>{} : null,
          );
      final transport = FakeMeshCoreTransport(MeshCoreTransportKind.tcp);
      final connector = MeshCoreConnector(
        transportOverrides: {
          for (final kind in MeshCoreTransportKind.values)
            kind: kind == MeshCoreTransportKind.tcp
                ? transport
                : FakeMeshCoreTransport(kind),
        },
      );
      addTearDown(connector.dispose);
      await connector.connect(
        const MeshCoreDevice(
          id: 'test:5000',
          displayName: 'Test radio',
          transportKind: MeshCoreTransportKind.tcp,
        ),
      );
      transport.sentFrames.clear();
      expect(await connector.setDefaultFloodScope('gc-la-msy-mm'), isTrue);
      final defaultFrame = transport.sentFrames.singleWhere(
        (f) => f[0] == cmdSetDefaultFloodScope,
      );
      final defaultInfo = DefaultFloodScopeInfo.fromPayload(
        defaultFrame.sublist(1),
      )!;
      expect(defaultInfo.name, 'us-la-msy');
      expect(defaultInfo.key, MeshRegion.deriveFloodScopeKey('us-la-msy'));
      expect(connector.defaultFloodScopeName, 'us-la-msy');

      await connector.setChannelRegionScope(1, 'gc-la-msy');
      expect(connector.getChannelRegionScope(1), 'us-la-msy');
      await connector.loadChannelSettings(maxChannels: 2);
      expect(connector.getChannelRegionScope(1), 'us-la-msy');
      transport.sentFrames.clear();
      await connector.sendChannelMessage(
        Channel(index: 1, name: '#local', psk: Uint8List(16)),
        'test',
        addToLocalHistory: false,
      );
      final scopeFrame = transport.sentFrames.singleWhere(
        (f) => f[0] == cmdSetFloodScopeKey,
      );
      expect(
        scopeFrame,
        buildSetFloodScopeKeyFrame(MeshRegion.deriveFloodScopeKey('us-la-msy')),
      );
    },
  );
}
