import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';

/// Green-tinted chip used by the catalog filter rows.
class CatalogFilterChip extends StatelessWidget {
  const CatalogFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      // The checkmark is replaced by the brand fill: the active filter is
      // obvious at a glance without spending horizontal room on it.
      showCheckmark: false,
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 16,
              color: selected ? colorScheme.onPrimary : colorScheme.primary,
            ),
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      side: BorderSide(
        color: selected
            ? colorScheme.primary
            : colorScheme.outlineVariant.withValues(alpha: 0.8),
      ),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}

/// Title of a filter row, marked by a short green bar.
class CatalogFilterLabel extends StatelessWidget {
  const CatalogFilterLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
