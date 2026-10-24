import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/admin/application/admin_providers.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/domain/admin_moderation_status.dart';
import 'package:agri_connect/features/admin/domain/admin_product.dart';
import 'package:agri_connect/features/admin/presentation/admin_users_page.dart';
import 'package:agri_connect/features/admin/presentation/extensions/admin_category_l10n.dart';
import 'package:agri_connect/features/admin/presentation/extensions/admin_moderation_status_l10n.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_delivery_status_badge.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/shared/widgets/quick_action_grid.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

import 'support/fakes.dart';

/// Every word the Admin console paints for itself comes from the translation
/// tables.
///
/// The three moderation sections were written with their labels inline, which
/// left a French reader looking at "Approver", "Archiver" and a naira sign
/// while the rest of the console spoke French. These tests pin the console to
/// the tables so the next section added cannot reintroduce that split.

const List<Size> _widths = [Size(320, 640), Size(360, 800), Size(412, 915)];

/// Reads a table without pumping a widget: the extensions take the object, not
/// the context.
AppLocalizations _l10n(String language) =>
    lookupAppLocalizations(Locale(language));

Finder _key(String name) => find.byKey(ValueKey(name));

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

Future<FakeAdminRepository> _pumpAdmin(
  WidgetTester tester, {
  FakeAdminRepository? repo,
  String language = 'fr',
  Size size = const Size(412, 915),
  double textScale = 1.0,
}) async {
  final repository = repo ?? FakeAdminRepository();
  const dpr = 3.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = size * dpr;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': language,
    'welcome_selected_role_v1': 'admin',
    'auth_user_v1': jsonEncode(
      AuthUser(
        id: 'a1',
        fullName: 'Awa Traore',
        email: 'awa@agriconnect.app',
        role: UserRole.admin,
      ).toJson(),
    ),
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [adminRepositoryProvider.overrideWithValue(repository)],
      child: const AgriConnectApp(),
    ),
  );
  await tester.pump();
  await _settle(tester);
  return repository;
}

/// Brings [target] into the viewport, building it first when the list has not
/// reached it yet.
///
/// The deliveries workspace nests its list in a pull-to-refresh scroll view, so
/// several scrollables match and the first one is the page's own.
Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  final scrollable = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .first;
  if (target.evaluate().isEmpty) {
    await tester.scrollUntilVisible(target, 220, scrollable: scrollable);
  }
  await tester.ensureVisible(target);
  await _settle(tester);
}

Finder _shortcut(String label) => find.descendant(
  of: find.byType(QuickActionGrid),
  matching: find.text(label),
);

/// Removes every space a number pattern may insert, including the narrow and
/// non-breaking ones Dart's `\s` does not cover, so an amount can be matched
/// without knowing how the current locale writes it.
String _compact(String value) => value.replaceAll(RegExp('[    ]'), '');

/// Finds an amount wherever it sits in a line, in either of the two places the
/// delivery workspace prints it: a tile of its own, or a row that also names the
/// fee. The leading boundary keeps 2 000 from answering for 12 000.
Finder _money(int amount) {
  final pattern = RegExp(
    '(^|[^0-9])$amount'
    'FCFA',
  );
  return find.byWidgetPredicate(
    (w) => w is Text && pattern.hasMatch(_compact(w.data ?? '')),
    description: 'money label $amount FCFA',
  );
}

/// Opens a moderation section from the dashboard shortcut of the current
/// language.
Future<void> _openSection(WidgetTester tester, String label) async {
  await _scrollTo(tester, _shortcut(label));
  await tester.tap(_shortcut(label));
  await _settle(tester);
}

