import 'dart:async';
import 'dart:typed_data';

import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/media/photo_picker.dart';
import 'package:agri_connect/core/media/prepared_photo.dart';
import 'package:agri_connect/features/admin/domain/admin_account_status.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/domain/admin_moderation_status.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';
import 'package:agri_connect/features/admin/domain/admin_product.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/domain/admin_stats.dart';
import 'package:agri_connect/features/admin/domain/admin_user.dart';
import 'package:agri_connect/features/agent/domain/agent_case.dart';
import 'package:agri_connect/features/agent/domain/agent_repository.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/buyer/domain/buyer_order.dart';
import 'package:agri_connect/features/super_admin/domain/platform_settings.dart';
import 'package:agri_connect/features/super_admin/domain/staff_account.dart';
import 'package:agri_connect/features/super_admin/domain/staff_permission.dart';
import 'package:agri_connect/features/super_admin/domain/super_admin_repository.dart';
import 'package:agri_connect/features/super_admin/domain/system_event.dart';
import 'package:agri_connect/features/buyer/domain/buyer_repository.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_repository.dart';
import 'package:agri_connect/features/driver/domain/driver_trip.dart';
import 'package:agri_connect/features/supplier/domain/supplier_order.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';

/// Immediate in-memory supplier repository used by widget tests.
///
/// It never leaves timers pending, so the dashboard loads synchronously with
/// the test time.
class FakeSupplierRepository implements SupplierRepository {
  FakeSupplierRepository({
    List<Product>? products,
    List<SupplierOrder>? orders,
    this.confirmThrowsNetwork = false,
    this.confirmGate,
    this.productSaveThrows,
    this.productSaveGate,
    this.ordersGate,
  }) : _products = List.of(products ?? _defaultProducts()),
       _orders = List.of(orders ?? _defaultOrders());

  final bool confirmThrowsNetwork;

  /// When set, confirmations wait for this future (double-click simulation).
  Completer<void>? confirmGate;

  /// When set, the order list waits for this future, to inspect the loading
  /// state before the orders are known.
  Completer<void>? ordersGate;

  /// When set, saving a product fails with this error.
  Object? productSaveThrows;

  /// When set, saving a product waits for this future (double-click test).
  Completer<void>? productSaveGate;

  int confirmCalls = 0;
  int productSaveCalls = 0;
  int fetchProductsCalls = 0;
  int fetchOrdersCalls = 0;

  final List<Product> _products;
  final List<SupplierOrder> _orders;

  static List<Product> _defaultProducts() => [
    Product(
      id: 'p1',
      name: 'Tomates',
      description: 'Tomates de saison.',
      price: 1200,
      stockQuantity: 150,
      unit: 'kg',
      createdAt: DateTime(2026, 9, 1),
      declaration: DeclarationStatus.pendingReview,
    ),
    Product(
      id: 'p2',
      name: 'Manioc',
      price: 500,
      stockQuantity: 0,
      unit: 'kg',
      createdAt: DateTime(2026, 9, 2),
      declaration: DeclarationStatus.draft,
    ),
  ];

  static List<SupplierOrder> _defaultOrders() => [
    SupplierOrder(
      id: 'c1',
      buyerName: 'Aminata',
      buyerEmail: 'aminata@example.com',
      buyerPhone: '+225 07 00 11 22 33',
      items: const [
        OrderItem(
          productId: 'p1',
          productName: 'Tomates',
          unitPrice: 1200,
          quantity: 10,
        ),
      ],
      status: OrderStatus.pending,
      createdAt: DateTime(2026, 9, 8),
    ),
    SupplierOrder(
      id: 'c2',
      buyerName: 'Fatoumata',
      buyerEmail: 'fatoumata@example.com',
      items: const [
        OrderItem(
          productId: 'p1',
          productName: 'Tomates',
          unitPrice: 1200,
          quantity: 5,
        ),
      ],
      status: OrderStatus.pending,
      createdAt: DateTime(2026, 9, 7),
    ),
    SupplierOrder(
      id: 'c3',
      buyerName: 'Souleymane',
      buyerEmail: 'souleymane@example.com',
      items: const [
        OrderItem(
          productId: 'p2',
          productName: 'Manioc',
          unitPrice: 500,
          quantity: 30,
        ),
      ],
      status: OrderStatus.confirmed,
      createdAt: DateTime(2026, 9, 6),
    ),
  ];

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCalls++;
    return List<Product>.unmodifiable(_products);
  }

  @override
  Future<Product> saveProduct({
    String? productId,
    required ProductDraft draft,
    required DeclarationStatus declaration,
  }) async {
    productSaveCalls++;
    final error = productSaveThrows;
    if (error != null) throw error;
    if (productSaveGate != null) await productSaveGate!.future;
    if (productId != null) {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index < 0) throw const ServerFailure('product_not_found');
      final existing = _products[index];
      final updated = Product(
        id: productId,
        name: draft.name,
        description: draft.description,
        price: draft.price,
        stockQuantity: draft.stockQuantity,
        unit: draft.unit,
        photos: draft.photos,
        createdAt: existing.createdAt,
        declaration: declaration,
      );
      _products[index] = updated;
      return updated;
    }
    final product = Product(
      id: 'p_new',
      name: draft.name,
      description: draft.description,
      price: draft.price,
      stockQuantity: draft.stockQuantity,
      unit: draft.unit,
      photos: draft.photos,
      createdAt: DateTime(2026, 9, 10),
      declaration: declaration,
    );
    _products.insert(0, product);
    return product;
  }

  @override
  Future<List<SupplierOrder>> fetchOrders() async {
    fetchOrdersCalls++;
    if (ordersGate != null) await ordersGate!.future;
    return List<SupplierOrder>.unmodifiable(_orders);
  }

  @override
  Future<SupplierOrder> confirmOrder(String orderId) async {
    confirmCalls++;
    if (confirmThrowsNetwork) throw const NetworkFailure();
    if (confirmGate != null) await confirmGate!.future;
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index < 0) throw const ServerFailure('order_not_found');
    final current = _orders[index];
    if (!current.isPending) return current;
    final updated = current.copyWith(status: OrderStatus.confirmed);
    _orders[index] = updated;
    return updated;
  }
}

/// Test picker returning fixed prepared photos without touching the device.
class FakePhotoPicker implements PhotoPicker {
  FakePhotoPicker({List<PreparedPhoto>? results})
    : results =
          results ??
          [
            PreparedPhoto(
              id: 'photo_1',
              name: 'photo.jpg',
              bytes: _defaultPhotoBytes(),
            ),
          ];

  final List<PreparedPhoto> results;
  int calls = 0;
  int lastLimit = 5;

  /// Thrown instead of returning when set, to exercise the failure path.
  Object? throws;

  @override
  Future<List<PreparedPhoto>> pickPhotos({int limit = 5}) async {
    calls++;
    lastLimit = limit;
    final error = throws;
    if (error != null) throw error;
    return results;
  }

  static Uint8List _defaultPhotoBytes() => Uint8List.fromList(fakePngBytes);
}

/// Smallest valid PNG, so picture previews decode for real in widget tests.
const fakePngBytes = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x03, 0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D,
  0xB0, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
  0x44, 0xAE, 0x42, 0x60, 0x82,
];

