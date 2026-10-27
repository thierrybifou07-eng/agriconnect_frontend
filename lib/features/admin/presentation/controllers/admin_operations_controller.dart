import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/admin/domain/admin_operations.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';

part 'admin_referential_controller_part.dart';
part 'admin_agency_controller_part.dart';
part 'admin_financial_controller_part.dart';
part 'admin_legal_controller_part.dart';

String? validateAdminReferential(String kind, Map<String, Object?> values) {
  String text(String key) =>
      values[key] is String ? (values[key] as String).trim() : '';
  int? positiveId(String key) {
    final value = values[key];
    return value is num && value == value.toInt() && value > 0
        ? value.toInt()
        : null;
  }

  bool length(String key, int min, int max) =>
      text(key).length >= min && text(key).length <= max;
  bool optionalLength(String key, int max) => text(key).length <= max;
  final code = text('code');
  switch (kind) {
    case 'categories':
    case 'units':
      if (!RegExp(r'^[A-Z][A-Z0-9_]{1,19}$').hasMatch(code)) return 'code';
      if (!length('label', 2, 80)) return 'label';
    case 'products':
      if (positiveId('categoryId') == null ||
          positiveId('unitId') == null ||
          !length('name', 2, 120)) {
        return 'name';
      }
      final imageUrl = text('imageUrl');
      if (!optionalLength('description', 500)) return 'description';
      if (imageUrl.length > 500 ||
          (imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasScheme != true)) {
        return 'imageUrl';
      }
    case 'zones':
      if (!length('name', 2, 120)) return 'name';
      if (!optionalLength('city', 80)) return 'city';
      if (!optionalLength('region', 80)) return 'region';
    case 'hubs':
      if (!length('name', 2, 120) ||
          text('address').length < 3 ||
          text('address').length > 500 ||
          positiveId('zoneId') == null ||
          !optionalLength('city', 80)) {
        return 'name';
      }
      final latitudeValue = values['latitude'];
      final longitudeValue = values['longitude'];
      final latitude = latitudeValue is num ? latitudeValue.toDouble() : null;
      final longitude = longitudeValue is num
          ? longitudeValue.toDouble()
          : null;
      if (latitude == null || latitude < -90 || latitude > 90) {
        return 'latitude';
      }
      if (longitude == null || longitude < -180 || longitude > 180) {
        return 'longitude';
      }
    default:
      return 'kind';
  }
  return null;
}

class AdminOperationsController extends GetxController {
  AdminOperationsController({
    required this.repository,
    required this.references,
  });

  final AdminOperationsRepository repository;
  final ReferenceRepository references;

  final RxString referentialKind = 'categories'.obs;
  final RxnBool activeFilter = RxnBool();
  final Rx<UiState<Paginated<AdminOperationRecord>>> referentialState =
      Rx<UiState<Paginated<AdminOperationRecord>>>(
        const Idle<Paginated<AdminOperationRecord>>(),
      );
  final Rx<UiState<Paginated<AdminOperationRecord>>> agencyState =
      Rx<UiState<Paginated<AdminOperationRecord>>>(
        const Idle<Paginated<AdminOperationRecord>>(),
      );
  final Rx<UiState<List<AdminOperationRecord>>> driversState =
      Rx<UiState<List<AdminOperationRecord>>>(
        const Idle<List<AdminOperationRecord>>(),
      );
  final Rx<UiState<Paginated<AdminOperationRecord>>> moneyState =
      Rx<UiState<Paginated<AdminOperationRecord>>>(
        const Idle<Paginated<AdminOperationRecord>>(),
      );
  final Rx<UiState<List<AdminLegalDocument>>> legalState =
      Rx<UiState<List<AdminLegalDocument>>>(
        const Idle<List<AdminLegalDocument>>(),
      );
  final Rx<UiState<void>> actionState = Rx<UiState<void>>(const Idle<void>());
  final RxString moneyKind = 'payouts'.obs;
  final RxnString moneyStatus = RxnString();
  final RxList<AdminOperationRecord> agencyDrivers =
      <AdminOperationRecord>[].obs;
  final RxList<AdminLegalDocument> publishedDocuments =
      <AdminLegalDocument>[].obs;
  int _referentialPage = 1;
  int _agencyPage = 1;
  int _moneyPage = 1;
  bool _referentialsHaveMore = false;
  bool _agenciesHaveMore = false;
  bool _moneyHaveMore = false;

  @override
  void onInit() {
    super.onInit();
    loadReferentials();
  }

  @override
  void onClose() {
    agencyDrivers.clear();
    publishedDocuments.clear();
    moneyState.value = const Idle<Paginated<AdminOperationRecord>>();
    super.onClose();
  }
}
