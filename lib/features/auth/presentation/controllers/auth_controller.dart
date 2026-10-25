import 'dart:async';

import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

class AuthController extends GetxController {
  AuthController({required this.tokenStorage, required this.sessionEvents});

  final TokenStorage tokenStorage;
  final SessionEvents sessionEvents;
  final Rxn<AuthUser> user = Rxn<AuthUser>();
  StreamSubscription<SessionEnded>? _sessionSubscription;

  bool get isAuthenticated => user.value != null;
  RoleCode? get role => user.value?.role;
  AuthUser? get currentUser => user.value;

  @override
  void onInit() {
    super.onInit();
    _sessionSubscription = sessionEvents.stream.listen(_onSessionEnded);
  }

  void setUser(AuthUser? value) => user.value = value;

  Future<void> signOutLocal() async {
    await tokenStorage.clear();
    user.value = null;
  }

  void _onSessionEnded(SessionEnded event) {
    unawaited(_handleSessionEnded(event));
  }

  Future<void> _handleSessionEnded(SessionEnded event) async {
    final context = Get.context;
    if (context == null) {
      throw StateError('A session ended without an active application context');
    }
    final localizations = AppLocalizations.of(context);
    final message = switch (event.reason) {
      SessionEndReason.expired => localizations.sessionExpiredNotice,
      SessionEndReason.suspended => localizations.sessionSuspendedNotice,
      SessionEndReason.revoked => localizations.sessionRevokedNotice,
    };
    await signOutLocal();
    await Get.offAllNamed(AppRoutes.login);
    AppNotifier.info(message);
  }

  @override
  void onClose() {
    unawaited(_sessionSubscription?.cancel() ?? Future<void>.value());
    super.onClose();
  }
}
