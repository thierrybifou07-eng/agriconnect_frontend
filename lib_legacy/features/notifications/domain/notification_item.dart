import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

enum NotificationCategory {
  orders,
  products,
  deliveries,
  support,
  administration,
}

enum DemoNotificationMessage {
  buyerOrderUpdate,
  buyerDeliveryUpdate,
  supplierNewOrder,
  supplierProductAction,
  driverDeliveryAssigned,
  driverTripUpdate,
  agentSupportRequest,
  agentOrderAction,
  agentStockReview,
  adminProductReview,
  adminOrderReview,
  rootPlatformActivity,
  rootStaffActivity,
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.role,
    required this.category,
    required this.message,
    required this.destination,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final UserRole role;
  final NotificationCategory category;
  final DemoNotificationMessage message;
  final RoleSection destination;
  final DateTime createdAt;
  final bool isRead;

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
    id: id,
    role: role,
    category: category,
    message: message,
    destination: destination,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );
}
