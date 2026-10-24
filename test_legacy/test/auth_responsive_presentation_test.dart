import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';

const _widths = [320.0, 360.0, 390.0, 412.0, 768.0, 1280.0];

void _useSize(WidgetTester tester, double width, {double textScale = 1}) {
  const dpr = 2.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = Size(width, 800) * dpr;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

Future<void> _openLogin(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': 'fr',
    'welcome_selected_role_v1': 'supplier',
  });
  await tester.pumpWidget(const ProviderScope(child: AgriConnectApp()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

void main() {
  for (final width in _widths) {
    testWidgets('login presentation fits at ${width.toInt()}dp', (
      tester,
    ) async {
      _useSize(tester, width);
      await _openLogin(tester);

      expect(find.text('Bon retour parmi nous'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('agent@agriconnect.app'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [320.0, 390.0, 768.0, 1280.0]) {
    testWidgets('registration presentation fits at ${width.toInt()}dp', (
      tester,
    ) async {
      _useSize(tester, width);
      await _openLogin(tester);

      await tester.ensureVisible(find.text('Créer un compte'));
      await tester.tap(find.text('Créer un compte'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Créer votre compte'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('login keeps the password visibility control accessible', (
    tester,
  ) async {
    _useSize(tester, 390);
    await _openLogin(tester);

    final passwordField = find.byType(EditableText).at(1);
    expect(tester.widget<EditableText>(passwordField).obscureText, isTrue);
    await tester.tap(find.byTooltip('Afficher le mot de passe'));
    await tester.pump();
    expect(tester.widget<EditableText>(passwordField).obscureText, isFalse);
  });
}
