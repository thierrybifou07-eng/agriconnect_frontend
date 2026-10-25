import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/features/auth/domain/agent_capability.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/profile_verification_status.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

void main() {
  test('role and capability parsers tolerate case and unknown values', () {
    expect(RoleCode.parse('sUpPlIeR'), RoleCode.supplier);
    expect(RoleCode.parse('new-role'), RoleCode.unknown);
    expect(
      AgentCapability.parse('payment_followup'),
      AgentCapability.paymentFollowup,
    );
    expect(AgentCapability.parse('unknown'), AgentCapability.unknown);
    expect(
      ProfileVerificationStatus.parse('verified'),
      ProfileVerificationStatus.verified,
    );
    expect(
      ProfileVerificationStatus.parse('not-a-status'),
      ProfileVerificationStatus.unknown,
    );
  });

  test('staff roles bypass capabilities while agents use assigned rights', () {
    final agent = _user(
      role: RoleCode.agent,
      agent: AgentInfo(
        id: 4,
        displayName: 'Agent',
        kind: 'HUMAN',
        autonomy: 'SUGGEST_ONLY',
        capabilities: const [AgentCapability.buyerSupport],
      ),
    );
    final admin = _user(role: RoleCode.admin);

    expect(agent.isStaff, isTrue);
    expect(agent.can(AgentCapability.buyerSupport), isTrue);
    expect(agent.can(AgentCapability.paymentFollowup), isFalse);
    expect(
      agent.canAny([
        AgentCapability.paymentFollowup,
        AgentCapability.buyerSupport,
      ]),
      isTrue,
    );
    expect(admin.can(AgentCapability.disputeHandling), isTrue);
  });
}

AuthUser _user({required RoleCode role, AgentInfo? agent}) => AuthUser(
  id: 12,
  firstname: 'Awa',
  lastname: 'Bello',
  email: 'awa@example.test',
  phone: '+237600000000',
  role: role,
  roleLabel: role.name,
  emailVerified: true,
  profileVerificationStatus: ProfileVerificationStatus.verified,
  agent: agent,
);
