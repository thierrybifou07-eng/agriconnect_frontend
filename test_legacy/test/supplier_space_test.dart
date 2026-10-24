import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/media/photo_picker.dart';
import 'package:agri_connect/core/media/prepared_photo.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/supplier/application/supplier_providers.dart';
import 'package:agri_connect/features/supplier/application/product_form_controller.dart';
import 'package:agri_connect/features/supplier/data/supplier_welcome_storage.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_order_detail_page.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_orders_page.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_product_form_page.dart';
import 'package:agri_connect/features/supplier/presentation/supplier_dashboard_page.dart';
import 'package:agri_connect/shared/widgets/product_card.dart';
import 'package:agri_connect/shared/widgets/product_photo_field.dart';
import 'package:agri_connect/shared/widgets/product_thumbnail.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/stat_card.dart';

import 'support/fakes.dart';

/// Smallest valid PNG, so picture previews decode in widget tests.
final Uint8List _onePixelPng = Uint8List.fromList(fakePngBytes);

Future<FakeSupplierRepository> _pumpSupplier(
  WidgetTester tester, {
  FakeSupplierRepository? repo,
  FakePhotoPicker? picker,
  bool welcomeSeen = true,
  SupplierWelcomeStorage? welcomeStorage,
  String languageCode = 'fr',
}) async {
  final repository = repo ?? FakeSupplierRepository();
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': languageCode,
    'welcome_selected_role_v1': 'supplier',
    'auth_user_v1': jsonEncode(
      AuthUser(
        id: 'f1',
        fullName: 'Alassane Traoré',
        email: 'supplier@agriconnect.app',
        role: UserRole.supplier,
      ).toJson(),
    ),
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supplierRepositoryProvider.overrideWithValue(repository),
        photoPickerProvider.overrideWithValue(picker ?? FakePhotoPicker()),
        // The panel is dismissed by default so the dashboard layout tests keep
        // the geometry they assert; the dedicated welcome test opts out.
        supplierWelcomeStorageProvider.overrideWithValue(
          welcomeStorage ?? _FakeWelcomeStorage(seen: welcomeSeen),
        ),
      ],
      child: const AgriConnectApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
  return repository;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump();
}

