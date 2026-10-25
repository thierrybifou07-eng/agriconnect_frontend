import 'package:agri_connect/features/auth/domain/agent_capability.dart';
import 'package:agri_connect/features/auth/domain/profile_verification_status.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

class AgentInfo {
  AgentInfo({
    required this.id,
    required this.displayName,
    required this.kind,
    required this.autonomy,
    required Iterable<AgentCapability> capabilities,
  }) : capabilities = Set.unmodifiable(capabilities);

  final int id;
  final String displayName;
  final String kind;
  final String autonomy;
  final Set<AgentCapability> capabilities;
}

sealed class AuthProfile {
  const AuthProfile();
}

class SupplierProfile extends AuthProfile {
  const SupplierProfile({
    required this.farmName,
    this.description,
    this.zoneId,
  });

  final String farmName;
  final String? description;
  final int? zoneId;
}

class BuyerProfile extends AuthProfile {
  const BuyerProfile({required this.buyerType, this.businessName, this.zoneId});

  final String buyerType;
  final String? businessName;
  final int? zoneId;
}

class DriverProfile extends AuthProfile {
  const DriverProfile({
    required this.agencyId,
    this.vehicleType,
    this.plateNumber,
  });

  final String? vehicleType;
  final String? plateNumber;
  final int agencyId;
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.role,
    required this.roleLabel,
    required this.emailVerified,
    required this.profileVerificationStatus,
    this.location,
    this.referralCode,
    this.avatarUrl,
    this.profile,
    this.agent,
  });

  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String? location;
  final RoleCode role;
  final String roleLabel;
  final bool emailVerified;
  final ProfileVerificationStatus profileVerificationStatus;
  final String? referralCode;
  final String? avatarUrl;
  final AuthProfile? profile;
  final AgentInfo? agent;

  bool get isStaff =>
      role == RoleCode.agent || role == RoleCode.admin || role == RoleCode.root;

  bool can(AgentCapability capability) =>
      role == RoleCode.admin ||
      role == RoleCode.root ||
      (role == RoleCode.agent &&
          capability != AgentCapability.unknown &&
          agent?.capabilities.contains(capability) == true);

  bool canAny(Iterable<AgentCapability> capabilities) => capabilities.any(can);
}
