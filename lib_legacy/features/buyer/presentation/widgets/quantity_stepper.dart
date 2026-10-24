import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';

/// Compact quantity stepper with decrement, value and increment actions.
///
/// The two actions carry the same tooltip everywhere they appear, so a screen
/// reader announces "augmenter la quantité" rather than a bare plus sign.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.min = 1,
    this.max,
  });

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int min;
  final int? max;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canDecrement = value > min;
    final canIncrement = max == null || value < max!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: canDecrement ? onDecrement : null,
          tooltip: l10n.quantityDecrease,
          icon: const Icon(Icons.remove_rounded, size: 18),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 44),
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Semantics(
            label: l10n.quantityLabel,
            child: Text(
              '$value',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: canIncrement ? onIncrement : null,
          tooltip: l10n.quantityIncrease,
          icon: const Icon(Icons.add_rounded, size: 18),
        ),
      ],
    );
  }
}
