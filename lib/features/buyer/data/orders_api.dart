import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/buyer/data/dto/buyer_dto.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';

class OrdersApi {
  OrdersApi(this.client);

  final ApiClient client;

  Future<Paginated<BuyerOrder>> orders({
    required int page,
    required int limit,
  }) async {
    final response = await client.get(
      '/orders',
      query: {'page': page, 'limit': limit},
    );
    if (response is! Map) {
      throw const FormatException('Orders response must be an object');
    }
    return Paginated.fromJson(
      Map<String, dynamic>.from(response),
      BuyerOrderDto.fromJson,
    );
  }

  Future<BuyerOrder> order(int id) async =>
      BuyerOrderDto.fromJson(await client.get('/orders/$id'));

  Future<BuyerOrder> confirm(int id) async =>
      BuyerOrderDto.fromJson(await client.post('/orders/$id/confirm'));

  Future<BuyerOrder> cancel(int id, {String? reason}) async {
    final content = <String, Object?>{};
    if (reason?.trim().isNotEmpty == true) content['reason'] = reason!.trim();
    return BuyerOrderDto.fromJson(
      await client.post('/orders/$id/cancel', data: content),
    );
  }
}
