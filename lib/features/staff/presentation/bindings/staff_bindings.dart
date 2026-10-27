import 'package:get/get.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/features/staff/data/staff_api.dart';
import 'package:agri_connect/features/staff/data/staff_repository_impl.dart';
import 'package:agri_connect/features/staff/domain/staff_repository.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_controllers.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StaffRepository>()) {
      Get.lazyPut<StaffRepository>(
        () => StaffRepositoryImpl(StaffApi(Get.find<ApiClient>())),
      );
    }
    Get.lazyPut<StaffInboxController>(
      () => StaffInboxController(
        repository: Get.find<StaffRepository>(),
        socket: Get.find<SocketService>(),
      ),
    );
    Get.lazyPut<StaffLotsController>(
      () => StaffLotsController(repository: Get.find<StaffRepository>()),
    );
    Get.lazyPut<StaffListingsController>(
      () => StaffListingsController(repository: Get.find<StaffRepository>()),
    );
  }
}
