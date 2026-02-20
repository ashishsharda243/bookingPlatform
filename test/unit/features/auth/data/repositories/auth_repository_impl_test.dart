import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hall_booking_platform/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  final tUser = AppUser(
    id: 'user-123',
    role: 'user',
    name: 'Test User',
    phone: '+919876543210',
    email: 'test@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  group('signInWithOtp', () {
    test('returns Right with placeholder AppUser when OTP is sent', () async {
      when(() => mockDataSource.signInWithOtp('+919876543210'))
          .thenAnswer((_) async {});

      final result = await repository.signInWithOtp('+919876543210');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (user) {
          expect(user.phone, '+919876543210');
          expect(user.role, 'user');
        },
      );
      verify(() => mockDataSource.signInWithOtp('+919876543210')).called(1);
    });

    test('returns Left AuthFailure when AuthException is thrown', () async {
      when(() => mockDataSource.signInWithOtp(any()))
          .thenThrow(const AuthException('Rate limit exceeded'));

      final result = await repository.signInWithOtp('+919876543210');

      expect(result, isA<Left<Failure, AppUser>>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left UnknownFailure on unexpected error', () async {
      when(() => mockDataSource.signInWithOtp(any()))
          .thenThrow(Exception('Network error'));

      final result = await repository.signInWithOtp('+919876543210');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('verifyOtp', () {
    test('returns Right with AppUser on successful verification', () async {
      when(() => mockDataSource.verifyOtp('+919876543210', '123456'))
          .thenAnswer((_) async => tUser);

      final result = await repository.verifyOtp('+919876543210', '123456');

      expect(result, Right(tUser));
      verify(() => mockDataSource.verifyOtp('+919876543210', '123456'))
          .called(1);
    });

    test('returns Left AuthFailure on invalid OTP', () async {
      when(() => mockDataSource.verifyOtp(any(), any()))
          .thenThrow(const AuthException('Invalid OTP'));

      final result = await repository.verifyOtp('+919876543210', '000000');

      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect((failure as AuthFailure).message, 'Invalid OTP');
        },
        (_) => fail('Expected Left'),
      );
    });
  });

  group('signInWithGoogle', () {
    test('returns Right with AppUser on successful Google sign-in', () async {
      when(() => mockDataSource.signInWithGoogle())
          .thenAnswer((_) async => tUser);

      final result = await repository.signInWithGoogle();

      expect(result, Right(tUser));
    });

    test('returns Left AuthFailure when Google sign-in is cancelled', () async {
      when(() => mockDataSource.signInWithGoogle())
          .thenThrow(const AuthException('Google sign-in was cancelled.'));

      final result = await repository.signInWithGoogle();

      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(
            (failure as AuthFailure).message,
            'Google sign-in was cancelled.',
          );
        },
        (_) => fail('Expected Left'),
      );
    });
  });

  group('signOut', () {
    test('returns Right(null) on successful sign-out', () async {
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Right(null));
      verify(() => mockDataSource.signOut()).called(1);
    });

    test('returns Left AuthFailure on sign-out error', () async {
      when(() => mockDataSource.signOut())
          .thenThrow(const AuthException('Sign out failed'));

      final result = await repository.signOut();

      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('authStateChanges', () {
    test('emits AppUser when auth state has a session', () {
      when(() => mockDataSource.authStateChanges())
          .thenAnswer((_) => Stream.value(tUser));

      final stream = repository.authStateChanges();

      expect(stream, emits(tUser));
    });

    test('emits null when auth state has no session', () {
      when(() => mockDataSource.authStateChanges())
          .thenAnswer((_) => Stream.value(null));

      final stream = repository.authStateChanges();

      expect(stream, emits(null));
    });
  });
}
