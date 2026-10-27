import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_controllers.dart';
import 'package:agri_connect/features/admin/presentation/pages/admin_platform_page.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

import '../../support/get_test_harness.dart';
import '../auth/fake_auth_repository.dart';

void main() {
  setupGetTestHarness();

  testWidgets('ADMIN sees the settings action disabled with ROOT explanation', (
    tester,
  ) async {
    final labels = await AppLocalizations.delegate.load(const Locale('en'));
    final auth = AuthController(
      tokenStorage: InMemoryTokenStorage(),
      sessionEvents: SessionEvents(),
      repository: FakeAuthRepository(),
    )..setUser(const AuthUser(role: RoleCode.admin));
    Get.put<AuthController>(auth);
    Get.put(AdminPlatformController(repository: _SettingsRepository()));

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: AdminPlatformPanel()),
      ),
    );
    await tester.pumpAndSettle();

    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, labels.adminSave),
    );
    expect(save.onPressed, isNull);
    expect(find.text(labels.adminSettingsLocked), findsOneWidget);
  });
}

class _SettingsRepository implements AdminRepository {
  @override
  Future<PlatformSettings> settings() async => const PlatformSettings(
    supplierCommissionRate: 0.1,
    buyerFeeType: 'NONE',
    buyerFeeValue: 0,
    transportMarkupRate: 0.1,
    referralBuyerReward: 0,
    referralSupplierReward: 0,
    reservationHours: 24,
    expiryCompensationRate: 0,
    currency: 'XAF',
  );

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
  }) async => Paginated(items: const [], page: page, limit: limit, total: 0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
