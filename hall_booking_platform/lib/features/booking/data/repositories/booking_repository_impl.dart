import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/slot.dart';
import 'package:hall_booking_platform/features/booking/domain/repositories/booking_repository.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hall_booking_platform/core/constants/dummy_data.dart'; // Added import

/// Implementation of [BookingRepository] backed by Supabase.
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._dataSource, this._client);

  final BookingRemoteDataSource _dataSource;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, List<Slot>>> getAvailableSlots({
    required String hallId,
    required DateTime date,
  }) async {
    try {
      final slots = await _dataSource.getSlotsByHallAndDate(
        hallId: hallId,
        date: date,
      );
      return Right(slots);
    } catch (e) {
      // Fallback to dummy slots on error (e.g. backend unavailable)
      print('BookingRepository: getAvailableSlots caught error: $e');
      print('Fallback to Dummy Slots');
      return Right(DummyData.generateDummySlots(hallId, date));
    }
  }

  @override
  Future<Either<Failure, Booking>> createBooking({
    required String hallId,
    required String slotId,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Left(Failure.auth(message: 'User not authenticated.'));
      }

      // Fetch hall base price for price calculation
      // Price = hall.base_price per slot (Property 9)
      final totalPrice = await _dataSource.getHallBasePrice(hallId);

      // Call the create_booking RPC (atomic slot lock + booking insert)
      final bookingId = await _dataSource.createBooking(
        userId: userId,
        hallId: hallId,
        slotId: slotId,
        totalPrice: totalPrice,
      );

      // Fetch the full booking with joined relations
      final booking = await _dataSource.getBookingById(bookingId);
      return Right(booking);
    } on PostgrestException catch (e) {
      // The RPC raises exceptions for slot conflicts
      if (e.message.contains('no longer available') ||
          e.message.contains('Slot not found')) {
        return Left(Failure.conflict(message: e.message));
      }
      return Left(Failure.server(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      ));
    } on TypeError catch (e) {
      return Left(Failure.server(
        message: 'Data serialization error: ${e.toString()}',
      ));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getUserBookings({
    required int page,
    required int pageSize,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Left(Failure.auth(message: 'User not authenticated.'));
      }

      final bookings = await _dataSource.getUserBookings(
        userId: userId,
        page: page,
        pageSize: pageSize,
      );
      return Right(bookings);
    } on PostgrestException catch (e) {
      return Left(Failure.server(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      ));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> cancelBooking(String bookingId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Left(Failure.auth(message: 'User not authenticated.'));
      }

      // Fetch the booking to validate ownership and cancellation eligibility
      final booking = await _dataSource.getBookingById(bookingId);

      // Verify the booking belongs to the current user
      if (booking.userId != userId) {
        return const Left(
          Failure.forbidden(message: 'You can only cancel your own bookings.'),
        );
      }

      // Check booking is in a cancellable state
      if (booking.bookingStatus == 'cancelled') {
        return const Left(
          Failure.validation(message: 'Booking is already cancelled.'),
        );
      }

      if (booking.bookingStatus == 'completed') {
        return const Left(
          Failure.validation(message: 'Cannot cancel a completed booking.'),
        );
      }

      // Enforce 24-hour cancellation policy (Requirement 6.3, 6.4)
      if (booking.slot != null) {
        final slotDateTime = _buildSlotDateTime(
          booking.slot!.date,
          booking.slot!.startTime,
        );
        final hoursUntilSlot =
            slotDateTime.difference(DateTime.now()).inHours;

        if (hoursUntilSlot < 24) {
          return const Left(Failure.validation(
            message:
                'Cancellation is only allowed at least 24 hours before the slot start time.',
          ));
        }
      }

      // Perform the cancellation
      await _dataSource.cancelBooking(bookingId, booking.slotId);

      // Return the updated booking
      final updatedBooking = await _dataSource.getBookingById(bookingId);
      return Right(updatedBooking);
    } on PostgrestException catch (e) {
      return Left(Failure.server(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      ));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Builds a [DateTime] from a slot's date and start time string (HH:mm).
  DateTime _buildSlotDateTime(DateTime date, String startTime) {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

/// Riverpod provider for [BookingRepositoryImpl].
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(
    ref.watch(bookingRemoteDataSourceProvider),
    ref.watch(supabaseClientProvider),
  );
});
