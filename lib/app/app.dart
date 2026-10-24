import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _MigrationPage(),
    );
  }
}

class _MigrationPage extends StatelessWidget {
  const _MigrationPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AppLocalizations.of(context).migrationInProgress),
      ),
    );
  }
}
