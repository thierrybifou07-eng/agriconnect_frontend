import 'package:get/get.dart';

import 'package:agri_connect/core/localization/locale_controller.dart';
import 'package:agri_connect/core/storage/prefs_storage.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_page_controllers.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SplashController(
        Get.find<AuthController>(),
        Get.find<PrefsStorage>(),
      ),
    );
  }
}

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => OnboardingController(
        Get.find<PrefsStorage>(),
        Get.find<LocaleController>(),
      ),
    );
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginPageController(Get.find<AuthController>()));
  }
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => RegisterPageController(
        Get.find<AuthController>(),
        Get.find<PrefsStorage>(),
      ),
    );
  }
}

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForgotPasswordController(Get.find<AuthController>()));
  }
}

class LegalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => LegalPageController(
        Get.find<AuthRepository>(),
        Get.find<LocaleController>(),
      ),
    );
  }
}
