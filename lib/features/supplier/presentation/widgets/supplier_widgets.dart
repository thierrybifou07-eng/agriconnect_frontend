import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';

String lotStatusLabel(LotStatus status, AppLocalizations l10n) =>
    switch (status) {
      LotStatus.pendingValidation => l10n.supplierLotStatusPending,
      LotStatus.available => l10n.supplierLotStatusAvailable,
      LotStatus.fullyReserved => l10n.supplierLotStatusReserved,
      LotStatus.soldOut => l10n.supplierLotStatusSold,
      LotStatus.expired => l10n.supplierLotStatusExpired,
      LotStatus.returned => l10n.supplierLotStatusReturned,
      LotStatus.rejected => l10n.supplierLotStatusRejected,
      LotStatus.withdrawn => l10n.supplierLotStatusWithdrawn,
    };

class SupplierLotStatusBadge extends StatelessWidget {
  const SupplierLotStatusBadge({super.key, required this.status});

  final LotStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      LotStatus.available => Colors.green.shade700,
      LotStatus.pendingValidation => Colors.orange.shade800,
      LotStatus.rejected || LotStatus.expired => Colors.red.shade700,
      LotStatus.fullyReserved || LotStatus.soldOut => Colors.blue.shade700,
      _ => Theme.of(context).colorScheme.onSurfaceVariant,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          lotStatusLabel(status, AppLocalizations.of(context)),
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
