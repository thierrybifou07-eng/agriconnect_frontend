import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/features/driver/data/driver_api.dart';
import 'package:agri_connect/features/driver/data/driver_repository_impl.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_repository.dart';
import 'package:agri_connect/features/driver/presentation/controllers/delivery_progress_controller.dart';
import 'package:agri_connect/features/driver/presentation/controllers/driver_controller.dart';

class DriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverRepository>(
      () => DriverRepositoryImpl(DriverApi(Get.find<ApiClient>())),
    );
    Get.lazyPut<DriverController>(
      () => DriverController(
        repository: Get.find<DriverRepository>(),
        socketService: Get.find<SocketService>(),
      ),
    );
  }
}

class DriverDeliveryDetailBinding extends Bindings {
  @override
  void dependencies() {
    final delivery = Get.arguments;
    if (delivery is! DriverDelivery) {
      throw ArgumentError('Driver delivery detail requires a DriverDelivery');
    }
    Get.lazyPut<DeliveryProgressController>(
      () => DeliveryProgressController(
        delivery: delivery,
        repository: Get.find<DriverRepository>(),
        reloadDelivery: Get.find<DriverController>().reloadDelivery,
        refreshLists: Get.find<DriverController>().refreshAll,
        socketService: Get.find<SocketService>(),
      ),
    );
  }
}
