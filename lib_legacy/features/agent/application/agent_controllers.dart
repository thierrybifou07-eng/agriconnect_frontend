import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/agent/application/agent_section_state.dart';
import 'package:agri_connect/features/agent/domain/agent_case.dart';
import 'package:agri_connect/features/agent/domain/agent_repository.dart';

/// Buyer-support requests.
final agentSupportControllerProvider =
    NotifierProvider<AgentSupportController, AgentSectionState<SupportRequest>>(
      AgentSupportController.new,
    );

class AgentSupportController extends AgentListController<SupportRequest> {
  @override
  String idOf(SupportRequest item) => item.id;

  @override
  Future<List<SupportRequest>> loadItems(AgentRepository repository) =>
      repository.fetchSupportRequests();

  /// Moves a request forward (take charge, then resolve).
  Future<bool> updateStatus(String id, SupportRequestStatus status) =>
      runAction(
        id,
        (repository) => repository.updateSupportRequest(id, status),
      );
}

/// Stock declarations to validate.
final agentStockControllerProvider =
    NotifierProvider<
      AgentStockController,
      AgentSectionState<StockValidationCase>
    >(AgentStockController.new);

class AgentStockController extends AgentListController<StockValidationCase> {
  @override
  String idOf(StockValidationCase item) => item.id;

  @override
  Future<List<StockValidationCase>> loadItems(AgentRepository repository) =>
      repository.fetchStockValidations();

  Future<bool> decide(String id, StockValidationStatus status) => runAction(
    id,
    (repository) => repository.decideStockValidation(id, status),
  );
}

/// Orders to process.
final agentOrdersControllerProvider =
    NotifierProvider<
      AgentOrdersController,
      AgentSectionState<OrderProcessingCase>
    >(AgentOrdersController.new);

class AgentOrdersController extends AgentListController<OrderProcessingCase> {
  @override
  String idOf(OrderProcessingCase item) => item.id;

  @override
  Future<List<OrderProcessingCase>> loadItems(AgentRepository repository) =>
      repository.fetchOrderCases();

  Future<bool> advance(String id, OrderProcessingStatus status) => runAction(
    id,
    (repository) => repository.advanceOrderProcessing(id, status),
  );
}

/// Payments to follow up on.
final agentPaymentsControllerProvider =
    NotifierProvider<
      AgentPaymentsController,
      AgentSectionState<PaymentFollowupCase>
    >(AgentPaymentsController.new);

class AgentPaymentsController extends AgentListController<PaymentFollowupCase> {
  @override
  String idOf(PaymentFollowupCase item) => item.id;

  @override
  Future<List<PaymentFollowupCase>> loadItems(AgentRepository repository) =>
      repository.fetchPaymentFollowups();

  Future<bool> confirm(String id) =>
      runAction(id, (repository) => repository.confirmPayment(id));
}
