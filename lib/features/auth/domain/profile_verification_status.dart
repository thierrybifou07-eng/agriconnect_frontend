enum ProfileVerificationStatus {
  unverified,
  pending,
  verified,
  rejected,
  unknown;

  static ProfileVerificationStatus parse(Object? value) {
    if (value is! String) return ProfileVerificationStatus.unknown;
    return ProfileVerificationStatus.values.firstWhere(
      (status) => status.name.toUpperCase() == value.trim().toUpperCase(),
      orElse: () => ProfileVerificationStatus.unknown,
    );
  }
}
