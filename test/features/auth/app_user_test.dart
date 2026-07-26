import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUser', () {
    final now = DateTime(2026, 7, 26);

    test('creates with required fields', () {
      final user = AppUser(
        id: '1',
        username: 'admin',
        fullName: 'Administrator',
        roleId: 'role-1',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(user.id, '1');
      expect(user.username, 'admin');
      expect(user.fullName, 'Administrator');
      expect(user.roleId, 'role-1');
      expect(user.isActive, true);
    });

    test('copyWith creates new instance with changes', () {
      final user = AppUser(
        id: '1',
        username: 'admin',
        fullName: 'Administrator',
        roleId: 'role-1',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final updated = user.copyWith(fullName: 'Super Admin');
      expect(updated.fullName, 'Super Admin');
      expect(user.fullName, 'Administrator'); // original unchanged
    });

    test('copyWith preserves unchanged fields', () {
      final user = AppUser(
        id: '1',
        username: 'admin',
        fullName: 'Administrator',
        roleId: 'role-1',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final updated = user.copyWith(isActive: false);
      expect(updated.id, user.id);
      expect(updated.username, user.username);
      expect(updated.isActive, false);
    });

    test('equality based on props', () {
      final user1 = AppUser(
        id: '1',
        username: 'admin',
        fullName: 'Administrator',
        roleId: 'role-1',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final user2 = AppUser(
        id: '1',
        username: 'admin',
        fullName: 'Administrator',
        roleId: 'role-1',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(user1, equals(user2));
    });

    test('inequality with different data', () {
      final user1 = AppUser(
        id: '1',
        username: 'admin',
        fullName: 'Administrator',
        roleId: 'role-1',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final user2 = AppUser(
        id: '2',
        username: 'user',
        fullName: 'User',
        roleId: 'role-2',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      expect(user1, isNot(equals(user2)));
    });
  });
}
