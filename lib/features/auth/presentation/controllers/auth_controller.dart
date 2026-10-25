import 'dart:async';

import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

class AuthController extends GetxController {
  AuthController({
    required this.tokenStorage,
    required this.sessionEvents,
    required this.repository,
  });

  final TokenStorage tokenStorage;
  final SessionEvents sessionEvents;
  final AuthRepository repository;
  final Rxn<AuthUser> user = Rxn<AuthUser>();
  final Rx<UiState<void>> authState = Rx<UiState<void>>(const Idle<void>());
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
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

  Future<AuthUser?> restoreSession() async {
    final tokens = await tokenStorage.read();
    if (tokens == null) {
      await signOutLocal();
      return null;
    }
    try {
      final restored = await repository.me();
      setUser(restored);
      return restored;
    } on ApiFailure {
      await signOutLocal();
      return null;
    } on FormatException {
      await signOutLocal();
      return null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    authState.value = const Loading<void>();
    fieldErrors.clear();
    try {
      final (authenticatedUser, tokens) = await repository.signIn(
        email.trim(),
        password,
      );
      await _saveSession(authenticatedUser, tokens);
      unawaited(Get.offAllNamed(AppRoutes.homeFor(authenticatedUser)));
      return true;
    } on ApiFailure catch (failure) {
      _setFailure(failure);
      return false;
    } on FormatException {
      _setFailure(_invalidResponse());
      return false;
    }
  }

  Future<bool> signUp(Map<String, Object?> payload) async {
    authState.value = const Loading<void>();
    fieldErrors.clear();
    try {
      final (authenticatedUser, tokens) = await repository.signUp(payload);
      await _saveSession(authenticatedUser, tokens);
      unawaited(Get.offAllNamed(AppRoutes.homeFor(authenticatedUser)));
      return true;
    } on ApiFailure catch (failure) {
      _setFailure(failure);
      return false;
    } on FormatException {
      _setFailure(_invalidResponse());
      return false;
    }
  }

  Future<bool> refreshUser() async {
    try {
      setUser(await repository.me());
      return true;
    } on ApiFailure {
      return false;
    }
  }

  Future<void> signOut() async {
    final tokens = await tokenStorage.read();
    if (tokens != null) {
      try {
        await repository.logout(tokens.refresh);
      } on ApiFailure {
        // A failed remote logout must not keep the local session alive.
      }
    }
    await signOutLocal();
    unawaited(Get.offAllNamed(AppRoutes.login));
  }

  Future<void> signOutEverywhere() async {
    final tokens = await tokenStorage.read();
    try {
      await repository.logoutAll();
      if (tokens != null) await repository.logout(tokens.refresh);
    } on ApiFailure {
      // Local logout remains available when the API cannot be reached.
    } finally {
      await signOutLocal();
      unawaited(Get.offAllNamed(AppRoutes.login));
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await repository.forgotPassword(email.trim());
    } on ApiFailure {
      // The UI always shows the same confirmation to prevent account discovery.
    }
  }

  Future<void> resendVerification() => repository.resendVerification();

  Future<void> _saveSession(
    AuthUser authenticatedUser,
    AuthTokens tokens,
  ) async {
    await tokenStorage.save(
      access: tokens.accessToken,
      refresh: tokens.refreshToken,
    );
    setUser(authenticatedUser);
    authState.value = const Success<void>(null);
  }

  void _setFailure(ApiFailure failure) {
    fieldErrors.value = Map<String, String>.from(failure.fieldErrors);
    authState.value = Failure<void>(failure);
  }

  ApiFailure _invalidResponse() => const ApiFailure(
    status: null,
    code: null,
    message: 'Invalid authentication response',
    fieldErrors: {},
    kind: ApiFailureKind.server,
  );

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
