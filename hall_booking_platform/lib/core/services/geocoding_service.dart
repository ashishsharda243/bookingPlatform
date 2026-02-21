import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Fetches coordinates (lat, lng) for a given [address].
  /// Returns a Map with 'lat' and 'lon' keys if found, or null otherwise.
  Future<Map<String, double>?> getCoordinates(String address) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': address,
        'format': 'json',
        'limit': '1',
      });

      // Nominatim requires a User-Agent header
      final response = await http.get(uri, headers: {
        'User-Agent': 'HallBookingPlatform/1.0',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final firstResult = data.first;
          return {
            'lat': double.parse(firstResult['lat']),
            'lng': double.parse(firstResult['lon']),
          };
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  /// Fetches the address for the given [lat] and [lng].
  /// Returns the display name if found, or null otherwise.
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      // Use the reverse geocoding API
      // https://nominatim.openstreetmap.org/reverse?lat=<value>&lon=<value>&format=json
      final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse').replace(queryParameters: {
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'json',
      });

      final response = await http.get(uri, headers: {
        'User-Agent': 'HallBookingPlatform/1.0',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('display_name')) {
          return data['display_name'] as String;
        }
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
    }
    return null;
  }
}
