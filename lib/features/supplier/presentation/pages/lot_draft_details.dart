import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/features/supplier/presentation/controllers/lot_draft_controller.dart';

class LotDraftDetailsStep extends StatelessWidget {
  const LotDraftDetailsStep({super.key, required this.controller});

  final LotDraftController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => _pickPhotos(context),
          icon: const Icon(Icons.add_a_photo_outlined),
          label: Text(l10n.supplierLotChoosePhotos),
        ),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < controller.photos.length; index++)
                _PhotoPreview(
                  photo: controller.photos[index],
                  onRemove: () => controller.removePhoto(index),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Obx(
          () => Column(
            children: [
              _DateField(
                label: l10n.supplierLotHarvestedAt,
                value: controller.harvestedAt.value,
                onSelected: (date) => controller.harvestedAt.value = date,
              ),
              _DateField(
                label: controller.isPerishable
                    ? '${l10n.supplierLotExpiresAt} *'
                    : l10n.supplierLotExpiresAt,
                value: controller.expiresAt.value,
                onSelected: (date) => controller.expiresAt.value = date,
              ),
            ],
          ),
        ),
        TextField(
          maxLength: 500,
          maxLines: 3,
          onChanged: (value) => controller.packagingNote.value = value,
          decoration: InputDecoration(
            labelText: l10n.supplierLotPackagingNote,
            helperText: l10n.supplierLotNotesLimit,
          ),
        ),
        TextField(
          maxLength: 500,
          maxLines: 3,
          onChanged: (value) => controller.qualityNote.value = value,
          decoration: InputDecoration(
            labelText: l10n.supplierLotQualityNote,
            helperText: l10n.supplierLotNotesLimit,
          ),
        ),
      ],
    );
  }

  Future<void> _pickPhotos(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      final images = await ImagePicker().pickMultiImage(
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (images.isEmpty) return;
      if (!await controller.addPhotos(images)) {
        AppNotifier.error(
          controller.validationError.value == 'photoSize'
              ? l10n.supplierLotPhotoTooLarge
              : l10n.supplierLotPhotosRequired,
        );
      }
    } on Exception {
      AppNotifier.error(l10n.supplierLotPhotosRequired);
    }
  }
}

class LotDraftSubmitFailure extends StatelessWidget {
  const LotDraftSubmitFailure({super.key, required this.failure});

  final ApiFailure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = failure.fieldErrors.isEmpty
        ? AppNotifier.failureMessage(failure, l10n)
        : failure.fieldErrors.entries
              .map((entry) => '${entry.key}: ${entry.value}')
              .join('\n');
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.photo, required this.onRemove});

  final XFile photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 92,
    height: 92,
    child: Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder(
            future: photo.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const ColoredBox(
                  color: Color(0xFFE8EDE8),
                  child: Icon(Icons.broken_image_outlined),
                );
              }
              return snapshot.hasData
                  ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                  : const ColoredBox(
                      color: Color(0xFFE8EDE8),
                      child: Center(child: CircularProgressIndicator()),
                    );
            },
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton.filledTonal(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    ),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onSelected,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onSelected;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(
      value == null
          ? AppLocalizations.of(context).supplierOptional
          : MaterialLocalizations.of(context).formatMediumDate(value!),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value != null)
          IconButton(
            onPressed: () => onSelected(null),
            icon: const Icon(Icons.clear),
            tooltip: AppLocalizations.of(context).supplierClear,
          ),
        IconButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) onSelected(date);
          },
          icon: const Icon(Icons.calendar_month_outlined),
        ),
      ],
    ),
  );
}
