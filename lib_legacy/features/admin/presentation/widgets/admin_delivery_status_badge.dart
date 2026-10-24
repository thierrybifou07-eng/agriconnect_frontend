import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/presentation/extensions/admin_status_l10n.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

/// Compact status badge used across the admin deliveries workspace.
///
/// Painted with the shared [StatusBadge] and the same palette as the dashboard
/// distribution legend — [AdminDeliveryStatusL10n] — so one delivery never reads
/// in two colours depending on the screen it is opened from. A plain badge, not
/// a Material [Chip]: the row it sits in is read-only and does not need a 48dp
/// tap target.
class AdminDeliveryStatusBadge extends StatelessWidget {
  const AdminDeliveryStatusBadge({super.key, required this.status});

  final AdminDeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: status.label(context.l10n),
      color: status.color(Theme.of(context).colorScheme),
      icon: status.icon,
    );
  }
}
