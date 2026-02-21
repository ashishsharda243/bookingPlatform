import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/discovery/data/datasources/discovery_remote_data_source.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/features/discovery/domain/repositories/discovery_repository.dart';

/// Implementation of [DiscoveryRepository] backed by Supabase.
class DiscoveryRepositoryImpl implements DiscoveryRepository {
  DiscoveryRepositoryImpl(this._dataSource);

  final DiscoveryRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<Hall>>> getNearbyHalls({
    required double lat,
    required double lng,
    required double radiusKm,
    required int page,
    required int pageSize,
    double? minPrice,
    double? maxPrice,
    double? maxDistance,
  }) async {
    try {
      final halls = await _dataSource.getNearbyHalls(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        page: page,
        pageSize: pageSize,
        minPrice: minPrice,
        maxPrice: maxPrice,
        maxDistance: maxDistance,
      );
      return Right(halls);
    } catch (e) {
      print('DiscoveryRepository: getNearbyHalls caught error: $e');
      return Left(Failure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Hall>>> searchHalls({
    required String query,
    double? lat,
    double? lng,
    required int page,
    required int pageSize,
    double? minPrice,
    double? maxPrice,
    double? maxDistance,
  }) async {
    try {
      final halls = await _dataSource.searchHalls(
        query: query,
        lat: lat,
        lng: lng,
        page: page,
        pageSize: pageSize,
        minPrice: minPrice,
        maxPrice: maxPrice,
        maxDistance: maxDistance,
      );
      return Right(halls);
    } catch (e) {
      print('DiscoveryRepository: searchHalls caught error: $e');
      return Left(Failure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Hall>> getHallDetails(String hallId) async {
    try {
      final hall = await _dataSource.getHallDetails(hallId);
      return Right(hall);
    } catch (e) {
      print('DiscoveryRepository: getHallDetails caught error: $e');
      return Left(Failure.server(message: e.toString()));
    }
  }
}

/// Riverpod provider for [DiscoveryRepositoryImpl].
final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepositoryImpl(
    ref.watch(discoveryRemoteDataSourceProvider),
  );
});
