import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';

/// Localized label and colour of an admin order status.
///
/// Beside the status set rather than in the screen that draws it, so the
/// dashboard distribution, the recent-order rows and the analytics page all
/// name a status the same way and paint it in the same colour.
extension AdminOrderStatusL10n on AdminOrderStatus {
  String label(AppLocalizations l10n) => switch (this) {
    AdminOrderStatus.pending => l10n.statusOrderPending,
    AdminOrderStatus.confirmed => l10n.statusOrderConfirmed,
    AdminOrderStatus.inTransit => l10n.statusOrderInTransit,
    AdminOrderStatus.delivered => l10n.statusOrderDelivered,
    AdminOrderStatus.cancelled => l10n.statusOrderCancelled,
  };

  Color color(ColorScheme scheme) => switch (this) {
    AdminOrderStatus.pending => scheme.tertiary,
    AdminOrderStatus.confirmed => scheme.primary,
    AdminOrderStatus.inTransit => AppColors.accent,
    AdminOrderStatus.delivered => AppColors.success,
    AdminOrderStatus.cancelled => scheme.error,
  };
}

/// Localized label, colour and icon of an admin delivery status.
extension AdminDeliveryStatusL10n on AdminDeliveryStatus {
  String label(AppLocalizations l10n) => switch (this) {
    AdminDeliveryStatus.pickUp => l10n.adminStatusPickUp,
    AdminDeliveryStatus.inTransit => l10n.adminStatusInTransit,
    AdminDeliveryStatus.delivered => l10n.adminStatusDelivered,
    AdminDeliveryStatus.cancelled => l10n.adminStatusCancelled,
  };

  Color color(ColorScheme scheme) => switch (this) {
    AdminDeliveryStatus.pickUp => scheme.tertiary,
    AdminDeliveryStatus.inTransit => AppColors.accent,
    AdminDeliveryStatus.delivered => AppColors.success,
    AdminDeliveryStatus.cancelled => scheme.error,
  };

  IconData get icon => switch (this) {
    AdminDeliveryStatus.pickUp => Icons.flag_rounded,
    AdminDeliveryStatus.inTransit => Icons.local_shipping_rounded,
    AdminDeliveryStatus.delivered => Icons.check_circle_rounded,
    AdminDeliveryStatus.cancelled => Icons.cancel_rounded,
  };
}
