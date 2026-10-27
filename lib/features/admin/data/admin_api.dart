import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';

class AdminApi {
  const AdminApi(this._client);

  final ApiClient _client;

  Future<AdminStats> stats({DateTime? from, DateTime? to}) async =>
      AdminStats.fromJson(
        await _client.get(
          'admin/stats',
          query: {
            'from': ?from?.toUtc().toIso8601String(),
            'to': ?to?.toUtc().toIso8601String(),
          },
        ),
      );

  Future<List<AdminUser>> users({
    String? role,
    String? search,
    String? status,
    String? profileVerificationStatus,
  }) async {
    final response = await _client.get(
      'admin/users',
      query: {
        'role': ?role,
        'search': ?_nonEmpty(search),
        'status': ?status,
        'profileVerificationStatus': ?profileVerificationStatus,
      },
    );
    if (response is! List) {
      throw const FormatException('Expected admin user list');
    }
    return List.unmodifiable(response.map(AdminUser.fromJson));
  }

  Future<void> createStaff(Map<String, Object?> body) async {
    await _client.post('admin/users', data: body);
  }

  Future<void> suspendUser(int id) async {
    await _client.patch('admin/users/$id/suspend');
  }

  Future<void> reactivateUser(int id) async {
    await _client.patch('admin/users/$id/reactivate');
  }

  Future<List<AdminAgent>> agents() async {
    final response = await _client.get('admin/agents');
    if (response is! List) {
      throw const FormatException('Expected admin agent list');
    }
    return List.unmodifiable(response.map(AdminAgent.fromJson));
  }

  Future<AdminAgent> createAiAgent(Map<String, Object?> body) async =>
      AdminAgent.fromJson(await _client.post('admin/agents/ai', data: body));

  Future<AdminAgent> updateAgent(int id, Map<String, Object?> body) async =>
      AdminAgent.fromJson(await _client.patch('admin/agents/$id', data: body));

  Future<PlatformSettings> settings() async =>
      PlatformSettings.fromJson(await _client.get('admin/settings'));

  Future<PlatformSettings> updateSettings(Map<String, Object?> fields) async =>
      PlatformSettings.fromJson(
        await _client.patch('admin/settings', data: fields),
      );

  Future<Paginated<AdminAuditLog>> auditLogs({
    required int page,
    required int limit,
    String? entityType,
    int? entityId,
    int? actorUserId,
    int? actorAgentId,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _client.get(
      'admin/audit-logs',
      query: {
        'page': page,
        'limit': limit,
        'entityType': ?_nonEmpty(entityType),
        'entityId': ?entityId,
        'actorUserId': ?actorUserId,
        'actorAgentId': ?actorAgentId,
        'from': ?from?.toUtc().toIso8601String(),
        'to': ?to?.toUtc().toIso8601String(),
      },
    );
    if (response is! Map) {
      throw const FormatException('Expected paginated audit log response');
    }
    return Paginated<AdminAuditLog>.fromJson(
      Map<String, dynamic>.from(response),
      AdminAuditLog.fromJson,
    );
  }

  Future<List<AdminAgency>> agencies() async {
    const limit = 100;
    var page = 1;
    final agencies = <AdminAgency>[];
    while (true) {
      final response = await _client.get(
        'admin/agencies',
        query: {'active': true, 'page': page, 'limit': limit},
      );
      if (response is! Map) {
        throw const FormatException('Expected paginated agency response');
      }
      final parsed = Paginated<AdminAgency>.fromJson(
        Map<String, dynamic>.from(response),
        AdminAgency.fromJson,
      );
      agencies.addAll(parsed.items);
      if (!parsed.hasMore) return List.unmodifiable(agencies);
      page++;
    }
  }
}

String? _nonEmpty(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