/// Immediate buyer repository used by widget tests.
class FakeBuyerRepository implements BuyerRepository {
  FakeBuyerRepository({
    List<BuyerProduct>? catalog,
    List<BuyerOrder>? orders,
    this.placeThrowsNetwork = false,
    this.catalogThrows,
    this.ordersThrows,
    this.catalogGate,
    this.ordersGate,
  }) : _catalog = List.of(catalog ?? _defaultCatalog()),
       _orders = List.of(orders ?? _defaultOrders());

  final bool placeThrowsNetwork;

  /// When set, loading the catalog fails with this error.
  Object? catalogThrows;

  /// When set, loading the orders fails with this error.
  Object? ordersThrows;

  /// When set, the catalog waits for this future, to inspect the loading state.
  Completer<void>? catalogGate;

  /// When set, the orders wait for this future, to inspect the loading state.
  Completer<void>? ordersGate;

  int fetchCatalogCalls = 0;
  int fetchOrdersCalls = 0;
  int placeOrderCalls = 0;

  final List<BuyerProduct> _catalog;
  final List<BuyerOrder> _orders;

  static List<BuyerProduct> _defaultCatalog() => const [
    BuyerProduct(
      id: 'p_3001',
      name: 'Tomates fraîches',
      description: 'Tomates de saison.',
      price: 1200,
      stockQuantity: 150,
      unit: 'kg',
      category: CatalogCategory.vegetables,
      location: 'Abidjan',
      sellerName: 'Aminata Diarra',
      published: true,
    ),
    BuyerProduct(
      id: 'p_3002',
      name: 'Oignons rouges',
      price: 800,
      stockQuantity: 320,
      unit: 'sac',
      category: CatalogCategory.vegetables,
      location: 'Korhogo',
      sellerName: 'Fatoumata Keïta',
      published: true,
    ),
    BuyerProduct(
      id: 'p_3003',
      name: 'Manioc frais',
      price: 500,
      stockQuantity: 0,
      unit: 'kg',
      category: CatalogCategory.tubers,
      location: 'Bouaké',
      sellerName: 'Souleymane Bamba',
      published: true,
    ),
    BuyerProduct(
      id: 'p_3004',
      name: 'Riz local',
      price: 1000,
      stockQuantity: 200,
      unit: 'sac',
      category: CatalogCategory.cereals,
      location: 'Yamoussoukro',
      sellerName: 'Aminata Diarra',
      published: true,
    ),
    BuyerProduct(
      id: 'p_3005',
      name: 'Ananas',
      price: 1500,
      stockQuantity: 60,
      unit: 'pièce',
      category: CatalogCategory.fruits,
      location: 'San-Pedro',
      sellerName: 'Kadiatou Sow',
      published: true,
    ),
    BuyerProduct(
      id: 'p_3006',
      name: 'Piment frais',
      price: 900,
      stockQuantity: 100,
      unit: 'kg',
      category: CatalogCategory.spices,
      location: 'Daloa',
      sellerName: 'Moussa Koné',
      published: true,
    ),
  ];

  static List<BuyerOrder> _defaultOrders() => [
    BuyerOrder(
      id: 'b_4001',
      items: [
        BuyerOrderItem(
          productId: 'p_3001',
          productName: 'Tomates fraîches',
          unitPrice: 1200,
          quantity: 10,
        ),
        BuyerOrderItem(
          productId: 'p_3002',
          productName: 'Oignons rouges',
          unitPrice: 800,
          quantity: 4,
        ),
      ],
      status: BuyerOrderStatus.pending,
      deliveryAddress: 'Marché de Yopougon, allée 12',
      buyerPhone: '+225 07 01 23 45 67',
      createdAt: DateTime(2026, 9, 10),
    ),
    BuyerOrder(
      id: 'b_4002',
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
      driver: const DriverInfo(
        id: 'd_5001',
        fullName: 'Kouamé Yao',
        phone: '+225 07 12 34 56 78',
        vehicleLabel: 'Camion frigorifique · AB-123-CD',
      ),
      createdAt: DateTime(2026, 9, 9),
    ),
    BuyerOrder(
      id: 'b_4003',
      items: [
        BuyerOrderItem(
          productId: 'p_3003',
          productName: 'Manioc frais',
          unitPrice: 500,
          quantity: 5,
        ),
      ],
      status: BuyerOrderStatus.delivered,
      deliveryAddress: 'Supermarché Carrefour, Adjamé',
      buyerPhone: '+225 07 01 23 45 67',
      createdAt: DateTime(2026, 9, 6),
    ),
    BuyerOrder(
      id: 'b_4004',
      items: [
        BuyerOrderItem(
          productId: 'p_3005',
          productName: 'Ananas',
          unitPrice: 1500,
          quantity: 3,
        ),
      ],
      status: BuyerOrderStatus.cancelled,
      deliveryAddress: 'Restaurant Le Baobab, Plateau',
      buyerPhone: '+225 07 01 23 45 67',
      createdAt: DateTime(2026, 9, 3),
    ),
  ];

  @override
  Future<List<BuyerProduct>> fetchCatalog() async {
    fetchCatalogCalls++;
    if (catalogGate != null) await catalogGate!.future;
    if (catalogThrows != null) throw catalogThrows!;
    return List<BuyerProduct>.unmodifiable(_catalog);
  }

  @override
  Future<List<BuyerOrder>> fetchOrders() async {
    fetchOrdersCalls++;
    if (ordersGate != null) await ordersGate!.future;
    if (ordersThrows != null) throw ordersThrows!;
    return List<BuyerOrder>.unmodifiable(_orders);
  }

  /// Swaps the orders the next load will return.
  ///
  /// A real refresh can bring a history the previous load did not have, and
  /// can leave behind a status that used to be there.
  void setOrders(List<BuyerOrder> orders) {
    _orders
      ..clear()
      ..addAll(orders);
  }

  @override
  Future<BuyerOrder> placeOrder(PlaceOrderRequest request) async {
    placeOrderCalls++;
    if (placeThrowsNetwork) throw const NetworkFailure();
    final now = DateTime.now();
    final order = BuyerOrder(
      id: 'b_${now.millisecondsSinceEpoch}',
      items: request.items,
      status: BuyerOrderStatus.pending,
      deliveryAddress: request.deliveryAddress,
      deliveryNote: request.deliveryNote,
      buyerPhone: request.buyerPhone,
      createdAt: now,
    );
    _orders.insert(0, order);
    return order;
  }
}

/// Immediate driver repository used by widget tests.
class FakeDriverRepository implements DriverRepository {
  FakeDriverRepository({
    List<DriverDelivery>? deliveries,
    List<DeliveryTrip>? trips,
    this.updateThrowsNetwork = false,
    this.updateGate,
    this.deliveriesGate,
    this.deliveriesThrows,
    this.tripsGate,
    this.tripsThrows,
  }) : _deliveries = List.of(deliveries ?? _defaultDeliveries()),
       _trips = List.of(trips ?? _defaultTrips());

  /// When set, status updates fail with a network error, to inspect the
  /// honest state of a sheet whose action did not go through. Switched back off
  /// by a test to inspect the recovery.
  bool updateThrowsNetwork;

  /// When set, status updates wait for this future (double-tap simulation).
  Completer<void>? updateGate;

