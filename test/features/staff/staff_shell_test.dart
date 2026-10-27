import 'package:flutter_test/flutter_test.dart';
import 'package:agri_connect/features/auth/domain/agent_capability.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/staff/presentation/pages/staff_pages.dart';

void main() {
  test('staff tabs follow capability groupings and retain account', () {
    final cases = <(List<AgentCapability>, List<StaffSection>)>[
      (
        [AgentCapability.buyerSupport],
        [StaffSection.support, StaffSection.account],
      ),
      (
        [AgentCapability.stockValidation],
        [StaffSection.stock, StaffSection.account],
      ),
      (
        [AgentCapability.listingManagement],
        [StaffSection.listings, StaffSection.account],
      ),
      (
        [
          AgentCapability.dispatchCoordination,
          AgentCapability.userVerification,
        ],
        [StaffSection.orders, StaffSection.verifications, StaffSection.account],
      ),
      (
        AgentCapability.values
            .where((value) => value != AgentCapability.unknown)
            .toList(),
        StaffSection.values,
      ),
    ];
    for (final (capabilities, expected) in cases) {
      final user = AuthUser(
        role: RoleCode.agent,
        agent: AgentInfo(capabilities: capabilities),
      );
      expect(visibleStaffSections(user), expected);
    }
    expect(visibleStaffSections(const AuthUser(role: RoleCode.agent)), [
      StaffSection.account,
    ]);
  });
}
