import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/approval/data/datasources/admin_remote_data_source.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository implementation for admin hall approval operations.
class AdminRepositoryImpl {
  AdminRepositoryImpl(this._dataSource);

  final AdminRemoteDataSource _dataSource;

  /// Fetches halls with approval_status='pending', sorted by submission date.
  Future<Either<Failure, List<Hall>>> getPendingHalls({
    required int page,
  }) async {
    try {
      final halls = await _dataSource.getPendingHalls(page: page);
      return Right(halls);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Approves a hall by setting approval_status to 'approved'.
  Future<Either<Failure, void>> approveHall(String hallId) async {
    try {
      await _dataSource.approveHall(hallId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Rejects a hall with a reason, notifying the hall owner.
  Future<Either<Failure, void>> rejectHall(
    String hallId,
    String reason,
  ) async {
    try {
      await _dataSource.rejectHall(hallId, reason);
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

/// Riverpod provider for [AdminRepositoryImpl].
final adminRepositoryProvider = Provider<AdminRepositoryImpl>((ref) {
  return AdminRepositoryImpl(ref.watch(adminRemoteDataSourceProvider));
});
