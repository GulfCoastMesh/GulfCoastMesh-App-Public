import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/blocked_node_filter.dart';

import '../support/node_blocking_fixtures.dart';

void main() {
  final a = blockingTestContact('A', seed: 1);
  final b = blockingTestContact('B', seed: 2);

  test('nothing hidden keeps every contact', () {
    expect(withoutHiddenNodes([a, b], (_) => false), [a, b]);
  });

  test('only hidden keys are removed', () {
    final result = withoutHiddenNodes([a, b], (k) => k == b.publicKeyHex);
    expect(result, [a]);
  });

  group('nodeMarkerLongPress', () {
    test('switch OFF keeps the remove-marker dialog', () {
      expect(
        nodeMarkerLongPress(isBuildingPathTrace: false, blockingEnabled: false),
        NodeMarkerLongPress.removeMarker,
      );
    });

    test('switch ON opens the block confirmation', () {
      expect(
        nodeMarkerLongPress(isBuildingPathTrace: false, blockingEnabled: true),
        NodeMarkerLongPress.confirmBlock,
      );
    });

    test('long-press does nothing while building a path trace', () {
      for (final enabled in [true, false]) {
        expect(
          nodeMarkerLongPress(
            isBuildingPathTrace: true,
            blockingEnabled: enabled,
          ),
          NodeMarkerLongPress.none,
        );
      }
    });
  });
}
