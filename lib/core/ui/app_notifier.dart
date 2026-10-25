import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';

abstract final class AppNotifier {
  static void success(String message) => _show(message);
  static void error(String message) => _show(message);
  static void info(String message) => _show(message);

  static String failureMessage(
    ApiFailure failure,
    AppLocalizations localizations,
  ) {
    if (failure.isUnauthorized) return localizations.errUnauthorized;
    if (failure.isProfileNotVerified) {
      return localizations.errProfileNotVerified;
    }
    if (failure.isStateConflict) return localizations.errStateConflict;
    if (failure.kind == ApiFailureKind.network) return localizations.errNetwork;
    if (failure.kind == ApiFailureKind.timeout) return localizations.errTimeout;
    if (failure.status != null && failure.status! >= 500) {
      return localizations.errServer;
    }
    return failure.message;
  }

  static void _show(String message) {
    Get.snackbar(
      'AgriConnect',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }
}
