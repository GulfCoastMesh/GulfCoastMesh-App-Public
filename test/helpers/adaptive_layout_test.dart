import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/adaptive_layout.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';

void main() {
  group('useWideAdaptiveLayout', () {
    test('auto uses breakpoint on mobile platforms', () {
      expect(
        useWideAdaptiveLayout(
          AppLayoutMode.auto,
          kAdaptiveWideBreakpoint - 1,
          platform: TargetPlatform.android,
        ),
        isFalse,
      );
      expect(
        useWideAdaptiveLayout(
          AppLayoutMode.auto,
          kAdaptiveWideBreakpoint,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
    });

    test('auto always uses the tablet layout on desktop platforms', () {
      for (final platform in [
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.windows,
      ]) {
        expect(
          useWideAdaptiveLayout(
            AppLayoutMode.auto,
            kAdaptiveWideBreakpoint - 1,
            platform: platform,
          ),
          isTrue,
        );
      }
    });

    test('mobile and tablet override width', () {
      expect(useWideAdaptiveLayout(AppLayoutMode.mobile, 1200), isFalse);
      expect(useWideAdaptiveLayout(AppLayoutMode.tablet, 400), isTrue);
    });
  });

  group('AppSettings layoutMode', () {
    test('round-trips through json', () {
      final original = AppSettings(layoutMode: AppLayoutMode.tablet);
      final restored = AppSettings.fromJson(original.toJson());
      expect(restored.layoutMode, AppLayoutMode.tablet);
    });

    test('defaults to auto', () {
      expect(AppSettings.fromJson({}).layoutMode, AppLayoutMode.auto);
    });
  });
}
