import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:hall_booking_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of [AuthRepository] backed by Supabase Auth.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, AppUser?>> signUpWithEmailPassword(
      String email, String password, String name) async {
    try {
      final user =
          await _dataSource.signUpWithEmailPassword(email, password, name);
      return Right(user);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmailPassword(
      String email, String password) async {
    try {
      final user = await _dataSource.signInWithEmailPassword(email, password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithOtp(String email) async {
    try {
      await _dataSource.signInWithOtp(email);
      // OTP sent successfully — return a placeholder user.
      // The actual user is resolved after OTP verification.
      return Right(AppUser(
        id: '',
        role: 'user',
        name: '',
        email: email,
        phone: '',
        createdAt: DateTime.now(),
      ));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> verifyOtp(String email, String otp, {OtpType type = OtpType.email}) async {
    try {
      final user = await _dataSource.verifyOtp(email, otp, type: type);
      return Right(user);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final user = await _dataSource.signInWithGoogle();
      return Right(user);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _dataSource.authStateChanges();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      return await _dataSource.getCurrentUser();
    } catch (e) {
      return null;
    }
  }
}

/// Riverpod provider for [AuthRepositoryImpl].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});
