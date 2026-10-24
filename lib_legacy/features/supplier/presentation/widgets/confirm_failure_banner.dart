import 'package:flutter/material.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';

/// Failure of a manual order confirmation, shown until the supplier acts on it.
///
/// The banner is never dismissed automatically: a confirmation that failed
/// must be verified or retried by hand, otherwise the order silently drifts
/// between "pending" and "confirmed". Both callbacks are nullable so the two
/// buttons can be disabled while their own request is in flight.
class ConfirmFailureBanner extends StatelessWidget {
  const ConfirmFailureBanner({super.key, this.onVerify, this.onRetry});

  /// Reloads the order list, to check the real state of the order.
  final VoidCallback? onVerify;

  /// Sends the confirmation again, for the order that failed.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.confirmOrderError,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.confirmOrderHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onVerify,
                    icon: const Icon(Icons.verified_user_outlined, size: 18),
                    label: Text(l10n.verifyStatus),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n.retry),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
