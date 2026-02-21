import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/users/data/datasources/user_management_remote_data_source.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository implementation for admin user management operations.
class UserManagementRepositoryImpl {
  UserManagementRepositoryImpl(this._dataSource);

  final UserManagementRemoteDataSource _dataSource;

  /// Fetches a paginated list of all users.
  Future<Either<Failure, List<AppUser>>> getUsers({
    required int page,
  }) async {
    try {
      final users = await _dataSource.getUsers(page: page);
      return Right(users);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Updates a user's role and enforces new RBAC permissions immediately.
  Future<Either<Failure, void>> updateUserRole(
    String userId,
    String role,
  ) async {
    try {
      await _dataSource.updateUserRole(userId, role);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Deactivates a user account, preventing login and cancelling active bookings.
  Future<Either<Failure, void>> deactivateUser(String userId) async {
    try {
      await _dataSource.deactivateUser(userId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}

/// Riverpod provider for [UserManagementRepositoryImpl].
final userManagementRepositoryProvider =
    Provider<UserManagementRepositoryImpl>((ref) {
  return UserManagementRepositoryImpl(
    ref.watch(userManagementRemoteDataSourceProvider),
  );
});
