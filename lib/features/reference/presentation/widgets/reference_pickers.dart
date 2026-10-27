import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/features/reference/domain/reference_entities.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';

class ZonePicker extends StatelessWidget {
  const ZonePicker({
    super.key,
    required this.repository,
    required this.value,
    required this.label,
  });

  final ReferenceRepository repository;
  final Rxn<RefZone> value;
  final String label;

  @override
  Widget build(BuildContext context) => Obx(
    () => _PickerField(
      label: label,
      value: value.value?.displayName,
      onTap: () => _open(context),
    ),
  );

  Future<void> _open(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReferenceListSheet<RefZone>(
        title: label,
        load: (_) => repository.zones(),
        label: (zone) => zone.displayName,
        onSelected: (zone) => value.value = zone,
      ),
    );
  }
}

class HubPicker extends StatelessWidget {
  const HubPicker({
    super.key,
    required this.repository,
    required this.value,
    required this.label,
    this.zoneId,
    this.acceptsPickup,
    this.acceptsDropoff,
  });

  final ReferenceRepository repository;
  final Rxn<RefHub> value;
  final String label;
  final int? zoneId;
  final bool? acceptsPickup;
  final bool? acceptsDropoff;

  @override
  Widget build(BuildContext context) => Obx(
    () => _PickerField(
      label: label,
      value: value.value?.name,
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ReferenceListSheet<RefHub>(
          title: label,
          load: (_) async => (await repository.hubs(zoneId: zoneId))
              .where(
                (hub) =>
                    (acceptsPickup == null ||
                        hub.acceptsPickup == acceptsPickup) &&
                    (acceptsDropoff == null ||
                        hub.acceptsDropoff == acceptsDropoff),
              )
              .toList(),
          label: (hub) => [hub.name, hub.city].whereType<String>().join(', '),
          onSelected: (hub) => value.value = hub,
        ),
      ),
    ),
  );
}

class ProductPicker extends StatelessWidget {
  const ProductPicker({
    super.key,
    required this.repository,
    required this.value,
    required this.label,
  });

  final ReferenceRepository repository;
  final Rxn<RefProduct> value;
  final String label;

  @override
  Widget build(BuildContext context) => Obx(
    () => _PickerField(
      label: label,
      value: value.value?.name,
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ProductPickerSheet(
          repository: repository,
          title: label,
          value: value,
        ),
      ),
    ),
  );
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      child: Text(value ?? '—'),
    ),
  );
}

class _ReferenceListSheet<T> extends StatefulWidget {
  const _ReferenceListSheet({
    required this.title,
    required this.load,
    required this.label,
    required this.onSelected,
  });

  final String title;
  final Future<List<T>> Function(String query) load;
  final String Function(T item) label;
  final ValueChanged<T> onSelected;

  @override
  State<_ReferenceListSheet<T>> createState() => _ReferenceListSheetState<T>();
}

class _ReferenceListSheetState<T> extends State<_ReferenceListSheet<T>> {
  late Future<List<T>> _future = widget.load('');
  String _query = '';

  void _search(String query) {
    setState(() {
      _query = query;
      _future = widget.load(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .7,
          child: Column(
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.accountSearch,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: _search,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<T>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      final error = snapshot.error;
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              error is ApiFailure
                                  ? AppNotifier.failureMessage(error, l10n)
                                  : l10n.accountLoadError,
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: () => _search(_query),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      );
                    }
                    final items = snapshot.data;
                    if (items == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (items.isEmpty) {
                      return Center(child: Text(l10n.accountNoResults));
                    }
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(widget.label(item)),
                          onTap: () {
                            widget.onSelected(item);
                            Get.back<void>();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductPickerSheet extends StatefulWidget {
  const _ProductPickerSheet({
    required this.repository,
    required this.title,
    required this.value,
  });

  final ReferenceRepository repository;
  final String title;
  final Rxn<RefProduct> value;

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  late Future<List<RefCategory>> _categories = widget.repository.categories();
  Future<List<RefProduct>>? _products;
  int? _categoryId;
  String _query = '';

  void _loadProducts() {
    setState(() {
      _products = widget.repository.products(
        q: _query,
        categoryId: _categoryId,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _products = widget.repository.products();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .75,
          child: Column(
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.accountSearch,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (query) {
                  _query = query;
                  _loadProducts();
                },
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<RefCategory>>(
                future: _categories,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return TextButton(
                      onPressed: () => setState(
                        () => _categories = widget.repository.categories(
                          forceRefresh: true,
                        ),
                      ),
                      child: Text(l10n.retry),
                    );
                  }
                  final categories = snapshot.data;
                  if (categories == null) {
                    return const LinearProgressIndicator();
                  }
                  return DropdownButtonFormField<int?>(
                    initialValue: _categoryId,
                    decoration: InputDecoration(
                      labelText: l10n.accountCategory,
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(l10n.accountAllCategories),
                      ),
                      for (final category in categories)
                        DropdownMenuItem<int?>(
                          value: category.id,
                          child: Text(category.label),
                        ),
                    ],
                    onChanged: (value) {
                      _categoryId = value;
                      _loadProducts();
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<RefProduct>>(
                  future: _products,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: TextButton(
                          onPressed: _loadProducts,
                          child: Text(l10n.retry),
                        ),
                      );
                    }
                    final products = snapshot.data;
                    if (products == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (products.isEmpty) {
                      return Center(child: Text(l10n.accountNoResults));
                    }
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                            '${product.category.label} · ${product.unit.label}',
                          ),
                          onTap: () {
                            widget.value.value = product;
                            Get.back<void>();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
