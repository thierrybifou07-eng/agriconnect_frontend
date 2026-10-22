import 'package:flutter/foundation.dart';

import 'package:agri_connect/features/admin/domain/admin_account_status.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

/// A platform account as seen from the Administrator workspace.
///
/// Identity fields (id, name, role) mirror the account the user registered;
/// the admin overlay adds operational metadata: join/last-activity dates,
/// aggregated transaction counts and the current [status].
@immutable
class AdminUser {
  const AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.joinedAt,
    required this.lastActiveAt,
    this.photoUrl,
    this.status = AdminAccountStatus.active,
    this.ordersCount = 0,
    this.productsCount = 0,
    this.deliveriesCount = 0,
    this.verified = false,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final DateTime joinedAt;
  final DateTime lastActiveAt;
  final String? photoUrl;
  final AdminAccountStatus status;
  final int ordersCount;
  final int productsCount;
  final int deliveriesCount;
  final bool verified;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }

  AdminUser copyWith({
    AdminAccountStatus? status,
    DateTime? lastActiveAt,
    int? ordersCount,
    int? productsCount,
    int? deliveriesCount,
  }) {
    return AdminUser(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      joinedAt: joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      photoUrl: photoUrl,
      status: status ?? this.status,
      ordersCount: ordersCount ?? this.ordersCount,
      productsCount: productsCount ?? this.productsCount,
      deliveriesCount: deliveriesCount ?? this.deliveriesCount,
      verified: verified,
    );
  }
}
