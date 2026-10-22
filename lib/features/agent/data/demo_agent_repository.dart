import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/agent/domain/agent_case.dart';
import 'package:agri_connect/features/agent/domain/agent_repository.dart';

/// In-memory repository backing the agent workspace demo for "Awa Diallo".
///
/// Swapping this class for a real remote implementation must be the only change
/// required to go live (see [AgentRepository]).
final class DemoAgentRepository implements AgentRepository {
  DemoAgentRepository();

  final List<SupportRequest> _supportRequests = [
    SupportRequest(
      id: 'sup_9001',
      reference: 'SUP-2381',
      buyerName: 'Marie Koné',
      subject: 'Colis incomplet sur la commande b_4006',
      summary:
          'La cliente signale deux kilos de mangues manquants dans sa livraison '
          'de Yopougon.',
      status: SupportRequestStatus.open,
      priority: SupportPriority.high,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SupportRequest(
      id: 'sup_9002',
      reference: 'SUP-2380',
      buyerName: 'Aminata Diarra',
      subject: 'Retard de livraison signalé',
      summary:
          'La livraison attendue hier au marché de Yopougon n\'est pas arrivée.',
      status: SupportRequestStatus.inProgress,
      priority: SupportPriority.high,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    SupportRequest(
      id: 'sup_9003',
      reference: 'SUP-2379',
      buyerName: 'Souleymane Bamba',
      subject: 'Question sur le paiement mobile',
      summary: 'Le client ne retrouve pas la référence de son paiement.',
      status: SupportRequestStatus.inProgress,
      priority: SupportPriority.normal,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    SupportRequest(
      id: 'sup_9004',
      reference: 'SUP-2378',
      buyerName: 'Fatoumata Keïta',
      subject: 'Produit non conforme',
      summary:
          'Les tomates reçues ne correspondent pas à la variété commandée.',
      status: SupportRequestStatus.resolved,
      priority: SupportPriority.normal,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SupportRequest(
      id: 'sup_9005',
      reference: 'SUP-2377',
      buyerName: 'Kadiatou Sow',
      subject: 'Demande de facture',
      summary: 'La cliente demande une facture pour sa comptabilité.',
      status: SupportRequestStatus.resolved,
      priority: SupportPriority.normal,
      createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
    ),
  ];

  final List<StockValidationCase> _stockValidations = [
    StockValidationCase(
      id: 'stk_9101',
      reference: 'STK-5120',
      productName: 'Riz local parfumé',
      supplierName: 'Coopérative de Bouaké',
      declaredQuantity: 120,
      unit: 'sac',
      location: 'Entrepôt de Yamoussoukro',
      status: StockValidationStatus.pending,
      submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    StockValidationCase(
      id: 'stk_9102',
      reference: 'STK-5119',
      productName: 'Tomates fraîches',
      supplierName: 'Maraîchers d\'Adjamé',
      declaredQuantity: 300,
      unit: 'kg',
      location: 'Marché de gros d\'Adjamé',
      status: StockValidationStatus.pending,
      submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    StockValidationCase(
      id: 'stk_9103',
      reference: 'STK-5118',
      productName: 'Mangues mûres',
      supplierName: 'Vergers de Korhogo',
      declaredQuantity: 80,
      unit: 'kg',
      location: 'Zone industrielle de Bouaké',
      status: StockValidationStatus.validated,
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    StockValidationCase(
      id: 'stk_9104',
      reference: 'STK-5117',
      productName: 'Oignons rouges',
      supplierName: 'Coopérative de Ferkessédougou',
      declaredQuantity: 40,
      unit: 'sac',
      location: 'Marché de gros d\'Adjamé',
      status: StockValidationStatus.rejected,
      submittedAt: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
    ),
    StockValidationCase(
      id: 'stk_9105',
      reference: 'STK-5116',
      productName: 'Ananas',
      supplierName: 'Plantation de Bonoua',
      declaredQuantity: 200,
      unit: 'pièce',
      location: 'Marché de Cocody',
      status: StockValidationStatus.validated,
      submittedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  final List<OrderProcessingCase> _orderCases = [
    OrderProcessingCase(
      id: 'ord_9201',
      reference: 'CMD-7310',
      buyerName: 'Restaurant Le Baobab',
      sellerName: 'Coopérative de Bouaké',
      itemCount: 6,
      amount: 145000,
      status: OrderProcessingStatus.awaiting,
      placedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    OrderProcessingCase(
      id: 'ord_9202',
      reference: 'CMD-7309',
      buyerName: 'Épicerie du Plateau',
      sellerName: 'Maraîchers d\'Adjamé',
      itemCount: 3,
      amount: 62000,
      status: OrderProcessingStatus.awaiting,
      placedAt: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    OrderProcessingCase(
      id: 'ord_9203',
      reference: 'CMD-7308',
      buyerName: 'Kadiatou Sow',
      sellerName: 'Vergers de Korhogo',
      itemCount: 2,
      amount: 38000,
      status: OrderProcessingStatus.processing,
      placedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    OrderProcessingCase(
      id: 'ord_9204',
      reference: 'CMD-7307',
      buyerName: 'Hôtel Ivoire',
      sellerName: 'Plantation de Bonoua',
      itemCount: 10,
      amount: 320000,
      status: OrderProcessingStatus.processing,
      placedAt: DateTime.now().subtract(const Duration(days: 1, hours: 9)),
    ),
    OrderProcessingCase(
      id: 'ord_9205',
      reference: 'CMD-7306',
      buyerName: 'Moussa Traoré',
      sellerName: 'Coopérative de Ferkessédougou',
      itemCount: 4,
      amount: 91000,
      status: OrderProcessingStatus.processed,
      placedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final List<PaymentFollowupCase> _paymentFollowups = [
    PaymentFollowupCase(
      id: 'pay_9301',
      reference: 'PAY-4510',
      payerName: 'Restaurant Le Baobab',
      amount: 145000,
      method: 'Mobile money',
      status: PaymentFollowupStatus.due,
      dueAt: DateTime.now().add(const Duration(days: 1)),
    ),
    PaymentFollowupCase(
      id: 'pay_9302',
      reference: 'PAY-4509',
      payerName: 'Épicerie du Plateau',
      amount: 62000,
      method: 'Mobile money',
      status: PaymentFollowupStatus.due,
      dueAt: DateTime.now().add(const Duration(days: 2)),
    ),
    PaymentFollowupCase(
      id: 'pay_9303',
      reference: 'PAY-4508',
      payerName: 'Kadiatou Sow',
      amount: 38000,
      method: 'Virement bancaire',
      status: PaymentFollowupStatus.awaitingConfirmation,
      dueAt: DateTime.now().add(const Duration(days: 1)),
    ),
    PaymentFollowupCase(
      id: 'pay_9304',
      reference: 'PAY-4507',
      payerName: 'Hôtel Ivoire',
      amount: 320000,
      method: 'Virement bancaire',
      status: PaymentFollowupStatus.confirmed,
      dueAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PaymentFollowupCase(
      id: 'pay_9305',
      reference: 'PAY-4506',
      payerName: 'Moussa Traoré',
      amount: 91000,
      method: 'Espèces',
      status: PaymentFollowupStatus.confirmed,
      dueAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<SupportRequest>> fetchSupportRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<SupportRequest>.unmodifiable(_supportRequests);
  }

  @override
  Future<SupportRequest> updateSupportRequest(
    String requestId,
    SupportRequestStatus status,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final index = _supportRequests.indexWhere((r) => r.id == requestId);
    if (index < 0) throw const ServerFailure('support_request_not_found');
    final current = _supportRequests[index];
    if (current.status == status) return current;
    final updated = current.copyWith(status: status);
    _supportRequests[index] = updated;
    return updated;
  }

  @override
  Future<List<StockValidationCase>> fetchStockValidations() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<StockValidationCase>.unmodifiable(_stockValidations);
  }

  @override
  Future<StockValidationCase> decideStockValidation(
    String caseId,
    StockValidationStatus status,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final index = _stockValidations.indexWhere((c) => c.id == caseId);
    if (index < 0) throw const ServerFailure('stock_case_not_found');
    final current = _stockValidations[index];
    if (current.status == status) return current;
    final updated = current.copyWith(status: status);
    _stockValidations[index] = updated;
    return updated;
  }

  @override
  Future<List<OrderProcessingCase>> fetchOrderCases() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<OrderProcessingCase>.unmodifiable(_orderCases);
  }

  @override
  Future<OrderProcessingCase> advanceOrderProcessing(
    String orderId,
    OrderProcessingStatus status,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final index = _orderCases.indexWhere((o) => o.id == orderId);
    if (index < 0) throw const ServerFailure('order_case_not_found');
    final current = _orderCases[index];
    if (current.status == status) return current;
    final updated = current.copyWith(status: status);
    _orderCases[index] = updated;
    return updated;
  }

  @override
  Future<List<PaymentFollowupCase>> fetchPaymentFollowups() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<PaymentFollowupCase>.unmodifiable(_paymentFollowups);
  }

  @override
  Future<PaymentFollowupCase> confirmPayment(String paymentId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final index = _paymentFollowups.indexWhere((p) => p.id == paymentId);
    if (index < 0) throw const ServerFailure('payment_not_found');
    final current = _paymentFollowups[index];
    if (current.isConfirmed) return current;
    final updated = current.copyWith(status: PaymentFollowupStatus.confirmed);
    _paymentFollowups[index] = updated;
    return updated;
  }
}