void main() {
  group('Admin console wording', () {
    testWidgets('the users section speaks the reader\'s language', (
      tester,
    ) async {
      await _pumpAdmin(tester);
      await _openSection(tester, 'Utilisateurs');

      expect(find.byType(AdminUsersPage), findsOneWidget);
      expect(find.text('Rechercher un compte…'), findsOneWidget);
      // The counts line is composed, not concatenated: "4 orders · 3 products"
      // stayed English on a French console.
      expect(find.textContaining('4 commandes'), findsOneWidget);
      expect(find.textContaining('3 produits'), findsOneWidget);
      expect(find.text('Approver'), findsNothing);
      expect(find.text('No users found'), findsNothing);
      expect(find.text('Could not load users'), findsNothing);
    });

    testWidgets('the users section in English', (tester) async {
      await _pumpAdmin(tester, language: 'en');
      await _openSection(tester, 'Users');

      expect(find.text('Search an account…'), findsOneWidget);
      expect(find.textContaining('4 orders'), findsOneWidget);
      expect(find.textContaining('3 products'), findsOneWidget);
    });

    testWidgets('the moderation queue speaks the reader\'s language', (
      tester,
    ) async {
      await _pumpAdmin(tester);
      await _openSection(tester, 'Produits');

      expect(find.text('Rechercher un produit…'), findsOneWidget);
      expect(find.text('Tous'), findsWidgets);
      // The seeded queue holds validated products: their badges read the French
      // wording, in the tiles and in the filter chips alike.
      expect(find.text('En ligne'), findsWidgets);
      expect(find.text('Live'), findsNothing);
      expect(find.text('Approver'), findsNothing);
      expect(find.text('Archiver'), findsNothing);
    });

    testWidgets('the moderation queue in English', (tester) async {
      await _pumpAdmin(tester, language: 'en');
      await _openSection(tester, 'Products');

      expect(find.text('Search a product…'), findsOneWidget);
      expect(find.text('Live'), findsWidgets);
      expect(find.text('En ligne'), findsNothing);
      expect(find.text('All'), findsWidgets);
    });

    testWidgets('a moderation action is offered in the reader\'s language', (
      tester,
    ) async {
      await _pumpAdmin(tester);
      await _openSection(tester, 'Produits');

      // Archiving only makes sense once a decision is made, which is what the
      // seeded product has.
      await tester.tap(_key('admin.products.menu.p1'));
      await _settle(tester);

      expect(find.text('Archiver'), findsOneWidget);
      expect(find.text('Archive'), findsNothing);
    });

    testWidgets('a moderation badge is painted from the brand palette', (
      tester,
    ) async {
      await _pumpAdmin(tester);
      await _openSection(tester, 'Produits');

      // The queue used to paint its own badge with the Material defaults, where
      // `Colors.green` is a different hue from the app's success green.
      final badge = tester.widget<StatusBadge>(find.byType(StatusBadge).first);
      expect(
        badge.color,
        isNot(anyOf(Colors.green, Colors.orange, Colors.red, Colors.grey)),
      );
    });

    testWidgets('a failed section says so in French and can be retried', (
      tester,
    ) async {
      final repository = FakeAdminRepository(productsThrows: Exception('boom'));
      await _pumpAdmin(tester, repo: repository);
      await _openSection(tester, 'Produits');

      expect(_key('admin.error.products'), findsOneWidget);
      expect(
        find.text('Cette section n\'a pas pu être chargée'),
        findsOneWidget,
      );
      expect(find.text('Could not load products'), findsNothing);

      repository.productsThrows = null;
      await tester.tap(_key('admin.retry.products'));
      await _settle(tester);

      expect(_key('admin.error.products'), findsNothing);
      expect(find.text('Rechercher un produit…'), findsOneWidget);
    });
  });

  group('the delivery workspace', () {
    testWidgets('a delivery states its fees in the app currency', (
      tester,
    ) async {
      await _pumpAdmin(tester);
      await _openSection(tester, 'Livraisons');

      // The tile carries its fees in both of its layouts, so this reads the
      // list before the detail sheet: a naira sign there was a second, quieter
      // version of the same wrong currency.
      expect(_money(2000), findsOneWidget);
      expect(_money(3500), findsOneWidget);
      expect(find.textContaining('₦'), findsNothing);

      // The tile identifies the delivery by its id, which both layouts show.
      await _scrollTo(tester, find.text('d1'));
      await tester.tap(find.text('d1'));
      await _settle(tester);

      // The sheet repeats the fees it inherited from the tile, and the tile is
      // still mounted behind it.
      expect(_money(2000), findsWidgets);
      expect(_money(3500), findsWidgets);
      expect(find.textContaining('₦'), findsNothing);
    });

    testWidgets('a delivery names its driver and its assignment action', (
      tester,
    ) async {
      await _pumpAdmin(tester);
      await _openSection(tester, 'Livraisons');

      await _scrollTo(tester, find.text('d1'));
      await tester.tap(find.text('d1'));
      await _settle(tester);

      expect(find.text('Livreur u4'), findsOneWidget);
      expect(find.text('Driver u4'), findsNothing);
      expect(find.text('Aucun chauffeur'), findsNothing);

      await tester.tap(find.byIcon(Icons.assignment_outlined));
      await _settle(tester);

      expect(find.text('Assigner un chauffeur'), findsOneWidget);
      expect(find.text('Nom du chauffeur…'), findsOneWidget);
      expect(find.text('Assigner'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Assign'), findsNothing);
    });
  });

  group('the products workspace', () {
    testWidgets('titles itself as the administrator\'s screen', (tester) async {
      await _pumpAdmin(tester);
      await _openSection(tester, 'Produits');

      // The header used to borrow the farmer's section label ("Mes produits").
      expect(find.text('Gestion des produits'), findsOneWidget);
    });

    testWidgets('titles itself in English', (tester) async {
      await _pumpAdmin(tester, language: 'en');
      await _openSection(tester, 'Products');

      expect(find.text('Product management'), findsOneWidget);
    });

    testWidgets('groups a price in the reader\'s language', (tester) async {
      await _pumpAdmin(tester, language: 'en');
      await _openSection(tester, 'Products');

      // Money.format defaults to French grouping; the English console used to
      // inherit it. The English grouping is the comma.
      expect(find.textContaining('1,200'), findsWidgets);
    });

    testWidgets('offers an archived filter that narrows the queue', (
      tester,
    ) async {
      final repository = FakeAdminRepository(
        products: [
          AdminProduct(
            id: 'p1',
            name: 'Tomates fraiches',
            category: 'Legumes',
            price: 1200,
            stockQuantity: 40,
            unit: 'kg',
            ownerId: 'u1',
            ownerName: 'Awa Traore',
            submittedAt: DateTime(2026, 9, 1),
          ),
          AdminProduct(
            id: 'p9',
            name: 'Vieux mais',
            category: 'Cereals',
            price: 700,
            stockQuantity: 0,
            unit: 'kg',
            ownerId: 'u1',
            ownerName: 'Awa Traore',
            submittedAt: DateTime(2026, 8, 1),
            moderation: AdminModerationStatus.archived,
          ),
        ],
      );
      await _pumpAdmin(tester, repo: repository);
      await _openSection(tester, 'Produits');

      expect(find.text('Tomates fraiches'), findsOneWidget);
      expect(find.text('Vieux mais'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Archivé'));
      await _settle(tester);

      expect(find.text('Vieux mais'), findsOneWidget);
      expect(find.text('Tomates fraiches'), findsNothing);
    });
  });

  group('the delivery status badge', () {
    testWidgets('colours in transit and delivered apart', (tester) async {
      Future<Color> colorOf(AdminDeliveryStatus status) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: AdminDeliveryStatusBadge(status: status)),
          ),
        );
        return tester.widget<StatusBadge>(find.byType(StatusBadge)).color;
      }

      final inTransit = await colorOf(AdminDeliveryStatus.inTransit);
      final delivered = await colorOf(AdminDeliveryStatus.delivered);

      // The badge used to paint both with the same primary colour, so a
      // delivery in transit and a delivered one were indistinguishable.
      expect(inTransit, isNot(delivered));
      expect(inTransit, AppColors.accent);
      expect(delivered, AppColors.success);
    });
  });

  group('moderation status wording', () {
    test('every status carries its own label and colour', () {
      final labels = <String>{};
      final colors = <Color>{};

      for (final status in AdminModerationStatus.values) {
        labels.add(status.label(_l10n('en')));
        colors.add(status.color());
      }

      expect(labels, hasLength(AdminModerationStatus.values.length));
      expect(colors, hasLength(AdminModerationStatus.values.length));
    });

    test('a status is never named with a Material colour name', () {
      for (final status in AdminModerationStatus.values) {
        expect(
          status.color(),
          isNot(anyOf(Colors.green, Colors.orange, Colors.red, Colors.grey)),
          reason: '$status falls back to a Material default',
        );
      }
    });
  });

  group('category wording', () {
    test('a recorded category is translated in the current language', () {
      // The queue stores free text, so the same wording has to be recognised in
      // either language the submitter may have typed it in.
      expect(adminCategoryLabel(_l10n('fr'), 'Cereales'), 'Céréales');
      expect(adminCategoryLabel(_l10n('en'), 'Cereals'), 'Cereals');
    });

    test('a recorded category is recognised whatever its spelling', () {
      expect(
        adminCategoryLabel(_l10n('fr'), 'Cereals'),
        adminCategoryLabel(_l10n('fr'), 'Céréales'),
      );
      expect(adminCategoryLabel(_l10n('fr'), 'LEGUMES'), 'Légumes');
    });

    test('an unknown category keeps the wording it arrived with', () {
      expect(
        adminCategoryLabel(_l10n('fr'), 'Légumes de saison'),
        'Légumes de saison',
      );
      expect(
        adminCategoryLabel(_l10n('en'), 'Seasonal greens'),
        'Seasonal greens',
      );
    });
  });

  group('the console at the sizes and fonts it has to survive', () {
    for (final size in _widths) {
      for (final scale in [1.0, 1.5]) {
        testWidgets('the moderation queue holds on $size at ${scale}x text', (
          tester,
        ) async {
          await _pumpAdmin(tester, size: size, textScale: scale);
          await _openSection(tester, 'Produits');

          // The badge shares a tile with a French status and a money figure: at
          // 1.5x on 320dp that row used to overflow by 12 pixels.
          expect(tester.takeException(), isNull);
          expect(find.byType(StatusBadge), findsWidgets);
        });
      }
    }
  });
}
