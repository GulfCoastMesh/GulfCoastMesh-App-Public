import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/meshmapper_wire_tag.dart';

void main() {
  const key = 'TESTKEY';
  final vectors = <(String, int), String>{
    ('PAR-20260611-0013', 1): 'MM:YVNPAr5OIw',
    ('AAR-20260611-0123', 1000): 'MM:yPPRVhdweg',
    ('PAE-20260621-0007', 18): 'MM:gCXS1s-0ew',
    ('ZZZ-20831231-9999', 2047): 'MM:lT-SF6aZAw',
  };

  for (final entry in vectors.entries) {
    test('${entry.key.$1}/${entry.key.$2} matches server vector', () {
      expect(
        MeshMapperWireTag.encode(entry.key.$1, entry.key.$2, key),
        entry.value,
      );
    });
  }

  test('rejects counters outside the wire format', () {
    expect(
      () => MeshMapperWireTag.encode('PAR-20260611-0013', 2048, key),
      throwsArgumentError,
    );
  });
}
