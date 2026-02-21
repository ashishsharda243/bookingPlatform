import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/users/data/repositories/user_management_repository_impl.dart';
import 'package:hall_booking_platform/features/admin/users/presentation/providers/user_management_providers.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:mocktail/mocktail.dart';

class MockUserManagementRepositoryImpl extends Mock
    implements UserManagementRepositoryImpl {}

void main() {
  late MockUserManagementRepositoryImpl mockRepository;

  setUp(() {
    mockRepository = MockUserManagementRepositoryImpl();
  });

  AppUser _makeUser(String id, {String role = 'user', bool isActive = true}) {
    return AppUser(
      id: id,
      role: role,
      name: 'User $id',
      phone: '+919000000$id',
      email: '$id@example.com',
      isActive: isActive,
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('UserManagementNotifier', () {
    test('loadUsers sets users on success', () async {
      final users = [_makeUser('u1'), _makeUser('u2')];
      when(() => mockRepository.getUsers(page: 1))
          .thenAnswer((_) async => Right(users));

      final notifier = UserManagementNotifier(mockRepository);

      await notifier.loadUsers();

      expect(notifier.state.users.length, 2);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
      expect(notifier.state.currentPage, 1);
    });

    test('loadUsers sets error on failure', () async {
      when(() => mockRepository.getUsers(page: 1)).thenAnswer(
        (_) async =>
            const Left(Failure.server(message: 'Server error')),
      );

      final notifier = UserManagementNotifier(mockRepository);

      await notifier.loadUsers();

      expect(notifier.state.users, isEmpty);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, 'Server error');
    });

    test('loadMore appends users to existing list', () async {
      final page1 = List.generate(20, (i) => _makeUser('u$i'));
      final page2 = [_makeUser('u20')];

      when(() => mockRepository.getUsers(page: 1))
          .thenAnswer((_) async => Right(page1));
      when(() => mockRepository.getUsers(page: 2))
          .thenAnswer((_) async => Right(page2));

      final notifier = UserManagementNotifier(mockRepository);

      await notifier.loadUsers();
      expect(notifier.state.users.length, 20);
      expect(notifier.state.hasMore, true);

      await notifier.loadMore();
      expect(notifier.state.users.length, 21);
      expect(notifier.state.currentPage, 2);
      expect(notifier.state.hasMore, false);
    });

    test('loadMore does nothing when hasMore is false', () async {
      when(() => mockRepository.getUsers(page: 1))
          .thenAnswer((_) async => Right([_makeUser('u1')]));

      final notifier = UserManagementNotifier(mockRepository);

      await notifier.loadUsers();
      expect(notifier.state.hasMore, false);

      await notifier.loadMore();
      verifyNever(() => mockRepository.getUsers(page: 2));
    });

    test('updateUserRole updates user role in list on success', () async {
      final users = [
        _makeUser('u1', role: 'user'),
        _makeUser('u2', role: 'user'),
      ];
      when(() => mockRepository.getUsers(page: 1))
          .thenAnswer((_) async => Right(users));
      when(() => mockRepository.updateUserRole('u1', 'admin'))
          .thenAnswer((_) async => const Right(null));

      final notifier = UserManagementNotifier(mockRepository);

      await notifier.loadUsers();
      await notifier.updateUserRole('u1', 'admin');

      expect(notifier.state.users[0].role, 'admin');
      expect(notifier.state.users[1].role, 'user');
      expect(notifier.state.isProcessing, false);
      expect(notifier.state.successMessage, 'User role updated successfully.');
    });

    test('updateUserRole sets error on failure', () async {
      final users = [_makeUser('u1')];
      when(() => mockRepository.getUsers(page: 1))
          .thenAnswer((_) async => Right(users));
      when(() => mockRepository.updateUserRole('u1', 'admin')).thenAnswer(
        (_) async =>
            const Left(Failure.auth(message: 'Not authorized')),
      );

      final notifier = UserManagementNotifier(mockRepository);

      await notifier.loadUsers();
      await notifier.updateUserRole('u1', 'admin');

      expect(notifier.state.users[0].role, 'user');
      expect(notifier.state.error, 'Not authorized');
      expect(notifier.state.isProcessing, false);
    });

    test('deactivateUser sets isActive=false in list on success', () async {
      final users = [_makeUser('u1'), _makeUser('u2')];
      when(() => mockRepository.getUsers(page: 1))
          .thenAnswer((_) async => Right(users));
      when(() => mockRepository.deactivateUser('u1'))
          .thenAnswer((_) async => const Right(null));

      final notifier = UserManagementNotifier(mockRepository);

      await notifier.loadUsers();
      await notifier.deactivateUser('u1');

      expect(notifier.state.users[0].isActive, false);
      expect(notifier.state.users[1].isActive, true);
      expect(notifier.state.isProcessing, false);
      expect(
          notifier.state.successMessage, 'User deactivated successfully.');
    });

    test('deactivateUser sets error on failure', () async {
      final users = [_makeUser('u1')];
      when(() => mockRepository.getUsers(page: 1))
          .thenAnswer((_) async => Right(users));
      when(() => mockRepository.deactivateUser('u1')).thenAnswer(
        (_) async =>
            const Left(Failure.server(message: 'DB error')),
      );

      final notifier = UserManagementNotifier(mockRepository);

      await notifier.loadUsers();
      await notifier.deactivateUser('u1');

      expect(notifier.state.users[0].isActive, true);
      expect(notifier.state.error, 'DB error');
    });

    test('clearError clears error state', () async {
      when(() => mockRepository.getUsers(page: 1)).thenAnswer(
        (_) async =>
            const Left(Failure.server(message: 'Error')),
      );

      final notifier = UserManagementNotifier(mockRepository);

      await notifier.loadUsers();
      expect(notifier.state.error, 'Error');

      notifier.clearError();
      expect(notifier.state.error, isNull);
    });

    test('clearSuccess clears success message', () async {
      final users = [_makeUser('u1')];
      when(() => mockRepository.getUsers(page: 1))
          .thenAnswer((_) async => Right(users));
      when(() => mockRepository.deactivateUser('u1'))
          .thenAnswer((_) async => const Right(null));

      final notifier = UserManagementNotifier(mockRepository);

      await notifier.loadUsers();
      await notifier.deactivateUser('u1');
      expect(notifier.state.successMessage, isNotNull);

      notifier.clearSuccess();
      expect(notifier.state.successMessage, isNull);
    });
  });
}
