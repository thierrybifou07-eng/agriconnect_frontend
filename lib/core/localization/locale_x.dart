import 'package:flutter/widgets.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/features/agent/domain/agent_case.dart';
import 'package:agri_connect/features/buyer/domain/buyer_order.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_trip.dart';
import 'package:agri_connect/features/supplier/domain/supplier_order.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocaleX on BuildContext {
  /// Active language code, used to format dates and amounts.
  String get localeCode => Localizations.localeOf(this).languageCode;
}

extension UserRoleLabelX on UserRole {
  String label(AppLocalizations l10n) => switch (this) {
    UserRole.buyer => l10n.roleBuyer,
    UserRole.supplier => l10n.roleSupplier,
    UserRole.driver => l10n.roleDriver,
    UserRole.agent => l10n.roleAgent,
    UserRole.admin => l10n.roleAdmin,
    UserRole.root => l10n.roleRoot,
  };

  String description(AppLocalizations l10n) => switch (this) {
    UserRole.buyer => l10n.roleBuyerDesc,
    UserRole.supplier => l10n.roleSupplierDesc,
    UserRole.driver => l10n.roleDriverDesc,
    UserRole.agent => l10n.roleAgentDesc,
    UserRole.admin => l10n.roleAdminDesc,
    UserRole.root => l10n.roleRootDesc,
  };
}

extension UserCapabilityLabelX on UserCapability {
  String label(AppLocalizations l10n) => switch (this) {
    UserCapability.buyerSupport => l10n.capabilityBuyerSupport,
    UserCapability.stockValidation => l10n.capabilityStockValidation,
    UserCapability.orderProcessing => l10n.capabilityOrderProcessing,
    UserCapability.paymentFollowup => l10n.capabilityPaymentFollowup,
  };
}

extension RoleSectionLabelX on RoleSection {
  String label(AppLocalizations l10n) => switch (this) {
    RoleSection.dashboard => l10n.sectionDashboard,
    RoleSection.products => l10n.sectionProducts,
    RoleSection.orders => l10n.sectionOrders,
    RoleSection.profile => l10n.sectionProfile,
    RoleSection.catalog => l10n.sectionCatalog,
    RoleSection.deliveries => l10n.sectionDeliveries,
    RoleSection.trips => l10n.sectionTrips,
    RoleSection.users => l10n.sectionUsers,
    RoleSection.analytics => l10n.sectionAnalytics,
    RoleSection.platform => l10n.sectionPlatform,
    RoleSection.buyerSupport => l10n.sectionBuyerSupport,
    RoleSection.stockValidation => l10n.sectionStockValidation,
    RoleSection.orderProcessing => l10n.sectionOrderProcessing,
    RoleSection.paymentFollowup => l10n.sectionPaymentFollowup,
  };
}

/// Label used by the navigation surfaces: the bottom bar, the staff sidebar and
/// the "More" sheet.
///
/// The dashboard section is the way back to the home screen of the signed-in
/// role, so the navigation reads "Accueil" / "Home" while the section itself
/// keeps its own title.
extension RoleSectionNavLabelX on RoleSection {
  String navLabel(AppLocalizations l10n) => switch (this) {
    RoleSection.dashboard => l10n.navHome,
    _ => label(l10n),
  };
}

extension ProductStatusLabelX on ProductStatus {
  String label(AppLocalizations l10n) => switch (this) {
    ProductStatus.onSale => l10n.productStatusOnSale,
    ProductStatus.outOfStock => l10n.productStatusOutOfStock,
  };
}

extension DeclarationStatusLabelX on DeclarationStatus {
  String label(AppLocalizations l10n) => switch (this) {
    DeclarationStatus.draft => l10n.declarationStatusDraft,
    DeclarationStatus.pendingReview => l10n.declarationStatusPendingReview,
    DeclarationStatus.additionalInfoRequired =>
      l10n.declarationStatusAdditionalInfoRequired,
    DeclarationStatus.underDiscussion => l10n.declarationStatusUnderDiscussion,
    DeclarationStatus.approvedForPublication =>
      l10n.declarationStatusApprovedForPublication,
    DeclarationStatus.rejected => l10n.declarationStatusRejected,
  };
}

extension OrderStatusLabelX on OrderStatus {
  String label(AppLocalizations l10n) => switch (this) {
    OrderStatus.pending => l10n.statusOrderPending,
    OrderStatus.confirmed => l10n.statusOrderConfirmed,
    OrderStatus.cancelled => l10n.statusOrderCancelled,
  };
}

extension CatalogCategoryLabelX on CatalogCategory {
  String label(AppLocalizations l10n) => switch (this) {
    CatalogCategory.cereals => l10n.categoryCereals,
    CatalogCategory.vegetables => l10n.categoryVegetables,
    CatalogCategory.fruits => l10n.categoryFruits,
    CatalogCategory.tubers => l10n.categoryTubers,
    CatalogCategory.spices => l10n.categorySpices,
  };
}

