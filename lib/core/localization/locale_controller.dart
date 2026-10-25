import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:agri_connect/core/storage/prefs_storage.dart';

class LocaleController extends GetxController {
  LocaleController(this._prefsStorage);

  final PrefsStorage _prefsStorage;
  final Rx<Locale> locale = const Locale('fr').obs;

  @override
  void onInit() {
    super.onInit();
    _restoreLocale();
  }

  Future<void> _restoreLocale() async {
    final saved = await _prefsStorage.readLanguage();
    switch (saved) {
      case 'fr':
        await changeLocale('fr', persist: false);
      case 'en':
        await changeLocale('en', persist: false);
    }
  }

  Future<void> changeLocale(String language, {bool persist = true}) async {
    if (language != 'fr' && language != 'en') {
      throw ArgumentError.value(language, 'language', 'Unsupported locale');
    }
    locale.value = Locale(language);
    Intl.defaultLocale = language;
    await Get.updateLocale(locale.value);
    if (persist) await _prefsStorage.saveLanguage(language);
  }
}
