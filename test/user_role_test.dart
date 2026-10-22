import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/features/auth/domain/user_role.dart';

void main() {
  group('UserRole', () {
    test('exposes the six V2 roles in workspace order', () {
      expect(UserRole.values.map((role) => role.key), [
        'buyer',
        'supplier',
        'driver',
        'agent',
        'admin',
        'root',
      ]);
    });

    test('maps every role to its own workspace prefix and home path', () {
      expect(UserRole.buyer.homePath, '/buyer/home');
      expect(UserRole.supplier.homePath, '/supplier/home');
      expect(UserRole.driver.homePath, '/driver/home');
      expect(UserRole.agent.homePath, '/agent/home');
      expect(UserRole.admin.homePath, '/admin/home');
      expect(UserRole.root.homePath, '/root/home');
    });

    test('marks staff roles', () {
      expect(UserRole.agent.isStaff, isTrue);
      expect(UserRole.admin.isStaff, isTrue);
      expect(UserRole.root.isStaff, isTrue);
      expect(UserRole.buyer.isStaff, isFalse);
      expect(UserRole.supplier.isStaff, isFalse);
      expect(UserRole.driver.isStaff, isFalse);
    });

    test('exposes the self-registerable roles only', () {
      expect(UserRole.onboardingRoles, [
        UserRole.supplier,
        UserRole.buyer,
        UserRole.driver,
      ]);
      expect(UserRole.supplier.selectableForSignup, isTrue);
      expect(UserRole.buyer.selectableForSignup, isTrue);
      expect(UserRole.driver.selectableForSignup, isTrue);
      expect(UserRole.agent.selectableForSignup, isFalse);
      expect(UserRole.admin.selectableForSignup, isFalse);
      expect(UserRole.root.selectableForSignup, isFalse);
    });

    test('round-trips through documented keys', () {
      for (final role in UserRole.values) {
        expect(UserRole.values.byName(role.name), role);
      }
    });

    test('resolves legacy V1 stored role names', () {
      expect(UserRole.fromName('farmer'), UserRole.supplier);
      expect(UserRole.fromName('superAdmin'), UserRole.root);
      expect(UserRole.fromName('buyer'), UserRole.buyer);
      expect(UserRole.fromName('driver'), UserRole.driver);
      expect(UserRole.fromName('admin'), UserRole.admin);
    });
  });
}
