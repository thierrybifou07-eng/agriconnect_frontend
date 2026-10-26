import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/presentation/controllers/catalog_controller.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_listing_card.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';
import 'package:agri_connect/features/reference/presentation/widgets/reference_pickers.dart';

class CatalogPage extends GetView<CatalogController> {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.buyerCatalogTab)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: controller.searchController,
              onChanged: (value) => controller.query.value = value,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.searchCatalog,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 58,
            child: Obx(() {
              final current = controller.categoriesState.value;
              if (current is Loading<List<CatalogCategory>> ||
                  current is Idle<List<CatalogCategory>>) {
                return const Center(
                  child: SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (current is Failure<List<CatalogCategory>>) {
                return TextButton.icon(
                  onPressed: controller.loadCategories,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    '${AppNotifier.failureMessage(current.failure, l10n)} · ${l10n.retry}',
                  ),
                );
              }
              final categories =
                  (current as Success<List<CatalogCategory>>).data;
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Obx(
                      () => ChoiceChip(
                        label: Text(l10n.filterAll),
                        selected: controller.selectedCategoryId.value == 0,
                        onSelected: (_) => controller.selectCategory(null),
                      ),
                    ),
                  ),
                  for (final category in categories)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Obx(
                        () => ChoiceChip(
                          label: Text(category.label),
                          selected:
                              controller.selectedCategoryId.value ==
                              category.id,
                          onSelected: (_) =>
                              controller.selectCategory(category.id),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: ZonePicker(
                    repository: Get.find<ReferenceRepository>(),
                    value: controller.selectedZone,
                    label: l10n.filterLocation,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => PopupMenuButton<String>(
                    tooltip: l10n.catalogSortLabel,
                    initialValue: controller.sort.value ?? 'recent',
                    onSelected: (value) =>
                        controller.selectSort(value == 'recent' ? null : value),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'recent',
                        child: Text(l10n.catalogSortRecent),
                      ),
                      PopupMenuItem(
                        value: 'price',
                        child: Text(l10n.catalogSortPrice),
                      ),
                      PopupMenuItem(
                        value: 'expiry',
                        child: Text(l10n.catalogSortExpiry),
                      ),
                    ],
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.sort),
                      label: Text(
                        controller.sort.value == 'price'
                            ? l10n.catalogSortPrice
                            : controller.sort.value == 'expiry'
                            ? l10n.catalogSortExpiry
                            : l10n.catalogSortLabel,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final hasFilters =
                controller.selectedCategoryId.value != 0 ||
                controller.selectedZone.value != null ||
                controller.query.value.isNotEmpty ||
                controller.sort.value != null;
            if (!hasFilters) return const SizedBox.shrink();
            return Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.clearFilters,
                child: Text(l10n.catalogFiltersReset),
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              final state = controller.state.value;
              if (state is Loading<List<CatalogListing>> ||
                  state is Idle<List<CatalogListing>>) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is Failure<List<CatalogListing>>) {
                return _MessageState(
                  message: AppNotifier.failureMessage(state.failure, l10n),
                  actionLabel: l10n.retry,
                  onAction: controller.loadFirst,
                );
              }
              final listings = (state as Success<List<CatalogListing>>).data;
              if (listings.isEmpty) {
                return _MessageState(
                  message:
                      '${l10n.catalogEmptyTitle}\n${l10n.catalogEmptyBody}',
                );
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >
                      notification.metrics.maxScrollExtent - 300) {
                    unawaited(controller.loadMore());
                  }
                  return false;
                },
                child: RefreshIndicator(
                  onRefresh: controller.loadFirst,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: listings.length + (controller.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == listings.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final listing = listings[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CatalogListingCard(
                          listing: listing,
                          onTap: () => Get.toNamed(
                            AppRoutes.buyerListing(listing.id),
                            arguments: listing.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    ),
  );
}
