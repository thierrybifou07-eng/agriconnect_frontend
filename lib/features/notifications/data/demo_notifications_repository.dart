import 'dart:convert';

import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/notifications/data/notification_read_storage.dart';
import 'package:agri_connect/features/notifications/domain/notification_item.dart';

class DemoNotificationsRepository {
  const DemoNotificationsRepository(this._storage);

  final NotificationReadStorage _storage;

  Future<List<NotificationItem>> fetchFor(AuthUser user) async {
    final entries = _demoEntries(user.role, user.capabilities);
    final key = _storageKey(user);
    final readIds = await _storage.readIds(key);
    return List.unmodifiable([
      for (final entry in entries)
        entry.copyWith(isRead: readIds.contains(entry.id)),
    ]);
  }

  Future<void> saveReadState(AuthUser user, Set<String> readIds) =>
      _storage.writeIds(_storageKey(user), readIds);

  String _storageKey(AuthUser user) {
    final userId = base64Url.encode(utf8.encode(user.id));
    return 'agri_notifications_read_v1_${user.role.name}_$userId';
  }

  List<NotificationItem> _demoEntries(
    UserRole role,
    Set<UserCapability> capabilities,
  ) {
    final now = DateTime.now();
    NotificationItem entry(
      String id,
      NotificationCategory category,
      DemoNotificationMessage message,
      RoleSection destination,
      Duration age,
    ) => NotificationItem(
      id: id,
      role: role,
      category: category,
      message: message,
      destination: destination,
      createdAt: now.subtract(age),
    );

    return switch (role) {
      UserRole.buyer => [
        entry(
          'buyer-order-example',
          NotificationCategory.orders,
          DemoNotificationMessage.buyerOrderUpdate,
          RoleSection.orders,
          const Duration(hours: 1),
        ),
        entry(
          'buyer-delivery-example',
          NotificationCategory.deliveries,
          DemoNotificationMessage.buyerDeliveryUpdate,
          RoleSection.orders,
          const Duration(hours: 5),
        ),
      ],
      UserRole.supplier => [
        entry(
          'supplier-order-example',
          NotificationCategory.orders,
          DemoNotificationMessage.supplierNewOrder,
          RoleSection.orders,
          const Duration(hours: 2),
        ),
        entry(
          'supplier-product-example',
          NotificationCategory.products,
          DemoNotificationMessage.supplierProductAction,
          RoleSection.products,
          const Duration(days: 1),
        ),
      ],
      UserRole.driver => [
        entry(
          'driver-delivery-example',
          NotificationCategory.deliveries,
          DemoNotificationMessage.driverDeliveryAssigned,
          RoleSection.deliveries,
          const Duration(hours: 1),
        ),
        entry(
          'driver-trip-example',
          NotificationCategory.deliveries,
          DemoNotificationMessage.driverTripUpdate,
          RoleSection.trips,
          const Duration(hours: 4),
        ),
      ],
      UserRole.agent => [
        if (capabilities.contains(UserCapability.buyerSupport))
          entry(
            'agent-support-example',
            NotificationCategory.support,
            DemoNotificationMessage.agentSupportRequest,
            RoleSection.buyerSupport,
            const Duration(hours: 1),
          ),
        if (capabilities.contains(UserCapability.orderProcessing))
          entry(
            'agent-order-example',
            NotificationCategory.orders,
            DemoNotificationMessage.agentOrderAction,
            RoleSection.orderProcessing,
            const Duration(hours: 3),
          ),
        if (capabilities.contains(UserCapability.stockValidation))
          entry(
            'agent-stock-example',
            NotificationCategory.products,
            DemoNotificationMessage.agentStockReview,
            RoleSection.stockValidation,
            const Duration(days: 1),
          ),
      ],
      UserRole.admin => [
        entry(
          'admin-product-example',
          NotificationCategory.products,
          DemoNotificationMessage.adminProductReview,
          RoleSection.products,
          const Duration(hours: 1),
        ),
        entry(
          'admin-order-example',
          NotificationCategory.orders,
          DemoNotificationMessage.adminOrderReview,
          RoleSection.orders,
          const Duration(hours: 6),
        ),
      ],
      UserRole.root => [
        entry(
          'root-platform-example',
          NotificationCategory.administration,
          DemoNotificationMessage.rootPlatformActivity,
          RoleSection.platform,
          const Duration(hours: 2),
        ),
        entry(
          'root-staff-example',
          NotificationCategory.administration,
          DemoNotificationMessage.rootStaffActivity,
          RoleSection.users,
          const Duration(days: 1),
        ),
      ],
    };
  }
}
