/// The six roles of the AgriConnect platform.
///
/// This enum is the single source of truth for roles: every route guard,
/// shell and UI lookup derives from it. Role names as strings must never be
/// scattered through the codebase.
enum UserRole {
  buyer,
  supplier,
  driver,
  agent,
  admin,
  root;

  /// Stable machine-readable key, used for persistence and API payloads.
  String get key => name;

  /// URL prefix for the role workspace.
  String get routePrefix => switch (this) {
    UserRole.buyer => '/buyer',
    UserRole.supplier => '/supplier',
    UserRole.driver => '/driver',
    UserRole.agent => '/agent',
    UserRole.admin => '/admin',
    UserRole.root => '/root',
  };

  /// Landing page of the role workspace.
  String get homePath => '$routePrefix/home';

  /// Staff roles manage other users and the platform itself.
  bool get isStaff =>
      this == UserRole.admin || this == UserRole.agent || this == UserRole.root;

  /// The roles a visitor can register for on their own, in the order the role
  /// page offers them.
  ///
  /// Supplier, buyer and driver are external marketplace roles. Agent, admin
  /// and root are provisioned by the platform and are never selectable at
  /// signup, so they are deliberately absent from this list.
  static const List<UserRole> onboardingRoles = [
    UserRole.supplier,
    UserRole.buyer,
    UserRole.driver,
  ];

  /// Whether a visitor may register an account for this role.
  bool get selectableForSignup => onboardingRoles.contains(this);

  /// Resolves a stored role name, mapping the legacy V1 values so a session
  /// persisted before the V2 migration still restores.
  static UserRole fromName(String name) => switch (name) {
    'farmer' => UserRole.supplier,
    'superAdmin' => UserRole.root,
    _ => UserRole.values.byName(name),
  };
}
