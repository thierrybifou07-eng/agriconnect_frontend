import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/app/theme/app_theme.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/auth/presentation/pages/splash_page.dart';

const _onboardingKey = 'welcome_onboarding_completed_v1';
const _languageKey = 'welcome_language_code_v1';
const _roleKey = 'welcome_selected_role_v1';

void _setViewport(WidgetTester tester, double width, {double textScale = 1}) {
  const dpr = 2.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = Size(width, 800) * dpr;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
}

Future<void> _openApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(key: UniqueKey(), child: const AgriConnectApp()),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

Future<void> _settleRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump();
}

void main() {
  for (final width in [320.0, 360.0, 390.0, 412.0, 768.0, 1280.0]) {
    testWidgets(
      'welcome journey fits at ${width.toInt()}dp and preserves choices',
      (tester) async {
        _setViewport(tester, width);
        SharedPreferences.setMockInitialValues({});
        await _openApp(tester);

        expect(find.text('Passer'), findsOneWidget);
        expect(find.text('AgriConnect'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'onboarding $width dp');

        await tester.tap(find.text('Passer'));
        await _settleRoute(tester);
        expect(find.text('Choisissez votre langue'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'language $width dp');

        await tester.tap(find.text('Anglais'));
        await tester.pump();
        expect(find.text('What is your profile?'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'role $width dp');

        await tester.tap(find.text('Supplier'));
        await _settleRoute(tester);
        expect(find.text('Welcome back'), findsOneWidget);

        final preferences = await SharedPreferences.getInstance();
        expect(preferences.getBool(_onboardingKey), isTrue);
        expect(preferences.getString(_languageKey), 'en');
        expect(preferences.getString(_roleKey), 'supplier');
        expect(
          tester.takeException(),
          isNull,
          reason: 'login after onboarding $width dp',
        );
      },
    );
  }

  for (final width in [320.0, 390.0, 768.0]) {
    testWidgets('welcome screens support large text at ${width.toInt()}dp', (
      tester,
    ) async {
      _setViewport(tester, width, textScale: 1.8);
      SharedPreferences.setMockInitialValues({});
      await _openApp(tester);
      expect(find.text('Un marché agricole connecté'), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'large text onboarding $width dp',
      );

      SharedPreferences.setMockInitialValues({_onboardingKey: true});
      await _openApp(tester);
      expect(find.text('Choisissez votre langue'), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'large text language $width dp',
      );

      SharedPreferences.setMockInitialValues({
        _onboardingKey: true,
        _languageKey: 'fr',
      });
      await _openApp(tester);
      expect(find.text('Quel est votre profil ?'), findsOneWidget);
      expect(find.text('Fournisseur'), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'large text role $width dp',
      );
    });
  }

  testWidgets('branded splash fits supported widths and large text', (
    tester,
  ) async {
    for (final width in [320.0, 360.0, 390.0, 412.0, 768.0, 1280.0]) {
      for (final scale in [1.0, 1.8]) {
        _setViewport(tester, width, textScale: scale);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SplashPage(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('AgriConnect'), findsOneWidget);
        expect(
          tester.takeException(),
          isNull,
          reason: 'splash $width dp at text scale $scale',
        );
      }
    }
  });
}
