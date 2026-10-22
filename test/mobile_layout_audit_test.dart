import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

/// Sections reachable from the shell, in the order the router declares them.
const Map<UserRole, int> _sectionCount = {
  UserRole.supplier: 4,
  UserRole.buyer: 4,
  UserRole.driver: 4,
  UserRole.agent: 6,
  UserRole.admin: 7,
  UserRole.root: 5,
};

/// Handsets worth testing against: the common Android size, a small one, and an
/// accessibility text scale on top of the common one.
typedef _Profile = ({String name, Size size, double textScale});

const List<_Profile> _profiles = [
  (name: '360x800', size: Size(360, 800), textScale: 1.0),
  (name: '320x640', size: Size(320, 640), textScale: 1.0),
  (name: '360x800 at a 1.5x text scale', size: Size(360, 800), textScale: 1.5),
];

/// Simulates a real Android phone: logical size plus the physical insets of a
/// notched device with a gesture bar, so `MediaQuery.padding` and every
/// `SafeArea` see what they see on the handset.
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

Future<void> _pumpRole(
  WidgetTester tester,
  UserRole role, {
  required double textScale,
}) async {
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

  // The wrapper keeps the device insets that `MediaQuery.fromView` reported and
  // only raises the text scale on top of them.
  final media = MediaQueryData.fromView(
    tester.view,
  ).copyWith(textScaler: TextScaler.linear(textScale));

  await tester.pumpWidget(
    MediaQuery(
      data: media,
      child: const ProviderScope(child: AgriConnectApp()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
}

/// Walks every section of [role] the way a thumb does, on a phone, and reports
/// what a real handset would show: layout exceptions, and a page that draws its
/// own app bar under the one the shell already draws.
Future<List<String>> _auditRole(
  WidgetTester tester,
  UserRole role, {
  required double textScale,
}) async {
  final findings = <String>[];
  final declared = _sectionCount[role]!;

  await _pumpRole(tester, role, textScale: textScale);

  final destinations = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.byType(NavigationDestination),
  );
  final tabs = destinations.evaluate().length;

  // A bar that shows fewer destinations than the role declares hides the
  // surplus behind an overflow tab: its last destination opens a sheet instead
  // of a page. The audit has to open that sheet and walk each entry, otherwise
  // the pages behind "More" are never laid out on a phone.
  final overflow = tabs < declared;
  final directTabs = overflow ? tabs - 1 : tabs;

  void audit(String label) {
    final error = tester.takeException();
    if (error != null) {
      findings.add('$label: ${error.toString().split('\n').first}');
    }

    final appBarCount = find.byType(AppBar).evaluate().length;
    if (appBarCount > 1) {
      findings.add(
        '$label: $appBarCount AppBar widgets stacked, the shell already '
        'draws one',
      );
    }
  }

  Future<void> tapTab(int index) async {
    final bar = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byType(NavigationDestination),
    );
    await tester.tap(bar.at(index), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  // The dashboard is already on screen right after the shell is pumped.
  audit('$role / section 0');

  for (var i = 1; i < directTabs; i++) {
    await tapTab(i);
    audit('$role / destination $i');
  }

  if (overflow) {
    // Every section the bar does not show directly lives behind the overflow
    // tab, so opening that tab and walking its entries covers the rest.
    final hidden = declared - directTabs;
    for (var i = 0; i < hidden; i++) {
      await tapTab(tabs - 1);
      await tester.tap(
        find
            .descendant(
              of: find.byType(BottomSheet),
              matching: find.byType(ListTile),
            )
            .at(i),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      audit('$role / more entry $i');
    }
  }

  return findings;
}

void main() {
  for (final role in _sectionCount.keys) {
    for (final profile in _profiles) {
      testWidgets('MOBILE $role on ${profile.name}', (tester) async {
        _usePhone(tester, profile.size);

        final findings = await _auditRole(
          tester,
          role,
          textScale: profile.textScale,
        );

        expect(findings, isEmpty, reason: findings.join('\n'));
      });
    }
  }
}
