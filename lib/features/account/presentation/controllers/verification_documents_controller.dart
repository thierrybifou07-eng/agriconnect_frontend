import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/account/domain/account_entities.dart';
import 'package:agri_connect/features/account/domain/account_repository.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

class VerificationDocumentsController extends GetxController {
  VerificationDocumentsController(this._account, this._auth);

  final AccountRepository _account;
  final AuthController _auth;
  final Rx<UiState<List<VerificationDocument>>> state =
      Rx<UiState<List<VerificationDocument>>>(
        const Idle<List<VerificationDocument>>(),
      );
  final RxBool uploading = false.obs;
  final Rxn<ApiFailure> uploadFailure = Rxn<ApiFailure>();
  final Rxn<PlatformFile> selectedFile = Rxn<PlatformFile>();
  final RxString selectedType = 'ID_CARD'.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    state.value = const Loading<List<VerificationDocument>>();
    try {
      state.value = Success<List<VerificationDocument>>(
        await _account.listDocuments(),
      );
    } on ApiFailure catch (failure) {
      state.value = Failure<List<VerificationDocument>>(failure);
    }
  }

  Future<void> selectFile() async {
    try {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      );
      if (result == null) return;
      selectedFile.value = result;
      uploadFailure.value = null;
    } on PlatformException catch (error) {
      uploadFailure.value = ApiFailure(
        status: null,
        code: 'FILE_PICKER_FAILED',
        message: error.message ?? 'Unable to select file',
        fieldErrors: const {},
        kind: ApiFailureKind.client,
      );
    }
  }

  Future<bool> uploadSelectedFile() async {
    final file = selectedFile.value;
    if (file == null) {
      uploadFailure.value = const ApiFailure(
        status: 400,
        code: 'FILE_REQUIRED',
        message: 'Select a file before uploading',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
      return false;
    }
    late final Uint8List bytes;
    try {
      final size = await file.length();
      if (size == null) {
        uploadFailure.value = const ApiFailure(
          status: null,
          code: 'FILE_READ_FAILED',
          message: 'Unable to read selected file',
          fieldErrors: {},
          kind: ApiFailureKind.client,
        );
        return false;
      }
      if (size > 8 * 1024 * 1024) {
        uploadFailure.value = const ApiFailure(
          status: 400,
          code: 'FILE_TOO_LARGE',
          message: 'File exceeds the 8 MB limit',
          fieldErrors: {},
          kind: ApiFailureKind.client,
        );
        return false;
      }
      bytes = await file.readAsBytes();
    } on PlatformException catch (error) {
      uploadFailure.value = ApiFailure(
        status: null,
        code: 'FILE_READ_FAILED',
        message: error.message ?? 'Unable to read selected file',
        fieldErrors: const {},
        kind: ApiFailureKind.client,
      );
      return false;
    }
    return upload(bytes: bytes, filename: file.name, type: selectedType.value);
  }

  Future<bool> upload({
    required Uint8List bytes,
    required String filename,
    required String type,
  }) async {
    uploadFailure.value = null;
    final extension = filename.split('.').last.toLowerCase();
    if (bytes.length > 8 * 1024 * 1024) {
      uploadFailure.value = const ApiFailure(
        status: 400,
        code: 'FILE_TOO_LARGE',
        message: 'File exceeds the 8 MB limit',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
      return false;
    }
    if (!const {'jpg', 'jpeg', 'png', 'webp', 'pdf'}.contains(extension)) {
      uploadFailure.value = const ApiFailure(
        status: 400,
        code: 'INVALID_FILE',
        message: 'File must be PDF or image',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
      return false;
    }
    uploading.value = true;
    try {
      await _account.uploadDocument(bytes, filename, type);
      if (!await _auth.refreshUser()) {
        throw const ApiFailure(
          status: null,
          code: null,
          message: 'Unable to refresh the account verification status',
          fieldErrors: {},
          kind: ApiFailureKind.server,
        );
      }
      await load();
      return state.value is Success<List<VerificationDocument>>;
    } on ApiFailure catch (failure) {
      uploadFailure.value = failure;
      return false;
    } finally {
      uploading.value = false;
    }
  }
}
