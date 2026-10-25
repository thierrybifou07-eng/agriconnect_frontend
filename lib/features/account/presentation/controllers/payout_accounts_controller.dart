import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/account/domain/account_entities.dart';
import 'package:agri_connect/features/account/domain/account_repository.dart';

class PayoutAccountsController extends GetxController {
  PayoutAccountsController(this._account);

  final AccountRepository _account;
  final Rx<UiState<List<PayoutAccount>>> state =
      Rx<UiState<List<PayoutAccount>>>(const Idle<List<PayoutAccount>>());
  final Rxn<ApiFailure> actionFailure = Rxn<ApiFailure>();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    state.value = const Loading<List<PayoutAccount>>();
    try {
      state.value = Success<List<PayoutAccount>>(
        await _account.listPayoutAccounts(),
      );
    } on ApiFailure catch (failure) {
      state.value = Failure<List<PayoutAccount>>(failure);
    }
  }

  Future<bool> create(Map<String, Object?> values) async {
    actionFailure.value = null;
    try {
      await _account.createPayoutAccount(values);
      await load();
      return state.value is Success<List<PayoutAccount>>;
    } on ApiFailure catch (failure) {
      actionFailure.value = failure;
      return false;
    }
  }

  Future<bool> updateAccount(int id, Map<String, Object?> values) async {
    actionFailure.value = null;
    try {
      await _account.updatePayoutAccount(id, values);
      await load();
      return state.value is Success<List<PayoutAccount>>;
    } on ApiFailure catch (failure) {
      actionFailure.value = failure;
      return false;
    }
  }

  Future<bool> delete(int id) async {
    actionFailure.value = null;
    try {
      await _account.deletePayoutAccount(id);
      await load();
      return state.value is Success<List<PayoutAccount>>;
    } on ApiFailure catch (failure) {
      actionFailure.value = failure;
      return false;
    }
  }
}
