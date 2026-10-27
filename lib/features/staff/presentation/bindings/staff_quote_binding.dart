import 'package:get/get.dart';

import 'package:agri_connect/features/reference/domain/reference_repository.dart';
import 'package:agri_connect/features/staff/presentation/bindings/staff_bindings.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_quote_controller.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_workflow_controllers.dart';

class StaffQuoteBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StaffOrdersController>()) {
      StaffBinding().dependencies();
    }
    final buyerId = int.tryParse(Get.parameters['buyerId'] ?? '');
    final conversationId = int.tryParse(Get.parameters['conversationId'] ?? '');
    if (buyerId == null || buyerId <= 0) {
      throw ArgumentError('Quote creation requires a buyerId');
    }
    Get.lazyPut<StaffQuoteController>(
      () => StaffQuoteController(
        buyerId: buyerId,
        conversationId: conversationId,
        ordersController: Get.find<StaffOrdersController>(),
        referenceRepository: Get.find<ReferenceRepository>(),
      ),
    );
  }
}
