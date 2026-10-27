import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_entities.dart';

class StaffWorkflowApi {
  const StaffWorkflowApi(this._client);
  final ApiClient _client;

  Future<Paginated<T>> _page<T>(
    String path,
    Map<String, Object?> query,
    T Function(Object?) parse,
  ) async =>
      Paginated<T>.fromJson(await _client.get(path, query: query), parse);

  Future<Paginated<StaffOrder>> orders({
    required int page,
    required int limit,
  }) => _page('staff/orders', {
    'page': page,
    'limit': limit,
  }, StaffOrder.fromJson);

  Future<StaffOrder> order(int id) async =>
      StaffOrder.fromJson(await _client.get('staff/orders/$id'));

  Future<StaffOrder> createOrder(Map<String, Object?> body) async =>
      StaffOrder.fromJson(await _client.post('staff/orders', data: body));

  Future<StaffOrder> changeOrderStatus(int id, String status) async =>
      StaffOrder.fromJson(
        await _client.patch(
          'staff/orders/$id/status',
          data: {'status': status},
        ),
      );

  Future<StaffOrder> confirmOrder(int id) async =>
      StaffOrder.fromJson(await _client.post('staff/orders/$id/confirm'));

  Future<void> cancelOrder(int id, {String? reason}) async {
    await _client.post(
      'staff/orders/$id/cancel',
      data: reason?.trim().isNotEmpty == true
          ? {'reason': reason!.trim()}
          : null,
    );
  }

  Future<List<StaffPayment>> payments(int orderId) async {
    final response = await _client.get('staff/orders/$orderId/payments');
    if (response is! List) {
      throw const FormatException('Expected payments list');
    }
    return List.unmodifiable(response.map(StaffPayment.fromJson));
  }

  Future<void> recordPayment(
    int orderId,
    Map<String, Object?> body,
    String idempotencyKey,
  ) async {
    await _client.post(
      'staff/orders/$orderId/payments',
      data: body,
      headers: {'Idempotency-Key': idempotencyKey},
    );
  }

  Future<void> refundPayment(int paymentId) async {
    await _client.post('staff/payments/$paymentId/refund');
  }

  Future<void> createDeliveries(int orderId) async {
    await _client.post('staff/orders/$orderId/deliveries');
  }

  Future<Paginated<StaffDelivery>> deliveries({
    required int page,
    required int limit,
    String? status,
    int? orderId,
  }) {
    final query = <String, Object?>{'page': page, 'limit': limit};
    if (status != null) query['status'] = status;
    if (orderId != null) query['orderId'] = orderId;
    return _page('staff/deliveries', query, StaffDelivery.fromJson);
  }

  Future<void> releaseDelivery(int id, {String? reason}) async {
    await _client.post(
      'staff/deliveries/$id/release',
      data: reason?.trim().isNotEmpty == true
          ? {'reason': reason!.trim()}
          : null,
    );
  }

  Future<void> redispatchDelivery(int id) async {
    await _client.post('staff/deliveries/$id/redispatch');
  }

  Future<void> cancelDelivery(int id, String reason) async {
    await _client.post(
      'staff/deliveries/$id/cancel',
      data: {'reason': reason.trim()},
    );
  }

  Future<void> createCompensation(Map<String, Object?> body) async {
    await _client.post('staff/compensations', data: body);
  }

  Future<Paginated<StaffVerification>> verifications({
    required int page,
    required int limit,
    String? status,
    String? type,
    String? role,
    int? userId,
  }) {
    final query = <String, Object?>{'page': page, 'limit': limit};
    if (status != null) query['status'] = status;
    if (type != null) query['type'] = type;
    if (role != null) query['role'] = role;
    if (userId != null) query['userId'] = userId;
    return _page('admin/verifications', query, StaffVerification.fromJson);
  }

  Future<StaffVerificationDetail> verification(int id) async =>
      StaffVerificationDetail.fromJson(
        await _client.get('admin/verifications/$id'),
      );

  Future<List<int>> verificationBytes(String signedUrl) =>
      _client.getBytes(signedUrl, auth: true);

  Future<void> decideVerification(
    int id, {
    required String decision,
    String? note,
  }) async {
    await _client.patch(
      'admin/verifications/$id',
      data: {'decision': decision, if (note != null) 'note': note.trim()},
    );
  }
}
