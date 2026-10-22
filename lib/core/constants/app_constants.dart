import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';

/// Version tag used to expose the app version in the UI.
abstract final class AppInfo {
  static const name = 'AgriConnect';
  static const version = '1.0.0';
}

/// Central place for sizing and spacing tokens.
abstract final class AppSizes {
  static const double pagePadding = 20;
  static const double cardRadius = 16;
  static const double fieldRadius = 14;
  static const double buttonHeight = 52;
  static const double avatarRadius = 24;

  /// Radius used by image-led cards and artwork.
  static const double imageRadius = 20;

  /// Radius of a small media tile, e.g. a photo thumbnail.
  static const double tileRadius = 12;
}

/// Reusable spacing scale. These multiples already drive the interface; naming
/// them keeps new screens from inventing their own gaps and drifting away from
/// the shared rhythm.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = AppSizes.pagePadding;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Layout breakpoints shared by the responsive grids, so a rule is stated once
/// instead of being re-guessed on every screen.
abstract final class AppBreakpoints {
  /// Below this available width, four shortcut tiles no longer fit on one row.
  static const double compactWidth = 360;

  /// Below this content width, dashboards stack their leading figure above the
  /// rest instead of laying the metrics out side by side.
  static const double narrowContent = 380;
}

/// Central place for elevation tokens.
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadowSoft,
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.shadowSoft,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

/// Central place for animation tokens.
abstract final class AppDurations {
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 600);
}

/// Central place for api configuration.
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.agriconnect.app',
  );
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// Supported UI languages.
abstract final class AppLanguage {
  static const String defaultCode = 'fr';
  static const List<String> supportedCodes = ['fr', 'en'];
}
