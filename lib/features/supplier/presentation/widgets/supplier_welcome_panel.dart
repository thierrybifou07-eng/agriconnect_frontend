import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/supplier/application/supplier_welcome_controller.dart';

/// Welcoming panel shown on the supplier dashboard the first time they enter.
class SupplierWelcomePanel extends ConsumerWidget {
  const SupplierWelcomePanel({super.key, required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seen = ref.watch(supplierWelcomeControllerProvider);
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
                l10n.supplierWelcomeTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.supplierWelcomeGreeting(firstName),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.supplierWelcomeBody,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(supplierWelcomeControllerProvider.notifier)
                      .markSeen();
                  if (context.mounted) {
                    await context.push(RoutePaths.supplierProductNew);
                  }
                },
                icon: const Icon(Icons.add_box_rounded),
                label: Text(l10n.supplierWelcomePrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(supplierWelcomeControllerProvider.notifier)
                      .markSeen();
                },
                child: Text(l10n.supplierWelcomeSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
