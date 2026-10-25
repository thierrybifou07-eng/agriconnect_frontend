import 'package:get/get.dart';

import 'package:agri_connect/core/localization/locale_controller.dart';

class AccountLanguageController extends GetxController {
  AccountLanguageController(this._locale);

  final LocaleController _locale;

  String get language => _locale.locale.value.languageCode;

  Future<void> select(String language) => _locale.changeLocale(language);
}
