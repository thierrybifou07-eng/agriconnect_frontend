import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/reference/domain/reference_entities.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';

class LotDraftController extends GetxController {
  LotDraftController({required this.repository});

  static const maxPhotoBytes = 5 * 1024 * 1024;
  final SupplierRepository repository;
  final RxInt step = 0.obs;
  final Rxn<RefProduct> product = Rxn<RefProduct>();
  final Rxn<RefZone> zone = Rxn<RefZone>();
  final Rxn<RefHub> hub = Rxn<RefHub>();
  final RxString quantity = ''.obs;
  final RxString agreedUnitPrice = ''.obs;
  final RxString storageType = 'HUB'.obs;
  final RxString pickupAddress = ''.obs;
  final RxString pickupLatitude = ''.obs;
  final RxString pickupLongitude = ''.obs;
  final RxList<XFile> photos = <XFile>[].obs;
  final Rxn<DateTime> harvestedAt = Rxn<DateTime>();
  final Rxn<DateTime> expiresAt = Rxn<DateTime>();
  final RxString packagingNote = ''.obs;
  final RxString qualityNote = ''.obs;
  final RxString validationError = ''.obs;
  final Rx<UiState<SupplierLot>> submitState = Rx<UiState<SupplierLot>>(
    const Idle(),
  );
  Worker? _zoneWorker;

  bool get isSubmitting => submitState.value is Loading<SupplierLot>;
  bool get isPerishable => product.value?.isPerishable == true;

  @override
  void onInit() {
    super.onInit();
    _zoneWorker = ever<RefZone?>(zone, (_) => hub.value = null);
  }

  @override
  void onClose() {
    _zoneWorker?.dispose();
    super.onClose();
  }

  String? validateStep([int? value]) {
    final current = value ?? step.value;
    if (current == 0) return product.value == null ? 'product' : null;
    if (current == 1) {
      final amount = double.tryParse(quantity.value.trim());
      final price = double.tryParse(agreedUnitPrice.value.trim());
      if (amount == null ||
          amount <= 0 ||
          !_hasAtMostDecimals(quantity.value, 3)) {
        return 'quantity';
      }
      if (price == null ||
          price <= 0 ||
          !_hasAtMostDecimals(agreedUnitPrice.value, 2)) {
        return 'price';
      }
      return null;
    }
    if (current == 2) {
      if (zone.value == null) return 'zone';
      if (storageType.value == 'HUB') return hub.value == null ? 'hub' : null;
      if (pickupAddress.value.trim().isEmpty) return 'pickupAddress';
      final latitude = double.tryParse(pickupLatitude.value.trim());
      if (latitude == null || latitude < -90 || latitude > 90) {
        return 'pickupLatitude';
      }
      final longitude = double.tryParse(pickupLongitude.value.trim());
      if (longitude == null || longitude < -180 || longitude > 180) {
        return 'pickupLongitude';
      }
      return null;
    }
    if (current == 3) {
      if (photos.isEmpty || photos.length > 5) return 'photos';
      if (isPerishable && expiresAt.value == null) return 'expiresAt';
      if (packagingNote.value.length > 500) return 'packagingNote';
      if (qualityNote.value.length > 500) return 'qualityNote';
    }
    return null;
  }

  Future<bool> addPhotos(Iterable<XFile> selected) async {
    final incoming = selected.toList(growable: false);
    if (photos.length + incoming.length > 5) {
      validationError.value = 'photos';
      return false;
    }
    for (final file in incoming) {
      if (await file.length() > maxPhotoBytes) {
        validationError.value = 'photoSize';
        return false;
      }
    }
    photos.addAll(incoming);
    validationError.value = '';
    return true;
  }

  void removePhoto(int index) => photos.removeAt(index);

  void selectStorage(String value) {
    storageType.value = value;
    hub.value = null;
    pickupAddress.value = '';
    pickupLatitude.value = '';
    pickupLongitude.value = '';
  }

  bool nextStep() {
    final error = validateStep();
    validationError.value = error ?? '';
    if (error != null) return false;
    if (step.value < 3) step.value++;
    return true;
  }

  void previousStep() {
    if (step.value > 0) step.value--;
    validationError.value = '';
  }

  Map<String, Object?> createFields() {
    final error =
        validateStep(0) ??
        validateStep(1) ??
        validateStep(2) ??
        validateStep(3);
    if (error != null) throw ArgumentError.value(error, 'draft');
    return {
      'productId': product.value!.id,
      'zoneId': zone.value!.id,
      'agreedUnitPrice': double.parse(agreedUnitPrice.value.trim()),
      'quantity': double.parse(quantity.value.trim()),
      'storageType': storageType.value,
      if (storageType.value == 'HUB') 'hubId': hub.value!.id,
      if (storageType.value == 'SUPPLIER_SITE') ...{
        'pickupAddress': pickupAddress.value.trim(),
        'pickupLatitude': double.parse(pickupLatitude.value.trim()),
        'pickupLongitude': double.parse(pickupLongitude.value.trim()),
      },
      if (harvestedAt.value != null)
        'harvestedAt': harvestedAt.value!.toUtc().toIso8601String(),
      if (expiresAt.value != null)
        'expiresAt': expiresAt.value!.toUtc().toIso8601String(),
      if (packagingNote.value.trim().isNotEmpty)
        'packagingNote': packagingNote.value.trim(),
      if (qualityNote.value.trim().isNotEmpty)
        'qualityNote': qualityNote.value.trim(),
    };
  }

  Future<bool> submit() async {
    final error =
        validateStep(0) ??
        validateStep(1) ??
        validateStep(2) ??
        validateStep(3);
    if (error != null) {
      step.value = switch (error) {
        'product' => 0,
        'quantity' || 'price' => 1,
        'zone' ||
        'hub' ||
        'pickupAddress' ||
        'pickupLatitude' ||
        'pickupLongitude' => 2,
        _ => 3,
      };
      validationError.value = error;
      return false;
    }
    submitState.value = const Loading();
    try {
      final lot = await repository.createLot(
        createFields(),
        photos.map((photo) => photo.path).toList(growable: false),
      );
      submitState.value = Success(lot);
      return true;
    } on ApiFailure catch (failure) {
      submitState.value = Failure(failure);
      validationError.value = failure.fieldErrors.keys.firstOrNull ?? '';
      return false;
    }
  }

  static bool _hasAtMostDecimals(String input, int places) {
    final match = RegExp(r'^\d+(?:\.(\d+))?$').firstMatch(input.trim());
    return match != null && (match.group(1)?.length ?? 0) <= places;
  }
}
