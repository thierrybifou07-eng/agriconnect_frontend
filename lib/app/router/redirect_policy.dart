import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/features/auth/application/auth_state.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/onboarding/application/welcome_state.dart';

/// Centralized navigation guard of the platform.
///
/// This is the single place that decides where a request may go. It combines
/// the four policy layers as a pure function of the current [AuthState] and
/// [WelcomeState], so it is unit-testable without a router:
///
///  - AuthGuard — anonymous sessions stay inside the public shell and can
///    never reach a workspace;
///  - SessionGuard — an expired session is sent back to sign-in;
///  - RoleGuard — every request maps to the workspace of the role that owns
///    its URL prefix, and a role only sees its own workspace;
///  - RedirectPolicy — the convergence rules above, with the splash as the
///    busy state for both session restore and welcome loading, and a settled
///    terminal state for every combination, so no request loops.
///
/// The router keeps the side effects (clearing an expired persisted session);
/// this class only *returns* where to go next, and `null` means "stay".
class RedirectPolicy {
  RedirectPolicy({required this.auth, required this.welcome});

  final AuthState auth;
  final WelcomeState welcome;

  /// Where [location] must go, or `null` when it is already allowed.
  String? resolve(String location) {
    switch (auth.status) {
      case AuthStatus.initial:
        return location == RoutePaths.splash ? null : RoutePaths.splash;
      case AuthStatus.authenticated:
        // An expired session is sent back to sign-in. The login stays allowed
        // once it is reached: returning login from the login itself would keep
        // redirecting forever, so the policy settles here and the router's side
        // effect clears the persisted session.
        if (auth.isExpired) {
          return location == RoutePaths.login ? null : RoutePaths.login;
        }
        final role = auth.user!.role;
        if (isPublicLocation(location)) return role.homePath;
        return belongsToRole(location, role) ? null : role.homePath;
      case AuthStatus.unauthenticated:
        if (welcome.isLoading) {
          return location == RoutePaths.splash ? null : RoutePaths.splash;
        }
        if (!welcome.onboardingCompleted) {
          return location == RoutePaths.onboarding
              ? null
              : RoutePaths.onboarding;
        }
        if (welcome.languageCode == null) {
          return location == RoutePaths.language ? null : RoutePaths.language;
        }
        if (welcome.selectedRole == null) {
          if (location == RoutePaths.login) return null;
          return location == RoutePaths.role ? null : RoutePaths.role;
        }
        if (isAuthLocation(location)) return null;
        return RoutePaths.login;
    }
  }

  /// Whether [location] is reachable without a session (splash, welcome and
  /// the sign-in routes).
  static bool isPublicLocation(String location) =>
      location == RoutePaths.splash ||
      isWelcomeLocation(location) ||
      isAuthLocation(location);

  static bool isWelcomeLocation(String location) =>
      location == RoutePaths.onboarding ||
      location == RoutePaths.language ||
      location == RoutePaths.role;

  static bool isAuthLocation(String location) =>
      location == RoutePaths.login || location == RoutePaths.register;

  /// Whether [location] lives under the workspace of [role].
  ///
  /// A prefix match is intentionally broad: an address under the prefix that
  /// matches no declared sub-route stays under the role guard and falls to the
  /// router's not-found page instead of being redirected away.
  static bool belongsToRole(String location, UserRole role) {
    final prefix = role.routePrefix;
    return location == prefix || location.startsWith('$prefix/');
  }
}
