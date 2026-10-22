import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/app/theme/app_theme.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/buyer/application/buyer_cart_controller.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';
import 'package:agri_connect/features/buyer/presentation/pages/checkout_page.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_product_form_page.dart';

/// A Gboard with its suggestion strip is the worst realistic case for a form:
/// it eats roughly 40% of a compact phone.
const double _keyboard = 300;

/// Phone widths the brief asks for, from the smallest still-supported Android
/// handset to a large one.
const List<Size> _phones = [
  Size(320, 640),
  Size(360, 800),
  Size(390, 844),
  Size(412, 915),
];

void _usePhone(
  WidgetTester tester,
  Size logical, {
  double topInset = 24,
  double bottomInset = 34,
}) {
  const dpr = 3.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = logical * dpr;
  tester.view.padding = FakeViewPadding(
    top: topInset * dpr,
    bottom: bottomInset * dpr,
  );
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.view.resetPadding();
    tester.view.resetViewInsets();
  });
}

/// Raises the software keyboard the way Android does: a bottom view inset.
Future<void> _openKeyboard(WidgetTester tester) async {
  tester.view.viewInsets = FakeViewPadding(
    bottom: _keyboard * tester.view.devicePixelRatio,
  );
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump();
}

/// The area the user can actually see once the keyboard is up.
Rect _visible(WidgetTester tester) {
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  final top = tester.view.padding.top / tester.view.devicePixelRatio;
  final inset = tester.view.viewInsets.bottom / tester.view.devicePixelRatio;
  return Rect.fromLTRB(0, top, size.width, size.height - inset);
}

bool _fullyVisible(WidgetTester tester, Finder finder) {
  final target = tester.getRect(finder);
  final area = _visible(tester);
  return target.top >= area.top - 0.5 && target.bottom <= area.bottom + 0.5;
}

Future<void> _pumpSignedOut(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': 'fr',
    'welcome_selected_role_v1': UserRole.supplier.key,
  });
  await tester.pumpWidget(const ProviderScope(child: AgriConnectApp()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
}

Future<void> _pumpRole(WidgetTester tester, UserRole role) async {
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': 'fr',
    'welcome_selected_role_v1': role.key,
    // The shell layout is under audit, not the first-run welcome panel.
    'supplier_welcome_seen_v1': true,
    'buyer_welcome_seen_v1': true,
    'auth_user_v1': jsonEncode(
      AuthUser(
        id: 'u1',
        fullName: 'Awa Traoré',
        email: 'awa@agriconnect.app',
        role: role,
      ).toJson(),
    ),
  });
  await tester.pumpWidget(const ProviderScope(child: AgriConnectApp()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
}

/// The checkout only renders its form once the cart holds something, so the
/// audit seeds one line the way a real buyer session would arrive with it.
class _SeededCartController extends CartController {
  @override
  CartState build() => CartState(
    lines: [
      CartLine(
        quantity: 2,
        product: const BuyerProduct(
          id: 'p1',
          name: 'Mil',
          description: 'Mil jaune du Sahel, récolté cette saison.',
          price: 4500,
          stockQuantity: 40,
          unit: 'kg',
          category: CatalogCategory.cereals,
          location: 'Kati',
          sellerName: 'Awa Traoré',
        ),
      ),
    ],
  );
}

/// Hosts a single form outside the router, with the same theme and localizations
/// the app uses, so a form can be judged on its own layout.
Future<void> _pumpForm(WidgetTester tester, Widget child) async {
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': 'fr',
    'welcome_selected_role_v1': UserRole.supplier.key,
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cartControllerProvider.overrideWith(_SeededCartController.new),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
}

/// With the keyboard up, nothing may overflow and every control a user has to
/// reach must be bringable into the visible band by scrolling.
Future<List<String>> _auditWithKeyboard(
  WidgetTester tester,
  String screen,
  List<({String what, Finder finder})> controls,
) async {
  final findings = <String>[];

  await _openKeyboard(tester);

  final overflow = tester.takeException();
  if (overflow != null) {
    findings.add('$screen: $overflow');
  }

  for (final control in controls) {
    if (control.finder.evaluate().isEmpty) {
      findings.add('$screen: ${control.what} is missing from the screen');
      continue;
    }
    try {
      await tester.ensureVisible(control.finder);
      await _settle(tester);
    } on Object catch (error) {
      findings.add('$screen: ${control.what} cannot be scrolled to ($error)');
      continue;
    }
    if (!_fullyVisible(tester, control.finder)) {
      findings.add(
        '$screen: ${control.what} stays behind the keyboard '
        '(rect ${tester.getRect(control.finder)}, visible ${_visible(tester)})',
      );
    }
  }

  return findings;
}

List<({String what, Finder finder})> _formControls({
  required int fields,
  Finder? submit,
}) {
  return [
    for (var i = 0; i < fields; i++)
      (what: 'field $i', finder: find.byType(TextFormField).at(i)),
    if (submit != null) (what: 'submit button', finder: submit),
  ];
}

/// Walks into the shell section [index] the way a thumb does.
Future<void> _openSection(WidgetTester tester, int index) async {
  final destinations = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.byType(NavigationDestination),
  );
  await tester.tap(destinations.at(index), warnIfMissed: false);
  await _settle(tester);
}

