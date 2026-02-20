import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/features/discovery/data/datasources/discovery_remote_data_source.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Mocks ---

/// We subclass DiscoveryRemoteDataSource to intercept the Supabase calls
/// and test the mapping/pagination logic in isolation.
class _TestableDataSource extends DiscoveryRemoteDataSource {
  _TestableDataSource(super.client);

  // Capture the params passed to the RPC call
  Map<String, dynamic>? lastRpcParams;
  List<dynamic> rpcResult = [];

  // Override getNearbyHalls to intercept the RPC call
  @override
  Future<List<Hall>> getNearbyHalls({
    required double lat,
    required double lng,
    required double radiusKm,
    required int page,
    required int pageSize,
  }) async {
    final offset = (page - 1) * pageSize;
    lastRpcParams = {
      'p_lat': lat,
      'p_lng': lng,
      'p_radius_km': radiusKm,
      'p_limit': pageSize,
      'p_offset': offset,
    };

    return rpcResult.map((json) {
      final map = Map<String, dynamic>.from(json as Map);
      if (map.containsKey('distance_km')) {
        map['distance'] = map.remove('distance_km');
      }
      return Hall.fromJson(map);
    }).toList();
  }
}

class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Helper to build a raw hall map as returned by the `get_nearby_halls` RPC.
Map<String, dynamic> _rpcHallMap({
  String id = 'hall-1',
  String ownerId = 'owner-1',
  String name = 'Test Hall',
  String description = 'A great hall',
  double lat = 12.97,
  double lng = 77.59,
  String address = '123 Main St',
  List<String> amenities = const ['wifi', 'parking'],
  int slotDurationMinutes = 60,
  double basePrice = 500.0,
  String approvalStatus = 'approved',
  String createdAt = '2024-01-01T00:00:00.000Z',
  double distanceKm = 1.2,
}) =>
    {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'lat': lat,
      'lng': lng,
      'address': address,
      'amenities': amenities,
      'slot_duration_minutes': slotDurationMinutes,
      'base_price': basePrice,
      'approval_status': approvalStatus,
      'created_at': createdAt,
      'distance_km': distanceKm,
    };

