import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/app/router/app_router.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

/// Last global mobile audit.
///
/// The earlier audits each proved one thing in isolation: keyboard avoidance,
/// layout at three widths, the back stack, tap targets. This one checks the
/// dimensions none of them covered, which is where a phone differs most from a
/// test default:
///
///  * the system font size, which Android users raise far more often than
///    developers assume, and which turns every fixed height into an overflow;
///  * a short viewport, the shape a phone has in landscape and with the
///    keyboard open;
///  * a real display cutout, so nothing hides under a notch or a gesture bar.
///
/// A rendering error is not something to tolerate here: on a phone it paints
/// the black and yellow stripes across the screen the user is trying to read.
const List<Size> _phones = [Size(320, 640), Size(360, 800), Size(412, 915)];

/// Short viewports: landscape, and a portrait screen with the keyboard up.
const List<Size> _short = [Size(640, 320), Size(412, 420)];

/// Font sizes Android users actually run. 1.0 is the default, 1.15 and 1.3 are
/// the common settings, 1.5 is the top of the normal range.
const List<double> _scales = [1.15, 1.3, 1.5];

/// Overflow below this many pixels is rounding, not a layout a reader can see.
const double _subPixelOverflow = 0.01;

/// Every screen the router can push above the shell, per role.
///
/// The shell keeps all of a role's tabs alive at once, so these screens are the
/// ones the tab sweep never lays out: they are built on top of a page that is
/// still in the tree. Driving them by path rather than by tapping also reaches
/// the forms, which sit behind an action instead of behind a card.
///
/// The ids come from the demo repositories, so the pages find their data.
final Map<UserRole, List<String>> _pushedRoutes = {
  UserRole.supplier: [
    RoutePaths.supplierProductNew,
    _withIds(RoutePaths.supplierProductDetail, productId: 'p_1001'),
    _withIds(RoutePaths.supplierProductEdit, productId: 'p_1001'),
    _withIds(RoutePaths.supplierOrderDetail, orderId: 'c_2001'),
    RoutePaths.supplierMessages,
    _withIds(RoutePaths.supplierConversation, conversationId: 'chat_5001'),
  ],
  UserRole.buyer: [
    _withIds(RoutePaths.buyerProductDetail, productId: 'p_3011'),
    RoutePaths.buyerCart,
    RoutePaths.buyerCheckout,
    _withIds(RoutePaths.buyerOrderDetail, orderId: 'b_4006'),
    RoutePaths.buyerMessages,
    _withIds(RoutePaths.buyerConversation, conversationId: 'chat_5001'),
  ],
  UserRole.driver: [
    _withIds(RoutePaths.driverDeliveryDetail, deliveryId: 'del_7001'),
    RoutePaths.driverMessages,
    _withIds(RoutePaths.driverConversation, conversationId: 'chat_5001'),
  ],
  // Admin, agent and root have no pushed screen beyond their tabs: the agent
  // workspace is entirely served by its six shell tabs.
  UserRole.agent: [],
  UserRole.admin: [],
  UserRole.root: [],
};

/// Fills the `:name` slots of a [RoutePaths] template with demo ids.
String _withIds(
  String template, {
  String productId = '',
  String orderId = '',
  String deliveryId = '',
  String conversationId = '',
}) {
  final ids = <String, String>{
    if (productId.isNotEmpty) 'productId': productId,
    if (orderId.isNotEmpty) 'orderId': orderId,
    if (deliveryId.isNotEmpty) 'deliveryId': deliveryId,
    if (conversationId.isNotEmpty) 'conversationId': conversationId,
  };
  var path = template;
  ids.forEach((slot, id) => path = path.replaceFirst(':$slot', id));
  // A slot left unfilled would 404 in the router and the page under audit would
  // never be built, which would make the whole test quietly worthless.
  if (path.contains(':')) {
    throw ArgumentError('unfilled route slot in $template');
  }
  return path;
}

void _usePhone(
  WidgetTester tester,
  Size logical, {
  double textScale = 1.0,
  bool cutout = false,
}) {
  const dpr = 3.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = logical * dpr;
  tester.view.padding = cutout
      ? FakeViewPadding(top: 48 * dpr, bottom: 24 * dpr)
      : FakeViewPadding(top: 24 * dpr, bottom: 34 * dpr);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.view.resetPadding();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

/// Signs a role in and returns the container, so a test can drive the router
/// itself instead of hunting for the control that opens a screen.
Future<ProviderContainer> _pumpRole(WidgetTester tester, UserRole role) async {
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': 'fr',
    'welcome_selected_role_v1': role.key,
    // The shell layout is under audit, not the first-run welcome panels.
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
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const AgriConnectApp(),
    ),
  );
  await tester.pump();
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  return container;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

