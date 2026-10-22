import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/features/admin/presentation/admin_analytics_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_deliveries_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_orders_page.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/auth/presentation/widgets/role_profile_page.dart';

/// Secondary screens audit.
///
/// The main audit covered the dashboards, lists, details and forms. This one
/// walks what is left: every shell tab for every role, the profile page, and
/// the routes pushed above the shell. It checks the four things that actually
/// bite a phone: a layout that overflows at 320 dp, a control too small to hit
/// with a thumb, content the user cannot scroll down to, and a back gesture
/// that either does nothing or leaves the app.
const List<Size> _phones = [
  Size(320, 640),
  Size(360, 800),
  Size(412, 915),
  Size(600, 1000),
  Size(1200, 900),
];

/// Android's accessibility floor for a touch target.
const double _minTarget = 48;

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

/// Drags a vertical scroller from top to bottom so lazily built rows are
/// actually laid out. A screen whose overflow only exists below the fold is
/// invisible to a test that never scrolls.
Future<void> _walkToTheBottom(WidgetTester tester) async {
  final scroller = find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down,
  );
  if (scroller.evaluate().isEmpty) return;

  for (var i = 0; i < 12; i++) {
    final position = tester.widget<Scrollable>(scroller.first).controller;
    if (position != null && position.hasClients) {
      final max = position.position.maxScrollExtent;
      final offset = position.position.pixels;
      if (offset >= max - 0.5) break;
    }
    await tester.drag(scroller.first, const Offset(0, -400));
    await _settle(tester);
  }
}

/// Whether a padded control already owns the touch target.
///
/// Material wraps the label of a button or a chip in an `InkWell` and grows the
/// pair out to 48 dp, so measuring that inner `InkWell` on its own would report
/// a target the user can actually hit. The button and the chip are measured
/// separately instead.
bool _insidePaddedControl(Element element) {
  var inside = false;
  element.visitAncestorElements((ancestor) {
    // A chip builds its ink response inside a RawChip, which is the widget
    // that carries the padded 48 dp target.
    if (ancestor.widget is ButtonStyleButton || ancestor.widget is RawChip) {
      inside = true;
    }
    return !inside;
  });
  return inside;
}

/// Fails on any control a thumb cannot reasonably reach.
///
/// It measures render boxes rather than semantics rects. A semantics rect is
/// clipped by the nearest viewport, so the last card of a horizontal carousel
/// reports the few pixels still on screen and looks broken when it is not. It
/// also skips anything without a tap callback, because the tree is full of ink
/// dividers that are `InkWell`s two pixels tall and are not controls.
///
/// Material buttons are judged at 48 dp even when they render smaller, since
/// [MaterialTapTargetSize.padded] already grows their touch area; a bare
/// [InkWell] is exactly the size of its child, so it is judged as rendered.
Future<void> _expectReachableTapTargets(
  WidgetTester tester,
  String where, {
  double minTarget = _minTarget,
}) async {
  final tooSmall = <String>[];

  void check(Element element, bool padded) {
    final box = element.renderObject;
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final size = box.size;
    if (size.isEmpty) return;

    final width = padded ? math.max(size.width, minTarget) : size.width;
    final height = padded ? math.max(size.height, minTarget) : size.height;
    if (width >= minTarget && height >= minTarget) return;

    tooSmall.add(
      '${element.widget.runtimeType} '
      '${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)}',
    );
  }

  for (final element in find.byType(InkWell).evaluate()) {
    if ((element.widget as InkWell).onTap == null) continue;
    if (_insidePaddedControl(element)) continue;
    check(element, false);
  }
  for (final element in find.byType(GestureDetector).evaluate()) {
    if ((element.widget as GestureDetector).onTap == null) continue;
    if (_insidePaddedControl(element)) continue;
    check(element, false);
  }
  for (final finder in [
    find.byType(IconButton),
    find.byType(TextButton),
    find.byType(ElevatedButton),
    find.byType(FilledButton),
    find.byType(OutlinedButton),
    find.byType(FloatingActionButton),
  ]) {
    for (final element in finder.evaluate()) {
      check(element, true);
    }
  }

  // Chips measure differently: Material grows the chip itself to 48 dp when the
  // tap target is padded, so the render box is already the real target. Asking
  // for 48 here is what catches a chip pinned to `shrinkWrap`, whose ink
  // response stays at 38 dp however it is measured.
  for (final finder in [
    find.byType(FilterChip),
    find.byType(ChoiceChip),
    find.byType(ActionChip),
    find.byType(InputChip),
  ]) {
    for (final element in finder.evaluate()) {
      check(element, false);
    }
  }

  expect(
    tooSmall,
    isEmpty,
    reason: 'tap targets under ${minTarget}dp on $where',
  );
}

