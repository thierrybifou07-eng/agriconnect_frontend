import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/buyer/application/buyer_welcome_controller.dart';

/// Welcoming panel shown on the buyer dashboard the first time they enter.
///
/// It offers one clear action toward the existing buyer catalog and a plain
/// dismiss button; both mark the message as seen so it stops appearing.
class BuyerWelcomePanel extends ConsumerWidget {
  const BuyerWelcomePanel({super.key, required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seen = ref.watch(buyerWelcomeControllerProvider);
    if (seen) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      // Its own trailing gap: the panel disappears entirely once dismissed, so
      // a fixed spacer in the dashboard would leave a hole in the layout.
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Card(
        color: AppColors.primarySoft,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.buyerWelcomeTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.buyerWelcomeGreeting(firstName),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.buyerWelcomeBody,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(buyerWelcomeControllerProvider.notifier)
                      .markSeen();
                  if (context.mounted) {
                    context.go(RoutePaths.buyerCatalog);
                  }
                },
                icon: const Icon(Icons.storefront_rounded),
                label: Text(l10n.buyerWelcomePrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(buyerWelcomeControllerProvider.notifier)
                      .markSeen();
                },
                child: Text(l10n.buyerWelcomeDismiss),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
