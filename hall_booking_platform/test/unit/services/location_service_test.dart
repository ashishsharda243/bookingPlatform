import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:hall_booking_platform/services/location_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

void main() {
  late MockGeolocatorPlatform mockPlatform;
  late LocationService service;

  setUp(() {
    mockPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockPlatform;
    service = LocationService();
  });

  group('LocationService.getCurrentLocation', () {
    test('returns success with coordinates when permission is granted', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(() => mockPlatform.getCurrentPosition(
            locationSettings: any(named: 'locationSettings'),
          )).thenAnswer((_) async => Position(
            latitude: 12.9716,
            longitude: 77.5946,
            timestamp: DateTime.now(),
            accuracy: 10.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          ));

      final result = await service.getCurrentLocation();

      expect(result.isSuccess, isTrue);
      expect(result.status, LocationResultStatus.success);
      expect(result.latitude, 12.9716);
      expect(result.longitude, 77.5946);
    });

    test('returns serviceDisabled when location services are off', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      final result = await service.getCurrentLocation();

      expect(result.isSuccess, isFalse);
      expect(result.status, LocationResultStatus.serviceDisabled);
      expect(result.latitude, isNull);
      expect(result.longitude, isNull);
    });

    test('returns denied when permission is denied after request', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(() => mockPlatform.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      final result = await service.getCurrentLocation();

      expect(result.isSuccess, isFalse);
      expect(result.status, LocationResultStatus.denied);
    });

    test('returns permanentlyDenied when permission is deniedForever', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      final result = await service.getCurrentLocation();

      expect(result.isSuccess, isFalse);
      expect(result.status, LocationResultStatus.permanentlyDenied);
    });

    test('requests permission when initially denied, succeeds on grant', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(() => mockPlatform.requestPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(() => mockPlatform.getCurrentPosition(
            locationSettings: any(named: 'locationSettings'),
          )).thenAnswer((_) async => Position(
            latitude: 40.7128,
            longitude: -74.0060,
            timestamp: DateTime.now(),
            accuracy: 5.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          ));

      final result = await service.getCurrentLocation();

      expect(result.isSuccess, isTrue);
      expect(result.latitude, 40.7128);
      expect(result.longitude, -74.0060);
      verify(() => mockPlatform.requestPermission()).called(1);
    });

    test('returns permanentlyDenied when request returns deniedForever', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(() => mockPlatform.requestPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      final result = await service.getCurrentLocation();

      expect(result.isSuccess, isFalse);
      expect(result.status, LocationResultStatus.permanentlyDenied);
    });
  });
}
