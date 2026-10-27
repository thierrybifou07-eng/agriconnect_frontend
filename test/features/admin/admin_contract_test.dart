import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';

dynamic fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync());

void main() {
  test('admin dashboard parses the aggregate stats contract', () {
    final stats = AdminStats.fromJson(fixture('admin_stats.json'));
    expect(stats.usersByRole['BUYER'], 12);
    expect(stats.ordersByStatus['COMPLETED'], 6);
    expect(stats.availableStock, 120.5);
    expect(stats.pendingCompensationsAmount, 1400);
    expect(stats.grossRevenue, 250000);
  });

  test('dashboard stats tolerate absent contract fields', () {
    final stats = AdminStats.fromJson({
      'usersByRole': {'BUYER': 2},
    });
    expect(stats.usersByRole, {'BUYER': 2});
    expect(stats.ordersByStatus, isEmpty);
    expect(stats.grossRevenue, 0);
  });

  test('admin user list is a raw array and includes account details', () {
    final users = (fixture('admin_users_array.json') as List)
        .map(AdminUser.fromJson)
        .toList();
    expect(users.single.id, 41);
    expect(users.single.role, 'BUYER');
    expect(users.single.emailVerified, isTrue);
    expect(users.single.createdAt, DateTime.utc(2026, 10, 25, 10, 30));
  });

  test(
    'settings and paginated audit contracts preserve read-only currency',
    () {
      final settings = PlatformSettings.fromJson(
        fixture('admin_settings.json'),
      );
      final audit = Paginated<AdminAuditLog>.fromJson(
        fixture('audit_logs_page.json'),
        AdminAuditLog.fromJson,
      );
      expect(settings.supplierCommissionRate, 0.15);
      expect(settings.currency, 'XAF');
      expect(audit.items, hasLength(2));
      expect(audit.items.first.actorLabel, 'Root Admin');
      expect(audit.items.last.actorLabel, 'Assistant IA');
      expect(audit.items.first.metadata['reason'], 'policy');
    },
  );

  test('agent contract parses both human and AI records', () {
    final agents = (fixture('admin_agents.json') as List)
        .map(AdminAgent.fromJson)
        .toList();
    expect(agents.first.capabilities, ['BUYER_SUPPORT', 'ORDER_PROCESSING']);
    expect(agents.first.userName, 'Awa Ndiaye');
    expect(agents.last.isAi, isTrue);
    expect(agents.last.userName, isNull);
  });
}
