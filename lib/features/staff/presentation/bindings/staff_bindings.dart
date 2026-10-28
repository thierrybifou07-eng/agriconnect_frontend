import 'package:get/get.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/features/ai/data/ai_api.dart';
import 'package:agri_connect/features/ai/data/ai_repository_impl.dart';
import 'package:agri_connect/features/ai/domain/ai_repository.dart';
import 'package:agri_connect/features/ai/presentation/controllers/ai_controllers.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';
import 'package:agri_connect/features/staff/data/staff_api.dart';
import 'package:agri_connect/features/staff/data/staff_repository_impl.dart';
import 'package:agri_connect/features/staff/data/staff_workflow_api.dart';
import 'package:agri_connect/features/staff/data/staff_workflow_repository_impl.dart';
import 'package:agri_connect/features/staff/domain/staff_repository.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_repository.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_controllers.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_workflow_controllers.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AiRepository>()) {
      Get.lazyPut<AiRepository>(
        () => AiRepositoryImpl(AiApi(Get.find<ApiClient>())),
      );
    }
    Get.lazyPut<AiSuggestionController>(
      () => AiSuggestionController(
        repository: Get.find<AiRepository>(),
        socket: Get.find<SocketService>(),
      ),
    );
    if (!Get.isRegistered<StaffWorkflowRepository>()) {
      Get.lazyPut<StaffWorkflowRepository>(
        () => StaffWorkflowRepositoryImpl(
          StaffWorkflowApi(Get.find<ApiClient>()),
        ),
      );
    }
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
    Get.lazyPut<StaffOrdersController>(
      () => StaffOrdersController(
        repository: Get.find<StaffWorkflowRepository>(),
        staffRepository: Get.find<StaffRepository>(),
        referenceRepository: Get.find<ReferenceRepository>(),
        user: Get.find<AuthController>().currentUser!,
        socket: Get.find<SocketService>(),
      ),
    );
    Get.lazyPut<StaffVerificationsController>(
      () => StaffVerificationsController(
        repository: Get.find<StaffWorkflowRepository>(),
      ),
    );
  }
}
