import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';

/// Minimum width (logical pixels) for automatic tablet-style layout.
const double kAdaptiveWideBreakpoint = 600;

bool useWideAdaptiveLayout(
  AppLayoutMode layoutMode,
  double width, {
  TargetPlatform? platform,
}) {
  switch (layoutMode) {
    case AppLayoutMode.tablet:
      return true;
    case AppLayoutMode.mobile:
      return false;
    case AppLayoutMode.auto:
      return _isDesktopPlatform(platform ?? defaultTargetPlatform) ||
          width >= kAdaptiveWideBreakpoint;
  }
}

bool _isDesktopPlatform(TargetPlatform platform) {
  return switch (platform) {
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => true,
    _ => false,
  };
}
