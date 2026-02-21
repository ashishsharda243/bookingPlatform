import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:hall_booking_platform/features/admin/analytics/domain/entities/analytics_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository implementation for admin analytics operations.
class AnalyticsRepositoryImpl {
  AnalyticsRepositoryImpl(this._dataSource);

  final AnalyticsRemoteDataSource _dataSource;

  /// Fetches analytics data for the given [period].
  Future<Either<Failure, AnalyticsDashboard>> getAnalytics(
    String period,
  ) async {
    try {
      final analytics = await _dataSource.getAnalytics(period);
      return Right(analytics);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}

/// Riverpod provider for [AnalyticsRepositoryImpl].
final analyticsRepositoryProvider =
    Provider<AnalyticsRepositoryImpl>((ref) {
  return AnalyticsRepositoryImpl(
    ref.watch(analyticsRemoteDataSourceProvider),
  );
});
