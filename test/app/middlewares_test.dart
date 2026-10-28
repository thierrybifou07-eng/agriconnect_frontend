import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/app/routes/middlewares/auth_middleware.dart';
import 'package:agri_connect/app/routes/middlewares/capability_middleware.dart';
import 'package:agri_connect/app/routes/middlewares/role_middleware.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/agent_capability.dart';
import 'package:agri_connect/features/auth/domain/profile_verification_status.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

import '../features/auth/fake_auth_repository.dart';
import '../support/get_test_harness.dart';

void main() {
  setupGetTestHarness();

  test('authentication middleware sends a guest to login', () {
    expect(
      AuthMiddleware().redirect(AppRoutes.supplier)?.name,
      AppRoutes.login,
    );
  });

  test('role middleware redirects an authenticated user to their own home', () {
    final controller = AuthController(
      tokenStorage: InMemoryTokenStorage(),
      sessionEvents: SessionEvents(),
      repository: FakeAuthRepository(),
    );
    Get.put<AuthController>(controller);
    controller.setUser(_buyer());

    expect(AuthMiddleware().redirect(AppRoutes.buyer), isNull);
    expect(
      RoleMiddleware({RoleCode.supplier}).redirect(AppRoutes.supplier)?.name,
      AppRoutes.buyer,
    );
  });

  test(
    'capability middleware protects each staff operation with an OR set',
    () {
      final controller = AuthController(
        tokenStorage: InMemoryTokenStorage(),
        sessionEvents: SessionEvents(),
        repository: FakeAuthRepository(),
      );
      Get.put<AuthController>(controller);
      controller.setUser(
        AuthUser(
          role: RoleCode.agent,
          agent: AgentInfo(capabilities: const [AgentCapability.buyerSupport]),
        ),
      );

      expect(
        CapabilityMiddleware({
          AgentCapability.buyerSupport,
          AgentCapability.supplierSupport,
        }).redirect(AppRoutes.staffConversations),
        isNull,
      );
      expect(
        CapabilityMiddleware({AgentCapability.stockValidation})
            .redirect(AppRoutes.staffLots)
            ?.name,
        AppRoutes.staff,
      );
    },
  );
}

AuthUser _buyer() => const AuthUser(
  id: 1,
  firstname: 'Buyer',
  lastname: 'One',
  email: 'buyer@example.test',
  phone: '+237600000000',
  role: RoleCode.buyer,
  roleLabel: 'Buyer',
  emailVerified: true,
  profileVerificationStatus: ProfileVerificationStatus.verified,
);
