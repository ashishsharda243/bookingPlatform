import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/features/reviews/domain/entities/review.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for review operations using Supabase.
class ReviewRemoteDataSource {
  ReviewRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Checks whether the current user has a completed booking for [hallId].
  Future<bool> hasCompletedBooking({
    required String userId,
    required String hallId,
  }) async {
    final response = await _client
        .from('bookings')
        .select('id')
        .eq('user_id', userId)
        .eq('hall_id', hallId)
        .eq('booking_status', 'completed')
        .limit(1);

    return (response as List).isNotEmpty;
  }

  /// Checks whether the user already has a review for [hallId].
  Future<bool> hasExistingReview({
    required String userId,
    required String hallId,
  }) async {
    final response = await _client
        .from('reviews')
        .select('id')
        .eq('user_id', userId)
        .eq('hall_id', hallId)
        .limit(1);

    return (response as List).isNotEmpty;
  }

  /// Submits a review for a hall.
  Future<void> submitReview({
    required String userId,
    required String hallId,
    required int rating,
    String? comment,
  }) async {
    await _client.from('reviews').insert({
      'user_id': userId,
      'hall_id': hallId,
      'rating': rating,
      'comment': comment,
    });
  }

  /// Fetches paginated reviews for a hall, joined with user name.
  Future<List<Review>> getHallReviews({
    required String hallId,
    required int page,
    required int pageSize,
  }) async {
    final offset = (page - 1) * pageSize;

    final response = await _client
        .from('reviews')
        .select('*, users(name)')
        .eq('hall_id', hallId)
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);

    return (response as List<dynamic>).map((json) {
      final map = Map<String, dynamic>.from(json as Map);
      // Extract user name from the joined users relation
      if (map.containsKey('users') && map['users'] != null) {
        final user = map.remove('users') as Map<String, dynamic>;
        map['userName'] = user['name'];
      }
      return Review.fromJson(map);
    }).toList();
  }
}

/// Riverpod provider for [ReviewRemoteDataSource].
final reviewRemoteDataSourceProvider =
    Provider<ReviewRemoteDataSource>((ref) {
  return ReviewRemoteDataSource(ref.watch(supabaseClientProvider));
});
