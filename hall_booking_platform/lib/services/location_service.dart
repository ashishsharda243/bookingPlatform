import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Result of a location request, indicating success or the reason for failure.
enum LocationResultStatus {
  /// Location was successfully retrieved.
  success,

  /// Location services are disabled on the device.
  serviceDisabled,

  /// The user denied location permission.
  denied,

  /// The user permanently denied location permission.
  permanentlyDenied,
}

/// Holds the outcome of a location request.
class LocationResult {
  const LocationResult._({
    required this.status,
    this.latitude,
    this.longitude,
  });

  factory LocationResult.success({
    required double latitude,
    required double longitude,
  }) =>
      LocationResult._(
        status: LocationResultStatus.success,
        latitude: latitude,
        longitude: longitude,
      );

  factory LocationResult.serviceDisabled() =>
      const LocationResult._(status: LocationResultStatus.serviceDisabled);

  factory LocationResult.denied() =>
      const LocationResult._(status: LocationResultStatus.denied);

  factory LocationResult.permanentlyDenied() =>
      const LocationResult._(status: LocationResultStatus.permanentlyDenied);

  final LocationResultStatus status;
  final double? latitude;
  final double? longitude;

  bool get isSuccess => status == LocationResultStatus.success;
}

/// Service for retrieving the device GPS location via the geolocator package.
///
/// Handles permission checking, requesting, and all denial states.
/// When permission is denied or the service is disabled, callers should
/// fall back to manual address search (Requirement 2.6).
class LocationService {
  /// Checks and requests location permission, then retrieves the current
  /// GPS position. Returns a [LocationResult] indicating the outcome.
  Future<LocationResult> getCurrentLocation() async {
    // 1. Check if location services are enabled.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationResult.serviceDisabled();
    }

    // 2. Check current permission status.
    var permission = await Geolocator.checkPermission();

    // 3. If not yet determined, request permission.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationResult.denied();
      }
    }

    // 4. Handle permanently denied — user must enable via app settings.
    if (permission == LocationPermission.deniedForever) {
      return LocationResult.permanentlyDenied();
    }

    // 5. Permission granted — retrieve position.
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return LocationResult.success(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

/// Riverpod provider for [LocationService].
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
