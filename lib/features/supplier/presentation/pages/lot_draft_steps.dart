import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';
import 'package:agri_connect/features/reference/presentation/widgets/reference_pickers.dart';
import 'package:agri_connect/features/supplier/presentation/controllers/lot_draft_controller.dart';

class LotDraftStepHeader extends StatelessWidget {
  const LotDraftStepHeader({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
    child: LinearProgressIndicator(value: (step + 1) / 4),
  );
}

class LotDraftStepTitle extends StatelessWidget {
  const LotDraftStepTitle({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = switch (step) {
      0 => l10n.supplierLotProductStep,
      1 => l10n.supplierLotQuantityStep,
      2 => l10n.supplierLotStorageStep,
      _ => l10n.supplierLotPhotosStep,
    };
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class LotDraftProductStep extends StatelessWidget {
  const LotDraftProductStep({
    super.key,
    required this.controller,
    required this.reference,
  });

  final LotDraftController controller;
  final ReferenceRepository reference;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductPicker(
          repository: reference,
          value: controller.product,
          label: l10n.supplierLotProduct,
        ),
        Obx(() {
          final product = controller.product.value;
          if (product == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text('${product.category.label} · ${product.unit.label}'),
          );
        }),
      ],
    );
  }
}

class LotDraftQuantityStep extends StatelessWidget {
  const LotDraftQuantityStep({super.key, required this.controller});

  final LotDraftController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        TextField(
          onChanged: (value) => controller.quantity.value = value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.supplierLotQuantity),
        ),
        const SizedBox(height: 14),
        Obx(() {
          final unit = controller.product.value?.unit.label;
          return unit == null
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.supplierLotUnitHint(unit)),
                );
        }),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => controller.agreedUnitPrice.value = value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.supplierLotAgreedPrice,
            suffixText: 'XAF',
          ),
        ),
      ],
    );
  }
}

class LotDraftStorageStep extends StatelessWidget {
  const LotDraftStorageStep({
    super.key,
    required this.controller,
    required this.reference,
  });

  final LotDraftController controller;
  final ReferenceRepository reference;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ZonePicker(
          repository: reference,
          value: controller.zone,
          label: l10n.supplierLotZone,
        ),
        const SizedBox(height: 14),
        Obx(
          () => Column(
            children: [
              RadioGroup<String>(
                groupValue: controller.storageType.value,
                onChanged: (value) {
                  if (value != null) controller.selectStorage(value);
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'HUB',
                      title: Text(l10n.supplierLotHubStorage),
                    ),
                    RadioListTile<String>(
                      value: 'SUPPLIER_SITE',
                      title: Text(l10n.supplierLotSiteStorage),
                    ),
                  ],
                ),
              ),
              if (controller.storageType.value == 'HUB')
                HubPicker(
                  repository: reference,
                  value: controller.hub,
                  label: l10n.supplierLotHub,
                  zoneId: controller.zone.value?.id,
                )
              else
                _SupplierSiteFields(controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupplierSiteFields extends StatelessWidget {
  const _SupplierSiteFields({required this.controller});

  final LotDraftController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        TextField(
          onChanged: (value) => controller.pickupAddress.value = value,
          decoration: InputDecoration(labelText: l10n.supplierLotPickupAddress),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => controller.pickupLatitude.value = value,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.supplierLotLatitude,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (value) => controller.pickupLongitude.value = value,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.supplierLotLongitude,
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _useLocation(context),
            icon: const Icon(Icons.my_location),
            label: Text(l10n.supplierUseLocation),
          ),
        ),
      ],
    );
  }

  Future<void> _useLocation(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        AppNotifier.error(l10n.supplierLocationUnavailable);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        AppNotifier.error(l10n.supplierLocationUnavailable);
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      controller.pickupLatitude.value = position.latitude.toString();
      controller.pickupLongitude.value = position.longitude.toString();
    } on Exception {
      AppNotifier.error(l10n.supplierLocationUnavailable);
    }
  }
}
