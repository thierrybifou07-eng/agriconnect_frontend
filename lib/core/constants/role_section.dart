import 'package:flutter/material.dart';

import 'package:agri_connect/features/auth/domain/capability.dart';

/// Canonical section identifiers shared by the router and the role shells.
///
/// Each value maps to a route fragment and a localized label. Business
/// features import this enum instead of building their own navigation keys,
/// which keeps navigation state centralized.
enum RoleSection {
  dashboard,
  products,
  orders,
  profile,
  catalog,
  deliveries,
  trips,
  users,
  analytics,
  platform,
  buyerSupport,
  stockValidation,
  orderProcessing,
  paymentFollowup;

  String get routeName => switch (this) {
    RoleSection.dashboard => 'home',
    RoleSection.products => 'products',
    RoleSection.orders => 'orders',
    RoleSection.profile => 'profile',
    RoleSection.catalog => 'catalog',
    RoleSection.deliveries => 'deliveries',
    RoleSection.trips => 'trips',
    RoleSection.users => 'users',
    RoleSection.analytics => 'analytics',
    RoleSection.platform => 'platform',
    RoleSection.buyerSupport => 'support',
    RoleSection.stockValidation => 'stock',
    RoleSection.orderProcessing => 'order-processing',
    RoleSection.paymentFollowup => 'payments',
  };
}

extension RoleSectionIconX on RoleSection {
  IconData get icon => switch (this) {
    RoleSection.dashboard => Icons.dashboard_outlined,
    RoleSection.products => Icons.inventory_2_outlined,
    RoleSection.orders => Icons.receipt_long_outlined,
    RoleSection.profile => Icons.person_outline,
    RoleSection.catalog => Icons.storefront_outlined,
    RoleSection.deliveries => Icons.local_shipping_outlined,
    RoleSection.trips => Icons.route_outlined,
    RoleSection.users => Icons.people_outline,
    RoleSection.analytics => Icons.bar_chart_rounded,
    RoleSection.platform => Icons.public_outlined,
    RoleSection.buyerSupport => Icons.support_agent_outlined,
    RoleSection.stockValidation => Icons.fact_check_outlined,
    RoleSection.orderProcessing => Icons.pending_actions_outlined,
    RoleSection.paymentFollowup => Icons.payments_outlined,
  };

  IconData get activeIcon => switch (this) {
    RoleSection.dashboard => Icons.dashboard_rounded,
    RoleSection.products => Icons.inventory_2_rounded,
    RoleSection.orders => Icons.receipt_long_rounded,
    RoleSection.profile => Icons.person_rounded,
    RoleSection.catalog => Icons.storefront_rounded,
    RoleSection.deliveries => Icons.local_shipping_rounded,
    RoleSection.trips => Icons.route_rounded,
    RoleSection.users => Icons.people_rounded,
    RoleSection.analytics => Icons.bar_chart_rounded,
    RoleSection.platform => Icons.public_rounded,
    RoleSection.buyerSupport => Icons.support_agent_rounded,
    RoleSection.stockValidation => Icons.fact_check_rounded,
    RoleSection.orderProcessing => Icons.pending_actions_rounded,
    RoleSection.paymentFollowup => Icons.payments_rounded,
  };

  /// Capability a session must hold to reach this section, or `null` when the
  /// section is not restricted by an atomic capability.
  ///
  /// The shell hides a section the session cannot open, and each section page
  /// re-checks the same capability, so hiding the tab is never the only guard.
  UserCapability? get requiredCapability => switch (this) {
    RoleSection.buyerSupport => UserCapability.buyerSupport,
    RoleSection.stockValidation => UserCapability.stockValidation,
    RoleSection.orderProcessing => UserCapability.orderProcessing,
    RoleSection.paymentFollowup => UserCapability.paymentFollowup,
    _ => null,
  };
}
