import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Transparent system bars with icon contrast picked for [brightness].
///
/// Android 15 (targetSdk 35+) draws every app edge-to-edge and ignores opaque
/// bar colours, so the bars are always transparent here and only the icon
/// brightness varies. `contrastEnforced: false` stops Android 10-14 from
/// painting its own translucent scrim over the navigation bar, which would
/// otherwise look different from 15+.
SystemUiOverlayStyle systemOverlayStyleFor(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    // iOS reads statusBarBrightness as the *background* brightness.
    statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: isDark
        ? Brightness.light
        : Brightness.dark,
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
  );
}

class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF2979FF);
  static const Color _onAccent = Colors.white;

  static ThemeData light() => _build(
    // ColorScheme.fromSeed doesn't use the seed color verbatim for
    // `primary` — its tonal-palette algorithm shifts it. Overriding
    // `primary`/`onPrimary` back to the exact seed keeps buttons, links,
    // etc. matching AppColors.outgoingBubble (which uses the same literal),
    // instead of drifting to a visibly different shade.
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.light,
        ).copyWith(
          primary: _seed,
          onPrimary: _onAccent,
          surface: const Color(0xFFF4F8FA),
          onSurface: const Color(0xFF0B1B26),
        ),
    appColors: AppColors.light,
  );

  static ThemeData dark() => _build(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ).copyWith(
          primary: _seed,
          onPrimary: _onAccent,
          surface: const Color(0xFF0A1420),
          surfaceContainerHighest: const Color(0xFF13212F),
          onSurface: const Color(0xFFDCE7ED),
        ),
    appColors: AppColors.dark,
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required AppColors appColors,
  }) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: 'Inter',
      extensions: [appColors],
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: systemOverlayStyleFor(colorScheme.brightness),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
