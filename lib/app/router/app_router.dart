import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/app/router/redirect_policy.dart';
import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/features/admin/application/admin_providers.dart';
import 'package:agri_connect/features/admin/presentation/admin_analytics_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_dashboard_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_deliveries_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_orders_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_products_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_users_page.dart';
import 'package:agri_connect/features/agent/presentation/agent_dashboard_page.dart';
import 'package:agri_connect/features/agent/presentation/pages/agent_orders_page.dart';
import 'package:agri_connect/features/agent/presentation/pages/agent_payments_page.dart';
import 'package:agri_connect/features/agent/presentation/pages/agent_stock_page.dart';
import 'package:agri_connect/features/agent/presentation/pages/agent_support_page.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/application/auth_state.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/auth/presentation/pages/login_page.dart';
import 'package:agri_connect/features/auth/presentation/pages/register_page.dart';
import 'package:agri_connect/features/auth/presentation/pages/splash_page.dart';
import 'package:agri_connect/features/auth/presentation/widgets/role_profile_page.dart';
import 'package:agri_connect/features/buyer/presentation/buyer_dashboard_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/buyer_orders_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/cart_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/catalog_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/checkout_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/order_confirmation_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/order_detail_page.dart';
import 'package:agri_connect/features/buyer/presentation/pages/product_detail_page.dart';
import 'package:agri_connect/features/chat/presentation/chat_inbox_page.dart';
import 'package:agri_connect/features/chat/presentation/chat_thread_page.dart';
import 'package:agri_connect/features/driver/presentation/driver_dashboard_page.dart';
import 'package:agri_connect/features/driver/presentation/pages/driver_deliveries_page.dart';
import 'package:agri_connect/features/driver/presentation/pages/driver_delivery_detail_page.dart';
import 'package:agri_connect/features/driver/presentation/pages/driver_trips_page.dart';
import 'package:agri_connect/features/supplier/presentation/supplier_dashboard_page.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_order_detail_page.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_orders_page.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_product_detail_page.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_products_page.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_product_form_page.dart';
import 'package:agri_connect/features/onboarding/application/welcome_controller.dart';
import 'package:agri_connect/features/onboarding/application/welcome_state.dart';
import 'package:agri_connect/features/onboarding/presentation/pages/language_page.dart';
import 'package:agri_connect/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:agri_connect/features/onboarding/presentation/pages/role_page.dart';
import 'package:agri_connect/features/notifications/presentation/notifications_page.dart';
import 'package:agri_connect/features/super_admin/application/super_admin_providers.dart';
import 'package:agri_connect/features/super_admin/presentation/super_admin_analytics_page.dart';
import 'package:agri_connect/features/super_admin/presentation/super_admin_dashboard_page.dart';
import 'package:agri_connect/features/super_admin/presentation/super_admin_platform_page.dart';
import 'package:agri_connect/features/super_admin/presentation/super_admin_staff_page.dart';
import 'package:agri_connect/shared/widgets/role_shell.dart';
import 'package:agri_connect/shared/widgets/route_not_found_page.dart';
import 'package:agri_connect/shared/widgets/under_construction_page.dart';

