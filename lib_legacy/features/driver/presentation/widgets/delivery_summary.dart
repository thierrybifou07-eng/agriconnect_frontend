import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/driver/application/driver_deliveries_controller.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/presentation/widgets/driver_content.dart';
import 'package:agri_connect/shared/widgets/primary_button.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

/// Order reference, schedule, customer, carried volume and status, laid over the
/// brand gradient.
///
/// The header answers in one glance what the sheet is about: which order, who
/// waits for it, and where it stands.
class DeliverySummaryHeader extends StatelessWidget {
  const DeliverySummaryHeader({super.key, required this.delivery});

  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
            AppColors.primaryDeep,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.orderNumber(delivery.orderId),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: delivery.status.label(l10n),
                color: badgeColor(delivery.status),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.driverScheduledLabel} '
            '${AppFormats.date(delivery.scheduledAt, locale: context.localeCode)}',
            maxLines: 2,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          // Two figures side by side rather than a column: on a 320 px screen
          // they shrink and wrap inside their own box instead of overflowing.
          // IntrinsicHeight gives them the same height, which a plain Row cannot
          // ask for while its own height is still unknown.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _HeaderStat(
                    icon: Icons.person_outline_rounded,
                    label: l10n.driverCustomerLabel,
                    value: delivery.customerName,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HeaderStat(
                    icon: Icons.inventory_2_outlined,
                    label: l10n.orderItemsLabel,
                    value: l10n.ordersArticlesCount(
                      delivery.items.length,
                      delivery.itemCount,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Badge tints chosen for the dark header: the status colors are built for
  /// light surfaces and would sink into the green gradient.
  static Color badgeColor(DriverDeliveryStatus status) => switch (status) {
    DriverDeliveryStatus.pickUp => AppColors.accentSoft,
    DriverDeliveryStatus.inTransit => AppColors.accentSoft,
    DriverDeliveryStatus.delivered => AppColors.successSoft,
  };
}

/// One figure of the summary header, on the gradient.
class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

/// Terminal state of a delivery whose progression is over.
class DeliveredNotice extends StatelessWidget {
  const DeliveredNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.task_alt_rounded,
            color: AppColors.primaryDeep,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.driverDeliveryDelivered,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status action of the sheet, pinned under the content.
class DeliveryActionBar extends ConsumerWidget {
  const DeliveryActionBar({
    super.key,
    required this.delivery,
    required this.isUpdating,
  });

  final DriverDelivery delivery;
  final bool isUpdating;

  /// Longest line the sheet may take on a desktop window: the same measure the
  /// content above this bar uses, so the button sits under what it acts on.
  static const double maxContentWidth = DriverContent.maxContentWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Only the transitions the progression holds: leave the pickup, then close
    // the delivery. A delivered parcel has no action at all, which is why the
    // page drops this bar for it.
    final isStart = delivery.status == DriverDeliveryStatus.pickUp;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePadding,
            12,
            AppSizes.pagePadding,
            12,
          ),
          // `Align` and not `Center`: as the bottom bar of a Scaffold this is
          // laid out with loose constraints, and a `Center` would stretch to
          // the whole height of the sheet and swallow the content above it.
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DeliveryActionBar.maxContentWidth,
              ),
              child: PrimaryButton(
                label: isUpdating
                    ? (isStart
                          ? l10n.driverStartingDelivery
                          : l10n.driverMarkingDelivered)
                    : (isStart
                          ? l10n.driverStartDelivery
                          : l10n.driverMarkDelivered),
                loading: isUpdating,
                // Disabled for the whole call, so a second tap can never send
                // the same transition twice.
                onPressed: isUpdating ? null : () => _advance(context, ref),
                icon: isUpdating
                    ? null
                    : (isStart
                          ? Icons.navigation_rounded
                          : Icons.check_circle_outline_rounded),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _advance(BuildContext context, WidgetRef ref) async {
    final next = delivery.nextStatus;
    if (next == null) return;
    final wasStart = delivery.status == DriverDeliveryStatus.pickUp;
    final l10n = context.l10n;

    final ok = await ref
        .read(driverDeliveriesControllerProvider.notifier)
        .updateStatus(delivery.id, next);
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasStart
                ? l10n.driverDeliveryStarted
                : l10n.driverDeliveryDelivered,
          ),
        ),
      );
    }
  }
}
