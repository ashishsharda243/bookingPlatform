import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/commission/data/datasources/commission_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository implementation for admin commission management operations.
class CommissionRepositoryImpl {
  CommissionRepositoryImpl(this._dataSource);

  final CommissionRemoteDataSource _dataSource;

  /// Fetches the current commission percentage.
  Future<Either<Failure, double>> getCommissionPercentage() async {
    try {
      final percentage = await _dataSource.getCommissionPercentage();
      return Right(percentage);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Updates the commission percentage.
  Future<Either<Failure, void>> setCommissionPercentage(
    double percentage,
  ) async {
    try {
      await _dataSource.setCommissionPercentage(percentage);
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

/// Riverpod provider for [CommissionRepositoryImpl].
final commissionRepositoryProvider =
    Provider<CommissionRepositoryImpl>((ref) {
  return CommissionRepositoryImpl(
    ref.watch(commissionRemoteDataSourceProvider),
  );
});
