abstract final class RoutePaths {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String language = '/language';
  static const String role = '/role';
  static const String login = '/login';
  static const String register = '/register';

  static const String supplierProductNew = '/supplier/product/new';
  static const String supplierProductDetail = '/supplier/product/:productId';
  static const String supplierProductEdit = '/supplier/product/:productId/edit';

  /// Dashboard of the supplier shell.
  static const String supplierHome = '/supplier/home';

  /// Orders tab of the supplier shell.
  static const String supplierOrders = '/supplier/orders';
  static const String supplierOrderDetail = '/supplier/orders/:orderId';
  static const String supplierMessages = '/supplier/messages';
  static const String supplierConversation =
      '/supplier/messages/:conversationId';

  static String supplierProduct(String productId) =>
      '/supplier/product/$productId';
  static String supplierProductEdition(String productId) =>
      '/supplier/product/$productId/edit';
  static String supplierOrder(String orderId) => '/supplier/orders/$orderId';
  static String supplierMessageThread(String conversationId) =>
      '/supplier/messages/$conversationId';

  static const String buyerProductDetail = '/buyer/product/:productId';
  static const String buyerCart = '/buyer/cart';
  static const String buyerCheckout = '/buyer/checkout';
  static const String buyerOrderDetail = '/buyer/orders/:orderId';
  static const String buyerOrderConfirmationDetail =
      '/buyer/orders/:orderId/confirmation';

  /// Dashboard of the buyer shell.
  static const String buyerHome = '/buyer/home';

  /// Catalog tab of the buyer shell.
  static const String buyerCatalog = '/buyer/catalog';

  /// Orders tab of the buyer shell.
  static const String buyerOrders = '/buyer/orders';
  static const String buyerMessages = '/buyer/messages';
  static const String buyerConversation = '/buyer/messages/:conversationId';

  static String buyerProduct(String productId) => '/buyer/product/$productId';
  static String buyerOrder(String orderId) => '/buyer/orders/$orderId';
  static String buyerOrderConfirmation(String orderId) =>
      '/buyer/orders/$orderId/confirmation';
  static String buyerMessageThread(String conversationId) =>
      '/buyer/messages/$conversationId';

  /// Dashboard of the driver shell.
  static const String driverHome = '/driver/home';

  /// Deliveries tab of the driver shell.
  static const String driverDeliveries = '/driver/deliveries';

  /// Trips tab of the driver shell.
  static const String driverTrips = '/driver/trips';

  static const String driverMessages = '/driver/messages';
  static const String driverConversation = '/driver/messages/:conversationId';

  static const String driverDeliveryDetail = '/driver/deliveries/:deliveryId';

  static String driverDelivery(String deliveryId) =>
      '/driver/deliveries/$deliveryId';

  static String driverMessageThread(String conversationId) =>
      '/driver/messages/$conversationId';

  /// Dashboard of the agent shell.
  static const String agentHome = '/agent/home';

  /// Buyer support tab of the agent shell.
  static const String agentSupport = '/agent/support';

  /// Stock validation tab of the agent shell.
  static const String agentStock = '/agent/stock';

  /// Order processing tab of the agent shell.
  static const String agentOrderProcessing = '/agent/order-processing';

  /// Payment follow-up tab of the agent shell.
  static const String agentPayments = '/agent/payments';
}
