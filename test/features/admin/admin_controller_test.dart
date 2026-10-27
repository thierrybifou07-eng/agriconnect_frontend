import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_controllers.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

dynamic fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync());

class _AdminRepository implements AdminRepository {
  ApiFailure? createFailure;
  final List<Map<String, Object?>> agentBodies = [];
  final List<Map<String, Object?>> settingBodies = [];
  final List<int> suspendedIds = [];
  int userListCalls = 0;

  @override
  Future<AdminStats> stats({DateTime? from, DateTime? to}) async =>
      AdminStats.fromJson(fixture('admin_stats.json'));

  @override
  Future<List<AdminUser>> users({
    String? role,
    String? search,
    String? status,
    String? profileVerificationStatus,
  }) async {
    userListCalls++;
    return (fixture('admin_users_array.json') as List)
        .map(AdminUser.fromJson)
        .toList();
  }

  @override
  Future<void> createStaff(Map<String, Object?> body) async {
    if (createFailure != null) throw createFailure!;
  }

  @override
  Future<void> suspendUser(int id) async => suspendedIds.add(id);

  @override
  Future<void> reactivateUser(int id) async {}

  @override
  Future<List<AdminAgent>> agents() async =>
      (fixture('admin_agents.json') as List).map(AdminAgent.fromJson).toList();

  @override
  Future<AdminAgent> updateAgent(int id, Map<String, Object?> body) async {
    agentBodies.add(body);
    return AdminAgent.fromJson((fixture('admin_agents.json') as List).first);
  }

  @override
  Future<PlatformSettings> settings() async =>
      PlatformSettings.fromJson(fixture('admin_settings.json'));

  @override
  Future<PlatformSettings> updateSettings(Map<String, Object?> fields) async {
    settingBodies.add(fields);
    return PlatformSettings.fromJson(fixture('admin_settings.json'));
  }

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
  }) async => Paginated<AdminAuditLog>.fromJson(
    fixture('audit_logs_page.json'),
    AdminAuditLog.fromJson,
  );

  @override
  Future<List<AdminAgency>> agencies() async => const [
    AdminAgency(id: 1, name: 'Agence Centre'),
  ];
}

void main() {
  late _AdminRepository repository;

  setUp(() => repository = _AdminRepository());

  test(
    'ADMIN staff creation denial is exposed as an API failure state',
    () async {
      repository.createFailure = const ApiFailure(
        status: 403,
        code: 'FORBIDDEN',
        message: 'Réservé au compte ROOT',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
      final controller = AdminUsersController(repository: repository);
      final created = await controller.createStaff({
        'role': 'ADMIN',
        'firstname': 'Admin',
        'lastname': 'Test',
      });
      expect(created, isFalse);
      expect(controller.actionState.value, isA<Failure<void>>());
      expect(
        (controller.actionState.value as Failure<void>).failure.message,
        'Réservé au compte ROOT',
      );
    },
  );

  test(
    'agent updates always send the complete deduplicated capability list',
    () async {
      final controller = AdminAgentsController(repository: repository);
      final agent = AdminAgent.fromJson(
        (fixture('admin_agents.json') as List).first,
      );
      await controller.updateAgent(
        agent,
        displayName: 'Équipe',
        isActive: true,
        capabilities: [...adminCapabilities, adminCapabilities.first],
        autonomy: null,
      );
      expect(repository.agentBodies.single['capabilities'], adminCapabilities);
      expect(repository.agentBodies.single['autonomy'], isNull);
    },
  );

  test(
    'ROOT settings payload sends fractions and never sends currency',
    () async {
      expect(canEditPlatformSettings(RoleCode.admin), isFalse);
      expect(canEditPlatformSettings(RoleCode.root), isTrue);
      final fields = platformSettingsPatch(
        supplierCommissionPercent: 15,
        buyerFeeType: 'PERCENT',
        buyerFeeValue: 2.5,
        transportMarkupPercent: 10,
        referralBuyerReward: 500,
        referralSupplierReward: 700,
        reservationHours: 24,
        expiryCompensationPercent: 20,
      );
      final controller = AdminPlatformController(repository: repository);
      expect(await controller.saveSettings(fields), isTrue);
      expect(repository.settingBodies.single['supplierCommissionRate'], 0.15);
      expect(repository.settingBodies.single['buyerFeeValue'], 0.025);
      expect(repository.settingBodies.single['transportMarkupRate'], 0.1);
      expect(repository.settingBodies.single['expiryCompensationRate'], 0.2);
      expect(repository.settingBodies.single.containsKey('currency'), isFalse);
    },
  );

  test('suspending a user reloads the non-paginated user list', () async {
    final controller = AdminUsersController(repository: repository);
    await controller.load();
    final initialCalls = repository.userListCalls;
    final user = AdminUser.fromJson(
      (fixture('admin_users_array.json') as List).single,
    );
    expect(await controller.setSuspended(user, suspend: true), isTrue);
    expect(repository.suspendedIds, [41]);
    expect(repository.userListCalls, initialCalls + 1);
  });
}