// The agent config carries a closure (its under-construction dashboard), so
// the list cannot stay `const`.
final List<RoleShellConfig> _roleConfigs = [
  RoleShellConfig(
    role: UserRole.supplier,
    sections: [
      RoleSection.dashboard,
      RoleSection.products,
      RoleSection.orders,
      RoleSection.profile,
    ],
    dashboardBuilder: SupplierDashboardPage.new,
  ),
  RoleShellConfig(
    role: UserRole.buyer,
    sections: [
      RoleSection.dashboard,
      RoleSection.catalog,
      RoleSection.orders,
      RoleSection.profile,
    ],
    dashboardBuilder: BuyerDashboardPage.new,
  ),
  RoleShellConfig(
    role: UserRole.driver,
    sections: [
      RoleSection.dashboard,
      RoleSection.deliveries,
      RoleSection.trips,
      RoleSection.profile,
    ],
    dashboardBuilder: DriverDashboardPage.new,
  ),
  RoleShellConfig(
    role: UserRole.agent,
    // The four operational capabilities are offered as their own sections; the
    // shell keeps only the ones the session actually holds, so an agent without
    // stock validation never sees its tab.
    sections: [
      RoleSection.dashboard,
      RoleSection.buyerSupport,
      RoleSection.stockValidation,
      RoleSection.orderProcessing,
      RoleSection.paymentFollowup,
      RoleSection.profile,
    ],
    dashboardBuilder: AgentDashboardPage.new,
  ),
  RoleShellConfig(
    role: UserRole.admin,
    sections: [
      RoleSection.dashboard,
      RoleSection.products,
      RoleSection.orders,
      RoleSection.users,
      RoleSection.deliveries,
      RoleSection.analytics,
      RoleSection.profile,
    ],
    dashboardBuilder: AdminDashboardPage.new,
  ),
  RoleShellConfig(
    role: UserRole.root,
    sections: [
      RoleSection.dashboard,
      RoleSection.users,
      RoleSection.platform,
      RoleSection.analytics,
      RoleSection.profile,
    ],
    dashboardBuilder: SuperAdminDashboardPage.new,
  ),
];

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) => _resolveRedirect(ref, state),
    // An address that passes the role guard but matches no declared sub-route
    // (e.g. `/supplier/bogus`) lands here, on a localized page with a way out,
    // instead of a bare error screen or a redirect loop.
    errorBuilder: (context, state) => const RouteNotFoundPage(),
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (_, _) => const SplashPage()),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(
        path: RoutePaths.language,
        builder: (_, _) => const LanguagePage(),
      ),
      GoRoute(path: RoutePaths.role, builder: (_, _) => const RolePage()),
      GoRoute(path: RoutePaths.login, builder: (_, _) => const LoginPage()),
      GoRoute(
        path: RoutePaths.register,
        builder: (_, _) => const RegisterPage(),
      ),
      for (final role in UserRole.values)
        GoRoute(
          path: '${role.routePrefix}/notifications',
          builder: (_, _) => const NotificationsPage(),
        ),
      for (final config in _roleConfigs) _roleShellRoute(ref, config),
      GoRoute(
        path: RoutePaths.supplierProductNew,
        builder: (_, _) => const SupplierProductFormPage(),
      ),
      GoRoute(
        path: RoutePaths.supplierProductDetail,
        builder: (_, state) => SupplierProductDetailPage(
          productId: state.pathParameters['productId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.supplierProductEdit,
        builder: (_, state) => SupplierProductFormPage(
          productId: state.pathParameters['productId'],
        ),
      ),
      GoRoute(
        path: RoutePaths.supplierOrderDetail,
        builder: (_, state) =>
            SupplierOrderDetailPage(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: RoutePaths.supplierMessages,
        builder: (_, _) =>
            const ChatInboxPage(backPath: RoutePaths.supplierHome),
      ),
      GoRoute(
        path: RoutePaths.supplierConversation,
        builder: (_, state) => ChatThreadPage(
          conversationId: state.pathParameters['conversationId']!,
          backPath: RoutePaths.supplierMessages,
        ),
      ),
      GoRoute(
        path: RoutePaths.buyerProductDetail,
        builder: (_, state) =>
            ProductDetailPage(productId: state.pathParameters['productId']!),
      ),
      GoRoute(path: RoutePaths.buyerCart, builder: (_, _) => const CartPage()),
      GoRoute(
        path: RoutePaths.buyerCheckout,
        builder: (_, _) => const CheckoutPage(),
      ),
      GoRoute(
        path: RoutePaths.buyerOrderDetail,
        builder: (_, state) =>
            OrderDetailPage(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: RoutePaths.buyerOrderConfirmationDetail,
        builder: (_, state) =>
            OrderConfirmationPage(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: RoutePaths.buyerMessages,
        builder: (_, _) => const ChatInboxPage(
          threadPathBuilder: RoutePaths.buyerMessageThread,
          backPath: RoutePaths.buyerHome,
        ),
      ),
      GoRoute(
        path: RoutePaths.buyerConversation,
        builder: (_, state) => ChatThreadPage(
          conversationId: state.pathParameters['conversationId']!,
          backPath: RoutePaths.buyerMessages,
        ),
      ),
      GoRoute(
        path: RoutePaths.driverDeliveryDetail,
        builder: (_, state) => DriverDeliveryDetailPage(
          deliveryId: state.pathParameters['deliveryId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.driverMessages,
        builder: (_, _) => const ChatInboxPage(
          threadPathBuilder: RoutePaths.driverMessageThread,
          backPath: RoutePaths.driverHome,
        ),
      ),
      GoRoute(
        path: RoutePaths.driverConversation,
        builder: (_, state) => ChatThreadPage(
          conversationId: state.pathParameters['conversationId']!,
          backPath: RoutePaths.driverMessages,
        ),
      ),
    ],
  );

  final subscription = ref.listen<AuthState>(authControllerProvider, (
    previous,
    next,
  ) {
    // A session that just fell past its expiry signs itself out; the
    // resulting unauthenticated state refreshes the router towards login.
    if (next.status == AuthStatus.authenticated && next.isExpired) {
      unawaited(ref.read(authControllerProvider.notifier).signOut());
      return;
    }
    router.refresh();
  });
  final welcomeSubscription = ref.listen<WelcomeState>(
    welcomeControllerProvider,
    (_, _) => router.refresh(),
  );
  ref.onDispose(() {
    subscription.close();
    welcomeSubscription.close();
    router.dispose();
  });
  return router;
});

StatefulShellRoute _roleShellRoute(Ref ref, RoleShellConfig config) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        RoleShell(config: config, navigationShell: navigationShell),
    branches: [
      for (final section in config.sections)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '${config.role.routePrefix}/${section.routeName}',
              builder: (context, state) =>
                  _sectionPage(ref, config, section, context),
            ),
          ],
        ),
    ],
  );
}

