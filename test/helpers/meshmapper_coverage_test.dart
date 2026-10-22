import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/meshmapper_coverage.dart';

const _knownTile =
    'GmUKCGNvdmVyYWdlEhkIKhIGAAABAQICGAMiCwkAABoUAAAUEwAPEhsIKxIGAAMBAQIEGAMiDQnIAZADGhQAABQTAA8aAWkaAWoaAnN0IgIwCSICMA4iAjACIgIwBiICMAwogCB4Ag==';

void main() {
  test('decodes MeshMapper server MVT cell fixture', () {
    final cells = decodeMeshMapperCoverageCells(base64Decode(_knownTile));
    expect(cells, hasLength(2));
    expect(cells.first.id, 42);
    expect(cells.first.latitudeIndex, -5);
    expect(cells.first.longitudeIndex, 7);
    expect(cells.first.status, 1);
    expect(cells.last.status, 6);
  });

  test('malformed tiles are ignored', () {
    expect(decodeMeshMapperCoverageCells(base64Decode('aGVsbG8=')), isEmpty);
  });
}
