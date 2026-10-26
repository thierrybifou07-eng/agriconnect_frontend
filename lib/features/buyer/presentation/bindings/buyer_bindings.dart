import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/features/buyer/data/catalog_api.dart';
import 'package:agri_connect/features/buyer/data/catalog_repository_impl.dart';
import 'package:agri_connect/features/buyer/data/orders_api.dart';
import 'package:agri_connect/features/buyer/data/orders_repository_impl.dart';
import 'package:agri_connect/features/buyer/domain/buyer_repository.dart';
import 'package:agri_connect/features/buyer/presentation/controllers/catalog_controller.dart';
import 'package:agri_connect/features/buyer/presentation/controllers/orders_controller.dart';
import 'package:agri_connect/features/chat/presentation/bindings/chat_bindings.dart';

class BuyerBinding extends Bindings {
  @override
  void dependencies() {
    ConversationsBinding().dependencies();
    Get.lazyPut<CatalogRepository>(
      () => CatalogRepositoryImpl(CatalogApi(Get.find<ApiClient>())),
    );
    Get.lazyPut<OrdersRepository>(
      () => OrdersRepositoryImpl(OrdersApi(Get.find<ApiClient>())),
    );
    Get.lazyPut<CatalogController>(
      () => CatalogController(repository: Get.find<CatalogRepository>()),
    );
    Get.lazyPut<BuyerOrdersController>(
      () => BuyerOrdersController(
        repository: Get.find<OrdersRepository>(),
        socketService: Get.find<SocketService>(),
      ),
    );
  }
}

class ListingDetailBinding extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments;
    if (arguments is! int) {
      throw ArgumentError('Listing detail requires an integer id');
    }
    Get.lazyPut<ListingDetailController>(
      () => ListingDetailController(
        id: arguments,
        repository: Get.find<CatalogRepository>(),
      ),
    );
  }
}

class BuyerOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    final rawId = Get.parameters['orderId'];
    final id = int.tryParse(rawId ?? '');
    if (id == null) {
      throw ArgumentError('Buyer order detail requires an integer id');
    }
    Get.lazyPut<BuyerOrderDetailController>(
      () => BuyerOrderDetailController(
        id: id,
        repository: Get.find<OrdersRepository>(),
        refreshOrders: Get.find<BuyerOrdersController>().refreshFromDetail,
      ),
    );
  }
}
