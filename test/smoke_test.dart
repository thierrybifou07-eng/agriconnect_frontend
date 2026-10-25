import 'package:agri_connect/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/get_test_harness.dart';

void main() {
  setupGetTestHarness();

  testWidgets('the app starts on the splash route with missing config', (
    tester,
  ) async {
    await tester.pumpWidget(const AgriConnectApp());

    expect(find.text('Configuration manquante'), findsOneWidget);
  });
}
