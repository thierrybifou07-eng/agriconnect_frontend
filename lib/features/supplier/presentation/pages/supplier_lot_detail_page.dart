import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/utils/dates.dart';
import 'package:agri_connect/core/utils/money.dart';
import 'package:agri_connect/features/chat/presentation/bindings/chat_bindings.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';
import 'package:agri_connect/features/supplier/presentation/controllers/supplier_controllers.dart';
import 'package:agri_connect/features/supplier/presentation/widgets/supplier_lot_detail_widgets.dart';
import 'package:agri_connect/features/supplier/presentation/widgets/supplier_widgets.dart';

class SupplierLotDetailPage extends GetView<SupplierLotDetailController> {
  const SupplierLotDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.supplierLotProduct)),
      body: Obx(() {
        final state = controller.state.value;
        if (state is Loading<SupplierLot> || state is Idle<SupplierLot>) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is Failure<SupplierLot>) {
          return _DetailFailure(failure: state.failure, retry: controller.load);
        }
        final lot = (state as Success<SupplierLot>).data;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SupplierLotGallery(images: lot.images),
            const SizedBox(height: 16),
            Text(
              lot.product.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('${lot.lotCode} · ${lot.zone.name}'),
            const SizedBox(height: 10),
            SupplierLotStatusBadge(status: lot.status),
            if (lot.status == LotStatus.rejected &&
                lot.rejectionReason?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              SupplierLotInfoCard(
                title: l10n.supplierLotRejectionReason,
                value: lot.rejectionReason!,
              ),
            ],
            const SizedBox(height: 16),
            SupplierLotInfoCard(
              title: l10n.supplierLotAgreedPrice,
              value: Money.format(lot.agreedUnitPrice),
            ),
            const SizedBox(height: 8),
            SupplierLotInfoCard(
              title: l10n.supplierLotInitial,
              value: '${lot.quantityInitial} ${lot.product.unit.label}',
            ),
            SupplierLotInfoCard(
              title: l10n.supplierLotAvailable,
              value: '${lot.quantityAvailable} ${lot.product.unit.label}',
            ),
            SupplierLotInfoCard(
              title: l10n.supplierLotReserved,
              value: '${lot.quantityReserved} ${lot.product.unit.label}',
            ),
            SupplierLotInfoCard(
              title: l10n.supplierLotSold,
              value: '${lot.quantitySold} ${lot.product.unit.label}',
            ),
            SupplierLotInfoCard(
              title: l10n.supplierLotLost,
              value: '${lot.quantityLost} ${lot.product.unit.label}',
            ),
            const SizedBox(height: 8),
            SupplierLotInfoCard(
              title: l10n.supplierLotStorageType,
              value: lot.storageType == 'HUB'
                  ? '${lot.hub?.name ?? ''} · ${lot.zone.name}'
                  : '${lot.pickupAddress ?? ''} · ${lot.zone.name}',
            ),
            if (lot.harvestedAt != null)
              SupplierLotInfoCard(
                title: l10n.supplierLotHarvestedAt,
                value: Dates.short(lot.harvestedAt!),
              ),
            if (lot.expiresAt != null)
              SupplierLotInfoCard(
                title: l10n.supplierLotExpiresAt,
                value: Dates.short(lot.expiresAt!),
              ),
            if (lot.packagingNote?.isNotEmpty == true)
              SupplierLotInfoCard(
                title: l10n.supplierLotPackagingNote,
                value: lot.packagingNote!,
              ),
            if (lot.qualityNote?.isNotEmpty == true)
              SupplierLotInfoCard(
                title: l10n.supplierLotQualityNote,
                value: lot.qualityNote!,
              ),
            const SizedBox(height: 16),
            if (lot.canEdit) ...[
              OutlinedButton.icon(
                onPressed: () => _edit(context, lot),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.supplierLotEdit),
              ),
              OutlinedButton.icon(
                onPressed: () => _delete(context),
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.supplierLotDelete),
              ),
            ] else if (lot.canDelete) ...[
              OutlinedButton.icon(
                onPressed: () => _delete(context),
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.supplierLotDelete),
              ),
            ] else if (lot.canWithdraw) ...[
              OutlinedButton.icon(
                onPressed: () => _withdraw(context),
                icon: const Icon(Icons.remove_circle_outline),
                label: Text(l10n.supplierLotWithdraw),
              ),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => ChatLauncher.openForLot(
                lot.id,
                prefill: l10n.supplierLotChatPrefill(lot.lotCode),
              ),
              icon: const Icon(Icons.forum_outlined),
              label: Text(l10n.supplierLotContactTeam),
            ),
            Obx(() {
              final failure = controller.actionFailure.value;
              if (failure == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  AppNotifier.failureMessage(failure, l10n),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  Future<void> _edit(BuildContext context, SupplierLot lot) async {
    final l10n = AppLocalizations.of(context);
    final quantity = TextEditingController(text: '${lot.quantityInitial}');
    final price = TextEditingController(text: '${lot.agreedUnitPrice}');
    final packaging = TextEditingController(text: lot.packagingNote ?? '');
    final quality = TextEditingController(text: lot.qualityNote ?? '');
    var harvested = lot.harvestedAt;
    var expires = lot.expiresAt;
    final fields = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.supplierLotEditTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SupplierLotEditField(
                  controller: price,
                  label: l10n.supplierLotAgreedPrice,
                ),
                SupplierLotEditField(
                  controller: quantity,
                  label: l10n.supplierLotQuantity,
                ),
                SupplierLotEditDateField(
                  label: l10n.supplierLotHarvestedAt,
                  value: harvested,
                  onChanged: (date) => setDialogState(() => harvested = date),
                ),
                SupplierLotEditDateField(
                  label: l10n.supplierLotExpiresAt,
                  value: expires,
                  onChanged: (date) => setDialogState(() => expires = date),
                ),
                SupplierLotEditField(
                  controller: packaging,
                  label: l10n.supplierLotPackagingNote,
                ),
                SupplierLotEditField(
                  controller: quality,
                  label: l10n.supplierLotQualityNote,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: Get.back, child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(quantity.text);
                final unitPrice = double.tryParse(price.text);
                final quantityValid =
                    amount != null &&
                    amount > 0 &&
                    RegExp(r'^\d+(?:\.\d{1,3})?$')
                        .hasMatch(quantity.text.trim());
                final priceValid =
                    unitPrice != null &&
                    unitPrice > 0 &&
                    RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(price.text.trim());
                if (!quantityValid) {
                  AppNotifier.error(l10n.supplierLotQuantityError);
                  return;
                }
                if (!priceValid) {
                  AppNotifier.error(l10n.supplierLotPriceError);
                  return;
                }
                if (lot.product.isPerishable && expires == null) {
                  AppNotifier.error(l10n.supplierLotExpiryRequired);
                  return;
                }
                if (packaging.text.length > 500 || quality.text.length > 500) {
                  AppNotifier.error(l10n.supplierLotNotesError);
                  return;
                }
                Get.back(
                  result: <String, Object?>{
                    'agreedUnitPrice': unitPrice,
                    'quantity': amount,
                    'harvestedAt': harvested?.toUtc().toIso8601String(),
                    'expiresAt': expires?.toUtc().toIso8601String(),
                    'packagingNote': packaging.text.trim(),
                    'qualityNote': quality.text.trim(),
                  },
                );
              },
              child: Text(l10n.supplierSave),
            ),
          ],
        ),
      ),
    );
    quantity.dispose();
    price.dispose();
    packaging.dispose();
    quality.dispose();
    if (fields == null) return;
    final success = await controller.updateLot(fields);
    if (!success && controller.actionFailure.value != null) {
      AppNotifier.error(
        AppNotifier.failureMessage(controller.actionFailure.value!, l10n),
      );
    }
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.supplierLotDelete),
        content: Text(l10n.supplierLotDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(l10n.supplierLotDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await controller.delete();
    if (success) {
      Get.back();
    } else if (controller.actionFailure.value != null) {
      AppNotifier.error(
        AppNotifier.failureMessage(controller.actionFailure.value!, l10n),
      );
    }
  }

  Future<void> _withdraw(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final reason = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.supplierLotWithdraw),
        content: TextField(
          controller: reason,
          maxLength: 500,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.supplierLotWithdrawReason,
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              if (reason.text.trim().isEmpty || reason.text.length > 500) {
                AppNotifier.error(l10n.supplierLotWithdrawError);
                return;
              }
              Get.back(result: reason.text.trim());
            },
            child: Text(l10n.supplierLotWithdraw),
          ),
        ],
      ),
    );
    reason.dispose();
    if (result == null) return;
    final success = await controller.withdraw(result);
    if (!success && controller.actionFailure.value != null) {
      AppNotifier.error(
        AppNotifier.failureMessage(controller.actionFailure.value!, l10n),
      );
    }
  }
}

class _DetailFailure extends StatelessWidget {
  const _DetailFailure({required this.failure, required this.retry});

  final ApiFailure failure;
  final Future<void> Function() retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(AppNotifier.failureMessage(failure, AppLocalizations.of(context))),
        TextButton(
          onPressed: retry,
          child: Text(AppLocalizations.of(context).retry),
        ),
      ],
    ),
  );
}
