import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gps_location_service.dart';

/// Autocomplete prediction item returned by Google Places.
class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    this.matchedSubstrings = const [],
  });

  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> matchedSubstrings;

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structured =
        json['structured_formatting'] as Map<String, dynamic>? ?? {};
    return PlacePrediction(
      placeId: json['place_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mainText: structured['main_text'] as String? ??
          json['description'] as String? ??
          '',
      secondaryText: structured['secondary_text'] as String? ?? '',
    );
  }

  factory PlacePrediction.fromLandmark(LocationDto lm) {
    return PlacePrediction(
      placeId: 'landmark_${lm.label?.replaceAll(' ', '_') ?? lm.latitude}',
      description: '${lm.label ?? 'Landmark'}, ${lm.address}',
      mainText: lm.label ?? 'Landmark',
      secondaryText: lm.address,
    );
  }
}

/// Production Google Places Autocomplete, Geocoding, and Place Details Service.
/// Implements session tokens, country & location biasing, and seamless local fallback.
class GooglePlacesService {
  GooglePlacesService({
    Dio? dio,
    String? apiKey,
  })  : _dio = dio ?? Dio(),
        _apiKey = apiKey;

  final Dio _dio;
  final String? _apiKey;

  static const String _autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String _detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const String _geocodeUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  /// Operating area default coordinates (Shaganu, Ogun State, Nigeria)
  static const double operatingLat = 6.8403;
  static const double operatingLng = 3.6487;
  static const int biasRadiusMeters = 50000; // 50km bias radius

  String get _effectiveApiKey {
    final explicitKey = _apiKey;
    if (explicitKey != null && explicitKey.isNotEmpty) return explicitKey;
    final fromConfig = AppConfig.current.googleMapsApiKey;
    if (fromConfig != null && fromConfig.isNotEmpty) return fromConfig;
    return const String.fromEnvironment('GOOGLE_MAPS_KEY', defaultValue: '');
  }

