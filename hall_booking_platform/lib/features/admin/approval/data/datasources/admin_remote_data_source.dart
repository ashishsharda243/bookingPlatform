import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for admin hall approval operations.
class AdminRemoteDataSource {
  AdminRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Page size for paginated queries.
  static const int _pageSize = 20;

  /// Fetches halls with approval_status='pending', sorted by submission date.
  Future<List<Hall>> getPendingHalls({required int page}) async {
    final offset = (page - 1) * _pageSize;

    final data = await _client
        .from('halls')
        .select()
        .eq('approval_status', 'pending')
        .order('created_at', ascending: true)
        .range(offset, offset + _pageSize - 1);

    return data.map<Hall>((row) => _hallFromRow(row)).toList();
  }

  /// Approves a hall by setting approval_status to 'approved'.
  Future<void> approveHall(String hallId) async {
    await _client
        .from('halls')
        .update({'approval_status': 'approved'})
        .eq('id', hallId);
  }

  /// Rejects a hall by setting approval_status to 'rejected'.
  ///
  /// Also sends a notification to the hall owner with the rejection reason.
  Future<void> rejectHall(String hallId, String reason) async {
    // Update the hall status
    final hallData = await _client
        .from('halls')
        .update({'approval_status': 'rejected'})
        .eq('id', hallId)
        .select('owner_id, name')
        .single();

    // Notify the hall owner via Edge Function
    final ownerId = hallData['owner_id'] as String;
    final hallName = hallData['name'] as String;

    try {
      await _client.functions.invoke(
        'send-notification',
        body: {
          'userId': ownerId,
          'title': 'Hall Rejected',
          'body': 'Your hall "$hallName" was rejected. Reason: $reason',
          'data': {
            'type': 'hall_rejected',
            'hallId': hallId,
            'reason': reason,
          },
        },
      );
    } catch (_) {
      // Notification failure should not block the rejection operation.
    }
  }

  /// Converts a database row to a [Hall] entity.
  Hall _hallFromRow(Map<String, dynamic> row) {
    final lat = row['lat'] as double? ?? 0.0;
    final lng = row['lng'] as double? ?? 0.0;

    return Hall(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      name: row['name'] as String,
      description: row['description'] as String? ?? '',
      lat: lat,
      lng: lng,
      address: row['address'] as String,
      amenities: (row['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      slotDurationMinutes: row['slot_duration_minutes'] as int,
      basePrice: (row['base_price'] as num).toDouble(),
      approvalStatus: row['approval_status'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

/// Riverpod provider for [AdminRemoteDataSource].
final adminRemoteDataSourceProvider =
    Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSource(ref.watch(supabaseClientProvider));
});