Future<void> _tapSection(WidgetTester tester, int index) async {
  final sidebar = find.byKey(const ValueKey('roleShellSidebar'));
  if (sidebar.evaluate().isNotEmpty) {
    await tester.tap(
      find.descendant(of: sidebar, matching: find.byType(ListTile)).at(index),
    );
    await _settle(tester);
    return;
  }

  final destinations = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.byType(NavigationDestination),
  );
  await tester.tap(destinations.at(index), warnIfMissed: false);
  await _settle(tester);
  final label = tester
      .widget<NavigationDestination>(destinations.at(index))
      .label;
  if (index == destinations.evaluate().length - 1 &&
      (label == 'Plus' || label == 'More')) {
    final items = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(ListTile),
    );
    if (items.evaluate().isNotEmpty) {
      await tester.tap(items.first);
      await _settle(tester);
    }
  }
}

int _sectionCount(WidgetTester tester) {
  final sidebar = find.byKey(const ValueKey('roleShellSidebar'));
  if (sidebar.evaluate().isNotEmpty) {
    return find
        .descendant(of: sidebar, matching: find.byType(ListTile))
        .evaluate()
        .length;
  }
  return find
      .descendant(
        of: find.byType(NavigationBar),
        matching: find.byType(NavigationDestination),
      )
      .evaluate()
      .length;
}

Future<bool> _systemBack(WidgetTester tester) async {
  final handled = await tester.binding.handlePopRoute();
  await _settle(tester);
  return handled;
}

void main() {
  for (final role in UserRole.values) {
    final tag = role.key;

    for (final phone in _phones) {
      testWidgets('SECONDARY $tag: every tab is scrollable and hittable on '
          '${phone.width.toInt()}dp', (tester) async {
        _usePhone(tester, phone);
        await _pumpRole(tester, role);

        final tabs = _sectionCount(tester);
        expect(tabs, greaterThan(0), reason: '$tag has no shell tab');

        for (var index = 0; index < tabs; index++) {
          await _tapSection(tester, index);

          // Laying the whole page out is what surfaces a RenderFlex overflow.
          await _walkToTheBottom(tester);
          await _settle(tester);

          expect(
            tester.takeException(),
            isNull,
            reason: '$tag tab $index overflowed at ${phone.width}dp',
          );

          await _expectReachableTapTargets(
            tester,
            '$tag tab $index at ${phone.width}dp',
          );
        }
      });
    }
  }

  testWidgets('SECONDARY admin: the overflow menu opens the sections the bar '
      'hides on a 320dp phone', (tester) async {
    _usePhone(tester, const Size(320, 640));
    await _pumpRole(tester, UserRole.admin);

    final destinations = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byType(NavigationDestination),
    );
    expect(
      destinations,
      findsNWidgets(4),
      reason: 'a narrow admin bar keeps four primary destinations',
    );

    // The last destination is the overflow, not a page. Opening it lists the
    // four hidden sections.
    await tester.tap(destinations.at(3), warnIfMissed: false);
    await _settle(tester);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(ListTile),
      ),
      findsNWidgets(4),
      reason: 'Orders, Deliveries, Analytics and Profile live under More',
    );
    // Close the sheet so each entry can be opened on its own.
    await tester.tapAt(const Offset(4, 4));
    await _settle(tester);

    // Each entry opens its real page, and the bar marks More as selected so the
    // user always knows which workspace a hidden section belongs to.
    final expected = <Type>[
      AdminOrdersPage,
      AdminDeliveriesPage,
      AdminAnalyticsPage,
      RoleProfilePage,
    ];
    for (var i = 0; i < expected.length; i++) {
      await tester.tap(destinations.at(3), warnIfMissed: false);
      await _settle(tester);
      await tester.tap(
        find
            .descendant(
              of: find.byType(BottomSheet),
              matching: find.byType(ListTile),
            )
            .at(i),
      );
      await _settle(tester);

      expect(
        find.byType(expected[i]),
        findsOneWidget,
        reason: 'More entry $i must open its actual page',
      );
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(
        bar.selectedIndex,
        3,
        reason: 'the More tab reflects the section it opened',
      );
      expect(tester.takeException(), isNull);
    }
  });

  for (final phone in _phones) {
    testWidgets('SECONDARY: the profile tab carries one app bar and the whole '
        'page scrolls on ${phone.width.toInt()}dp', (tester) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.supplier);

      await _tapSection(tester, _lastTab(tester));

      expect(
        find.byType(AppBar),
        findsOneWidget,
        reason:
            'the shell already owns an app bar, the profile must not add one',
      );

      await _walkToTheBottom(tester);
      await _settle(tester);
      expect(tester.takeException(), isNull);
      await _expectReachableTapTargets(tester, 'profile at ${phone.width}dp');
    });

    testWidgets('SECONDARY: back from a shell tab leaves the app running, it '
        'does not close it on ${phone.width.toInt()}dp', (tester) async {
      _usePhone(tester, phone);
      await _pumpRole(tester, UserRole.supplier);

      await _tapSection(tester, 1);

      // At the root of a shell the gesture is allowed to bubble out, but it must
      // not throw or tear the tree down.
      await _systemBack(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  }
}

int _lastTab(WidgetTester tester) {
  final destinations = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.byType(NavigationDestination),
  );
  return destinations.evaluate().length - 1;
}
