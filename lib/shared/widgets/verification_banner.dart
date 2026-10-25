import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/auth/domain/profile_verification_status.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

class VerificationBanner extends StatelessWidget {
  const VerificationBanner({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final user = Get.find<AuthController>().currentUser;
    if (user == null ||
        (user.role != RoleCode.supplier && user.role != RoleCode.buyer)) {
      return const SizedBox.shrink();
    }
    final localizations = AppLocalizations.of(context);
    final message = switch (user.profileVerificationStatus) {
      ProfileVerificationStatus.unverified =>
        localizations.accountVerificationUnverified,
      ProfileVerificationStatus.pending =>
        localizations.accountVerificationPending,
      ProfileVerificationStatus.rejected =>
        localizations.accountVerificationRejected,
      ProfileVerificationStatus.verified ||
      ProfileVerificationStatus.unknown => null,
    };
    if (message == null) return const SizedBox.shrink();
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.documents),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.verified_user_outlined),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  });
}
