import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for admin user management operations.
class UserManagementRemoteDataSource {
  UserManagementRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Page size for paginated queries.
  static const int _pageSize = 20;

  /// Fetches a paginated list of all users, ordered by registration date.
  Future<List<AppUser>> getUsers({required int page}) async {
    final offset = (page - 1) * _pageSize;

    final data = await _client
        .from('users')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + _pageSize - 1);

    return data.map<AppUser>((row) => AppUser.fromJson(row)).toList();
  }

  /// Updates a user's role.
  Future<void> updateUserRole(String userId, String role) async {
    await _client
        .from('users')
        .update({'role': role})
        .eq('id', userId);
  }

  /// Deactivates a user account: sets is_active=false and cancels active bookings.
  Future<void> deactivateUser(String userId) async {
    // Set user as inactive
    await _client
        .from('users')
        .update({'is_active': false})
        .eq('id', userId);

    // Cancel all active bookings (pending or confirmed) for this user
    await _client
        .from('bookings')
        .update({'booking_status': 'cancelled'})
        .eq('user_id', userId)
        .inFilter('booking_status', ['pending', 'confirmed']);

    // Release the associated slots back to available
    final cancelledBookings = await _client
        .from('bookings')
        .select('slot_id')
        .eq('user_id', userId)
        .eq('booking_status', 'cancelled');

    final slotIds = cancelledBookings
        .map<String>((b) => b['slot_id'] as String)
        .toList();

    if (slotIds.isNotEmpty) {
      await _client
          .from('slots')
          .update({'status': 'available'})
          .inFilter('id', slotIds)
          .eq('status', 'booked');
    }
  }
}

/// Riverpod provider for [UserManagementRemoteDataSource].
final userManagementRemoteDataSourceProvider =
    Provider<UserManagementRemoteDataSource>((ref) {
  return UserManagementRemoteDataSource(ref.watch(supabaseClientProvider));
});