  /// When set, the delivery load waits for this future, to inspect the
  /// dashboard before the deliveries are known.
  Completer<void>? deliveriesGate;

  /// When set, the delivery load fails with this error, to inspect the failed
  /// state of a sheet opened without a working list.
  Object? deliveriesThrows;

  /// When set, the trip load waits for this future, to inspect the history
  /// before its routes are known.
  Completer<void>? tripsGate;

  /// When set, the trip load fails with this error, to inspect the failed
  /// state of the history.
  Object? tripsThrows;

  int fetchDeliveriesCalls = 0;
  int fetchTripsCalls = 0;
  int updateCalls = 0;

  final List<DriverDelivery> _deliveries;
  final List<DeliveryTrip> _trips;

  static List<DriverDelivery> _defaultDeliveries() => [
    DriverDelivery(
      id: 'd1',
      orderId: 'b_9001',
      customerName: 'Aminata',
      customerPhone: '+225 07 00 00 00 01',
      pickupLocation: 'Marché de gros, Abidjan',
      deliveryAddress: 'Yopougon, allée 4',
      items: const [
        DriverDeliveryItem(
          productId: 'p1',
          productName: 'Tomates',
          quantity: 10,
          unit: 'kg',
        ),
      ],
      status: DriverDeliveryStatus.pickUp,
      scheduledAt: DateTime(2026, 9, 10),
      createdAt: DateTime(2026, 9, 9),
    ),
    DriverDelivery(
      id: 'd2',
      orderId: 'b_9002',
      customerName: 'Fatoumata',
      customerPhone: '+225 07 00 00 00 02',
      pickupLocation: 'Entrepôt central',
      deliveryAddress: 'Cocody, stand 8',
      items: const [
        DriverDeliveryItem(
          productId: 'p2',
          productName: 'Manioc',
          quantity: 30,
          unit: 'kg',
        ),
      ],
      status: DriverDeliveryStatus.inTransit,
      scheduledAt: DateTime(2026, 9, 10),
      createdAt: DateTime(2026, 9, 9),
    ),
    DriverDelivery(
      id: 'd3',
      orderId: 'b_9003',
      customerName: 'Souleymane',
      customerPhone: '+225 07 00 00 00 03',
      pickupLocation: 'Marché de gros, Abidjan',
      deliveryAddress: 'Adjamé, point relais',
      items: const [
        DriverDeliveryItem(
          productId: 'p1',
          productName: 'Tomates',
          quantity: 5,
          unit: 'kg',
        ),
      ],
      status: DriverDeliveryStatus.delivered,
      scheduledAt: DateTime(2026, 9, 8),
      createdAt: DateTime(2026, 9, 7),
    ),
  ];

  static List<DeliveryTrip> _defaultTrips() => [
    DeliveryTrip(
      id: 't1',
      routeLabel: 'Adjamé → Yopougon',
      vehicleLabel: 'Fourgonnette · ZZ-000-AA',
      deliveryIds: const ['d1', 'd2'],
      scheduledAt: DateTime(2026, 9, 10),
      createdAt: DateTime(2026, 9, 9),
    ),
  ];

  @override
  Future<List<DriverDelivery>> fetchDeliveries() async {
    fetchDeliveriesCalls++;
    if (deliveriesGate != null) await deliveriesGate!.future;
    if (deliveriesThrows != null) throw deliveriesThrows!;
    return List<DriverDelivery>.unmodifiable(_deliveries);
  }

  @override
  Future<List<DeliveryTrip>> fetchTrips() async {
    fetchTripsCalls++;
    if (tripsGate != null) await tripsGate!.future;
    if (tripsThrows != null) throw tripsThrows!;
    return List<DeliveryTrip>.unmodifiable(_trips);
  }

  @override
  Future<DriverDelivery> updateDeliveryStatus(
    String deliveryId,
    DriverDeliveryStatus status,
  ) async {
    updateCalls++;
    if (updateThrowsNetwork) throw const NetworkFailure();
    if (updateGate != null) await updateGate!.future;
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index < 0) throw const ServerFailure('delivery_not_found');
    final updated = _deliveries[index].copyWith(status: status);
    _deliveries[index] = updated;
    return updated;
  }
}

/// Immediate admin repository used by dashboard tests.
///
/// Every list is served from memory, so the dashboard reaches its loaded state
/// within one frame and a test can inspect the skeleton by holding a gate open
/// instead of waiting for a timer. The moderation and decision methods work on
/// the same lists, so a test can prove the dashboard reacts to a real change
/// rather than to a hard-coded string.
class FakeAdminRepository implements AdminRepository {
  FakeAdminRepository({
    List<AdminUser>? users,
    List<AdminProduct>? products,
    List<AdminOrder>? orders,
    List<AdminDelivery>? deliveries,
    this.statsThrows,
    this.ordersThrows,
    this.deliveriesThrows,
    this.productsThrows,
    this.statsGate,
    this.ordersGate,
  }) : _users = List.of(users ?? _defaultUsers()),
       _products = List.of(products ?? _defaultProducts()),
       _orders = List.of(orders ?? _defaultOrders()),
       _deliveries = List.of(deliveries ?? _defaultDeliveries());

  /// When set, the aggregate fails: the dashboard has to say so instead of
  /// showing figures it does not have.
  Object? statsThrows;

  /// When set, the orders call fails, so one section degrades on its own.
  Object? ordersThrows;
  Object? deliveriesThrows;

  /// When set, both the moderation queue and the dashboard's own moderation
  /// section fail: the products list has two readers and they degrade together.
  Object? productsThrows;

  /// When set, the matching call waits for this future, which is how a test
  /// observes the dashboard before its data is known.
  Completer<void>? statsGate;
  Completer<void>? ordersGate;

  int fetchStatsCalls = 0;
  int fetchOrdersCalls = 0;
  int fetchDeliveriesCalls = 0;
  int fetchPendingProductsCalls = 0;

  final List<AdminUser> _users;
  final List<AdminProduct> _products;
  final List<AdminOrder> _orders;
  final List<AdminDelivery> _deliveries;

  static List<AdminUser> _defaultUsers() => [
    AdminUser(
      id: 'u1',
      fullName: 'Awa Traore',
      email: 'awa@agriconnect.app',
      role: UserRole.supplier,
      joinedAt: DateTime(2026, 7, 2),
      lastActiveAt: DateTime(2026, 9, 10),
      ordersCount: 4,
      productsCount: 3,
      verified: true,
    ),
    AdminUser(
      id: 'u2',
      fullName: 'Moussa Konate',
      email: 'moussa@agriconnect.app',
      role: UserRole.supplier,
      joinedAt: DateTime(2026, 8, 11),
      lastActiveAt: DateTime(2026, 9, 9),
      productsCount: 2,
    ),
    AdminUser(
      id: 'u3',
      fullName: 'Fatoumata Keita',
      email: 'fatoumata@agriconnect.app',
      role: UserRole.buyer,
      joinedAt: DateTime(2026, 6, 20),
      lastActiveAt: DateTime(2026, 9, 10),
      ordersCount: 7,
      verified: true,
    ),
    AdminUser(
      id: 'u4',
      fullName: 'Kouame Yao',
      email: 'kouame@agriconnect.app',
      role: UserRole.driver,
      joinedAt: DateTime(2026, 5, 4),
      lastActiveAt: DateTime(2026, 9, 10),
      deliveriesCount: 31,
    ),
    AdminUser(
      id: 'u5',
      fullName: 'Adjoua Kouadio',
      email: 'adjoua@agriconnect.app',
      role: UserRole.driver,
      joinedAt: DateTime(2026, 9, 8),
      lastActiveAt: DateTime(2026, 9, 9),
      deliveriesCount: 2,
    ),
    AdminUser(
      id: 'u6',
      fullName: 'Bakary Diarra',
      email: 'bakary@agriconnect.app',
      role: UserRole.supplier,
      joinedAt: DateTime(2026, 9, 11),
      lastActiveAt: DateTime(2026, 9, 11),
      status: AdminAccountStatus.verificationPending,
    ),
  ];

