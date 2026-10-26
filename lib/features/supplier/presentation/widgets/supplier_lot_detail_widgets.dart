import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/media/media_url.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';

class SupplierLotGallery extends StatelessWidget {
  const SupplierLotGallery({super.key, required this.images});

  final List<SupplierLotImage> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox(
        height: 220,
        child: ColoredBox(
          color: Color(0xFFE8EDE8),
          child: Icon(Icons.image_outlined, size: 54),
        ),
      );
    }
    return SizedBox(
      height: 240,
      child: PageView(
        children: [
          for (final image in images)
            Image.network(
              MediaUrl.resolve(image.url) ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFFE8EDE8),
                child: Icon(Icons.broken_image_outlined, size: 54),
              ),
            ),
        ],
      ),
    );
  }
}

class SupplierLotInfoCard extends StatelessWidget {
  const SupplierLotInfoCard({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    subtitle: Text(value),
  );
}

class SupplierLotEditField extends StatelessWidget {
  const SupplierLotEditField({
    super.key,
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

class SupplierLotEditDateField extends StatelessWidget {
  const SupplierLotEditDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

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
            tooltip: AppLocalizations.of(context).supplierClear,
            onPressed: () => onChanged(null),
            icon: const Icon(Icons.clear),
          ),
        IconButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) onChanged(date);
          },
          icon: const Icon(Icons.calendar_month_outlined),
        ),
      ],
    ),
  );
}