extension BuyerOrderStatusLabelX on BuyerOrderStatus {
  String label(AppLocalizations l10n) => switch (this) {
    BuyerOrderStatus.pending => l10n.statusOrderPending,
    BuyerOrderStatus.confirmed => l10n.statusOrderConfirmed,
    BuyerOrderStatus.inTransit => l10n.statusOrderInTransit,
    BuyerOrderStatus.delivered => l10n.statusOrderDelivered,
    BuyerOrderStatus.cancelled => l10n.statusOrderCancelled,
  };

  Color color(BuildContext context) => switch (this) {
    BuyerOrderStatus.pending => AppColors.warning,
    BuyerOrderStatus.confirmed => AppColors.success,
    BuyerOrderStatus.inTransit => AppColors.accent,
    BuyerOrderStatus.delivered => AppColors.success,
    BuyerOrderStatus.cancelled => AppColors.danger,
  };
}

extension DriverDeliveryStatusLabelX on DriverDeliveryStatus {
  String label(AppLocalizations l10n) => switch (this) {
    DriverDeliveryStatus.pickUp => l10n.driverStatusPickUp,
    DriverDeliveryStatus.inTransit => l10n.driverStatusInTransit,
    DriverDeliveryStatus.delivered => l10n.driverStatusDelivered,
  };

  Color color(BuildContext context) => switch (this) {
    DriverDeliveryStatus.pickUp => AppColors.warning,
    DriverDeliveryStatus.inTransit => AppColors.accent,
    DriverDeliveryStatus.delivered => AppColors.success,
  };
}

extension TripStatusLabelX on TripStatus {
  String label(AppLocalizations l10n) => switch (this) {
    TripStatus.upcoming => l10n.tripStatusUpcoming,
    TripStatus.active => l10n.tripStatusActive,
    TripStatus.completed => l10n.tripStatusCompleted,
  };

  Color color(BuildContext context) => switch (this) {
    TripStatus.upcoming => AppColors.accent,
    TripStatus.active => AppColors.primary,
    TripStatus.completed => AppColors.success,
  };
}

extension SupportPriorityLabelX on SupportPriority {
  String label(AppLocalizations l10n) => switch (this) {
    SupportPriority.high => l10n.agentSupportPriorityHigh,
    SupportPriority.normal => l10n.agentSupportPriorityNormal,
  };

  Color color(BuildContext context) => switch (this) {
    SupportPriority.high => AppColors.danger,
    SupportPriority.normal => AppColors.accent,
  };
}

extension SupportRequestStatusLabelX on SupportRequestStatus {
  String label(AppLocalizations l10n) => switch (this) {
    SupportRequestStatus.open => l10n.agentSupportStatusOpen,
    SupportRequestStatus.inProgress => l10n.agentSupportStatusInProgress,
    SupportRequestStatus.resolved => l10n.agentSupportStatusResolved,
  };

  Color color(BuildContext context) => switch (this) {
    SupportRequestStatus.open => AppColors.warning,
    SupportRequestStatus.inProgress => AppColors.accent,
    SupportRequestStatus.resolved => AppColors.success,
  };
}

extension StockValidationStatusLabelX on StockValidationStatus {
  String label(AppLocalizations l10n) => switch (this) {
    StockValidationStatus.pending => l10n.agentStockStatusPending,
    StockValidationStatus.validated => l10n.agentStockStatusValidated,
    StockValidationStatus.rejected => l10n.agentStockStatusRejected,
  };

  Color color(BuildContext context) => switch (this) {
    StockValidationStatus.pending => AppColors.warning,
    StockValidationStatus.validated => AppColors.success,
    StockValidationStatus.rejected => AppColors.danger,
  };
}

extension OrderProcessingStatusLabelX on OrderProcessingStatus {
  String label(AppLocalizations l10n) => switch (this) {
    OrderProcessingStatus.awaiting => l10n.agentOrderStatusAwaiting,
    OrderProcessingStatus.processing => l10n.agentOrderStatusProcessing,
    OrderProcessingStatus.processed => l10n.agentOrderStatusProcessed,
  };

  Color color(BuildContext context) => switch (this) {
    OrderProcessingStatus.awaiting => AppColors.warning,
    OrderProcessingStatus.processing => AppColors.accent,
    OrderProcessingStatus.processed => AppColors.success,
  };
}

extension PaymentFollowupStatusLabelX on PaymentFollowupStatus {
  String label(AppLocalizations l10n) => switch (this) {
    PaymentFollowupStatus.due => l10n.agentPaymentStatusDue,
    PaymentFollowupStatus.awaitingConfirmation =>
      l10n.agentPaymentStatusAwaiting,
    PaymentFollowupStatus.confirmed => l10n.agentPaymentStatusConfirmed,
  };

  Color color(BuildContext context) => switch (this) {
    PaymentFollowupStatus.due => AppColors.danger,
    PaymentFollowupStatus.awaitingConfirmation => AppColors.warning,
    PaymentFollowupStatus.confirmed => AppColors.success,
  };
}
