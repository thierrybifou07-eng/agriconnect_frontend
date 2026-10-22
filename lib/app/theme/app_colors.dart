import 'package:flutter/material.dart';

/// Brand palette of AgriConnect.
abstract final class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryDeep = Color(0xFF123018);

  /// Soft light-green tint used for chips, indicators and accents.
  static const Color primarySoft = Color(0xFFDCEBDD);
  static const Color primarySoftStrong = Color(0xFFC6E1C8);

  /// Dark green-muted text colour used across the light interface.
  static const Color textPrimary = Color(0xFF1B2A1C);

  static const Color accent = Color(0xFFFFB300);
  static const Color accentSoft = Color(0xFFFFE082);

  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFF9A825);
  static const Color danger = Color(0xFFE53935);

  /// Soft green tint used behind success text, so a confirmed amount reads
  /// positive without shouting louder than the value it sits under.
  static const Color successSoft = Color(0xFFA5D6A7);

  /// Matching tint behind danger text, for the same reason.
  static const Color dangerSoft = Color(0xFFFFCDD2);

  /// Secondary accents that tell statistical categories apart. They are kept
  /// deliberately clear of [danger]: a category is neutral information, never
  /// an alert, so the reserved red never competes with a data hue.
  static const Color info = Color(0xFF1565C0);
  static const Color warm = Color(0xFFEF6C00);
  static const Color violet = Color(0xFF6A1B9A);

  /// Soft tints behind the secondary accents, for chips and chart legends.
  static const Color infoSoft = Color(0xFFBBDEFB);
  static const Color warmSoft = Color(0xFFFFE0B2);
  static const Color violetSoft = Color(0xFFE1BEE7);

  /// Muted slate used for inactive or draft states. A draft is neither an
  /// alert nor a success, so it must not borrow [danger], [warning] or
  /// [success].
  static const Color neutral = Color(0xFF607D8B);

  /// Ordered secondary tones for category-based cards and charts: the brand
  /// green leads, then blue, orange and violet. Callers index into this list
  /// rather than inventing their own hues, so a category reads the same
  /// wherever it appears.
  static const List<Color> categoryTones = [primary, info, warm, violet];

  /// Dark scrim laid over a hero photo so white text stays readable on it.
  static const Color imageScrim = Color(0xE6123018);

  /// Soft off-white used as the light theme scaffold background.
  static const Color background = Color(0xFFF7FAF5);

  /// Elevated surface used for cards and raised elements.
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  /// Soft shadow used to lift cards and surfaces.
  static const Color shadowSoft = Color(0x142E7D32);
  static const Color shadowHeavy = Color(0x402E7D32);

  /// Wider green glow behind a floating brand element.
  static const Color shadowGlow = Color(0x332E7D32);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDeep],
  );

  /// Warm sunny gradient used for hero banners and highlights.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent, Color(0xFFFF8F00)],
  );
}
