import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';
import 'package:agri_connect/features/admin/presentation/extensions/admin_status_l10n.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

/// Compact status badge used across the admin orders workspace.
///
/// Painted with the shared [StatusBadge] and the same palette as the dashboard
/// order distribution and the analytics page — [AdminOrderStatusL10n] — so one
/// order never reads in two colours depending on the screen it is opened from.
class AdminOrderStatusBadge extends StatelessWidget {
  const AdminOrderStatusBadge({super.key, required this.status});

  final AdminOrderStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: status.label(context.l10n),
      color: status.color(Theme.of(context).colorScheme),
      icon: status.icon,
    );
  }
}

extension _AdminOrderStatusIcon on AdminOrderStatus {
  IconData get icon => switch (this) {
    AdminOrderStatus.pending => Icons.schedule_rounded,
    AdminOrderStatus.confirmed => Icons.check_circle_outline_rounded,
    AdminOrderStatus.inTransit => Icons.local_shipping_rounded,
    AdminOrderStatus.delivered => Icons.check_circle_rounded,
    AdminOrderStatus.cancelled => Icons.cancel_rounded,
  };
}