/// Scrolls every vertical list on the screen to its end.
///
/// An overflow that only exists past the last visible pixel still reaches a real
/// user as soon as they scroll, and a lazy list only builds the rows it has to,
/// so the sweep has to reach the bottom rather than judge the first screenful.
///
/// Three details make this less obvious than it looks:
///
///  * every vertical scrollable is walked, not just the first: a page can nest
///    lists, and the one holding the row under audit is not always the one that
///    comes first in the tree;
///  * the whole set is walked again after each pass, because reaching the
///    bottom is what makes the next lazy row exist;
///  * the position is driven directly instead of dragging. A drag hit-tests
///    every box under the finger, and a lazily built list item can be caught
///    with no size yet, which fails the test for a reason that has nothing to
///    do with the layout under audit;
///  * each move is a fraction of the viewport, not a whole one. A lazy list
///    grows its scroll extent as it builds, and jumping a screen at a time
///    overshoots an extent that is still being computed: the position lands
///    past the real end, the extent then corrects itself downwards, and the
///    sweep believes it has reached the bottom while the rows below were never
///    built.
Future<void> _walkToTheBottom(WidgetTester tester) async {
  final scroller = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  if (scroller.evaluate().isEmpty) return;

  for (var pass = 0; pass < 3; pass++) {
    var moved = false;
    for (final state in tester.stateList<ScrollableState>(scroller)) {
      final position = state.position;
      final step = (position.viewportDimension / 2).clamp(80.0, 240.0);
      for (var i = 0; i < 80; i++) {
        if (!position.hasContentDimensions) break;
        if (position.pixels >= position.maxScrollExtent - 0.5) break;
        position.jumpTo(
          (position.pixels + step).clamp(0.0, position.maxScrollExtent),
        );
        moved = true;
        await _settle(tester);
      }
    }
    if (!moved) break;
  }
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

/// Fails when the framework painted an overflow. Flutter reports these through
/// the error channel rather than the exception channel, so the handler has to
/// be watching before the widget is built.
Future<void> _expectNoRenderError(WidgetTester tester, String where) async {
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    // The bare message does not say which widget overflowed; the collected
    // information names it, which is the difference between a fix and a hunt.
    final context = details.informationCollector?.call().join('\n') ?? '';
    final message = details.exceptionAsString();
    final overflow = RegExp(
      r'overflowed by ([\d.]+) pixels',
    ).firstMatch(message);
    if (overflow != null &&
        double.parse(overflow.group(1)!) < _subPixelOverflow) {
      // Dividing a width between columns leaves a rounding remainder of a few
      // hundred-thousandths of a pixel. Nothing reaches the glass at that size,
      // even on the densest screen, so treating it as a failure would only
      // train us to ignore the report.
      return;
    }
    errors.add('$message\n$context');
  };

  try {
    await _walkToTheBottom(tester);
    await _settle(tester);
    expect(errors, isEmpty, reason: 'render error on $where');
  } finally {
    FlutterError.onError = previous;
  }
}