/// Bottom navigation destination, scoped so it is never confused with a
/// dashboard quick action carrying the same wording.
Finder _navDestination(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// Quick action tile label, scoped to the dashboard grid for the same reason.
Finder _quickAction(String label) => find.descendant(
  of: find.byKey(const Key('supplierQuickActions')),
  matching: find.text(label),
);

Finder _statusChip(String label) => find.widgetWithText(FilterChip, label);

Finder _ordersStat(String label) => find.widgetWithText(StatCard, label);

/// Order card owning [id], so a status can be checked on that order only.
Finder _orderCard(String id) =>
    find.ancestor(of: find.text('Commande $id'), matching: find.byType(Card));

Finder _labelIn(Finder ancestor, String label) =>
    find.descendant(of: ancestor, matching: find.text(label));

/// Scrollable driving the screen under test.
///
/// The role shell keeps every branch alive in an `IndexedStack`, so the first
/// `Scrollable` of the tree usually belongs to another section. Scoping to the
/// visible page avoids dragging the wrong list.
Finder _primaryScrollable(WidgetTester tester) {
  final sheet = find.byType(SupplierOrderDetailPage);
  final root = sheet.evaluate().isNotEmpty
      ? sheet
      : find.byType(SupplierOrdersPage);
  return find.descendant(of: root, matching: find.byType(Scrollable)).first;
}

/// Scrolls [finder] into view inside the primary scrollable of the page.
///
/// The order list and the order sheet are lazy lists, so a target may not be
/// built at all yet and `ensureVisible` would throw on it. `scrollUntilVisible`
/// is unusable here: it walks one direction only and throws when the target
/// sits behind the current offset, which is the common case after a tap lower
/// in the list. The list is therefore swept from the top down, then from the
/// bottom up.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  Future<void> sweep(double step) async {
    for (var i = 0; i < 20 && finder.evaluate().isEmpty; i++) {
      await tester.drag(
        _primaryScrollable(tester),
        Offset(0, step),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
    }
  }

  await sweep(180); // back to the top of the list
  await sweep(-180); // then down to the target
  await sweep(180); // and back up for headers and banners

  if (finder.evaluate().isEmpty) {
    throw TestFailure('Target not found in the order space: $finder');
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}

/// Reveals a target, lets the layout settle, then taps it: a long card must
/// not be tapped while it is still half off-screen.
Future<void> _tapEnsured(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.tap(finder.first);
  await tester.pump();
}

/// Taps a target that sits at the bottom of the product form.
///
/// Two things get in the way of a plain tap there: a field still holds the
/// focus, and its `EditableText` keeps re-asserting its own visibility and drags
/// the form back up, and a `SnackBar` floats over the bottom of the screen.
/// Releasing the focus and letting a snack bar expire mirrors what a supplier
/// does before scrolling down, and lets `ensureVisible` finish its job.
Future<void> _tapBelowTheFold(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);
  FocusManager.instance.primaryFocus?.unfocus();
  if (find.byType(SnackBar).evaluate().isNotEmpty) {
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

/// Localized strings read from the mounted page.
///
/// Building the expected values with the real l10n and the real money
/// formatter keeps the assertions honest whatever the locale separators are.
/// The order sheet is a separate route, so the detail page is used as context
/// once the list has been left behind.
AppLocalizations _l10n(WidgetTester tester) {
  final sheet = find.byType(SupplierOrderDetailPage);
  final context = sheet.evaluate().isNotEmpty
      ? tester.element(sheet.first)
      : tester.element(find.byType(SupplierOrdersPage).first);
  return AppLocalizations.of(context);
}

/// Text scoped to the order sheet, so a total shared with the order list
/// behind it is never counted twice.
Finder _sheetText(String label) => find.descendant(
  of: find.byType(SupplierOrderDetailPage),
  matching: find.text(label),
);

/// The order total inside its own card.
///
/// A single line order prints the same amount twice, once as the line total
/// and once as the highlighted order total.
Finder _totalFigure(String amount, String totalLabel) => find.descendant(
  of: find.ancestor(of: _sheetText(totalLabel), matching: find.byType(Card)),
  matching: find.text(amount),
);

/// Bounding box of a quick action label, used by the responsive matrix.
Rect _quickActionRect(WidgetTester tester, String label) =>
    tester.getRect(_quickAction(label).first);

Future<void> _openSection(WidgetTester tester, String label) async {
  await tester.tap(_navDestination(label));
  await _settle(tester);
}

void main() {
  testWidgets('supplier dashboard shows the live overview and seeded data', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    expect(find.text("Vue d'ensemble"), findsOneWidget);
    expect(find.text('Produits déclarés'), findsOneWidget);
    expect(find.text('En attente de confirmation'), findsOneWidget);
    expect(find.text('Confirmées'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pump();
    expect(find.text('Tomates'), findsWidgets);
    expect(find.text('Aminata'), findsOneWidget);
  });

  testWidgets('products page lists statuses and opens the product form', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    await _openSection(tester, 'Mes produits');

    expect(find.text('Tomates'), findsWidgets);
    // The card carries the declaration status, not the availability: the
    // public listing is a separate concern that never leaks into the catalog.
    expect(
      find.descendant(
        of: find.byType(ProductCard),
        matching: find.text('En attente d\'examen'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(ProductCard),
        matching: find.text('Brouillon'),
      ),
      findsOneWidget,
    );
    expect(find.text('Nouveau produit'), findsOneWidget);

    await tester.tap(find.text('Nouveau produit'));
    await _settle(tester);

    expect(find.text('Product name'.toUpperCase()), findsNothing);
    expect(find.text('Nom du produit'), findsOneWidget);
    expect(find.text('Prix'), findsOneWidget);
    expect(find.text('Stock disponible'), findsOneWidget);
  });

  testWidgets('creates a product with a photo and sees it in the list', (
    tester,
  ) async {
    final picker = FakePhotoPicker();
    await _pumpSupplier(tester, picker: picker);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Nouveau produit'));
    await _settle(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Igname');
    await tester.enterText(fields.at(1), 'Igname fraîche');
    await tester.enterText(fields.at(2), '700');
    await tester.enterText(fields.at(3), '90');

    await _tapBelowTheFold(tester, find.text('Ajouter une photo'));
    await _settle(tester);

    expect(picker.calls, 1);
    // The picker is only asked for the room that is left, never the full quota.
    expect(picker.lastLimit, 5);
    // The picked picture is previewed, and the counter tracks the budget.
    expect(find.byType(ProductPhotoField), findsOneWidget);
    expect(find.text('1/5'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ProductPhotoField),
        matching: find.byType(Image),
      ),
      findsWidgets,
    );
    expect(find.text('Aucune photo pour le moment'), findsNothing);

    await _tapBelowTheFold(tester, find.text('Soumettre la déclaration'));
    await _settle(tester);

    expect(find.text('Igname'), findsWidgets);
    expect(
      find.text(
        'Déclaration soumise. Elle sera examinée avant toute publication.',
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('the form refuses an incomplete product and explains why', (
    tester,
  ) async {
    final repo = FakeSupplierRepository();
    await _pumpSupplier(tester, repo: repo);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Nouveau produit'));
    await _settle(tester);

    await _tapBelowTheFold(tester, find.text('Soumettre la déclaration'));
    await _settle(tester);

    expect(repo.productSaveCalls, 0);
    expect(
      find.text('Corrigez les champs signalés avant d\'enregistrer.'),
      findsOneWidget,
    );
    expect(find.text('Veuillez saisir un nom de produit.'), findsOneWidget);
    // Still on the form, so the supplier can fix the fields in place.
    expect(find.text('Soumettre la déclaration'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Igname');
    await tester.enterText(fields.at(2), '700');
    await tester.enterText(fields.at(3), '90');
    await _tapBelowTheFold(tester, find.text('Soumettre la déclaration'));
    await _settle(tester);

    expect(repo.productSaveCalls, 1);
  });

  testWidgets('a failed save keeps the fields and offers a retry', (
    tester,
  ) async {
    final repo = FakeSupplierRepository(
      productSaveThrows: const NetworkFailure(),
    );
    await _pumpSupplier(tester, repo: repo);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Nouveau produit'));
    await _settle(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Igname');
    await tester.enterText(fields.at(2), '700');
    await tester.enterText(fields.at(3), '90');

    await _tapBelowTheFold(tester, find.text('Soumettre la déclaration'));
    await _settle(tester);

    expect(repo.productSaveCalls, 1);
    expect(find.text("Le produit n'a pas été enregistré"), findsOneWidget);
    // Nothing typed is lost: the values are still in the fields.
    expect(
      tester.widget<TextFormField>(fields.at(0)).controller?.text,
      'Igname',
    );
    expect(find.text('Igname'), findsOneWidget);

    repo.productSaveThrows = null;
    await _tapBelowTheFold(tester, find.text('Réessayer'));
    await _settle(tester);

    expect(repo.productSaveCalls, 2);
    expect(find.text('Igname'), findsWidgets);
  });

  test('submitting twice reaches the repository once', () async {
    final gate = Completer<void>();
    final repo = FakeSupplierRepository(productSaveGate: gate);
    final container = ProviderContainer(
      overrides: [supplierRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final controller = container.read(productFormControllerProvider.notifier);
    final draft = ProductDraft(
      name: 'Igname',
      description: '',
      price: 700,
      stockQuantity: 90,
      unit: 'kg',
      photos: const [],
    );

    // Both calls start in the same frame, before the first one can complete:
    // the second must be turned down rather than queued behind the first.
    final first = controller.submit(
      draft: draft,
      declaration: DeclarationStatus.pendingReview,
    );
    final second = controller.submit(
      draft: draft,
      declaration: DeclarationStatus.pendingReview,
    );

    expect(container.read(productFormControllerProvider).isSaving, isTrue);
    expect(repo.productSaveCalls, 1);

    gate.complete();
    expect(await first, isNull);
    expect(await second, isNull);
    expect(repo.productSaveCalls, 1);
    expect(container.read(productFormControllerProvider).isSaving, isFalse);
  });

  testWidgets('a pending publish disables the call to action', (tester) async {
    final gate = Completer<void>();
    final repo = FakeSupplierRepository(productSaveGate: gate);
    await _pumpSupplier(tester, repo: repo);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Nouveau produit'));
    await _settle(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Igname');
    await tester.enterText(fields.at(2), '700');
    await tester.enterText(fields.at(3), '90');

    final publish = find.text('Soumettre la déclaration');
    await _tapBelowTheFold(tester, publish);
    // Second tap on the very spot the call to action occupied.
    await tester.tapAt(tester.getCenter(publish));
    await tester.pump();
    // The button swaps to its loading state, so it cannot be pressed again.
    await tester.pump(const Duration(milliseconds: 300));

    expect(repo.productSaveCalls, 1);
    expect(publish, findsNothing);
    expect(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    gate.complete();
    await _settle(tester);

    expect(repo.productSaveCalls, 1);
    expect(find.text('Igname'), findsWidgets);
  });

  testWidgets('a stock typed with spaces is saved without crashing', (
    tester,
  ) async {
    final repo = FakeSupplierRepository();
    await _pumpSupplier(tester, repo: repo);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Nouveau produit'));
    await _settle(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Igname espace');
    await tester.enterText(fields.at(2), '1 200');
    await tester.enterText(fields.at(3), '1 000');
    await tester.pump();
    expect(find.text('En vente'), findsOneWidget);

    await _tapBelowTheFold(tester, find.text('Soumettre la déclaration'));
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(repo.productSaveCalls, 1);

    final saved = tester
        .widgetList<ProductCard>(find.byType(ProductCard))
        .map((card) => card.product)
        .firstWhere((product) => product.name == 'Igname espace');
    expect(saved.stockQuantity, 1000);
    expect(saved.price, 1200);
  });

  testWidgets('a refused photo picker is reported and the form survives', (
    tester,
  ) async {
    final picker = FakePhotoPicker()..throws = Exception('camera denied');
    await _pumpSupplier(tester, picker: picker);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Nouveau produit'));
    await _settle(tester);

    await _tapBelowTheFold(tester, find.text('Ajouter une photo'));
    await _settle(tester);

    expect(
      find.text('Impossible de lire ces photos. Réessayez.'),
      findsWidgets,
    );
    // The section explains itself instead of staying blank.
    expect(find.text('0/5'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Igname');
    await tester.enterText(fields.at(2), '700');
    await tester.enterText(fields.at(3), '90');
    await _tapBelowTheFold(tester, find.text('Soumettre la déclaration'));
    await _settle(tester);

    expect(find.text('Igname'), findsWidgets);
  });

  testWidgets('editing a product updates the catalog from the same form', (
    tester,
  ) async {
    final repo = FakeSupplierRepository();
    await _pumpSupplier(tester, repo: repo);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Tomates').first);
    await _settle(tester);
    await tester.tap(find.text('Modifier le produit'));
    await _settle(tester);

    // Edition offers its own call to action, and the photo section is there.
    expect(find.text('Soumettre les modifications'), findsOneWidget);
    expect(find.byType(ProductPhotoField), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Tomates bio');
    // A stock of 0 flips the derived status without any status field.
    await tester.enterText(fields.at(3), '0');
    await tester.pump();
    expect(find.text('En rupture'), findsOneWidget);

    await _tapBelowTheFold(tester, find.text('Soumettre les modifications'));
    await _settle(tester);

    expect(repo.productSaveCalls, 1);
    expect(find.text('Tomates bio'), findsWidgets);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('the product form reflows from 320 px to desktop', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Nouveau produit'));
    await _settle(tester);

    for (final size in [
      const Size(320, 568),
      const Size(360, 640),
      const Size(390, 844),
      const Size(412, 915),
      const Size(430, 932),
      const Size(834, 1112),
      const Size(1280, 900),
    ]) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'overflow at $size');
      expect(find.text('Soumettre la déclaration'), findsOneWidget);
    }
  });

  testWidgets('editing a product that vanished explains how to recover', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/supplier/products',
      routes: [
        GoRoute(
          path: '/supplier',
          builder: (_, _) => const Scaffold(body: Text('supplier home')),
        ),
        GoRoute(
          path: '/supplier/product/new',
          builder: (_, _) => const SupplierProductFormPage(),
        ),
        GoRoute(
          path: '/supplier/products',
          builder: (_, _) => const Scaffold(body: Text('catalogue')),
        ),
        GoRoute(
          path: '/supplier/product/:productId/edit',
          builder: (_, state) => SupplierProductFormPage(
            productId: state.pathParameters['productId'],
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supplierRepositoryProvider.overrideWithValue(
            FakeSupplierRepository(products: const []),
          ),
          photoPickerProvider.overrideWithValue(FakePhotoPicker()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('fr'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/supplier/product/gone/edit');
    await tester.pumpAndSettle();

    expect(find.text('Produit introuvable'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets(
    'tapping a product opens a read-only sheet, edit is one tap away',
    (tester) async {
      await _pumpSupplier(tester);

      await _openSection(tester, 'Mes produits');

      await tester.tap(find.text('Tomates').first);
      await _settle(tester);

      expect(find.text('Nom du produit'), findsNothing);
      expect(find.text('Tomates de saison.'), findsOneWidget);
      expect(find.text('Unité'), findsOneWidget);
      expect(find.text('Déclaré le'), findsOneWidget);
      expect(find.textContaining('FCFA'), findsOneWidget);
      expect(find.text('Modifier le produit'), findsOneWidget);

      await tester.tap(find.text('Modifier le produit'));
      await _settle(tester);

      expect(find.text('Nom du produit'), findsOneWidget);
      final fields = find.byType(TextFormField);
      expect(
        tester.widget<TextFormField>(fields.at(0)).controller?.text,
        'Tomates',
      );
      expect(
        tester.widget<TextFormField>(fields.at(2)).controller?.text,
        '1200',
      );
    },
  );

  testWidgets('supplier screens lay out cleanly on a 320 px wide screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);

    await _pumpSupplier(tester);

    await _openSection(tester, 'Mes produits');

    await tester.tap(find.text('Tomates').first);
    await _settle(tester);

    await tester.tap(find.text('Modifier le produit'));
    await _settle(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await _settle(tester);

    // The form is pushed on top of the detail, so back lands on the detail.
    expect(find.text('Modifier le produit'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await _settle(tester);

    await _openSection(tester, 'Commandes');

    await _tapEnsured(tester, find.text('Aminata'));
    await _settle(tester);
    expect(find.text('Aminata'), findsWidgets);
  });

  testWidgets('confirming a pending order updates its status everywhere', (
    tester,
  ) async {
    final repo = await _pumpSupplier(tester);

    await _openSection(tester, 'Commandes');

    expect(find.text('Aminata'), findsOneWidget);
    expect(_labelIn(_orderCard('c1'), 'En attente'), findsOneWidget);
    expect(_statusChip('En attente'), findsOneWidget);

    await _tapEnsured(tester, find.text('Confirmer la commande'));
    await _settle(tester);

    expect(repo.confirmCalls, 1);
    expect(find.text('Commande confirmée avec succès.'), findsOneWidget);
    expect(_labelIn(_orderCard('c1'), 'Confirmée'), findsOneWidget);
    expect(_labelIn(_orderCard('c1'), 'En attente'), findsNothing);
    expect(_labelIn(_orderCard('c1'), 'Confirmer la commande'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('a failed confirmation is never retried automatically and offers '
      'verification', (tester) async {
    final repo = await _pumpSupplier(
      tester,
      repo: FakeSupplierRepository(confirmThrowsNetwork: true),
    );

    await _openSection(tester, 'Commandes');
    await _tapEnsured(tester, find.text('Confirmer la commande'));
    await _settle(tester);

    expect(repo.confirmCalls, 1);

    await _reveal(tester, find.text("La confirmation n'a pas abouti."));
    expect(find.text("La confirmation n'a pas abouti."), findsOneWidget);
    expect(find.text('Vérifier le statut'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    await _tapEnsured(tester, find.text('Réessayer'));
    await _settle(tester);
    expect(repo.confirmCalls, 2);

    await _tapEnsured(tester, find.text('Vérifier le statut'));
    await _settle(tester);
    expect(repo.confirmCalls, 2);
    expect(find.text("La confirmation n'a pas abouti."), findsNothing);
  });

  testWidgets('double tapping confirm sends a single request', (tester) async {
    final repo = FakeSupplierRepository(confirmGate: Completer<void>());
    await _pumpSupplier(tester, repo: repo);

    await _openSection(tester, 'Commandes');
    await _tapEnsured(tester, find.text('Confirmer la commande'));
    await tester.pump();

    expect(find.text('Confirmation…'), findsOneWidget);
    await tester.tap(find.text('Confirmation…'), warnIfMissed: false);
    await tester.pump();

    repo.confirmGate!.complete();
    await _settle(tester);

    expect(repo.confirmCalls, 1);
    await _reveal(tester, find.text('Commande c1'));
    expect(_labelIn(_orderCard('c1'), 'Confirmée'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('the orders page summarizes and filters the real statuses', (
    tester,
  ) async {
    await _pumpSupplier(tester);
    await _openSection(tester, 'Commandes');
    final l10n = _l10n(tester);

    // Header, revenue and the three status figures come from the real list.
    expect(
      find.text(l10n.ordersConfirmedRevenue(Money.format(15000))),
      findsOneWidget,
    );
    expect(_ordersStat('À confirmer'), findsOneWidget);
    expect(_ordersStat('Confirmées'), findsOneWidget);
    expect(_ordersStat('Annulées'), findsOneWidget);
    expect(find.text(l10n.ordersResultsCount(3)), findsOneWidget);

    await _tapEnsured(tester, _statusChip('En attente'));
    await _settle(tester);

    expect(find.text(l10n.ordersResultsCount(2)), findsOneWidget);
    await _reveal(tester, find.text('Aminata'));
    await _reveal(tester, find.text('Fatoumata'));
    expect(find.text('Souleymane'), findsNothing);

    await _tapEnsured(tester, _statusChip('Toutes'));
    await _settle(tester);

    expect(find.text(l10n.ordersResultsCount(3)), findsOneWidget);
    await _reveal(tester, find.text('Souleymane'));
  });

  testWidgets('a status figure filters the list it summarizes', (tester) async {
    await _pumpSupplier(tester);
    await _openSection(tester, 'Commandes');
    final l10n = _l10n(tester);

    await _tapEnsured(tester, _ordersStat('Confirmées'));
    await _settle(tester);

    expect(find.text(l10n.ordersResultsCount(1)), findsOneWidget);
    await _reveal(tester, find.text('Souleymane'));
    expect(find.text('Aminata'), findsNothing);
  });

  testWidgets('searching orders matches the buyer, the product and the id', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);

    await _pumpSupplier(tester);
    await _openSection(tester, 'Commandes');
    final l10n = _l10n(tester);

    // Searching from the results list: the field is rebuilt by the list, so it
    // is revealed again before every entry, then the card is checked.
    Future<void> search(String query) async {
      final field = find.byType(TextField);
      await _reveal(tester, field);
      await tester.enterText(field, query);
      await _settle(tester);
    }

    await search('souleymane');
    expect(find.text(l10n.ordersResultsCount(1)), findsOneWidget);
    await _reveal(tester, find.text('Souleymane'));
    expect(find.text('Aminata'), findsNothing);

    await search('tomates');
    expect(find.text(l10n.ordersResultsCount(2)), findsOneWidget);
    await _reveal(tester, find.text('Aminata'));
    expect(find.text('Souleymane'), findsNothing);

    await search('c3');
    expect(find.text(l10n.ordersResultsCount(1)), findsOneWidget);

    await search('zzz');

    expect(find.text('Aucune commande ne correspond'), findsOneWidget);
    expect(find.text(l10n.ordersResultsCount(0)), findsOneWidget);

    await _tapEnsured(tester, find.text('Réinitialiser'));
    await _settle(tester);

    expect(find.text(l10n.ordersResultsCount(3)), findsOneWidget);
    expect(find.text('Aucune commande ne correspond'), findsNothing);
  });

  testWidgets('the order sheet shows the summary, the buyer and the totals', (
    tester,
  ) async {
    await _pumpSupplier(tester);
    await _openSection(tester, 'Commandes');

    await _tapEnsured(tester, find.text('Commande c1'));
    await _settle(tester);
    final l10n = _l10n(tester);

    expect(_sheetText('Récapitulatif'), findsOneWidget);
    expect(_sheetText('c1'), findsOneWidget);
    expect(_sheetText('Articles'), findsOneWidget);
    expect(_sheetText(l10n.ordersArticlesCount(1, 10)), findsOneWidget);

    await _reveal(
      tester,
      _sheetText(l10n.ordersItemDetail(10, Money.format(1200))),
    );
    expect(
      _sheetText(l10n.ordersItemDetail(10, Money.format(1200))),
      findsOneWidget,
    );

    await _reveal(tester, _sheetText('Acheteur'));
    expect(_sheetText('Acheteur'), findsOneWidget);
    expect(_sheetText('aminata@example.com'), findsOneWidget);
    // The order carries a phone, so the row is displayed.
    expect(_sheetText('+225 07 00 11 22 33'), findsOneWidget);

    final total = _totalFigure(Money.format(12000), l10n.totalLabel);
    await _reveal(tester, total);
    expect(total, findsOneWidget);
    expect(_sheetText('Confirmer la commande'), findsOneWidget);
  });

  testWidgets('the order sheet retries a failed confirmation', (tester) async {
    final repo = await _pumpSupplier(
      tester,
      repo: FakeSupplierRepository(confirmThrowsNetwork: true),
    );

    await _openSection(tester, 'Commandes');
    await _tapEnsured(tester, find.text('Commande c1'));
    await _settle(tester);

    await _tapEnsured(tester, find.text('Confirmer la commande'));
    await _settle(tester);

    expect(repo.confirmCalls, 1);
    await _reveal(tester, find.text("La confirmation n'a pas abouti."));
    expect(find.text("La confirmation n'a pas abouti."), findsOneWidget);
    expect(find.text('Vérifier le statut'), findsOneWidget);

    await _tapEnsured(tester, find.text('Réessayer'));
    await _settle(tester);

    expect(repo.confirmCalls, 2);
  });

  testWidgets('a missing order offers a way out instead of a dead end', (
    tester,
  ) async {
    await _pumpSupplier(tester);
    await _openSection(tester, 'Commandes');
    await _settle(tester);

    // Deep link straight to an unknown order: the sheet must recover rather
    // than leave the supplier on a bare sentence.
    final router = GoRouter.of(
      tester.element(find.byType(SupplierOrdersPage).first),
    );
    router.go('/supplier/orders/does-not-exist');
    await _settle(tester);

    expect(find.text('Commande introuvable'), findsOneWidget);
    expect(find.text('Retour aux commandes'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    await tester.tap(find.text('Retour aux commandes'));
    await _settle(tester);

    // Back on the list, with the real orders and no leftover error state.
    expect(find.text('Commande c1'), findsWidgets);
    expect(find.text('Commande introuvable'), findsNothing);
  });

  testWidgets('the orders page reflows from 320 px to desktop', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const widths = [320.0, 360.0, 390.0, 412.0, 430.0, 800.0, 1280.0];

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 900);

      // The order sheet is a route of its own, and re-pumping the same widget
      // would keep the navigator state. An empty frame in between forces a
      // real remount, so every width starts from the shell.
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpSupplier(tester);
      await _openSection(tester, 'Commandes');
      final l10n = _l10n(tester);
      final total = _totalFigure(Money.format(12000), l10n.totalLabel);

      expect(find.byType(StatCard), findsNWidgets(3), reason: 'width $width');
      expect(
        find.text(l10n.ordersResultsCount(3)),
        findsOneWidget,
        reason: 'width $width',
      );
      expect(_statusChip('En attente'), findsOneWidget, reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');

      // The order sheet is the deepest layout of the space: it must also
      // survive the narrowest and the widest viewport.
      await _tapEnsured(tester, find.text('Commande c1'));
      await _settle(tester);

      await _reveal(tester, total);
      expect(total, findsOneWidget, reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('the products page reflows from 320 px to desktop', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const widths = [320.0, 360.0, 390.0, 412.0, 430.0, 800.0, 1280.0];

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 900);

      // Rerouting through an empty frame remounts the shell, so every width
      // starts from the same state instead of carrying the previous layout.
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpSupplier(tester);
      await _openSection(tester, 'Mes produits');

      final l10n = AppLocalizations.of(
        tester.element(find.byType(ProductCard).first),
      );

      // Every fact a supplier decides on lives on the card: the picture, the
      // name, the stock, the price and the status flag.
      final tomatoes = find.ancestor(
        of: find.text('Tomates'),
        matching: find.byType(ProductCard),
      );
      expect(tomatoes, findsOneWidget, reason: 'width $width');
      expect(
        find.descendant(of: tomatoes, matching: find.byType(ProductThumbnail)),
        findsOneWidget,
        reason: 'width $width',
      );
      expect(
        find.descendant(
          of: tomatoes,
          matching: find.text(l10n.productInStock(150, 'kg')),
        ),
        findsOneWidget,
        reason: 'width $width',
      );
      expect(
        find.descendant(of: tomatoes, matching: find.text(Money.format(1200))),
        findsOneWidget,
        reason: 'width $width',
      );
      expect(
        find.descendant(
          of: tomatoes,
          matching: find.text('En attente d\'examen'),
        ),
        findsOneWidget,
        reason: 'width $width',
      );

      expect(
        find.text('2 résultat(s)'),
        findsOneWidget,
        reason: 'width $width',
      );
      expect(_statusChip('En rupture'), findsOneWidget, reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('a product card survives a long name, a large price and larger '
      'fonts', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 900);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpSupplier(
      tester,
      repo: FakeSupplierRepository(
        products: [
          Product(
            id: 'long',
            name:
                'Tomates cerises allongées de la vallée du fleuve Sénégal '
                'récoltées à la main',
            description: 'Lot de saison cueilli à maturité, vendu par cagette.',
            price: 1250000,
            stockQuantity: 12500,
            unit: 'sac',
            createdAt: DateTime(2026, 9, 3),
          ),
        ],
      ),
    );

    await _openSection(tester, 'Mes produits');

    // The card compresses every text rather than letting the row overflow.
    expect(find.byType(ProductCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('searching and filtering the catalog narrows the results', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);

    await _pumpSupplier(tester);

    await _openSection(tester, 'Mes produits');

    expect(find.text('2 résultat(s)'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'manioc');
    await _settle(tester);

    expect(find.text('1 résultat(s)'), findsOneWidget);
    expect(find.text('Manioc'), findsWidgets);
    expect(find.text('Tomates'), findsNothing);

    await tester.enterText(find.byType(TextField).first, '');
    await _settle(tester);
    final outOfStockChip = find.widgetWithText(FilterChip, 'En rupture');
    await tester.ensureVisible(outOfStockChip);
    await _settle(tester);
    await tester.tap(outOfStockChip);
    await _settle(tester);

    expect(find.text('1 résultat(s)'), findsOneWidget);
    expect(find.text('Manioc'), findsWidgets);
    expect(find.text('Tomates'), findsNothing);

    await tester.tap(outOfStockChip);
    await _settle(tester);

    expect(find.text('2 résultat(s)'), findsOneWidget);
    expect(find.text('Tomates'), findsWidgets);
  });

  testWidgets('a search without any match explains how to recover', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    await _openSection(tester, 'Mes produits');

    await tester.enterText(find.byType(TextField).first, 'mangue');
    await _settle(tester);

    expect(find.text('Aucun produit trouvé'), findsOneWidget);
    expect(find.text('Tomates'), findsNothing);
  });

  testWidgets('leaving a modified form asks before dropping the changes', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Tomates').first);
    await _settle(tester);
    await tester.tap(find.text('Modifier le produit'));
    await _settle(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await _settle(tester);
    // An untouched form returns to the detail it was opened from.
    expect(find.text('Modifier le produit'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await _settle(tester);
    expect(find.text('Nouveau produit'), findsOneWidget);

    await tester.tap(find.text('Tomates').first);
    await _settle(tester);
    await tester.tap(find.text('Modifier le produit'));
    await _settle(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Tomates bio');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await _settle(tester);

    expect(find.text('Modifications non enregistrées'), findsOneWidget);

    await tester.tap(find.text('Continuer à modifier'));
    await _settle(tester);

    expect(find.text('Tomates bio'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await _settle(tester);
    await tester.tap(find.text('Quitter'));
    await _settle(tester);

    // Dropping the changes lands on the detail, with the saved name intact.
    expect(find.text('Modifier le produit'), findsOneWidget);
    expect(find.text('Tomates bio'), findsNothing);
  });

  testWidgets('a product with several pictures opens a swipeable gallery', (
    tester,
  ) async {
    final repo = FakeSupplierRepository(
      products: [
        Product(
          id: 'p9',
          name: 'Mangues',
          description: 'Mangues mûres.',
          price: 900,
          stockQuantity: 40,
          unit: 'kg',
          createdAt: DateTime(2026, 9, 5),
          photos: [
            PreparedPhoto(id: 'photo_a', name: 'a.png', bytes: _onePixelPng),
            PreparedPhoto(id: 'photo_b', name: 'b.png', bytes: _onePixelPng),
          ],
        ),
      ],
      orders: const [],
    );
    await _pumpSupplier(tester, repo: repo);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Mangues').first);
    await _settle(tester);

    expect(find.text('1/2'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('2/2'), findsOneWidget);
  });

  testWidgets('dashboard labels its on-sale count and exposes quick actions', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    expect(find.text('Produits actuellement en vente'), findsOneWidget);
    expect(find.text('Accès rapide'), findsOneWidget);

    for (final label in [
      'Ajouter un produit',
      'Mes produits',
      'Commandes reçues',
      'Messages',
    ]) {
      expect(_quickAction(label), findsOneWidget, reason: label);
    }

    await tester.tap(_quickAction('Ajouter un produit'));
    await _settle(tester);

    expect(find.text('Nom du produit'), findsOneWidget);
  });

  testWidgets(
    'dashboard sale metric counts only published in-stock products in FR and EN',
    (tester) async {
      const products = [
        Product(
          id: 'published-in-stock',
          name: 'Publié et en stock',
          price: 1000,
          stockQuantity: 12,
          unit: 'kg',
          declaration: DeclarationStatus.approvedForPublication,
          publicationStatus: ProductPublicationStatus.published,
        ),
        Product(
          id: 'published-out-of-stock',
          name: 'Publié mais épuisé',
          price: 1000,
          stockQuantity: 0,
          unit: 'kg',
          declaration: DeclarationStatus.approvedForPublication,
          publicationStatus: ProductPublicationStatus.published,
        ),
        Product(
          id: 'approved-not-published',
          name: 'Approuvé non publié',
          price: 1000,
          stockQuantity: 12,
          unit: 'kg',
          declaration: DeclarationStatus.approvedForPublication,
        ),
        Product(
          id: 'rejected',
          name: 'Rejeté',
          price: 1000,
          stockQuantity: 12,
          unit: 'kg',
          declaration: DeclarationStatus.rejected,
          publicationStatus: ProductPublicationStatus.published,
        ),
        Product(
          id: 'suspended',
          name: 'Suspendu',
          price: 1000,
          stockQuantity: 12,
          unit: 'kg',
          declaration: DeclarationStatus.approvedForPublication,
          publicationStatus: ProductPublicationStatus.suspended,
        ),
        Product(
          id: 'archived',
          name: 'Archivé',
          price: 1000,
          stockQuantity: 12,
          unit: 'kg',
          declaration: DeclarationStatus.approvedForPublication,
          publicationStatus: ProductPublicationStatus.archived,
        ),
      ];

      for (final (languageCode, label) in const [
        ('fr', 'Produits actuellement en vente'),
        ('en', 'Products currently on sale'),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await _pumpSupplier(
          tester,
          repo: FakeSupplierRepository(products: products),
          languageCode: languageCode,
        );
        await _settle(tester);

        final metric = find.byKey(const Key('supplierOnSaleMetric'));
        expect(
          find.descendant(of: metric, matching: find.text('1')),
          findsOneWidget,
          reason: languageCode,
        );
        expect(
          find.descendant(of: metric, matching: find.text(label)),
          findsOneWidget,
          reason: languageCode,
        );
      }
    },
  );

  testWidgets('quick actions reach the catalog, the orders and the messages', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    await tester.tap(_quickAction('Mes produits'));
    await _settle(tester);
    expect(find.text('En rupture'), findsWidgets);

    await _openSection(tester, 'Accueil');
    await tester.tap(_quickAction('Commandes reçues'));
    await _settle(tester);
    expect(find.text('Commandes'), findsWidgets);

    await _openSection(tester, 'Accueil');
    await tester.tap(_quickAction('Messages'));
    await _settle(tester);

    // The inbox is derived from the session, so the supplier reaches his own
    // conversations with buyers and drivers.
    expect(find.text('Marie Koné'), findsOneWidget);
    expect(find.text('Ibrahim Cissé'), findsOneWidget);
    expect(
      find.text('Commande de 5 sacs de riz demain matin.'),
      findsOneWidget,
    );
  });

  testWidgets('the messages action opens a thread and sends a message', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    await tester.tap(_quickAction('Messages'));
    await _settle(tester);
    await tester.tap(find.text('Marie Koné'));
    await _settle(tester);

    expect(
      find.text('Commande de 5 sacs de riz demain matin.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'Le riz est prêt.');
    await tester.tap(find.byTooltip('Envoyer'));
    await _settle(tester);

    expect(find.text('Le riz est prêt.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pulling the dashboard down refreshes products and orders', (
    tester,
  ) async {
    final repo = await _pumpSupplier(tester);

    final productsBefore = repo.fetchProductsCalls;
    final ordersBefore = repo.fetchOrdersCalls;

    await tester.fling(find.byType(ListView).first, const Offset(0, 260), 900);
    await tester.pumpAndSettle();

    expect(repo.fetchProductsCalls, greaterThan(productsBefore));
    expect(repo.fetchOrdersCalls, greaterThan(ordersBefore));
  });

  testWidgets('dashboard stacks its stats and quick actions on 320 px', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);

    await _pumpSupplier(tester);

    expect(find.text('Accès rapide'), findsOneWidget);
    expect(find.text('Produits actuellement en vente'), findsOneWidget);
    for (final label in [
      'Ajouter un produit',
      'Mes produits',
      'Commandes reçues',
      'Messages',
    ]) {
      expect(_quickAction(label), findsOneWidget, reason: label);
    }

    // On 320 px the four quick actions wrap over two rows, so the stats sit
    // just below the fold.
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    final stats = find.byType(StatCard);
    expect(stats, findsNWidgets(3));

    // Narrow layout: the leading metric takes the whole row, the two others
    // share the second one.
    final leading = tester.getSize(stats.at(0)).width;
    final secondary = tester.getSize(stats.at(1)).width;
    expect(leading, greaterThan(secondary * 1.5));

    expect(find.text('En attente de confirmation'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Tomates'), findsWidgets);
  });

  testWidgets('the four quick actions reflow from 320 px to desktop', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const widths = [320.0, 360.0, 390.0, 412.0, 430.0, 800.0, 1280.0];

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 900);
      await _pumpSupplier(tester);

      final add = _quickActionRect(tester, 'Ajouter un produit');
      final messages = _quickActionRect(tester, 'Messages');

      // Every label is readable and stays inside the viewport.
      expect(add.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(messages.right, lessThanOrEqualTo(width), reason: 'width $width');

      // A 1 px difference is expected: the outlined tiles inset their content
      // by half a border stroke, the primary one does not.
      final onOneRow = (messages.top - add.top).abs() < 2;
      final onTwoRows = messages.top > add.top + 20;

      if (width >= 400) {
        // Four across: the shortcuts share a single row.
        expect(onOneRow, isTrue, reason: 'width $width');
      } else {
        // Two per row: a 2x2 grid, and every tile still fits its column.
        expect(onTwoRows, isTrue, reason: 'width $width');
        expect(messages.left, greaterThan(add.left), reason: 'width $width');
      }

      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('the dashboard reports the real figures and confirmed revenue', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SupplierDashboardPage)),
    );

    // The three figures come straight from the seeded repository: two products
    // published, two orders awaiting confirmation and one already confirmed.
    expect(find.byType(StatCard), findsNWidgets(3));
    expect(
      find.descendant(of: find.byType(StatCard), matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(StatCard), matching: find.text('2')),
      findsNWidgets(2),
    );

    // The overview caption quotes the revenue actually recorded: the single
    // confirmed order is 30 x 500 FCFA.
    expect(
      find.text(l10n.ordersConfirmedRevenue(Money.format(15000, locale: 'fr'))),
      findsOneWidget,
    );
  });

  testWidgets('the header refresh control reloads the dashboard', (
    tester,
  ) async {
    final repo = await _pumpSupplier(tester);

    final productsBefore = repo.fetchProductsCalls;
    final ordersBefore = repo.fetchOrdersCalls;

    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pumpAndSettle();

    expect(repo.fetchProductsCalls, greaterThan(productsBefore));
    expect(repo.fetchOrdersCalls, greaterThan(ordersBefore));
  });

  testWidgets('the storefront call to action closes the dashboard', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SupplierDashboardPage)),
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, -1600));
    await tester.pumpAndSettle();

    // The closing banner quotes the real catalog size.
    expect(find.text(l10n.catalogTotalProducts(2)), findsOneWidget);

    await tester.tap(find.text(l10n.dashboardManageProducts));
    await _settle(tester);

    expect(find.text('En rupture'), findsWidgets);
  });

  testWidgets(
    'the dashboard stays centered and bounded from phone to desktop',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      for (final size in const [
        Size(320, 568),
        Size(360, 800),
        Size(390, 844),
        Size(412, 915),
        Size(600, 900),
        Size(900, 900),
        Size(1200, 900),
        Size(720, 900),
        Size(1024, 900),
        Size(1280, 900),
      ]) {
        tester.view.physicalSize = size;
        await _pumpSupplier(tester);
        // The tree is reused from the previous iteration, so the list has to be
        // brought back to the top before the header is checked again.
        await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'overflow at $size');
        expect(find.text('Accès rapide'), findsOneWidget, reason: '$size');
        expect(
          find.text('Produits actuellement en vente'),
          findsOneWidget,
          reason: '$size',
        );

        // The hero and the shortcut grid always stay inside the viewport.
        for (final key in const [
          Key('supplierHero'),
          Key('supplierQuickActions'),
        ]) {
          final rect = tester.getRect(find.byKey(key));
          expect(rect.left, greaterThanOrEqualTo(0), reason: '$key at $size');
          expect(
            rect.right,
            lessThanOrEqualTo(size.width),
            reason: '$key at $size',
          );
        }
        final heroRect = tester.getRect(find.byKey(const Key('supplierHero')));
        final expectedWidth = math.min(
          size.width - 2 * AppSizes.pagePadding,
          1080.0,
        );
        expect(heroRect.width, closeTo(expectedWidth, 1), reason: '$size');
        expect(heroRect.center.dx, closeTo(size.width / 2, 1), reason: '$size');

        // Reaching the end of the dashboard must not overflow the width either.
        await tester.drag(
          find.byType(ListView).first,
          Offset(0, -size.height * 3),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'overflow after scroll at $size',
        );

        final cta = find.byKey(const Key('supplierCatalogCta'));
        expect(cta, findsOneWidget, reason: '$size');
        final ctaRect = tester.getRect(cta);
        expect(ctaRect.left, greaterThanOrEqualTo(0), reason: '$size');
        expect(ctaRect.right, lessThanOrEqualTo(size.width), reason: '$size');
      }
    },
  );

  testWidgets('the supplier dashboard remains usable with enlarged text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpSupplier(tester);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('supplierHero')), findsOneWidget);
    expect(find.byKey(const Key('supplierQuickActions')), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -1800));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('supplierCatalogCta')), findsOneWidget);
  });

  testWidgets('the order sheet waits for the data before calling it missing', (
    tester,
  ) async {
    final ordersGate = Completer<void>();
    final repo = FakeSupplierRepository(ordersGate: ordersGate);
    await _pumpSupplier(tester, repo: repo);
    await _openSection(tester, 'Commandes');

    // The order route is reached while the orders are still loading: the sheet
    // must show a loading state instead of announcing a missing order.
    GoRouter.of(
      tester.element(find.byType(SupplierOrdersPage).first),
    ).go('/supplier/orders/c1');
    await _settle(tester);

    expect(find.text('Commande introuvable'), findsNothing);
    expect(find.byType(CardListSkeleton), findsOneWidget);

    ordersGate.complete();
    await _settle(tester);

    expect(find.text('Commande c1'), findsWidgets);
  });

  testWidgets('the order sheet offers a way back to the list', (tester) async {
    await _pumpSupplier(tester);
    await _openSection(tester, 'Commandes');

    // The sheet is a root route reached with `go`, so the navigator has nothing
    // to pop: without an explicit back button the supplier is stuck on it.
    GoRouter.of(
      tester.element(find.byType(SupplierOrdersPage).first),
    ).go('/supplier/orders/c1');
    await _settle(tester);

    expect(find.byType(SupplierOrderDetailPage), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await _settle(tester);

    expect(find.byType(SupplierOrderDetailPage), findsNothing);
    expect(find.byType(SupplierOrdersPage), findsOneWidget);
  });

  testWidgets('the inbox and the thread both lead back where they came from', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    await tester.tap(_quickAction('Messages'));
    await _settle(tester);

    // The inbox is outside the shell, reached from a quick action.
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    await tester.tap(find.text('Marie Koné'));
    await _settle(tester);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await _settle(tester);
    expect(find.text('Marie Koné'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await _settle(tester);

    // Both back buttons land on the dashboard, not on a dead end.
    expect(find.text("Vue d'ensemble"), findsOneWidget);
  });

  testWidgets('the creation button never covers the last product', (
    tester,
  ) async {
    await _pumpSupplier(tester);
    await _openSection(tester, 'Mes produits');

    final lastCard = find.byType(ProductCard).last;
    final fab = find.byType(FloatingActionButton);

    // The button floats, so it necessarily passes over the list while the
    // list scrolls. What matters is the resting position: the last product has
    // to end up completely above it, still fully tappable.
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await _settle(tester);

    expect(tester.getRect(lastCard).overlaps(tester.getRect(fab)), isFalse);
    expect(
      tester.getRect(lastCard).bottom,
      lessThanOrEqualTo(tester.getRect(fab).top),
    );
  });

  testWidgets('an empty result offers to drop the criteria at once', (
    tester,
  ) async {
    await _pumpSupplier(tester);
    await _openSection(tester, 'Mes produits');

    await tester.enterText(find.byType(TextField).first, 'mangue');
    await _settle(tester);

    expect(find.text('Aucun produit trouvé'), findsOneWidget);
    // A search that finds nothing is a dead end of its own: the supplier has to be
    // able to come back to the whole catalog.
    expect(find.text('Réinitialiser'), findsOneWidget);

    await _tapBelowTheFold(tester, find.text('Réinitialiser'));
    await _settle(tester);

    expect(find.text('Tomates'), findsWidgets);
    expect(find.text('Aucun produit trouvé'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );
  });

  testWidgets('the field follows the criteria when they change elsewhere', (
    tester,
  ) async {
    await _pumpSupplier(tester);
    await _openSection(tester, 'Mes produits');

    await tester.enterText(find.byType(TextField).first, 'riz');
    await _settle(tester);
    expect(find.text('Tomates'), findsNothing);

    // The "all" chip clears the criteria behind the field's back: a stale term
    // left on screen would promise a search that no longer applies.
    await tester.tap(_statusChip('Toutes'));
    await _settle(tester);

    expect(find.text('Tomates'), findsWidgets);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );
  });

  testWidgets('saving a draft keeps the declaration out of publication', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Nouveau produit'));
    await _settle(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Igname');
    await tester.enterText(fields.at(2), '700');
    await tester.enterText(fields.at(3), '90');

    await _tapBelowTheFold(tester, find.text('Enregistrer le brouillon'));
    await _settle(tester);

    expect(
      find.text(
        'Brouillon enregistré. Il n\'est pas visible par les acheteurs.',
      ),
      findsOneWidget,
    );

    // The declaration is stored as a draft: nothing the supplier did here can
    // turn it into a public listing on its own.
    final saved = tester
        .widgetList<ProductCard>(find.byType(ProductCard))
        .map((card) => card.product)
        .firstWhere((product) => product.name == 'Igname');
    expect(saved.declaration, DeclarationStatus.draft);
    expect(saved.isPublished, isFalse);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('submitting a declaration sends it for review, never to sale', (
    tester,
  ) async {
    await _pumpSupplier(tester);

    await _openSection(tester, 'Mes produits');
    await tester.tap(find.text('Nouveau produit'));
    await _settle(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Igname');
    await tester.enterText(fields.at(2), '700');
    await tester.enterText(fields.at(3), '90');

    await _tapBelowTheFold(tester, find.text('Soumettre la déclaration'));
    await _settle(tester);

    final saved = tester
        .widgetList<ProductCard>(find.byType(ProductCard))
        .map((card) => card.product)
        .firstWhere((product) => product.name == 'Igname');
    expect(saved.declaration, DeclarationStatus.pendingReview);
    // Only the platform can ever approve a declaration for publication.
    expect(saved.isPublished, isFalse);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('the welcome panel greets once and remembers the dismissal', (
    tester,
  ) async {
    final storage = _FakeWelcomeStorage();
    await _pumpSupplier(tester, welcomeSeen: false, welcomeStorage: storage);

    expect(find.text('Bienvenue sur votre espace fournisseur'), findsOneWidget);
    expect(storage.writes, 0);

    await _tapBelowTheFold(tester, find.text('Accéder au tableau de bord'));
    await _settle(tester);

    expect(find.text('Bienvenue sur votre espace fournisseur'), findsNothing);
    expect(storage.seen, isTrue);
    expect(storage.writes, 1);

    // A later visit, with the choice remembered, starts without the panel.
    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpSupplier(tester, welcomeSeen: false, welcomeStorage: storage);
    expect(find.text('Bienvenue sur votre espace fournisseur'), findsNothing);
  });
}

/// In-memory welcome storage, so the panel's persistence can be observed.
class _FakeWelcomeStorage implements SupplierWelcomeStorage {
  _FakeWelcomeStorage({this.seen = false});

  bool seen;
  int writes = 0;

  @override
  Future<bool> readSeen() async => seen;

  @override
  Future<void> writeSeen(bool value) async {
    writes++;
    seen = value;
  }
}
