import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/staff/presentation/pages/staff_pages.dart';

void main() {
  testWidgets('staff verification placeholder renders its empty state', (
    tester,
  ) async {
    final labels = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StaffVerificationsPage(),
      ),
    );
    expect(find.text(labels.staffNoData), findsOneWidget);
  });
}
