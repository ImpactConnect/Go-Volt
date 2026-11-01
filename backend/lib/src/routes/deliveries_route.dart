import 'dart:convert';
import 'package:app_models/app_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// In-memory store for parcel deliveries before DB connection
final Map<String, ParcelDeliveryDto> _mockDeliveries = {};

Router deliveriesRouter() {
  final router = Router();

  // GET /catalogue (v1.4 §6.4 & §22.3)
  router.get('/catalogue', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    const catalogue = ParcelCatalogueDto();

    return Response.ok(
      jsonEncode({
        'data': catalogue.toJson(),
        'meta': {
          'request_id': requestId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /policies/current (v1.4 §6.4)
  router.get('/policies/current', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';

    return Response.ok(
      jsonEncode({
        'data': {
          'policy_version': 'v1.4',
          'restricted_items': [
            'Hazardous chemicals or flammable substances',
            'Cash, bullion, or negotiable instruments',
            'Firearms, weapons, or explosives',
            'Illegal drugs and contraband',
            'Unpackaged perishable food',
          ],
          'declared_value_policy':
              'Declaration of value does not constitute automatic insurance coverage. Maximum declaration limit is ₦500,000.',
        },
        'meta': {
          'request_id': requestId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /quotes (v1.4 §6.4 & §22.4)
  router.post('/quotes', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final deliveryOption = DeliveryOptionDto.fromJson(
      body['delivery_option'] as Map<String, dynamic>? ??
          DeliveryOptionDto.standard.toJson(),
    );
    final _ = (body['weight_kg'] as num?)?.toDouble() ?? 1.5;
    final sizeBand = ParcelSizeBandDto.fromJson(
      body['size_band'] as Map<String, dynamic>? ??
          ParcelSizeBandDto.small.toJson(),
    );
    final handling = (body['handling_options'] as List<dynamic>?)
            ?.map((e) =>
                SpecialHandlingOptionDto.fromJson(e as Map<String, dynamic>))
            .where((h) => h.isEnabled)
            .fold(0, (acc, h) => acc + h.surchargeKobo) ??
        20000;

    final baseFare = deliveryOption.baseFareKobo;
    const distanceFare = 30000; // ₦300 for 12.4 km
    final handlingFare = handling + sizeBand.surchargeKobo;
    const insuranceFare = 0;

    int discountKobo = 0;
    final coupon = body['coupon_code'] as String?;
    if (coupon == 'DELIVER20' || coupon == 'GO20') {
      discountKobo = (baseFare * 0.20).round();
    }

    final quote = ParcelPriceBreakdownDto(
      baseFareKobo: baseFare,
      distanceFareKobo: distanceFare,
      handlingFareKobo: handlingFare,
      insuranceFareKobo: insuranceFare,
      discountKobo: discountKobo,
      distanceKm: 12.4,
      estimatedMinutes: deliveryOption.code == 'EXPRESS' ? 15 : 25,
    );

    return Response.ok(
      jsonEncode({
        'data': quote.toJson(),
        'meta': {
          'request_id': requestId,
          'quote_id': 'quote_del_${_uuid.v4().substring(0, 8)}',
          'expires_at': DateTime.now()
              .toUtc()
              .add(const Duration(minutes: 15))
              .toIso8601String(),
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST / (v1.4 §6.4 & §22.5)
  router.post('/', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final deliveryId = 'del_${_uuid.v4().substring(0, 10)}';
    final tracking = 'DVL${_uuid.v4().substring(0, 8).toUpperCase()}';

    final delivery = ParcelDeliveryDto(
      id: deliveryId,
      trackingNumber: tracking,
      status: BookingStatus.assigned,
      deliveryOption: DeliveryOptionDto.fromJson(
        body['delivery_option'] as Map<String, dynamic>? ??
            DeliveryOptionDto.standard.toJson(),
      ),
      pickupLocation: LocationDto.fromJson(
        body['pickup'] as Map<String, dynamic>? ??
            const LocationDto(
              latitude: 6.4281,
              longitude: 3.4219,
              address: 'Eko Hotel and Suites, Victoria Island, Lagos',
              label: 'Eko Hotel and Suites',
            ).toJson(),
      ),
      destinationLocation: LocationDto.fromJson(
        body['dropoff'] as Map<String, dynamic>? ??
            const LocationDto(
              latitude: 6.4357,
              longitude: 3.4418,
              address: 'Palms Mall, Lekki, Lagos',
              label: 'Palms Mall',
            ).toJson(),
      ),
      recipient: RecipientDetailsDto.fromJson(
        body['recipient'] as Map<String, dynamic>? ??
            RecipientDetailsDto.defaultRecipient.toJson(),
      ),
      packageDetails: ParcelDetailsDto.fromJson(
        body['package_details'] as Map<String, dynamic>? ??
            const ParcelDetailsDto(
              category: ParcelCategoryDto.fragile,
              weightKg: 1.5,
              sizeBand: ParcelSizeBandDto.small,
            ).toJson(),
      ),
      priceBreakdown: ParcelPriceBreakdownDto.fromJson(
        body['price_breakdown'] as Map<String, dynamic>? ??
            ParcelPriceBreakdownDto.defaultBreakdown.toJson(),
      ),
      paymentMethod: PaymentMethod.fromString(
        body['payment_method'] as String? ?? 'WALLET',
      ),
      riderName: 'Daniel Okafor',
      riderPhone: '+234 802 000 1122',
      riderRating: 4.9,
      riderTotalTrips: 320,
      riderVehicle: 'Yamaha Bike - ABC-123XY',
      createdAt: DateTime.now().toUtc(),
      pickupTimestamp:
          DateTime.now().toUtc().add(const Duration(minutes: 6)),
      etaMinutes: 6,
    );

    _mockDeliveries[deliveryId] = delivery;
    _mockDeliveries[tracking] = delivery;

    return Response(
      201,
      body: jsonEncode({
        'data': delivery.toJson(),
        'meta': {
          'request_id': requestId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /<id> (v1.4 §6.4)
  router.get('/<id>', (Request request, String id) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final delivery = _mockDeliveries[id];

    if (delivery == null) {
      return Response.notFound(
        jsonEncode({
          'error': {
            'code': 'DELIVERY_NOT_FOUND',
            'message': 'No parcel delivery found for id $id',
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({
        'data': delivery.toJson(),
        'meta': {
          'request_id': requestId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/cancel (v1.4 §6.4 & §22.10)
  router.post('/<id>/cancel', (Request request, String id) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final delivery = _mockDeliveries[id];

    if (delivery == null) {
      return Response.notFound(
        jsonEncode({
          'error': {
            'code': 'DELIVERY_NOT_FOUND',
            'message': 'No parcel delivery found for id $id',
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    final updated = delivery.copyWith(status: BookingStatus.cancelled);
    _mockDeliveries[id] = updated;

    return Response.ok(
      jsonEncode({
        'data': updated.toJson(),
        'meta': {
          'request_id': requestId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/rating (v1.4 §22.2 Screen 17)
  router.post('/<id>/rating', (Request request, String id) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;
    final rating = ParcelRatingDto.fromJson(body);

    return Response.ok(
      jsonEncode({
        'data': {
          'success': true,
          'tracking_number': rating.trackingNumber,
          'rating_stars': rating.ratingStars,
        },
        'meta': {
          'request_id': requestId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}

