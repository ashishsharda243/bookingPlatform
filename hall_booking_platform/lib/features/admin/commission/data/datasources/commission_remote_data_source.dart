import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for admin commission management operations.
class CommissionRemoteDataSource {
  CommissionRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Fetches the current commission percentage from platform_config.
  Future<double> getCommissionPercentage() async {
    final data = await _client
        .from('platform_config')
        .select('value')
        .eq('key', 'commission_percentage')
        .single();

    final value = data['value'];
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    // JSONB value stored as raw number or string
    return double.parse(value.toString());
  }

  /// Updates the commission percentage in platform_config.
  Future<void> setCommissionPercentage(double percentage) async {
    await _client
        .from('platform_config')
        .update({
          'value': percentage.toString(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('key', 'commission_percentage');
  }
}

/// Riverpod provider for [CommissionRemoteDataSource].
final commissionRemoteDataSourceProvider =
    Provider<CommissionRemoteDataSource>((ref) {
  return CommissionRemoteDataSource(ref.watch(supabaseClientProvider));
});
