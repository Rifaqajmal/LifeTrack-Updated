import 'package:flutter/material.dart';

/// Brand + accent palette from the LifeTrack v2 design board.
///
/// Colors that change between light and dark mode (backgrounds, surfaces,
/// text, borders) live in [LTColors] and are read with `context.lt`.
/// Everything here is constant across both themes.
class AppColors {
  AppColors._();

  // Violet brand system
  static const Color primary = Color(0xFF5533FF);
  static const Color primary2 = Color(0xFF7B5CF6);
  static const Color primaryDark = Color(0xFF3318DD);

  // Accents
  static const Color green = Color(0xFF22D07A);
  static const Color pink = Color(0xFFFF4F93);
  static const Color pinkSoft = Color(0xFFFF8FAB);
  static const Color amber = Color(0xFFFFB830);
  static const Color blue = Color(0xFF3B8BF5);
  static const Color red = Color(0xFFFF4444);

  // Gradients (CSS 155deg ≈ mostly downward, slightly to the right)
  static const Alignment _gradStart = Alignment(-0.45, -1);
  static const Alignment _gradEnd = Alignment(0.45, 1);

  /// Header gradient used on Home and Profile.
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: _gradStart,
    end: _gradEnd,
  );

  /// Full-screen gradient used on Login and Splash.
  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryDark, primary, primary2],
    stops: [0.0, 0.4, 1.0],
    begin: _gradStart,
    end: _gradEnd,
  );

  /// Primary buttons and the center tab-bar button.
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primary, primary2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Birthday detail header.
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [pink, pinkSoft],
    begin: _gradStart,
    end: _gradEnd,
  );
}

/// Theme-dependent colors (light / dark), registered on [ThemeData] as a
/// [ThemeExtension] so any widget can read them with `context.lt`.
@immutable
class LTColors extends ThemeExtension<LTColors> {
  const LTColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text,
    required this.text2,
    required this.text3,
    required this.primarySoft,
    required this.shadow,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color text;
  final Color text2;
  final Color text3;

  /// Soft violet tint (design token "Primary-3") for chips and badges.
  final Color primarySoft;

  /// Card shadow color.
  final Color shadow;

  static const LTColors light = LTColors(
    bg: Color(0xFFF2F0FA),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF7F5FF),
    border: Color(0xFFE8E5F5),
    text: Color(0xFF18172E),
    text2: Color(0xFF5F5D7E),
    text3: Color(0xFF9896B5),
    primarySoft: Color(0xFFEDE9FF),
    shadow: Color(0x1A5533FF),
  );

  static const LTColors dark = LTColors(
    bg: Color(0xFF0F0E1A),
    surface: Color(0xFF1A1828),
    surface2: Color(0xFF231F38),
    border: Color(0xFF2E2A45),
    text: Color(0xFFF0EEFF),
    text2: Color(0xFFA8A6C4),
    text3: Color(0xFF7C7A9C),
    primarySoft: Color(0xFF2B2358),
    shadow: Color(0x4D000000),
  );

  /// Soft tint of an accent color that works on the current surface.
  Color tint(Color accent) => accent.withValues(alpha: 0.14);

  @override
  LTColors copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? border,
    Color? text,
    Color? text2,
    Color? text3,
    Color? primarySoft,
    Color? shadow,
  }) {
    return LTColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      border: border ?? this.border,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      primarySoft: primarySoft ?? this.primarySoft,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  LTColors lerp(ThemeExtension<LTColors>? other, double t) {
    if (other is! LTColors) return this;
    return LTColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension LTThemeContext on BuildContext {
  /// Theme-dependent LifeTrack colors for the current brightness.
  LTColors get lt => Theme.of(this).extension<LTColors>() ?? LTColors.light;
}
