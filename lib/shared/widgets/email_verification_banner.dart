import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  State<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner>
    with WidgetsBindingObserver {
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(Get.find<AuthController>().refreshUser());
    }
  }

  Future<void> _resend() async {
    setState(() => _sending = true);
    final l10n = AppLocalizations.of(context);
    try {
      await Get.find<AuthController>().resendVerification();
      AppNotifier.success(l10n.authVerificationSent);
    } on ApiFailure catch (failure) {
      if (failure.status == 429) {
        AppNotifier.info(l10n.authVerificationWait);
      } else {
        AppNotifier.error(AppNotifier.failureMessage(failure, l10n));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final user = Get.find<AuthController>().currentUser;
    if (user == null || user.emailVerified != false) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.mark_email_unread_outlined),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.authEmailUnverified)),
            TextButton(
              onPressed: _sending ? null : _resend,
              child: _sending
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.authResendVerification),
            ),
          ],
        ),
      ),
    );
  });
}
