import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

const adminCapabilities = <String>[
  'BUYER_SUPPORT',
  'SUPPLIER_SUPPORT',
  'LISTING_MANAGEMENT',
  'ORDER_PROCESSING',
  'STOCK_VALIDATION',
  'PAYMENT_FOLLOWUP',
  'DISPATCH_COORDINATION',
  'USER_VERIFICATION',
  'DISPUTE_HANDLING',
];

bool canEditPlatformSettings(RoleCode role) => role == RoleCode.root;

Map<String, Object?> platformSettingsPatch({
  required double supplierCommissionPercent,
  required String buyerFeeType,
  required double buyerFeeValue,
  required double transportMarkupPercent,
  required double referralBuyerReward,
  required double referralSupplierReward,
  required int reservationHours,
  required double expiryCompensationPercent,
}) => {
  'supplierCommissionRate': supplierCommissionPercent / 100,
  'buyerFeeType': buyerFeeType,
  'buyerFeeValue': buyerFeeType == 'PERCENT'
      ? buyerFeeValue / 100
      : buyerFeeValue,
  'transportMarkupRate': transportMarkupPercent / 100,
  'referralBuyerReward': referralBuyerReward,
  'referralSupplierReward': referralSupplierReward,
  'reservationHours': reservationHours,
  'expiryCompensationRate': expiryCompensationPercent / 100,
};

class AdminDashboardController extends GetxController {
  AdminDashboardController({required this.repository, DateTime? now})
    : to = (now ?? DateTime.now()).toUtc().obs,
      from = (now ?? DateTime.now())
          .toUtc()
          .subtract(const Duration(days: 30))
          .obs;

  final AdminRepository repository;
  final Rx<DateTime> from;
  final Rx<DateTime> to;
  final Rx<UiState<AdminStats>> state = Rx<UiState<AdminStats>>(
    const Idle<AdminStats>(),
  );

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const Loading<AdminStats>();
    try {
      state.value = Success(
        await repository.stats(from: from.value, to: to.value),
      );
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    }
  }

  Future<void> setPeriod(DateTime start, DateTime end) async {
    from.value = DateTime.utc(start.year, start.month, start.day);
    to.value = DateTime(end.year, end.month, end.day, 23, 59, 59).toUtc();
    await load();
  }
}

class AdminUsersController extends GetxController {
  AdminUsersController({required this.repository});

  final AdminRepository repository;
  final Rx<UiState<List<AdminUser>>> state = Rx<UiState<List<AdminUser>>>(
    const Idle<List<AdminUser>>(),
  );
  final Rx<UiState<void>> actionState = Rx<UiState<void>>(const Idle<void>());
  final RxString search = ''.obs;
  final RxnString role = RxnString();
  final RxnString status = RxnString();
  final RxnString profileVerificationStatus = RxnString();
  int _loadSequence = 0;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final request = ++_loadSequence;
    state.value = const Loading<List<AdminUser>>();
    try {
      final users = await repository.users(
        role: role.value,
        search: search.value,
        status: status.value,
        profileVerificationStatus: profileVerificationStatus.value,
      );
      if (request != _loadSequence) return;
      state.value = Success(users);
    } on ApiFailure catch (failure) {
      if (request == _loadSequence) state.value = Failure(failure);
    }
  }

  Future<bool> createStaff(Map<String, Object?> body) async {
    actionState.value = const Loading<void>();
    try {
      await repository.createStaff(body);
      actionState.value = const Success<void>(null);
      await load();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      return false;
    }
  }

  Future<bool> setSuspended(AdminUser user, {required bool suspend}) async {
    actionState.value = const Loading<void>();
    try {
      if (suspend) {
        await repository.suspendUser(user.id);
      } else {
        await repository.reactivateUser(user.id);
      }
      actionState.value = const Success<void>(null);
      await load();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      return false;
    }
  }

  Future<void> setSearch(String value) async {
    search.value = value;
    await load();
  }

  Future<void> setRole(String? value) async {
    role.value = value;
    await load();
  }

  Future<void> setStatus(String? value) async {
    status.value = value;
    await load();
  }

  Future<void> setProfileVerificationStatus(String? value) async {
    profileVerificationStatus.value = value;
    await load();
  }
}

