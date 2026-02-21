import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/features/admin/analytics/domain/entities/analytics_dashboard.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for admin analytics operations.
class AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Fetches analytics data for the given [period].
  ///
  /// [period] can be 'daily', 'weekly', 'monthly', or 'yearly'.
  /// Queries aggregate counts from bookings, users, and halls tables.
  Future<AnalyticsDashboard> getAnalytics(String period) async {
    final dateFilter = _dateFilterForPeriod(period);

    // Total bookings in period
    final bookingsData = await _client
        .from('bookings')
        .select('id')
        .gte('created_at', dateFilter.toIso8601String());
    final totalBookings = bookingsData.length;

    // Total revenue from confirmed bookings in period
    final revenueData = await _client
        .from('bookings')
        .select('total_price')
        .eq('booking_status', 'confirmed')
        .gte('created_at', dateFilter.toIso8601String());
    final totalRevenue = revenueData.fold<double>(
      0.0,
      (sum, row) => sum + (row['total_price'] as num).toDouble(),
    );

    // Active users (users who made bookings in period)
    final usersData = await _client
        .from('bookings')
        .select('user_id')
        .gte('created_at', dateFilter.toIso8601String());
    final activeUsers =
        usersData.map((row) => row['user_id']).toSet().length;

    // Active halls (halls that received bookings in period)
    final hallsData = await _client
        .from('bookings')
        .select('hall_id')
        .gte('created_at', dateFilter.toIso8601String());
    final activeHalls =
        hallsData.map((row) => row['hall_id']).toSet().length;

    return AnalyticsDashboard(
      totalBookings: totalBookings,
      totalRevenue: totalRevenue,
      activeUsers: activeUsers,
      activeHalls: activeHalls,
      period: period,
    );
  }

  /// Returns the start date for the given period filter.
  DateTime _dateFilterForPeriod(String period) {
    final now = DateTime.now();
    return switch (period) {
      'daily' => DateTime(now.year, now.month, now.day),
      'weekly' => now.subtract(const Duration(days: 7)),
      'monthly' => DateTime(now.year, now.month - 1, now.day),
      'yearly' => DateTime(now.year - 1, now.month, now.day),
      _ => DateTime(now.year, now.month, now.day),
    };
  }
}

/// Riverpod provider for [AnalyticsRemoteDataSource].
final analyticsRemoteDataSourceProvider =
    Provider<AnalyticsRemoteDataSource>((ref) {
  return AnalyticsRemoteDataSource(ref.watch(supabaseClientProvider));
});
