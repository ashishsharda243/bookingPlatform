import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the Mapbox access token from environment variables.
/// Pass via: --dart-define=MAPBOX_ACCESS_TOKEN=your-token
const _mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

/// Default Mapbox Streets style URL.
const _defaultMapStyle = 'mapbox://styles/mapbox/streets-v12';

/// Holds latitude/longitude coordinates for use with Mapbox maps.
class MapLatLng {
  const MapLatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapLatLng &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'MapLatLng($latitude, $longitude)';
}

/// Configuration for rendering a hall marker on the map.
class HallMarkerOptions {
  const HallMarkerOptions({
    required this.position,
    required this.title,
    this.iconImage = 'marker-15',
    this.iconSize = 1.5,
  });

  final MapLatLng position;
  final String title;
  final String iconImage;
  final double iconSize;
}

/// Service providing Mapbox configuration and helpers for map rendering.
///
/// The actual map widget lives in the presentation layer; this service
/// supplies the access token, style URL, and convenience methods for
/// creating map-related objects (markers, coordinates).
class MapboxService {
  /// The Mapbox access token configured via `--dart-define`.
  String get accessToken => _mapboxAccessToken;

  /// The default map style URL used across the app.
  String get defaultMapStyle => _defaultMapStyle;

  /// Creates a [MapLatLng] from raw coordinate values.
  MapLatLng latLngFrom(double latitude, double longitude) =>
      MapLatLng(latitude, longitude);

  /// Creates [HallMarkerOptions] for rendering a hall marker on the map.
  ///
  /// [latitude] and [longitude] specify the marker position.
  /// [title] is the hall name displayed alongside the marker.
  /// [iconImage] defaults to the built-in Mapbox marker icon.
  HallMarkerOptions hallMarkerOptions({
    required double latitude,
    required double longitude,
    required String title,
    String iconImage = 'marker-15',
  }) {
    return HallMarkerOptions(
      position: MapLatLng(latitude, longitude),
      title: title,
      iconImage: iconImage,
    );
  }
}

/// Riverpod provider for [MapboxService].
final mapboxServiceProvider = Provider<MapboxService>((ref) {
  return MapboxService();
});
