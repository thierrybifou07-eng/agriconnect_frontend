import 'package:get/get.dart';

import 'package:agri_connect/core/localization/locale_controller.dart';
import 'package:agri_connect/features/account/domain/account_repository.dart';
import 'package:agri_connect/features/account/presentation/controllers/language_controller.dart';
import 'package:agri_connect/features/account/presentation/controllers/payout_accounts_controller.dart';
import 'package:agri_connect/features/account/presentation/controllers/profile_controller.dart';
import 'package:agri_connect/features/account/presentation/controllers/referral_controller.dart';
import 'package:agri_connect/features/account/presentation/controllers/sessions_controller.dart';
import 'package:agri_connect/features/account/presentation/controllers/verification_documents_controller.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ProfileController(
        Get.find<AuthController>(),
        Get.find<AccountRepository>(),
        Get.find<ReferenceRepository>(),
      ),
    );
  }
}

class VerificationDocumentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => VerificationDocumentsController(
        Get.find<AccountRepository>(),
        Get.find<AuthController>(),
      ),
    );
  }
}

class PayoutAccountsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PayoutAccountsController(Get.find<AccountRepository>()));
  }
}

class ReferralBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReferralController(Get.find<AccountRepository>()));
  }
}

class SessionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SessionsController(
        Get.find<AuthController>(),
        Get.find<AuthRepository>(),
      ),
    );
  }
}

class AccountLanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AccountLanguageController(Get.find<LocaleController>()));
  }
}
