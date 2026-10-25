enum AgentCapability {
  buyerSupport,
  supplierSupport,
  listingManagement,
  orderProcessing,
  stockValidation,
  paymentFollowup,
  dispatchCoordination,
  userVerification,
  disputeHandling,
  unknown;

  String get code => switch (this) {
    AgentCapability.buyerSupport => 'BUYER_SUPPORT',
    AgentCapability.supplierSupport => 'SUPPLIER_SUPPORT',
    AgentCapability.listingManagement => 'LISTING_MANAGEMENT',
    AgentCapability.orderProcessing => 'ORDER_PROCESSING',
    AgentCapability.stockValidation => 'STOCK_VALIDATION',
    AgentCapability.paymentFollowup => 'PAYMENT_FOLLOWUP',
    AgentCapability.dispatchCoordination => 'DISPATCH_COORDINATION',
    AgentCapability.userVerification => 'USER_VERIFICATION',
    AgentCapability.disputeHandling => 'DISPUTE_HANDLING',
    AgentCapability.unknown => '',
  };

  static AgentCapability parse(Object? value) {
    if (value is! String) return AgentCapability.unknown;
    return AgentCapability.values.firstWhere(
      (capability) => capability.code == value.trim().toUpperCase(),
      orElse: () => AgentCapability.unknown,
    );
  }
}
