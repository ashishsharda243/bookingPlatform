import 'package:dartz/dartz.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/slot.dart';

abstract class BookingRepository {
  Future<Either<Failure, List<Slot>>> getAvailableSlots({
    required String hallId,
    required DateTime date,
  });

  Future<Either<Failure, Booking>> createBooking({
    required String hallId,
    required String slotId,
  });

  Future<Either<Failure, List<Booking>>> getUserBookings({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, Booking>> cancelBooking(String bookingId);
}