class AdminAgentsController extends GetxController {
  AdminAgentsController({required this.repository});

  final AdminRepository repository;
  final Rx<UiState<List<AdminAgent>>> state = Rx<UiState<List<AdminAgent>>>(
    const Idle<List<AdminAgent>>(),
  );
  final Rx<UiState<void>> actionState = Rx<UiState<void>>(const Idle<void>());

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const Loading<List<AdminAgent>>();
    try {
      state.value = Success(await repository.agents());
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    }
  }

  Future<bool> updateAgent(
    AdminAgent agent, {
    required String displayName,
    required bool isActive,
    required Iterable<String> capabilities,
    required String? autonomy,
  }) async {
    actionState.value = const Loading<void>();
    final completeCapabilities = <String>[];
    for (final capability in capabilities) {
      if (adminCapabilities.contains(capability) &&
          !completeCapabilities.contains(capability)) {
        completeCapabilities.add(capability);
      }
    }
    try {
      await repository.updateAgent(agent.id, {
        'displayName': displayName.trim(),
        'isActive': isActive,
        'capabilities': completeCapabilities,
        'autonomy': autonomy,
      });
      actionState.value = const Success<void>(null);
      await load();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      return false;
    }
  }
}

class AdminPlatformController extends GetxController {
  AdminPlatformController({required this.repository});

  final AdminRepository repository;
  final Rx<UiState<PlatformSettings>> settingsState =
      Rx<UiState<PlatformSettings>>(const Idle<PlatformSettings>());
  final Rx<UiState<Paginated<AdminAuditLog>>> auditState =
      Rx<UiState<Paginated<AdminAuditLog>>>(
        const Idle<Paginated<AdminAuditLog>>(),
      );
  final Rx<UiState<void>> actionState = Rx<UiState<void>>(const Idle<void>());
  final RxInt auditPage = 1.obs;
  final RxInt auditTotal = 0.obs;
  final RxString entityType = ''.obs;
  final RxnInt entityId = RxnInt();
  final RxnInt actorUserId = RxnInt();
  final RxnInt actorAgentId = RxnInt();
  final Rxn<DateTime> auditFrom = Rxn<DateTime>();
  final Rxn<DateTime> auditTo = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadAudit();
  }

  Future<void> loadSettings() async {
    settingsState.value = const Loading<PlatformSettings>();
    try {
      settingsState.value = Success(await repository.settings());
    } on ApiFailure catch (failure) {
      settingsState.value = Failure(failure);
    }
  }

  Future<bool> saveSettings(Map<String, Object?> fields) async {
    if (fields.isEmpty || fields.containsKey('currency')) {
      throw ArgumentError('Settings require editable fields only');
    }
    actionState.value = const Loading<void>();
    try {
      settingsState.value = Success(await repository.updateSettings(fields));
      actionState.value = const Success<void>(null);
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      return false;
    }
  }

  Future<void> loadAudit({int? page}) async {
    final nextPage = page ?? auditPage.value;
    auditState.value = const Loading<Paginated<AdminAuditLog>>();
    try {
      final result = await repository.auditLogs(
        page: nextPage,
        limit: 20,
        entityType: entityType.value,
        entityId: entityId.value,
        actorUserId: actorUserId.value,
        actorAgentId: actorAgentId.value,
        from: auditFrom.value,
        to: auditTo.value,
      );
      auditPage.value = result.page;
      auditTotal.value = result.total;
      auditState.value = Success(result);
    } on ApiFailure catch (failure) {
      auditState.value = Failure(failure);
    }
  }
}
