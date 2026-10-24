import 'package:flutter/foundation.dart';

/// One entry of the platform activity trail, as recorded by the repository.
///
/// The trail is the only record of who changed a staff right or a platform
/// setting, so it carries the actor, what happened and when: an entry that
/// lacked the actor could not be acted upon.
@immutable
class SystemEvent {
  const SystemEvent({
    required this.id,
    required this.actorName,
    required this.action,
    required this.target,
    required this.occurredAt,
  });

  final String id;
  final String actorName;

  /// What happened, as a closed set rather than a sentence: the repository
  /// records which action took place, the screen words it. A free-form string
  /// here would leave the trail half translated.
  final SystemEventAction action;

  /// What the action was performed on, such as a staff member or a setting.
  final String target;
  final DateTime occurredAt;
}

/// The closed set of actions the platform trail records.
enum SystemEventAction {
  suspended,
  restored,
  updatedPermissions,
  updatedSettings,
  moderatedProduct,
}

extension SystemEventActionX on SystemEventAction {
  /// Stable identifier, used for tests and for keys, never for display.
  String keyName() => name;
}

/// Platform-wide counters shown on the Super Admin dashboard.
///
/// These are the figures the platform itself can compute from its own seeds.
/// Nothing here is derived from a period comparison: the repository holds no
/// history, so the dashboard shows totals and never claims a trend.
@immutable
class PlatformOverview {
  const PlatformOverview({
    required this.totalUsers,
    required this.farmers,
    required this.buyers,
    required this.drivers,
    required this.staff,
    required this.publishedProducts,
    required this.pendingModeration,
    required this.totalOrders,
    required this.openOrders,
    required this.activeDeliveries,
    required this.grossMerchandiseValue,
    required this.pendingUsers,
  });

  final int totalUsers;
  final int farmers;
  final int buyers;
  final int drivers;

  /// Administrators and Super Admins together.
  final int staff;

  final int publishedProducts;

  /// Products still waiting for a moderation decision.
  final int pendingModeration;

  final int totalOrders;
  final int openOrders;
  final int activeDeliveries;

  final double grossMerchandiseValue;
  final int pendingUsers;

  /// Counters the console must escalate, all computed from the seeds above.
  int get attentionCount => pendingModeration + pendingUsers + activeDeliveries;
}
