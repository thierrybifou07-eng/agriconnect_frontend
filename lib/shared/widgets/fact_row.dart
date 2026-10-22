import 'package:flutter/material.dart';

/// One labelled fact of a card: an icon, the name of the fact above its value.
///
/// The value is laid out last and takes the room the row has left, so a long
/// address or note wraps under its own label instead of pushing the row past
/// its edges, at any text scale.
///
/// Shared by the order detail and its confirmation: both answer "where does it
/// go, who is called, what was written" with the same block, and a buyer
/// reading one and the other must not have to learn the layout twice.
class FactRow extends StatelessWidget {
  const FactRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Emphasises the value, for the one fact a buyer has to act on.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor,
                  fontWeight: valueColor != null ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