  static List<AdminProduct> _defaultProducts() => [
    AdminProduct(
      id: 'p1',
      name: 'Tomates de saison',
      category: 'Legumes',
      price: 1200,
      stockQuantity: 150,
      unit: 'kg',
      ownerId: 'u1',
      ownerName: 'Awa Traore',
      submittedAt: DateTime(2026, 9, 1),
      moderation: AdminModerationStatus.validated,
    ),
    AdminProduct(
      id: 'p2',
      name: 'Riz local',
      category: 'Cereales',
      price: 900,
      stockQuantity: 200,
      unit: 'sac',
      ownerId: 'u2',
      ownerName: 'Moussa Konate',
      submittedAt: DateTime(2026, 9, 3),
      moderation: AdminModerationStatus.validated,
    ),
    AdminProduct(
      id: 'p3',
      name: 'Ananas',
      category: 'Fruits',
      price: 1500,
      stockQuantity: 60,
      unit: 'piece',
      ownerId: 'u1',
      ownerName: 'Awa Traore',
      submittedAt: DateTime(2026, 9, 9),
    ),
    AdminProduct(
      id: 'p4',
      name: 'Piment fort',
      category: 'Epices',
      price: 800,
      stockQuantity: 45,
      unit: 'kg',
      ownerId: 'u2',
      ownerName: 'Moussa Konate',
      submittedAt: DateTime(2026, 9, 10),
    ),
  ];

  static List<AdminOrder> _defaultOrders() => [
    AdminOrder(
      id: 'o1',
      orderNumber: 'CMD-1001',
      status: AdminOrderStatus.pending,
      buyerId: 'u3',
      buyerName: 'Fatoumata Keita',
      sellerId: 'u1',
      sellerName: 'Awa Traore',
      amount: 45000,
      itemCount: 2,
      placedAt: DateTime(2026, 9, 10),
      items: const [
        AdminOrderItem(
          productId: 'p1',
          name: 'Tomates de saison',
          quantity: 20,
          unit: 'kg',
          unitPrice: 1200,
        ),
        AdminOrderItem(
          productId: 'p2',
          name: 'Riz local',
          quantity: 15,
          unit: 'sac',
          unitPrice: 1400,
        ),
      ],
    ),
    AdminOrder(
      id: 'o2',
      orderNumber: 'CMD-1002',
      status: AdminOrderStatus.confirmed,
      buyerId: 'u3',
      buyerName: 'Fatoumata Keita',
      sellerId: 'u2',
      sellerName: 'Moussa Konate',
      amount: 32000,
      itemCount: 1,
      placedAt: DateTime(2026, 9, 9),
      items: const [
        AdminOrderItem(
          productId: 'p2',
          name: 'Riz local',
          quantity: 20,
          unit: 'sac',
          unitPrice: 1600,
        ),
      ],
    ),
    AdminOrder(
      id: 'o3',
      orderNumber: 'CMD-1003',
      status: AdminOrderStatus.delivered,
      buyerId: 'u3',
      buyerName: 'Fatoumata Keita',
      sellerId: 'u1',
      sellerName: 'Awa Traore',
      amount: 61000,
      itemCount: 3,
      placedAt: DateTime(2026, 9, 6),
      items: const [
        AdminOrderItem(
          productId: 'p3',
          name: 'Ananas',
          quantity: 18,
          unit: 'piece',
          unitPrice: 1500,
        ),
        AdminOrderItem(
          productId: 'p4',
          name: 'Piment fort',
          quantity: 20,
          unit: 'kg',
          unitPrice: 800,
        ),
        AdminOrderItem(
          productId: 'p1',
          name: 'Tomates de saison',
          quantity: 15,
          unit: 'kg',
          unitPrice: 1200,
        ),
      ],
    ),
    AdminOrder(
      id: 'o4',
      orderNumber: 'CMD-1004',
      status: AdminOrderStatus.inTransit,
      buyerId: 'u3',
      buyerName: 'Fatoumata Keita',
      sellerId: 'u2',
      sellerName: 'Moussa Konate',
      amount: 18600,
      itemCount: 2,
      placedAt: DateTime(2026, 9, 5),
      items: const [
        AdminOrderItem(
          productId: 'p4',
          name: 'Piment fort',
          quantity: 12,
          unit: 'kg',
          unitPrice: 800,
        ),
        AdminOrderItem(
          productId: 'p2',
          name: 'Riz local',
          quantity: 10,
          unit: 'sac',
          unitPrice: 900,
        ),
      ],
    ),
    AdminOrder(
      id: 'o5',
      orderNumber: 'CMD-1005',
      status: AdminOrderStatus.cancelled,
      buyerId: 'u3',
      buyerName: 'Fatoumata Keita',
      sellerId: 'u1',
      sellerName: 'Awa Traore',
      amount: 9000,
      itemCount: 1,
      placedAt: DateTime(2026, 9, 2),
      items: const [
        AdminOrderItem(
          productId: 'p3',
          name: 'Ananas',
          quantity: 6,
          unit: 'piece',
          unitPrice: 1500,
        ),
      ],
    ),
  ];

  static List<AdminDelivery> _defaultDeliveries() => [
    AdminDelivery(
      id: 'd1',
      orderId: 'o1',
      status: AdminDeliveryStatus.pickUp,
      driverId: 'u4',
      driverName: 'Kouame Yao',
      pickupLabel: 'Marché de Yopougon, Abidjan',
      destinationLabel: 'Cocody, Riviera 3',
      distanceKm: 12.5,
      baseFee: 2000,
      totalFee: 3500,
      scheduledAt: DateTime(2026, 9, 11),
    ),
    AdminDelivery(
      id: 'd2',
      orderId: 'o4',
      status: AdminDeliveryStatus.inTransit,
      driverId: 'u5',
      driverName: 'Adjoua Kouadio',
      pickupLabel: 'Adjamé, marché',
      destinationLabel: 'Yopougon, allée 4',
      distanceKm: 8.2,
      baseFee: 1500,
      totalFee: 2500,
      scheduledAt: DateTime(2026, 9, 11),
      startedAt: DateTime(2026, 9, 11, 8),
    ),
    AdminDelivery(
      id: 'd3',
      orderId: 'o3',
      status: AdminDeliveryStatus.delivered,
      driverId: 'u4',
      driverName: 'Kouame Yao',
      pickupLabel: 'Plateau, boutique',
      destinationLabel: 'Marcory Résidentiel',
      distanceKm: 6.4,
      baseFee: 1200,
      totalFee: 1800,
      scheduledAt: DateTime(2026, 9, 7),
      startedAt: DateTime(2026, 9, 7, 9),
      completedAt: DateTime(2026, 9, 7, 11),
    ),
    AdminDelivery(
      id: 'd4',
      orderId: 'o5',
      status: AdminDeliveryStatus.cancelled,
      driverId: 'u4',
      driverName: 'Kouame Yao',
      pickupLabel: 'Treichville',
      destinationLabel: 'Yopougon',
      distanceKm: 9.1,
      baseFee: 1000,
      totalFee: 1500,
      scheduledAt: DateTime(2026, 9, 3),
    ),
  ];

