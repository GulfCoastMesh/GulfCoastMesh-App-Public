import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';

void main() {
  test('node blocking defaults to off', () {
    expect(AppSettings().experimentalNodeBlockingEnabled, isFalse);
    expect(AppSettings.fromJson({}).experimentalNodeBlockingEnabled, isFalse);
  });

  test('JSON round trip keeps the flag', () {
    final on = AppSettings(experimentalNodeBlockingEnabled: true);
    expect(on.toJson()['experimental_node_blocking_enabled'], isTrue);
    expect(
      AppSettings.fromJson(on.toJson()).experimentalNodeBlockingEnabled,
      isTrue,
    );
  });

  test('copyWith changes only the flag', () {
    final base = AppSettings(experimentalWeatherEnabled: true);
    final copy = base.copyWith(experimentalNodeBlockingEnabled: true);
    expect(copy.experimentalNodeBlockingEnabled, isTrue);
    expect(copy.experimentalWeatherEnabled, isTrue);
    expect(base.copyWith().experimentalNodeBlockingEnabled, isFalse);
  });

  test('a non-bool value falls back without discarding other settings', () {
    final settings = AppSettings.fromJson({
      'experimental_node_blocking_enabled': 'yes',
      'theme_mode': 'dark',
    });
    expect(settings.experimentalNodeBlockingEnabled, isFalse);
    expect(settings.themeMode, 'dark');
  });
}
