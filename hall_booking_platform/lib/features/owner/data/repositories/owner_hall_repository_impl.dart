import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/features/owner/data/datasources/owner_hall_remote_data_source.dart';
import 'package:hall_booking_platform/features/owner/earnings/domain/entities/earnings_report.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/entities/hall_create_request.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/entities/hall_update_request.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/repositories/owner_hall_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository implementation for owner hall management.
class OwnerHallRepositoryImpl implements OwnerHallRepository {
  OwnerHallRepositoryImpl(this._dataSource);

  final OwnerHallRemoteDataSource _dataSource;

  // ... (existing getOwnerHalls, getHall, createHall, updateHall)

  Future<Either<Failure, List<Hall>>> getOwnerHalls() async {
     try {
      final halls = await _dataSource.getOwnerHalls();
      return Right(halls);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  Future<Either<Failure, Hall>> getHall(String hallId) async {
     try {
      final hall = await _dataSource.getHall(hallId);
      return Right(hall);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Hall>> createHall(HallCreateRequest request) async {
    try {
      // Validate slot duration
      if (request.slotDurationMinutes < 30 ||
          request.slotDurationMinutes > 480) {
        return const Left(Failure.validation(
          message: 'Slot duration must be between 30 and 480 minutes.',
        ));
      }
      final hall = await _dataSource.createHall(request);
      return Right(hall);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Hall>> updateHall(
    String hallId,
    HallUpdateRequest request,
  ) async {
    try {
      // Validate slot duration if provided
      if (request.slotDurationMinutes != null &&
          (request.slotDurationMinutes! < 30 ||
              request.slotDurationMinutes! > 480)) {
        return const Left(Failure.validation(
          message: 'Slot duration must be between 30 and 480 minutes.',
        ));
      }
      final hall = await _dataSource.updateHall(hallId, request);
      return Right(hall);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Soft deletes a hall.
  @override
  Future<Either<Failure, void>> deleteHall(String hallId) async {
    try {
      await _dataSource.deleteHall(hallId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Uploads images for a hall (max 10 per hall).
  @override
  Future<Either<Failure, List<String>>> uploadHallImages(
    String hallId,
    List<XFile> images,
  ) async {
    try {
      final urls = await _dataSource.uploadHallImages(hallId, images);
      return Right(urls);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on StorageException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Availability Management
  // ---------------------------------------------------------------------------

  /// Fetches all slots for a specific hall and date.
  Future<Either<Failure, List<Map<String, dynamic>>>> getSlotsByDate(
    String hallId,
    DateTime date,
  ) async {
    try {
      final slots = await _dataSource.getSlotsByDate(hallId, date);
      return Right(slots);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Fetches slot summary counts for a hall within a date range.
  Future<Either<Failure, Map<String, Map<String, int>>>> getSlotSummary(
    String hallId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final summary =
          await _dataSource.getSlotSummary(hallId, startDate, endDate);
      return Right(summary);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Blocks slots for the given hall across a date range.
  @override
  Future<Either<Failure, void>> blockSlots({
    required String hallId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final dates = <DateTime>[];
      var current = startDate;
      while (!current.isAfter(endDate)) {
        dates.add(current);
        current = current.add(const Duration(days: 1));
      }

      await _dataSource.blockSlots(hallId, dates);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.conflict(message: e.toString()));
    }
  }

  /// Unblocks slots for the given hall across a date range.
  @override
  Future<Either<Failure, void>> unblockSlots({
    required String hallId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final dates = <DateTime>[];
      var current = startDate;
      while (!current.isAfter(endDate)) {
        dates.add(current);
        current = current.add(const Duration(days: 1));
      }

      await _dataSource.unblockSlots(hallId, dates);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
  
  /// Fetches bookings for a specific hall with pagination.
  @override
  Future<Either<Failure, List<Booking>>> getHallBookings({
    required String hallId,
    required int page,
  }) async {
    try {
      final bookings = await _dataSource.getHallBookings(
        hallId: hallId,
        page: page,
      );
      return Right(bookings);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Owner Bookings
  // ---------------------------------------------------------------------------

  /// Fetches all bookings for halls owned by the current user.
  @override
  Future<Either<Failure, List<Booking>>> getOwnerBookings({
    required int page,
  }) async {
    try {
      final bookings = await _dataSource.getOwnerBookings(page: page);
      return Right(bookings);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookingStatus(
    String bookingId,
    String newStatus, {
    String? slotIdToRelease,
  }) async {
    try {
      await _dataSource.updateBookingStatus(
        bookingId,
        newStatus,
        slotIdToRelease: slotIdToRelease,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Earnings
  // ---------------------------------------------------------------------------

  /// Fetches earnings report for a specific hall.
  @override
  Future<Either<Failure, EarningsReport>> getEarnings({
    required String hallId,
    required String period,
  }) async {
    try {
      final report = await _dataSource.getEarnings(
        hallId: hallId,
        period: period,
      );
      return Right(report);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Fetches earnings report across all halls owned by the current user.
  @override
  Future<Either<Failure, EarningsReport>> getOwnerEarnings({
    required String period,
  }) async {
    try {
      final report = await _dataSource.getOwnerEarnings(period: period);
      return Right(report);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on PostgrestException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}

/// Riverpod provider for [OwnerHallRepositoryImpl].
final ownerHallRepositoryProvider = Provider<OwnerHallRepositoryImpl>((ref) {
  return OwnerHallRepositoryImpl(
    ref.watch(ownerHallRemoteDataSourceProvider),
  );
});
