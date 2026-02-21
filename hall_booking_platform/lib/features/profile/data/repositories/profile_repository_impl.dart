import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:hall_booking_platform/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository implementation for profile operations.
class ProfileRepositoryImpl {
  ProfileRepositoryImpl(this._dataSource);

  final ProfileRemoteDataSource _dataSource;

  /// Fetches the current user's profile.
  Future<Either<Failure, AppUser>> getProfile() async {
    try {
      final user = await _dataSource.getProfile();
      return Right(user);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Updates the current user's profile fields.
  Future<Either<Failure, AppUser>> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      final user = await _dataSource.updateProfile(
        name: name,
        email: email,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Upgrades the current user to 'owner'.
  Future<Either<Failure, AppUser>> upgradeToOwner() async {
    try {
      final user = await _dataSource.upgradeToOwner();
      return Right(user);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Uploads a profile image and returns the public URL.
  Future<Either<Failure, String>> uploadProfileImage(
    XFile imageFile,
  ) async {
    try {
      final url = await _dataSource.uploadProfileImage(imageFile);
      return Right(url);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on StorageException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}

/// Riverpod provider for [ProfileRepositoryImpl].
final profileRepositoryProvider = Provider<ProfileRepositoryImpl>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
});
