import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/admin/domain/admin_moderation_status.dart';

/// Localized wording and colour of a moderation status.
///
/// Beside the status set rather than in the screen that shows it, so the
/// moderation queue, its filter chips and the product tiles all name a status
/// the same way and paint it in the same colour.
extension AdminModerationStatusL10n on AdminModerationStatus {
  String label(AppLocalizations l10n) => switch (this) {
    AdminModerationStatus.pending => l10n.adminModerationPending,
    AdminModerationStatus.validated => l10n.adminModerationValidated,
    AdminModerationStatus.suspended => l10n.adminModerationSuspended,
    AdminModerationStatus.rejected => l10n.adminModerationRejected,
    AdminModerationStatus.archived => l10n.adminModerationArchived,
  };

  IconData get icon => switch (this) {
    AdminModerationStatus.pending => Icons.schedule_rounded,
    AdminModerationStatus.validated => Icons.check_circle_rounded,
    AdminModerationStatus.suspended => Icons.pause_circle_rounded,
    AdminModerationStatus.rejected => Icons.cancel_rounded,
    AdminModerationStatus.archived => Icons.inventory_2_rounded,
  };

  /// Palette colour of the status.
  ///
  /// Drawn from [AppColors] rather than the Material defaults so a moderation
  /// state reads the same in the Admin queue as everywhere else in the app;
  /// `Colors.orange` next to `AppColors.warning` is a visibly different hue.
  Color color() => switch (this) {
    AdminModerationStatus.pending => AppColors.warning,
    AdminModerationStatus.validated => AppColors.success,
    AdminModerationStatus.suspended => AppColors.accent,
    AdminModerationStatus.rejected => AppColors.danger,
    AdminModerationStatus.archived => AppColors.textPrimary,
  };
}
