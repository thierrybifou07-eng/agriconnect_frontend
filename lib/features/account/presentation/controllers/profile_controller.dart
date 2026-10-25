import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/account/domain/account_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/reference/domain/reference_entities.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';

class ProfileController extends GetxController {
  ProfileController(this.auth, this._account, this._references);

  final AuthController auth;
  final AccountRepository _account;
  final ReferenceRepository _references;
  ReferenceRepository get references => _references;
  final ImagePicker _imagePicker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final location = TextEditingController();
  final farmName = TextEditingController();
  final description = TextEditingController();
  final businessName = TextEditingController();
  final vehicleType = TextEditingController();
  final plateNumber = TextEditingController();
  final Rx<UiState<AuthUser>> state = Rx<UiState<AuthUser>>(
    const Idle<AuthUser>(),
  );
  final Rxn<RefZone> selectedZone = Rxn<RefZone>();
  final RxList<RefZone> zones = <RefZone>[].obs;
  final RxBool saving = false.obs;
  final RxBool uploadingAvatar = false.obs;
  final RxBool loadingZones = false.obs;
  final Rxn<ApiFailure> zoneFailure = Rxn<ApiFailure>();
  final Rxn<ApiFailure> avatarFailure = Rxn<ApiFailure>();
  final RxString buyerType = 'RETAILER'.obs;
  bool _zoneSelectionLoaded = false;

  AuthUser? get currentUser => auth.currentUser;
  RoleCode? get role => currentUser?.role;
  bool get canEditRoleProfile =>
      role == RoleCode.supplier ||
      role == RoleCode.buyer ||
      role == RoleCode.driver;

  @override
  void onInit() {
    super.onInit();
    _populateFields();
    if (role == RoleCode.supplier || role == RoleCode.buyer) {
      unawaited(loadZones());
    }
  }

  void _populateFields() {
    final user = currentUser;
    if (user == null) return;
    firstname.text = user.firstname ?? '';
    lastname.text = user.lastname ?? '';
    location.text = user.location ?? '';
    switch (user.profile) {
      case SupplierProfile profile:
        farmName.text = profile.farmName ?? '';
        description.text = profile.description ?? '';
      case BuyerProfile profile:
        buyerType.value = profile.buyerType ?? 'RETAILER';
        businessName.text = profile.businessName ?? '';
      case DriverProfile profile:
        vehicleType.text = profile.vehicleType ?? '';
        plateNumber.text = profile.plateNumber ?? '';
      case null:
        break;
    }
  }

  Future<void> loadZones() async {
    loadingZones.value = true;
    zoneFailure.value = null;
    try {
      final result = await _references.zones();
      zones.assignAll(result);
      _zoneSelectionLoaded = true;
      final selectedId = switch (currentUser?.profile) {
        SupplierProfile profile => profile.zoneId,
        BuyerProfile profile => profile.zoneId,
        _ => null,
      };
      selectedZone.value = result
          .where((zone) => zone.id == selectedId)
          .firstOrNull;
    } on ApiFailure catch (failure) {
      zoneFailure.value = failure;
    } finally {
      loadingZones.value = false;
    }
  }

  Future<bool> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    saving.value = true;
    state.value = const Loading<AuthUser>();
    try {
      await _account.updateUser({
        'firstname': firstname.text.trim(),
        'lastname': lastname.text.trim(),
        'location': location.text.trim(),
      });
      if (canEditRoleProfile) {
        await _account.updateRoleProfile(_roleProfilePayload());
      }
      final refreshed = await auth.refreshUser();
      if (!refreshed) throw _refreshFailure();
      final user = auth.currentUser!;
      state.value = Success<AuthUser>(user);
      return true;
    } on ApiFailure catch (failure) {
      state.value = Failure<AuthUser>(failure);
      return false;
    } finally {
      saving.value = false;
    }
  }

  Map<String, Object?> _roleProfilePayload() => switch (role) {
    RoleCode.supplier => {
      'farmName': farmName.text.trim(),
      'description': description.text.trim().isEmpty
          ? null
          : description.text.trim(),
      if (_zoneSelectionLoaded) 'zoneId': selectedZone.value?.id,
    },
    RoleCode.buyer => {
      'buyerType': buyerType.value,
      'businessName': businessName.text.trim().isEmpty
          ? null
          : businessName.text.trim(),
      if (_zoneSelectionLoaded) 'zoneId': selectedZone.value?.id,
    },
    RoleCode.driver => {
      'vehicleType': vehicleType.text.trim().isEmpty
          ? null
          : vehicleType.text.trim(),
      'plateNumber': plateNumber.text.trim().isEmpty
          ? null
          : plateNumber.text.trim(),
    },
    _ => const {},
  };

  Future<bool?> chooseAndUploadAvatar() async {
    avatarFailure.value = null;
    XFile? image;
    try {
      image = await _imagePicker.pickImage(source: ImageSource.gallery);
    } on PlatformException catch (error) {
      avatarFailure.value = ApiFailure(
        status: null,
        code: 'IMAGE_PICKER_FAILED',
        message: error.message ?? 'Unable to select image',
        fieldErrors: const {},
        kind: ApiFailureKind.client,
      );
      return false;
    }
    if (image == null) return null;
    late final Uint8List bytes;
    try {
      bytes = await image.readAsBytes();
    } on PlatformException catch (error) {
      avatarFailure.value = ApiFailure(
        status: null,
        code: 'IMAGE_READ_FAILED',
        message: error.message ?? 'Unable to read selected image',
        fieldErrors: const {},
        kind: ApiFailureKind.client,
      );
      return false;
    }
    final extension = image.name.split('.').last.toLowerCase();
    if (bytes.length > 5 * 1024 * 1024 ||
        !const {'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
      avatarFailure.value = const ApiFailure(
        status: 400,
        code: 'INVALID_FILE',
        message: 'Choose a supported image no larger than 5 MB',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
      return false;
    }
    return uploadAvatar(bytes, image.name);
  }

  Future<bool> uploadAvatar(Uint8List bytes, String filename) async {
    avatarFailure.value = null;
    if (bytes.length > 5 * 1024 * 1024 ||
        !const {
          'jpg',
          'jpeg',
          'png',
          'webp',
        }.contains(filename.split('.').last.toLowerCase())) {
      avatarFailure.value = const ApiFailure(
        status: 400,
        code: 'INVALID_FILE',
        message: 'Choose a supported image no larger than 5 MB',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
      return false;
    }
    uploadingAvatar.value = true;
    try {
      await _account.uploadAvatar(bytes, filename);
      if (!await auth.refreshUser()) throw _refreshFailure();
      return true;
    } on ApiFailure catch (failure) {
      avatarFailure.value = failure;
      return false;
    } finally {
      uploadingAvatar.value = false;
    }
  }

  ApiFailure _refreshFailure() => const ApiFailure(
    status: null,
    code: null,
    message: 'Unable to refresh the account profile',
    fieldErrors: {},
    kind: ApiFailureKind.server,
  );

  @override
  void onClose() {
    firstname.dispose();
    lastname.dispose();
    location.dispose();
    farmName.dispose();
    description.dispose();
    businessName.dispose();
    vehicleType.dispose();
    plateNumber.dispose();
    super.onClose();
  }
}
