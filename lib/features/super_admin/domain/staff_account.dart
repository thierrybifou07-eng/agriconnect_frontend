import 'package:flutter/foundation.dart';

import 'package:agri_connect/features/auth/domain/user_role.dart';

import 'staff_permission.dart';

/// Access level held by a member of the platform staff.
///
/// The Super Admin does not manage end users here, it manages the staff that
/// supervises them, so the account carries a narrower shape than
/// `AdminUser`: a role limited to the staff roles, an access level, and the
/// explicit permission set the console can edit.
@immutable
class StaffAccount {
  const StaffAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.accessLevel,
    required this.permissions,
    required this.joinedAt,
    required this.lastActiveAt,
  });

  final String id;
  final String fullName;
  final String email;

  /// Only the staff roles reach this console; a farmer or buyer never appears
  /// in the staff directory.
  final UserRole role;

  final StaffAccessLevel accessLevel;
  final List<StaffPermission> permissions;
  final DateTime joinedAt;
  final DateTime lastActiveAt;

  bool hasPermission(StaffPermission permission) =>
      permissions.contains(permission);

  /// A suspended member keeps its permissions on record but cannot sign in.
  bool get isActive => accessLevel != StaffAccessLevel.suspended;

  /// Whether the console may hand this account more rights.
  ///
  /// A full Super Admin is never demoted here: the platform must always keep a
  /// way back into its own settings.
  bool get canReceiveMoreRights =>
      role != UserRole.root || accessLevel != StaffAccessLevel.fullAccess;

  /// Whether this console may edit the account at all.
  ///
  /// Super Admins and the account currently signed in are both left alone, so
  /// the console can neither lock itself out nor let two windows fight over the
  /// same account.
  bool canBeManagedBy(String currentUserId) =>
      role != UserRole.root && id != currentUserId;

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  StaffAccount copyWith({
    List<StaffPermission>? permissions,
    StaffAccessLevel? accessLevel,
  }) {
    return StaffAccount(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      accessLevel: accessLevel ?? this.accessLevel,
      permissions: permissions ?? this.permissions,
      joinedAt: joinedAt,
      lastActiveAt: lastActiveAt,
    );
  }
}

/// How much of the console a staff member may reach.
///
/// Ordered from weakest to strongest so the editor can present the choices in
/// that order without sorting them itself.
enum StaffAccessLevel { suspended, readOnly, fullAccess }

extension StaffAccessLevelX on StaffAccessLevel {
  bool get canModerate => this == StaffAccessLevel.fullAccess;

  String keyName() => switch (this) {
    StaffAccessLevel.suspended => 'suspended',
    StaffAccessLevel.readOnly => 'readOnly',
    StaffAccessLevel.fullAccess => 'fullAccess',
  };
}

/// Sign-in state of a directory entry, kept apart from [StaffAccessLevel].
///
/// A suspended account still carries an access level on record, so the level
/// says what the member could do and the status says whether they can sign in
/// at all. A filter has to ask about the second, not infer it from the first.
enum StaffAccountStatus { active, suspended }

extension StaffAccountStatusX on StaffAccountStatus {
  /// The status this account is in, derived rather than stored.
  static StaffAccountStatus statusOf(StaffAccount account) => account.isActive
      ? StaffAccountStatus.active
      : StaffAccountStatus.suspended;

  bool matches(StaffAccount account) => switch (this) {
    StaffAccountStatus.active => account.isActive,
    StaffAccountStatus.suspended => !account.isActive,
  };
}
