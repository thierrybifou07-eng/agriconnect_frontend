import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/app_binding.dart';
import 'package:agri_connect/app/routes/app_pages.dart';
import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/app/theme/app_theme.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';

class AgriConnectApp extends StatelessWidget {
  const AgriConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      initialBinding: AppBinding(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fr'),
      getPages: AppPages.pages,
      unknownRoute: AppPages.unknownRoute,
    );
  }
}
