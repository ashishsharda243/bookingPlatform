import 'package:dartz/dartz.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/features/owner/earnings/domain/entities/earnings_report.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/entities/hall_create_request.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/entities/hall_update_request.dart';
import 'package:image_picker/image_picker.dart';

abstract class OwnerHallRepository {
  Future<Either<Failure, Hall>> createHall(HallCreateRequest request);

  Future<Either<Failure, Hall>> updateHall(
    String hallId,
    HallUpdateRequest request,
  );

  /// Soft deletes a hall.
  Future<Either<Failure, void>> deleteHall(String hallId);

  Future<Either<Failure, List<String>>> uploadHallImages(
    String hallId,
    List<XFile> images,
  );

  Future<Either<Failure, void>> blockSlots({
    required String hallId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, void>> unblockSlots({
    required String hallId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, List<Booking>>> getHallBookings({
    required String hallId,
    required int page,
  });

  Future<Either<Failure, EarningsReport>> getEarnings({
    required String hallId,
    required String period,
  });

  Future<Either<Failure, List<Booking>>> getOwnerBookings({
    required int page,
  });

  Future<Either<Failure, EarningsReport>> getOwnerEarnings({
    required String period,
  });

  Future<Either<Failure, void>> updateBookingStatus(
    String bookingId,
    String newStatus, {
    String? slotIdToRelease,
  });
}
