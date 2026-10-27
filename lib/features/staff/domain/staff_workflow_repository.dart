import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_entities.dart';

abstract interface class StaffWorkflowRepository {
  Future<Paginated<StaffOrder>> orders({int page = 1, int limit = 20});
  Future<StaffOrder> order(int id);
  Future<StaffOrder> createOrder(Map<String, Object?> body);
  Future<StaffOrder> changeOrderStatus(int id, String status);
  Future<StaffOrder> confirmOrder(int id);
  Future<void> cancelOrder(int id, {String? reason});
  Future<List<StaffPayment>> payments(int orderId);
  Future<void> recordPayment(
    int orderId,
    Map<String, Object?> body,
    String idempotencyKey,
  );
  Future<void> refundPayment(int paymentId);
  Future<void> createDeliveries(int orderId);
  Future<Paginated<StaffDelivery>> deliveries({
    int page = 1,
    int limit = 20,
    String? status,
    int? orderId,
  });
  Future<void> releaseDelivery(int id, {String? reason});
  Future<void> redispatchDelivery(int id);
  Future<void> cancelDelivery(int id, String reason);
  Future<void> createCompensation(Map<String, Object?> body);
  Future<Paginated<StaffVerification>> verifications({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
    String? role,
    int? userId,
  });
  Future<StaffVerificationDetail> verification(int id);
  Future<List<int>> verificationBytes(String signedUrl);
  Future<void> decideVerification(
    int id, {
    required String decision,
    String? note,
  });
}
