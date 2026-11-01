import 'dart:convert';
import 'dart:math';
import 'package:app_models/app_models.dart';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Record holding a generated binding quote along with its requested pickup and dropoff locations.
class QuoteRecord {
  const QuoteRecord({
    required this.quote,
    required this.pickup,
    required this.dropoff,
  });

  final QuoteDto quote;
  final LocationDto pickup;
  final LocationDto dropoff;
}

/// In-memory store for active binding quotes so bookings can resolve dynamic pickup,
/// dropoff, and price breakdowns by quote ID.
final Map<String, QuoteRecord> quotesStore = {};

/// Calculates distance between two coordinates in kilometers using Haversine formula.
double _haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = (lat2 - lat1) * (pi / 180.0);
  final dLon = (lon2 - lon1) * (pi / 180.0);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * (pi / 180.0)) *
          cos(lat2 * (pi / 180.0)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

/// Handler for POST /api/v1/quotes
Future<Response> createQuoteHandler(Request request) async {
  final requestId = request.context['requestId'] as String? ?? 'unknown';
  final rawBody = await request.readAsString();
  final body = jsonDecode(rawBody) as Map<String, dynamic>;

  final serviceCode = ServiceCode.fromString(body['service_code'] as String);
  final pickup = LocationDto.fromJson(body['pickup'] as Map<String, dynamic>);
  final dropoff = LocationDto.fromJson(body['dropoff'] as Map<String, dynamic>);

  final distanceKm = max(
    1.0,
    _haversineDistanceKm(
      pickup.latitude,
      pickup.longitude,
      dropoff.latitude,
      dropoff.longitude,
    ),
  );

  // Urban Lagos average EV speed: ~22 km/h
  final durationMinutes = max(10, (distanceKm / 22.0 * 60.0).round());

  // Pricing rules per service type (all in NGN)
  final double baseFare;
  final double perKmRate;
  final double perMinuteRate;

  switch (serviceCode) {
    case ServiceCode.instantRide:
      baseFare = 400.0;
      perKmRate = 150.0;
      perMinuteRate = 25.0;
    case ServiceCode.scheduledRide:
      baseFare = 600.0;
      perKmRate = 160.0;
      perMinuteRate = 25.0;
    case ServiceCode.instantDelivery:
      baseFare = 350.0;
      perKmRate = 120.0;
      perMinuteRate = 15.0;
    case ServiceCode.scheduledPickup:
      baseFare = 500.0;
      perKmRate = 130.0;
      perMinuteRate = 15.0;
  }

  const platformFee = 50.0;
  final distanceFare = (distanceKm * perKmRate).roundToDouble();
  final timeFare = (durationMinutes * perMinuteRate).roundToDouble();
  final totalFare = (baseFare + distanceFare + timeFare + platformFee).roundToDouble();

  final quote = QuoteDto(
    quoteId: 'qt_${_uuid.v4().substring(0, 12)}',
    serviceCode: serviceCode,
    priceBreakdown: PriceBreakdownDto(
      baseFare: baseFare,
      distanceFare: distanceFare,
      timeFare: timeFare,
      platformFee: platformFee,
      totalFare: totalFare,
      currency: 'NGN',
    ),
    estimatedDurationMinutes: durationMinutes,
    estimatedDistanceKm: double.parse(distanceKm.toStringAsFixed(1)),
    expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 10)),
  );

  quotesStore[quote.quoteId] = QuoteRecord(
    quote: quote,
    pickup: pickup,
    dropoff: dropoff,
  );

  final payload = {
    'data': quote.toJson(),
    'meta': {
      'request_id': requestId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    },
  };

  return Response.ok(
    jsonEncode(payload),
    headers: {'content-type': 'application/json'},
  );
}
