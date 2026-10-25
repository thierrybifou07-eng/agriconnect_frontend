import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

class RoleMiddleware extends GetMiddleware {
  RoleMiddleware(this.allowedRoles);

  final Set<RoleCode> allowedRoles;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: AppRoutes.login);
    }
    final user = Get.find<AuthController>().currentUser;
    if (user == null) return const RouteSettings(name: AppRoutes.login);
    if (!allowedRoles.contains(user.role)) {
      return RouteSettings(name: AppRoutes.homeFor(user));
    }
    return null;
  }
}
