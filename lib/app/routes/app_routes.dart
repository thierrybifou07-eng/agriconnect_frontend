import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const legal = '/legal';
  static const supplier = '/supplier';
  static const buyer = '/buyer';
  static const driver = '/driver';
  static const staff = '/staff';
  static const admin = '/admin';

  static String homeFor(AuthUser user) => switch (user.role) {
    RoleCode.supplier => supplier,
    RoleCode.buyer => buyer,
    RoleCode.driver => driver,
    RoleCode.agent => staff,
    RoleCode.admin || RoleCode.root => admin,
    RoleCode.unknown => login,
  };
}
