import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/driver/data/dto/driver_delivery_dto.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';

class DriverApi {
  DriverApi(this.client);

  final ApiClient client;

  Future<Paginated<DriverDelivery>> available({
    required int page,
    required int limit,
  }) async {
    final response = await client.get(
      '/driver/deliveries/available',
      query: {'page': page, 'limit': limit},
    );
    if (response is! Map) {
      throw const FormatException(
        'Available deliveries response must be an object',
      );
    }
    return Paginated.fromJson(
      Map<String, dynamic>.from(response),
      DriverDeliveryDto.fromJson,
    );
  }

  Future<Paginated<DriverDelivery>> mine({
    DeliveryStatus? status,
    required int page,
    required int limit,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) query['status'] = status.apiValue;
    final response = await client.get('/driver/deliveries/mine', query: query);
    if (response is! Map) {
      throw const FormatException(
        'Driver deliveries response must be an object',
      );
    }
    return Paginated.fromJson(
      Map<String, dynamic>.from(response),
      DriverDeliveryDto.fromJson,
    );
  }

  Future<DriverDelivery> accept(int id) async => DriverDeliveryDto.fromJson(
    await client.post('/driver/deliveries/$id/accept'),
  );

  Future<DriverDelivery> updateStatus(
    int id, {
    required DeliveryStatus status,
    String? failureReason,
  }) async {
    final data = <String, Object?>{'status': status.apiValue};
    if (failureReason != null) data['failureReason'] = failureReason;
    return DriverDeliveryDto.fromJson(
      await client.patch('/driver/deliveries/$id/status', data: data),
    );
  }
}
