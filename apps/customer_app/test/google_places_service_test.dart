import 'package:customer_app/src/core/services/google_places_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GooglePlacesService Unit Tests', () {
    late GooglePlacesService service;

    setUp(() {
      service = GooglePlacesService();
    });

    test('generateSessionToken produces valid 32-character hex token', () {
      final token1 = GooglePlacesService.generateSessionToken();
      final token2 = GooglePlacesService.generateSessionToken();

      expect(token1.length, 32);
      expect(token2.length, 32);
      expect(token1, isNot(equals(token2)));
      // Check hex characters
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(token1), isTrue);
      // Check UUID v4 version nibble at position 12
      expect(token1[12], equals('4'));
    });

    test('searchPredictions with empty query returns default operating landmarks', () async {
      final predictions = await service.searchPredictions('');
      expect(predictions.isNotEmpty, isTrue);
      expect(
        predictions.any((p) => p.mainText.contains('Shaganu') || p.mainText.contains('Remo')),
        isTrue,
      );
    });

    test('searchPredictions in test/fallback filters local landmarks accurately', () async {
      final predictions = await service.searchPredictions('Shaganu');
      expect(predictions.isNotEmpty, isTrue);
      for (final p in predictions) {
        final matches = p.mainText.toLowerCase().contains('shaganu') ||
            p.description.toLowerCase().contains('shaganu');
        expect(matches, isTrue);
      }
    });

    test('getPlaceDetails resolves landmark place IDs cleanly', () async {
      final landmarkPred = (await service.searchPredictions('Shaganu')).first;
      final details = await service.getPlaceDetails(landmarkPred.placeId);

      expect(details, isNotNull);
      expect(details!.city, equals('Shaganu'));
      expect(details.state, equals('Ogun'));
      expect(details.latitude, isNonZero);
      expect(details.longitude, isNonZero);
    });

    test('reverseGeocode in test environment returns nearest landmark', () async {
      final loc = await service.reverseGeocode(
        GooglePlacesService.operatingLat,
        GooglePlacesService.operatingLng,
      );

      expect(loc.city, equals('Shaganu'));
      expect(loc.state, equals('Ogun'));
    });

    test('PlacePrediction.fromJson parses Google Places API response payload', () {
      final json = {
        'place_id': 'ChIJ_abc123',
        'description': 'Babcock University, Ilishan-Remo, Ogun, Nigeria',
        'structured_formatting': {
          'main_text': 'Babcock University',
          'secondary_text': 'Ilishan-Remo, Ogun, Nigeria',
        },
      };

      final prediction = PlacePrediction.fromJson(json);
      expect(prediction.placeId, equals('ChIJ_abc123'));
      expect(prediction.mainText, equals('Babcock University'));
      expect(prediction.secondaryText, equals('Ilishan-Remo, Ogun, Nigeria'));
      expect(prediction.description, equals('Babcock University, Ilishan-Remo, Ogun, Nigeria'));
    });

    test('googlePlacesServiceProvider is available in Riverpod container', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final placesService = container.read(googlePlacesServiceProvider);
      expect(placesService, isA<GooglePlacesService>());
    });
  });
}
