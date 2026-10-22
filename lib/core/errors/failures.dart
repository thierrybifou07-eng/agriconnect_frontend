import 'package:agri_connect/core/localization/generated/app_localizations.dart';

/// Base class for every failure surfaced by the application.
///
/// [code] is a stable machine-readable identifier, mapped to a localized
/// message through [message]. It must never be displayed raw.
sealed class Failure implements Exception {
  const Failure({required this.code, this.details});

  final String code;
  final Object? details;

  String message(AppLocalizations l10n) => switch (code) {
    'invalid_credentials' => l10n.errInvalidCredentials,
    'email_exists' => l10n.errEmailExists,
    'role_mismatch' => l10n.errRoleMismatch,
    'role_not_allowed' => l10n.errRoleNotAllowed,
    'access_denied' => l10n.errAccessDenied,
    'session_expired' => l10n.errSessionExpired,
    'profile_name_invalid' => l10n.profileNameInvalid,
    'network' => l10n.errNetwork,
    'timeout' => l10n.errTimeout,
    'server' => l10n.errServer,
    'cache' => l10n.errCache,
    _ => l10n.errUnexpected,
  };
}

final class NetworkFailure extends Failure {
  const NetworkFailure([Object? details])
    : super(code: 'network', details: details);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([Object? details])
    : super(code: 'timeout', details: details);
}

final class ServerFailure extends Failure {
  const ServerFailure([Object? details])
    : super(code: 'server', details: details);
}

final class CacheFailure extends Failure {
  const CacheFailure([Object? details])
    : super(code: 'cache', details: details);
}

final class AuthFailure extends Failure {
  const AuthFailure(String code, [Object? details])
    : super(code: code, details: details);
}

/// Raised when the authenticated session may not perform the requested
/// action, even though the route guard let it into the workspace.
///
/// Carries the missing capability key as [details] when available.
final class AccessDeniedFailure extends Failure {
  const AccessDeniedFailure([Object? details])
    : super(code: 'access_denied', details: details);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([Object? details])
    : super(code: 'unexpected', details: details);
}