  /// Swaps the orders the next load will return, to prove a refresh re-reads
  /// the repository instead of replaying the state it already had.
  void setOrders(List<AdminOrder> orders) {
    _orders
      ..clear()
      ..addAll(orders);
  }

  void setStatsThrows(Object? error) => statsThrows = error;

  @override
  Future<AdminStats> fetchStats() async {
    fetchStatsCalls++;
    if (statsGate != null) await statsGate!.future;
    if (statsThrows != null) throw statsThrows!;
    final pendingUsers = _users
        .where((u) => u.status == AdminAccountStatus.verificationPending)
        .length;
    return AdminStats(
      totalUsers: _users.length,
      farmers: _users.where((u) => u.role == UserRole.supplier).length,
      buyers: _users.where((u) => u.role == UserRole.buyer).length,
      drivers: _users.where((u) => u.role == UserRole.driver).length,
      admins: _users.where((u) => u.role == UserRole.admin).length,
      pendingUsers: pendingUsers,
      publishedProducts: _products.where((p) => p.moderation.isLive).length,
      totalProducts: _products.length,
      pendingProducts: _products
          .where((p) => p.moderation.isUnderReview)
          .length,
      totalOrders: _orders.length,
      pendingOrders: _orders
          .where((o) => o.status == AdminOrderStatus.pending)
          .length,
      activeOrders: _orders.where((o) => o.status.isOpen).length,
      totalDeliveries: _deliveries.length,
      activeDeliveries: _deliveries.where((d) => d.status.isActive).length,
      completedDeliveries: _deliveries
          .where((d) => d.status == AdminDeliveryStatus.delivered)
          .length,
      ordersRevenue: _orders
          .where((o) => o.status != AdminOrderStatus.cancelled)
          .fold<double>(0, (sum, o) => sum + o.amount),
    );
  }

  @override
  Future<List<AdminUser>> fetchUsers({String? query}) async {
    if (query == null || query.isEmpty) {
      return List<AdminUser>.unmodifiable(_users);
    }
    final needle = query.toLowerCase();
    return _users
        .where(
          (u) =>
              u.fullName.toLowerCase().contains(needle) ||
              u.email.toLowerCase().contains(needle),
        )
        .toList(growable: false);
  }

  @override
  Future<List<AdminUser>> fetchPendingModerationUsers() async => _users
      .where((u) => u.status == AdminAccountStatus.verificationPending)
      .toList(growable: false);

  @override
  Future<void> approveUser(String userId) async => _setUserStatus(
    userId,
    AdminAccountStatus.active,
    from: {AdminAccountStatus.verificationPending},
  );

  @override
  Future<void> restrictUser(String userId, {String? reason}) async =>
      _setUserStatus(
        userId,
        AdminAccountStatus.suspended,
        from: {AdminAccountStatus.active},
      );

  @override
  Future<void> reactivateUser(String userId) async => _setUserStatus(
    userId,
    AdminAccountStatus.active,
    from: {AdminAccountStatus.suspended},
  );

