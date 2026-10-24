/// Operational visibility of an account as supervised by the administrator.
///
/// The admin never inspects credentials; this status only controls whether an
/// account may sign in and transact on the marketplace.
enum AdminAccountStatus { active, suspended, verificationPending }

extension AdminAccountStatusX on AdminAccountStatus {
  String keyName() => switch (this) {
    AdminAccountStatus.active => 'active',
    AdminAccountStatus.suspended => 'suspended',
    AdminAccountStatus.verificationPending => 'verificationPending',
  };

  bool get isActive =>
      this == AdminAccountStatus.active ||
      this == AdminAccountStatus.verificationPending;
}
