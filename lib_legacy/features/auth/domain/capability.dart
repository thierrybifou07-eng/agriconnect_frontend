import 'package:agri_connect/features/auth/domain/user_role.dart';

/// Atomic authorization rights of the AgriConnect V2 platform.
///
/// A capability is the smallest unit a screen or an action can require, so
/// authorization no longer reduces to the role alone. A role only provides the
/// default bundle; the authenticated session carries the capabilities actually
/// granted to the account.
///
/// Only the capabilities explicitly listed by the V2 specification are
/// declared here; new ones get added when a phase defines what they authorize.
enum UserCapability {
  buyerSupport,
  stockValidation,
  orderProcessing,
  paymentFollowup;

  /// Stable machine-readable key used in API payloads and persistence.
  String get key => switch (this) {
    UserCapability.buyerSupport => 'BUYER_SUPPORT',
    UserCapability.stockValidation => 'STOCK_VALIDATION',
    UserCapability.orderProcessing => 'ORDER_PROCESSING',
    UserCapability.paymentFollowup => 'PAYMENT_FOLLOWUP',
  };

  /// Resolves a persisted or API key, or `null` when it names no known
  /// capability, so an unknown server value degrades instead of crashing.
  static UserCapability? fromKey(String key) => switch (key) {
    'BUYER_SUPPORT' => UserCapability.buyerSupport,
    'STOCK_VALIDATION' => UserCapability.stockValidation,
    'ORDER_PROCESSING' => UserCapability.orderProcessing,
    'PAYMENT_FOLLOWUP' => UserCapability.paymentFollowup,
    _ => null,
  };
}

/// Default capability bundle of each role.
///
/// Used by the demo as the offline fallback when the session carries no
/// explicit capability list.
///
/// BACKEND À CONFIRMER: the production sign-in payload must return the
/// capabilities granted to the account itself; this table only mirrors the
/// demo roles and must never become the authority in production.
extension UserRoleCapabilityX on UserRole {
  Set<UserCapability> get capabilities {
    return switch (this) {
      UserRole.agent || UserRole.admin || UserRole.root => const {
        UserCapability.buyerSupport,
        UserCapability.stockValidation,
        UserCapability.orderProcessing,
        UserCapability.paymentFollowup,
      },
      UserRole.buyer || UserRole.supplier || UserRole.driver => const {},
    };
  }
}
