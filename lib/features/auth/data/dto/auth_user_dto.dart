import 'package:agri_connect/core/media/media_url.dart';
import 'package:agri_connect/features/auth/domain/agent_capability.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/profile_verification_status.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

abstract final class AuthUserDto {
  static AuthUser fromJson(Object? json) {
    if (json is! Map) return const AuthUser();
    final roleMap = _map(json['role']);
    final role = RoleCode.parse(roleMap?['code'] ?? json['role']);
    final profile = _map(json['profile']);
    final media = json['media'];
    String? avatarUrl;
    if (media is List) {
      for (final item in media) {
        final itemMap = _map(item);
        if (itemMap?['isPrimary'] == true && itemMap?['url'] is String) {
          avatarUrl = MediaUrl.resolve(itemMap!['url'] as String);
          break;
        }
      }
    }

    return AuthUser(
      id: _integer(json['id']),
      firstname: _string(json['firstname']),
      lastname: _string(json['lastname']),
      email: _string(json['email']),
      phone: _string(json['phone']),
      location: _string(json['location']),
      referralCode: _string(json['referralCode']),
      role: role,
      roleLabel: _string(roleMap?['label'] ?? json['roleLabel']),
      emailVerified: json['emailVerified'] is bool
          ? json['emailVerified'] as bool
          : null,
      profileVerificationStatus: ProfileVerificationStatus.parse(
        json['profileVerificationStatus'] ??
            profile?['profileVerificationStatus'],
      ),
      avatarUrl: avatarUrl,
      profile: _profile(role, profile),
      agent: _agent(_map(json['agent'])),
    );
  }

  static AuthProfile? _profile(RoleCode role, Map<Object?, Object?>? profile) {
    if (profile == null) return null;
    return switch (role) {
      RoleCode.supplier => SupplierProfile(
        farmName: _string(profile['farmName']),
        description: _string(profile['description']),
        zoneId: _integer(profile['zoneId']),
      ),
      RoleCode.buyer => BuyerProfile(
        buyerType: _string(profile['buyerType']),
        businessName: _string(profile['businessName']),
        zoneId: _integer(profile['zoneId']),
      ),
      RoleCode.driver => DriverProfile(
        agencyId: _integer(profile['agencyId']),
        vehicleType: _string(profile['vehicleType']),
        plateNumber: _string(profile['plateNumber']),
      ),
      _ => null,
    };
  }

  static AgentInfo? _agent(Map<Object?, Object?>? value) {
    if (value == null) return null;
    final rawCapabilities = value['capabilities'];
    return AgentInfo(
      id: _integer(value['id']),
      displayName: _string(value['displayName']),
      kind: _string(value['kind']),
      autonomy: _string(value['autonomy']),
      capabilities: rawCapabilities is List
          ? rawCapabilities.map(AgentCapability.parse)
          : const <AgentCapability>[],
    );
  }

  static Map<Object?, Object?>? _map(Object? value) =>
      value is Map ? value : null;

  static String? _string(Object? value) => value is String ? value : null;

  static int? _integer(Object? value) => value is int
      ? value
      : value is num
      ? value.toInt()
      : null;
}
