import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';

abstract interface class AdminRepository {
  Future<AdminStats> stats({DateTime? from, DateTime? to});
  Future<List<AdminUser>> users({
    String? role,
    String? search,
    String? status,
    String? profileVerificationStatus,
  });
  Future<void> createStaff(Map<String, Object?> body);
  Future<void> suspendUser(int id);
  Future<void> reactivateUser(int id);
  Future<List<AdminAgent>> agents();
  Future<AdminAgent> updateAgent(int id, Map<String, Object?> body);
  Future<PlatformSettings> settings();
  Future<PlatformSettings> updateSettings(Map<String, Object?> fields);
  Future<Paginated<AdminAuditLog>> auditLogs({
    required int page,
    required int limit,
    String? entityType,
    int? entityId,
    int? actorUserId,
    int? actorAgentId,
    DateTime? from,
    DateTime? to,
  });
  Future<List<AdminAgency>> agencies();
}
