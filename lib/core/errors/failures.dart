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

/// How an API call failed, independently of the server's own error code.
enum ApiFailureKind {
  /// No response: no connectivity, DNS failure, refused connection.
  network,

  /// The connection or the response took longer than the configured delay.
  timeout,

  /// The server answered with a 5xx status.
  server,

  /// The server answered with a 4xx status (validation, rights, state...).
  client,
}

/// Failure of a call to the AgriConnect backend.
///
/// Built from the error envelope of `docs/API_CONTRACT.md` § 2:
/// `{ error, code?, details?[], profileVerificationStatus?, expectedField?,
/// retryAfterMs? }`. [code] holds the server code when there is one, else a
/// stable fallback (`network`, `timeout`, `server`, `http_<status>`), so the
/// base [Failure.code] contract still holds.
final class ApiFailure extends Failure {
  ApiFailure({
    required this.kind,
    this.status,
    this.apiCode,
    this.serverMessage,
    Map<String, String> fieldErrors = const {},
    this.profileVerificationStatus,
    this.expectedField,
    this.retryAfter,
  }) : fieldErrors = Map.unmodifiable(fieldErrors),
       super(
         code: apiCode ?? _fallbackCode(kind, status),
         details: serverMessage,
       );

  final ApiFailureKind kind;

  /// HTTP status, `null` when no response was received.
  final int? status;

  /// Machine-readable code sent by the server (e.g. `PROFILE_NOT_VERIFIED`).
  final String? apiCode;

  /// French message sent by the server, shown only as a last resort.
  final String? serverMessage;

  /// Joi validation errors (`details[]`), keyed by field name.
  final Map<String, String> fieldErrors;

  /// Sent with `PROFILE_NOT_VERIFIED`: UNVERIFIED, PENDING or REJECTED.
  final String? profileVerificationStatus;

  /// Sent with `UNEXPECTED_FILE_FIELD`: the multipart field the server wanted.
  final String? expectedField;

  /// Sent with some rate limits (`retryAfterMs`).
  final Duration? retryAfter;

  bool get isUnauthorized => status == 401;
  bool get isSuspended => apiCode == 'ACCOUNT_SUSPENDED';
  bool get isProfileNotVerified => apiCode == 'PROFILE_NOT_VERIFIED';
  bool get isStateConflict => apiCode == 'INVALID_STATE_TRANSITION';
  bool get isCapabilityRequired => apiCode == 'CAPABILITY_REQUIRED';
  bool get isHumanActorRequired => apiCode == 'HUMAN_ACTOR_REQUIRED';
  bool get isRateLimited =>
      status == 429 ||
      apiCode == 'RATE_LIMITED' ||
      apiCode == 'AI_RATE_LIMITED';
  bool get isValidation => status == 400 && fieldErrors.isNotEmpty;

  static String _fallbackCode(ApiFailureKind kind, int? status) =>
      switch (kind) {
        ApiFailureKind.network => 'network',
        ApiFailureKind.timeout => 'timeout',
        ApiFailureKind.server => 'server',
        ApiFailureKind.client => 'http_${status ?? 0}',
      };

  /// Localized message: the server code first, then the HTTP status, then
  /// the server's own (French) message, then a generic message.
  @override
  String message(AppLocalizations l10n) {
    final byCode = apiCode == null ? null : apiErrorMessage(apiCode!, l10n);
    if (byCode != null) return byCode;
    switch (kind) {
      case ApiFailureKind.network:
        return l10n.errNetwork;
      case ApiFailureKind.timeout:
        return l10n.errTimeout;
      case ApiFailureKind.server:
        return l10n.errServer;
      case ApiFailureKind.client:
        break;
    }
    return switch (status) {
      400 => l10n.errInvalidRequest,
      401 => l10n.errSessionExpired,
      403 => l10n.errAccessDenied,
      404 => l10n.errNotFound,
      409 => l10n.errConflict,
      413 => l10n.apiErrFileTooLarge,
      429 => l10n.apiErrRateLimited,
      _ =>
        (serverMessage != null && serverMessage!.trim().isNotEmpty)
            ? serverMessage!
            : l10n.errUnexpected,
    };
  }

  @override
  String toString() => 'ApiFailure($status, $code)';
}

