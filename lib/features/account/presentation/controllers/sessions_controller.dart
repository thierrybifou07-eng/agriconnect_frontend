import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

class SessionsController extends GetxController {
  SessionsController(this._auth, this._repository);

  final AuthController _auth;
  final AuthRepository _repository;
  final Rx<UiState<List<AuthSession>>> state = Rx<UiState<List<AuthSession>>>(
    const Idle<List<AuthSession>>(),
  );
  final Rxn<ApiFailure> actionFailure = Rxn<ApiFailure>();
  final RxBool actionLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    state.value = const Loading<List<AuthSession>>();
    try {
      state.value = Success<List<AuthSession>>(
        await _repository.listSessions(),
      );
    } on ApiFailure catch (failure) {
      state.value = Failure<List<AuthSession>>(failure);
    }
  }

  Future<bool> closeSession(int id) async {
    actionLoading.value = true;
    actionFailure.value = null;
    try {
      await _repository.closeSession(id);
      await load();
      return state.value is Success<List<AuthSession>>;
    } on ApiFailure catch (failure) {
      actionFailure.value = failure;
      return false;
    } finally {
      actionLoading.value = false;
    }
  }

  Future<bool> logoutOtherSessions() async {
    actionLoading.value = true;
    actionFailure.value = null;
    try {
      await _auth.signOutEverywhere();
      await load();
      return state.value is Success<List<AuthSession>>;
    } on ApiFailure catch (failure) {
      actionFailure.value = failure;
      return false;
    } finally {
      actionLoading.value = false;
    }
  }
}
