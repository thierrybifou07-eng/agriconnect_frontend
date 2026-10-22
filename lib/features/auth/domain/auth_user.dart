import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

/// Authenticated user of the platform, serialized to persist the session.
class AuthUser {
  AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.photoUrl,
    Set<UserCapability>? capabilities,
  }) : capabilities = capabilities ?? role.capabilities;

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? photoUrl;

  /// Capabilities granted to this session.
  ///
  /// When the constructor receives no explicit list, the role default bundle
  /// is used, so the demo keeps working without a server.
  ///
  /// A session restored from storage is never granted the bundle: the role is
  /// the demo fallback for freshly signed-in accounts, while the persisted
  /// list is taken verbatim — an empty or absent list stays empty. The backend
  /// remains the authority, and the demo capabilities must never silently
  /// replace the authorizations a stored session was given.
  final Set<UserCapability> capabilities;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'role': role.name,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (capabilities.isNotEmpty)
      'capabilities': capabilities.map((c) => c.key).toList(),
  };

  factory AuthUser.fromJson(Map<String, Object?> json) {
    final rawCapabilities = json['capabilities'];
    final capabilities = rawCapabilities is List
        ? rawCapabilities
              .whereType<String>()
              .map(UserCapability.fromKey)
              .whereType<UserCapability>()
              .toSet()
        : <UserCapability>{};
    final role = UserRole.fromName(json['role']! as String);
    return AuthUser(
      id: json['id']! as String,
      fullName: json['fullName']! as String,
      email: json['email']! as String,
      role: role,
      photoUrl: json['photoUrl'] as String?,
      // The bundle is a constructor fallback for fresh demo accounts, never a
      // re-grant for a restored session: pass the explicit (possibly empty)
      // set so the restore is verbatim.
      capabilities: capabilities,
    );
  }

  @override
  String toString() => 'AuthUser($id, $role, $fullName)';
}

/// Capability checks bound to an authenticated session.
///
/// Authorization is decided by the session capabilities, not by the role: the
/// role merely provides the default bundle, and a session may carry a
/// different set once the server grants one.
extension AuthCapabilityGuardX on AuthUser {
  bool hasCapability(UserCapability capability) =>
      capabilities.contains(capability);

  bool hasAnyCapability(Iterable<UserCapability> required) =>
      required.any(hasCapability);

  bool hasAllCapabilities(Iterable<UserCapability> required) =>
      required.every(hasCapability);

  /// Throws [AccessDeniedFailure] when the session lacks [capability].
  ///
  /// Route guards keep a user outside another role's workspace; this guard
  /// protects the fine-grained actions within a workspace.
  void requireCapability(UserCapability capability) {
    if (!hasCapability(capability)) {
      throw AccessDeniedFailure(capability.key);
    }
  }
}
