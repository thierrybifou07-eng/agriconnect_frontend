import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/core/errors/failures.dart';

/// A seeded test account used by the demo repository and the login page.
class DemoAccount {
  const DemoAccount({
    required this.role,
    required this.fullName,
    required this.email,
    required this.password,
  });

  final UserRole role;
  final String fullName;
  final String email;
  final String password;

  AuthUser toUser() => AuthUser(
    id: 'demo_${role.name}',
    fullName: fullName,
    email: email,
    role: role,
  );
}

/// Offline repository backing the presentation demo.
///
/// Swapping this class for a real remote implementation must be the only
/// change required to go live (see [AuthRepository]).
final class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository();

  static const accounts = <DemoAccount>[
    DemoAccount(
      role: UserRole.supplier,
      fullName: 'Alassane Traoré',
      email: 'supplier@agriconnect.app',
      password: 'demo1234',
    ),
    DemoAccount(
      role: UserRole.buyer,
      fullName: 'Marie Koné',
      email: 'buyer@agriconnect.app',
      password: 'demo1234',
    ),
    DemoAccount(
      role: UserRole.driver,
      fullName: 'Ibrahim Cissé',
      email: 'driver@agriconnect.app',
      password: 'demo1234',
    ),
    DemoAccount(
      role: UserRole.agent,
      fullName: 'Awa Diallo',
      email: 'agent@agriconnect.app',
      password: 'demo1234',
    ),
    DemoAccount(
      role: UserRole.admin,
      fullName: 'Cheick Diarra',
      email: 'admin@agriconnect.app',
      password: 'demo1234',
    ),
    DemoAccount(
      role: UserRole.root,
      fullName: 'Binta Cissé',
      email: 'root@agriconnect.app',
      password: 'demo1234',
    ),
  ];

  final List<String> _registeredEmails = [];

  @override
  Future<AuthResult> signIn(SignInRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final normalizedEmail = request.email.trim().toLowerCase();
    for (final account in accounts) {
      if (account.email == normalizedEmail &&
          account.password == request.password) {
        final expectedRole = request.expectedRole;
        if (expectedRole != null && account.role != expectedRole) {
          throw const AuthFailure('role_mismatch');
        }
        return _resultFor(account.toUser());
      }
    }
    throw const AuthFailure('invalid_credentials');
  }

  AuthResult _resultFor(AuthUser user) {
    return AuthResult(
      user: user,
      accessToken:
          'demo_${user.email}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<AuthResult> register(RegisterRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    // Staff roles are provisioned by the platform: a visitor may never
    // register an agent, admin or root account on their own.
    if (!request.role.selectableForSignup) {
      throw const AuthFailure('role_not_allowed');
    }
    final normalizedEmail = request.email.trim().toLowerCase();
    for (final account in accounts) {
      if (account.email == normalizedEmail) {
        throw const AuthFailure('email_exists');
      }
    }
    if (_registeredEmails.contains(normalizedEmail)) {
      throw const AuthFailure('email_exists');
    }
    _registeredEmails.add(normalizedEmail);
    final user = AuthUser(
      id: 'registered_${DateTime.now().millisecondsSinceEpoch}',
      fullName: request.fullName.trim(),
      email: normalizedEmail,
      role: request.role,
    );
    return _resultFor(user);
  }
}