  /// Applies an account decision only from the state the workspace offers it in.
  ///
  /// Deliberately synchronous so a refusal surfaces to the caller's Future
  /// instead of being swallowed the way an `async void` helper would.
  void _setUserStatus(
    String userId,
    AdminAccountStatus to, {
    required Set<AdminAccountStatus> from,
  }) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index < 0) throw const ServerFailure('user_not_found');
    final current = _users[index];
    if (current.status == to) return;
    if (!from.contains(current.status)) {
      throw const ServerFailure('invalid_transition');
    }
    _users[index] = current.copyWith(status: to);
  }

  @override
  Future<List<AdminProduct>> fetchProducts({
    String? query,
    AdminModerationStatus? status,
  }) async {
    if (productsThrows != null) throw productsThrows!;
    var result = _products;
    if (status != null) {
      result = result.where((p) => p.moderation == status).toList();
    }
    if (query != null && query.isNotEmpty) {
      final needle = query.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(needle) ||
                p.ownerName.toLowerCase().contains(needle),
          )
          .toList();
    }
    return List<AdminProduct>.unmodifiable(result);
  }

  @override
  Future<AdminProduct?> fetchProductById(String productId) async {
    for (final product in _products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  @override
  Future<List<AdminProduct>> fetchPendingModerationProducts() async {
    fetchPendingProductsCalls++;
    if (productsThrows != null) throw productsThrows!;
    return _products
        .where((p) => p.moderation.isUnderReview)
        .toList(growable: false);
  }

  @override
  Future<void> approveProduct(String productId) async =>
      _setModeration(productId, AdminModerationStatus.validated);

  @override
  Future<void> rejectProduct(String productId, {String? reason}) async =>
      _setModeration(productId, AdminModerationStatus.rejected, reason: reason);

  @override
  Future<void> archiveProduct(String productId) async =>
      _setModeration(productId, AdminModerationStatus.archived);

  /// Mirrors the demo rule: approve/reject only a submitted product, archive
  /// only a decided one, and a rejection records its reason. Synchronous so a
  /// refusal surfaces to the caller's Future instead of being swallowed.
  void _setModeration(
    String productId,
    AdminModerationStatus to, {
    String? reason,
  }) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index < 0) throw const ServerFailure('product_not_found');
    final current = _products[index];
    if (current.moderation == to) return;
    final allowed = switch (to) {
      AdminModerationStatus.validated ||
      AdminModerationStatus.rejected => current.moderation.isUnderReview,
      AdminModerationStatus.archived => current.moderation.isDecided,
      AdminModerationStatus.pending || AdminModerationStatus.suspended => false,
    };
    if (!allowed) throw const ServerFailure('invalid_transition');
    _products[index] = current.copyWith(
      moderation: to,
      rejectionReason: to == AdminModerationStatus.rejected ? reason : null,
    );
  }

  @override
  Future<List<AdminOrder>> fetchOrders({
    String? query,
    AdminOrderStatus? status,
    bool? recent,
  }) async {
    fetchOrdersCalls++;
    if (ordersGate != null) await ordersGate!.future;
    if (ordersThrows != null) throw ordersThrows!;
    var result = _orders;
    if (status != null) {
      result = result.where((o) => o.status == status).toList();
    }
    if (query != null && query.isNotEmpty) {
      final needle = query.toLowerCase();
      result = result
          .where(
            (o) =>
                o.orderNumber.toLowerCase().contains(needle) ||
                o.buyerName.toLowerCase().contains(needle),
          )
          .toList();
    }
    // Newest first: the dashboard lists what happened most recently, and the
    // repository is the only place allowed to decide that order.
    result = List<AdminOrder>.of(result)
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return List<AdminOrder>.unmodifiable(result);
  }

  @override
  Future<AdminOrder?> fetchOrderById(String orderId) async {
    for (final order in _orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    AdminOrderStatus status,
  ) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index < 0) throw const ServerFailure('order_not_found');
    _orders[index] = AdminOrder(
      id: _orders[index].id,
      orderNumber: _orders[index].orderNumber,
      status: status,
      buyerId: _orders[index].buyerId,
      buyerName: _orders[index].buyerName,
      sellerId: _orders[index].sellerId,
      sellerName: _orders[index].sellerName,
      amount: _orders[index].amount,
      itemCount: _orders[index].itemCount,
      placedAt: _orders[index].placedAt,
      deliveryId: _orders[index].deliveryId,
      deliveryStatus: _orders[index].deliveryStatus,
      items: _orders[index].items,
    );
  }

  @override
  Future<List<AdminDelivery>> fetchDeliveries({
    String? query,
    AdminDeliveryStatus? status,
    bool? active,
  }) async {
    fetchDeliveriesCalls++;
    if (deliveriesThrows != null) throw deliveriesThrows!;
    var result = _deliveries;
    if (status != null) {
      result = result.where((d) => d.status == status).toList();
    }
    if (active == true) {
      result = result.where((d) => d.status.isActive).toList();
    } else if (active == false) {
      result = result.where((d) => !d.status.isActive).toList();
    }
    if (query != null && query.isNotEmpty) {
      final needle = query.toLowerCase();
      result = result
          .where(
            (d) =>
                d.driverName.toLowerCase().contains(needle) ||
                d.orderId.toLowerCase().contains(needle),
          )
          .toList();
    }
    return List<AdminDelivery>.unmodifiable(result);
  }

  @override
  Future<AdminDelivery?> fetchDeliveryById(String deliveryId) async {
    for (final delivery in _deliveries) {
      if (delivery.id == deliveryId) return delivery;
    }
    return null;
  }

  @override
  Future<void> updateDeliveryStatus(
    String deliveryId,
    AdminDeliveryStatus status,
  ) async {
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index < 0) throw const ServerFailure('delivery_not_found');
    final current = _deliveries[index];
    if (current.status == status) return;
    // Mirrors the demo rule: a delivery moves one leg forward only.
    final allowed = switch (current.status) {
      AdminDeliveryStatus.pickUp => status == AdminDeliveryStatus.inTransit,
      AdminDeliveryStatus.inTransit => status == AdminDeliveryStatus.delivered,
      AdminDeliveryStatus.delivered || AdminDeliveryStatus.cancelled => false,
    };
    if (!allowed) throw const ServerFailure('invalid_transition');
    _deliveries[index] = AdminDelivery(
      id: current.id,
      orderId: current.orderId,
      status: status,
      driverId: current.driverId,
      driverName: current.driverName,
      pickupLabel: current.pickupLabel,
      destinationLabel: current.destinationLabel,
      distanceKm: current.distanceKm,
      baseFee: current.baseFee,
      totalFee: current.totalFee,
      scheduledAt: current.scheduledAt,
      startedAt: current.startedAt,
      completedAt: current.completedAt,
    );
  }

  @override
  Future<void> assignDriver(String deliveryId, String driverName) async {
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index < 0) throw const ServerFailure('delivery_not_found');
    final current = _deliveries[index];
    _deliveries[index] = AdminDelivery(
      id: current.id,
      orderId: current.orderId,
      status: current.status,
      driverId: 'driver',
      driverName: driverName,
      pickupLabel: current.pickupLabel,
      destinationLabel: current.destinationLabel,
      distanceKm: current.distanceKm,
      baseFee: current.baseFee,
      totalFee: current.totalFee,
      scheduledAt: current.scheduledAt,
      startedAt: current.startedAt,
      completedAt: current.completedAt,
    );
  }

  @override
  List<RoleSection> get managedSections => const [
    RoleSection.dashboard,
    RoleSection.products,
    RoleSection.orders,
    RoleSection.users,
    RoleSection.deliveries,
    RoleSection.analytics,
    RoleSection.profile,
  ];
}

/// Controllable [SuperAdminRepository] for widget tests.
///
/// Every call can be made to fail or to hang, which is how the console's
/// section-level error and skeleton states are observed without a real backend.
/// Writes mutate the in-memory lists exactly as the demo repository does, so a
/// test can assert that a screen reflects what was just written.
class FakeSuperAdminRepository implements SuperAdminRepository {
  FakeSuperAdminRepository({
    List<StaffAccount>? staff,
    List<SystemEvent>? events,
    PlatformSettings? settings,
    this.overviewThrows,
    this.staffThrows,
    this.eventsThrows,
    this.settingsThrows,
    this.overviewGate,
    this.staffGate,
    this.eventsGate,
  }) : _staff = List.of(staff ?? _defaultStaff()),
       _events = List.of(events ?? _defaultEvents()),
       _settings = settings ?? _defaultSettings();

  /// When set, the matching read fails: the console has to say so instead of
  /// showing figures it does not have.
  Object? overviewThrows;
  Object? staffThrows;
  Object? eventsThrows;
  Object? settingsThrows;

  /// When set, the matching read waits for this future, which is how a test
  /// observes the console before its data is known.
  Completer<void>? overviewGate;
  Completer<void>? staffGate;
  Completer<void>? eventsGate;

  int fetchOverviewCalls = 0;
  int fetchStaffCalls = 0;
  int fetchEventsCalls = 0;
  int saveSettingsCalls = 0;
  int updatePermissionsCalls = 0;

  /// Set by [updateStaffPermissions] so a test can assert what was requested.
  Set<StaffPermission>? lastPermissions;

  /// The filters of the last directory read, so a test can assert that the
  /// screen actually asked the repository for a narrowed directory.
  String? lastQuery;
  UserRole? lastRole;
  StaffAccountStatus? lastStatus;

  /// The stored settings, so a test can assert what a save actually wrote
  /// rather than only that a write happened.
  PlatformSettings get storedSettings => _settings;

  final List<StaffAccount> _staff;
  final List<SystemEvent> _events;
  PlatformSettings _settings;

  static PlatformSettings _defaultSettings() => PlatformSettings(
    registrationsOpen: true,
    autoModeration: false,
    maintenanceMode: false,
    supportEmail: 'support@agri-connect.app',
    maxUploadMb: 8,
    updatedAt: DateTime(2026, 9, 1),
  );