/// Localized message of a backend error code, or `null` when the code has
/// no dedicated message (the caller then falls back on the HTTP status).
String? apiErrorMessage(String code, AppLocalizations l10n) => switch (code) {
    'ACCOUNT_SUSPENDED' => l10n.apiErrAccountSuspended,
    'ROLE_FORBIDDEN' => l10n.apiErrRoleForbidden,
    'LEVEL_FORBIDDEN' => l10n.apiErrLevelForbidden,
    'CAPABILITY_REQUIRED' => l10n.apiErrCapabilityRequired,
    'HUMAN_ACTOR_REQUIRED' => l10n.apiErrHumanActorRequired,
    'TOKEN_INVALID' => l10n.apiErrTokenInvalid,
    'TOKEN_MISSING' => l10n.apiErrTokenMissing,
    'RATE_LIMITED' => l10n.apiErrRateLimited,
    'PROFILE_NOT_VERIFIED' => l10n.apiErrProfileNotVerified,
    'NOT_VERIFIED' => l10n.apiErrNotVerified,
    'PROFILE_MISSING' => l10n.apiErrProfileMissing,
    'INVALID_STATE_TRANSITION' => l10n.apiErrInvalidStateTransition,
    'FILE_TOO_LARGE' => l10n.apiErrFileTooLarge,
    'FILE_REQUIRED' => l10n.apiErrFileRequired,
    'FILE_MISSING' => l10n.apiErrFileMissing,
    'FILE_CONTENT_MISMATCH' => l10n.apiErrFileContentMismatch,
    'UNSUPPORTED_MEDIA_TYPE' => l10n.apiErrUnsupportedMediaType,
    'INVALID_MULTIPART' => l10n.apiErrInvalidMultipart,
    'UNEXPECTED_FILE_FIELD' => l10n.apiErrUnexpectedFileField,
    'TOO_MANY_PENDING_DOCUMENTS' => l10n.apiErrTooManyPendingDocuments,
    'INSUFFICIENT_STOCK' => l10n.apiErrInsufficientStock,
    'PRICE_BELOW_SUPPLIER' => l10n.apiErrPriceBelowSupplier,
    'ZONE_NOT_COVERED' => l10n.apiErrZoneNotCovered,
    'LOT_ALREADY_LINKED' => l10n.apiErrLotAlreadyLinked,
    'LOT_NOT_AVAILABLE' => l10n.apiErrLotNotAvailable,
    'LISTING_NO_LOT' => l10n.apiErrListingNoLot,
    'HUB_NO_PICKUP' => l10n.apiErrHubNoPickup,
    'INVALID_DELIVERY_MODE' => l10n.apiErrInvalidDeliveryMode,
    'INVALID_ORDER_STATUS' => l10n.apiErrInvalidOrderStatus,
    'PAYMENT_REQUIRED' => l10n.apiErrPaymentRequired,
    'IDEMPOTENCY_KEY_CONFLICT' => l10n.apiErrIdempotencyKeyConflict,
    'OVERPAYMENT' => l10n.apiErrOverpayment,
    'INVALID_AMOUNT' => l10n.apiErrInvalidAmount,
    'INVALID_QUANTITY' => l10n.apiErrInvalidQuantity,
    'COMPENSATION_RATE_ZERO' => l10n.apiErrCompensationRateZero,
    'COMPENSATION_QUANTITY_EXCEEDED' => l10n.apiErrCompensationQuantityExceeded,
    'AGENCY_INSURANCE_EXPIRED' => l10n.apiErrAgencyInsuranceExpired,
    'BUYER_NOT_ACTIVE' => l10n.apiErrBuyerNotActive,
    'DELIVERY_ALREADY_TAKEN' => l10n.apiErrDeliveryAlreadyTaken,
    'DELIVERY_ALREADY_ACTIVE' => l10n.apiErrDeliveryAlreadyActive,
    'DELIVERIES_ALREADY_CREATED' => l10n.apiErrDeliveriesAlreadyCreated,
    'NOT_DELIVERY_OWNER' => l10n.apiErrNotDeliveryOwner,
    'NO_DRIVER_PROFILE' => l10n.apiErrNoDriverProfile,
    'REFERRAL_CODE_UNKNOWN' => l10n.apiErrReferralCodeUnknown,
    'REFERRAL_CODE_UNAVAILABLE' => l10n.apiErrReferralCodeUnavailable,
    'CONVERSATION_CLOSED' => l10n.apiErrConversationClosed,
    'AI_DISABLED' => l10n.apiErrAiDisabled,
    'AI_NO_AGENT' => l10n.apiErrAiNoAgent,
    'AI_BUSY' => l10n.apiErrAiBusy,
    'AI_RATE_LIMITED' => l10n.apiErrAiRateLimited,
    'AI_UNREACHABLE' => l10n.apiErrAiUnreachable,
    'AI_INVALID_OUTPUT' => l10n.apiErrAiInvalidOutput,
    'AI_AUTH_FAILED' => l10n.apiErrAiAuthFailed,
    'AI_MODEL_MISSING' => l10n.apiErrAiModelMissing,
  _ => null,
};
