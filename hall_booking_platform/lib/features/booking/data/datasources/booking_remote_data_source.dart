import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/slot.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for booking operations using Supabase.
class BookingRemoteDataSource {
  BookingRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Fetches available slots for a [hallId] on a given [date].
  /// Queries the `slots` table filtered by hall_id and date.
  Future<List<Slot>> getSlotsByHallAndDate({
    required String hallId,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final response = await _client
        .from('slots')
        .select()
        .eq('hall_id', hallId)
        .eq('date', dateStr)
        .order('start_time');

    return (response as List<dynamic>).map((json) {
      final map = Map<String, dynamic>.from(json as Map);
      return Slot.fromJson(map);
    }).toList();
  }

  /// Creates a booking by calling the `create_booking` RPC function.
  /// The RPC handles slot locking and atomic state transition.
  /// Returns the created booking ID.
  Future<String> createBooking({
    required String userId,
    required String hallId,
    required String slotId,
    required double totalPrice,
  }) async {
    final response = await _client.rpc('create_booking', params: {
      'p_user_id': userId,
      'p_hall_id': hallId,
      'p_slot_id': slotId,
      'p_total_price': totalPrice,
    });

    // The RPC returns the booking UUID directly
    return response as String;
  }

  /// Fetches the user's booking history with joins to halls and slots.
  /// Results are sorted by created_at descending (newest first).
  Future<List<Booking>> getUserBookings({
    required String userId,
    required int page,
    required int pageSize,
  }) async {
    final offset = (page - 1) * pageSize;

    final response = await _client
        .from('bookings')
        .select('*, halls(*), slots(*), users(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);

    return (response as List<dynamic>).map((json) {
      final map = Map<String, dynamic>.from(json as Map);
      _mapJoinedRelations(map);
      return Booking.fromJson(map);
    }).toList();
  }

  /// Fetches a single booking by [bookingId] with hall and slot details.
  Future<Booking> getBookingById(String bookingId) async {
    final response = await _client
        .from('bookings')
        .select('*, halls(*), slots(*), users(*)')
        .eq('id', bookingId)
        .single();

    final map = Map<String, dynamic>.from(response);
    _mapJoinedRelations(map);
    return Booking.fromJson(map);
  }

  /// Cancels a booking by updating its status and releasing the slot.
  Future<void> cancelBooking(String bookingId, String slotId) async {
    // Update booking status to cancelled
    await _client
        .from('bookings')
        .update({'booking_status': 'cancelled'}).eq('id', bookingId);

    // Release the slot back to available
    await _client
        .from('slots')
        .update({'status': 'available'}).eq('id', slotId);
  }

  /// Fetches the base price for a hall.
  Future<double> getHallBasePrice(String hallId) async {
    final response = await _client
        .from('halls')
        .select('base_price')
        .eq('id', hallId)
        .single();

    final price = response['base_price'];
    if (price == null) return 0.0;
    return (price is int) ? price.toDouble() : (price as num).toDouble();
  }

  /// Maps Supabase joined relation keys to the Freezed entity field names.
  void _mapJoinedRelations(Map<String, dynamic> map) {
    // Map 'halls' join to 'hall' for the Booking entity
    if (map.containsKey('halls') && map['halls'] != null) {
      map['hall'] = map.remove('halls');
    }

    // Map 'slots' join to 'slot' for the Booking entity
    if (map.containsKey('slots') && map['slots'] != null) {
      map['slot'] = map.remove('slots');
    }

    // Map 'users' join to 'user' for the Booking entity
    if (map.containsKey('users') && map['users'] != null) {
      map['user'] = map.remove('users');
    }
  }
}

/// Riverpod provider for [BookingRemoteDataSource].
final bookingRemoteDataSourceProvider =
    Provider<BookingRemoteDataSource>((ref) {
  return BookingRemoteDataSource(ref.watch(supabaseClientProvider));
});
