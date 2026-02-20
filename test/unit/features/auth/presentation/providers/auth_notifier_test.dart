import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:hall_booking_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:hall_booking_platform/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late AuthNotifier notifier;

  final tUser = AppUser(
    id: 'user-123',
    role: 'user',
    name: 'Test User',
    phone: '+919876543210',
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    when(() => mockRepo.authStateChanges())
        .thenAnswer((_) => const Stream.empty());
    notifier = AuthNotifier(mockRepo);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('sendOtp', () {
    test('sets otpSent to true on success', () async {
      when(() => mockRepo.signInWithOtp('+919876543210'))
          .thenAnswer((_) async => Right(tUser));

      await notifier.sendOtp('+919876543210');

      expect(notifier.state.otpSent, true);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });

    test('sets error on failure', () async {
      when(() => mockRepo.signInWithOtp(any())).thenAnswer(
        (_) async => const Left(Failure.auth(message: 'Rate limited')),
      );

      await notifier.sendOtp('+919876543210');

      expect(notifier.state.otpSent, false);
      expect(notifier.state.error, 'Rate limited');
    });

    test('blocks when account is locked', () async {
      // Lock the account by simulating max failed attempts.
      when(() => mockRepo.verifyOtp(any(), any())).thenAnswer(
        (_) async => const Left(Failure.auth(message: 'Invalid OTP')),
      );
      for (var i = 0; i < AppConstants.maxAuthAttempts; i++) {
        await notifier.verifyOtp('+919876543210', '000000');
      }
      expect(notifier.state.isLocked, true);

      await notifier.sendOtp('+919876543210');

      expect(notifier.state.error, contains('locked'));
      verifyNever(() => mockRepo.signInWithOtp(any()));
    });
  });

  group('verifyOtp', () {
    test('sets user on success and resets attempts', () async {
      when(() => mockRepo.verifyOtp('+919876543210', '123456'))
          .thenAnswer((_) async => Right(tUser));

      await notifier.verifyOtp('+919876543210', '123456');

      expect(notifier.state.user, tUser);
      expect(notifier.state.isAuthenticated, true);
      expect(notifier.state.failedAttempts, 0);
      expect(notifier.state.isLocked, false);
    });

    test('increments failedAttempts on failure', () async {
      when(() => mockRepo.verifyOtp(any(), any())).thenAnswer(
        (_) async => const Left(Failure.auth(message: 'Invalid OTP')),
      );

      await notifier.verifyOtp('+919876543210', '000000');

      expect(notifier.state.failedAttempts, 1);
      expect(notifier.state.isLocked, false);
    });

    test('locks account after maxAuthAttempts failures', () async {
      when(() => mockRepo.verifyOtp(any(), any())).thenAnswer(
        (_) async => const Left(Failure.auth(message: 'Invalid OTP')),
      );

      for (var i = 0; i < AppConstants.maxAuthAttempts; i++) {
        await notifier.verifyOtp('+919876543210', '000000');
      }

      expect(notifier.state.failedAttempts, AppConstants.maxAuthAttempts);
      expect(notifier.state.isLocked, true);
      expect(notifier.state.lockedUntil, isNotNull);
      expect(notifier.state.error, contains('locked'));
    });

    test('blocks verification when locked', () async {
      // Lock the account first.
      when(() => mockRepo.verifyOtp(any(), any())).thenAnswer(
        (_) async => const Left(Failure.auth(message: 'Invalid OTP')),
      );
      for (var i = 0; i < AppConstants.maxAuthAttempts; i++) {
        await notifier.verifyOtp('+919876543210', '000000');
      }

      // Reset mock call count.
      reset(mockRepo);
      when(() => mockRepo.authStateChanges())
          .thenAnswer((_) => const Stream.empty());

      await notifier.verifyOtp('+919876543210', '123456');

      expect(notifier.state.error, contains('locked'));
      verifyNever(() => mockRepo.verifyOtp(any(), any()));
    });
  });

  group('signInWithGoogle', () {
    test('sets user on success', () async {
      when(() => mockRepo.signInWithGoogle())
          .thenAnswer((_) async => Right(tUser));

      await notifier.signInWithGoogle();

      expect(notifier.state.user, tUser);
      expect(notifier.state.isAuthenticated, true);
      expect(notifier.state.isLoading, false);
    });

    test('sets error on failure', () async {
      when(() => mockRepo.signInWithGoogle()).thenAnswer(
        (_) async =>
            const Left(Failure.auth(message: 'Google sign-in cancelled')),
      );

      await notifier.signInWithGoogle();

      expect(notifier.state.error, 'Google sign-in cancelled');
      expect(notifier.state.isAuthenticated, false);
    });
  });

  group('signOut', () {
    test('clears user on success', () async {
      // Sign in first.
      when(() => mockRepo.signInWithGoogle())
          .thenAnswer((_) async => Right(tUser));
      await notifier.signInWithGoogle();
      expect(notifier.state.isAuthenticated, true);

      when(() => mockRepo.signOut())
          .thenAnswer((_) async => const Right(null));

      await notifier.signOut();

      expect(notifier.state.isAuthenticated, false);
      expect(notifier.state.user, isNull);
      expect(notifier.state.otpSent, false);
    });
  });

  group('resetOtpState', () {
    test('clears otpSent and error', () async {
      when(() => mockRepo.signInWithOtp(any()))
          .thenAnswer((_) async => Right(tUser));
      await notifier.sendOtp('+919876543210');
      expect(notifier.state.otpSent, true);

      notifier.resetOtpState();

      expect(notifier.state.otpSent, false);
      expect(notifier.state.error, isNull);
    });
  });

  group('authStateChanges listener', () {
    test('updates user when auth stream emits', () async {
      final controller = StreamController<AppUser?>();
      when(() => mockRepo.authStateChanges())
          .thenAnswer((_) => controller.stream);

      final streamNotifier = AuthNotifier(mockRepo);

      controller.add(tUser);
      await Future.delayed(Duration.zero);

      expect(streamNotifier.state.user, tUser);

      controller.add(null);
      await Future.delayed(Duration.zero);

      expect(streamNotifier.state.user, isNull);

      streamNotifier.dispose();
      await controller.close();
    });
  });
}
