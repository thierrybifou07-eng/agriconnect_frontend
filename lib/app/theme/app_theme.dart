import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/app/theme/app_typography.dart';
import 'package:agri_connect/core/constants/app_constants.dart';

/// Central Material 3 theme of the application.
///
/// The light theme is the flagship look of AgriConnect: an off-white canvas,
/// white cards, dark-green headers and the brand green used for primary
/// actions and accents. The dark theme is kept only as a technical fallback
/// and is never enabled by default ([ThemeMode.light]).
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = brightness == Brightness.light
        ? _lightScheme
        : _darkScheme;
    final base = brightness == Brightness.light
        ? ThemeData.light()
        : ThemeData.dark();
    final textTheme = AppTypography.build(base.textTheme);

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? AppColors.background
          : colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceElevated,
        foregroundColor: AppColors.primaryDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.primaryDark,
        ),
        titleSpacing: 4,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 8,
        height: 80,
        backgroundColor: AppColors.surfaceElevated,
        indicatorColor: AppColors.primarySoft,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryDark
                : colorScheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            height: 1.3,
            letterSpacing: 0,
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryDark
                : colorScheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: AppColors.shadowSoft,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        color: AppColors.surfaceElevated,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          foregroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          ),
          side: const BorderSide(color: AppColors.primarySoftStrong),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primarySoft,
        side: BorderSide(color: AppColors.primarySoftStrong),
        labelStyle: base.chipTheme.labelStyle?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: base.chipTheme.labelStyle?.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
        checkmarkColor: AppColors.primaryDark,
      ),
      progressIndicatorTheme: base.progressIndicatorTheme.copyWith(
        color: colorScheme.primary,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static const ColorScheme _lightScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.primaryDeep,
    secondary: Color(0xFF558B2F),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE8F2E1),
    onSecondaryContainer: Color(0xFF1B5E20),
    tertiary: Color(0xFF33691E),
    onTertiary: Colors.white,
    error: AppColors.danger,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD9),
    onErrorContainer: Color(0xFF7A0000),
    surface: AppColors.surfaceElevated,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: Color(0xFFEDF3EA),
    onSurfaceVariant: Color(0xFF48574B),
    outline: Color(0xFF7A8B7E),
    outlineVariant: Color(0xFFDCE6DB),
    shadow: Color(0xFF2E7D32),
    scrim: Colors.black,
    inverseSurface: Color(0xFF1F2B21),
    onInverseSurface: Color(0xFFEDF3EA),
    inversePrimary: Color(0xFF9BD6A0),
  );

  static ColorScheme get _darkScheme => ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  );
}
