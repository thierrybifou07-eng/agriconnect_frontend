import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/features/admin/data/admin_api.dart';
import 'package:agri_connect/features/admin/data/admin_repository_impl.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_controllers.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminRepository>(
      () => AdminRepositoryImpl(AdminApi(Get.find<ApiClient>())),
    );
    Get.lazyPut(
      () => AdminDashboardController(repository: Get.find<AdminRepository>()),
    );
    Get.lazyPut(
      () => AdminUsersController(repository: Get.find<AdminRepository>()),
    );
    Get.lazyPut(
      () => AdminAgentsController(repository: Get.find<AdminRepository>()),
    );
    Get.lazyPut(
      () => AdminPlatformController(repository: Get.find<AdminRepository>()),
    );
  }
}
