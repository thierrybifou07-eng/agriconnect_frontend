import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/super_admin/application/super_admin_providers.dart';
import 'package:agri_connect/features/super_admin/domain/staff_account.dart';
import 'package:agri_connect/features/super_admin/domain/staff_permission.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/super_admin_dashboard_skeleton.dart';
import 'package:agri_connect/shared/widgets/quick_action_grid.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';

import 'support/fakes.dart';

/// Widths a console actually meets: the narrowest phone still sold, the common
/// ones, and a tablet-sized window.
const List<Size> _widths = [
  Size(320, 640),
  Size(360, 800),
  Size(412, 915),
  Size(430, 932),
  Size(1280, 800),
];

/// Overflow below this many pixels is rounding, not a layout a reader can see.
const double _subPixelOverflow = 0.01;

/// Revenue the fake repository legitimately reports.
const int _seedGmv = 156600;

void _useSize(WidgetTester tester, Size logical, {double textScale = 1.0}) {
  const dpr = 3.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = logical * dpr;
  tester.view.padding = FakeViewPadding(top: 24 * dpr, bottom: 34 * dpr);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.view.resetPadding();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

/// Signs a Super Admin in and mounts the real application.
///
/// The full app is used on purpose: it is the only way to prove the router
/// actually serves the console sections instead of the generic placeholder, so
/// a regression in `app_router.dart` fails here rather than in a demo.
Future<FakeSuperAdminRepository> _pumpConsole(
  WidgetTester tester, {
  FakeSuperAdminRepository? repo,
  String language = 'fr',
}) async {
  final repository = repo ?? FakeSuperAdminRepository();
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': language,
    'welcome_selected_role_v1': 'root',
    'auth_user_v1': jsonEncode(
      AuthUser(
        id: 'sa1',
        fullName: 'Adjoua Koffi',
        email: 'adjoua@agri-connect.app',
        role: UserRole.root,
      ).toJson(),
    ),
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [superAdminRepositoryProvider.overrideWithValue(repository)],
      child: const AgriConnectApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
  return repository;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

ScrollableState _mainScrollable(WidgetTester tester) =>
    tester.state<ScrollableState>(
      find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
    );

Finder _scrollable(WidgetTester tester) => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .last;

/// The sideways scrollable of the filter row.
Finder _horizontalScrollable(WidgetTester tester) => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
    )
    .first;

/// Brings a widget into the viewport, building it first when it is lazy.
///
/// The scroll is driven by real drags on the page's own scrollable, and it
/// stops at the end of the content: a lazy list that has run out of items must
/// not be dragged forever waiting for a widget that will never be built.
Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  if (target.evaluate().isEmpty) {
    final scrollable = _scrollable(tester);
    final state = tester.state<ScrollableState>(scrollable);
    // A lazy list forgets whatever the scroll left far behind, so the walk
    // always starts from the top and only ever goes one way.
    state.position.jumpTo(0);
    await _settle(tester);
    var guard = 0;
    while (target.evaluate().isEmpty && guard++ < 40) {
      final position = state.position;
      if (!position.hasContentDimensions) break;
      if (position.pixels >= position.maxScrollExtent - 0.5) break;
      await tester.drag(scrollable, const Offset(0, -220));
      await _settle(tester);
    }
  }
  // Only a widget that exists is brought into view: a test asserting that
  // something is absent must reach its end of the list, not throw on the way.
  if (target.evaluate().isNotEmpty) {
    await tester.ensureVisible(target);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
  await _settle(tester);
}

/// Taps a chip of the horizontal filter row.
///
/// The row sits inside the page's own scroll view and scrolls sideways itself,
/// so the page is walked until the row exists and the row is then walked until
/// the chip does. One walk is never enough: a chip off the right of a 320 dp
/// phone is not built, and the page scroll cannot bring it into existence.
Future<void> _tapChip(WidgetTester tester, String key) async {
  final chip = _key(key);
  await _scrollTo(tester, chip);
  if (chip.evaluate().isEmpty) {
    final state = tester.state<ScrollableState>(_horizontalScrollable(tester));
    var guard = 0;
    while (chip.evaluate().isEmpty && guard++ < 20) {
      final position = state.position;
      if (!position.hasContentDimensions) break;
      if (position.pixels >= position.maxScrollExtent - 0.5) break;
      position.jumpTo(
        (position.pixels + 120).clamp(0.0, position.maxScrollExtent),
      );
      await _settle(tester);
    }
  }
  expect(chip, findsOneWidget, reason: 'the filter chip $key is unreachable');
  await tester.ensureVisible(chip);
  await _settle(tester);
  await tester.tap(chip);
  await _settle(tester);
}

/// Taps a widget after making sure it is really on screen.
///
/// A tap on an off-screen widget silently misses while still passing, which is
/// how a navigation test ends up asserting nothing.
Future<void> _tapVisible(WidgetTester tester, Finder target) async {
  await _scrollTo(tester, target);
  await tester.tap(target);
  await _settle(tester);
}

String _compact(String value) =>
    value.replaceAll(RegExp('[ \u00A0\u202F\u2009]'), '');

Finder _money(int amount) {
  final needle = '${amount}FCFA';
  return find.byWidgetPredicate(
    (w) => w is Text && _compact(w.data ?? '') == needle,
    description: 'money label $needle',
  );
}

Finder _key(String name) => find.byKey(ValueKey(name));

Finder _figureValue(String id, String value) => find.descendant(
  of: _key('superAdmin.figure.$id'),
  matching: find.text(value),
);

Finder _shortcut(String label) => find.descendant(
  of: find.byType(QuickActionGrid),
  matching: find.text(label),
);

/// Opens a console section through the navigation offered at the current size.
Future<void> _openSection(WidgetTester tester, String label) async {
  final sidebar = find.byKey(const ValueKey('roleShellSidebar'));
  if (sidebar.evaluate().isNotEmpty) {
    await tester.tap(
      find.descendant(
        of: sidebar,
        matching: find.widgetWithText(ListTile, label),
      ),
    );
    await _settle(tester);
    return;
  }

  final destinations = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.byType(NavigationDestination),
  );
  final matchingIndex = destinations.evaluate().toList().indexWhere(
    (element) => (element.widget as NavigationDestination).label == label,
  );
  if (matchingIndex >= 0) {
    await tester.tap(destinations.at(matchingIndex));
  } else {
    await tester.tap(destinations.last);
    await _settle(tester);
    await tester.tap(
      find.descendant(of: find.byType(BottomSheet), matching: find.text(label)),
    );
  }
  await _settle(tester);
}

