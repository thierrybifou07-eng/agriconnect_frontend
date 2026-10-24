import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/super_admin/domain/staff_permission.dart';

/// Localized wording of a [StaffPermission].
///
/// Kept beside the permission catalogue rather than in the screens that show
/// it, so the rights sheet, the staff tiles and the analytics counters all
/// describe a right the same way.
extension StaffPermissionL10n on StaffPermission {
  String label(AppLocalizations l10n) => switch (this) {
    StaffPermission.moderateProducts =>
      l10n.superAdminPermissionModerateProducts,
    StaffPermission.manageUsers => l10n.superAdminPermissionManageUsers,
    StaffPermission.superviseDeliveries =>
      l10n.superAdminPermissionSuperviseDeliveries,
    StaffPermission.manageOrders => l10n.superAdminPermissionManageOrders,
    StaffPermission.viewAnalytics => l10n.superAdminPermissionViewAnalytics,
    StaffPermission.managePlatformSettings =>
      l10n.superAdminPermissionManageSettings,
  };

  String body(AppLocalizations l10n) => switch (this) {
    StaffPermission.moderateProducts =>
      l10n.superAdminPermissionModerateProductsBody,
    StaffPermission.manageUsers => l10n.superAdminPermissionManageUsersBody,
    StaffPermission.superviseDeliveries =>
      l10n.superAdminPermissionSuperviseDeliveriesBody,
    StaffPermission.manageOrders => l10n.superAdminPermissionManageOrdersBody,
    StaffPermission.viewAnalytics => l10n.superAdminPermissionViewAnalyticsBody,
    StaffPermission.managePlatformSettings =>
      l10n.superAdminPermissionManageSettingsBody,
  };

  IconData get icon => switch (this) {
    StaffPermission.moderateProducts => Icons.inventory_2_rounded,
    StaffPermission.manageUsers => Icons.people_alt_rounded,
    StaffPermission.superviseDeliveries => Icons.local_shipping_rounded,
    StaffPermission.manageOrders => Icons.receipt_long_rounded,
    StaffPermission.viewAnalytics => Icons.bar_chart_rounded,
    StaffPermission.managePlatformSettings => Icons.settings_rounded,
  };

  /// Localized title of the group this right belongs to.
  static String groupLabel(StaffPermissionGroup group, AppLocalizations l10n) =>
      switch (group) {
        StaffPermissionGroup.marketplace =>
          l10n.superAdminPermissionMarketplace,
        StaffPermissionGroup.people => l10n.superAdminPermissionPeople,
        StaffPermissionGroup.platform => l10n.superAdminPermissionPlatform,
      };
}
