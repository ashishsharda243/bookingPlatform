import 'package:dartz/dartz.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser?>> signUpWithEmailPassword(
      String email, String password, String name);
  Future<Either<Failure, AppUser>> signInWithEmailPassword(
      String email, String password);
  Future<Either<Failure, AppUser>> signInWithOtp(String email);
  Future<Either<Failure, AppUser>> verifyOtp(String email, String otp, {OtpType type = OtpType.email});
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<AppUser?> getCurrentUser();
  Stream<AppUser?> authStateChanges();
}