  static List<StaffAccount> _defaultStaff() => [
    StaffAccount(
      id: 's1',
      fullName: 'Adjoua Koffi',
      email: 'adjoua@agri-connect.app',
      role: UserRole.root,
      accessLevel: StaffAccessLevel.fullAccess,
      permissions: StaffPermission.values,
      joinedAt: DateTime(2025, 10, 1),
      lastActiveAt: DateTime(2026, 9, 10),
    ),
    StaffAccount(
      id: 's2',
      fullName: 'Mensah Yao',
      email: 'yao@agri-connect.app',
      role: UserRole.admin,
      accessLevel: StaffAccessLevel.fullAccess,
      permissions: const [
        StaffPermission.moderateProducts,
        StaffPermission.superviseDeliveries,
      ],
      joinedAt: DateTime(2026, 1, 12),
      lastActiveAt: DateTime(2026, 9, 9),
    ),
    StaffAccount(
      id: 's3',
      fullName: 'Kouassi N\'Guessan',
      email: 'kouassi@agri-connect.app',
      role: UserRole.admin,
      accessLevel: StaffAccessLevel.readOnly,
      permissions: const [StaffPermission.viewAnalytics],
      joinedAt: DateTime(2026, 5, 4),
      lastActiveAt: DateTime(2026, 9, 1),
    ),
    StaffAccount(
      id: 's4',
      fullName: 'Traore Salimata',
      email: 'salimata@agri-connect.app',
      role: UserRole.admin,
      accessLevel: StaffAccessLevel.suspended,
      permissions: const [StaffPermission.manageOrders],
      joinedAt: DateTime(2025, 12, 2),
      lastActiveAt: DateTime(2026, 8, 20),
    ),
  ];

  static List<SystemEvent> _defaultEvents() => [
    SystemEvent(
      id: 'e1',
      actorName: 'Adjoua Koffi',
      action: SystemEventAction.updatedPermissions,
      target: 'Mensah Yao',
      occurredAt: DateTime(2026, 9, 10, 9),
    ),
    SystemEvent(
      id: 'e2',
      actorName: 'Mensah Yao',
      action: SystemEventAction.moderatedProduct,
      target: 'Plantain bio',
      occurredAt: DateTime(2026, 9, 9, 16),
    ),
  ];

  void setOverviewThrows(Object? error) => overviewThrows = error;

  @override
  Future<PlatformOverview> fetchOverview() async {
    fetchOverviewCalls++;
    if (overviewGate != null) await overviewGate!.future;
    if (overviewThrows != null) throw overviewThrows!;
    return PlatformOverview(
      totalUsers: 42,
      farmers: 24,
      buyers: 12,
      drivers: 6,
      staff: _staff.where((s) => s.isActive).length,
      publishedProducts: 34,
      pendingModeration: 3,
      totalOrders: 18,
      openOrders: 5,
      activeDeliveries: 2,
      grossMerchandiseValue: 156600,
      pendingUsers: 4,
    );
  }

  @override
  Future<List<StaffAccount>> fetchStaff({
    String? query,
    UserRole? role,
    StaffAccountStatus? status,
  }) async {
    fetchStaffCalls++;
    if (staffGate != null) await staffGate!.future;
    if (staffThrows != null) throw staffThrows!;
    lastQuery = query;
    lastRole = role;
    lastStatus = status;
    final needle = query?.trim().toLowerCase() ?? '';
    return List<StaffAccount>.unmodifiable(
      _staff.where((account) {
        if (role != null && account.role != role) return false;
        if (status != null && !status.matches(account)) return false;
        if (needle.isEmpty) return true;
        return account.fullName.toLowerCase().contains(needle) ||
            account.email.toLowerCase().contains(needle);
      }),
    );
  }

  @override
  Future<List<SystemEvent>> fetchRecentEvents() async {
    fetchEventsCalls++;
    if (eventsGate != null) await eventsGate!.future;
    if (eventsThrows != null) throw eventsThrows!;
    return List<SystemEvent>.unmodifiable(_events);
  }

  @override
  Future<PlatformSettings> fetchSettings() async {
    if (settingsThrows != null) throw settingsThrows!;
    return _settings;
  }

  @override
  Future<void> saveSettings(PlatformSettings settings) async {
    saveSettingsCalls++;
    if (settingsThrows != null) throw settingsThrows!;
    _settings = settings.copyWith(updatedAt: DateTime(2026, 9, 12));
  }

  @override
  Future<void> updateStaffPermissions(
    String staffId,
    Set<StaffPermission> permissions,
  ) async {
    updatePermissionsCalls++;
    final index = _staff.indexWhere((s) => s.id == staffId);
    if (index < 0) {
      throw StateError('Staff member $staffId is no longer in the directory.');
    }
    final account = _staff[index];
    if (!account.canReceiveMoreRights) {
      throw StateError('A Super Admin with full access cannot be demoted.');
    }
    final next = permissions.where((p) => !p.isSuperAdminOnly).toList();
    if (account.role == UserRole.root) {
      next.add(StaffPermission.managePlatformSettings);
    }
    _staff[index] = account.copyWith(permissions: next);
    lastPermissions = next.toSet();
  }

  @override
  Future<void> suspendStaff(String staffId) async {
    final index = _staff.indexWhere((s) => s.id == staffId);
    if (index < 0) {
      throw StateError('Staff member $staffId is no longer in the directory.');
    }
    final account = _staff[index];
    if (account.role == UserRole.root && account.isActive) {
      throw StateError('A Super Admin cannot be suspended.');
    }
    _staff[index] = account.copyWith(accessLevel: StaffAccessLevel.suspended);
  }

  @override
  Future<void> restoreStaff(String staffId) async {
    final index = _staff.indexWhere((s) => s.id == staffId);
    if (index < 0) {
      throw StateError('Staff member $staffId is no longer in the directory.');
    }
    _staff[index] = _staff[index].copyWith(
      accessLevel: StaffAccessLevel.readOnly,
    );
  }

  @override
  List<RoleSection> get managedSections => const [
    RoleSection.dashboard,
    RoleSection.users,
    RoleSection.platform,
    RoleSection.analytics,
    RoleSection.profile,
  ];
}

/// Immediate agent repository used by the agent workspace tests.
///
/// Every list is served from memory so a section reaches its loaded state within
/// one frame; a test observes a loading state by holding [fetchGate] open, and a
/// failure by setting [fetchThrows] or [actionThrows]. Writes mutate the same
/// lists, so a test can prove a section reflects a change rather than replaying
/// a hard-coded string.
class FakeAgentRepository implements AgentRepository {
  FakeAgentRepository({
    List<SupportRequest>? supportRequests,
    List<StockValidationCase>? stockValidations,
    List<OrderProcessingCase>? orderCases,
    List<PaymentFollowupCase>? paymentFollowups,
    this.fetchThrows,
    this.actionThrows,
    this.fetchGate,
    this.actionGate,
    Map<String, Object?>? fetchFailures,
    Map<String, Completer<void>>? fetchGates,
  }) : _supportRequests = List.of(supportRequests ?? _defaultSupport()),
       _stockValidations = List.of(stockValidations ?? _defaultStock()),
       _orderCases = List.of(orderCases ?? _defaultOrders()),
       _paymentFollowups = List.of(paymentFollowups ?? _defaultPayments()),
       fetchFailures = fetchFailures ?? {},
       fetchGates = fetchGates ?? {};

  /// When set, every read fails with this error.
  Object? fetchThrows;

  /// When set, every action fails with this error. Switched back off by a test
  /// to inspect the recovery.
  Object? actionThrows;

  /// When set, every read waits for this future, to inspect the loading state.
  Completer<void>? fetchGate;

  /// Per-section controls for tests that need queues to load independently.
  final Map<String, Object?> fetchFailures;
  final Map<String, Completer<void>> fetchGates;

  /// When set, every action waits for this future (double-tap simulation).
  Completer<void>? actionGate;

