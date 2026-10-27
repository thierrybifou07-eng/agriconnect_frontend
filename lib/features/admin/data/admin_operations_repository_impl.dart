import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/admin/data/admin_operations_api.dart';
import 'package:agri_connect/features/admin/domain/admin_operations.dart';

class AdminOperationsRepositoryImpl implements AdminOperationsRepository {
  const AdminOperationsRepositoryImpl(this._api);

  final AdminOperationsApi _api;

  @override
  Future<Paginated<AdminOperationRecord>> referentials(
    String kind, {
    required int page,
    required int limit,
    bool? active,
  }) => _guard(
    () => _api.referentials(kind, page: page, limit: limit, active: active),
  );

  @override
  Future<void> saveReferential(
    String kind,
    int? id,
    Map<String, Object?> body,
  ) => _guard(() async {
    if (id == null) {
      await _api.createReferential(kind, body);
    } else {
      await _api.updateReferential(kind, id, body);
    }
  });

  @override
  Future<Paginated<AdminOperationRecord>> agencies({
    required int page,
    required int limit,
  }) => _guard(() => _api.agencies(page: page, limit: limit));

  @override
  Future<void> saveAgency(int? id, Map<String, Object?> body) =>
      _guard(() => _api.saveAgency(id, body));

  @override
  Future<void> saveAgencyZone(
    int agencyId,
    int zoneId,
    Map<String, Object?> body,
  ) => _guard(() => _api.saveAgencyZone(agencyId, zoneId, body));

  @override
  Future<void> removeAgencyZone(int agencyId, int zoneId) =>
      _guard(() => _api.removeAgencyZone(agencyId, zoneId));

  @override
  Future<List<AdminOperationRecord>> agencyDrivers(int agencyId) =>
      _guard(() => _api.agencyDrivers(agencyId));

  @override
  Future<Paginated<AdminOperationRecord>> moneyRecords(
    String kind, {
    required int page,
    required int limit,
    String? status,
  }) => _guard(
    () => _api.moneyRecords(kind, page: page, limit: limit, status: status),
  );

  @override
  Future<void> payout(int id, Map<String, Object?> body) =>
      _guard(() => _api.payout(id, body));

  @override
  Future<void> referralAction(
    int id,
    String action,
    Map<String, Object?> body,
  ) => _guard(() => _api.referralAction(id, action, body));

  @override
  Future<void> compensationAction(
    int id,
    String action,
    Map<String, Object?> body,
  ) => _guard(() => _api.compensationAction(id, action, body));

  @override
  Future<List<AdminLegalDocument>> publishedLegal() =>
      _guard(_api.publishedLegal);

  @override
  Future<AdminLegalDocument> createLegalVersion(
    String code,
    Map<String, Object?> body,
  ) => _guard(() => _api.createLegalVersion(code, body));

  @override
  Future<void> publishLegalVersion(int id) =>
      _guard(() => _api.publishLegalVersion(id));

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FormatException catch (error) {
      throw ApiFailure(
        status: null,
        code: 'INVALID_RESPONSE',
        message: error.message.toString(),
        fieldErrors: const {},
        kind: ApiFailureKind.server,
      );
    }
  }
}
