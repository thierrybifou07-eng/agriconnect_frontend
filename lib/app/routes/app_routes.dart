import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const legal = '/legal';
  static const profile = '/account/profile';
  static const documents = '/account/documents';
  static const payoutAccounts = '/account/payout-accounts';
  static const referral = '/account/referral';
  static const sessions = '/account/sessions';
  static const language = '/account/language';
  static const conversations = '/messages';
  static const chatThread = '/messages/thread';
  static const notifications = '/notifications';
  static const buyerListingDetail = '/buyer/listings/:listingId';
  static const buyerOrderDetail = '/buyer/orders/:orderId';
  static const driverDeliveryDetail = '/driver/deliveries/:deliveryId';

  static String buyerListing(int listingId) => '/buyer/listings/$listingId';

  static String buyerOrder(int orderId) => '/buyer/orders/$orderId';
  static String driverDelivery(int deliveryId) =>
      '/driver/deliveries/$deliveryId';
  static String supplierLotDetail(int lotId) => '/supplier/lots/$lotId';
  static String legalDocument(String code) => '$legal/$code';
  static const supplier = '/supplier';
  static const supplierLotNew = '/supplier/lots/new';
  static const supplierLotDetailRoute = '/supplier/lots/:lotId';
  static const buyer = '/buyer';
  static const driver = '/driver';
  static const staff = '/staff';
  static const admin = '/admin';

  static String homeFor(AuthUser user) => switch (user.role) {
    RoleCode.supplier => supplier,
    RoleCode.buyer => buyer,
    RoleCode.driver => driver,
    RoleCode.agent => staff,
    RoleCode.admin || RoleCode.root => admin,
    RoleCode.unknown => login,
  };
}
