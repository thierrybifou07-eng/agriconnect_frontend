import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/admin/domain/admin_account_status.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/domain/admin_moderation_status.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';
import 'package:agri_connect/features/admin/domain/admin_product.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/domain/admin_stats.dart';
import 'package:agri_connect/features/admin/domain/admin_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

/// In-memory Administrator demo backing the workspace pages.
///
/// Deterministic seeds so lists, detail views and the stats funnel all render
/// without a backend, mirroring how the driver space demo behaves.
///
/// Every mutation writes to the lists this instance holds and every read serves
/// them back, so a decision taken on one screen (approve a product, assign a
/// driver, move a delivery forward) is visible on the next — for the lifetime of
/// this instance. Nothing is persisted to disk: a restart rebuilds the seeds.
class DemoAdminRepository implements AdminRepository {
  DemoAdminRepository({this.latency = const Duration(milliseconds: 140)})
    : _users = _seedUsers(),
      _products = _seedProducts(),
      _orders = _seedOrders(),
      _deliveries = _seedDeliveries();

  final Duration latency;

  final List<AdminUser> _users;
  final List<AdminProduct> _products;
  final List<AdminOrder> _orders;
  final List<AdminDelivery> _deliveries;

  Future<T> _go<T>(T Function() job) async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
    return job();
  }

  @override
  Future<List<AdminUser>> fetchUsers({String? query}) => _go(() {
    var list = List<AdminUser>.of(_users);
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list
          .where(
            (u) =>
                u.fullName.toLowerCase().contains(q) ||
                u.email.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  });

  @override
  Future<List<AdminUser>> fetchPendingModerationUsers() => _go(
    () => _users
        .where((u) => u.status == AdminAccountStatus.verificationPending)
        .toList(),
  );

  @override
  Future<void> approveUser(String userId) => _go(
    () => _setUserStatus(
      userId,
      AdminAccountStatus.active,
      from: {AdminAccountStatus.verificationPending},
    ),
  );

  @override
  Future<void> restrictUser(String userId, {String? reason}) => _go(
    () => _setUserStatus(
      userId,
      AdminAccountStatus.suspended,
      from: {AdminAccountStatus.active},
    ),
  );

  @override
  Future<void> reactivateUser(String userId) => _go(
    () => _setUserStatus(
      userId,
      AdminAccountStatus.active,
      from: {AdminAccountStatus.suspended},
    ),
  );

  /// Applies an account decision only from the state the workspace offers it in.
  ///
  /// Refusing an incompatible state here as well as in the menu keeps the rule
  /// in one place the domain owns, rather than trusting the button to hide it.
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
  }) => _go(() {
    var list = List<AdminProduct>.of(_products);
    if (status != null) {
      list = list.where((p) => p.moderation == status).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.ownerName.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  });

  @override
  Future<AdminProduct?> fetchProductById(String productId) => _go(() {
    for (final p in _products) {
      if (p.id == productId) return p;
    }
    return null;
  });

  @override
  Future<List<AdminProduct>> fetchPendingModerationProducts() => _go(
    () => _products
        .where((p) => p.moderation == AdminModerationStatus.pending)
        .toList(),
  );

  @override
  Future<void> approveProduct(String productId) =>
      _go(() => _setModeration(productId, AdminModerationStatus.validated));

  @override
  Future<void> rejectProduct(String productId, {String? reason}) => _go(
    () => _setModeration(
      productId,
      AdminModerationStatus.rejected,
      reason: reason,
    ),
  );

  @override
  Future<void> archiveProduct(String productId) =>
      _go(() => _setModeration(productId, AdminModerationStatus.archived));

  /// Applies a moderation decision the workspace actually offers for the
  /// current state: approve/reject only a submitted product, archive only a
  /// decided one. A rejection records its reason, as the model documents.
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
    bool? recent,
    AdminOrderStatus? status,
  }) => _go(() {
    var list = List<AdminOrder>.of(_orders);
    if (status != null) {
      list = list.where((o) => o.status == status).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list
          .where(
            (o) =>
                o.orderNumber.toLowerCase().contains(q) ||
                o.buyerName.toLowerCase().contains(q) ||
                o.sellerName.toLowerCase().contains(q),
          )
          .toList();
    }
    if (recent == true) {
      list.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    }
    return list;
  });

  @override
  Future<AdminOrder?> fetchOrderById(String orderId) => _go(() {
    for (final o in _orders) {
      if (o.id == orderId) return o;
    }
    return null;
  });

  @override
  Future<void> updateOrderStatus(String orderId, AdminOrderStatus status) =>
      _go(() {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index < 0) throw const ServerFailure('order_not_found');
        final current = _orders[index];
        if (current.status == status) return;
        _orders[index] = _orderWithStatus(current, status);
      });

  @override
  Future<List<AdminDelivery>> fetchDeliveries({
    String? query,
    bool? active,
    AdminDeliveryStatus? status,
  }) => _go(() {
    var list = List<AdminDelivery>.of(_deliveries);
    if (status != null) {
      list = list.where((d) => d.status == status).toList();
    }
    if (active == true) {
      list = list.where((d) => d.status.isActive).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list
          .where(
            (d) =>
                d.driverName.toLowerCase().contains(q) ||
                d.pickupLabel.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  });

  @override
  Future<AdminDelivery?> fetchDeliveryById(String deliveryId) => _go(() {
    for (final d in _deliveries) {
      if (d.id == deliveryId) return d;
    }
    return null;
  });

  @override
  Future<void> updateDeliveryStatus(
    String deliveryId,
    AdminDeliveryStatus status,
  ) => _go(() {
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index < 0) throw const ServerFailure('delivery_not_found');
    final current = _deliveries[index];
    if (current.status == status) return;
    // The workspace only ever moves a delivery one leg forward: pick-up then
    // in transit then delivered. Anything else is refused rather than silently
    // accepted.
    final allowed = switch (current.status) {
      AdminDeliveryStatus.pickUp => status == AdminDeliveryStatus.inTransit,
      AdminDeliveryStatus.inTransit => status == AdminDeliveryStatus.delivered,
      AdminDeliveryStatus.delivered || AdminDeliveryStatus.cancelled => false,
    };
    if (!allowed) throw const ServerFailure('invalid_transition');
    _deliveries[index] = _deliveryWithStatus(current, status);
  });

  @override
  Future<void> assignDriver(String deliveryId, String driverName) => _go(() {
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index < 0) throw const ServerFailure('delivery_not_found');
    final current = _deliveries[index];
    _deliveries[index] = AdminDelivery(
      id: current.id,
      orderId: current.orderId,
      status: current.status,
      // The assignment dialog takes a free-text name; there is no driver
      // directory in the admin contract to resolve a real id against.
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
  });

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

  @override
  Future<AdminStats> fetchStats() => _go(() {
    final users = _users;
    final products = _products;
    final orders = _orders;
    final deliveries = _deliveries;
    return AdminStats(
      totalUsers: users.length,
      farmers: users.where((u) => u.role == UserRole.supplier).length,
      buyers: users.where((u) => u.role == UserRole.buyer).length,
      drivers: users.where((u) => u.role == UserRole.driver).length,
      admins: users.where((u) => u.role == UserRole.admin).length,
      publishedProducts: products.where((p) => p.moderation.isLive).length,
      totalProducts: products.length,
      pendingProducts: products.where((p) => p.moderation.isUnderReview).length,
      totalOrders: orders.length,
      pendingOrders: orders
          .where((o) => o.status == AdminOrderStatus.pending)
          .length,
      activeOrders: orders.where((o) => o.status.isOpen).length,
      totalDeliveries: deliveries.length,
      activeDeliveries: deliveries.where((d) => d.status.isActive).length,
      completedDeliveries: deliveries
          .where((d) => d.status == AdminDeliveryStatus.delivered)
          .length,
      ordersRevenue: orders.fold(0.0, (sum, o) => sum + o.amount),
      pendingUsers: users
          .where((u) => u.status == AdminAccountStatus.verificationPending)
          .length,
    );
  });

  AdminOrder _orderWithStatus(AdminOrder order, AdminOrderStatus status) {
    return AdminOrder(
      id: order.id,
      orderNumber: order.orderNumber,
      status: status,
      buyerId: order.buyerId,
      buyerName: order.buyerName,
      sellerId: order.sellerId,
      sellerName: order.sellerName,
      amount: order.amount,
      itemCount: order.itemCount,
      placedAt: order.placedAt,
      deliveryId: order.deliveryId,
      deliveryStatus: order.deliveryStatus,
      items: order.items,
    );
  }

  AdminDelivery _deliveryWithStatus(
    AdminDelivery delivery,
    AdminDeliveryStatus status,
  ) {
    return AdminDelivery(
      id: delivery.id,
      orderId: delivery.orderId,
      status: status,
      driverId: delivery.driverId,
      driverName: delivery.driverName,
      pickupLabel: delivery.pickupLabel,
      destinationLabel: delivery.destinationLabel,
      distanceKm: delivery.distanceKm,
      baseFee: delivery.baseFee,
      totalFee: delivery.totalFee,
      scheduledAt: delivery.scheduledAt,
      startedAt: delivery.startedAt,
      completedAt: delivery.completedAt,
    );
  }

  static DateTime _d(int daysAgo, int hour) => DateTime.now()
      .subtract(Duration(days: daysAgo))
      .subtract(Duration(hours: DateTime.now().hour - hour));

  static List<AdminUser> _seedUsers() {
    return [
      AdminUser(
        id: 'u1',
        fullName: 'Lydia Mensah',
        email: 'lydia@farm.local',
        role: UserRole.supplier,
        joinedAt: _d(400, 9),
        lastActiveAt: _d(0, 2),
        status: AdminAccountStatus.active,
        ordersCount: 122,
        productsCount: 48,
        deliveriesCount: 60,
        verified: true,
      ),
      AdminUser(
        id: 'u2',
        fullName: 'Kofi Amoah',
        email: 'kofi@farm.local',
        role: UserRole.supplier,
        joinedAt: _d(320, 11),
        lastActiveAt: _d(1, 14),
        status: AdminAccountStatus.verificationPending,
        ordersCount: 54,
        productsCount: 18,
        deliveriesCount: 20,
        verified: false,
      ),
      AdminUser(
        id: 'u3',
        fullName: 'Chloé Dubois',
        email: 'chloe@buyer.local',
        role: UserRole.buyer,
        joinedAt: _d(260, 10),
        lastActiveAt: _d(0, 5),
        status: AdminAccountStatus.active,
        ordersCount: 34,
        productsCount: 0,
        deliveriesCount: 8,
        verified: true,
      ),
    ];
  }

  static List<AdminProduct> _seedProducts() {
    return [
      AdminProduct(
        id: 'p1',
        name: 'Yellow Corn',
        category: 'Cereals',
        price: 1850,
        stockQuantity: 240,
        unit: 'kg',
        ownerId: 'u1',
        ownerName: 'Lydia Mensah',
        submittedAt: _d(2, 8),
        moderation: AdminModerationStatus.pending,
      ),
      AdminProduct(
        id: 'p2',
        name: 'Sweet Cassava',
        category: 'Tubers',
        price: 980,
        stockQuantity: 800,
        unit: 'kg',
        ownerId: 'u2',
        ownerName: 'Kofi Amoah',
        submittedAt: _d(4, 9),
        moderation: AdminModerationStatus.pending,
      ),
      AdminProduct(
        id: 'p3',
        name: 'Fresh Tomatoes',
        category: 'Vegetables',
        price: 2600,
        stockQuantity: 120,
        unit: 'kg',
        ownerId: 'u1',
        ownerName: 'Lydia Mensah',
        submittedAt: _d(9, 14),
        moderation: AdminModerationStatus.validated,
      ),
    ];
  }

  static List<AdminOrder> _seedOrders() {
    return [
      AdminOrder(
        id: 'o1',
        orderNumber: 'ORD-221',
        status: AdminOrderStatus.pending,
        buyerId: 'u3',
        buyerName: 'Chloé Dubois',
        sellerId: 'u1',
        sellerName: 'Lydia Mensah',
        amount: 46500,
        itemCount: 3,
        placedAt: _d(1, 9),
        items: const [
          AdminOrderItem(
            productId: 'p1',
            name: 'Yellow Corn',
            quantity: 15,
            unit: 'kg',
            unitPrice: 1200,
          ),
          AdminOrderItem(
            productId: 'p2',
            name: 'Sweet Cassava',
            quantity: 20,
            unit: 'kg',
            unitPrice: 950,
          ),
          AdminOrderItem(
            productId: 'p3',
            name: 'Fresh Tomatoes',
            quantity: 5,
            unit: 'kg',
            unitPrice: 1900,
          ),
        ],
      ),
      AdminOrder(
        id: 'o2',
        orderNumber: 'ORD-334',
        status: AdminOrderStatus.confirmed,
        buyerId: 'u3',
        buyerName: 'Chloé Dubois',
        sellerId: 'u2',
        sellerName: 'Kofi Amoah',
        amount: 73600,
        itemCount: 5,
        placedAt: _d(2, 13),
        items: const [
          AdminOrderItem(
            productId: 'p4',
            name: 'Local Rice',
            quantity: 40,
            unit: 'sac',
            unitPrice: 900,
          ),
          AdminOrderItem(
            productId: 'p5',
            name: 'Hot Pepper',
            quantity: 10,
            unit: 'kg',
            unitPrice: 800,
          ),
          AdminOrderItem(
            productId: 'p6',
            name: 'Pineapple',
            quantity: 12,
            unit: 'piece',
            unitPrice: 1500,
          ),
          AdminOrderItem(
            productId: 'p7',
            name: 'Yam',
            quantity: 8,
            unit: 'kg',
            unitPrice: 700,
          ),
          AdminOrderItem(
            productId: 'p8',
            name: 'Okra',
            quantity: 6,
            unit: 'kg',
            unitPrice: 1000,
          ),
        ],
      ),
      AdminOrder(
        id: 'o3',
        orderNumber: 'ORD-410',
        status: AdminOrderStatus.delivered,
        buyerId: 'u3',
        buyerName: 'Chloé Dubois',
        sellerId: 'u1',
        sellerName: 'Lydia Mensah',
        amount: 26100,
        itemCount: 2,
        placedAt: _d(5, 10),
        items: const [
          AdminOrderItem(
            productId: 'p1',
            name: 'Yellow Corn',
            quantity: 6,
            unit: 'kg',
            unitPrice: 1850,
          ),
          AdminOrderItem(
            productId: 'p3',
            name: 'Fresh Tomatoes',
            quantity: 5,
            unit: 'kg',
            unitPrice: 3000,
          ),
        ],
      ),
    ];
  }

  static List<AdminDelivery> _seedDeliveries() {
    return [
      AdminDelivery(
        id: 'd1',
        orderId: 'o1',
        status: AdminDeliveryStatus.pickUp,
        driverId: 'v1',
        driverName: 'Yann Kouassi',
        pickupLabel: 'Lydia farm — Tamale',
        destinationLabel: 'Chloé — Makola',
        distanceKm: 34,
        baseFee: 2000,
        totalFee: 2600,
        scheduledAt: _d(1, 10),
      ),
      AdminDelivery(
        id: 'd2',
        orderId: 'o2',
        status: AdminDeliveryStatus.inTransit,
        driverId: 'v1',
        driverName: 'Yann Kouassi',
        pickupLabel: 'Kofi farm — Kumasi',
        destinationLabel: 'Chloé — Kaneshie',
        distanceKm: 18,
        baseFee: 1200,
        totalFee: 1650,
        scheduledAt: _d(2, 12),
      ),
      AdminDelivery(
        id: 'd3',
        orderId: 'o3',
        status: AdminDeliveryStatus.delivered,
        driverId: 'v2',
        driverName: 'Ama Owusu',
        pickupLabel: 'Lydia farm — Tamale',
        destinationLabel: 'Chloé — Makola',
        distanceKm: 42,
        baseFee: 2200,
        totalFee: 2800,
        scheduledAt: _d(5, 9),
      ),
    ];
  }
}
