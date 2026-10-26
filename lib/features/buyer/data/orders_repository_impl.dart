import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/buyer/data/orders_api.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/domain/buyer_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._api);

  final OrdersApi _api;

  @override
  Future<Paginated<BuyerOrder>> orders({
    required int page,
    required int limit,
  }) => _parse(() => _api.orders(page: page, limit: limit));

  @override
  Future<BuyerOrder> order(int id) => _parse(() => _api.order(id));

  @override
  Future<BuyerOrder> confirm(int id) => _parse(() => _api.confirm(id));

  @override
  Future<BuyerOrder> cancel(int id, {String? reason}) =>
      _parse(() => _api.cancel(id, reason: reason));

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
