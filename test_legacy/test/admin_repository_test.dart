import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/admin/data/demo_admin_repository.dart';
import 'package:agri_connect/features/admin/domain/admin_account_status.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/domain/admin_moderation_status.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/presentation/admin_deliveries_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_products_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_users_page.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';

import 'support/fakes.dart';

/// The admin operations are meant to be decisions, not acknowledgements.
///
/// These tests pin the demo repository and the test fake to the same rules: an
/// operation writes what the screen showed, a second read sees it, an
/// incompatible state is refused rather than reported as success, and the page
/// never paints a success message for an operation that failed.

Matcher _serverFailure(String detail) => isA<ServerFailure>().having(
  (failure) => failure.details,
  'details',
  detail,
);

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  String language = 'fr',
}) {
  // Taller than the default 800x600 so a tile further down a list can be
  // tapped without scrolling first.
  const dpr = 1.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = const Size(800, 1600) * dpr;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
  return tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: page,
    ),
  );
}

/// An admin failure message the console shows when an operation is refused.
const String _failureFr = 'L\'opération a échoué. Veuillez réessayer.';

void main() {
  final builders = <String, AdminRepository Function()>{
    'DemoAdminRepository': () => DemoAdminRepository(latency: Duration.zero),
    'FakeAdminRepository': () => FakeAdminRepository(),
  };

  for (final entry in builders.entries) {
    group('${entry.key} — account decisions', () {
      late AdminRepository repository;
      setUp(() => repository = entry.value());

      test(
        'approving a submitted account persists and updates the stats',
        () async {
          final pending = (await repository.fetchUsers()).firstWhere(
            (u) => u.status == AdminAccountStatus.verificationPending,
          );
          final pendingBefore = (await repository.fetchStats()).pendingUsers;

          await repository.approveUser(pending.id);

          final updated = (await repository.fetchUsers()).firstWhere(
            (u) => u.id == pending.id,
          );
          expect(updated.status, AdminAccountStatus.active);
          expect(
            (await repository.fetchStats()).pendingUsers,
            pendingBefore - 1,
          );
        },
      );

      test('a decision survives a second read', () async {
        final active = (await repository.fetchUsers()).firstWhere(
          (u) => u.status == AdminAccountStatus.active,
        );

        await repository.restrictUser(active.id);

        // Read twice: the second read must answer with the written state, not a
        // freshly rebuilt seed.
        for (var i = 0; i < 2; i++) {
          final read = (await repository.fetchUsers()).firstWhere(
            (u) => u.id == active.id,
          );
          expect(read.status, AdminAccountStatus.suspended);
        }

        await repository.reactivateUser(active.id);
        final reactivated = (await repository.fetchUsers()).firstWhere(
          (u) => u.id == active.id,
        );
        expect(reactivated.status, AdminAccountStatus.active);
      });

      test('an unknown account is refused, not acknowledged', () async {
        await expectLater(
          repository.approveUser('does-not-exist'),
          throwsA(_serverFailure('user_not_found')),
        );
      });

      test('an incompatible decision is refused', () async {
        final pending = (await repository.fetchUsers()).firstWhere(
          (u) => u.status == AdminAccountStatus.verificationPending,
        );

        // Reactivating an account that never left is not a decision the
        // workspace offers; it must fail rather than pretend.
        await expectLater(
          repository.reactivateUser(pending.id),
          throwsA(_serverFailure('invalid_transition')),
        );
      });

      test('repeating a decision already in effect is a quiet no-op', () async {
        final active = (await repository.fetchUsers()).firstWhere(
          (u) => u.status == AdminAccountStatus.active,
        );

        await expectLater(repository.approveUser(active.id), completes);
        final unchanged = (await repository.fetchUsers()).firstWhere(
          (u) => u.id == active.id,
        );
        expect(unchanged.status, AdminAccountStatus.active);
      });
    });

    group('${entry.key} — product moderation', () {
      late AdminRepository repository;
      setUp(() => repository = entry.value());

      test('approving a submitted product persists', () async {
        final pending = (await repository.fetchProducts()).firstWhere(
          (p) => p.moderation == AdminModerationStatus.pending,
        );

        await repository.approveProduct(pending.id);

        final updated = (await repository.fetchProducts()).firstWhere(
          (p) => p.id == pending.id,
        );
        expect(updated.moderation, AdminModerationStatus.validated);
      });

      test('rejecting a product records the reason it was given', () async {
        final pending = (await repository.fetchProducts()).firstWhere(
          (p) => p.moderation == AdminModerationStatus.pending,
        );

        await repository.rejectProduct(pending.id, reason: 'Photo illisible');

        final updated = (await repository.fetchProducts()).firstWhere(
          (p) => p.id == pending.id,
        );
        expect(updated.moderation, AdminModerationStatus.rejected);
        expect(updated.rejectionReason, 'Photo illisible');
      });

      test('archiving a decided product persists', () async {
        final decided = (await repository.fetchProducts()).firstWhere(
          (p) => p.moderation == AdminModerationStatus.validated,
        );

        await repository.archiveProduct(decided.id);

        final updated = (await repository.fetchProducts()).firstWhere(
          (p) => p.id == decided.id,
        );
        expect(updated.moderation, AdminModerationStatus.archived);
      });

      test('archiving a product still under review is refused', () async {
        final pending = (await repository.fetchProducts()).firstWhere(
          (p) => p.moderation == AdminModerationStatus.pending,
        );

        await expectLater(
          repository.archiveProduct(pending.id),
          throwsA(_serverFailure('invalid_transition')),
        );
      });

      test('an unknown product is refused', () async {
        await expectLater(
          repository.approveProduct('does-not-exist'),
          throwsA(_serverFailure('product_not_found')),
        );
      });
    });

    group('${entry.key} — orders and deliveries', () {
      late AdminRepository repository;
      setUp(() => repository = entry.value());

      test('an order status change persists', () async {
        final order = (await repository.fetchOrders()).first;

        await repository.updateOrderStatus(
          order.id,
          AdminOrderStatus.confirmed,
        );

        final updated = (await repository.fetchOrders()).firstWhere(
          (o) => o.id == order.id,
        );
        expect(updated.status, AdminOrderStatus.confirmed);
      });

      test('an unknown order is refused', () async {
        await expectLater(
          repository.updateOrderStatus(
            'does-not-exist',
            AdminOrderStatus.confirmed,
          ),
          throwsA(_serverFailure('order_not_found')),
        );
      });

      test(
        'a delivery advances one leg at a time and refuses a skip',
        () async {
          final pickUp = (await repository.fetchDeliveries()).firstWhere(
            (d) => d.status == AdminDeliveryStatus.pickUp,
          );

          // Skipping straight to delivered is not a leg the workspace offers.
          await expectLater(
            repository.updateDeliveryStatus(
              pickUp.id,
              AdminDeliveryStatus.delivered,
            ),
            throwsA(_serverFailure('invalid_transition')),
          );

          await repository.updateDeliveryStatus(
            pickUp.id,
            AdminDeliveryStatus.inTransit,
          );
          expect(
            (await repository.fetchDeliveryById(pickUp.id))!.status,
            AdminDeliveryStatus.inTransit,
          );

          await repository.updateDeliveryStatus(
            pickUp.id,
            AdminDeliveryStatus.delivered,
          );
          expect(
            (await repository.fetchDeliveryById(pickUp.id))!.status,
            AdminDeliveryStatus.delivered,
          );
        },
      );

      test('an unknown delivery is refused', () async {
        await expectLater(
          repository.updateDeliveryStatus(
            'does-not-exist',
            AdminDeliveryStatus.inTransit,
          ),
          throwsA(_serverFailure('delivery_not_found')),
        );
      });

      test('assigning a driver persists', () async {
        final delivery = (await repository.fetchDeliveries()).first;

        await repository.assignDriver(delivery.id, 'Ama Owusu');

        final updated = (await repository.fetchDeliveryById(delivery.id))!;
        expect(updated.driverName, 'Ama Owusu');
      });
    });
  }

  group('the admin page never fakes a successful operation', () {
    testWidgets('a performed decision shows one success message', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        AdminUsersPage(repository: FakeAdminRepository()),
      );
      await _settle(tester);

      await tester.tap(find.byKey(const ValueKey('admin.users.menu.u6')));
      await _settle(tester);
      await tester.tap(find.text('Approuver'));
      await _settle(tester);

      expect(find.text('Utilisateur mis à jour.'), findsOneWidget);
      expect(find.text(_failureFr), findsNothing);
    });

    testWidgets(
      'a refused decision shows the localized failure, not a success',
      (tester) async {
        await _pumpPage(
          tester,
          AdminUsersPage(repository: _RefusingAdminRepository()),
        );
        await _settle(tester);

        await tester.tap(find.byKey(const ValueKey('admin.users.menu.u6')));
        await _settle(tester);
        await tester.tap(find.text('Approuver'));
        await _settle(tester);

        expect(find.text(_failureFr), findsOneWidget);
        expect(find.text('Utilisateur mis à jour.'), findsNothing);
        // The raw failure object never reaches the reader.
        expect(find.textContaining('ServerFailure'), findsNothing);
      },
    );

    testWidgets('a refused moderation shows the failure, not a success', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        AdminProductsPage(
          repository: _RefusingAdminRepository(),
          capabilities: const {UserCapability.stockValidation},
        ),
      );
      await _settle(tester);

      await tester.tap(find.byKey(const ValueKey('admin.products.menu.p3')));
      await _settle(tester);
      await tester.tap(find.text('Approuver'));
      await _settle(tester);

      expect(find.text(_failureFr), findsOneWidget);
      expect(find.text('Produit mis à jour.'), findsNothing);
    });

    testWidgets('a refused delivery move shows the failure, not a success', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        AdminDeliveriesPage(repository: _RefusingAdminRepository()),
      );
      await _settle(tester);

      await tester.tap(find.text('d1'));
      await _settle(tester);
      await tester.tap(find.text('Marquer en transit'));
      await _settle(tester);

      expect(find.text(_failureFr), findsOneWidget);
      expect(find.text('Livraison mise à jour avec succès.'), findsNothing);
    });
  });
}

/// Refuses every write, so the pages can be observed reporting a failure
/// instead of a success.
class _RefusingAdminRepository extends FakeAdminRepository {
  @override
  Future<void> approveUser(String userId) async =>
      throw const ServerFailure('refused');

  @override
  Future<void> approveProduct(String productId) async =>
      throw const ServerFailure('refused');

  @override
  Future<void> updateDeliveryStatus(
    String deliveryId,
    AdminDeliveryStatus status,
  ) async => throw const ServerFailure('refused');
}
