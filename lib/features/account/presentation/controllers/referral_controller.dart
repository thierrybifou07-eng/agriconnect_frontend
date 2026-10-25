import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/account/domain/account_entities.dart';
import 'package:agri_connect/features/account/domain/account_repository.dart';

class ReferralController extends GetxController {
  ReferralController(this._account);

  final AccountRepository _account;
  final Rx<UiState<ReferralSummary>> state = Rx<UiState<ReferralSummary>>(
    const Idle<ReferralSummary>(),
  );

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    state.value = const Loading<ReferralSummary>();
    try {
      state.value = Success<ReferralSummary>(await _account.referral());
    } on ApiFailure catch (failure) {
      state.value = Failure<ReferralSummary>(failure);
    }
  }
}
