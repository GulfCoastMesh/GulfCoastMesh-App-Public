import 'package:flutter/material.dart';

/// Brightness-varying semantic colors, exposed via `context.appColors`.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.outgoingBubble,
    required this.incomingBubble,
    required this.repeatMode,
    required this.connecting,
    required this.connected,
    required this.disconnected,
    required this.connectionReadyBg,
    required this.connectionConnectingBg,
    required this.connectionRepeatBg,
  });

  final Color outgoingBubble;
  final Color incomingBubble;
  final Color repeatMode;
  final Color connecting;
  final Color connected;
  final Color disconnected;
  final Color connectionReadyBg;
  final Color connectionConnectingBg;
  final Color connectionRepeatBg;

  static final light = AppColors(
    outgoingBubble: const Color(0xFF2979FF),
    incomingBubble: const Color(0xFFEEEEEE),
    repeatMode: const Color(0xFFFF9500),
    connecting: const Color(0xFF007AFF),
    connected: const Color(0xFF34C759),
    disconnected: const Color(0xFF8E8E93),
    connectionReadyBg: const Color(0xFF34C759).withValues(alpha: 0.15),
    connectionConnectingBg: const Color(0xFF007AFF).withValues(alpha: 0.15),
    connectionRepeatBg: const Color(0xFFFF9500).withValues(alpha: 0.15),
  );

  static final dark = AppColors(
    outgoingBubble: const Color(0xFF2979FF),
    incomingBubble: const Color(0xFF2C2C2E),
    repeatMode: const Color(0xFFFF9F0A),
    connecting: const Color(0xFF0A84FF),
    connected: const Color(0xFF30D158),
    disconnected: const Color(0xFF8E8E93),
    connectionReadyBg: const Color(0xFF30D158).withValues(alpha: 0.15),
    connectionConnectingBg: const Color(0xFF0A84FF).withValues(alpha: 0.15),
    connectionRepeatBg: const Color(0xFFFF9F0A).withValues(alpha: 0.15),
  );

  // Fixed semantic colors that don't vary with brightness.
  static const Color failedBubble = Color(0xCCFF3B30);
  static const Color contactChat = Colors.blue;
  static const Color contactRepeater = Colors.green;
  static const Color contactRoom = Colors.purple;
  static const Color contactSensor = Colors.orange;
  static const Color mapPinCoral = Color(0xFFFF6B6B);
  static const Color mapPinCyan = Color(0xFF00BCD4);
  static const Color mapPinOrange = Color(0xFFFF9800);
  static const Color signalExcellent = Color(0xFF34C759);
  static const Color signalGood = Color(0xFFFFCC00);
  static const Color signalWeak = Color(0xFFFF9500);
  static const Color signalNone = Color(0xFFFF3B30);

  static final _avatarPalette = const [
    Color(0xFFE57373),
    Color(0xFFF06292),
    Color(0xFFBA68C8),
    Color(0xFF9575CD),
    Color(0xFF7986CB),
    Color(0xFF64B5F6),
    Color(0xFF4FC3F7),
    Color(0xFF4DD0E1),
    Color(0xFF4DB6AC),
    Color(0xFF81C784),
    Color(0xFFAED581),
    Color(0xFFFFD54F),
    Color(0xFFFFB74D),
    Color(0xFFFF8A65),
    Color(0xFFA1887F),
    Color(0xFF90A4AE),
  ];

  static Color colorForName(String name) {
    final hash = name.hashCode;
    return _avatarPalette[hash.abs() % _avatarPalette.length];
  }

  static Color textColorForBackground(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  AppColors copyWith({
    Color? outgoingBubble,
    Color? incomingBubble,
    Color? repeatMode,
    Color? connecting,
    Color? connected,
    Color? disconnected,
    Color? connectionReadyBg,
    Color? connectionConnectingBg,
    Color? connectionRepeatBg,
  }) {
    return AppColors(
      outgoingBubble: outgoingBubble ?? this.outgoingBubble,
      incomingBubble: incomingBubble ?? this.incomingBubble,
      repeatMode: repeatMode ?? this.repeatMode,
      connecting: connecting ?? this.connecting,
      connected: connected ?? this.connected,
      disconnected: disconnected ?? this.disconnected,
      connectionReadyBg: connectionReadyBg ?? this.connectionReadyBg,
      connectionConnectingBg:
          connectionConnectingBg ?? this.connectionConnectingBg,
      connectionRepeatBg: connectionRepeatBg ?? this.connectionRepeatBg,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      outgoingBubble: Color.lerp(outgoingBubble, other.outgoingBubble, t)!,
      incomingBubble: Color.lerp(incomingBubble, other.incomingBubble, t)!,
      repeatMode: Color.lerp(repeatMode, other.repeatMode, t)!,
      connecting: Color.lerp(connecting, other.connecting, t)!,
      connected: Color.lerp(connected, other.connected, t)!,
      disconnected: Color.lerp(disconnected, other.disconnected, t)!,
      connectionReadyBg: Color.lerp(
        connectionReadyBg,
        other.connectionReadyBg,
        t,
      )!,
      connectionConnectingBg: Color.lerp(
        connectionConnectingBg,
        other.connectionConnectingBg,
        t,
      )!,
      connectionRepeatBg: Color.lerp(
        connectionRepeatBg,
        other.connectionRepeatBg,
        t,
      )!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
