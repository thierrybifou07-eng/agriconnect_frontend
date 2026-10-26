import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/ui/paginated_controller.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/domain/buyer_repository.dart';
import 'package:agri_connect/features/reference/domain/reference_entities.dart';

class CatalogController extends PaginatedController<CatalogListing> {
  CatalogController({required this.repository, super.limit = 20});

  final CatalogRepository repository;
  final Rx<UiState<List<CatalogCategory>>> categoriesState =
      Rx<UiState<List<CatalogCategory>>>(const Idle());
  final RxInt selectedCategoryId = 0.obs;
  final Rxn<RefZone> selectedZone = Rxn<RefZone>();
  final RxString query = ''.obs;
  final RxnString sort = RxnString();
  final TextEditingController searchController = TextEditingController();
  late final Worker _queryWorker;
  late final Worker _zoneWorker;
  bool _loadingFirst = false;
  bool _reloadAfterCurrent = false;

  @override
  void onInit() {
    super.onInit();
    _queryWorker = debounce(
      query,
      (_) => unawaited(loadFirst()),
      time: const Duration(milliseconds: 400),
    );
    _zoneWorker = ever(selectedZone, (_) => unawaited(loadFirst()));
    unawaited(loadCategories());
    unawaited(loadFirst());
  }

  Future<void> loadCategories() async {
    categoriesState.value = const Loading();
    try {
      categoriesState.value = Success(
        List.unmodifiable(await repository.categories()),
      );
    } on ApiFailure catch (failure) {
      categoriesState.value = Failure(failure);
    }
  }

  void selectCategory(int? id) {
    selectedCategoryId.value = id ?? 0;
    unawaited(loadFirst());
  }

  void selectZone(RefZone? zone) {
    selectedZone.value = zone;
  }

  void selectSort(String? value) {
    sort.value = value;
    unawaited(loadFirst());
  }

  void clearFilters() {
    selectedCategoryId.value = 0;
    selectedZone.value = null;
    searchController.clear();
    query.value = '';
    sort.value = null;
    unawaited(loadFirst());
  }

  @override
  Future<void> loadFirst() async {
    if (_loadingFirst) {
      _reloadAfterCurrent = true;
      return;
    }
    _loadingFirst = true;
    try {
      do {
        _reloadAfterCurrent = false;
        await super.loadFirst();
      } while (_reloadAfterCurrent);
    } finally {
      _loadingFirst = false;
    }
  }

  @override
  Future<Paginated<CatalogListing>> fetch(int page, int limit) =>
      repository.listings(
        categoryId: selectedCategoryId.value == 0
            ? null
            : selectedCategoryId.value,
        zoneId: selectedZone.value?.id,
        query: query.value,
        sort: sort.value,
        page: page,
        limit: limit,
      );

  @override
  void onClose() {
    _queryWorker.dispose();
    _zoneWorker.dispose();
    searchController.dispose();
    super.onClose();
  }
}

class ListingDetailController extends GetxController {
  ListingDetailController({required this.id, required this.repository});

  final int id;
  final CatalogRepository repository;
  final Rx<UiState<CatalogListing>> state = Rx<UiState<CatalogListing>>(
    const Idle(),
  );

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    state.value = const Loading();
    try {
      state.value = Success(await repository.listing(id));
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    }
  }
}
