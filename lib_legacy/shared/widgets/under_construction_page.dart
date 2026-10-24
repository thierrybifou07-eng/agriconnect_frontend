import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/localization/locale_x.dart';

/// Placeholder shown for sections that are not implemented yet.
class UnderConstructionPage extends StatelessWidget {
  const UnderConstructionPage({super.key, required this.section});

  final RoleSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(section.activeIcon, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                section.label(l10n),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.underConstructionTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.underConstructionBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Chip(
                avatar: Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                label: Text(l10n.comingSoonBadge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
