import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/admin/data/admin_api.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._api);

  final AdminApi _api;

  @override
  Future<AdminStats> stats({DateTime? from, DateTime? to}) =>
      _guard(() => _api.stats(from: from, to: to));

  @override
  Future<List<AdminUser>> users({
    String? role,
    String? search,
    String? status,
    String? profileVerificationStatus,
  }) => _guard(
    () => _api.users(
      role: role,
      search: search,
      status: status,
      profileVerificationStatus: profileVerificationStatus,
    ),
  );

  @override
  Future<void> createStaff(Map<String, Object?> body) =>
      _guard(() => _api.createStaff(body));

  @override
  Future<void> suspendUser(int id) => _guard(() => _api.suspendUser(id));

  @override
  Future<void> reactivateUser(int id) => _guard(() => _api.reactivateUser(id));

  @override
  Future<List<AdminAgent>> agents() => _guard(_api.agents);

  @override
  Future<AdminAgent> createAiAgent(Map<String, Object?> body) =>
      _guard(() => _api.createAiAgent(body));

  @override
  Future<AdminAgent> updateAgent(int id, Map<String, Object?> body) =>
      _guard(() => _api.updateAgent(id, body));

  @override
  Future<PlatformSettings> settings() => _guard(_api.settings);

  @override
  Future<PlatformSettings> updateSettings(Map<String, Object?> fields) =>
      _guard(() => _api.updateSettings(fields));

  @override
  Future<Paginated<AdminAuditLog>> auditLogs({
    required int page,
    required int limit,
    String? entityType,
    int? entityId,
    int? actorUserId,
    int? actorAgentId,
    DateTime? from,
    DateTime? to,
  }) => _guard(
    () => _api.auditLogs(
      page: page,
      limit: limit,
      entityType: entityType,
      entityId: entityId,
      actorUserId: actorUserId,
      actorAgentId: actorAgentId,
      from: from,
      to: to,
    ),
  );

  @override
  Future<List<AdminAgency>> agencies() => _guard(_api.agencies);

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
