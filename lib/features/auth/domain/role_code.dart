enum RoleCode {
  root,
  admin,
  agent,
  supplier,
  buyer,
  driver,
  unknown;

  static RoleCode parse(Object? value) {
    if (value is! String) return RoleCode.unknown;
    final code = value.trim().toLowerCase();
    return RoleCode.values.firstWhere(
      (role) => role.name == code,
      orElse: () => RoleCode.unknown,
    );
  }
}
