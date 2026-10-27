import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/features/admin/data/admin_api.dart';
import 'package:agri_connect/features/admin/data/admin_repository_impl.dart';
import 'package:agri_connect/features/admin/data/admin_operations_api.dart';
import 'package:agri_connect/features/admin/data/admin_operations_repository_impl.dart';
import 'package:agri_connect/features/admin/domain/admin_operations.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_controllers.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_operations_controller.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminRepository>(
      () => AdminRepositoryImpl(AdminApi(Get.find<ApiClient>())),
    );
    Get.lazyPut<AdminOperationsRepository>(
      () => AdminOperationsRepositoryImpl(
        AdminOperationsApi(Get.find<ApiClient>()),
      ),
    );
    Get.lazyPut(
      () => AdminOperationsController(
        repository: Get.find<AdminOperationsRepository>(),
        references: Get.find<ReferenceRepository>(),
      ),
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
