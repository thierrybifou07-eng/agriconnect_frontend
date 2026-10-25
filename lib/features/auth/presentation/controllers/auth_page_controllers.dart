import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/locale_controller.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/storage/prefs_storage.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

class SplashController extends GetxController {
  SplashController(this._auth, this._prefs);

  final AuthController _auth;
  final PrefsStorage _prefs;
  final RxBool loading = false.obs;
  final RxBool hasError = false.obs;

  static const _startupTimeout = Duration(seconds: 45);
  static const _storageTimeout = Duration(seconds: 10);

  @override
  void onReady() {
    super.onReady();
    unawaited(restoreSession());
  }

  Future<void> restoreSession() async {
    if (loading.value) return;
    loading.value = true;
    hasError.value = false;
    try {
      final user = await _auth.restoreSession().timeout(_startupTimeout);
      if (user != null) {
        await Get.offAllNamed(AppRoutes.homeFor(user));
        return;
      }
      final onboardingSeen = await _prefs.readOnboardingSeen().timeout(
        _storageTimeout,
      );
      await Get.offAllNamed(
        onboardingSeen ? AppRoutes.login : AppRoutes.onboarding,
      );
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to restore the application session: $error');
      debugPrintStack(stackTrace: stackTrace);
      hasError.value = true;
    } finally {
      loading.value = false;
    }
  }

  Future<void> continueToLogin() async {
    await Get.offAllNamed(AppRoutes.login);
  }
}

class OnboardingController extends GetxController {
  OnboardingController(this._prefs, this._locale);

  final PrefsStorage _prefs;
  final LocaleController _locale;
  final Rx<RoleCode> selectedRole = RoleCode.supplier.obs;

  @override
  void onInit() {
    super.onInit();
    _restoreRole();
  }

  Future<void> _restoreRole() async {
    final saved = await _prefs.readRegistrationRole();
    final role = RoleCode.parse(saved);
    selectedRole.value = role == RoleCode.buyer
        ? RoleCode.buyer
        : RoleCode.supplier;
  }

  Future<void> chooseRole(RoleCode role) async {
    if (role != RoleCode.supplier && role != RoleCode.buyer) return;
    selectedRole.value = role;
    await _prefs.saveRegistrationRole(role.name.toUpperCase());
  }

  Future<void> continueToRegister() async {
    await _prefs.saveOnboardingSeen(true);
    await Get.toNamed(AppRoutes.register);
  }

  Future<void> chooseLanguage(String language) =>
      _locale.changeLocale(language);
}

class LoginPageController extends GetxController {
  LoginPageController(this.auth);

  final AuthController auth;
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  bool get loading => auth.authState.value is Loading<void>;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    await auth.signIn(email.text.trim(), password.text);
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}

class RegisterPageController extends GetxController {
  RegisterPageController(this.auth, this._prefs);

  final AuthController auth;
  final PrefsStorage _prefs;
  final formKey = GlobalKey<FormState>();
  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final referralCode = TextEditingController();
  final location = TextEditingController();
  final farmName = TextEditingController();
  final businessName = TextEditingController();
  final Rx<RoleCode> role = RoleCode.supplier.obs;
  final RxString buyerType = 'RETAILER'.obs;
  final RxBool acceptedGeneralTerms = false.obs;
  final RxBool acceptedRoleTerms = false.obs;
  final RxBool termsError = false.obs;
  final RxString passwordValue = ''.obs;

  bool get loading => auth.authState.value is Loading<void>;
  bool get acceptedTerms =>
      acceptedGeneralTerms.value && acceptedRoleTerms.value;

  @override
  void onInit() {
    super.onInit();
    _restoreRole();
  }

  Future<void> _restoreRole() async {
    final saved = RoleCode.parse(await _prefs.readRegistrationRole());
    role.value = saved == RoleCode.buyer ? RoleCode.buyer : RoleCode.supplier;
  }

  void selectRole(RoleCode value) {
    if (value == RoleCode.supplier || value == RoleCode.buyer) {
      role.value = value;
      unawaited(_prefs.saveRegistrationRole(value.name.toUpperCase()));
    }
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!acceptedTerms) {
      termsError.value = true;
      return;
    }
    termsError.value = false;
    final payload = <String, Object?>{
      'firstname': firstname.text.trim(),
      'lastname': lastname.text.trim(),
      'phone': phone.text.trim(),
      'email': email.text.trim(),
      'password': password.text,
      'role': role.value.name.toUpperCase(),
      'acceptTerms': true,
      if (referralCode.text.trim().isNotEmpty)
        'referralCode': referralCode.text.trim(),
      if (location.text.trim().isNotEmpty) 'location': location.text.trim(),
      if (role.value == RoleCode.supplier) 'farmName': farmName.text.trim(),
      if (role.value == RoleCode.buyer) ...{
        'buyerType': buyerType.value,
        if (businessName.text.trim().isNotEmpty)
          'businessName': businessName.text.trim(),
      },
    };
    await auth.signUp(payload);
  }

  @override
  void onClose() {
    firstname.dispose();
    lastname.dispose();
    phone.dispose();
    email.dispose();
    password.dispose();
    referralCode.dispose();
    location.dispose();
    farmName.dispose();
    businessName.dispose();
    super.onClose();
  }
}

class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this.auth);

  final AuthController auth;
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final RxBool loading = false.obs;
  final RxBool submitted = false.obs;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    loading.value = true;
    await auth.requestPasswordReset(email.text.trim());
    submitted.value = true;
    loading.value = false;
  }

  @override
  void onClose() {
    email.dispose();
    super.onClose();
  }
}

class LegalPageController extends GetxController {
  LegalPageController(this._repository, this._locale);

  final AuthRepository _repository;
  final LocaleController _locale;
  final Rxn<LegalDocument> document = Rxn<LegalDocument>();
  final Rxn<ApiFailure> failure = Rxn<ApiFailure>();
  final RxBool loading = true.obs;
  final RxBool notFound = false.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    loading.value = true;
    failure.value = null;
    final code = Get.parameters['code'] ?? '';
    final language = _locale.locale.value.languageCode;
    try {
      document.value = await _repository.getLegal(code, language);
      notFound.value = false;
    } on ApiFailure catch (error) {
      notFound.value = error.status == 404;
      failure.value = error.status == 404 ? null : error;
    } finally {
      loading.value = false;
    }
  }
}
