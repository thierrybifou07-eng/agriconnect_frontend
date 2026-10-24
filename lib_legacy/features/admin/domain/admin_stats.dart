import 'package:flutter/foundation.dart';

/// Aggregate figures powering the Administrator dashboard and reports.
@immutable
class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.farmers,
    required this.buyers,
    required this.drivers,
    required this.admins,
    required this.publishedProducts,
    required this.totalProducts,
    required this.pendingProducts,
    required this.totalOrders,
    required this.pendingOrders,
    required this.activeOrders,
    required this.totalDeliveries,
    required this.activeDeliveries,
    required this.completedDeliveries,
    required this.ordersRevenue,
    this.pendingUsers = 0,
  });

  final int totalUsers;
  final int farmers;
  final int buyers;
  final int drivers;
  final int admins;
  final int publishedProducts;
  final int totalProducts;
  final int pendingProducts;
  final int totalOrders;
  final int pendingOrders;
  final int activeOrders;
  final int totalDeliveries;
  final int activeDeliveries;
  final int completedDeliveries;
  final double ordersRevenue;
  final int pendingUsers;
}
