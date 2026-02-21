import 'package:dartz/dartz.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';

abstract class DiscoveryRepository {
  Future<Either<Failure, List<Hall>>> getNearbyHalls({
    required double lat,
    required double lng,
    required double radiusKm,
    required int page,
    required int pageSize,
    double? minPrice,
    double? maxPrice,
    double? maxDistance,
  });

  Future<Either<Failure, List<Hall>>> searchHalls({
    required String query,
    double? lat,
    double? lng,
    required int page,
    required int pageSize,
    double? minPrice,
    double? maxPrice,
    double? maxDistance,
  });

  Future<Either<Failure, Hall>> getHallDetails(String hallId);
}
