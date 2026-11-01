import 'dart:convert';
import 'package:app_models/app_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

import 'quotes_route.dart';

const _uuid = Uuid();

// In-memory backing store for initial scaffold before live DB connection
final Map<String, BookingDto> _mockBookings = {};

Router bookingsRouter() {
  final router = Router();

  // POST /
  router.post('/', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final bookingId = 'bk_${_uuid.v4().substring(0, 10)}';
    final refNumber = 'GV-${DateTime.now().year}-${_uuid.v4().substring(0, 4).toUpperCase()}';

    final paymentMethod = PaymentMethod.fromString(
      body['payment_method'] as String? ?? 'WALLET',
    );

    // Resolve dynamic pickup, dropoff, and pricing from active quotesStore if quote_id is supplied
    final quoteId = body['quote_id'] as String?;
    final quoteRecord = quoteId != null ? quotesStore[quoteId] : null;

    final serviceCode = quoteRecord != null
        ? quoteRecord.quote.serviceCode
        : ServiceCode.fromString(body['service_code'] as String? ?? 'RIDE_INSTANT');

    final LocationDto pickupLocation;
    if (quoteRecord != null) {
      pickupLocation = quoteRecord.pickup;
    } else if (body['pickup'] is Map<String, dynamic>) {
      pickupLocation = LocationDto.fromJson(body['pickup'] as Map<String, dynamic>);
    } else {
      pickupLocation = const LocationDto(
        latitude: 6.8403,
        longitude: 3.6487,
        address: 'Shaganu Central Hub, Shaganu, Ogun State',
        label: 'Shaganu Central',
        city: 'Shaganu',
        state: 'Ogun',
      );
    }

    final LocationDto dropoffLocation;
    if (quoteRecord != null) {
      dropoffLocation = quoteRecord.dropoff;
    } else if (body['dropoff'] is Map<String, dynamic>) {
      dropoffLocation = LocationDto.fromJson(body['dropoff'] as Map<String, dynamic>);
    } else {
      dropoffLocation = const LocationDto(
        latitude: 6.8450,
        longitude: 3.6520,
        address: 'Remo High Street, Shaganu, Ogun State',
        label: 'Remo High Street',
        city: 'Shaganu',
        state: 'Ogun',
      );
    }

    final PriceBreakdownDto priceBreakdown;
    if (quoteRecord != null) {
      priceBreakdown = quoteRecord.quote.priceBreakdown;
    } else if (body['price_breakdown'] is Map<String, dynamic>) {
      priceBreakdown = PriceBreakdownDto.fromJson(body['price_breakdown'] as Map<String, dynamic>);
    } else {
      priceBreakdown = const PriceBreakdownDto(
        baseFare: 400,
        distanceFare: 600,
        timeFare: 250,
        platformFee: 50,
        totalFare: 1300,
      );
    }

    final booking = BookingDto(
      id: bookingId,
      bookingReference: refNumber,
      serviceCode: serviceCode,
      status: BookingStatus.searchingRider,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      priceBreakdown: priceBreakdown,
      paymentMethod: paymentMethod,
      paymentStatus: PaymentStatus.authorized,
      createdAt: DateTime.now().toUtc(),
      instructions: body['instructions'] as String?,
      recipientName: body['recipient_name'] as String?,
      recipientPhone: body['recipient_phone'] as String?,
    );

    _mockBookings[bookingId] = booking;

    final payload = {
      'data': booking.toJson(),
      'meta': {
        'request_id': requestId,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
    };

    return Response(
      201,
      body: jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /
  router.get('/', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final list = _mockBookings.values.toList();

    final payload = {
      'data': list.map((b) => b.toJson()).toList(),
      'meta': {
        'request_id': requestId,
        'count': list.length,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
    };

    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /<id>
  router.get('/<id>', (Request request, String id) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final booking = _mockBookings[id];

    if (booking == null) {
      final errorPayload = {
        'error': {
          'code': 'BOOKING_NOT_FOUND',
          'message': 'Booking with id $id was not found.',
          'status_code': 404,
        },
        'meta': {'request_id': requestId},
      };
      return Response(
        404,
        body: jsonEncode(errorPayload),
        headers: {'content-type': 'application/json'},
      );
    }

    final payload = {
      'data': booking.toJson(),
      'meta': {'request_id': requestId},
    };

    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/cancel
  router.post('/<id>/cancel', (Request request, String id) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;
    final reason = body['reason'] as String? ?? 'Customer cancelled';

    final existing = _mockBookings[id];
    if (existing == null) {
      return Response(
        404,
        body: jsonEncode({
          'error': {
            'code': 'BOOKING_NOT_FOUND',
            'message': 'Booking not found.',
          },
          'meta': {'request_id': requestId},
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    final updated = BookingDto(
      id: existing.id,
      bookingReference: existing.bookingReference,
      serviceCode: existing.serviceCode,
      status: BookingStatus.cancelled,
      pickupLocation: existing.pickupLocation,
      dropoffLocation: existing.dropoffLocation,
      priceBreakdown: existing.priceBreakdown,
      paymentMethod: existing.paymentMethod,
      paymentStatus: PaymentStatus.refunded,
      createdAt: existing.createdAt,
      cancellationReason: reason,
      updatedAt: DateTime.now().toUtc(),
    );

    _mockBookings[id] = updated;

    return Response.ok(
      jsonEncode({
        'data': updated.toJson(),
        'meta': {'request_id': requestId},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
