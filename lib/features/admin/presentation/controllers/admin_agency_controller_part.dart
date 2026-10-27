part of 'admin_operations_controller.dart';

extension AdminAgencyOperations on AdminOperationsController {
  Future<void> loadAgencies({int? page}) async {
    final nextPage = page ?? _agencyPage;
    agencyState.value = const Loading<Paginated<AdminOperationRecord>>();
    try {
      final result = await repository.agencies(page: nextPage, limit: 20);
      _agencyPage = result.page;
      _agenciesHaveMore = result.hasMore;
      agencyState.value = Success(result);
    } on ApiFailure catch (failure) {
      agencyState.value = Failure(failure);
    }
  }

  Future<void> loadMoreAgencies() async {
    if (!_agenciesHaveMore) return;
    final oldState = agencyState.value;
    if (oldState is! Success<Paginated<AdminOperationRecord>>) return;
    try {
      final next = await repository.agencies(page: _agencyPage + 1, limit: 20);
      _agencyPage = next.page;
      _agenciesHaveMore = next.hasMore;
      agencyState.value = Success(
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

  Future<bool> saveAgency(int? id, Map<String, Object?> body) async {
    if (!_validAgency(body)) return false;
    actionState.value = const Loading<void>();
    try {
      await repository.saveAgency(id, body);
      actionState.value = const Success<void>(null);
      await loadAgencies();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      return false;
    }
  }

  Future<bool> saveCoverage(
    int agencyId,
    int zoneId,
    double baseFee,
    double perKmFee, {
    bool? isActive,
  }) async {
    if (zoneId <= 0 ||
        !baseFee.isFinite ||
        !perKmFee.isFinite ||
        baseFee < 0 ||
        perKmFee < 0) {
      return false;
    }
    actionState.value = const Loading<void>();
    try {
      await repository.saveAgencyZone(agencyId, zoneId, {
        'baseFee': baseFee,
        'perKmFee': perKmFee,
        'isActive': ?isActive,
      });
      actionState.value = const Success<void>(null);
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      return false;
    }
  }

  Future<bool> removeCoverage(int agencyId, int zoneId) async {
    actionState.value = const Loading<void>();
    try {
      await repository.removeAgencyZone(agencyId, zoneId);
      actionState.value = const Success<void>(null);
      await loadAgencies();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      return false;
    }
  }

  Future<void> loadAgencyDrivers(int agencyId) async {
    driversState.value = const Loading<List<AdminOperationRecord>>();
    try {
      final records = await repository.agencyDrivers(agencyId);
      agencyDrivers.assignAll(records);
      driversState.value = Success(records);
    } on ApiFailure catch (failure) {
      driversState.value = Failure(failure);
    }
  }
}

bool _validAgency(Map<String, Object?> body) {
  final name = body['name'];
  final phone = body['phone'];
  final email = body['email'];
  final contactName = body['contactName'];
  final insuranceProvider = body['insuranceProvider'];
  final insurancePolicyNumber = body['insurancePolicyNumber'];
  return name is String &&
      name.trim().length >= 2 &&
      name.trim().length <= 120 &&
      phone is String &&
      phone.trim().length >= 6 &&
      phone.trim().length <= 20 &&
      (email == null ||
          email is String &&
              email.length <= 160 &&
              (email.isEmpty ||
                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email))) &&
      (contactName == null ||
          contactName is String && contactName.length <= 120) &&
      (insuranceProvider == null ||
          insuranceProvider is String && insuranceProvider.length <= 120) &&
      (insurancePolicyNumber == null ||
          insurancePolicyNumber is String &&
              insurancePolicyNumber.length <= 80);
}