/// Scrolls the page to its end and fails on any painted overflow.
Future<void> _expectNoRenderError(WidgetTester tester, String where) async {
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final context = details.informationCollector?.call().join('\n') ?? '';
    final message = details.exceptionAsString();
    final overflow = RegExp(
      r'overflowed by ([\d.]+) pixels',
    ).firstMatch(message);
    if (overflow != null &&
        double.parse(overflow.group(1)!) < _subPixelOverflow) {
      return;
    }
    errors.add('$message\n$context');
  };

  try {
    for (var pass = 0; pass < 3; pass++) {
      var moved = false;
      final position = _mainScrollable(tester).position;
      final step = (position.viewportDimension / 2).clamp(80.0, 240.0);
      for (var i = 0; i < 60; i++) {
        if (!position.hasContentDimensions) break;
        if (position.pixels >= position.maxScrollExtent - 0.5) break;
        position.jumpTo(
          (position.pixels + step).clamp(0.0, position.maxScrollExtent),
        );
        moved = true;
        await _settle(tester);
      }
      if (!moved) break;
    }
    await _settle(tester);
    expect(errors, isEmpty, reason: 'render error on $where');
  } finally {
    FlutterError.onError = previous;
  }
}

void main() {
  group('Super Admin dashboard', () {
    testWidgets('shows the figures the repository returns', (tester) async {
      await _pumpConsole(tester);
      await _settle(tester);

      // Every number below is the fake repository's. A console that invented a
      // growth rate or a trend would have nothing to match here, which is the
      // point: it can only ever display what the repository holds.
      expect(_figureValue('users', '42'), findsOneWidget);
      expect(_figureValue('staff', '3'), findsOneWidget);
      expect(_figureValue('products', '34'), findsOneWidget);
      expect(_figureValue('deliveries', '2'), findsOneWidget);
      expect(
        find.descendant(
          of: _key('superAdmin.figure.gmv'),
          matching: _money(_seedGmv),
        ),
        findsOneWidget,
      );

      // The backlog counts the three platform counters.
      expect(_key('attention.moderation'), findsOneWidget);
      expect(_key('attention.users'), findsOneWidget);
      expect(_key('attention.deliveries'), findsOneWidget);

      // The activity trail is the repository's own list.
      await _scrollTo(tester, _key('superAdmin.activity.e1'));
      expect(_key('superAdmin.activity.e1'), findsOneWidget);
      expect(_key('superAdmin.activity.e2'), findsOneWidget);
    });

    testWidgets('counts the staff distribution from the directory', (
      tester,
    ) async {
      await _pumpConsole(tester);
      await _settle(tester);

      // Four seeded members: two with full access, one read only, one suspended.
      // The card is fed from the same list the tiles summarize, so the two
      // cannot disagree.
      await _scrollTo(tester, _key('superAdmin.distribution.staff'));
      expect(_key('superAdmin.distribution.staff'), findsOneWidget);
      expect(_key('superAdmin.distribution.permissions'), findsOneWidget);
    });

    testWidgets('shows a skeleton while the data is in flight', (tester) async {
      final gate = Completer<void>();
      final repo = FakeSuperAdminRepository(
        overviewGate: gate,
        staffGate: gate,
        eventsGate: gate,
      );
      await _pumpConsole(tester, repo: repo);

      expect(find.byType(SuperAdminDashboardSkeleton), findsOneWidget);

      gate.complete();
      await _settle(tester);
      expect(find.byType(SuperAdminDashboardSkeleton), findsNothing);
    });

    testWidgets('degrades to a retryable card when the overview fails', (
      tester,
    ) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);

      repo.setOverviewThrows(const ServerFailure('overview_unavailable'));
      await tester.tap(_key('superAdmin.refresh'));
      await _settle(tester);

      // The failing section is named and retryable, while the activity trail
      // keeps working: one unavailable call must not take the console down.
      expect(_key('superAdmin.error.overview'), findsOneWidget);
      expect(_key('superAdmin.error.distribution'), findsNothing);
      await _scrollTo(tester, _key('superAdmin.activity.e1'));
      expect(_key('superAdmin.activity.e1'), findsOneWidget);

      repo.setOverviewThrows(null);
      await _scrollTo(tester, _key('superAdmin.retry.overview'));
      await tester.tap(_key('superAdmin.retry.overview'));
      await _settle(tester);
      expect(_key('superAdmin.error.overview'), findsNothing);
    });

    testWidgets('refresh reloads every section', (tester) async {
      final repo = await _pumpConsole(tester);
      await _settle(tester);

      final overviewCalls = repo.fetchOverviewCalls;
      final staffCalls = repo.fetchStaffCalls;
      final eventCalls = repo.fetchEventsCalls;

      await tester.tap(_key('superAdmin.refresh'));
      await _settle(tester);

      expect(repo.fetchOverviewCalls, greaterThan(overviewCalls));
      expect(repo.fetchStaffCalls, greaterThan(staffCalls));
      expect(repo.fetchEventsCalls, greaterThan(eventCalls));
    });

    testWidgets('every shortcut opens a console section, not a placeholder', (
      tester,
    ) async {
      await _pumpConsole(tester);
      await _settle(tester);

      for (final shortcut in ['Équipe', 'Plateforme', 'Statistiques']) {
        // The shortcut has to be brought into view first: tapping a widget that
        // is off screen would silently do nothing and prove nothing.
        await _openSection(tester, 'Accueil');
        await _scrollTo(tester, _shortcut(shortcut));
        await tester.tap(_shortcut(shortcut));
        await _settle(tester);

        // The placeholder is the router's fallback; a real section never shows
        // its "coming soon" chip.
        expect(
          find.text('Bient\xF4t disponible'),
          findsNothing,
          reason: '$shortcut opened the under-construction page',
        );
        expect(find.byType(SuperAdminDashboardSkeleton), findsNothing);
      }
    });

    testWidgets('reads in English without losing a figure', (tester) async {
      await _pumpConsole(tester, language: 'en');
      await _settle(tester);

      expect(find.text('Overview'), findsOneWidget);
      expect(_figureValue('users', '42'), findsOneWidget);
      await _scrollTo(tester, _key('superAdmin.activity.e1'));
      expect(_key('superAdmin.activity.e1'), findsOneWidget);

      // The verb of a recorded action is data in the repository and wording in
      // the screen: the English trail must not read with the French verb.
      expect(
        find.descendant(
          of: _key('superAdmin.activity.e1'),
          matching: find.textContaining('changed the rights of'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('words the activity trail in the chosen language', (
      tester,
    ) async {
      await _pumpConsole(tester);
      await _settle(tester);

      await _scrollTo(tester, _key('superAdmin.activity.e1'));
      expect(
        find.descendant(
          of: _key('superAdmin.activity.e1'),
          matching: find.textContaining('a modifié les droits de'),
        ),
        findsOneWidget,
      );
    });

    for (final size in _widths) {
      testWidgets('lays out at ${size.width.toInt()}px without overflow', (
        tester,
      ) async {
        _useSize(tester, size);
        await _pumpConsole(tester);
        await _settle(tester);
        await _expectNoRenderError(tester, 'dashboard ${size.width}px');
      });
    }

    testWidgets('survives enlarged fonts on a narrow phone', (tester) async {
      _useSize(tester, const Size(320, 640), textScale: 1.6);
      await _pumpConsole(tester);
      await _settle(tester);
      await _expectNoRenderError(tester, 'dashboard at 1.6x');
    });
  });

  group('Super Admin staff directory', () {
    testWidgets('lists the seeded members', (tester) async {
      await _pumpConsole(tester);
      await _settle(tester);
      await _openSection(tester, 'Utilisateurs');

      // The list is lazy, so a member below the fold has to be scrolled into
      // existence before it can be asserted on.
      for (final id in ['s1', 's2', 's3', 's4']) {
        await _scrollTo(tester, _key('superAdmin.staff.$id'));
        expect(_key('superAdmin.staff.$id'), findsOneWidget);
      }
      expect(_key('superAdmin.staff.count'), findsOneWidget);
    });

    testWidgets('leaves a Super Admin and the signed-in account protected', (
      tester,
    ) async {
      await _pumpConsole(tester);
      await _settle(tester);
      await _openSection(tester, 'Utilisateurs');

      // s1 is a Super Admin, so the console offers no write on it at all.
      expect(_key('superAdmin.staff.permissions.s1'), findsNothing);
      expect(_key('superAdmin.staff.suspend.s1'), findsNothing);

      // An administrator is manageable and offers both actions.
      expect(_key('superAdmin.staff.permissions.s2'), findsOneWidget);
      expect(_key('superAdmin.staff.suspend.s2'), findsOneWidget);
    });

    testWidgets('search narrows the directory and clearing restores it', (
      tester,
    ) async {
      await _pumpConsole(tester);
      await _settle(tester);
      await _openSection(tester, 'Utilisateurs');

      await tester.enterText(_key('superAdmin.staff.search'), 'yao');
      await _settle(tester);

      expect(_key('superAdmin.staff.s2'), findsOneWidget);
      expect(_key('superAdmin.staff.s3'), findsNothing);

      await tester.enterText(_key('superAdmin.staff.search'), 'zzz');
      await _settle(tester);
      expect(_key('superAdmin.staff.empty'), findsOneWidget);

      // The keyboard has to go down first: it would otherwise cover the empty
      // state's own reset action and swallow the tap. The action is looked up
      // inside the empty state, because the header shows the same wording.
      tester.testTextInput.hide();
      await _settle(tester);
      await _tapVisible(
        tester,
        find.descendant(
          of: _key('superAdmin.staff.empty'),
          matching: find.text('Réinitialiser'),
        ),
      );

      // Each member is scrolled to before being asserted on: a lazy list drops
      // whatever the scroll left above the viewport.

      await _scrollTo(tester, _key('superAdmin.staff.s3'));
      expect(_key('superAdmin.staff.s3'), findsOneWidget);
      await _scrollTo(tester, _key('superAdmin.staff.s2'));
      expect(_key('superAdmin.staff.s2'), findsOneWidget);
    });

    testWidgets('filters the directory by role through the repository', (
      tester,
    ) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Utilisateurs');

      // The console asks the repository for a narrowed directory rather than
      // filtering a full list in memory: only the platform knows what a filter
      // means for accounts it has not returned.
      await _tapChip(tester, 'superAdmin.staff.filter.role.admin');
      expect(repo.lastRole, UserRole.admin);
      expect(repo.fetchStaffCalls, greaterThan(1));

      // s1 is the seeded Super Admin, so a role filter must drop it.
      await _scrollTo(tester, _key('superAdmin.staff.s2'));
      expect(_key('superAdmin.staff.s2'), findsOneWidget);
      await _scrollTo(tester, _key('superAdmin.staff.s1'));
      expect(_key('superAdmin.staff.s1'), findsNothing);
    });

    testWidgets('filters the directory by suspended status', (tester) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Utilisateurs');

      await _tapChip(tester, 'superAdmin.staff.filter.status.suspended');
      expect(repo.lastStatus, StaffAccountStatus.suspended);

      // Only s4 is suspended in the fake directory.
      await _scrollTo(tester, _key('superAdmin.staff.s4'));
      expect(_key('superAdmin.staff.s4'), findsOneWidget);
      expect(_key('superAdmin.staff.s2'), findsNothing);
    });

    testWidgets('resetting the filters restores the whole directory', (
      tester,
    ) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Utilisateurs');

      await tester.enterText(_key('superAdmin.staff.search'), 'yao');
      await _settle(tester);
      await _tapChip(tester, 'superAdmin.staff.filter.status.active');
      await _tapVisible(
        tester,
        find.descendant(
          of: find.byType(SectionHeader),
          matching: find.text('Réinitialiser'),
        ),
      );

      // The reset clears the search and the filters together: leaving one
      // behind would let the directory stay narrowed with nothing showing why.
      expect(repo.lastQuery, '');
      expect(repo.lastRole, isNull);
      expect(repo.lastStatus, isNull);
      await _scrollTo(tester, _key('superAdmin.staff.s1'));
      expect(_key('superAdmin.staff.s1'), findsOneWidget);
    });

    testWidgets('locks the settings right when editing an administrator', (
      tester,
    ) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Utilisateurs');

      await _tapVisible(tester, _key('superAdmin.staff.permissions.s2'));

      // The right is visible and disabled: hiding it would look like the
      // platform does not model it.
      await _scrollTo(
        tester,
        _key('superAdmin.permission.managePlatformSettings'),
      );
      final locked = tester.widget<SwitchListTile>(
        find.byKey(
          const ValueKey('superAdmin.permission.managePlatformSettings'),
        ),
      );
      expect(locked.value, isFalse);
      expect(locked.onChanged, isNull);
    });

    testWidgets('saves edited permissions and reloads the directory', (
      tester,
    ) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Utilisateurs');

      await _tapVisible(tester, _key('superAdmin.staff.permissions.s3'));

      // s3 arrives read only with analytics; granting moderation is the edit.
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('superAdmin.permission.moderateProducts')),
      );
      await _tapVisible(tester, _key('superAdmin.permissions.save'));

      expect(repo.updatePermissionsCalls, 1);
      expect(repo.lastPermissions, contains(StaffPermission.moderateProducts));
      // The sheet closes, so the directory owns the screen again.
      expect(find.text('Droits de Kouassi N\'Guessan'), findsNothing);
    });

    testWidgets('a suspended member offers a restore instead of a suspend', (
      tester,
    ) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Utilisateurs');

      await _scrollTo(tester, _key('superAdmin.staff.s4'));
      expect(_key('superAdmin.staff.suspend.s4'), findsNothing);
      expect(_key('superAdmin.staff.restore.s4'), findsOneWidget);

      await _tapVisible(tester, _key('superAdmin.staff.restore.s4'));

      expect(repo.fetchStaffCalls, greaterThan(1));
      await _scrollTo(tester, _key('superAdmin.staff.s4'));
      expect(_key('superAdmin.staff.suspend.s4'), findsOneWidget);
    });

    testWidgets('a failing directory offers a retry', (tester) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Utilisateurs');

      repo.staffThrows = const ServerFailure('staff_unavailable');
      await tester.enterText(_key('superAdmin.staff.search'), 'a');
      await _settle(tester);

      expect(find.text('R\xE9essayer'), findsWidgets);

      repo.staffThrows = null;
      tester.testTextInput.hide();
      await _settle(tester);
      await _tapVisible(tester, find.text('R\xE9essayer').first);
      await _scrollTo(tester, _key('superAdmin.staff.s2'));
      expect(_key('superAdmin.staff.s2'), findsOneWidget);
    });

    for (final size in _widths) {
      testWidgets('lays out at ${size.width.toInt()}px without overflow', (
        tester,
      ) async {
        _useSize(tester, size);
        await _pumpConsole(tester);
        await _settle(tester);
        await _openSection(tester, 'Utilisateurs');
        await _expectNoRenderError(tester, 'staff ${size.width}px');
      });
    }
  });

  group('Super Admin platform settings', () {
    testWidgets('disables the save until something changes', (tester) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Plateforme');

      await _scrollTo(tester, _key('superAdmin.settings.save'));
      final save = find.byKey(const ValueKey('superAdmin.settings.save'));
      expect(
        tester
            .widget<FilledButton>(
              find.descendant(of: save, matching: find.byType(FilledButton)),
            )
            .onPressed,
        isNull,
        reason: 'an untouched draft must not offer to be saved',
      );
      expect(repo.saveSettingsCalls, 0);
    });

    testWidgets('saves the settings the console actually holds', (
      tester,
    ) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Plateforme');

      await tester.tap(_key('superAdmin.setting.maintenance'));
      await _settle(tester);

      // The warning appears with the switch, because a maintenance mode takes
      // the marketplace offline.
      expect(
        find.text('La place de march\xE9 sera inaccessible.'),
        findsOneWidget,
      );
      // The reminder sits under the save button, so it only exists once the form
      // has been scrolled to its end.
      await _scrollTo(
        tester,
        find.text(
          'Modifications non enregistr\xE9es. Elles prendront effet \xE0 l\'enregistrement.',
        ),
      );
      expect(
        find.text(
          'Modifications non enregistr\xE9es. Elles prendront effet \xE0 l\'enregistrement.',
        ),
        findsOneWidget,
      );

      await _scrollTo(tester, _key('superAdmin.settings.save'));
      await tester.tap(_key('superAdmin.settings.save'));
      await _settle(tester);

      expect(repo.saveSettingsCalls, 1);
      expect(repo.storedSettings.maintenanceMode, isTrue);
    });

    testWidgets('refuses an invalid support email', (tester) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Plateforme');

      await tester.enterText(
        _key('superAdmin.setting.supportEmail'),
        'not-an-email',
      );
      await _settle(tester);
      await _scrollTo(
        tester,
        find.byKey(const ValueKey('superAdmin.settings.save')),
      );
      await tester.tap(_key('superAdmin.settings.save'));
      await _settle(tester);

      expect(find.text('Adresse email invalide.'), findsOneWidget);
      expect(repo.saveSettingsCalls, 0);
    });

    testWidgets('refuses an upload ceiling outside the allowed range', (
      tester,
    ) async {
      final repo = FakeSuperAdminRepository();
      await _pumpConsole(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Plateforme');

      await tester.enterText(_key('superAdmin.setting.maxUpload'), '99');
      await _settle(tester);
      await _scrollTo(
        tester,
        find.byKey(const ValueKey('superAdmin.settings.save')),
      );
      await tester.tap(_key('superAdmin.settings.save'));
      await _settle(tester);

      expect(
        find.text('La valeur doit \xEAtre comprise entre 1 et 20 Mo.'),
        findsOneWidget,
      );
      expect(repo.saveSettingsCalls, 0);
    });

    for (final size in _widths) {
      testWidgets('lays out at ${size.width.toInt()}px without overflow', (
        tester,
      ) async {
        _useSize(tester, size);
        await _pumpConsole(tester);
        await _settle(tester);
        await _openSection(tester, 'Plateforme');
        await _expectNoRenderError(tester, 'platform ${size.width}px');
      });
    }
  });

  group('Super Admin analytics', () {
    testWidgets('shows figures and no invented trend', (tester) async {
      await _pumpConsole(tester);
      await _settle(tester);
      await _openSection(tester, 'Statistiques');

      expect(_key('superAdmin.analytics.gmv'), findsOneWidget);
      expect(_key('superAdmin.analytics.orders'), findsOneWidget);
      expect(_key('superAdmin.analytics.openOrders'), findsOneWidget);

      // The absence of history is stated in words rather than drawn as an
      // empty chart that would look like missing data.
      expect(
        find.text(
          "L'historique n'est pas encore disponible sur cette version de d\xE9monstration.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('counts the rights granted across the directory', (
      tester,
    ) async {
      await _pumpConsole(tester);
      await _settle(tester);
      await _openSection(tester, 'Statistiques');

      await _scrollTo(tester, _key('superAdmin.analytics.accessLevels'));
      expect(_key('superAdmin.analytics.accessLevels'), findsOneWidget);
      expect(_key('superAdmin.analytics.permissions'), findsOneWidget);
    });

    for (final size in _widths) {
      testWidgets('lays out at ${size.width.toInt()}px without overflow', (
        tester,
      ) async {
        _useSize(tester, size);
        await _pumpConsole(tester);
        await _settle(tester);
        await _openSection(tester, 'Statistiques');
        await _expectNoRenderError(tester, 'analytics ${size.width}px');
      });
    }
  });
}
