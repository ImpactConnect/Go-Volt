import 'dart:io';
import 'package:app_models/app_models.dart';
import 'package:geolocator/geolocator.dart';

/// Helper service for GPS positioning and landmark locations.
class GpsLocationService {
  /// Default center coordinates for set operating city: Shaganu, Ogun
  static const double defaultLat = 6.8403;
  static const double defaultLng = 3.6487;
  static const String defaultCity = 'Shaganu';
  static const String defaultState = 'Ogun';

  /// Obtains the current GPS coordinates using the device sensor.
  /// Falls back gracefully to Shaganu, Ogun center if permission is denied or device offline.
  static Future<LocationDto> getCurrentPosition({
    String label = 'Current GPS Location',
  }) async {
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST') ||
          const bool.fromEnvironment('flutter.test')) {
        return LocationDto(
          latitude: defaultLat,
          longitude: defaultLng,
          label: label,
          address: 'Shaganu, Ogun State',
        );
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationDto(
          latitude: defaultLat,
          longitude: defaultLng,
          label: label,
          address: 'Shaganu, Ogun State',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return LocationDto(
          latitude: defaultLat,
          longitude: defaultLng,
          label: label,
          address: 'Shaganu, Ogun State',
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return LocationDto(
        latitude: pos.latitude,
        longitude: pos.longitude,
        label: label,
        address:
            '${pos.latitude.toStringAsFixed(4)}°N, ${pos.longitude.toStringAsFixed(4)}°E (GPS Detected)',
      );
    } catch (_) {
      return LocationDto(
        latitude: defaultLat,
        longitude: defaultLng,
        label: label,
        address: 'Shaganu, Ogun State',
      );
    }
  }

  /// Popular landmarks in the operating city for quick 1-tap map pinning.
  static List<LocationDto> getOperatingLandmarks({
    String city = defaultCity,
    String state = defaultState,
  }) {
    return [
      LocationDto(
        latitude: 6.8403,
        longitude: 3.6487,
        label: '$city Central Roundabout',
        address: 'Central Roundabout, $city, $state',
      ),
      LocationDto(
        latitude: 6.8435,
        longitude: 3.6510,
        label: '$city Main Market',
        address: 'Market Road, $city, $state',
      ),
      LocationDto(
        latitude: 6.8380,
        longitude: 3.6450,
        label: '$city Town Hall',
        address: 'Palace Way, $city, $state',
      ),
      LocationDto(
        latitude: 6.8470,
        longitude: 3.6540,
        label: 'General Hospital $city',
        address: 'Hospital Junction, $city, $state',
      ),
      LocationDto(
        latitude: 6.8340,
        longitude: 3.6420,
        label: '$city Central Motor Park',
        address: 'Expressway Interchange, $city, $state',
      ),
      LocationDto(
        latitude: 6.8415,
        longitude: 3.6495,
        label: '$city High School Junction',
        address: 'School Road, $city, $state',
      ),
    ];
  }
}

