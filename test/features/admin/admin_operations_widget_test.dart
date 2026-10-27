import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/features/admin/presentation/pages/admin_operations_page.dart';

void main() {
  testWidgets('compensation account number is masked until revealed', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminMaskedAccountNumber(
            label: 'Compte de paiement',
            accountNumber: '690123456',
            showLabel: 'Afficher',
            hideLabel: 'Masquer',
          ),
        ),
      ),
    );

    expect(find.text('Compte de paiement: •••••3456'), findsOneWidget);
    expect(find.textContaining('690123456'), findsNothing);
    await tester.tap(find.text('Afficher'));
    await tester.pump();
    expect(find.text('Compte de paiement: 690123456'), findsOneWidget);
  });
}
