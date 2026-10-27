import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_repository.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_workflow_controllers.dart';
import 'package:agri_connect/features/staff/presentation/pages/staff_workflow_pages.dart';

void main() {
  setUp(Get.reset);
  tearDown(Get.reset);

  testWidgets('staff verification queue renders its empty state', (
    tester,
  ) async {
    final labels = await AppLocalizations.delegate.load(const Locale('en'));
    Get.put(
      StaffVerificationsController(repository: _EmptyWorkflowRepository()),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StaffVerificationsPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(labels.staffNoVerifications), findsOneWidget);
  });
}

class _EmptyWorkflowRepository implements StaffWorkflowRepository {
  @override
  Future<Paginated<StaffVerification>> verifications({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
    String? role,
    int? userId,
  }) async => Paginated(items: const [], page: page, limit: limit, total: 0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
