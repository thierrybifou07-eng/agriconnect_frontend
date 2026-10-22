import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_order_status_badge.dart';

/// A single order row surfaced in the Administrator orders workspace.
///
/// Read-only: the order status transition workflow is not defined in the
/// contract yet, so the tile only reports the figures the model holds — the
/// order number, its status, the buyer and seller, the date and the amount.
class AdminOrderTile extends StatelessWidget {
  const AdminOrderTile({super.key, required this.order, this.onTap});

  final AdminOrder order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

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
                      order.orderNumber,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AdminOrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              _party(
                context,
                Icons.person_outline,
                '${l10n.adminOrderBuyerLabel} · ${order.buyerName}',
              ),
              const SizedBox(height: 2),
              _party(
                context,
                Icons.storefront_outlined,
                '${l10n.adminOrderSellerLabel} · ${order.sellerName}',
              ),
              const SizedBox(height: 6),
              Text(
                '${l10n.adminOrderPlacedAt} '
                '${AppFormats.date(order.placedAt, locale: context.localeCode)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      l10n.adminOrderArticlesCaption(order.itemCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // The amount is the figure that matters, but it still has to
                  // give way on a narrow phone and at a large text scale.
                  Flexible(
                    child: Text(
                      Money.format(
                        order.amount.round(),
                        locale: context.localeCode,
                      ),
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

  Widget _party(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