Widget _sectionPage(
  Ref ref,
  RoleShellConfig config,
  RoleSection section,
  BuildContext context,
) {
  if (section == RoleSection.dashboard) return config.dashboardBuilder();
  if (section == RoleSection.profile) return const RoleProfilePage();
  if (config.role == UserRole.supplier && section == RoleSection.products) {
    return const SupplierProductsPage();
  }
  if (config.role == UserRole.supplier && section == RoleSection.orders) {
    return const SupplierOrdersPage();
  }
  if (config.role == UserRole.buyer && section == RoleSection.catalog) {
    return const CatalogPage();
  }
  if (config.role == UserRole.buyer && section == RoleSection.orders) {
    return const BuyerOrdersPage();
  }
  if (config.role == UserRole.driver && section == RoleSection.deliveries) {
    return const DriverDeliveriesPage();
  }
  if (config.role == UserRole.driver && section == RoleSection.trips) {
    return const DriverTripsPage();
  }
  if (config.role == UserRole.agent && section == RoleSection.buyerSupport) {
    return const AgentSupportPage();
  }
  if (config.role == UserRole.agent && section == RoleSection.stockValidation) {
    return const AgentStockPage();
  }
  if (config.role == UserRole.agent && section == RoleSection.orderProcessing) {
    return const AgentOrdersPage();
  }
  if (config.role == UserRole.agent && section == RoleSection.paymentFollowup) {
    return const AgentPaymentsPage();
  }
  if (config.role == UserRole.admin && section == RoleSection.users) {
    return AdminUsersPage(repository: ref.read(adminRepositoryProvider));
  }
  if (config.role == UserRole.admin && section == RoleSection.products) {
    return AdminProductsPage(
      repository: ref.read(adminRepositoryProvider),
      capabilities:
          ref.read(authControllerProvider).user?.capabilities ?? const {},
    );
  }
  if (config.role == UserRole.admin && section == RoleSection.deliveries) {
    return AdminDeliveriesPage(repository: ref.read(adminRepositoryProvider));
  }
  if (config.role == UserRole.admin && section == RoleSection.orders) {
    return AdminOrdersPage(repository: ref.read(adminRepositoryProvider));
  }
  if (config.role == UserRole.admin && section == RoleSection.analytics) {
    return AdminAnalyticsPage(repository: ref.read(adminRepositoryProvider));
  }
  // The Root console reads the repository once here and hands the same
  // instance to the section, so a write made on one screen is visible on the
  // next without the two sections disagreeing mid-session.
  if (config.role == UserRole.root && section == RoleSection.users) {
    return SuperAdminStaffPage(
      repository: ref.read(superAdminRepositoryProvider),
      currentUserId: ref.read(authControllerProvider).user?.id,
    );
  }
  if (config.role == UserRole.root && section == RoleSection.platform) {
    return SuperAdminPlatformPage(
      repository: ref.read(superAdminRepositoryProvider),
    );
  }
  if (config.role == UserRole.root && section == RoleSection.analytics) {
    return SuperAdminAnalyticsPage(
      repository: ref.read(superAdminRepositoryProvider),
    );
  }
  return UnderConstructionPage(section: section);
}

/// Routes against the centralized [RedirectPolicy].
///
/// The policy is pure and decides the destination; the router keeps the side
/// effects, here clearing an expired persisted session in the background while
/// the session guard sends the user back to sign-in.
String? _resolveRedirect(Ref ref, GoRouterState state) {
  final auth = ref.read(authControllerProvider);
  if (auth.status == AuthStatus.authenticated && auth.isExpired) {
    unawaited(ref.read(authControllerProvider.notifier).signOut());
  }
  return RedirectPolicy(
    auth: auth,
    welcome: ref.read(welcomeControllerProvider),
  ).resolve(state.matchedLocation);
}