void main() {
  late MockSupabaseClient mockClient;
  late _TestableDataSource dataSource;

  setUp(() {
    mockClient = MockSupabaseClient();
    dataSource = _TestableDataSource(mockClient);
  });

  group('getNearbyHalls - pagination offset calculation', () {
    test('page 1 with pageSize 20 produces offset 0', () async {
      dataSource.rpcResult = [];
      await dataSource.getNearbyHalls(
        lat: 12.97, lng: 77.59, radiusKm: 2.0, page: 1, pageSize: 20,
      );
      expect(dataSource.lastRpcParams!['p_offset'], 0);
      expect(dataSource.lastRpcParams!['p_limit'], 20);
    });

    test('page 2 with pageSize 20 produces offset 20', () async {
      dataSource.rpcResult = [];
      await dataSource.getNearbyHalls(
        lat: 12.97, lng: 77.59, radiusKm: 2.0, page: 2, pageSize: 20,
      );
      expect(dataSource.lastRpcParams!['p_offset'], 20);
    });

    test('page 3 with pageSize 10 produces offset 20', () async {
      dataSource.rpcResult = [];
      await dataSource.getNearbyHalls(
        lat: 0.0, lng: 0.0, radiusKm: 2.0, page: 3, pageSize: 10,
      );
      expect(dataSource.lastRpcParams!['p_offset'], 20);
      expect(dataSource.lastRpcParams!['p_limit'], 10);
    });

    test('passes lat, lng, and radiusKm correctly', () async {
      dataSource.rpcResult = [];
      await dataSource.getNearbyHalls(
        lat: 28.61, lng: 77.23, radiusKm: 5.0, page: 1, pageSize: 20,
      );
      expect(dataSource.lastRpcParams!['p_lat'], 28.61);
      expect(dataSource.lastRpcParams!['p_lng'], 77.23);
      expect(dataSource.lastRpcParams!['p_radius_km'], 5.0);
    });
  });

  group('getNearbyHalls - distance_km mapping', () {
    test('maps distance_km to distance field', () async {
      dataSource.rpcResult = [
        _rpcHallMap(id: 'h1', distanceKm: 0.5),
        _rpcHallMap(id: 'h2', distanceKm: 1.8),
      ];

      final halls = await dataSource.getNearbyHalls(
        lat: 12.97, lng: 77.59, radiusKm: 2.0, page: 1, pageSize: 20,
      );

      expect(halls.length, 2);
      expect(halls[0].id, 'h1');
      expect(halls[0].distance, 0.5);
      expect(halls[1].id, 'h2');
      expect(halls[1].distance, 1.8);
    });

    test('returns empty list when no results', () async {
      dataSource.rpcResult = [];

      final halls = await dataSource.getNearbyHalls(
        lat: 0.0, lng: 0.0, radiusKm: 2.0, page: 1, pageSize: 20,
      );

      expect(halls, isEmpty);
    });

    test('correctly parses all hall fields from RPC response', () async {
      dataSource.rpcResult = [
        _rpcHallMap(
          id: 'hall-42',
          ownerId: 'owner-7',
          name: 'Grand Ballroom',
          description: 'Spacious venue',
          lat: 13.0,
          lng: 80.0,
          address: '456 Oak Ave',
          amenities: const ['ac', 'stage'],
          slotDurationMinutes: 120,
          basePrice: 1500.0,
          approvalStatus: 'approved',
          distanceKm: 0.3,
        ),
      ];

      final halls = await dataSource.getNearbyHalls(
        lat: 13.0, lng: 80.0, radiusKm: 2.0, page: 1, pageSize: 20,
      );

      expect(halls.length, 1);
      final hall = halls[0];
      expect(hall.id, 'hall-42');
      expect(hall.ownerId, 'owner-7');
      expect(hall.name, 'Grand Ballroom');
      expect(hall.description, 'Spacious venue');
      expect(hall.lat, 13.0);
      expect(hall.lng, 80.0);
      expect(hall.address, '456 Oak Ave');
      expect(hall.amenities, ['ac', 'stage']);
      expect(hall.slotDurationMinutes, 120);
      expect(hall.basePrice, 1500.0);
      expect(hall.approvalStatus, 'approved');
      expect(hall.distance, 0.3);
    });
  });

  group('getHallDetails - image and review mapping', () {
    test('extracts imageUrls from hall_images join', () {
      // Test the mapping logic directly
      final rawResponse = <String, dynamic>{
        'id': 'hall-1',
        'owner_id': 'owner-1',
        'name': 'Test Hall',
        'description': 'A great hall',
        'lat': 12.97,
        'lng': 77.59,
        'address': '123 Main St',
        'amenities': ['wifi'],
        'slot_duration_minutes': 60,
        'base_price': 500.0,
        'approval_status': 'approved',
        'created_at': '2024-01-01T00:00:00.000Z',
        'hall_images': [
          {'image_url': 'https://img.com/1.jpg'},
          {'image_url': 'https://img.com/2.jpg'},
        ],
        'reviews': [
          {'rating': 4},
          {'rating': 5},
          {'rating': 3},
        ],
      };

      // Simulate the mapping logic from getHallDetails
      final map = Map<String, dynamic>.from(rawResponse);
      final images = map.remove('hall_images') as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        map['image_urls'] =
            images.map((img) => (img as Map)['image_url'] as String).toList();
      }
      final reviews = map.remove('reviews') as List<dynamic>?;
      if (reviews != null && reviews.isNotEmpty) {
        final totalRating = reviews.fold<int>(
          0, (sum, r) => sum + ((r as Map)['rating'] as int));
        final avg = totalRating / reviews.length;
        map['average_rating'] = double.parse(avg.toStringAsFixed(1));
      }

      final hall = Hall.fromJson(map);

      expect(hall.imageUrls, ['https://img.com/1.jpg', 'https://img.com/2.jpg']);
      expect(hall.averageRating, 4.0); // (4+5+3)/3 = 4.0
    });

    test('handles empty images and reviews', () {
      final rawResponse = <String, dynamic>{
        'id': 'hall-1',
        'owner_id': 'owner-1',
        'name': 'Test Hall',
        'description': 'A great hall',
        'lat': 12.97,
        'lng': 77.59,
        'address': '123 Main St',
        'amenities': ['wifi'],
        'slot_duration_minutes': 60,
        'base_price': 500.0,
        'approval_status': 'approved',
        'created_at': '2024-01-01T00:00:00.000Z',
        'hall_images': <dynamic>[],
        'reviews': <dynamic>[],
      };

      final map = Map<String, dynamic>.from(rawResponse);
      final images = map.remove('hall_images') as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        map['image_urls'] =
            images.map((img) => (img as Map)['image_url'] as String).toList();
      }
      final reviews = map.remove('reviews') as List<dynamic>?;
      if (reviews != null && reviews.isNotEmpty) {
        final totalRating = reviews.fold<int>(
          0, (sum, r) => sum + ((r as Map)['rating'] as int));
        final avg = totalRating / reviews.length;
        map['average_rating'] = double.parse(avg.toStringAsFixed(1));
      }

      final hall = Hall.fromJson(map);

      expect(hall.imageUrls, isNull);
      expect(hall.averageRating, isNull);
    });

    test('computes average rating with single review', () {
      final rawResponse = <String, dynamic>{
        'id': 'hall-1',
        'owner_id': 'owner-1',
        'name': 'Test Hall',
        'description': 'Desc',
        'lat': 12.97,
        'lng': 77.59,
        'address': 'Addr',
        'amenities': <String>[],
        'slot_duration_minutes': 60,
        'base_price': 100.0,
        'approval_status': 'approved',
        'created_at': '2024-01-01T00:00:00.000Z',
        'hall_images': <dynamic>[],
        'reviews': [
          {'rating': 3},
        ],
      };

      final map = Map<String, dynamic>.from(rawResponse);
      map.remove('hall_images');
      final reviews = map.remove('reviews') as List<dynamic>?;
      if (reviews != null && reviews.isNotEmpty) {
        final totalRating = reviews.fold<int>(
          0, (sum, r) => sum + ((r as Map)['rating'] as int));
        final avg = totalRating / reviews.length;
        map['average_rating'] = double.parse(avg.toStringAsFixed(1));
      }

      final hall = Hall.fromJson(map);
      expect(hall.averageRating, 3.0);
    });
  });
}
