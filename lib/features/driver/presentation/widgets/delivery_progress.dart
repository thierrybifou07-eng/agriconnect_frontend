import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

/// Progression of a delivery from the pickup to the client.
///
/// The steps are the real [driverDeliverySteps], so the widget cannot drift from
/// the contract: a status added to the domain becomes a step only once it has
/// been placed in that list. Icons come from a switch rather than a lookup table,
/// so a status added without an icon fails to compile here instead of crashing
/// on a null at the first delivery that reaches it.
class DeliveryProgress extends StatelessWidget {
  const DeliveryProgress({super.key, required this.delivery});

  final DriverDelivery delivery;

  static IconData _iconFor(DriverDeliveryStatus status) => switch (status) {
    DriverDeliveryStatus.pickUp => Icons.inventory_2_outlined,
    DriverDeliveryStatus.inTransit => Icons.local_shipping_outlined,
    DriverDeliveryStatus.delivered => Icons.home_work_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final steps = driverDeliverySteps;
    final status = delivery.status;
    // A status outside [driverDeliverySteps] would leave the progression: it
    // shows its own badge and never claims a step it has not reached.
    final current = status.progressStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                current == null
                    ? status.label(l10n)
                    : l10n.trackingStepOf(current + 1, steps.length),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              label: status.label(l10n),
              color: status.color(context),
              icon: _iconFor(status),
            ),
          ],
        ),
        if (current != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (current + 1) / steps.length,
              minHeight: 6,
              color: status.color(context),
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
        const SizedBox(height: 18),
        for (var index = 0; index < steps.length; index++)
          _ProgressStep(
            label: steps[index].label(l10n),
            icon: _iconFor(steps[index]),
            isCompleted: current != null && index < current,
            isCurrent: current == index,
            isLast: index == steps.length - 1,
            reached: current != null,
            color: current != null && index <= current
                ? status.color(context)
                : colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.label,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    required this.reached,
    required this.color,
  });

  final String label;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final bool reached;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reached ? color : colorScheme.surfaceContainerHighest,
                  border: isCurrent ? Border.all(color: color, width: 4) : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : icon,
                  size: 14,
                  color: reached ? colorScheme.surface : colorScheme.outline,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        ? color
                        : colorScheme.surfaceContainerHighest,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: reached ? FontWeight.w700 : FontWeight.w500,
                      color: reached
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                  if (isCompleted)
                    Text(
                      l10n.trackingStepDone,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
