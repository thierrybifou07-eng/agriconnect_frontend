import 'package:agri_connect/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the app starts and displays the migration message', (
    tester,
  ) async {
    await tester.pumpWidget(const AgriConnectApp());

    expect(find.text('AgriConnect — migration en cours'), findsOneWidget);
  });
}
