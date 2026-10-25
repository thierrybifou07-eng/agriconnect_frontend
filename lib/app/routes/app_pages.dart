import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/app/routes/middlewares/auth_middleware.dart';
import 'package:agri_connect/app/routes/middlewares/role_middleware.dart';
import 'package:agri_connect/core/config/app_env.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/bindings/auth_page_bindings.dart';
import 'package:agri_connect/features/auth/presentation/pages/auth_pages.dart';
import 'package:agri_connect/shared/widgets/role_placeholder_page.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => AppEnv.isConfigured
          ? const SplashPage()
          : const _ConfigurationMissingPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      middlewares: [GuestMiddleware()],
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      middlewares: [GuestMiddleware()],
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      middlewares: [GuestMiddleware()],
      page: () => const ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.legal,
      page: () => const _PlaceholderPage(title: _PageTitle.legal),
    ),
    GetPage(
      name: '${AppRoutes.legal}/:code',
      page: () => const LegalPage(),
      binding: LegalBinding(),
    ),
    _rolePage(AppRoutes.supplier, RoleCode.supplier),
    _rolePage(AppRoutes.buyer, RoleCode.buyer),
    _rolePage(AppRoutes.driver, RoleCode.driver),
    _rolePage(AppRoutes.staff, RoleCode.agent),
    _rolePage(AppRoutes.admin, RoleCode.admin, RoleCode.root),
  ];

  static final unknownRoute = GetPage<dynamic>(
    name: '/not-found',
    page: () => const _NotFoundPage(),
  );

  static GetPage<dynamic> _rolePage(
    String route,
    RoleCode role, [
    RoleCode? additionalRole,
  ]) {
    return GetPage(
      name: route,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({role, ?additionalRole}),
      ],
      page: () => RolePlaceholderPage(role: role),
    );
  }
}

enum _PageTitle { splash, onboarding, login, register, forgotPassword, legal }

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final _PageTitle title;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final label = switch (title) {
      _PageTitle.splash => localizations.splashLoading,
      _PageTitle.onboarding => localizations.onboardingPageTitle,
      _PageTitle.login => localizations.loginPageTitle,
      _PageTitle.register => localizations.registerPageTitle,
      _PageTitle.forgotPassword => localizations.forgotPasswordPageTitle,
      _PageTitle.legal => localizations.legalPageTitle,
    };
    return Scaffold(body: Center(child: Text(label)));
  }
}

class _ConfigurationMissingPage extends StatelessWidget {
  const _ConfigurationMissingPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          AppLocalizations.of(context).configurationMissing,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text(AppLocalizations.of(context).pageNotFound)),
  );
}
