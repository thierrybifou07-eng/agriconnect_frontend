part of 'admin_operations_controller.dart';

extension AdminReferentialOperations on AdminOperationsController {
  Future<void> setReferentialKind(String kind) async {
    if (kind == referentialKind.value) return;
    referentialKind.value = kind;
    _referentialPage = 1;
    await loadReferentials();
  }

  Future<void> setActiveFilter(bool? value) async {
    activeFilter.value = value;
    _referentialPage = 1;
    await loadReferentials();
  }

  Future<void> loadReferentials({int? page}) async {
    final nextPage = page ?? _referentialPage;
    referentialState.value = const Loading<Paginated<AdminOperationRecord>>();
    try {
      final result = await repository.referentials(
        referentialKind.value,
        page: nextPage,
        limit: 20,
        active: activeFilter.value,
      );
      _referentialPage = result.page;
      _referentialsHaveMore = result.hasMore;
      referentialState.value = Success(result);
    } on ApiFailure catch (failure) {
      referentialState.value = Failure(failure);
    }
  }

  Future<void> loadMoreReferentials() async {
    if (!_referentialsHaveMore) return;
    final oldState = referentialState.value;
    if (oldState is! Success<Paginated<AdminOperationRecord>>) return;
    try {
      final next = await repository.referentials(
        referentialKind.value,
        page: _referentialPage + 1,
        limit: 20,
        active: activeFilter.value,
      );
      _referentialPage = next.page;
      _referentialsHaveMore = next.hasMore;
      referentialState.value = Success(
        Paginated<AdminOperationRecord>(
          items: [...oldState.data.items, ...next.items],
          page: next.page,
          limit: next.limit,
          total: next.total,
        ),
      );
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
    }
  }

  Future<bool> saveReferential({
    required int? id,
    required Map<String, Object?> values,
  }) async {
    final errorField = validateAdminReferential(referentialKind.value, values);
    if (errorField != null) return false;
    actionState.value = const Loading<void>();
    try {
      await repository.saveReferential(referentialKind.value, id, values);
      references.invalidate();
      actionState.value = const Success<void>(null);
      await loadReferentials();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      return false;
    }
  }
}