void main() {
  for (final role in UserRole.values) {
    final tag = role.key;

    for (final scale in _scales) {
      testWidgets('GLOBAL $tag: a ${scale}x system font does not break any tab '
          'on a 360dp phone', (tester) async {
        _usePhone(tester, const Size(360, 800), textScale: scale);
        await _pumpRole(tester, role);

        final tabs = _sectionCount(tester);

        for (var index = 0; index < tabs; index++) {
          await _tapSection(tester, index);
          await _expectNoRenderError(
            tester,
            '$tag tab $index at ${scale}x on 360dp',
          );
        }
      });
    }

    testWidgets('GLOBAL $tag: a short viewport keeps every tab usable', (
      tester,
    ) async {
      for (final size in _short) {
        _usePhone(tester, size);
        await _pumpRole(tester, role);

        final tabs = _sectionCount(tester);

        for (var index = 0; index < tabs; index++) {
          await _tapSection(tester, index);
          await _expectNoRenderError(
            tester,
            '$tag tab $index on ${size.width}x${size.height}',
          );
        }
      }
    });

    testWidgets(
      'GLOBAL $tag: a display cutout hides nothing on a 320dp phone',
      (tester) async {
        _usePhone(tester, const Size(320, 640), cutout: true);
        await _pumpRole(tester, role);

        final tabs = _sectionCount(tester);

        for (var index = 0; index < tabs; index++) {
          await _tapSection(tester, index);
          await _expectNoRenderError(tester, '$tag tab $index under a cutout');
        }
      },
    );

    final pushed = _pushedRoutes[role]!;
    if (pushed.isNotEmpty) {
      testWidgets('GLOBAL $tag: every screen pushed above the shell survives a '
          '1.3x font', (tester) async {
        _usePhone(tester, const Size(360, 800), textScale: 1.3);
        final container = await _pumpRole(tester, role);
        final router = container.read(routerProvider);

        for (final path in pushed) {
          // Driven by path, not by tap: a tap only reaches what the screen
          // offers, and the forms sit behind an action rather than a card.
          // `go` rather than `push` because a `push` issued from outside a
          // widget callback is dropped by the router, which would leave the
          // sweep below auditing the tab it started from.
          router.go(path);
          await _settle(tester);

          // A redirect would leave the page unbuilt, and the sweep after this
          // would pass without ever having laid out the screen it names.
          expect(
            router.routerDelegate.currentConfiguration.uri.path,
            path,
            reason: '$tag: $path did not stay open',
          );
          await _expectNoRenderError(tester, '$tag $path at 1.3x');

          router.go(role.homePath);
          await _settle(tester);
          // The shell has to come back: a screen that leaves the tabs gone
          // strands the reader with no way out but the system back button.
          expect(
            find.byType(NavigationBar),
            findsOneWidget,
            reason: '$tag: the compact tabs did not come back after $path',
          );
          await _expectNoRenderError(tester, '$tag tabs after $path');
        }
      });
    }
  }

  for (final phone in _phones) {
    testWidgets('GLOBAL: the pushed screens above the shell survive a 1.3x '
        'font on ${phone.width.toInt()}dp', (tester) async {
      _usePhone(tester, phone, textScale: 1.3);
      await _pumpRole(tester, UserRole.supplier);

      // Products list, then the product detail pushed over it.
      await _tapSection(tester, 1);
      await _expectNoRenderError(tester, 'products at 1.3x');

      final card = find.byType(Card).first;
      await tester.tap(card, warnIfMissed: false);
      await _settle(tester);
      await _expectNoRenderError(tester, 'product detail at 1.3x');

      await tester.binding.handlePopRoute();
      await _settle(tester);
      await _expectNoRenderError(tester, 'products again at 1.3x');

      // Orders, then the order detail pushed over it.
      await _tapSection(tester, 2);
      await _expectNoRenderError(tester, 'orders at 1.3x');

      await tester.tap(find.byType(Card).first, warnIfMissed: false);
      await _settle(tester);
      await _expectNoRenderError(tester, 'order detail at 1.3x');
    });
  }

  // The contact sheets are the one place the app puts a column of text in a
  // box whose height the framework chooses: a bottom sheet is capped by the
  // screen, so the largest font and the narrowest phone are exactly where it
  // should break, and no tab or route sweep ever opens one.
  final contactSheets = <UserRole, ({String route, String label})>{
    UserRole.buyer: (
      route: _withIds(RoutePaths.buyerOrderDetail, orderId: 'b_4006'),
      label: 'Contacter le chauffeur',
    ),
    UserRole.driver: (
      route: _withIds(RoutePaths.driverDeliveryDetail, deliveryId: 'del_7001'),
      label: 'Contacter le client',
    ),
  };

  for (final entry in contactSheets.entries) {
    final tag = entry.key.key;
    final sheet = entry.value;

    testWidgets('GLOBAL $tag: the contact sheet survives a 1.5x font on a '
        '320dp phone', (tester) async {
      _usePhone(tester, const Size(320, 640), textScale: 1.5);
      final container = await _pumpRole(tester, entry.key);
      final router = container.read(routerProvider);

      router.go(sheet.route);
      await _settle(tester);
      // The demo repositories answer after a short delay, and the page builds
      // its lower half lazily, so the button is scrolled to rather than looked
      // for: a row the list has already released is not in the tree, which is
      // why the walk to the bottom cannot come first here.
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // The label is scrolled to rather than the button around it: the two
      // sides use different button widgets, and the label is what identifies
      // the action in both. `findsOneWidget` keeps an ambiguous match from
      // silently auditing the wrong one.
      final button = find.text(sheet.label);
      await tester.scrollUntilVisible(
        button,
        240,
        scrollable: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        ),
      );
      expect(button, findsOneWidget, reason: '$tag: no ${sheet.label} button');
      await tester.tap(button, warnIfMissed: false);
      await _settle(tester);

      await _expectNoRenderError(tester, '$tag contact sheet at 1.5x');
    });
  }
}
