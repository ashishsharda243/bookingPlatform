import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/services/mapbox_service.dart';

void main() {
  late MapboxService service;

  setUp(() {
    service = MapboxService();
  });

  group('MapboxService', () {
    test('defaultMapStyle returns streets-v12 style URL', () {
      expect(service.defaultMapStyle, 'mapbox://styles/mapbox/streets-v12');
    });

    test('accessToken returns value from environment', () {
      // When no --dart-define is passed, the token is an empty string.
      expect(service.accessToken, isA<String>());
    });

    test('latLngFrom creates MapLatLng with correct coordinates', () {
      final latLng = service.latLngFrom(12.9716, 77.5946);

      expect(latLng.latitude, 12.9716);
      expect(latLng.longitude, 77.5946);
    });

    test('hallMarkerOptions creates options with correct position and title',
        () {
      final options = service.hallMarkerOptions(
        latitude: 13.0827,
        longitude: 80.2707,
        title: 'Grand Hall',
      );

      expect(options.position, const MapLatLng(13.0827, 80.2707));
      expect(options.title, 'Grand Hall');
      expect(options.iconImage, 'marker-15');
      expect(options.iconSize, 1.5);
    });

    test('hallMarkerOptions accepts custom iconImage', () {
      final options = service.hallMarkerOptions(
        latitude: 0,
        longitude: 0,
        title: 'Test',
        iconImage: 'custom-icon',
      );

      expect(options.iconImage, 'custom-icon');
    });
  });

  group('MapLatLng', () {
    test('equality works for same coordinates', () {
      const a = MapLatLng(10.0, 20.0);
      const b = MapLatLng(10.0, 20.0);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality for different coordinates', () {
      const a = MapLatLng(10.0, 20.0);
      const b = MapLatLng(10.0, 21.0);

      expect(a, isNot(equals(b)));
    });

    test('toString returns readable format', () {
      const latLng = MapLatLng(12.5, 77.3);

      expect(latLng.toString(), 'MapLatLng(12.5, 77.3)');
    });
  });
}
