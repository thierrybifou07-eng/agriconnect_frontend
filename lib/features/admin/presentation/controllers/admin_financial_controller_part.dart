part of 'admin_operations_controller.dart';

extension AdminFinancialOperations on AdminOperationsController {
  Future<void> setMoneyKind(String kind) async {
    moneyKind.value = kind;
    moneyStatus.value = null;
    _moneyPage = 1;
    await loadMoney();
  }

  Future<void> setMoneyFilter(String kind, String? status) async {
    moneyKind.value = kind;
    moneyStatus.value = status;
    _moneyPage = 1;
    await loadMoney();
  }

  Future<void> setMoneyStatus(String? status) async {
    moneyStatus.value = status;
    _moneyPage = 1;
    await loadMoney();
  }

  Future<void> loadMoney({int? page}) async {
    final nextPage = page ?? _moneyPage;
    moneyState.value = const Loading<Paginated<AdminOperationRecord>>();
    try {
      final result = await repository.moneyRecords(
        moneyKind.value,
        page: nextPage,
        limit: 20,
        status: moneyStatus.value,
      );
      _moneyPage = result.page;
      _moneyHaveMore = result.hasMore;
      moneyState.value = Success(result);
    } on ApiFailure catch (failure) {
      moneyState.value = Failure(failure);
    }
  }

  Future<void> loadMoreMoney() async {
    if (!_moneyHaveMore) return;
    final oldState = moneyState.value;
    if (oldState is! Success<Paginated<AdminOperationRecord>>) return;
    try {
      final next = await repository.moneyRecords(
        moneyKind.value,
        page: _moneyPage + 1,
        limit: 20,
        status: moneyStatus.value,
      );
      _moneyPage = next.page;
      _moneyHaveMore = next.hasMore;
      moneyState.value = Success(
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

  Future<bool> payPayout(
    int id,
    String reference, {
    int? payoutAccountId,
  }) async {
    final normalized = reference.trim();
    if (normalized.isEmpty || normalized.length > 255) return false;
    actionState.value = const Loading<void>();
    try {
      await repository.payout(id, {
        'reference': normalized,
        'payoutAccountId': ?payoutAccountId,
      });
      actionState.value = const Success<void>(null);
      await loadMoney();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      return false;
    }
  }

  Future<bool> referralAction(int id, String action, String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty ||
        (action == 'pay' && normalized.length > 100) ||
        (action == 'reject' && normalized.length > 2000)) {
      return false;
    }
    actionState.value = const Loading<void>();
    try {
      await repository.referralAction(id, action, {
        action == 'pay' ? 'reference' : 'reason': normalized,
      });
      actionState.value = const Success<void>(null);
      await loadMoney();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      if (failure.isStateConflict) await loadMoney();
      return false;
    }
  }

  Future<bool> compensationAction(int id, String action, String value) async {
    final normalized = value.trim();
    if ((action == 'reject' &&
            (normalized.isEmpty || normalized.length > 500)) ||
        (action == 'pay' && (normalized.isEmpty || normalized.length > 100))) {
      return false;
    }
    actionState.value = const Loading<void>();
    try {
      await repository.compensationAction(id, action, switch (action) {
        'approve' => const {},
        'reject' => {'note': normalized},
        'pay' => {'reference': normalized},
        _ => throw ArgumentError.value(action, 'action'),
      });
      actionState.value = const Success<void>(null);
      await loadMoney();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      if (failure.isStateConflict) await loadMoney();
      return false;
    }
  }
}
