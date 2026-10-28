import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';
import 'package:agri_connect/features/supplier/presentation/controllers/lot_draft_controller.dart';
import 'package:agri_connect/features/supplier/presentation/pages/lot_draft_page.dart';
import 'package:agri_connect/features/supplier/presentation/widgets/supplier_widgets.dart';

import '../../support/get_test_harness.dart';

void main() {
  setupGetTestHarness();

  testWidgets('lot status badge uses localized lifecycle label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SupplierLotStatusBadge(status: LotStatus.pendingValidation),
        ),
      ),
    );

    expect(find.text('Awaiting validation'), findsOneWidget);
  });

  testWidgets('lot declaration screen starts on the product step', (
    tester,
  ) async {
    Get.put<ReferenceRepository>(_ReferenceRepository());
    Get.put(LotDraftController(repository: _SupplierRepository()));

    await tester.pumpWidget(
      GetMaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LotDraftPage(),
      ),
    );

    expect(find.text('Declare a lot'), findsOneWidget);
    expect(find.text('Product'), findsNWidgets(2));
    expect(find.text('Next'), findsOneWidget);
  });
}

class _ReferenceRepository implements ReferenceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SupplierRepository implements SupplierRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
