import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_delivery_status_badge.dart';

/// A single delivery row surfaced in the Administrator deliveries workspace.
///
/// Kept as a plain, focused widget so it can be reused inside admin detail
/// pages and the deliveries list without pulling in room-level navigation.
class AdminDeliveryTile extends StatelessWidget {
  const AdminDeliveryTile({super.key, required this.delivery, this.onTap});

  final AdminDelivery delivery;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final media = MediaQuery.sizeOf(context);
    final compact = media.width < 640;

    final schedule = delivery.startedAt ?? delivery.scheduledAt;

    final details = <Widget>[
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.logout_rounded, size: 20),
        title: Text(delivery.pickupLabel),
        subtitle: Text(
          '${l10n.driverScheduledLabel} · '
          '${_formatSchedule(schedule)}',
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.place_outlined, size: 20),
        title: Text(delivery.destinationLabel),
        subtitle: Text(
          '${l10n.driverTitle} ${delivery.driverName} · '
          '${_km(delivery.distanceKm)}',
        ),
      ),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      delivery.id,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  AdminDeliveryStatusBadge(status: delivery.status),
                ],
              ),
              const SizedBox(height: 6),
              if (!compact)
                ...details
              else
                _expandableDetails(context, details),
              const Divider(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.adminDeliveryBaseFee} · '
                      '${_money(context, delivery.baseFee)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // The total is the figure that matters, but it still has to
                  // give way: on a narrow phone, and more so at a large text
                  // scale, holding it rigid pushed the row off the screen.
                  Flexible(
                    child: Text(
                      '${l10n.adminDeliveryTotalFee} '
                      '${_money(context, delivery.totalFee)}',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expandableDetails(BuildContext context, List<Widget> details) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text(context.l10n.adminDeliveryTracking),
      children: details,
    );
  }

  String _formatSchedule(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} · $h:$m';
  }

  String _km(double km) => '${km.toStringAsFixed(1)} km';

  /// Fees are francs CFA like every other amount in the app.
  ///
  /// The tile used to print a naira sign and its own comma grouping, so the same
  /// delivery showed two currencies depending on which Admin screen it was read
  /// from.
  String _money(BuildContext context, double value) =>
      Money.format(value.round(), locale: context.localeCode);
}
