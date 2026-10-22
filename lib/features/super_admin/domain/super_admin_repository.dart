import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

import 'platform_settings.dart';
import 'staff_account.dart';
import 'staff_permission.dart';
import 'system_event.dart';

/// Contract for the Super Admin workspace.
///
/// Same shape as `AdminRepository`: one async surface consumed by the
/// application layer, backed by an in-memory demo implementation and a fake for
/// widget tests. Reads are filtered server side, and every write that changes a
/// right or a setting is a separate method so the caller can report its own
/// outcome.
abstract interface class SuperAdminRepository {
  /// Staff directory, optionally narrowed by [query], [role] and [status].
  ///
  /// A null filter means "every member", so an unfiltered call and a call with
  /// three nulls behave the same.
  Future<List<StaffAccount>> fetchStaff({
    String? query,
    UserRole? role,
    StaffAccountStatus? status,
  });

  /// Grants or revokes [permissions], leaving the account's other fields alone.
  Future<void> updateStaffPermissions(
    String staffId,
    Set<StaffPermission> permissions,
  );

  /// Suspends a member: they keep their permissions on record but cannot
  /// sign in. The repository rejects the last active Super Admin.
  Future<void> suspendStaff(String staffId);

  /// Restores a suspended member to read-only, the safest level a Super Admin
  /// may hand back without making an access decision on someone's behalf.
  Future<void> restoreStaff(String staffId);

  Future<PlatformSettings> fetchSettings();

  Future<void> saveSettings(PlatformSettings settings);

  Future<PlatformOverview> fetchOverview();

  /// Most recent activity first, capped by the repository.
  Future<List<SystemEvent>> fetchRecentEvents();

  /// Sections the Super Admin console serves.
  List<RoleSection> get managedSections;
}
