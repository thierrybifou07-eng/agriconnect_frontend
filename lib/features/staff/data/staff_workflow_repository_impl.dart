import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/staff/data/staff_workflow_api.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_repository.dart';

class StaffWorkflowRepositoryImpl implements StaffWorkflowRepository {
  const StaffWorkflowRepositoryImpl(this._api);
  final StaffWorkflowApi _api;

  @override
  Future<Paginated<StaffOrder>> orders({int page = 1, int limit = 20}) =>
      _parse(() => _api.orders(page: page, limit: limit));
  @override
  Future<StaffOrder> order(int id) => _parse(() => _api.order(id));
  @override
  Future<StaffOrder> createOrder(Map<String, Object?> body) =>
      _parse(() => _api.createOrder(body));
  @override
  Future<StaffOrder> changeOrderStatus(int id, String status) =>
      _parse(() => _api.changeOrderStatus(id, status));
  @override
  Future<StaffOrder> confirmOrder(int id) =>
      _parse(() => _api.confirmOrder(id));
  @override
  Future<void> cancelOrder(int id, {String? reason}) =>
      _parse(() => _api.cancelOrder(id, reason: reason));
  @override
  Future<List<StaffPayment>> payments(int orderId) =>
      _parse(() => _api.payments(orderId));
  @override
  Future<void> recordPayment(
    int orderId,
    Map<String, Object?> body,
    String idempotencyKey,
  ) => _parse(() => _api.recordPayment(orderId, body, idempotencyKey));
  @override
  Future<void> refundPayment(int paymentId) =>
      _parse(() => _api.refundPayment(paymentId));
  @override
  Future<void> createDeliveries(int orderId) =>
      _parse(() => _api.createDeliveries(orderId));
  @override
  Future<Paginated<StaffDelivery>> deliveries({
    int page = 1,
    int limit = 20,
    String? status,
    int? orderId,
  }) => _parse(
    () => _api.deliveries(
      page: page,
      limit: limit,
      status: status,
      orderId: orderId,
    ),
  );
  @override
  Future<void> releaseDelivery(int id, {String? reason}) =>
      _parse(() => _api.releaseDelivery(id, reason: reason));
  @override
  Future<void> redispatchDelivery(int id) =>
      _parse(() => _api.redispatchDelivery(id));
  @override
  Future<void> cancelDelivery(int id, String reason) =>
      _parse(() => _api.cancelDelivery(id, reason));
  @override
  Future<void> createCompensation(Map<String, Object?> body) =>
      _parse(() => _api.createCompensation(body));
  @override
  Future<Paginated<StaffVerification>> verifications({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
    String? role,
    int? userId,
  }) => _parse(
    () => _api.verifications(
      page: page,
      limit: limit,
      status: status,
      type: type,
      role: role,
      userId: userId,
    ),
  );
  @override
  Future<StaffVerificationDetail> verification(int id) =>
      _parse(() => _api.verification(id));
  @override
  Future<List<int>> verificationBytes(String signedUrl) =>
      _parse(() => _api.verificationBytes(signedUrl));
  @override
  Future<void> decideVerification(
    int id, {
    required String decision,
    String? note,
  }) =>
      _parse(() => _api.decideVerification(id, decision: decision, note: note));

  Future<T> _parse<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FormatException catch (error) {
      throw ApiFailure(
        status: null,
        code: null,
        message: error.message,
        fieldErrors: const {},
        kind: ApiFailureKind.server,
      );
    }
  }
}
