import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

import '../domain/platform_settings.dart';
import '../domain/staff_account.dart';
import '../domain/staff_permission.dart';
import '../domain/super_admin_repository.dart';
import '../domain/system_event.dart';

/// In-memory [SuperAdminRepository] used by the demo build.
///
/// Mutable by design: the console's whole purpose is to change rights and
/// settings, so a read-only stub would make every write untestable. State lives
/// in memory and is rebuilt from the seeds on each launch, exactly like
/// `DemoAdminRepository`.
class DemoSuperAdminRepository implements SuperAdminRepository {
  DemoSuperAdminRepository({
    this.latency = const Duration(milliseconds: 260),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final Duration latency;
  final DateTime Function() _now;

  late final List<StaffAccount> _staff = _seedStaff();
  late PlatformSettings _settings = PlatformSettings(
    registrationsOpen: true,
    autoModeration: false,
    maintenanceMode: false,
    supportEmail: 'support@agri-connect.app',
    maxUploadMb: 8,
    updatedAt: _now().subtract(const Duration(days: 3)),
  );
  late List<SystemEvent> _events = _seedEvents();

  DateTime get _nowUtc => _now().toUtc();

  Future<T> _go<T>(T Function() job) async {
    await Future<void>.delayed(latency);
    return job();
  }

  @override
  List<RoleSection> get managedSections => const [
    RoleSection.dashboard,
    RoleSection.users,
    RoleSection.platform,
    RoleSection.analytics,
    RoleSection.profile,
  ];

  @override
  Future<List<StaffAccount>> fetchStaff({
    String? query,
    UserRole? role,
    StaffAccountStatus? status,
  }) => _go(() {
    final needle = query?.trim().toLowerCase() ?? '';
    final matches = _staff.where((account) {
      // A suspended member keeps its permissions on record but is not one of
      // the active staff, so the status filter asks for the sign-in state and
      // not for the access level.
      if (role != null && account.role != role) return false;
      if (status != null && !status.matches(account)) return false;
      if (needle.isEmpty) return true;
      return account.fullName.toLowerCase().contains(needle) ||
          account.email.toLowerCase().contains(needle);
    }).toList();
    return List<StaffAccount>.unmodifiable(matches);
  });

  @override
  Future<void> updateStaffPermissions(
    String staffId,
    Set<StaffPermission> permissions,
  ) => _go(() {
    final index = _staff.indexWhere((s) => s.id == staffId);
    if (index == -1) {
      throw StateError('Staff member $staffId is no longer in the directory.');
    }
    final account = _staff[index];
    if (!account.canReceiveMoreRights) {
      throw StateError('A Super Admin with full access cannot be demoted.');
    }

    // The console never delegates the platform's own settings, whatever the
    // caller sent, so a crafted payload cannot hand that right to an admin.
    final next = permissions.where((p) => !p.isSuperAdminOnly).toList();
    if (account.role == UserRole.root) {
      next.add(StaffPermission.managePlatformSettings);
    }

    _staff[index] = account.copyWith(permissions: next);
    _record(
      actor: 'You',
      action: SystemEventAction.updatedPermissions,
      target: account.fullName,
    );
  });

  @override
  Future<void> suspendStaff(String staffId) => _go(() {
    final index = _staff.indexWhere((s) => s.id == staffId);
    if (index == -1) {
      throw StateError('Staff member $staffId is no longer in the directory.');
    }
    final account = _staff[index];
    if (account.role == UserRole.root && account.isActive) {
      throw StateError('A Super Admin cannot be suspended.');
    }
    _staff[index] = account.copyWith(accessLevel: StaffAccessLevel.suspended);
    _record(
      actor: 'You',
      action: SystemEventAction.suspended,
      target: account.fullName,
    );
  });

  @override
  Future<void> restoreStaff(String staffId) => _go(() {
    final index = _staff.indexWhere((s) => s.id == staffId);
    if (index == -1) {
      throw StateError('Staff member $staffId is no longer in the directory.');
    }
    final account = _staff[index];
    _staff[index] = account.copyWith(accessLevel: StaffAccessLevel.readOnly);
    _record(
      actor: 'You',
      action: SystemEventAction.restored,
      target: account.fullName,
    );
  });

  @override
  Future<PlatformSettings> fetchSettings() => _go(() => _settings);

  @override
  Future<void> saveSettings(PlatformSettings settings) => _go(() {
    _settings = settings.copyWith(updatedAt: _nowUtc);
    _record(
      actor: 'You',
      action: SystemEventAction.updatedSettings,
      target: 'Configuration',
    );
  });

  @override
  Future<PlatformOverview> fetchOverview() => _go(() {
    // The platform counters reuse the Administrator seeds: both consoles read
    // the same marketplace, so inventing a second set of figures here would
    // make the two dashboards disagree.
    final users = _platformUsers;
    final orders = _platformOrders;
    return PlatformOverview(
      totalUsers: users.length,
      farmers: users.where((u) => u.role == UserRole.supplier).length,
      buyers: users.where((u) => u.role == UserRole.buyer).length,
      drivers: users.where((u) => u.role == UserRole.driver).length,
      staff: _staff.where((s) => s.isActive).length,
      publishedProducts: publishedProducts,
      pendingModeration: pendingModeration,
      totalOrders: orders.length,
      openOrders: orders.where((o) => o.isOpen).length,
      activeDeliveries: activeDeliveries,
      grossMerchandiseValue: orders.fold(0.0, (sum, o) => sum + o.amount),
      pendingUsers: users.where((u) => !u.verified).length,
    );
  });

  @override
  Future<List<SystemEvent>> fetchRecentEvents() =>
      _go(() => List<SystemEvent>.unmodifiable(_events));

  void _record({
    required String actor,
    required SystemEventAction action,
    required String target,
  }) {
    _events = [
      SystemEvent(
        id: 'e${_events.length + 1}',
        actorName: actor,
        action: action,
        target: target,
        occurredAt: _nowUtc,
      ),
      ..._events,
    ];
  }

  // The three counters below are the marketplace figures the console needs but
  // the staff models do not carry. They belong to the platform rather than to
  // the staff directory, so they are static: no write on a staff account can
  // move them, and the dashboard and the analytics screen read the same values.
  static const int publishedProducts = 34;
  static const int pendingModeration = 3;
  static const int activeDeliveries = 2;

  DateTime _d(int daysAgo, int hour) {
    final now = _now();
    return DateTime.utc(
      now.year,
      now.month,
      now.day,
      hour,
    ).subtract(Duration(days: daysAgo));
  }

  List<StaffAccount> _seedStaff() {
    return [
      StaffAccount(
        id: 's1',
        fullName: 'Adjoua Koffi',
        email: 'adjoua@agri-connect.app',
        role: UserRole.root,
        accessLevel: StaffAccessLevel.fullAccess,
        permissions: StaffPermission.values,
        joinedAt: _d(210, 8),
        lastActiveAt: _d(0, 7),
      ),
      StaffAccount(
        id: 's2',
        fullName: 'Mensah Yao',
        email: 'yao@agri-connect.app',
        role: UserRole.admin,
        accessLevel: StaffAccessLevel.fullAccess,
        permissions: const [
          StaffPermission.moderateProducts,
          StaffPermission.superviseDeliveries,
          StaffPermission.manageOrders,
          StaffPermission.viewAnalytics,
        ],
        joinedAt: _d(180, 9),
        lastActiveAt: _d(0, 6),
      ),
      StaffAccount(
        id: 's3',
        fullName: 'Ama Boateng',
        email: 'ama@agri-connect.app',
        role: UserRole.admin,
        accessLevel: StaffAccessLevel.fullAccess,
        permissions: const [
          StaffPermission.moderateProducts,
          StaffPermission.manageUsers,
          StaffPermission.superviseDeliveries,
        ],
        joinedAt: _d(150, 10),
        lastActiveAt: _d(1, 15),
      ),
      StaffAccount(
        id: 's4',
        fullName: 'Kouassi N\'Guessan',
        email: 'kouassi@agri-connect.app',
        role: UserRole.admin,
        accessLevel: StaffAccessLevel.readOnly,
        permissions: const [StaffPermission.viewAnalytics],
        joinedAt: _d(90, 11),
        lastActiveAt: _d(2, 13),
      ),
      StaffAccount(
        id: 's5',
        fullName: 'Traore Salimata',
        email: 'salimata@agri-connect.app',
        role: UserRole.admin,
        accessLevel: StaffAccessLevel.suspended,
        permissions: const [StaffPermission.manageOrders],
        joinedAt: _d(240, 14),
        lastActiveAt: _d(12, 9),
      ),
    ];
  }

  List<SystemEvent> _seedEvents() {
    return [
      SystemEvent(
        id: 'e1',
        actorName: 'Adjoua Koffi',
        action: SystemEventAction.restored,
        target: 'Kouassi N\'Guessan',
        occurredAt: _d(0, 7),
      ),
      SystemEvent(
        id: 'e2',
        actorName: 'Mensah Yao',
        action: SystemEventAction.moderatedProduct,
        target: 'Plantain bio',
        occurredAt: _d(0, 6),
      ),
      SystemEvent(
        id: 'e3',
        actorName: 'Adjoua Koffi',
        action: SystemEventAction.updatedSettings,
        target: 'Configuration',
        occurredAt: _d(1, 18),
      ),
      SystemEvent(
        id: 'e4',
        actorName: 'Ama Boateng',
        action: SystemEventAction.updatedPermissions,
        target: 'Mensah Yao',
        occurredAt: _d(2, 11),
      ),
      SystemEvent(
        id: 'e5',
        actorName: 'Adjoua Koffi',
        action: SystemEventAction.suspended,
        target: 'Traore Salimata',
        occurredAt: _d(12, 9),
      ),
    ];
  }
}

/// Minimal view of a platform account: the console counts roles, so it does not
/// need the moderation fields the Administrator console carries.
class _PlatformUser {
  const _PlatformUser({required this.role, required this.verified});

  final UserRole role;
  final bool verified;
}

/// Minimal view of an order: the console needs the open flag and the amount, so
/// a narrow record beats importing the Administrator order model.
class _PlatformOrder {
  const _PlatformOrder({required this.amount, required this.isOpen});

  final double amount;
  final bool isOpen;
}

/// Marketplace accounts the console aggregates over.
///
/// The counters both consoles read come from here, so the Administrator
/// dashboard and the Super Admin console cannot report different totals.
const List<_PlatformUser> _platformUsers = [
  _PlatformUser(role: UserRole.supplier, verified: true),
  _PlatformUser(role: UserRole.supplier, verified: true),
  _PlatformUser(role: UserRole.supplier, verified: false),
  _PlatformUser(role: UserRole.supplier, verified: true),
  _PlatformUser(role: UserRole.buyer, verified: true),
  _PlatformUser(role: UserRole.buyer, verified: true),
  _PlatformUser(role: UserRole.buyer, verified: false),
  _PlatformUser(role: UserRole.driver, verified: true),
  _PlatformUser(role: UserRole.driver, verified: true),
  _PlatformUser(role: UserRole.driver, verified: true),
];

/// Orders the console aggregates over.
const List<_PlatformOrder> _platformOrders = [
  _PlatformOrder(amount: 24500, isOpen: false),
  _PlatformOrder(amount: 8600, isOpen: false),
  _PlatformOrder(amount: 15200, isOpen: true),
  _PlatformOrder(amount: 3100, isOpen: false),
  _PlatformOrder(amount: 48000, isOpen: false),
  _PlatformOrder(amount: 12900, isOpen: true),
  _PlatformOrder(amount: 7400, isOpen: false),
  _PlatformOrder(amount: 22600, isOpen: true),
];
