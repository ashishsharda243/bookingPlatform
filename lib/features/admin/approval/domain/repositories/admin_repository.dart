import 'package:dartz/dartz.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/analytics/domain/entities/analytics_dashboard.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<Hall>>> getPendingHalls({required int page});

  Future<Either<Failure, void>> approveHall(String hallId);

  Future<Either<Failure, void>> rejectHall(String hallId, String reason);

  Future<Either<Failure, List<AppUser>>> getUsers({required int page});

  Future<Either<Failure, void>> updateUserRole(String userId, String role);

  Future<Either<Failure, void>> deactivateUser(String userId);

  Future<Either<Failure, AnalyticsDashboard>> getAnalytics(String period);

  Future<Either<Failure, void>> setCommissionPercentage(double percentage);
}
