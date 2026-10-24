import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/media/photo_picker.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/buyer/application/buyer_providers.dart';
import 'package:agri_connect/features/buyer/data/buyer_welcome_storage.dart';
import 'package:agri_connect/features/buyer/data/demo_buyer_repository.dart';
import 'package:agri_connect/features/buyer/domain/buyer_order.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';
import 'package:agri_connect/features/buyer/presentation/pages/buyer_orders_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/cart_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/catalog_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/checkout_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/order_confirmation_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/order_detail_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/product_detail_page.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/buyer_hero.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_filter_bar.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_product_card.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_search_field.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/category_artwork.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/featured_product_card.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/recent_order_tile.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/tracking_timeline.dart';
import 'package:agri_connect/features/chat/presentation/chat_thread_page.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_product_form_page.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/stat_card.dart';

import 'support/fakes.dart';

Future<FakeBuyerRepository> _pumpBuyer(
  WidgetTester tester, {
  FakeBuyerRepository? repo,
  FakePhotoPicker? picker,
  String languageCode = 'fr',
  bool welcomeSeen = true,
  BuyerWelcomeStorage? welcomeStorage,
}) async {
  final repository = repo ?? FakeBuyerRepository();
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': languageCode,
    'welcome_selected_role_v1': 'buyer',
    'auth_user_v1': jsonEncode(
      AuthUser(
        id: 'demo_buyer',
        fullName: 'Marie Koné',
        email: 'buyer@agriconnect.app',
        role: UserRole.buyer,
      ).toJson(),
    ),
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        buyerRepositoryProvider.overrideWithValue(repository),
        photoPickerProvider.overrideWithValue(picker ?? FakePhotoPicker()),
        // The panel is dismissed by default so the dashboard layout tests keep
        // the geometry they assert; the dedicated welcome test opts out.
        buyerWelcomeStorageProvider.overrideWithValue(
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

/// Reaches the catalog and opens the "Tomates fraîches" product.
Future<void> _openTomatoes(WidgetTester tester) async {
  await tester.tap(find.text('Catalogue'));
  await _settle(tester);
  await tester.drag(find.byType(ListView).first, const Offset(0, -400));
  await tester.pump();
  await tester.tap(find.text('Tomates fraîches').first);
  await _settle(tester);
}

/// Adds the opened product and lands on the cart, the way the funnel is walked.
Future<void> _addAndGoToCart(WidgetTester tester) async {
  await tester.tap(find.text('Ajouter au panier'));
  await _settle(tester);
  await tester.tap(find.text('Commander'));
  await _settle(tester);
  expect(find.byType(CartPage), findsOneWidget);
}

/// Opens any product from the catalog through the search field.
///
/// [navigate] is false when the catalog is already on screen: the tab label and
/// the page title then carry the same wording.
Future<void> _openProduct(
  WidgetTester tester,
  String name, {
  bool navigate = true,
}) async {
  if (navigate) await _openCatalog(tester);
  await tester.enterText(
    find.descendant(
      of: find.byType(CatalogPage),
      matching: find.byType(TextField),
    ),
    name,
  );
  await _settle(tester);
  // Scoped to the card: the query typed above is a text of its own.
  final card = find.descendant(
    of: find.byType(CatalogProductCard),
    matching: find.text(name),
  );
  expect(card, findsOneWidget);
  // A previous visit can leave the list scrolled, and a card that no longer
  // fits the viewport is tappable nowhere: bring the list back to its top.
  await tester.drag(
    find
        .descendant(
          of: find.byType(CatalogPage),
          matching: find.byType(ListView),
        )
        .first,
    const Offset(0, 600),
  );
  await _settle(tester);
  await tester.ensureVisible(card);
  await _settle(tester);
  await tester.tap(card);
  await _settle(tester);
  expect(find.byType(ProductDetailPage), findsOneWidget);
}

/// Delivery fields of the checkout, scoped to it.
///
/// The buyer shell stays mounted under the pushed funnel, so an unscoped
/// `find.byType(TextFormField)` also matches the catalog search field.
Finder _checkoutFields(WidgetTester tester) => find.descendant(
  of: find.byType(CheckoutPage),
  matching: find.byType(TextFormField),
);

void main() {
  testWidgets('buyer dashboard shows the overview, featured catalog and '
      'recent orders', (tester) async {
    await _pumpBuyer(tester);

    expect(find.text('Bonjour, Marie'), findsOneWidget);
    expect(find.text("Vue d'ensemble"), findsOneWidget);
    expect(find.text('Commandes actives'), findsOneWidget);
    expect(find.text('En transit'), findsWidgets);
    expect(find.text('Livrées'), findsWidgets);
    expect(find.text('Tomates fraîches'), findsWidgets);

    await tester.scrollUntilVisible(
      find.textContaining('2 article(s)'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.textContaining('2 article(s)'), findsOneWidget);
    expect(find.text(Money.format(15200)), findsOneWidget);
  });

  testWidgets('the dashboard counts the orders that are still moving', (
    tester,
  ) async {
    _useTallWindow(tester);
    await _pumpBuyer(tester);

    // "Active" is what the orders list calls "En cours": the two orders still
    // on their way (one pending, one in transit) are counted, the delivered
    // and cancelled ones are not. The two screens must answer the same
    // question with the same figure.
    expect(_statValue(tester, 'Commandes actives'), '2');
    expect(_statValue(tester, 'En transit'), '1');
    expect(_statValue(tester, 'Livrées'), '1');
  });

  testWidgets('catalog searches and filters by category and location', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    await tester.tap(find.text('Catalogue'));
    await _settle(tester);

    await tester.enterText(find.byType(TextField), 'riz');
    await tester.pump();
    expect(find.text('1 résultat(s)'), findsOneWidget);
    expect(find.text('Riz local'), findsOneWidget);
    expect(find.text('Tomates fraîches'), findsNothing);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    // Scoped to the filter row: the category also labels the product cards.
    await tester.tap(
      find.descendant(
        of: find.byType(CatalogCategoryFilter),
        matching: find.text('Légumes'),
      ),
    );
    await tester.pump();
    expect(find.text('2 résultat(s)'), findsOneWidget);
    expect(find.text('Tomates fraîches'), findsOneWidget);
    expect(find.text('Oignons rouges'), findsOneWidget);

    final korhogo = find.widgetWithText(FilterChip, 'Korhogo');
    await tester.ensureVisible(korhogo);
    await tester.pump();
    await tester.tap(korhogo);
    await tester.pump();
    expect(find.text('1 résultat(s)'), findsOneWidget);
    expect(find.text('Oignons rouges'), findsOneWidget);
    expect(find.text('Tomates fraîches'), findsNothing);
  });

  testWidgets('dashboard search opens the catalog with its query applied', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    final searchField = find.descendant(
      of: find.byType(CatalogSearchField),
      matching: find.byType(TextField),
    );
    await tester.enterText(searchField, 'riz');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await _settle(tester);

    expect(find.byType(CatalogPage), findsOneWidget);
    expect(find.text('1 résultat(s)'), findsOneWidget);
    expect(find.text('Riz local'), findsOneWidget);
    expect(find.text('Tomates fraîches'), findsNothing);
    final catalogSearchField = find.descendant(
      of: find.byType(CatalogPage),
      matching: find.byType(CatalogSearchField),
    );
    final catalogTextField = find.descendant(
      of: catalogSearchField,
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(catalogTextField).controller?.text, 'riz');
  });

  testWidgets('dashboard category opens the catalog with the category active', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    final vegetables = find.descendant(
      of: find.byType(CatalogCategoryFilter),
      matching: find.text('Légumes'),
    );
    await tester.tap(vegetables);
    await _settle(tester);

    expect(find.byType(CatalogPage), findsOneWidget);
    expect(find.text('2 résultat(s)'), findsOneWidget);
    expect(find.text('Tomates fraîches'), findsOneWidget);
    expect(find.text('Oignons rouges'), findsOneWidget);
    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Légumes'))
          .selected,
      isTrue,
    );
  });

  testWidgets('product detail picks a quantity and goes to the cart', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    await _openTomatoes(tester);

    expect(find.text('Ajouter au panier'), findsOneWidget);
    expect(find.text('Commander'), findsOneWidget);
    expect(find.text(Money.format(1200)), findsWidgets);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    await tester.tap(find.text('Commander'));
    await _settle(tester);

    expect(find.text('Panier'), findsOneWidget);
    expect(find.text(Money.format(3600)), findsWidgets);
    // Once on the cart the name belongs to the single line of the cart.
    expect(find.text('Tomates fraîches'), findsOneWidget);
  });

  testWidgets('cart adjusts quantities, removes lines and clears', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    await _openTomatoes(tester);
    await tester.tap(find.text('Commander'));
    await _settle(tester);

    expect(find.text(Money.format(1200)), findsWidgets);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(find.text(Money.format(2400)), findsWidgets);

    await tester.tap(find.byTooltip('Retirer du panier'));
    await tester.pump();

    expect(find.text('Panier vide'), findsOneWidget);
    expect(find.text('Voir le catalogue'), findsOneWidget);

    await tester.tap(find.text('Voir le catalogue'));
    await _settle(tester);

    expect(find.text('Catalogue'), findsWidgets);
  });

  testWidgets('checkout places the order, confirms it and opens tracking', (
    tester,
  ) async {
    final repo = await _pumpBuyer(tester);

    await _openTomatoes(tester);
    await tester.tap(find.text('Commander'));
    await _settle(tester);
    await tester.tap(find.text('Valider la commande'));
    await _settle(tester);

    final fields = _checkoutFields(tester);
    await tester.enterText(fields.at(0), 'Boulevard du Commerce, Zone 4');
    await tester.enterText(fields.at(1), '+225 07 01 23 45 67');

    await tester.ensureVisible(find.text('Passer la commande'));
    await tester.tap(find.text('Passer la commande'));
    await _settle(tester);

    expect(repo.placeOrderCalls, 1);

    // The funnel ends on a real confirmation, not on a snackbar.
    expect(find.byType(OrderConfirmationPage), findsOneWidget);
    expect(find.text('Merci, votre commande est enregistrée.'), findsOneWidget);
    expect(find.textContaining('1 article(s)'), findsWidgets);
    expect(find.textContaining('Commande b_'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Le vendeur prépare vos produits'),
      200,
    );
    expect(find.text('Et maintenant ?'), findsOneWidget);
    expect(find.text('Un livreur est assigné à la livraison'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Boulevard du Commerce, Zone 4'),
      200,
    );
    expect(find.text('Boulevard du Commerce, Zone 4'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Suivre ma commande'), 200);
    await tester.tap(find.text('Suivre ma commande'));
    await _settle(tester);

    expect(find.byType(OrderDetailPage), findsOneWidget);
    expect(find.text('Suivi de livraison'), findsOneWidget);
    expect(find.textContaining('Commande b_'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('a failed checkout keeps the cart intact', (tester) async {
    final repo = await _pumpBuyer(
      tester,
      repo: FakeBuyerRepository(placeThrowsNetwork: true),
    );

    await _openTomatoes(tester);
    await tester.tap(find.text('Commander'));
    await _settle(tester);
    await tester.tap(find.text('Valider la commande'));
    await _settle(tester);

    final fields = _checkoutFields(tester);
    await tester.enterText(fields.at(0), 'Marché de Treichville, allée 3');
    await tester.enterText(fields.at(1), '+225 07 01 23 45 67');

    await tester.ensureVisible(find.text('Passer la commande'));
    await tester.tap(find.text('Passer la commande'));
    await _settle(tester);

    expect(repo.placeOrderCalls, 1);
    // The failure is not only a snackbar: it stays on the screen next to the
    // button, and the typed address is not lost.
    expect(find.text('Commande non passée'), findsOneWidget);
    // Said once: an inline notice plus a snackbar would repeat the same sentence
    // in two places, and the snackbar would cover the form.
    expect(
      find.text('Erreur réseau. Vérifiez votre connexion.'),
      findsOneWidget,
    );
    expect(find.byType(OrderConfirmationPage), findsNothing);
    expect(find.text('Articles'), findsOneWidget);
    expect(find.text(Money.format(1200)), findsWidgets);
    expect(_checkoutFields(tester).at(0), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(_checkoutFields(tester).at(0))
          .controller
          ?.text,
      'Marché de Treichville, allée 3',
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('in-transit order detail exposes the driver contact sheet', (
    tester,
  ) async {
    String? copiedNumber;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedNumber =
              (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await _pumpBuyer(tester);

    await tester.tap(find.text('Commandes'));
    await _settle(tester);

    expect(find.text('Riz local'), findsOneWidget);
    expect(find.text('En transit'), findsOneWidget);

    await tester.tap(find.text('Riz local'));
    await _settle(tester);

    await tester.scrollUntilVisible(find.text('Contacter le chauffeur'), 200);
    await tester.pump();
    await tester.tap(find.text('Contacter le chauffeur'));
    await _settle(tester);

    expect(find.text('Kouamé Yao'), findsWidgets);
    expect(find.text('+225 07 12 34 56 78'), findsWidgets);
    expect(find.text('Camion frigorifique · AB-123-CD'), findsWidgets);

    await tester.tap(find.text('Copier le numéro'));
    await _settle(tester);

    expect(copiedNumber, '+225 07 12 34 56 78');
    expect(find.text('Numéro copié.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('the purchase funnel can be walked back step by step', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    await _openTomatoes(tester);
    expect(find.byType(ProductDetailPage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await _settle(tester);
    expect(find.byType(CatalogPage), findsOneWidget);

    await tester.tap(find.text('Tomates fraîches').first);
    await _settle(tester);
    await tester.tap(find.text('Ajouter au panier'));
    await _settle(tester);
    await tester.tap(find.text('Commander'));
    await _settle(tester);

    expect(find.byType(CartPage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await _settle(tester);
    expect(find.byType(ProductDetailPage), findsOneWidget);

    // The line is already in the cart: ordering only walks the buyer there.
    await tester.tap(find.text('Commander'));
    await _settle(tester);
    expect(find.byType(CartPage), findsOneWidget);
    expect(find.text('1 article(s)'), findsWidgets);

    await tester.tap(find.text('Valider la commande'));
    await _settle(tester);
    expect(find.byType(CheckoutPage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('the checkout hands the cart back to edit it', (tester) async {
    await _pumpBuyer(tester);

    await _openTomatoes(tester);
    await _addAndGoToCart(tester);
    await tester.tap(find.text('Valider la commande'));
    await _settle(tester);

    await tester.tap(find.text('Modifier le panier'));
    await _settle(tester);

    expect(find.byType(CartPage), findsOneWidget);
    expect(find.text('Tomates fraîches'), findsWidgets);
  });

  testWidgets('the detail tells what the cart already holds', (tester) async {
    await _pumpBuyer(tester);

    await _openTomatoes(tester);
    expect(find.text('Déjà dans le panier · 0'), findsNothing);

    // Two in one go, so the cart is not asked to grow twice in a row.
    await tester.tap(find.byIcon(Icons.add_rounded));
    await _settle(tester);
    await tester.tap(find.text('Ajouter au panier'));
    await _settle(tester);

    // Back to the catalog and in again: the detail reflects the real cart.
    await tester.tap(find.byType(BackButton));
    await _settle(tester);
    await _openProduct(tester, 'Tomates fraîches', navigate: false);

    expect(find.text('Déjà dans le panier · 2'), findsOneWidget);

    // Ordering from a page the buyer came back to does not grow the line.
    await tester.tap(find.text('Commander'));
    await _settle(tester);
    expect(find.byType(CartPage), findsOneWidget);
    expect(find.text('2 article(s)'), findsWidgets);
  });

  testWidgets('an out of stock product cannot be bought from its detail', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    await _openProduct(tester, 'Manioc frais');

    expect(find.text('En rupture'), findsWidgets);

    // Both actions are dead: a disabled button ignores the tap entirely.
    for (final label in ['Ajouter au panier', 'Commander']) {
      await tester.tap(find.text(label));
      await _settle(tester);
    }
    expect(find.byType(ProductDetailPage), findsOneWidget);
    expect(find.byType(CartPage), findsNothing);

    // The quantity control is inert rather than promising unavailable stock.
    await tester.tap(find.byIcon(Icons.add_rounded));
    await _settle(tester);
    expect(find.text('En rupture'), findsWidgets);
  });

  testWidgets('the cart asks before it empties itself', (tester) async {
    await _pumpBuyer(tester);

    await _openTomatoes(tester);
    await _addAndGoToCart(tester);

    await tester.tap(find.text('Vider'));
    await _settle(tester);
    expect(find.text('Vider le panier ?'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await _settle(tester);
    expect(find.text('Tomates fraîches'), findsWidgets);

    await tester.tap(find.text('Vider'));
    await _settle(tester);
    await tester.tap(find.text('Vider le panier').last);
    await _settle(tester);

    expect(find.text('Panier vide'), findsOneWidget);
    expect(find.text('Voir le catalogue'), findsOneWidget);
  });

  testWidgets('the cart counts its items and caps a line at the stock', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    await _openTomatoes(tester);
    await tester.tap(find.text('Commander'));
    await _settle(tester);
    expect(find.byType(CartPage), findsOneWidget);

    expect(find.text('1 article(s)'), findsWidgets);

    // Scoped to the cart: the shell below the pushed route still holds cards
    // of its own.
    final stepper = find.descendant(
      of: find.byType(CartPage),
      matching: find.byIcon(Icons.add_rounded),
    );
    await tester.tap(stepper);
    await _settle(tester);
    expect(find.text('2 article(s)'), findsWidgets);
    expect(find.text(Money.format(2400)), findsWidgets);

    // Bump the line up to the available stock: the cap is announced.
    for (var i = 0; i < 148; i++) {
      await tester.tap(stepper);
    }
    await _settle(tester);
    expect(find.text('150 article(s)'), findsWidgets);
    expect(find.text('Stock disponible : 150'), findsOneWidget);
  });

  testWidgets('the checkout recap adds up, line by line', (tester) async {
    await _pumpBuyer(tester);

    // Two lines with different prices: their totals are then worth checking
    // against the grand total, which is the whole point of a recap.
    await _openTomatoes(tester);
    await tester.tap(find.text('Ajouter au panier'));
    await _settle(tester);
    await tester.tap(find.byType(BackButton));
    await _settle(tester);
    await _openProduct(tester, 'Riz local', navigate: false);
    await tester.tap(find.text('Ajouter au panier'));
    await _settle(tester);

    await tester.tap(find.text('Commander'));
    await _settle(tester);
    expect(find.byType(CartPage), findsOneWidget);

    await tester.tap(find.text('Valider la commande'));
    await _settle(tester);

    final recap = find.descendant(
      of: find.byType(CheckoutPage),
      matching: find.byType(Card),
    );
    // Scoped to the page: its own text fields scroll internally, and
    // scrollUntilVisible needs to know which scroller to drive.
    final pageScroller = find
        .descendant(
          of: find.byType(CheckoutPage),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text(Money.format(2200)),
      200,
      scrollable: pageScroller,
    );

    // Every line states its own total, so the figure at the bottom can be
    // checked instead of taken on faith: 1 200 and 1 000 are the line totals,
    // and 2 200 their sum, which nothing but the total row states.
    expect(find.text(Money.format(1200)), findsOneWidget);
    expect(find.text(Money.format(1000)), findsOneWidget);
    expect(find.text(Money.format(2200)), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(recap, findsWidgets);
  });

  testWidgets('a product that left the catalog offers the catalog back', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go(RoutePaths.buyerProduct('unknown'));
    await _settle(tester);

    expect(find.text('Produit introuvable'), findsOneWidget);
    await tester.tap(find.text('Voir le catalogue'));
    await _settle(tester);

    expect(find.byType(CatalogPage), findsOneWidget);
  });

  testWidgets('the confirmation owns its way out of the funnel', (
    tester,
  ) async {
    final repo = await _pumpBuyer(tester);

    await _openTomatoes(tester);
    await _addAndGoToCart(tester);
    await tester.tap(find.text('Valider la commande'));
    await _settle(tester);

    final fields = _checkoutFields(tester);
    await tester.enterText(fields.at(0), 'Rue des Jardins, Cocody');
    await tester.enterText(fields.at(1), '+225 07 00 11 22 33');
    await tester.ensureVisible(find.text('Passer la commande'));
    await tester.tap(find.text('Passer la commande'));
    await _settle(tester);

    expect(repo.placeOrderCalls, 1);
    expect(find.byType(OrderConfirmationPage), findsOneWidget);
    // Nothing to go back to: the step before is an emptied checkout.
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.text('Continuer mes achats'));
    await _settle(tester);
    expect(find.byType(CatalogPage), findsOneWidget);
  });

  testWidgets('the whole funnel survives 320 px and a large text scale', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 900);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpBuyer(tester);
    await _openTomatoes(tester);
    expect(tester.takeException(), isNull);

    await _addAndGoToCart(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Valider la commande'));
    await _settle(tester);
    expect(find.byType(CheckoutPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    final fields = _checkoutFields(tester);
    await tester.enterText(fields.at(0), 'Rue des Jardins, Cocody');
    await tester.enterText(fields.at(1), '+225 07 00 11 22 33');
    await tester.ensureVisible(find.text('Passer la commande'));
    await tester.tap(find.text('Passer la commande'));
    await _settle(tester);

    expect(find.byType(OrderConfirmationPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the four quick actions reach their real destinations', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    expect(find.byKey(const Key('buyerQuickActions')), findsOneWidget);
    expect(find.text('Explorer les produits'), findsOneWidget);
    expect(find.text('Mon panier'), findsOneWidget);
    expect(find.text('Mes commandes'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);

    await _tapQuickAction(tester, 'Explorer les produits');
    expect(find.text('Catalogue'), findsWidgets);
    expect(find.text('Riz local'), findsWidgets);

    await _backToDashboard(tester);
    await _tapQuickAction(tester, 'Mon panier');
    expect(find.text('Panier vide'), findsOneWidget);

    await _backToDashboard(tester);
    await _tapQuickAction(tester, 'Mes commandes');
    expect(find.byType(BuyerOrdersPage), findsOneWidget);

    await _backToDashboard(tester);
    await _tapQuickAction(tester, 'Messages');
    // The buyer reaches his own conversation with a supplier.
    expect(find.text('Alassane Traoré'), findsOneWidget);
    expect(
      find.text('Les tomates sont disponibles cette semaine.'),
      findsOneWidget,
    );
  });

  testWidgets('the messages shortcut leads back to the dashboard', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    await _tapQuickAction(tester, 'Messages');
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    await tester.tap(find.text('Alassane Traoré'));
    await _settle(tester);

    // The thread is pushed over the inbox, so the platform back gesture walks
    // the buyer out of the conversation instead of out of the app.
    final router = GoRouter.of(tester.element(find.byType(ChatThreadPage)));
    expect(router.canPop(), isTrue);

    // Thread, then inbox, then dashboard: no dead end on the way back.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await _settle(tester);
    expect(find.text('Alassane Traoré'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await _settle(tester);
    // Back on the dashboard, at the shortcut it was left from. The shortcut
    // rather than the hero: the dashboard kept its scroll offset, and a
    // greeting scrolled out of the viewport is not built to be found.
    expect(find.byKey(const Key('buyerQuickActions')), findsOneWidget);
  });

  testWidgets('a featured product shows its price, seller and opens the buyer '
      'detail', (tester) async {
    await _pumpBuyer(tester);

    await _revealSection(tester, 'Catalogue à la une');

    final card = find.ancestor(
      of: find.text('Tomates fraîches').first,
      matching: find.byType(FeaturedProductCard),
    );
    expect(card, findsOneWidget);

    // Everything a buyer decides on, from the real catalog entry.
    expect(find.text('/ kg'), findsWidgets);
    expect(find.text('Aminata Diarra'), findsWidgets);
    expect(find.textContaining('Légumes'), findsWidgets);

    await tester.tap(card);
    await _settle(tester);

    // The buyer detail, never the supplier form.
    expect(find.byType(ProductDetailPage), findsOneWidget);
    expect(find.byType(SupplierProductFormPage), findsNothing);
    expect(find.text('Ajouter au panier'), findsOneWidget);
  });

  testWidgets('adding from the dashboard fills the cart and the hero badge', (
    tester,
  ) async {
    await _pumpBuyer(tester);

    expect(find.text('Panier vide'), findsOneWidget);
    expect(find.text('0'), findsNothing);

    await _revealSection(tester, 'Catalogue à la une');
    await tester.tap(
      find
          .descendant(
            of: find.ancestor(
              of: find.text('Tomates fraîches').first,
              matching: find.byType(FeaturedProductCard),
            ),
            matching: find.byType(IconButton),
          )
          .first,
    );
    await _settle(tester);

    expect(find.text('Tomates fraîches ajouté au panier.'), findsOneWidget);
    // The badge on the shortcut reacts right away.
    expect(
      find.descendant(
        of: find.byKey(const Key('buyerQuickActions')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );

    // And the hero at the top of the page shows the real cart content.
    await tester.drag(find.byType(ListView).first, const Offset(0, 600));
    await _settle(tester);
    expect(find.text('1 article(s)'), findsOneWidget);
    expect(find.text(Money.format(1200)), findsWidgets);
  });

  testWidgets('a recent order opens the buyer order detail', (tester) async {
    await _pumpBuyer(tester);

    await _revealSection(tester, 'Commandes récentes');

    final tile = find.ancestor(
      of: find.textContaining('Référence b_4001'),
      matching: find.byType(RecentOrderTile),
    );
    expect(tile, findsOneWidget);

    // Reference, item count, amount and status, all from the order itself.
    expect(find.textContaining('2 article(s)'), findsOneWidget);
    expect(find.text(Money.format(15200)), findsOneWidget);
    expect(find.text('En attente'), findsWidgets);

    await tester.tap(tile);
    await _settle(tester);

    expect(find.byType(OrderDetailPage), findsOneWidget);
  });

  testWidgets('the dashboard waits for its data instead of claiming it is '
      'empty', (tester) async {
    final catalogGate = Completer<void>();
    final ordersGate = Completer<void>();
    await _pumpBuyer(
      tester,
      repo: FakeBuyerRepository(
        catalogGate: catalogGate,
        ordersGate: ordersGate,
      ),
    );

    // Still loading: skeletons, and none of the empty states yet.
    expect(find.byType(CardListSkeleton), findsNWidgets(2));
    expect(find.text('Aucun produit disponible'), findsNothing);
    expect(find.text('Aucune commande'), findsNothing);
    expect(find.text('Tomates fraîches'), findsNothing);

    catalogGate.complete();
    ordersGate.complete();
    await _settle(tester);

    expect(find.byType(CardListSkeleton), findsNothing);
    expect(find.text('Tomates fraîches'), findsWidgets);
  });

  testWidgets('a failed load offers a retry that recovers', (tester) async {
    final repo = FakeBuyerRepository(
      catalogThrows: const NetworkFailure(),
      ordersThrows: const NetworkFailure(),
    );
    await _pumpBuyer(tester, repo: repo);

    expect(find.byType(FailureView), findsNWidgets(2));

    // The data lands on the retry: the error state must not be sticky.
    repo.catalogThrows = null;
    repo.ordersThrows = null;
    await _tapRetry(tester);
    await _tapRetry(tester);

    expect(find.byType(FailureView), findsNothing);
    expect(find.text('Tomates fraîches'), findsWidgets);
  });

  testWidgets('an empty buyer workspace offers a way out', (tester) async {
    await _pumpBuyer(
      tester,
      repo: FakeBuyerRepository(catalog: const [], orders: const []),
    );

    expect(find.text('Aucun produit disponible'), findsOneWidget);
    expect(find.text('Aucune commande'), findsOneWidget);
    // Nothing to feature and nothing to summarise, but the page still leads
    // back to the catalog instead of being a dead end: the primary shortcut,
    // plus the action of each empty section.
    expect(find.text('Explorer les produits'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'pulling the dashboard down refreshes the catalog and the orders',
    (tester) async {
      final repo = await _pumpBuyer(tester);
      final catalogCalls = repo.fetchCatalogCalls;
      final orderCalls = repo.fetchOrdersCalls;

      await tester.drag(find.byType(ListView).first, const Offset(0, 320));
      await _settle(tester);
      expect(repo.fetchOrdersCalls, 2, reason: 'the refresh must have fired');

      expect(repo.fetchCatalogCalls, greaterThan(catalogCalls));
      expect(repo.fetchOrdersCalls, greaterThan(orderCalls));
    },
  );

  testWidgets('the buyer dashboard reflows from 320 px to desktop', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const widths = [320.0, 360.0, 390.0, 430.0, 600.0, 900.0, 1200.0];
    const maxContentWidth = 760.0;

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 900);
      // A fresh widget tree per width, so the shell is rebuilt from scratch
      // instead of keeping the previous viewport state.
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpBuyer(tester);
      await _settle(tester);

      final hero = find.byType(BuyerHero);
      final heroRect = tester.getRect(hero);

      // The banner never overflows and stops stretching on a wide window.
      expect(heroRect.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(heroRect.right, lessThanOrEqualTo(width), reason: 'width $width');
      expect(heroRect.width, lessThanOrEqualTo(maxContentWidth));
      // Growing with the content, never a clipped fixed box.
      expect(heroRect.height, greaterThan(120), reason: 'width $width');

      // Every shortcut stays inside the viewport and readable.
      final explore = tester.getRect(
        find.descendant(
          of: find.byKey(const Key('buyerQuickActions')),
          matching: find.text('Explorer les produits'),
        ),
      );
      expect(explore.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(explore.right, lessThanOrEqualTo(width), reason: 'width $width');

      // The bottom navigation keeps its four destinations.
      final nav = find.byType(NavigationBar);
      expect(nav, findsOneWidget, reason: 'width $width');
      expect(
        find.descendant(of: nav, matching: find.byType(NavigationDestination)),
        findsNWidgets(4),
        reason: 'width $width',
      );
      expect(tester.getRect(nav).bottom, 900, reason: 'width $width');

      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('the dashboard signals when more categories are off-screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.reset);

    await _pumpBuyer(tester);
    await _settle(tester);

    final filter = find.byType(CatalogCategoryFilter);
    final scrollHint = find.descendant(
      of: filter,
      matching: find.byIcon(Icons.chevron_right_rounded),
    );
    expect(scrollHint, findsOneWidget);

    await tester.ensureVisible(
      find.descendant(of: filter, matching: find.text('Épices')),
    );
    await tester.pumpAndSettle();

    expect(scrollHint, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the category hint tracks viewport resizing', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.reset);

    await _pumpBuyer(tester);
    await _settle(tester);

    final filter = find.byType(CatalogCategoryFilter);
    Finder hint() => find.descendant(
      of: filter,
      matching: find.byIcon(Icons.chevron_right_rounded),
    );
    double overflow() => tester
        .widget<SingleChildScrollView>(
          find.descendant(
            of: filter,
            matching: find.byType(SingleChildScrollView),
          ),
        )
        .controller!
        .position
        .maxScrollExtent;

    // The dashboard caps the filter row at 720 px, so the categories overflow it at
    // every viewport: a wide window does not make them fit, and one category stays
    // clipped. The hint is shown, and it has to follow the real overflow instead of
    // keeping the value measured at the previous size.
    final overflowAt1200 = overflow();
    expect(overflowAt1200, greaterThan(1));
    expect(hint(), findsOneWidget);

    tester.view.physicalSize = const Size(320, 900);
    await tester.pumpAndSettle();
    expect(overflow(), greaterThan(overflowAt1200));
    expect(hint(), findsOneWidget);

    // Scrolling the row to its end clears the hint...
    await tester.ensureVisible(
      find.descendant(of: filter, matching: find.text('Épices')),
    );
    await tester.pumpAndSettle();
    expect(hint(), findsNothing);

    // ...and widening the window again must not bring a stale hint back: the
    // position is clamped to the new extent, so nothing is left to scroll to.
    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpAndSettle();
    expect(hint(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the English buyer dashboard fits a narrow mobile viewport', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 900);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpBuyer(tester, languageCode: 'en');
    await _settle(tester);

    expect(find.text('Explore products'), findsOneWidget);
    expect(find.text('Vegetables'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the catalog introduces itself and shows how many products it '
      'holds', (tester) async {
    await _pumpBuyer(tester);
    await _openCatalog(tester);

    expect(find.text('Catalogue'), findsWidgets);
    expect(
      find.text(
        'Des produits frais, directement de nos producteurs partenaires.',
      ),
      findsOneWidget,
    );
    // The pill counts the catalog itself, not the current selection.
    expect(find.text('6'), findsOneWidget);
    expect(find.text('6 résultat(s)'), findsOneWidget);
  });

  testWidgets('a catalog card shows the facts a buyer decides on and opens the '
      'buyer detail', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await _pumpBuyer(tester);
    await _openCatalog(tester);

    final card = find
        .ancestor(
          of: find.text('Tomates fraîches'),
          matching: find.byType(CatalogProductCard),
        )
        .first;
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await _settle(tester);

    // Picture, name, price per unit, family, origin, seller and remaining
    // stock, all read from the loaded product.
    final rect = tester.getRect(card);
    expect(
      find.descendant(of: card, matching: find.byType(CategoryArtwork)),
      findsOneWidget,
    );
    expect(find.text('/ kg'), findsWidgets);
    expect(find.text(Money.format(1200)), findsWidgets);
    expect(find.text('Légumes'), findsWidgets);
    expect(find.text('Aminata Diarra · Abidjan'), findsOneWidget);
    expect(find.text('150 kg en stock'), findsOneWidget);
    // Two columns on a phone, so the tile stays a card and not a banner.
    expect(rect.width, lessThan(200));

    await tester.tap(card);
    await _settle(tester);

    // The read-only buyer detail, never the supplier form.
    expect(find.byType(ProductDetailPage), findsOneWidget);
    expect(find.byType(SupplierProductFormPage), findsNothing);
  });

  testWidgets('an out of stock product is badged and cannot be added', (
    tester,
  ) async {
    await _pumpBuyer(tester);
    await _openCatalog(tester);

    final card = find
        .ancestor(
          of: find.text('Manioc frais'),
          matching: find.byType(CatalogProductCard),
        )
        .first;
    await tester.ensureVisible(card);
    await _settle(tester);

    // The status shows on the picture and in the details, and no stock is
    // claimed for a product that has none.
    expect(
      find.descendant(of: card, matching: find.text('En rupture')),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: card, matching: find.textContaining('en stock')),
      findsNothing,
    );
    // The add button is disabled rather than hidden: the layout never jumps.
    final add = tester.widget<IconButton>(
      find.descendant(of: card, matching: find.byType(IconButton)).first,
    );
    expect(add.onPressed, isNull);
  });

  testWidgets('the grid card adds to the cart without leaving the catalog', (
    tester,
  ) async {
    final repo = await _pumpBuyer(tester);
    await _openCatalog(tester);

    final card = find
        .ancestor(
          of: find.text('Riz local'),
          matching: find.byType(CatalogProductCard),
        )
        .first;
    await tester.ensureVisible(card);
    await _settle(tester);

    await tester.tap(
      find.descendant(of: card, matching: find.byType(IconButton)).first,
    );
    await _settle(tester);

    expect(find.text('Riz local ajouté au panier.'), findsOneWidget);

    // Still on the catalog, and the catalog itself was not reloaded.
    expect(find.byType(CatalogPage), findsOneWidget);
    expect(repo.fetchCatalogCalls, 1);

    // The cart really took the line, at the real price.
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go(RoutePaths.buyerCart);
    await _settle(tester);
    expect(find.text('Riz local'), findsOneWidget);
    expect(find.text(Money.format(1000)), findsWidgets);
  });

  testWidgets('searching filters the loaded products without reloading them', (
    tester,
  ) async {
    final repo = await _pumpBuyer(tester);
    await _openCatalog(tester);

    final calls = repo.fetchCatalogCalls;
    await tester.enterText(find.byType(TextField), 'riz');
    await tester.pump();

    expect(find.text('1 résultat(s)'), findsOneWidget);
    expect(find.text('Riz local'), findsOneWidget);
    // Typing works on the products already in memory.
    expect(repo.fetchCatalogCalls, calls);

    // The search also reaches the seller and the description.
    await tester.enterText(find.byType(TextField), 'Aminata');
    await tester.pump();
    expect(find.text('2 résultat(s)'), findsOneWidget);

    // An empty query restores the whole catalog.
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.text('6 résultat(s)'), findsOneWidget);
    expect(repo.fetchCatalogCalls, calls);
  });

  testWidgets(
    'a search that matches nothing explains itself and can be reset',
    (tester) async {
      await _pumpBuyer(tester);
      await _openCatalog(tester);

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pump();

      // A search with no result is not an empty catalog: it says so and offers
      // the way back.
      expect(find.text('Aucun produit ne correspond'), findsOneWidget);
      expect(find.text('Tomates fraîches'), findsNothing);
      expect(find.byType(CatalogProductCard), findsNothing);

      // Two ways back exist, but only the one offered by the empty state is
      // tapped here: the header also carries a reset.
      final reset = find.descendant(
        of: find.byType(EmptyState),
        matching: find.text('Réinitialiser les filtres'),
      );
      await tester.ensureVisible(reset);
      await _settle(tester);
      await tester.tap(reset);
      await _settle(tester);

      expect(find.text('6 résultat(s)'), findsOneWidget);
      expect(find.byType(CatalogProductCard), findsWidgets);
      // The query itself is cleared with the filters.
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );
    },
  );

  testWidgets('the all chip releases the category but keeps the search', (
    tester,
  ) async {
    await _pumpBuyer(tester);
    await _openCatalog(tester);

    final fruits = find.descendant(
      of: find.byType(CatalogCategoryFilter),
      matching: find.text('Fruits'),
    );
    final all = find.descendant(
      of: find.byType(CatalogCategoryFilter),
      matching: find.text('Toutes'),
    );

    await tester.tap(fruits);
    await _settle(tester);
    expect(find.text('1 résultat(s)'), findsOneWidget);

    // Selecting a chip scrolls it to the middle of the row, so the "all" chip
    // is asked for by name and brought back into the row before it is tapped.
    await tester.ensureVisible(all);
    await _settle(tester);
    await tester.tap(all);
    await _settle(tester);
    expect(find.text('6 résultat(s)'), findsOneWidget);
  });

  testWidgets('a category picked at the end of the row stays in sight', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpBuyer(tester);
    await _openCatalog(tester);

    // The row of categories does not fit a narrow screen, so the last one starts
    // out of sight: the filter row scrolls the chip it just selected back into
    // view, and a buyer who cannot see the active filter cannot trust it.
    final spices = find.descendant(
      of: find.byType(CatalogCategoryFilter),
      matching: find.text('Épices'),
    );
    expect(spices, findsOneWidget);
    expect(
      _isOnScreen(tester, spices, 320),
      isFalse,
      reason: 'the last chip starts out of the viewport',
    );

    await tester.drag(
      find.byType(CatalogCategoryFilter),
      const Offset(-900, 0),
    );
    await _settle(tester);
    await tester.ensureVisible(spices);
    await _settle(tester);
    await tester.tap(spices);
    await _settle(tester);

    expect(find.text('1 résultat(s)'), findsOneWidget);
    expect(_isOnScreen(tester, spices, 320), isTrue);
    // The header keeps its reset action and its badge on the same row.
    expect(tester.takeException(), isNull);
  });

  testWidgets('the catalog skeleton mirrors the grid instead of a spinner', (
    tester,
  ) async {
    final catalogGate = Completer<void>();
    final ordersGate = Completer<void>();
    await _pumpBuyer(
      tester,
      repo: FakeBuyerRepository(
        catalogGate: catalogGate,
        ordersGate: ordersGate,
      ),
    );

    await tester.tap(find.text('Catalogue'));
    await tester.pump();

    // Placeholders shaped like the product cards, and no premature empty state.
    expect(find.byType(GridSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Aucun produit disponible'), findsNothing);

    catalogGate.complete();
    ordersGate.complete();
    await _settle(tester);

    expect(find.byType(GridSkeleton), findsNothing);
    expect(find.byType(CatalogProductCard), findsWidgets);
  });

  testWidgets('a failed catalog load offers a retry that recovers', (
    tester,
  ) async {
    final repo = FakeBuyerRepository(
      catalogThrows: const NetworkFailure(),
      ordersGate: Completer<void>()..complete(),
    );
    await _pumpBuyer(tester, repo: repo);
    await _openCatalog(tester);

    expect(find.byType(FailureView), findsOneWidget);
    expect(find.byType(CatalogProductCard), findsNothing);

    repo.catalogThrows = null;
    await _tapRetry(tester);

    expect(find.byType(FailureView), findsNothing);
    expect(find.byType(CatalogProductCard), findsWidgets);
  });

  testWidgets('an empty catalog is not confused with a search that found '
      'nothing', (tester) async {
    await _pumpBuyer(tester, repo: FakeBuyerRepository(catalog: const []));
    await _openCatalog(tester);

    expect(find.text('Aucun produit disponible'), findsOneWidget);
    expect(find.text('Le catalogue se remplira bientôt.'), findsOneWidget);
    // Retrying is what this state offers, not resetting filters.
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Réinitialiser les filtres'), findsNothing);
  });

  testWidgets('pulling the catalog down refreshes it', (tester) async {
    final repo = await _pumpBuyer(tester);
    await _openCatalog(tester);

    final calls = repo.fetchCatalogCalls;
    await tester.drag(find.byType(ListView).first, const Offset(0, 320));
    await _settle(tester);

    expect(repo.fetchCatalogCalls, greaterThan(calls));
  });

  testWidgets('the catalog reflows from 320 px to desktop', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const widths = [320.0, 360.0, 390.0, 412.0, 430.0, 800.0, 1280.0];

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpBuyer(tester);
      await _openCatalog(tester);
      await _settle(tester);

      // Header, search and filters all stay inside the window.
      final search = tester.getRect(find.byType(CatalogSearchField));
      expect(search.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(search.right, lessThanOrEqualTo(width), reason: 'width $width');

      final categoryRow = tester.getRect(find.byType(CatalogCategoryFilter));
      expect(categoryRow.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(
        categoryRow.right,
        lessThanOrEqualTo(width),
        reason: 'width $width',
      );

      // A tile never gets wider than a comfortable reading size, and the grid
      // never becomes a single giant column on a desktop window.
      final tile = tester.getRect(find.byType(CatalogProductCard).first);
      expect(tile.width, lessThan(300), reason: 'width $width');
      expect(tile.width, greaterThan(100), reason: 'width $width');
      expect(tile.height, greaterThan(150), reason: 'width $width');

      // The bottom navigation is whole.
      expect(
        find.byType(NavigationBar),
        findsOneWidget,
        reason: 'width $width',
      );
      expect(
        tester.getRect(find.byType(NavigationBar)).bottom,
        900,
        reason: 'width $width',
      );

      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('the catalog grid gains columns as the window grows', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Future<double> firstTileWidth(double width) async {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpBuyer(tester);
      await _openCatalog(tester);
      await _settle(tester);
      return tester.getRect(find.byType(CatalogProductCard).first).width;
    }

    // A phone keeps two columns, a tablet three, a desktop four.
    final phone = await firstTileWidth(390);
    final tablet = await firstTileWidth(800);
    final desktop = await firstTileWidth(1280);

    expect(phone, lessThan(180));
    expect(tablet, greaterThan(phone));
    expect(tablet, lessThan(280));
    expect(desktop, lessThan(280));
    expect(desktop, greaterThan(phone));
  });

  testWidgets('the catalog holds up at a large text scale', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 800);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpBuyer(tester);
    await _openCatalog(tester);
    await _settle(tester);

    expect(find.byType(CatalogProductCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the orders list splits what is moving from what is closed', (
    tester,
  ) async {
    _useTallWindow(tester);
    await _pumpBuyer(tester);
    await _openOrders(tester);

    // The two groups the buyer actually reasons about.
    expect(find.text('En cours'), findsOneWidget);
    expect(find.text('Terminées'), findsOneWidget);
    expect(find.byType(BuyerOrderCard), findsNWidgets(4));

    // The most recent order leads, whatever order the repository hands over.
    final firstCard = tester.widget<BuyerOrderCard>(
      find.byType(BuyerOrderCard).first,
    );
    expect(firstCard.order.id, 'b_4001');

    // A card carries everything the list is scanned for.
    expect(find.text('Commande b_4001'), findsOneWidget);
    expect(find.text('Tomates fraîches'), findsOneWidget);
    expect(find.text('+1 autres'), findsOneWidget);
    expect(find.textContaining('2 article(s)'), findsOneWidget);
    expect(find.text('Marché de Yopougon, allée 12'), findsOneWidget);
    expect(find.text(Money.format(15200)), findsOneWidget);

    // The in-transit order names its driver on the card, no detour needed.
    final inTransit = find.ancestor(
      of: find.text('Riz local'),
      matching: find.byType(BuyerOrderCard),
    );
    expect(
      find.descendant(of: inTransit, matching: find.text('Kouamé Yao')),
      findsOneWidget,
    );
  });

  testWidgets('a status chip narrows the list and the same chip releases it', (
    tester,
  ) async {
    _useTallWindow(tester);
    await _pumpBuyer(tester);
    await _openOrders(tester);

    // Only the statuses the orders really hold, each with its count.
    expect(find.text('Toutes · 4'), findsOneWidget);
    expect(find.text('En attente · 1'), findsOneWidget);
    expect(find.text('En transit · 1'), findsOneWidget);
    expect(find.text('Livrée · 1'), findsOneWidget);
    expect(find.text('Annulée · 1'), findsOneWidget);
    // No order is confirmed, so no filter leads nowhere.
    expect(find.textContaining('Confirmée ·'), findsNothing);

    await _tapStatusChip(tester, 'En transit · 1');

    expect(find.byType(BuyerOrderCard), findsOneWidget);
    expect(find.text('Riz local'), findsOneWidget);
    expect(find.text('En cours'), findsOneWidget);
    // The closed group is empty under this filter, so it is not shown.
    expect(find.text('Terminées'), findsNothing);

    await _tapStatusChip(tester, 'En transit · 1');

    expect(find.byType(BuyerOrderCard), findsNWidgets(4));
    expect(find.text('Terminées'), findsOneWidget);
  });

  testWidgets('the all chip releases a status without touching the orders', (
    tester,
  ) async {
    _useTallWindow(tester);
    final repo = await _pumpBuyer(tester);
    await _openOrders(tester);

    await _tapStatusChip(tester, 'Annulée · 1');
    expect(find.byType(BuyerOrderCard), findsOneWidget);

    await _tapStatusChip(tester, 'Toutes · 4');
    expect(find.byType(BuyerOrderCard), findsNWidgets(4));

    // Filtering is a view concern: the buyer orders were never reloaded.
    expect(repo.fetchOrdersCalls, 1);
  });

  testWidgets('a status the last refresh dropped explains itself and resets', (
    tester,
  ) async {
    const line = [
      BuyerOrderItem(
        productId: 'p_3003',
        productName: 'Manioc frais',
        unitPrice: 500,
        quantity: 5,
      ),
    ];
    // Enough delivered orders that the filtered list scrolls, so pulling it
    // down really reaches the refresh.
    final delivered = [
      for (var day = 1; day <= 6; day++)
        BuyerOrder(
          id: 'b_600$day',
          items: line,
          status: BuyerOrderStatus.delivered,
          deliveryAddress: 'Supermarché Carrefour, Adjamé',
          buyerPhone: '+225 07 01 23 45 67',
          createdAt: DateTime(2026, 8, day),
        ),
    ];
    final inTransit = BuyerOrder(
      id: 'b_5001',
      items: [
        BuyerOrderItem(
          productId: 'p_3004',
          productName: 'Riz local',
          unitPrice: 1000,
          quantity: 20,
        ),
      ],
      status: BuyerOrderStatus.inTransit,
      deliveryAddress: 'Marché de Cocody, stand 8',
      buyerPhone: '+225 07 01 23 45 67',
      createdAt: DateTime(2026, 9, 9),
    );

    final repo = FakeBuyerRepository(orders: [...delivered, inTransit]);
    await _pumpBuyer(tester, repo: repo);
    await _openOrders(tester);

    await _tapStatusChip(tester, 'Livrée · 6');
    expect(find.byType(BuyerOrderCard), findsWidgets);

    // The refresh comes back without the orders the filter was holding.
    repo.setOrders([inTransit]);
    final calls = repo.fetchOrdersCalls;
    await _refreshOrders(tester);
    expect(repo.fetchOrdersCalls, greaterThan(calls), reason: 'refresh');

    // The orders are there, the filter is what hides them: say which, and
    // offer the way back.
    expect(find.text('Aucune commande ne correspond'), findsOneWidget);
    expect(find.byType(BuyerOrderCard), findsNothing);
    expect(find.textContaining('Livrée ·'), findsNothing);
    // One status left means no chip row, so the way back is the reset action.
    expect(
      find.text(
        "Le statut sélectionné n'a plus aucune commande. Réinitialisez le filtre pour toutes les revoir.",
      ),
      findsOneWidget,
    );
    expect(find.text('Réinitialiser'), findsOneWidget);

    await tester.tap(find.text('Réinitialiser'));
    await _settle(tester);

    expect(find.text('Riz local'), findsOneWidget);
    expect(find.text('En cours'), findsOneWidget);
  });

  testWidgets('pulling the orders list down refreshes it', (tester) async {
    final repo = await _pumpBuyer(tester);
    await _openOrders(tester);

    final calls = repo.fetchOrdersCalls;
    await _refreshOrders(tester);

    expect(repo.fetchOrdersCalls, greaterThan(calls));
    expect(find.byType(BuyerOrderCard), findsWidgets);
  });

  testWidgets('a failed orders load offers a retry that recovers', (
    tester,
  ) async {
    _useTallWindow(tester);
    final repo = FakeBuyerRepository(
      ordersThrows: const NetworkFailure(),
      ordersGate: Completer<void>()..complete(),
    );
    await _pumpBuyer(tester, repo: repo);
    await _openOrders(tester);

    expect(find.byType(FailureView), findsOneWidget);
    expect(find.byType(BuyerOrderCard), findsNothing);

    repo.ordersThrows = null;
    await _tapRetry(tester);

    expect(find.byType(FailureView), findsNothing);
    expect(find.byType(BuyerOrderCard), findsNWidgets(4));
  });

  testWidgets('the orders list waits for its data instead of claiming it is '
      'empty', (tester) async {
    _useTallWindow(tester);
    final gate = Completer<void>();
    final repo = FakeBuyerRepository(ordersGate: gate);
    await _pumpBuyer(tester, repo: repo);
    await _openOrders(tester);

    expect(find.byType(CardListSkeleton), findsOneWidget);
    expect(find.text('Aucune commande'), findsNothing);

    gate.complete();
    await _settle(tester);

    expect(find.byType(CardListSkeleton), findsNothing);
    expect(find.byType(BuyerOrderCard), findsNWidgets(4));
  });

  testWidgets('an in-transit order tracks its delivery step by step', (
    tester,
  ) async {
    await _pumpBuyer(tester);
    await _openOrders(tester);
    await _openOrder(tester, 'Riz local');

    expect(find.byType(TrackingTimeline), findsOneWidget);
    expect(find.text('Étape 3 sur 4'), findsOneWidget);

    // The progression is drawn from the real statuses: the two steps behind
    // are behind, and the one ahead is not reached.
    expect(find.text('Fait'), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byType(TrackingTimeline),
        matching: find.text('Confirmée'),
      ),
      findsOneWidget,
    );

    // The order and its driver first.
    expect(find.text('Kouamé Yao'), findsWidgets);

    // Then the figures the buyer checks when the parcel shows up.
    await tester.scrollUntilVisible(
      find.text('20 × ${Money.format(1000)}'),
      200,
    );
    expect(find.text('20 × ${Money.format(1000)}'), findsOneWidget);
    expect(find.text(Money.format(20000)), findsWidgets);

    await tester.scrollUntilVisible(find.text('Statut de la livraison'), 200);
    expect(find.text('Statut de la livraison'), findsOneWidget);
    expect(find.text('Marché de Cocody, stand 8'), findsOneWidget);
  });

  testWidgets('a delivered order closes the timeline and keeps no driver '
      'hint', (tester) async {
    await _pumpBuyer(tester);
    await _openOrders(tester);
    await _tapStatusChip(tester, 'Livrée · 1');
    await _openOrder(tester, 'Manioc frais');

    expect(find.text('Étape 4 sur 4'), findsOneWidget);
    expect(find.text('Fait'), findsNWidgets(3));
    // No driver on a delivered order means no "a driver is coming" card.
    expect(
      find.text('Un chauffeur sera assigné après confirmation de la commande.'),
      findsNothing,
    );
  });

  testWidgets('a cancelled order shows its cancellation, not a progress', (
    tester,
  ) async {
    await _pumpBuyer(tester);
    await _openOrders(tester);
    await _tapStatusChip(tester, 'Annulée · 1');
    await _openOrder(tester, 'Ananas');

    expect(find.text('Cette commande a été annulée.'), findsOneWidget);
    // A cancelled order left the progression: no step is reached.
    expect(find.byType(TrackingTimeline), findsNothing);
    expect(find.textContaining('Étape'), findsNothing);
  });

  testWidgets('the orders list reflows from 320 px to desktop', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const widths = [320.0, 360.0, 390.0, 800.0, 1280.0];

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpBuyer(tester);
      await _openOrders(tester);
      await _settle(tester);

      // Five status chips cannot fit a 320 px row, so they scroll instead of
      // overflowing.
      final chips = tester.getRect(find.byType(BuyerOrderFilterChip).first);
      expect(chips.left, greaterThanOrEqualTo(0), reason: 'width $width');

      // A card never runs past the window, whatever the amount costs.
      final card = tester.getRect(find.byType(BuyerOrderCard).first);
      expect(card.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(card.right, lessThanOrEqualTo(width), reason: 'width $width');

      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('the orders list holds up at a large text scale', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 800);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpBuyer(tester);
    await _openOrders(tester);
    await _settle(tester);

    expect(find.byType(BuyerOrderCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the catalog hides products that are not published', (
    tester,
  ) async {
    await _pumpBuyer(
      tester,
      repo: FakeBuyerRepository(
        catalog: const [
          BuyerProduct(
            id: 'published_1',
            name: 'Riz local',
            price: 1000,
            stockQuantity: 200,
            unit: 'sac',
            category: CatalogCategory.cereals,
            location: 'Yamoussoukro',
            sellerName: 'Aminata Diarra',
            published: true,
          ),
          // A declaration that was never cleared for publication: it must stay
          // invisible to buyers even though it carries real stock.
          BuyerProduct(
            id: 'unpublished_1',
            name: 'Igname en attente de validation',
            price: 700,
            stockQuantity: 90,
            unit: 'kg',
            category: CatalogCategory.tubers,
            location: 'Bouaké',
            sellerName: 'Souleymane Bamba',
            published: false,
          ),
        ],
        orders: const [],
      ),
    );
    await _openCatalog(tester);

    expect(find.text('Riz local'), findsWidgets);
    expect(find.text('Igname en attente de validation'), findsNothing);
  });

  testWidgets('a product with no explicit publication flag is never shown', (
    tester,
  ) async {
    await _pumpBuyer(
      tester,
      repo: FakeBuyerRepository(
        catalog: const [
          // No `published:` at all. The fail-closed default must keep it out,
          // so a forgotten flag hides the listing instead of publishing it.
          BuyerProduct(
            id: 'implicit_1',
            name: 'Igname non publiée',
            price: 700,
            stockQuantity: 90,
            unit: 'kg',
            category: CatalogCategory.tubers,
            location: 'Bouaké',
            sellerName: 'Souleymane Bamba',
          ),
          BuyerProduct(
            id: 'explicit_1',
            name: 'Riz publié',
            price: 1000,
            stockQuantity: 200,
            unit: 'sac',
            category: CatalogCategory.cereals,
            location: 'Yamoussoukro',
            sellerName: 'Aminata Diarra',
            published: true,
          ),
        ],
        orders: const [],
      ),
    );
    await _openCatalog(tester);

    expect(find.text('Riz publié'), findsWidgets);
    expect(find.text('Igname non publiée'), findsNothing);
  });

  test('the demo catalog only lists products explicitly published', () async {
    final catalog = await DemoBuyerRepository().fetchCatalog();

    expect(catalog, isNotEmpty);
    expect(catalog.every((product) => product.published), isTrue);
  });

  testWidgets('the welcome panel greets once, opens the catalog and remembers '
      'the dismissal', (tester) async {
    final storage = _FakeWelcomeStorage();
    await _pumpBuyer(tester, welcomeSeen: false, welcomeStorage: storage);

    expect(find.text('Bienvenue sur AgriConnect'), findsOneWidget);
    expect(storage.writes, 0);

    final primary = find.text('Découvrir le catalogue');
    await tester.ensureVisible(primary);
    await _settle(tester);
    await tester.tap(primary);
    await _settle(tester);

    // The action leads to the existing buyer catalog and marks the panel seen.
    expect(find.text('Catalogue'), findsWidgets);
    expect(find.text('Bienvenue sur AgriConnect'), findsNothing);
    expect(storage.seen, isTrue);
    expect(storage.writes, 1);

    // A later visit, with the choice remembered, starts without the panel.
    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpBuyer(tester, welcomeSeen: false, welcomeStorage: storage);
    expect(find.text('Bienvenue sur AgriConnect'), findsNothing);
  });

  testWidgets('the welcome panel close button dismisses it for good', (
    tester,
  ) async {
    final storage = _FakeWelcomeStorage();
    await _pumpBuyer(tester, welcomeSeen: false, welcomeStorage: storage);

    expect(find.text('Bienvenue sur AgriConnect'), findsOneWidget);

    final dismiss = find.text('Plus tard');
    await tester.ensureVisible(dismiss);
    await _settle(tester);
    await tester.tap(dismiss);
    await _settle(tester);

    expect(find.text('Bienvenue sur AgriConnect'), findsNothing);
    expect(storage.seen, isTrue);
    expect(storage.writes, 1);
  });
}

/// In-memory welcome storage, so the panel's persistence can be observed.
class _FakeWelcomeStorage implements BuyerWelcomeStorage {
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

Future<void> _openCatalog(WidgetTester tester) async {
  await tester.tap(find.text('Catalogue'));
  await _settle(tester);
}

/// A window tall enough to build the whole seeded history.
///
/// A list only builds what it shows, so a test that counts its rows needs a
/// viewport that holds them all instead of a guess about scroll offsets.
void _useTallWindow(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(430, 1600);
  addTearDown(tester.view.reset);
}

/// Opens the orders branch of the buyer shell.
Future<void> _openOrders(WidgetTester tester) async {
  await tester.tap(find.text('Commandes'));
  await _settle(tester);
}

/// Opens the detail of the order holding [productName] in the orders list.
Future<void> _openOrder(WidgetTester tester, String productName) async {
  final product = find.text(productName);
  expect(product, findsOneWidget);
  await tester.ensureVisible(product);
  await _settle(tester);
  await tester.tap(product);
  await _settle(tester);
  expect(find.byType(OrderDetailPage), findsOneWidget);
}

/// Scrolls the orders list down to trigger its refresh.
///
/// The buyer shell keeps the dashboard branch alive, so the first list of the
/// tree is not always the one on screen, and a pull-to-refresh only arms at the
/// very top of the list.
Future<void> _refreshOrders(WidgetTester tester) async {
  final list = find.descendant(
    of: find.byType(BuyerOrdersPage),
    matching: find.byType(ListView),
  );
  expect(list, findsOneWidget);
  await tester.drag(list, const Offset(0, 800));
  await _settle(tester);
  await tester.drag(list, const Offset(0, 320));
  await _settle(tester);
}

/// Taps a status chip of the orders list, scrolling the chip row when needed.
Future<void> _tapStatusChip(WidgetTester tester, String label) async {
  final chip = find.byType(BuyerOrderFilterChip);
  final target = find.descendant(of: chip, matching: find.text(label));
  expect(target, findsOneWidget, reason: 'chip $label');

  await tester.ensureVisible(target);
  await _settle(tester);
  await tester.tap(target);
  await _settle(tester);
}

/// Whether [finder] lies inside a viewport [width] wide.
///
/// A chip scrolled out of the row is still built, so "findsOneWidget" says
/// nothing about what a buyer can see: only its position does.
bool _isOnScreen(WidgetTester tester, Finder finder, double width) {
  final rect = tester.getRect(finder);
  return rect.left >= 0 && rect.right <= width;
}

/// Value of the dashboard stat tile carrying [label].
///
/// A tile is a widget of its own, so the figure is read inside it: the same
/// digit appears in several tiles, and picking it up anywhere else would make
/// this assertion about whichever tile was built first.
String? _statValue(WidgetTester tester, String label) {
  final tile = find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate(
      (widget) => widget is StatCard && widget.label == label,
    ),
  );
  expect(tile, findsOneWidget, reason: 'stat tile $label');

  final value = find.descendant(of: tile, matching: find.byType(Text));
  return tester.widget<Text>(value.last).data;
}

/// Dashboard shortcut label, scoped to the grid so it is never confused with a
/// destination of the bottom navigation carrying the same wording.
Finder _quickAction(String label) => find.descendant(
  of: find.byKey(const Key('buyerQuickActions')),
  matching: find.text(label),
);

/// Taps a shortcut after making sure the tile is fully on screen: the quick
/// actions sit under the hero and fall below the fold on a small window.
Future<void> _tapQuickAction(WidgetTester tester, String label) async {
  final target = _quickAction(label);
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await _settle(tester);
  await tester.tap(target);
  await _settle(tester);
}

/// Returns to the dashboard after a shortcut opened a root route.
Future<void> _backToDashboard(WidgetTester tester) async {
  final context = tester.element(find.byType(Scaffold).first);
  GoRouter.of(context).go(RoutePaths.buyerHome);
  await _settle(tester);
}

/// Taps the retry button of a failure state, wherever it sits in the page.
Future<void> _tapRetry(WidgetTester tester) async {
  final retry = find.text('Réessayer');
  expect(retry, findsWidgets);
  await tester.ensureVisible(retry.first);
  await _settle(tester);
  await tester.tap(retry.first);
  await _settle(tester);
}

/// Scrolls until a dashboard section header is visible.
Future<void> _revealSection(WidgetTester tester, String title) async {
  final target = find.text(title);
  if (target.evaluate().isEmpty) return;
  await tester.ensureVisible(target);
  await _settle(tester);
}
