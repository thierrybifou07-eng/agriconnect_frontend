import 'package:flutter/foundation.dart';

import 'package:agri_connect/features/admin/domain/admin_moderation_status.dart';

/// A marketplace product as reviewed by the Administrator.
///
/// The admin never edits commercial data — only moderates. [moderation] is the
/// current state and [moderatedAt]/[moderatedBy] close the review trail;
/// [rejectionReason] is required whenever the decision is [rejected].
@immutable
class AdminProduct {
  const AdminProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.unit,
    required this.ownerId,
    required this.ownerName,
    required this.submittedAt,
    this.photoUrl,
    this.description,
    this.moderation = AdminModerationStatus.pending,
    this.moderatedAt,
    this.moderatedBy,
    this.rejectionReason,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final int stockQuantity;
  final String unit;
  final String ownerId;
  final String ownerName;
  final DateTime submittedAt;
  final String? photoUrl;
  final String? description;
  final AdminModerationStatus moderation;
  final DateTime? moderatedAt;
  final String? moderatedBy;

  /// Required when [moderation] is [AdminModerationStatus.rejected].
  final String? rejectionReason;

  AdminProduct copyWith({
    AdminModerationStatus? moderation,
    DateTime? moderatedAt,
    String? moderatedBy,
    String? rejectionReason,
  }) {
    return AdminProduct(
      id: id,
      name: name,
      category: category,
      price: price,
      stockQuantity: stockQuantity,
      unit: unit,
      ownerId: ownerId,
      ownerName: ownerName,
      submittedAt: submittedAt,
      photoUrl: photoUrl,
      description: description,
      moderation: moderation ?? this.moderation,
      moderatedAt: moderatedAt ?? this.moderatedAt,
      moderatedBy: moderatedBy ?? this.moderatedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
