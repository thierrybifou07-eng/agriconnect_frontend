import 'package:agri_connect/core/constants/role_section.dart';

import 'admin_delivery.dart';
import 'admin_moderation_status.dart';
import 'admin_order.dart';
import 'admin_product.dart';
import 'admin_stats.dart';
import 'admin_user.dart';

/// Contract for the Administrator workspace.
///
/// Mirrors the proven `DriverRepository` pattern: a single async surface the
/// application layer consumes, with a rich in-memory demo implementation used
/// in production demos and a fake used by widget tests.
abstract interface class AdminRepository {
  Future<List<AdminUser>> fetchUsers({String? query});

  Future<List<AdminUser>> fetchPendingModerationUsers();

  Future<void> approveUser(String userId);

  Future<void> restrictUser(String userId, {String? reason});

  Future<void> reactivateUser(String userId);

  Future<List<AdminProduct>> fetchProducts({
    String? query,
    AdminModerationStatus? status,
  });

  Future<AdminProduct?> fetchProductById(String productId);

  Future<List<AdminProduct>> fetchPendingModerationProducts();

  Future<void> approveProduct(String productId);

  Future<void> rejectProduct(String productId, {String? reason});

  Future<void> archiveProduct(String productId);

  Future<List<AdminOrder>> fetchOrders({
    String? query,
    AdminOrderStatus? status,
    bool? recent,
  });

  Future<AdminOrder?> fetchOrderById(String orderId);

  Future<void> updateOrderStatus(String orderId, AdminOrderStatus status);

  Future<List<AdminDelivery>> fetchDeliveries({
    String? query,
    AdminDeliveryStatus? status,
    bool? active,
  });

  Future<AdminDelivery?> fetchDeliveryById(String deliveryId);

  Future<void> updateDeliveryStatus(
    String deliveryId,
    AdminDeliveryStatus status,
  );

  Future<void> assignDriver(String deliveryId, String driverName);

  Future<AdminStats> fetchStats();

  /// Sections the current Administrator should manage.
  List<RoleSection> get managedSections;
}
