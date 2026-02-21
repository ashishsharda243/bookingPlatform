import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for hall discovery operations using Supabase.
class DiscoveryRemoteDataSource {
  DiscoveryRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Calls the `get_nearby_halls` RPC to fetch halls within [radiusKm]
  /// of the given coordinates. Converts [page]/[pageSize] to offset/limit.
  Future<List<Hall>> getNearbyHalls({
    required double lat,
    required double lng,
    required double radiusKm,
    required int page,
    required int pageSize,
    double? minPrice,
    double? maxPrice,
    double? maxDistance,
  }) async {
    final offset = (page - 1) * pageSize;

    // Note: If the RPC doesn't support filtering, we might need to fetch more and filter here,
    // or update the RPC. For now assuming we filter the result list or the RPC is updated.
    // If RPC update is not possible from client, we filter the results.
    
    final response = await _client.rpc('get_nearby_halls', params: {
      'p_lat': lat,
      'p_lng': lng,
      'p_radius_km': maxDistance ?? radiusKm, // Use filter distance if provided
      'p_limit': pageSize + 50, // Fetch more to allow for filtering
      'p_offset': offset,
    });

    final data = (response as List<dynamic>?) ?? [];
    return data.map((json) {
      final map = Map<String, dynamic>.from(json as Map);
      // RPC returns distance_km; Hall entity expects distance
      if (map.containsKey('distance_km')) {
        map['distance'] = map.remove('distance_km');
      }
      return Hall.fromJson(map);
    }).where((hall) {
      if (minPrice != null && hall.basePrice < minPrice) return false;
      if (maxPrice != null && hall.basePrice > maxPrice) return false;
      if (maxDistance != null && (hall.distance ?? 0) > maxDistance) return false;
      return true;
    }).take(pageSize).toList();
  }

  /// Fetches full hall details by [hallId], including images and reviews.
  Future<Hall> getHallDetails(String hallId) async {
    try {
      final response = await _client
          .from('halls')
          .select('*, hall_images(image_url), reviews(rating)')
          .eq('id', hallId)
          .single();

      print('Hall Details Raw JSON: $response'); // DEBUG LOG

      final map = Map<String, dynamic>.from(response);

      // Handle missing lat/lng by defaulting to 0.0 if not present
      if (!map.containsKey('lat') || map['lat'] == null) {
        map['lat'] = 0.0;
      }
      if (!map.containsKey('lng') || map['lng'] == null) {
        map['lng'] = 0.0;
      }

      // Ensure amenities is List<String>
      if (map['amenities'] != null) {
        map['amenities'] = (map['amenities'] as List).map((e) => e.toString()).toList();
      } else {
        map['amenities'] = <String>[];
      }

      // Extract hall_images
      final images = map.remove('hall_images') as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        map['image_urls'] =
            images.map((img) => (img as Map)['image_url'] as String).toList();
      }

      // Extract average rating
      final reviews = map.remove('reviews') as List<dynamic>?;
      if (reviews != null && reviews.isNotEmpty) {
        final totalRating = reviews.fold<int>(
          0,
          (sum, r) => sum + ((r as Map)['rating'] as int),
        );
        final avg = totalRating / reviews.length;
        map['average_rating'] = double.parse(avg.toStringAsFixed(1));
      }

      final hall = Hall.fromJson(map);
      return hall;
    } catch (e, st) {
      print('Error parsing hall details: $e');
      print(st);
      rethrow;
    }
  }

  /// Searches halls by text matching on name, description, or address.
  /// Only returns approved halls. Supports pagination.
  Future<List<Hall>> searchHalls({
    required String query,
    double? lat,
    double? lng,
    required int page,
    required int pageSize,
    double? minPrice,
    double? maxPrice,
    double? maxDistance,
  }) async {
    final offset = (page - 1) * pageSize;
    final pattern = '%$query%';

    var request = _client
        .from('halls')
        .select('*, hall_images(image_url), reviews(rating)')
        .eq('approval_status', 'approved')
        .or('name.ilike.$pattern,description.ilike.$pattern,address.ilike.$pattern');

    if (minPrice != null) {
      request = request.gte('base_price', minPrice);
    }
    if (maxPrice != null) {
      request = request.lte('base_price', maxPrice);
    }

    final response = await request.range(offset, offset + pageSize - 1);

    final data = (response as List<dynamic>?) ?? [];
    return data.map((json) {
      final map = Map<String, dynamic>.from(json as Map);

      // Handle missing lat/lng
      if (!map.containsKey('lat') || map['lat'] == null) map['lat'] = 0.0;
      if (!map.containsKey('lng') || map['lng'] == null) map['lng'] = 0.0;

       // Ensure amenities
      if (map['amenities'] != null) {
        map['amenities'] = (map['amenities'] as List).map((e) => e.toString()).toList();
      } else {
        map['amenities'] = <String>[];
      }

      // Map joined hall_images to imageUrls list
      final images = map.remove('hall_images') as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        map['image_urls'] =
            images.map((img) => (img as Map)['image_url'] as String).toList();
      }

      // Compute average rating from joined reviews
      final reviews = map.remove('reviews') as List<dynamic>?;
      if (reviews != null && reviews.isNotEmpty) {
        final totalRating = reviews.fold<int>(
          0,
          (sum, r) => sum + ((r as Map)['rating'] as int),
        );
        final avg = totalRating / reviews.length;
        map['average_rating'] = double.parse(avg.toStringAsFixed(1));
      }

      return Hall.fromJson(map);
    }).toList();
  }
}

/// Riverpod provider for [DiscoveryRemoteDataSource].
final discoveryRemoteDataSourceProvider =
    Provider<DiscoveryRemoteDataSource>((ref) {
  return DiscoveryRemoteDataSource(ref.watch(supabaseClientProvider));
});
