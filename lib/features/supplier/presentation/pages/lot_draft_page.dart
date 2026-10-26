import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';
import 'package:agri_connect/features/supplier/presentation/controllers/lot_draft_controller.dart';
import 'package:agri_connect/features/supplier/presentation/pages/lot_draft_details.dart';
import 'package:agri_connect/features/supplier/presentation/pages/lot_draft_steps.dart';

class LotDraftPage extends GetView<LotDraftController> {
  const LotDraftPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reference = Get.find<ReferenceRepository>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.supplierLotNewTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => LotDraftStepHeader(step: controller.step.value)),
            Expanded(
              child: Obx(
                () => SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LotDraftStepTitle(step: controller.step.value),
                      const SizedBox(height: 18),
                      switch (controller.step.value) {
                        0 => LotDraftProductStep(
                          controller: controller,
                          reference: reference,
                        ),
                        1 => LotDraftQuantityStep(controller: controller),
                        2 => LotDraftStorageStep(
                          controller: controller,
                          reference: reference,
                        ),
                        _ => LotDraftDetailsStep(controller: controller),
                      },
                      Obx(() {
                        final state = controller.submitState.value;
                        if (state is Failure<SupplierLot>) {
                          return LotDraftSubmitFailure(failure: state.failure);
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => Row(
                  children: [
                    if (controller.step.value > 0)
                      OutlinedButton(
                        onPressed: controller.previousStep,
                        child: Text(l10n.supplierLotPrevious),
                      ),
                    const Spacer(),
                    if (controller.step.value < 3)
                      FilledButton(
                        onPressed: () {
                          if (!controller.nextStep()) {
                            _showValidationError(
                              context,
                              controller.validationError.value,
                            );
                          }
                        },
                        child: Text(l10n.supplierLotNext),
                      )
                    else
                      FilledButton(
                        onPressed: controller.isSubmitting
                            ? null
                            : () => _submit(context),
                        child: controller.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.supplierLotSubmit),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showValidationError(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context);
    final message = switch (error) {
      'product' => l10n.supplierLotSelectProduct,
      'quantity' => l10n.supplierLotQuantityError,
      'price' => l10n.supplierLotPriceError,
      'zone' => l10n.supplierLotSelectZone,
      'hub' => l10n.supplierLotSelectHub,
      'pickupAddress' ||
      'pickupLatitude' ||
      'pickupLongitude' => l10n.supplierLotPickupRequired,
      'photos' => l10n.supplierLotPhotosRequired,
      'photoSize' => l10n.supplierLotPhotoTooLarge,
      'expiresAt' => l10n.supplierLotExpiryRequired,
      'packagingNote' || 'qualityNote' => l10n.supplierLotNotesError,
      _ => l10n.supplierLotPhotosRequired,
    };
    AppNotifier.error(message);
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final sent = await controller.submit();
    if (!context.mounted) return;
    if (sent) {
      AppNotifier.success(l10n.supplierLotSubmitted);
      Get.back(result: true);
    } else if (controller.validationError.value.isNotEmpty) {
      _showValidationError(context, controller.validationError.value);
    }
  }
}
