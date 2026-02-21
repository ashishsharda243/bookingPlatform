import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/users/data/datasources/user_management_remote_data_source.dart';
import 'package:hall_booking_platform/features/admin/users/data/repositories/user_management_repository_impl.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockUserManagementRemoteDataSource extends Mock
    implements UserManagementRemoteDataSource {}

void main() {
  late MockUserManagementRemoteDataSource mockDataSource;
  late UserManagementRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockUserManagementRemoteDataSource();
    repository = UserManagementRepositoryImpl(mockDataSource);
  });

  AppUser _makeUser(String id, {String role = 'user', bool isActive = true}) {
    return AppUser(
      id: id,
      role: role,
      name: 'User $id',
      phone: '+91900000000$id',
      email: '$id@example.com',
      isActive: isActive,
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('getUsers', () {
    test('returns list of users on success', () async {
      final users = [_makeUser('1'), _makeUser('2')];
      when(() => mockDataSource.getUsers(page: 1))
          .thenAnswer((_) async => users);

      final result = await repository.getUsers(page: 1);

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.length, 2);
          expect(data[0].id, '1');
          expect(data[1].id, '2');
        },
      );
    });

    test('returns AuthFailure on AuthException', () async {
      when(() => mockDataSource.getUsers(page: 1))
          .thenThrow(const AuthException('Not authenticated'));

      final result = await repository.getUsers(page: 1);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.getUsers(page: 1))
          .thenThrow(PostgrestException(message: 'DB error'));

      final result = await repository.getUsers(page: 1);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure on unexpected exception', () async {
      when(() => mockDataSource.getUsers(page: 1))
          .thenThrow(Exception('Unexpected'));

      final result = await repository.getUsers(page: 1);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('updateUserRole', () {
    test('returns Right(null) on success', () async {
      when(() => mockDataSource.updateUserRole('u1', 'admin'))
          .thenAnswer((_) async {});

      final result = await repository.updateUserRole('u1', 'admin');

      expect(result, isA<Right>());
      verify(() => mockDataSource.updateUserRole('u1', 'admin')).called(1);
    });

    test('returns AuthFailure on AuthException', () async {
      when(() => mockDataSource.updateUserRole('u1', 'admin'))
          .thenThrow(const AuthException('Forbidden'));

      final result = await repository.updateUserRole('u1', 'admin');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.updateUserRole('u1', 'admin'))
          .thenThrow(PostgrestException(message: 'Invalid role'));

      final result = await repository.updateUserRole('u1', 'admin');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure on unexpected exception', () async {
      when(() => mockDataSource.updateUserRole('u1', 'admin'))
          .thenThrow(Exception('Oops'));

      final result = await repository.updateUserRole('u1', 'admin');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('deactivateUser', () {
    test('returns Right(null) on success', () async {
      when(() => mockDataSource.deactivateUser('u1'))
          .thenAnswer((_) async {});

      final result = await repository.deactivateUser('u1');

      expect(result, isA<Right>());
      verify(() => mockDataSource.deactivateUser('u1')).called(1);
    });

    test('returns AuthFailure on AuthException', () async {
      when(() => mockDataSource.deactivateUser('u1'))
          .thenThrow(const AuthException('Unauthorized'));

      final result = await repository.deactivateUser('u1');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.deactivateUser('u1'))
          .thenThrow(PostgrestException(message: 'DB error'));

      final result = await repository.deactivateUser('u1');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure on unexpected exception', () async {
      when(() => mockDataSource.deactivateUser('u1'))
          .thenThrow(Exception('Unexpected'));

      final result = await repository.deactivateUser('u1');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
