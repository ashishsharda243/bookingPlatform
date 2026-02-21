import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/slot.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String userId,
    required String hallId,
    required String slotId,
    @Default(0.0) double totalPrice,
    required String paymentStatus,
    required String bookingStatus,
    required DateTime createdAt,
    Hall? hall,
    Slot? slot,
    AppUser? user,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
