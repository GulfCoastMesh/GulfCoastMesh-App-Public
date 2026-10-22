import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:gulf_coast_mesh_app/helpers/channel_invite_uri.dart';
import 'package:gulf_coast_mesh_app/models/gulf_coast_region_tree.dart';

void main() {
  group('ChannelInviteUri', () {
    test('builds official meshcore channel/add URI with region_scope', () {
      final uri = ChannelInviteUri.build(
        name: 'Public',
        secretHex: '8b3387e9c5cdea6ac9e5edbaa115cd72',
        regionScope: 'us-la-msy',
      );
      expect(
        uri,
        'meshcore://channel/add?name=Public&secret=8b3387e9c5cdea6ac9e5edbaa115cd72&region_scope=us-la-msy',
      );
    });

    test('omits region_scope when null or empty', () {
      final uri = ChannelInviteUri.build(
        name: '#emergency',
        secretHex: 'aabbccddeeff00112233445566778899',
      );
      expect(uri.contains('region_scope'), isFalse);
      expect(
        uri.contains('name=%23emergency') || uri.contains('name=#emergency'),
        isTrue,
      );
    });

    test('round-trips name, secret, and region_scope', () {
      final built = ChannelInviteUri.build(
        name: 'Team Private',
        secretHex: 'AABBCCDDEEFF00112233445566778899',
        regionScope: 'us-ms',
      );
      final invite = ChannelInviteUri.parse(built);
      expect(invite.name, 'Team Private');
      expect(invite.secretHex, 'aabbccddeeff00112233445566778899');
      expect(invite.regionScope, 'us-ms');
      expect(invite.secretBytes.length, 16);
    });

    test('parses URL-encoded names', () {
      final invite = ChannelInviteUri.parse(
        'meshcore://channel/add?name=%23weather&secret=0123456789abcdef0123456789abcdef&region_scope=us-ms-gpt',
      );
      expect(invite.name, '#weather');
      expect(invite.regionScope, 'us-ms-gpt');
    });

    test('tryParse returns null for contact URIs', () {
      expect(
        ChannelInviteUri.tryParse(
          'meshcore://contact/add?name=x&public_key=${'ab' * 32}&type=1',
        ),
        isNull,
      );
    });
  });

  group('GulfCoastRegionTree', () {
    test('simplePicker excludes us and us-southeast', () {
      final simpleCodes = GulfCoastRegionTree.simplePickerNodes
          .map((n) => n.code)
          .toSet();
      expect(simpleCodes, isNot(contains('us')));
      expect(simpleCodes, isNot(contains('us-southeast')));
      expect(simpleCodes, contains('us-gc'));
      expect(simpleCodes, contains('us-la-msy'));
    });

    test('simpleVisibleAt root includes us-gc and its children', () {
      final codes = GulfCoastRegionTree.simpleVisibleAt(
        GulfCoastRegionTree.simpleRootCode,
      ).map((n) => n.code).toList();
      expect(codes.first, 'us-gc');
      expect(codes, containsAll(['us-la', 'us-ms', 'us-ms-gpt', 'us-pns']));
      expect(codes, isNot(contains('us-la-msy')));
    });

    test('organic outlines are closed polygons with 3+ points', () {
      for (final node in GulfCoastRegionTree.simplePickerNodes) {
        expect(node.hasOutline, isTrue, reason: node.code);
        expect(node.outline.length, greaterThanOrEqualTo(3), reason: node.code);
      }
    });

    test('containsPoint hits interior of us-la-msy', () {
      final msy = GulfCoastRegionTree.find('us-la-msy')!;
      // Rough center of New Orleans area inside the outline.
      expect(
        GulfCoastRegionTree.containsPoint(msy, const LatLng(30.0, -90.3)),
        isTrue,
      );
      expect(
        GulfCoastRegionTree.containsPoint(msy, const LatLng(40.0, -90.0)),
        isFalse,
      );
    });

    test('sendSelectable excludes -mm MeshMapper codes', () {
      final codes = GulfCoastRegionTree.sendSelectableCodes;
      expect(codes, contains('us'));
      expect(codes, contains('us-gc'));
      expect(codes, isNot(contains('gc-la-msy-mm')));
    });

    test('ancestry walks parent chain', () {
      final path = GulfCoastRegionTree.ancestry('us-la-msy');
      expect(path.map((n) => n.code).toList(), [
        'us',
        'us-southeast',
        'us-gc',
        'us-la',
        'us-la-msy',
      ]);
    });

    test('simpleBreadcrumb skips us levels', () {
      expect(
        GulfCoastRegionTree.simpleBreadcrumb('us-la-lft'),
        'us-gc > us-la > us-la-lft',
      );
    });
  });
}
