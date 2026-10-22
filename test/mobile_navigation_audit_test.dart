import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

/// Phones the audit walks. A 320dp handset is the tightest layout the app
/// claims to support, the others are the common Android sizes.
const List<Size> _phones = [Size(320, 640), Size(360, 800), Size(412, 915)];

void _usePhone(WidgetTester tester, Size logical) {
  const dpr = 3.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = logical * dpr;
  tester.view.padding = FakeViewPadding(top: 24 * dpr, bottom: 34 * dpr);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.view.resetPadding();
  });
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
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

/// The shell pages carry the bottom navigation; the routes pushed above the
/// shell (details, forms, chat) do not.
bool _inShell(WidgetTester tester) =>
    find.byType(NavigationBar).evaluate().isNotEmpty;

Future<void> _tapSection(WidgetTester tester, int index) async {
  final destinations = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.byType(NavigationDestination),
  );
  await tester.tap(destinations.at(index), warnIfMissed: false);
  await _settle(tester);
}

/// Presses the Android system back button, the way the gesture bar does.
/// Returns whether the navigator consumed it, which is exactly what decides
/// whether the app closes or goes back one screen.
Future<bool> _systemBack(WidgetTester tester) async {
  final handled = await tester.binding.handlePopRoute();
  await _settle(tester);
  return handled;
}

/// Scrolls the page the way a thumb does until [finder] has an element.
///
/// The orders list starts with a tall overview block, so on the shortest
/// handset it fills the first screen on its own and the first order sits below
/// the fold. That is a scroll, not a failure.
Future<void> _scrollUntilVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) return;

  // Only a vertical scroller can bring a below-the-fold target into view.
  // Dashboards built from a plain Column have none, and need no scrolling.
  final vertical = find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down,
  );
  if (vertical.evaluate().isEmpty) {
    expect(finder, findsWidgets, reason: 'the screen never showed the target');
    return;
  }

  for (var i = 0; i < 8; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.drag(vertical.first, const Offset(0, -260));
    await _settle(tester);
  }
  expect(finder, findsWidgets, reason: 'scrolling never showed the target');
}

Future<void> _tapFirst(WidgetTester tester, Finder finder) async {
  await _scrollUntilVisible(tester, finder);
  await tester.ensureVisible(finder.first);
  await _settle(tester);
  await tester.tap(finder.first, warnIfMissed: false);
  await _settle(tester);
}

void main() {
  for (final phone in _phones) {
    final tag = '${phone.width.round()}x${phone.height.round()}';

    testWidgets(
      'NAV supplier: list -> detail -> edit -> back keeps a stack on $tag',
      (tester) async {
        _usePhone(tester, phone);
        await _pumpRole(tester, UserRole.supplier);

        await _tapSection(tester, 1);
        expect(
          _inShell(tester),
          isTrue,
          reason: 'the products tab is a shell page',
        );

        // List -> detail
        await _tapFirst(tester, find.byType(Card));
        expect(
          _inShell(tester),
          isFalse,
          reason: 'the product detail is pushed over the shell',
        );

        // Detail -> edit form
        final edit = find.byIcon(Icons.edit_outlined).first;
        await tester.tap(edit);
        await _settle(tester);

        // System back from the form must return to the detail, not to the list.
        final handled = await _systemBack(tester);
        expect(
          handled,
          isTrue,
          reason: 'the edit form must be poppable so the system back works',
        );
        expect(
          find.byIcon(Icons.edit_outlined),
          findsWidgets,
          reason: 'back from the edit form returns to the product detail',
        );

        // System back from the detail must return to the list.
        final handledAgain = await _systemBack(tester);
        expect(
          handledAgain,
          isTrue,
          reason: 'the product detail must be poppable back to the list',
        );
        expect(
          _inShell(tester),
          isTrue,
          reason: 'back from the detail lands on the products tab again',
        );
      },
    );

    testWidgets('NAV supplier: dashboard -> messages -> conversation on $tag', (
      tester,
    ) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.supplier);

      await _tapFirst(tester, find.text('Messages'));
      expect(
        _inShell(tester),
        isFalse,
        reason: 'the inbox is pushed over the shell',
      );

      final conversation = find
          .descendant(of: find.byType(ListView), matching: find.byType(InkWell))
          .first;
      await _tapFirst(tester, conversation);

      expect(
        find.byType(TextField),
        findsOneWidget,
        reason: 'the conversation shows its composer',
      );

      expect(await _systemBack(tester), isTrue);
      expect(
        find.byType(TextField),
        findsNothing,
        reason: 'back from a conversation returns to the inbox',
      );
      expect(await _systemBack(tester), isTrue);
      expect(
        _inShell(tester),
        isTrue,
        reason: 'back from the inbox returns to the shell',
      );
    });

    testWidgets('NAV supplier: orders -> order detail -> back on $tag', (
      tester,
    ) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.supplier);

      await _tapSection(tester, 2);
      await _tapFirst(tester, find.byType(Card));

      expect(_inShell(tester), isFalse, reason: 'the order detail is pushed');
      expect(
        await _systemBack(tester),
        isTrue,
        reason: 'the order detail must be poppable back to the orders tab',
      );
      expect(_inShell(tester), isTrue);
    });

    testWidgets('NAV driver: deliveries -> detail -> back on $tag', (
      tester,
    ) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.driver);

      await _tapSection(tester, 1);
      await _tapFirst(tester, find.byType(Card));

      expect(
        _inShell(tester),
        isFalse,
        reason: 'the delivery detail is pushed',
      );
      expect(
        await _systemBack(tester),
        isTrue,
        reason:
            'the delivery detail must be poppable back to the deliveries tab',
      );
      expect(_inShell(tester), isTrue);
    });

    testWidgets('NAV buyer: catalog -> product detail -> back on $tag', (
      tester,
    ) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.buyer);

      await _tapSection(tester, 1);
      await _tapFirst(tester, find.byType(Card));

      expect(_inShell(tester), isFalse, reason: 'the product detail is pushed');
      expect(
        await _systemBack(tester),
        isTrue,
        reason: 'the product detail must be poppable back to the catalog',
      );
      expect(_inShell(tester), isTrue);
    });

    testWidgets('NAV shell: the profile tab keeps a single app bar on $tag', (
      tester,
    ) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.supplier);

      await _tapSection(tester, 3);
      expect(_inShell(tester), isTrue);
      expect(
        find.byType(AppBar),
        findsOneWidget,
        reason: 'the shell owns the only app bar of a tab',
      );
      expect(tester.takeException(), isNull);
    });
  }
}
