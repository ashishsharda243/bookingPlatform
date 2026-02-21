import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/entities/hall_create_request.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

/// Remote data source responsible for Owner Hall Management operations.
class HallManagementRemoteDataSource {
  HallManagementRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Creates a new hall in the database.
  Future<Hall> createHall(HallCreateRequest request) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not authenticated');
    }

    // Prepare data for insertion
    final hallData = {
      'owner_id': userId,
      'name': request.name,
      'description': request.description,
      'location': 'POINT(${request.lng} ${request.lat})', // PostGIS format
      'address': request.address,
      'amenities': request.amenities,
      'slot_duration_minutes': request.slotDurationMinutes,
      'base_price': request.basePrice,
      'approval_status': 'approved', // Auto-approve for now (or pending)
    };

    // Insert and select the created hall
    final response = await _client
        .from('halls')
        .insert(hallData)
        .select()
        .single();

    // The response is a Map, but we need to convert the location (which might be GeoJSON or WKT)
    // Supabase PostGIS returns location as GeoJSON by default if using select()
    // However, our Hall.fromJson expects lat/long fields which are NOT in the raw DB row
    // We need to parse the location or fetch it with ST_X/ST_Y
    // Simpler: use the RPC 'get_hall_details' or construct Hall manually from response + request

    // Let's rely on the Hall.fromJson for standard fields, but we need to manually inject lat/lng
    // because the direct insert return won't have the computed lat/lng columns unless we use a view or RPC.
    
    // Quick fix: Merge request lat/lng into the response map before parsing
    final data = Map<String, dynamic>.from(response);
    data['lat'] = request.lat;
    data['lng'] = request.lng;
    
    return Hall.fromJson(data);
  }

  /// Uploads images to Supabase Storage and returns their public URLs.
  Future<List<String>> uploadHallImages(String hallId, List<File> images) async {
    final List<String> imageUrls = [];

    for (var image in images) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final storagePath = '$hallId/$fileName';

      await _client.storage.from('hall_images').upload(
            storagePath,
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = _client.storage.from('hall_images').getPublicUrl(storagePath);
      imageUrls.add(publicUrl);
    }

    return imageUrls;
  }

  /// Inserts image URLs into the `hall_images` table.
  Future<void> addHallImagesToDb(String hallId, List<String> imageUrls) async {
    if (imageUrls.isEmpty) return;

    final records = imageUrls.map((url) => {
      'hall_id': hallId,
      'image_url': url,
    }).toList();

    await _client.from('hall_images').insert(records);
  }
}

/// Riverpod provider for [HallManagementRemoteDataSource].
final hallManagementRemoteDataSourceProvider = Provider<HallManagementRemoteDataSource>((ref) {
  return HallManagementRemoteDataSource(ref.watch(supabaseClientProvider));
});
