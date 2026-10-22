import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:gulf_coast_mesh_app/models/mesh_region.dart';
import 'package:gulf_coast_mesh_app/services/region_index_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Expected lists captured from the docs site's RegionCore.configure on
  // 2026-10-06, using the same bundled regions.json snapshot.
  test('matches website recommendation for Pensacola', () async {
    final catalog = await RegionIndexService.load();
    expect(catalog.repeaterCodesAt(const LatLng(30.4213, -87.2169)), [
      "gc-fl-pns-mm",
      "us",
      "us-east",
      "us-fl",
      "us-fl-nw",
      "us-gc",
      "us-pns",
      "us-south",
      "us-southeast",
    ]);
  });

  test('matches website recommendation for Baton Rouge', () async {
    final catalog = await RegionIndexService.load();
    expect(catalog.repeaterCodesAt(const LatLng(30.4515, -91.1871)), [
      "us",
      "us-east",
      "us-gc",
      "us-la",
      "us-la-msy",
      "us-south",
      "us-southeast",
    ]);
  });

  test('matches website recommendation for New Orleans', () async {
    final catalog = await RegionIndexService.load();
    expect(catalog.repeaterCodesAt(const LatLng(29.9511, -90.0715)), [
      "us",
      "us-east",
      "us-gc",
      "us-la",
      "us-la-msy",
      "us-south",
      "us-southeast",
    ]);
  });

  test('matches website recommendation for Lafayette', () async {
    final catalog = await RegionIndexService.load();
    expect(catalog.repeaterCodesAt(const LatLng(30.2241, -92.0198)), [
      "gc-la-lft-mm",
      "us",
      "us-east",
      "us-gc",
      "us-la",
      "us-la-lft",
      "us-south",
      "us-southeast",
    ]);
  });

  test('matches website recommendation for Lake Charles', () async {
    final catalog = await RegionIndexService.load();
    expect(catalog.repeaterCodesAt(const LatLng(30.2266, -93.2174)), [
      "us",
      "us-east",
      "us-gc",
      "us-la",
      "us-la-lc",
      "us-la-lc-mm",
      "us-south",
      "us-southeast",
    ]);
  });

  test('matches website recommendation for Gulfport', () async {
    final catalog = await RegionIndexService.load();
    expect(catalog.repeaterCodesAt(const LatLng(30.3674, -89.0928)), [
      "us",
      "us-gc",
      "us-ms",
      "us-ms-gpt",
      "us-ms-gpt-mm",
      "us-south",
      "us-southeast",
    ]);
  });

  test('matches website recommendation for Demopolis', () async {
    final catalog = await RegionIndexService.load();
    expect(catalog.repeaterCodesAt(const LatLng(32.5176, -87.8364)), [
      "us",
      "us-al",
      "us-al-dya",
      "us-south",
      "us-southeast",
    ]);
  });

  test('matches website recommendation for Ocean', () async {
    final catalog = await RegionIndexService.load();
    expect(catalog.repeaterCodesAt(const LatLng(0, 0)), []);
  });

  test('rejects invalid coordinates', () async {
    final catalog = await RegionIndexService.load();
    expect(
      () => catalog.repeaterCodesAt(const LatLng(91, 0)),
      throwsFormatException,
    );
    expect(
      () => catalog.repeaterCodesAt(const LatLng(0, double.nan)),
      throwsFormatException,
    );
  });

  test('stages location scopes while retaining home and custom flags', () {
    const current = [
      RepeaterRegionEntry(name: '*', floodAllowed: false, isHome: false),
      RepeaterRegionEntry(name: 'us-la-msy', floodAllowed: false, isHome: true),
      RepeaterRegionEntry(
        name: 'custom-region',
        floodAllowed: false,
        isHome: false,
      ),
    ];
    final draft = RepeaterRegionEntry.applyLocationToDraft(
      current: current,
      allowedCodes: ['us-la-msy', 'us-gc', 'us-la-msy'],
    );
    expect(draft, hasLength(4));
    expect(draft.singleWhere((r) => r.name == '*').floodAllowed, isTrue);
    expect(draft.singleWhere((r) => r.name == 'us-la-msy').isHome, isTrue);
    expect(
      draft.singleWhere((r) => r.name == 'custom-region').floodAllowed,
      isFalse,
    );
    expect(current.first.floodAllowed, isFalse);
    expect(
      RepeaterRegionEntry.commandsToSyncDevice(baseline: current, draft: draft),
      [
        'region put us-gc',
        'region allowf *',
        'region allowf us-la-msy',
        'region allowf us-gc',
      ],
    );
  });
}