  int fetchSupportCalls = 0;
  int fetchStockCalls = 0;
  int fetchOrderCalls = 0;
  int fetchPaymentCalls = 0;

  /// Total number of write actions dispatched, whatever the section.
  int actionCalls = 0;

  final List<SupportRequest> _supportRequests;
  final List<StockValidationCase> _stockValidations;
  final List<OrderProcessingCase> _orderCases;
  final List<PaymentFollowupCase> _paymentFollowups;

  static List<SupportRequest> _defaultSupport() => [
    SupportRequest(
      id: 'sup_1',
      reference: 'SUP-1001',
      buyerName: 'Marie Koné',
      subject: 'Colis incomplet',
      summary: 'Deux kilos de mangues manquants.',
      status: SupportRequestStatus.open,
      priority: SupportPriority.high,
      createdAt: DateTime(2026, 9, 10),
    ),
    SupportRequest(
      id: 'sup_2',
      reference: 'SUP-1002',
      buyerName: 'Aminata Diarra',
      subject: 'Retard de livraison',
      summary: 'La livraison attendue hier n\'est pas arrivée.',
      status: SupportRequestStatus.inProgress,
      priority: SupportPriority.normal,
      createdAt: DateTime(2026, 9, 9),
    ),
    SupportRequest(
      id: 'sup_3',
      reference: 'SUP-1003',
      buyerName: 'Souleymane Bamba',
      subject: 'Question paiement',
      summary: 'Le client ne retrouve pas sa référence.',
      status: SupportRequestStatus.resolved,
      priority: SupportPriority.normal,
      createdAt: DateTime(2026, 9, 8),
    ),
  ];

  static List<StockValidationCase> _defaultStock() => [
    StockValidationCase(
      id: 'stk_1',
      reference: 'STK-2001',
      productName: 'Riz local',
      supplierName: 'Coopérative de Bouaké',
      declaredQuantity: 120,
      unit: 'sac',
      location: 'Entrepôt de Yamoussoukro',
      status: StockValidationStatus.pending,
      submittedAt: DateTime(2026, 9, 10),
    ),
    StockValidationCase(
      id: 'stk_2',
      reference: 'STK-2002',
      productName: 'Tomates fraîches',
      supplierName: 'Maraîchers d\'Adjamé',
      declaredQuantity: 300,
      unit: 'kg',
      location: 'Marché de gros d\'Adjamé',
      status: StockValidationStatus.validated,
      submittedAt: DateTime(2026, 9, 9),
    ),
  ];

  static List<OrderProcessingCase> _defaultOrders() => [
    OrderProcessingCase(
      id: 'ord_1',
      reference: 'CMD-3001',
      buyerName: 'Restaurant Le Baobab',
      sellerName: 'Coopérative de Bouaké',
      itemCount: 6,
      amount: 145000,
      status: OrderProcessingStatus.awaiting,
      placedAt: DateTime(2026, 9, 10),
    ),
    OrderProcessingCase(
      id: 'ord_2',
      reference: 'CMD-3002',
      buyerName: 'Épicerie du Plateau',
      sellerName: 'Maraîchers d\'Adjamé',
      itemCount: 3,
      amount: 62000,
      status: OrderProcessingStatus.processed,
      placedAt: DateTime(2026, 9, 8),
    ),
  ];

  static List<PaymentFollowupCase> _defaultPayments() => [
    PaymentFollowupCase(
      id: 'pay_1',
      reference: 'PAY-4001',
      payerName: 'Restaurant Le Baobab',
      amount: 145000,
      method: 'Mobile money',
      status: PaymentFollowupStatus.due,
      dueAt: DateTime(2026, 9, 12),
    ),
    PaymentFollowupCase(
      id: 'pay_2',
      reference: 'PAY-4002',
      payerName: 'Hôtel Ivoire',
      amount: 320000,
      method: 'Virement bancaire',
      status: PaymentFollowupStatus.confirmed,
      dueAt: DateTime(2026, 9, 8),
    ),
  ];

  Future<void> _beforeFetch(String section) async {
    if (fetchGate != null) await fetchGate!.future;
    final gate = fetchGates[section];
    if (gate != null) await gate.future;
    if (fetchThrows != null) throw fetchThrows!;
    final failure = fetchFailures[section];
    if (failure != null) throw failure;
  }

  Future<void> _beforeAction() async {
    actionCalls++;
    if (actionThrows != null) throw actionThrows!;
    if (actionGate != null) await actionGate!.future;
  }

  @override
  Future<List<SupportRequest>> fetchSupportRequests() async {
    fetchSupportCalls++;
    await _beforeFetch('support');
    return List<SupportRequest>.unmodifiable(_supportRequests);
  }

  @override
  Future<SupportRequest> updateSupportRequest(
    String requestId,
    SupportRequestStatus status,
  ) async {
    await _beforeAction();
    final index = _supportRequests.indexWhere((r) => r.id == requestId);
    if (index < 0) throw const ServerFailure('support_request_not_found');
    final current = _supportRequests[index];
    if (current.status == status) return current;
    final updated = current.copyWith(status: status);
    _supportRequests[index] = updated;
    return updated;
  }

  @override
  Future<List<StockValidationCase>> fetchStockValidations() async {
    fetchStockCalls++;
    await _beforeFetch('stock');
    return List<StockValidationCase>.unmodifiable(_stockValidations);
  }

  @override
  Future<StockValidationCase> decideStockValidation(
    String caseId,
    StockValidationStatus status,
  ) async {
    await _beforeAction();
    final index = _stockValidations.indexWhere((c) => c.id == caseId);
    if (index < 0) throw const ServerFailure('stock_case_not_found');
    final current = _stockValidations[index];
    if (current.status == status) return current;
    final updated = current.copyWith(status: status);
    _stockValidations[index] = updated;
    return updated;
  }

  @override
  Future<List<OrderProcessingCase>> fetchOrderCases() async {
    fetchOrderCalls++;
    await _beforeFetch('orders');
    return List<OrderProcessingCase>.unmodifiable(_orderCases);
  }

  @override
  Future<OrderProcessingCase> advanceOrderProcessing(
    String orderId,
    OrderProcessingStatus status,
  ) async {
    await _beforeAction();
    final index = _orderCases.indexWhere((o) => o.id == orderId);
    if (index < 0) throw const ServerFailure('order_case_not_found');
    final current = _orderCases[index];
    if (current.status == status) return current;
    final updated = current.copyWith(status: status);
    _orderCases[index] = updated;
    return updated;
  }

  @override
  Future<List<PaymentFollowupCase>> fetchPaymentFollowups() async {
    fetchPaymentCalls++;
    await _beforeFetch('payments');
    return List<PaymentFollowupCase>.unmodifiable(_paymentFollowups);
  }

  @override
  Future<PaymentFollowupCase> confirmPayment(String paymentId) async {
    await _beforeAction();
    final index = _paymentFollowups.indexWhere((p) => p.id == paymentId);
    if (index < 0) throw const ServerFailure('payment_not_found');
    final current = _paymentFollowups[index];
    if (current.isConfirmed) return current;
    final updated = current.copyWith(status: PaymentFollowupStatus.confirmed);
    _paymentFollowups[index] = updated;
    return updated;
  }
}
