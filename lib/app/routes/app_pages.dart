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
import 'package:agri_connect/features/account/presentation/bindings/account_bindings.dart';
import 'package:agri_connect/features/account/presentation/pages/account_pages.dart';
import 'package:agri_connect/features/account/presentation/pages/profile_page.dart';
import 'package:agri_connect/features/account/presentation/pages/verification_documents_page.dart';
import 'package:agri_connect/shared/widgets/role_placeholder_page.dart';
import 'package:agri_connect/features/chat/presentation/bindings/chat_bindings.dart';
import 'package:agri_connect/features/chat/presentation/pages/chat_pages.dart';
import 'package:agri_connect/features/notifications/presentation/pages/notifications_page.dart';
import 'package:agri_connect/features/buyer/presentation/bindings/buyer_bindings.dart';
import 'package:agri_connect/features/buyer/presentation/pages/buyer_pages.dart';
import 'package:agri_connect/features/supplier/presentation/bindings/supplier_bindings.dart';
import 'package:agri_connect/features/supplier/presentation/pages/lot_draft_page.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_home_page.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_lot_detail_page.dart';
import 'package:agri_connect/features/driver/presentation/bindings/driver_binding.dart';
import 'package:agri_connect/features/driver/presentation/pages/driver_delivery_detail_page.dart';
import 'package:agri_connect/features/driver/presentation/pages/driver_page.dart';

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
    GetPage(
      name: AppRoutes.profile,
      middlewares: [AuthMiddleware()],
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.documents,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({RoleCode.supplier, RoleCode.buyer}),
      ],
      page: () => const VerificationDocumentsPage(),
      binding: VerificationDocumentsBinding(),
    ),
    GetPage(
      name: AppRoutes.payoutAccounts,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({RoleCode.supplier, RoleCode.buyer}),
      ],
      page: () => const PayoutAccountsPage(),
      binding: PayoutAccountsBinding(),
    ),
    GetPage(
      name: AppRoutes.referral,
      middlewares: [AuthMiddleware()],
      page: () => const ReferralPage(),
      binding: ReferralBinding(),
    ),
    GetPage(
      name: AppRoutes.sessions,
      middlewares: [AuthMiddleware()],
      page: () => const SessionsPage(),
      binding: SessionsBinding(),
    ),
    GetPage(
      name: AppRoutes.language,
      middlewares: [AuthMiddleware()],
      page: () => const AccountLanguagePage(),
      binding: AccountLanguageBinding(),
    ),
    GetPage(
      name: AppRoutes.conversations,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({RoleCode.buyer, RoleCode.supplier}),
      ],
      page: () => const ConversationsPage(),
      binding: ConversationsBinding(),
    ),
    GetPage(
      name: AppRoutes.chatThread,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({RoleCode.buyer, RoleCode.supplier}),
      ],
      page: () => const ChatThreadPage(),
      binding: ThreadBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      middlewares: [AuthMiddleware()],
      page: () => const NotificationsPage(),
    ),
    GetPage(
      name: AppRoutes.buyerListingDetail,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({RoleCode.buyer}),
      ],
      page: () => const ListingDetailPage(),
      binding: ListingDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.buyerOrderDetail,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({RoleCode.buyer}),
      ],
      page: () => const BuyerOrderDetailPage(),
      binding: BuyerOrderDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.driver,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({RoleCode.driver}),
      ],
      page: () => const DriverPage(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: AppRoutes.driverDeliveryDetail,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({RoleCode.driver}),
      ],
      page: () => const DriverDeliveryDetailPage(),
      binding: DriverDeliveryDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.supplier,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({RoleCode.supplier}),
      ],
      page: () => const SupplierHomePage(),
      binding: SupplierBinding(),
    ),
    GetPage(
      name: AppRoutes.supplierLotNew,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({RoleCode.supplier}),
      ],
      page: () => const LotDraftPage(),
      binding: LotDraftBinding(),
    ),
    GetPage(
      name: AppRoutes.supplierLotDetailRoute,
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware({RoleCode.supplier}),
      ],
      page: () => const SupplierLotDetailPage(),
      binding: SupplierLotDetailBinding(),
    ),
    _rolePage(AppRoutes.buyer, RoleCode.buyer),
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
      binding: role == RoleCode.buyer
          ? BuyerBinding()
          : role == RoleCode.supplier
          ? ConversationsBinding()
          : null,
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
