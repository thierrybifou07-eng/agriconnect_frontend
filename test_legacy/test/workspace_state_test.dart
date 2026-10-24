import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/buyer/application/buyer_orders_controller.dart';
import 'package:agri_connect/features/buyer/application/buyer_providers.dart';
import 'package:agri_connect/features/buyer/domain/buyer_order.dart';
import 'package:agri_connect/features/buyer/domain/buyer_repository.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';
import 'package:agri_connect/features/chat/application/chat_inbox_controller.dart';
import 'package:agri_connect/features/chat/application/chat_providers.dart';
import 'package:agri_connect/features/chat/application/chat_thread_controller.dart';
import 'package:agri_connect/features/chat/domain/chat_conversation.dart';
import 'package:agri_connect/features/chat/domain/chat_message.dart';
import 'package:agri_connect/features/chat/domain/chat_participant.dart';
import 'package:agri_connect/features/chat/domain/chat_repository.dart';
import 'package:agri_connect/features/driver/application/driver_deliveries_controller.dart';
import 'package:agri_connect/features/driver/application/driver_providers.dart';
import 'package:agri_connect/features/driver/application/driver_trips_controller.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_repository.dart';
import 'package:agri_connect/features/driver/domain/driver_trip.dart';

void main() {
  group('Chat inbox state', () {
    test('a failed load is dropped by the retry that follows it', () async {
      final repository = FakeChatRepository(
        conversationsThrows: NetworkFailure(),
      );
      final container = _container(repository);
      addTearDown(container.dispose);

      await _boot(() => container.read(chatInboxControllerProvider));
      expect(
        container.read(chatInboxControllerProvider).failure,
        isA<NetworkFailure>(),
      );

      repository.conversationsThrows = null;
      await container.read(chatInboxControllerProvider.notifier).refresh();
      await _pump();

      final state = container.read(chatInboxControllerProvider);
      expect(state.failure, isNull);
      expect(state.conversations, hasLength(1));
    });

    test('a refresh keeps the conversations on screen while it runs', () async {
      final repository = FakeChatRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      await _boot(() => container.read(chatInboxControllerProvider));
      expect(
        container.read(chatInboxControllerProvider).conversations,
        hasLength(1),
      );

      final gate = Completer<void>();
      repository.conversationsGate = gate;
      final pending = container
          .read(chatInboxControllerProvider.notifier)
          .refresh();
      await _pump();

      // The list is not blanked out: a refresh, not a load, and the failure of
      // an earlier attempt is not what a clean refresh would keep showing.
      final refreshing = container.read(chatInboxControllerProvider);
      expect(refreshing.isLoading, isFalse);
      expect(refreshing.isRefreshing, isTrue);
      expect(refreshing.conversations, hasLength(1));

      gate.complete();
      await pending;
      await _pump();

      final settled = container.read(chatInboxControllerProvider);
      expect(settled.isRefreshing, isFalse);
      expect(settled.failure, isNull);
    });

    test(
      'a refresh with nothing on screen shows a load, not an empty inbox',
      () async {
        final repository = FakeChatRepository(
          conversationsThrows: NetworkFailure(),
        );
        final container = _container(repository);
        addTearDown(container.dispose);

        await _boot(() => container.read(chatInboxControllerProvider));
        expect(container.read(chatInboxControllerProvider).failure, isNotNull);

        final gate = Completer<void>();
        repository.conversationsGate = gate;
        final pending = container
            .read(chatInboxControllerProvider.notifier)
            .refresh();
        await _pump();

        // With no conversation to keep, the retry must look like the first load
        // instead of the "no message yet" empty state.
        final retrying = container.read(chatInboxControllerProvider);
        expect(retrying.isLoading, isTrue);
        expect(retrying.failure, isNull);

        repository.conversationsThrows = null;
        gate.complete();
        await pending;
        await _pump();

        final settled = container.read(chatInboxControllerProvider);
        expect(settled.isLoading, isFalse);
        expect(settled.conversations, hasLength(1));
      },
    );
  });

  group('Chat thread state', () {
    test('a failed load is dropped by the retry that follows it', () async {
      final repository = FakeChatRepository(messagesThrows: NetworkFailure());
      final container = _container(repository);
      addTearDown(container.dispose);

      await _boot(
        () => container.read(chatThreadControllerProvider(_threadId)),
      );
      expect(
        container.read(chatThreadControllerProvider(_threadId)).failure,
        isA<NetworkFailure>(),
      );

      repository.messagesThrows = null;
      await container
          .read(chatThreadControllerProvider(_threadId).notifier)
          .refresh();
      await _pump();

      final state = container.read(chatThreadControllerProvider(_threadId));
      expect(state.failure, isNull);
      expect(state.messages, hasLength(1));
    });

    test('a successful send retires the error of the failed one', () async {
      final repository = FakeChatRepository(sendThrows: NetworkFailure());
      final container = _container(repository);
      addTearDown(container.dispose);

      await _boot(
        () => container.read(chatThreadControllerProvider(_threadId)),
      );
      final controller = container.read(
        chatThreadControllerProvider(_threadId).notifier,
      );

      await controller.sendMessage('Bonjour');
      final failed = container.read(chatThreadControllerProvider(_threadId));
      expect(failed.actionFailure, isA<NetworkFailure>());
      expect(failed.failedMessageText, 'Bonjour');

      repository.sendThrows = null;
      await controller.sendMessage('Bonjour');

      // The retry succeeded: its message is there and the error of the previous
      // attempt is gone, instead of shadowing the thread forever.
      final sent = container.read(chatThreadControllerProvider(_threadId));
      expect(sent.actionFailure, isNull);
      expect(sent.failedMessageText, isNull);
      expect(sent.sendingIds, isEmpty);
      expect(sent.messages.map((message) => message.text), contains('Bonjour'));
    });
  });

  group('Buyer orders state', () {
    test(
      'an order placed after a failed load leaves no error behind',
      () async {
        final repository = FakeBuyerRepository(ordersThrows: NetworkFailure());
        final container = ProviderContainer(
          overrides: [buyerRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        await _boot(() => container.read(buyerOrdersControllerProvider));
        expect(
          container.read(buyerOrdersControllerProvider).failure,
          isA<NetworkFailure>(),
        );

        container.read(buyerOrdersControllerProvider.notifier).upsert(_order());

        // The new order proves the list is not empty: an error from before must
        // not be what the screen shows next to it.
        final state = container.read(buyerOrdersControllerProvider);
        expect(state.failure, isNull);
        expect(state.orders, hasLength(1));
      },
    );
  });

  group('Driver deliveries state', () {
    test('a refresh keeps the deliveries on screen while it runs', () async {
      final repository = _FakeDriverRepository();
      final container = _driverContainer(repository);
      addTearDown(container.dispose);

      await _boot(() => container.read(driverDeliveriesControllerProvider));
      expect(
        container.read(driverDeliveriesControllerProvider).deliveries,
        hasLength(1),
      );

      final gate = Completer<void>();
      repository.deliveriesGate = gate;
      final pending = container
          .read(driverDeliveriesControllerProvider.notifier)
          .refresh();
      await _pump();

      // The list is not blanked out: a refresh, not a load.
      final refreshing = container.read(driverDeliveriesControllerProvider);
      expect(refreshing.isLoading, isFalse);
      expect(refreshing.isRefreshing, isTrue);
      expect(refreshing.deliveries, hasLength(1));

      gate.complete();
      await pending;
      await _pump();

      final settled = container.read(driverDeliveriesControllerProvider);
      expect(settled.isRefreshing, isFalse);
      expect(settled.failure, isNull);
    });

    test(
      'a refresh verifies the status left in doubt by a failed action',
      () async {
        final repository = _FakeDriverRepository(
          updateThrows: NetworkFailure(),
        );
        final container = _driverContainer(repository);
        addTearDown(container.dispose);

        await _boot(() => container.read(driverDeliveriesControllerProvider));
        final notifier = container.read(
          driverDeliveriesControllerProvider.notifier,
        );

        await notifier.updateStatus('d_1', DriverDeliveryStatus.inTransit);
        final failed = container.read(driverDeliveriesControllerProvider);
        expect(failed.actionFailure, isA<NetworkFailure>());
        expect(failed.failedDeliveryId, 'd_1');

        repository.updateThrows = null;
        await notifier.refresh();
        await _pump();

        // The reload is the real status of the world: it supersedes the action
        // whose outcome was never confirmed, instead of shadowing the list.
        final verified = container.read(driverDeliveriesControllerProvider);
        expect(verified.actionFailure, isNull);
        expect(verified.failedDeliveryId, isNull);
      },
    );

    test(
      'a refresh with nothing on screen shows a load, not an empty list',
      () async {
        final repository = _FakeDriverRepository(
          deliveriesThrows: NetworkFailure(),
        );
        final container = _driverContainer(repository);
        addTearDown(container.dispose);

        await _boot(() => container.read(driverDeliveriesControllerProvider));
        expect(
          container.read(driverDeliveriesControllerProvider).failure,
          isNotNull,
        );

        final gate = Completer<void>();
        repository.deliveriesGate = gate;
        final pending = container
            .read(driverDeliveriesControllerProvider.notifier)
            .refresh();
        await _pump();

        // With no delivery to keep, the retry must look like the first load
        // instead of the "no delivery yet" empty state.
        final retrying = container.read(driverDeliveriesControllerProvider);
        expect(retrying.isLoading, isTrue);
        expect(retrying.failure, isNull);

        repository.deliveriesThrows = null;
        gate.complete();
        await pending;
        await _pump();

        final settled = container.read(driverDeliveriesControllerProvider);
        expect(settled.isLoading, isFalse);
        expect(settled.deliveries, hasLength(1));
      },
    );
  });

  group('Driver trips state', () {
    test('a refresh keeps the trips on screen while it runs', () async {
      final repository = _FakeDriverRepository();
      final container = _driverContainer(repository);
      addTearDown(container.dispose);

      await _boot(() => container.read(driverTripsControllerProvider));
      expect(container.read(driverTripsControllerProvider).trips, hasLength(1));

      final gate = Completer<void>();
      repository.tripsGate = gate;
      final pending = container
          .read(driverTripsControllerProvider.notifier)
          .refresh();
      await _pump();

      final refreshing = container.read(driverTripsControllerProvider);
      expect(refreshing.isLoading, isFalse);
      expect(refreshing.isRefreshing, isTrue);
      expect(refreshing.trips, hasLength(1));

      gate.complete();
      await pending;
      await _pump();

      final settled = container.read(driverTripsControllerProvider);
      expect(settled.isRefreshing, isFalse);
      expect(settled.failure, isNull);
    });
  });
}

/// Wires the chat repository into a container under test.
ProviderContainer _container(FakeChatRepository repository) {
  return ProviderContainer(
    overrides: [chatRepositoryProvider.overrideWithValue(repository)],
  );
}

/// Builds a provider through [build] and lets the load it schedules complete.
///
/// A provider is built by its first read, and the load that read starts only
/// lands a microtask later: reading first, then yielding, is what makes the
/// state of that load observable.
Future<void> _boot(void Function() build) async {
  build();
  await _pump();
}

/// Lets the pending loads and microtasks of a container run.
Future<void> _pump() => Future<void>.delayed(Duration.zero);

const _threadId = 'c_1';

const _participant = ChatParticipant(
  id: 'farm_1',
  fullName: 'Awa Traoré',
  role: UserRole.supplier,
);

BuyerOrder _order() => BuyerOrder(
  id: 'o_1',
  items: const [
    BuyerOrderItem(
      productId: 'p_1',
      productName: 'Riz local',
      quantity: 2,
      unitPrice: 1500,
    ),
  ],
  status: BuyerOrderStatus.pending,
  deliveryAddress: 'Rue 12, Cocody',
  buyerPhone: '+225 07 00 00 00 00',
  createdAt: DateTime(2026, 9, 20),
);

/// Chat repository whose failures are decided by the test, per call kind.
class FakeChatRepository implements ChatRepository {
  FakeChatRepository({
    this.conversationsThrows,
    this.messagesThrows,
    this.sendThrows,
  });

  Object? conversationsThrows;
  Object? messagesThrows;
  Object? sendThrows;

  /// Holds the next inbox load open, to watch the state while it runs.
  Completer<void>? conversationsGate;

  @override
  Future<List<ChatConversation>> fetchConversations() async {
    if (conversationsGate != null) await conversationsGate!.future;
    if (conversationsThrows != null) throw conversationsThrows!;
    return [
      ChatConversation(
        id: _threadId,
        participant: _participant,
        lastMessage: 'Bonjour',
        lastMessageAt: DateTime(2026, 9, 20, 9),
        unreadCount: 1,
      ),
    ];
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    if (messagesThrows != null) throw messagesThrows!;
    return [
      ChatMessage(
        id: 'm_1',
        conversationId: conversationId,
        sender: _participant,
        text: 'Bonjour',
        sentAt: DateTime(2026, 9, 20, 9),
      ),
    ];
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    if (sendThrows != null) throw sendThrows!;
    return ChatMessage(
      id: 'm_2',
      conversationId: conversationId,
      sender: const ChatParticipant(
        id: 'demo_buyer',
        fullName: 'Marie Koné',
        role: UserRole.buyer,
      ),
      text: text,
      sentAt: DateTime(2026, 9, 20, 10),
      isMine: true,
    );
  }
}

/// Buyer repository that can fail its order load on demand.
class FakeBuyerRepository implements BuyerRepository {
  FakeBuyerRepository({this.ordersThrows});

  Object? ordersThrows;

  @override
  Future<List<BuyerOrder>> fetchOrders() async {
    if (ordersThrows != null) throw ordersThrows!;
    return const [];
  }

  @override
  Future<List<BuyerProduct>> fetchCatalog() async => const [];

  @override
  Future<BuyerOrder> placeOrder(PlaceOrderRequest request) async => _order();
}

/// Driver repository whose failures are decided by the test, per call kind.
class _FakeDriverRepository implements DriverRepository {
  _FakeDriverRepository({this.deliveriesThrows, this.updateThrows});

  Object? deliveriesThrows;
  Object? updateThrows;

  /// Holds the next load open, to watch the state while it runs.
  Completer<void>? deliveriesGate;
  Completer<void>? tripsGate;

  @override
  Future<List<DriverDelivery>> fetchDeliveries() async {
    if (deliveriesGate != null) await deliveriesGate!.future;
    if (deliveriesThrows != null) throw deliveriesThrows!;
    return [_driverDelivery()];
  }

  @override
  Future<List<DeliveryTrip>> fetchTrips() async {
    if (tripsGate != null) await tripsGate!.future;
    return [_driverTrip()];
  }

  @override
  Future<DriverDelivery> updateDeliveryStatus(
    String deliveryId,
    DriverDeliveryStatus status,
  ) async {
    if (updateThrows != null) throw updateThrows!;
    return _driverDelivery().copyWith(status: status);
  }
}

DriverDelivery _driverDelivery() => DriverDelivery(
  id: 'd_1',
  orderId: 'b_1',
  customerName: 'Aminata',
  customerPhone: '+225 07 00 00 00 00',
  pickupLocation: 'Marché de gros, Abidjan',
  deliveryAddress: 'Yopougon, allée 4',
  items: const [
    DriverDeliveryItem(
      productId: 'p_1',
      productName: 'Tomates',
      quantity: 10,
      unit: 'kg',
    ),
  ],
  status: DriverDeliveryStatus.pickUp,
  scheduledAt: DateTime(2026, 9, 20),
  createdAt: DateTime(2026, 9, 19),
);

DeliveryTrip _driverTrip() => DeliveryTrip(
  id: 't_1',
  routeLabel: 'Adjamé → Yopougon',
  vehicleLabel: 'Fourgonnette · ZZ-000-AA',
  deliveryIds: const ['d_1'],
  scheduledAt: DateTime(2026, 9, 20),
  createdAt: DateTime(2026, 9, 19),
);

/// Wires the driver repository into a container under test.
ProviderContainer _driverContainer(DriverRepository repository) {
  return ProviderContainer(
    overrides: [driverRepositoryProvider.overrideWithValue(repository)],
  );
}
