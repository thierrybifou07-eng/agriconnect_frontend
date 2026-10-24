/// Domain models of the agent workspace.
///
/// An agent only ever works on the four operational capabilities the V2
/// specification defines: buyer support, stock validation, order processing and
/// payment follow-up. Every value here is handed over by the repository as-is —
/// no business total is recomputed on the client — and every status belongs to
/// the closed list its feature owns, so a screen can never invent a transition.
library;

/// Urgency of a buyer-support request.
enum SupportPriority { high, normal }

/// Lifecycle of a buyer-support request.
enum SupportRequestStatus { open, inProgress, resolved }

/// A buyer-support request an agent answers.
class SupportRequest {
  const SupportRequest({
    required this.id,
    required this.reference,
    required this.buyerName,
    required this.subject,
    required this.summary,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  final String id;
  final String reference;
  final String buyerName;
  final String subject;
  final String summary;
  final SupportRequestStatus status;
  final SupportPriority priority;
  final DateTime createdAt;

  bool get isOpen => status == SupportRequestStatus.open;

  bool get isResolved => status == SupportRequestStatus.resolved;

  /// Only status the agent may move to from here, `null` once resolved.
  SupportRequestStatus? get nextStatus => switch (status) {
    SupportRequestStatus.open => SupportRequestStatus.inProgress,
    SupportRequestStatus.inProgress => SupportRequestStatus.resolved,
    SupportRequestStatus.resolved => null,
  };

  SupportRequest copyWith({SupportRequestStatus? status}) => SupportRequest(
    id: id,
    reference: reference,
    buyerName: buyerName,
    subject: subject,
    summary: summary,
    status: status ?? this.status,
    priority: priority,
    createdAt: createdAt,
  );
}

/// Lifecycle of a declared-stock validation case.
enum StockValidationStatus { pending, validated, rejected }

/// A stock declaration an agent has to validate or reject.
class StockValidationCase {
  const StockValidationCase({
    required this.id,
    required this.reference,
    required this.productName,
    required this.supplierName,
    required this.declaredQuantity,
    required this.unit,
    required this.location,
    required this.status,
    required this.submittedAt,
  });

  final String id;
  final String reference;
  final String productName;
  final String supplierName;
  final int declaredQuantity;
  final String unit;
  final String location;
  final StockValidationStatus status;
  final DateTime submittedAt;

  bool get isPending => status == StockValidationStatus.pending;

  StockValidationCase copyWith({StockValidationStatus? status}) =>
      StockValidationCase(
        id: id,
        reference: reference,
        productName: productName,
        supplierName: supplierName,
        declaredQuantity: declaredQuantity,
        unit: unit,
        location: location,
        status: status ?? this.status,
        submittedAt: submittedAt,
      );
}

/// Lifecycle of an order an agent moves through processing.
enum OrderProcessingStatus { awaiting, processing, processed }

/// An order the agent has to process for the platform.
class OrderProcessingCase {
  const OrderProcessingCase({
    required this.id,
    required this.reference,
    required this.buyerName,
    required this.sellerName,
    required this.itemCount,
    required this.amount,
    required this.status,
    required this.placedAt,
  });

  final String id;
  final String reference;
  final String buyerName;
  final String sellerName;
  final int itemCount;

  /// Amount already computed by the platform, in FCFA. Never recomputed here.
  final int amount;

  final OrderProcessingStatus status;
  final DateTime placedAt;

  bool get isProcessed => status == OrderProcessingStatus.processed;

  /// Only status the agent may move to from here, `null` once processed.
  OrderProcessingStatus? get nextStatus => switch (status) {
    OrderProcessingStatus.awaiting => OrderProcessingStatus.processing,
    OrderProcessingStatus.processing => OrderProcessingStatus.processed,
    OrderProcessingStatus.processed => null,
  };

  OrderProcessingCase copyWith({OrderProcessingStatus? status}) =>
      OrderProcessingCase(
        id: id,
        reference: reference,
        buyerName: buyerName,
        sellerName: sellerName,
        itemCount: itemCount,
        amount: amount,
        status: status ?? this.status,
        placedAt: placedAt,
      );
}

/// Lifecycle of a payment the agent has to follow up on.
///
/// A payment is only ever shown as received once the platform confirms it, so
/// [confirmed] is reached exclusively through an explicit repository action.
enum PaymentFollowupStatus { due, awaitingConfirmation, confirmed }

/// A payment an agent has to follow up on.
class PaymentFollowupCase {
  const PaymentFollowupCase({
    required this.id,
    required this.reference,
    required this.payerName,
    required this.amount,
    required this.method,
    required this.status,
    required this.dueAt,
  });

  final String id;
  final String reference;
  final String payerName;

  /// Amount already computed by the platform, in FCFA. Never recomputed here.
  final int amount;

  final String method;
  final PaymentFollowupStatus status;
  final DateTime dueAt;

  bool get isConfirmed => status == PaymentFollowupStatus.confirmed;

  PaymentFollowupCase copyWith({PaymentFollowupStatus? status}) =>
      PaymentFollowupCase(
        id: id,
        reference: reference,
        payerName: payerName,
        amount: amount,
        method: method,
        status: status ?? this.status,
        dueAt: dueAt,
      );
}