/// Opens the first conversation of the inbox, the way a tap does: the supplier
/// shell reaches Messages from the dashboard quick actions, not from its
/// navigation bar, which carries the profile instead.
Future<void> _openConversation(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Messages'));
  await _settle(tester);
  await tester.tap(find.text('Messages'), warnIfMissed: false);
  await _settle(tester);

  final tile = find
      .descendant(of: find.byType(ListView), matching: find.byType(InkWell))
      .first;
  await tester.ensureVisible(tile);
  await _settle(tester);
  await tester.tap(tile, warnIfMissed: false);
  await _settle(tester);
}

void main() {
  for (final phone in _phones) {
    final tag = '${phone.width.round()}x${phone.height.round()}';

    testWidgets('KEYBOARD login on $tag', (tester) async {
      _usePhone(tester, phone);
      await _pumpSignedOut(tester);

      final findings = await _auditWithKeyboard(
        tester,
        'login',
        _formControls(fields: 2, submit: find.text('Se connecter')),
      );
      expect(findings, isEmpty, reason: findings.join('\n'));
    });

    testWidgets('KEYBOARD register on $tag', (tester) async {
      _usePhone(tester, phone);
      await _pumpSignedOut(tester);

      await tester.ensureVisible(find.text('Créer un compte'));
      await _settle(tester);
      await tester.tap(find.text('Créer un compte'));
      await _settle(tester);

      final findings = await _auditWithKeyboard(
        tester,
        'register',
        _formControls(fields: 4, submit: find.text('Créer mon compte')),
      );
      expect(findings, isEmpty, reason: findings.join('\n'));
    });

    testWidgets('KEYBOARD supplier product form on $tag', (tester) async {
      _usePhone(tester, phone);
      await _pumpForm(tester, const SupplierProductFormPage());

      final findings = await _auditWithKeyboard(
        tester,
        'supplier product form',
        _formControls(fields: 4, submit: find.text('Soumettre la déclaration')),
      );
      expect(findings, isEmpty, reason: findings.join('\n'));
    });

    testWidgets('KEYBOARD buyer checkout on $tag', (tester) async {
      _usePhone(tester, phone);
      await _pumpForm(tester, const CheckoutPage());

      final findings = await _auditWithKeyboard(
        tester,
        'buyer checkout',
        _formControls(fields: 3, submit: find.text('Passer la commande')),
      );
      expect(findings, isEmpty, reason: findings.join('\n'));
    });

    testWidgets('KEYBOARD supplier product search on $tag', (tester) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.supplier);
      await _openSection(tester, 1);

      final findings = await _auditWithKeyboard(
        tester,
        'supplier product search',
        [(what: 'search field', finder: find.byType(TextField))],
      );
      expect(findings, isEmpty, reason: findings.join('\n'));
    });

    testWidgets('KEYBOARD supplier order search on $tag', (tester) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.supplier);
      await _openSection(tester, 2);

      final findings = await _auditWithKeyboard(
        tester,
        'supplier order search',
        [(what: 'search field', finder: find.byType(TextField))],
      );
      expect(findings, isEmpty, reason: findings.join('\n'));
    });

    testWidgets('KEYBOARD buyer catalog search on $tag', (tester) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.buyer);
      await _openSection(tester, 1);

      final findings = await _auditWithKeyboard(
        tester,
        'buyer catalog search',
        [(what: 'search field', finder: find.byType(TextField))],
      );
      expect(findings, isEmpty, reason: findings.join('\n'));
    });

    testWidgets('KEYBOARD admin search fields on $tag', (tester) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.admin);

      final findings = <String>[];
      for (final section in const [1, 2, 3]) {
        await _openSection(tester, section);
        final error = tester.takeException();
        if (error != null) {
          findings.add('admin section $section: $error');
        }
      }
      expect(findings, isEmpty, reason: findings.join('\n'));
    });

    testWidgets('KEYBOARD chat composer on $tag', (tester) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.supplier);
      await _openConversation(tester);

      final findings = await _auditWithKeyboard(tester, 'chat composer', [
        (what: 'composer field', finder: find.byType(TextField)),
        (what: 'send button', finder: find.byTooltip('Envoyer')),
      ]);
      expect(findings, isEmpty, reason: findings.join('\n'));
    });
  }

  testWidgets('CHAT composer sends a message and clears itself', (
    tester,
  ) async {
    _usePhone(tester, const Size(360, 800));
    await _pumpRole(tester, UserRole.supplier);
    await _openConversation(tester);

    final composer = find.byType(TextField);
    await tester.tap(composer);
    await _openKeyboard(tester);

    await tester.enterText(composer, 'Bonjour, la récolte est prête.');
    await _settle(tester);

    final send = find.byTooltip('Envoyer');
    await tester.ensureVisible(send);
    await _settle(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(send);
    // The demo repository holds the send for 350 ms before echoing it back.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // The draft is cleared, so the next message starts from a clean composer.
    expect(
      tester.widget<TextField>(composer).controller?.text,
      isEmpty,
      reason: 'the composer must be emptied once the message is sent',
    );
    // And the message is now part of the thread.
    expect(find.text('Bonjour, la récolte est prête.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
