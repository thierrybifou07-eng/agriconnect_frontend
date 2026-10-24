/// Capability granted to a member of the platform staff.
///
/// A permission is a data value, not a widget concern: the Super Admin edits it
/// on a member's sheet, the repository persists it, and the dashboard counts it
/// to explain who can do what. The catalogue is closed on purpose, so a screen
/// can never offer a right the platform does not model.
enum StaffPermission {
  moderateProducts,
  manageUsers,
  superviseDeliveries,
  manageOrders,
  viewAnalytics,
  managePlatformSettings,
}

/// The permission groups offered by the editor, in display order.
///
/// Grouping is presentation logic kept next to the catalogue it sorts, which
/// keeps the "Permissions" sheet honest: a right added to the enum has to be
/// placed in a group to become reachable.
enum StaffPermissionGroup { marketplace, people, platform }

extension StaffPermissionGroupX on StaffPermissionGroup {
  List<StaffPermission> get permissions => switch (this) {
    StaffPermissionGroup.marketplace => const [
      StaffPermission.moderateProducts,
      StaffPermission.superviseDeliveries,
      StaffPermission.manageOrders,
    ],
    StaffPermissionGroup.people => const [StaffPermission.manageUsers],
    StaffPermissionGroup.platform => const [
      StaffPermission.viewAnalytics,
      StaffPermission.managePlatformSettings,
    ],
  };
}

extension StaffPermissionX on StaffPermission {
  /// Permissions that only a Super Admin may hold.
  ///
  /// Changing the platform's own settings is the act that defines the role, so
  /// the console refuses to delegate it and refuses to revoke it from the
  /// signed-in Super Admin rather than letting a console lock itself out.
  bool get isSuperAdminOnly => this == StaffPermission.managePlatformSettings;

  String keyName() => switch (this) {
    StaffPermission.moderateProducts => 'moderateProducts',
    StaffPermission.manageUsers => 'manageUsers',
    StaffPermission.superviseDeliveries => 'superviseDeliveries',
    StaffPermission.manageOrders => 'manageOrders',
    StaffPermission.viewAnalytics => 'viewAnalytics',
    StaffPermission.managePlatformSettings => 'managePlatformSettings',
  };
}
