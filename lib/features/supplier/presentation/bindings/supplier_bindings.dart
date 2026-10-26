import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/features/chat/presentation/bindings/chat_bindings.dart';
import 'package:agri_connect/features/chat/presentation/controllers/conversations_controller.dart';
import 'package:agri_connect/features/supplier/data/supplier_api.dart';
import 'package:agri_connect/features/supplier/data/supplier_repository_impl.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';
import 'package:agri_connect/features/supplier/presentation/controllers/lot_draft_controller.dart';
import 'package:agri_connect/features/supplier/presentation/controllers/supplier_controllers.dart';

class SupplierBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupplierRepository>()) {
      Get.lazyPut<SupplierRepository>(
        () => SupplierRepositoryImpl(SupplierApi(Get.find<ApiClient>())),
      );
    }
    if (!Get.isRegistered<SupplierLotsController>()) {
      Get.lazyPut(() => SupplierLotsController(Get.find<SupplierRepository>()));
    }
    if (!Get.isRegistered<ConversationsController>()) {
      ConversationsBinding().dependencies();
    }
    SupplierRevenueBinding().dependencies();
  }
}

class SupplierLotDetailBinding extends Bindings {
  @override
  void dependencies() {
    final id = int.tryParse(Get.parameters['lotId'] ?? '');
    if (id == null || id < 1) {
      throw ArgumentError('Supplier lot route requires a valid lotId');
    }
    Get.lazyPut(
      () => SupplierLotDetailController(
        repository: Get.find<SupplierRepository>(),
        id: id,
      ),
    );
  }
}

class LotDraftBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => LotDraftController(repository: Get.find<SupplierRepository>()),
    );
  }
}

class SupplierRevenueBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupplierRevenueController<SupplierPayout>>(
      tag: 'supplier-payouts',
    )) {
      Get.lazyPut(
        () => SupplierRevenueController<SupplierPayout>(
          fetch: (page, limit) =>
              Get.find<SupplierRepository>().payouts(page: page, limit: limit),
        ),
        tag: 'supplier-payouts',
      );
    }
    if (!Get.isRegistered<SupplierRevenueController<SupplierCompensation>>(
      tag: 'supplier-compensations',
    )) {
      Get.lazyPut(
        () => SupplierRevenueController<SupplierCompensation>(
          fetch: (page, limit) => Get.find<SupplierRepository>().compensations(
            page: page,
            limit: limit,
          ),
        ),
        tag: 'supplier-compensations',
      );
    }
  }
}