  bool get _isTestEnvironment {
    try {
      return !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// Generates a UUID v4 session token for grouping autocomplete requests into a single billing SKU.
  static String generateSessionToken() {
    final random = math.Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // version 4
    values[8] = (values[8] & 0x3f) | 0x80; // variant
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Fetches autocomplete predictions for the user's typed search query.
  /// Biased towards Nigeria and the operating city (Shaganu, Ogun State).
  Future<List<PlacePrediction>> searchPredictions(
    String query, {
    String? sessionToken,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      // Return popular landmarks as default quick choices
      return GpsLocationService.getOperatingLandmarks()
          .map(PlacePrediction.fromLandmark)
          .toList();
    }

    // In headless test environment or without API key, use local operating landmark filter
    final key = _effectiveApiKey;
    if (_isTestEnvironment || key.isEmpty || key.contains('LiveMapsKey')) {
      return _searchLocalLandmarks(trimmed);
    }

    try {
      final queryParams = <String, dynamic>{
        'input': trimmed,
        'key': key,
        'components': 'country:ng',
        'location': '$operatingLat,$operatingLng',
        'radius': biasRadiusMeters,
      };
      if (sessionToken != null) queryParams['sessiontoken'] = sessionToken;

      final response = await _dio.get<Map<String, dynamic>>(
        _autocompleteUrl,
        queryParameters: queryParams,
      ).timeout(const Duration(seconds: 4));

      final data = response.data;
      final status = data?['status'] as String?;

      if (status == 'OK' && data?['predictions'] is List) {
        final predictions = (data!['predictions'] as List)
            .map((item) =>
                PlacePrediction.fromJson(item as Map<String, dynamic>))
            .toList();

        // Also merge local operating landmarks matching the query if predictions are sparse
        final localMatches = _searchLocalLandmarks(trimmed);
        for (final local in localMatches) {
          if (!predictions.any((p) =>
              p.mainText.toLowerCase() == local.mainText.toLowerCase())) {
            predictions.add(local);
          }
        }
        return predictions;
      }

      return _searchLocalLandmarks(trimmed);
    } catch (_) {
      return _searchLocalLandmarks(trimmed);
    }
  }

  /// Fetches place details including exact coordinates and street address.
  Future<LocationDto?> getPlaceDetails(
    String placeId, {
    String? sessionToken,
  }) async {
    // Handle mock / landmark place IDs
    if (placeId.startsWith('landmark_')) {
      final label = placeId.replaceFirst('landmark_', '').replaceAll('_', ' ');
      final landmarks = GpsLocationService.getOperatingLandmarks();
      return landmarks.firstWhere(
        (lm) =>
            lm.label?.toLowerCase() == label.toLowerCase() ||
            lm.address.toLowerCase().contains(label.toLowerCase()),
        orElse: () => landmarks.first,
      );
    }

    final key = _effectiveApiKey;
    if (_isTestEnvironment || key.isEmpty || key.contains('LiveMapsKey')) {
      return null;
    }

    try {
      final queryParams = <String, dynamic>{
        'place_id': placeId,
        'key': key,
        'fields': 'geometry,name,formatted_address,address_components',
      };
      if (sessionToken != null) queryParams['sessiontoken'] = sessionToken;

      final response = await _dio.get<Map<String, dynamic>>(
        _detailsUrl,
        queryParameters: queryParams,
      ).timeout(const Duration(seconds: 4));

      final data = response.data;
      final status = data?['status'] as String?;

      if (status == 'OK' && data?['result'] is Map<String, dynamic>) {
        final result = data!['result'] as Map<String, dynamic>;
        final geometry = result['geometry'] as Map<String, dynamic>?;
        final location = geometry?['location'] as Map<String, dynamic>?;

        if (location != null) {
          final lat = (location['lat'] as num).toDouble();
          final lng = (location['lng'] as num).toDouble();
          final formattedAddress =
              result['formatted_address'] as String? ?? '';
          final name = result['name'] as String? ?? '';

          // Parse city and state from address components
          String city = 'Shaganu';
          String state = 'Ogun';
          final components = result['address_components'] as List?;
          if (components != null) {
            for (final comp in components) {
              final types = comp['types'] as List?;
              if (types != null) {
                if (types.contains('locality') ||
                    types.contains('administrative_area_level_2')) {
                  city = comp['long_name'] as String? ?? city;
                }
                if (types.contains('administrative_area_level_1')) {
                  state = comp['long_name'] as String? ?? state;
                }
              }
            }
          }

          return LocationDto(
            latitude: lat,
            longitude: lng,
            address: formattedAddress.isNotEmpty
                ? formattedAddress
                : '$name, $city, $state',
            label: name.isNotEmpty ? name : formattedAddress.split(',').first,
            city: city,
            state: state,
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Reverse geocodes a coordinate pair to a human-readable street address.
  Future<LocationDto> reverseGeocode(double lat, double lng) async {
    final key = _effectiveApiKey;
    if (_isTestEnvironment || key.isEmpty || key.contains('LiveMapsKey')) {
      return _reverseGeocodeLocal(lat, lng);
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _geocodeUrl,
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': key,
        },
      ).timeout(const Duration(seconds: 4));

      final data = response.data;
      final status = data?['status'] as String?;

      if (status == 'OK' && data?['results'] is List && (data!['results'] as List).isNotEmpty) {
        final first = (data['results'] as List).first as Map<String, dynamic>;
        final formattedAddress = first['formatted_address'] as String? ?? '';
        
        String city = 'Shaganu';
        String state = 'Ogun';
        final components = first['address_components'] as List?;
        if (components != null) {
          for (final comp in components) {
            final types = comp['types'] as List?;
            if (types != null) {
              if (types.contains('locality') ||
                  types.contains('administrative_area_level_2')) {
                city = comp['long_name'] as String? ?? city;
              }
              if (types.contains('administrative_area_level_1')) {
                state = comp['long_name'] as String? ?? state;
              }
            }
          }
        }

        return LocationDto(
          latitude: lat,
          longitude: lng,
          address: formattedAddress,
          label: formattedAddress.split(',').first,
          city: city,
          state: state,
        );
      }
      return _reverseGeocodeLocal(lat, lng);
    } catch (_) {
      return _reverseGeocodeLocal(lat, lng);
    }
  }

  List<PlacePrediction> _searchLocalLandmarks(String query) {
    final landmarks = GpsLocationService.getOperatingLandmarks();
    final lower = query.toLowerCase();
    final filtered = landmarks.where((lm) {
      final labelMatch = lm.label?.toLowerCase().contains(lower) ?? false;
      final addrMatch = lm.address.toLowerCase().contains(lower);
      return labelMatch || addrMatch;
    }).toList();

    return filtered.map(PlacePrediction.fromLandmark).toList();
  }

  LocationDto _reverseGeocodeLocal(double lat, double lng) {
    final landmarks = GpsLocationService.getOperatingLandmarks();
    for (final lm in landmarks) {
      final dLat = (lm.latitude - lat).abs();
      final dLng = (lm.longitude - lng).abs();
      if (dLat < 0.0015 && dLng < 0.0015) {
        return LocationDto(
          latitude: lat,
          longitude: lng,
          label: lm.label,
          address: lm.address,
          city: lm.city,
          state: lm.state,
        );
      }
    }

    return LocationDto(
      latitude: lat,
      longitude: lng,
      label: 'Selected Map Location',
      address:
          '${lat.toStringAsFixed(4)}°N, ${lng.toStringAsFixed(4)}°E, Shaganu, Ogun State',
      city: 'Shaganu',
      state: 'Ogun',
    );
  }
}

/// Global provider for GooglePlacesService
final googlePlacesServiceProvider = Provider<GooglePlacesService>((ref) {
  return GooglePlacesService();
});
