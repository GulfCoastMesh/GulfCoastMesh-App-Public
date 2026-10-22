import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';

void main() {
  test('does not restore or write retired media settings', () {
    final settings = AppSettings.fromJson({
      'image_max_dimension': 64,
      'image_compression': 10,
      'image_grayscale': false,
      'experimental_media_enabled': true,
    });

    final json = settings.toJson();
    expect(json.containsKey('image_max_dimension'), isFalse);
    expect(json.containsKey('image_compression'), isFalse);
    expect(json.containsKey('image_grayscale'), isFalse);
    expect(json.containsKey('experimental_media_enabled'), isFalse);
  });
}
