import 'package:agri_connect/features/agent/domain/agent_case.dart';

/// Data access of the agent workspace.
///
/// Each operation is scoped to the capability that authorizes it: the
/// repository is the single place a real backend will enforce those rights.
/// Swapping the demo implementation for a real remote one must be the only
/// change required to go live.
abstract interface class AgentRepository {
  /// Buyer-support requests, in the order they should be handled.
  Future<List<SupportRequest>> fetchSupportRequests();

  /// Moves a support request to [status] and returns the updated request.
  Future<SupportRequest> updateSupportRequest(
    String requestId,
    SupportRequestStatus status,
  );

  /// Stock declarations waiting for validation.
  Future<List<StockValidationCase>> fetchStockValidations();

  /// Applies a validation decision and returns the updated case.
  Future<StockValidationCase> decideStockValidation(
    String caseId,
    StockValidationStatus status,
  );

  /// Orders to move through processing.
  Future<List<OrderProcessingCase>> fetchOrderCases();

  /// Moves an order to [status] and returns the updated order.
  Future<OrderProcessingCase> advanceOrderProcessing(
    String orderId,
    OrderProcessingStatus status,
  );

  /// Payments to follow up on.
  Future<List<PaymentFollowupCase>> fetchPaymentFollowups();

  /// Confirms a payment was received and returns the updated case.
  ///
  /// The action is only ever offered once the platform can reliably attest the
  /// reception; the UI never assumes it on its own.
  Future<PaymentFollowupCase> confirmPayment(String paymentId);
}
