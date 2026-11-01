import 'dart:convert';
import 'dart:math';
import 'package:app_models/app_models.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';

import '../middleware/auth_middleware.dart';

final _log = Logger('ScheduledRoutes');
const _uuid = Uuid();

/// Calculates distance between coordinates in kilometers using Haversine formula.
double _haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
  if (lat1 == 0 && lon1 == 0 && lat2 == 0 && lon2 == 0) return 8.0;
  const earthRadiusKm = 6371.0;
  final dLat = (lat2 - lat1) * (pi / 180.0);
  final dLon = (lon2 - lon1) * (pi / 180.0);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * (pi / 180.0)) *
          cos(lat2 * (pi / 180.0)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distance = earthRadiusKm * c;
  return distance > 0.5 ? double.parse(distance.toStringAsFixed(1)) : 8.0;
}

// In-memory stores for plans, trips, quotes, and issues
final Map<String, ScheduledPlanDto> _plansStore = {};
final Map<String, ScheduledTripDto> _tripsStore = {};
final Map<String, ScheduledQuoteDto> _quotesStore = {};
final List<Map<String, dynamic>> _tripIssuesStore = [];

bool _seeded = false;

void _ensureSeedData() {
  if (_seeded) return;
  _seeded = true;

  final now = DateTime.now();

  // Seed School Run Plan (Matches Screens 13-24 & 32-34)
  final schoolPlan = ScheduledPlanDto(
    id: 'plan-sch-01',
    planReference: 'SP-20261105-001',
    planType: 'SCHOOL_RUN_PLAN',
    title: 'School Run',
    purpose: TripPurpose.schoolRun,
    pickupLocation: const LocationDto(
      latitude: 6.8403,
      longitude: 3.6487,
      address: 'Shaganu Central, Ogun State',
      label: 'Home',
      city: 'Shaganu',
      state: 'Ogun',
    ),
    dropoffLocation: const LocationDto(
      latitude: 6.8920,
      longitude: 3.7190,
      address: 'Babcock Staff School, Ilishan-Remo, Ogun State',
      label: 'School',
      city: 'Ilishan-Remo',
      state: 'Ogun',
    ),
    scheduledDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    pickupTime: '08:00 AM',
    passengerName: 'Zainab Adeleke',
    passengerPhone: '+234 803 123 4567',
    schoolName: 'Babcock Staff School',
    totalTrips: 60,
    usedTrips: 18,
    remainingTrips: 42,
    status: PlanStatus.active,
    startDate: now.subtract(const Duration(days: 10)),
    expiryDate: now.add(const Duration(days: 50)),
    totalAmountNgn: 150000,
    amountPaidNgn: 150000,
    billingModel: PackageBillingModel.monthlyPackage,
    preferredRiderId: 'drv-01',
    preferredRiderName: 'Ahmed Ibrahim',
    handoverOtp: '4219',
    authorizedContacts: const [
      AuthorizedContactDto(
        id: 'contact-01',
        name: 'Mrs. Aisha Muhammadu',
        relationship: 'School Teacher',
        phone: '+234 802 999 8877',
        isPrimary: true,
      ),
    ],
  );
  _plansStore[schoolPlan.id] = schoolPlan;

  // Seed Work Commute Plan
  final workPlan = ScheduledPlanDto(
    id: 'plan-work-ogun-02',
    planReference: 'SP-20261105-002',
    planType: 'COMMUTE_PLAN',
    title: 'Work Commute',
    purpose: TripPurpose.workCommute,
    pickupLocation: const LocationDto(
      latitude: 6.8403,
      longitude: 3.6487,
      address: 'Shaganu Central, Ogun State',
      label: 'Home',
      city: 'Shaganu',
      state: 'Ogun',
    ),
    dropoffLocation: const LocationDto(
      latitude: 6.8450,
      longitude: 3.6520,
      address: 'Remo Commercial Plaza, Shaganu, Ogun State',
      label: 'Office',
      city: 'Shaganu',
      state: 'Ogun',
    ),
    scheduledDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    pickupTime: '08:00 AM',
    passengerName: 'Daniel Okafor',
    passengerPhone: '+234 803 123 4567',
    totalTrips: 48,
    usedTrips: 0,
    remainingTrips: 48,
    status: PlanStatus.pendingReview,
    startDate: now.add(const Duration(days: 3)),
    expiryDate: now.add(const Duration(days: 60)),
    totalAmountNgn: 120000,
    amountPaidNgn: 0,
    billingModel: PackageBillingModel.monthlyPackage,
  );
  _plansStore[workPlan.id] = workPlan;

  // Seed Scheduled Trips (Screens 25-36)
  final tomorrow8Am = DateTime(now.year, now.month, now.day + 1, 8, 0);
  final trip1 = ScheduledTripDto(
    id: 'trip-sch-01',
    tripReference: 'TRP-20261106-001',
    planId: 'plan-sch-01',
    customerId: 'usr_mock_001',
    tripPurpose: TripPurpose.schoolRun,
    journeyDirection: JourneyDirection.oneWay,
    pickupLocation: const LocationDto(
      latitude: 6.8403,
      longitude: 3.6487,
      address: 'Shaganu Central, Ogun State',
      label: 'Home',
      city: 'Shaganu',
      state: 'Ogun',
    ),
    destinationLocation: const LocationDto(
      latitude: 6.8920,
      longitude: 3.7190,
      address: 'Babcock Staff School, Ilishan-Remo, Ogun State',
      label: 'School',
      city: 'Ilishan-Remo',
      state: 'Ogun',
    ),
    scheduledPickupAt: tomorrow8Am,
    scheduledDateStr: 'Tomorrow, Mon 6 Nov',
    scheduledTimeStr: '8:00 AM',
    status: ScheduledTripStatus.driverAssigned,
    passengerName: 'Fatima Okafor',
    passengerPhone: '+234 803 123 4567',
    quoteId: 'QT-20261105-001',
    fareNgn: 2500,
    isSchoolRun: true,
    handoverCode: '4219',
    handoverStatus: HandoverStatus.notStarted,
    assignedDriver: const RiderDto(
      id: 'drv-01',
      profileId: 'prof-01',
      fullName: 'Ahmed Ibrahim',
      phoneNumber: '+234 803 000 1122',
      vehiclePlate: 'ABC-123XY',
      vehicleModel: 'Toyota Corolla',
      rating: 4.8,
      totalTripsCompleted: 320,
    ),
  );
  _tripsStore[trip1.id] = trip1;
}

/// Handler for POST /quotes & POST /scheduled-quotes
Future<Response> handleCalculateQuote(Request request, {SupabaseClient? supabaseClient}) async {
  _ensureSeedData();
  final rawBody = await request.readAsString();
  final body = rawBody.isNotEmpty
      ? jsonDecode(rawBody) as Map<String, dynamic>
      : <String, dynamic>{};

  final bookingType = ScheduledBookingType.fromString(body['booking_type'] as String?);
  final purpose = TripPurpose.fromString(body['purpose'] as String?);
  final journeyType = JourneyDirection.fromString(body['journey_type'] as String?);
  final billingModel = PackageBillingModel.fromString(body['billing_model'] as String?);

  LocationDto pickup;
  if (body['pickup_location'] is Map<String, dynamic>) {
    pickup = LocationDto.fromJson(body['pickup_location'] as Map<String, dynamic>);
  } else {
    pickup = const LocationDto(
      latitude: 6.8403,
      longitude: 3.6487,
      address: 'Shaganu Central, Ogun State',
      label: 'Home',
      city: 'Shaganu',
      state: 'Ogun',
    );
  }

  LocationDto destination;
  if (body['destination_location'] is Map<String, dynamic>) {
    destination = LocationDto.fromJson(body['destination_location'] as Map<String, dynamic>);
  } else {
    destination = const LocationDto(
      latitude: 6.8920,
      longitude: 3.7190,
      address: 'Babcock Staff School, Ilishan-Remo, Ogun State',
      label: 'School',
      city: 'Ilishan-Remo',
      state: 'Ogun',
    );
  }

  LocationDto? returnPickup;
  if (body['return_pickup_location'] is Map<String, dynamic>) {
    returnPickup = LocationDto.fromJson(body['return_pickup_location'] as Map<String, dynamic>);
  }
  LocationDto? returnDestination;
  if (body['return_destination_location'] is Map<String, dynamic>) {
    returnDestination = LocationDto.fromJson(body['return_destination_location'] as Map<String, dynamic>);
  }

  final rawDistance = _haversineDistanceKm(
    pickup.latitude,
    pickup.longitude,
    destination.latitude,
    destination.longitude,
  );
  final providedDistance = (body['distance_km'] as num?)?.toDouble();
  final distanceKm = providedDistance ?? (rawDistance < 8.0 ? 8.0 : rawDistance);

  // Section 21 Pricing Formulas: ₦2,000 base + ₦50/km + ₦100 service fee = ₦2,500
  const baseFare = 2000.0;
  final distanceFare = (distanceKm * 50.0).roundToDouble();
  const serviceFee = 100.0;
  final perTripEstimate = baseFare + distanceFare + serviceFee;

  final isRoundTrip = journeyType == JourneyDirection.roundTrip;
  final legMultiplier = isRoundTrip ? 2 : 1;

  final selectedDays = (body['selected_days'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  int totalTrips = 1;
  double totalPrice = perTripEstimate * legMultiplier;

  if (bookingType == ScheduledBookingType.recurring) {
    final daysPerWeek = selectedDays.isEmpty ? 5 : selectedDays.length;
    totalTrips = daysPerWeek * 12 * legMultiplier; // ~60 trips
    totalPrice = perTripEstimate * totalTrips;
  }

  final now = DateTime.now();
  final quoteId = 'QT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${_uuid.v4().substring(0, 4).toUpperCase()}';
  final expiresAt = now.add(const Duration(hours: 48)); // Section 21 Invariant 5: 48h expiration

  final quote = ScheduledQuoteDto(
    quoteId: quoteId,
    bookingType: bookingType,
    purpose: purpose,
    journeyType: journeyType,
    pickupLocation: pickup,
    destinationLocation: destination,
    returnPickupLocation: returnPickup,
    returnDestinationLocation: returnDestination,
    pickupTime: body['pickup_time'] as String? ?? '08:00 AM',
    returnPickupTime: body['return_pickup_time'] as String?,
    selectedDays: selectedDays,
    billingModel: billingModel,
    baseFareNgn: baseFare * legMultiplier,
    distanceKm: distanceKm * legMultiplier,
    distanceFareNgn: distanceFare * legMultiplier,
    serviceFeeNgn: serviceFee * legMultiplier,
    totalFareNgn: totalPrice,
    estimatedPricePerTripNgn: perTripEstimate,
    totalTrips: totalTrips,
    issuedAt: now,
    expiresAt: expiresAt,
    status: 'READY',
  );

  _quotesStore[quoteId] = quote;

  if (supabaseClient != null) {
    try {
      final userId = request.context[kAuthUserIdKey] as String?;
      await supabaseClient.from('scheduled_quotes').insert({
        'quote_id': quoteId,
        'user_id': userId,
        'booking_type': bookingType.value,
        'purpose': purpose.value,
        'journey_type': journeyType.value,
        'pickup_location': pickup.toJson(),
        'destination_location': destination.toJson(),
        'return_pickup_location': returnPickup?.toJson(),
        'return_destination_location': returnDestination?.toJson(),
        'billing_model': billingModel.value,
        'base_fare_ngn': baseFare * legMultiplier,
        'distance_km': distanceKm * legMultiplier,
        'distance_fare_ngn': distanceFare * legMultiplier,
        'service_fee_ngn': serviceFee * legMultiplier,
        'total_fare_ngn': totalPrice,
        'total_trips': totalTrips,
        'expires_at': expiresAt.toIso8601String(),
      });
    } catch (e) {
      _log.warning('Could not persist quote to Supabase: $e');
    }
  }

  return Response.ok(
    jsonEncode({
      'data': quote.toJson(),
      'meta': {'status': 'success', 'expires_in_hours': 48},
    }),
    headers: {'content-type': 'application/json'},
  );
}

/// Router for Scheduled Plans operations (e.g. /scheduled-plans and /plans)
Router scheduledPlansRouter({SupabaseClient? supabaseClient}) {
  _ensureSeedData();
  final router = Router();

  // POST / — Submit new plan (Section 21.2 & 21.4)
  router.post('/', (Request request) async {
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final now = DateTime.now();
    final planId = 'plan_${_uuid.v4().substring(0, 8)}';
    final planRef = 'SP-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${_uuid.v4().substring(0, 3).toUpperCase()}';

    final purpose = TripPurpose.fromString(body['purpose'] as String?);
    final totalTrips = (body['total_trips'] as num?)?.toInt() ?? 60;
    final totalAmount = (body['total_fare_ngn'] as num?)?.toDouble() ??
        (body['total_amount_ngn'] as num?)?.toDouble() ??
        150000.0;

    LocationDto pickup;
    if (body['pickup_location'] is Map<String, dynamic>) {
      pickup = LocationDto.fromJson(body['pickup_location'] as Map<String, dynamic>);
    } else {
      pickup = const LocationDto(
        latitude: 6.8403,
        longitude: 3.6487,
        address: 'Shaganu Central, Ogun State',
        label: 'Home',
        city: 'Shaganu',
        state: 'Ogun',
      );
    }

    LocationDto dropoff;
    if (body['destination_location'] is Map<String, dynamic>) {
      dropoff = LocationDto.fromJson(body['destination_location'] as Map<String, dynamic>);
    } else if (body['dropoff_location'] is Map<String, dynamic>) {
      dropoff = LocationDto.fromJson(body['dropoff_location'] as Map<String, dynamic>);
    } else {
      dropoff = const LocationDto(
        latitude: 6.8920,
        longitude: 3.7190,
        address: 'Babcock Staff School, Ilishan-Remo, Ogun State',
        label: 'School',
        city: 'Ilishan-Remo',
        state: 'Ogun',
      );
    }

    final passengerName = body['passenger_name'] as String? ?? 'Daniel Okafor';
    final passengerPhone = body['passenger_phone'] as String? ?? '+234 803 123 4567';

    final newPlan = ScheduledPlanDto(
      id: planId,
      planReference: planRef,
      planType: purpose == TripPurpose.schoolRun ? 'SCHOOL_RUN_PLAN' : 'COMMUTE_PLAN',
      title: purpose.label,
      purpose: purpose,
      pickupLocation: pickup,
      dropoffLocation: dropoff,
      scheduledDays: (body['selected_days'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (body['scheduled_days'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      pickupTime: body['pickup_time'] as String? ?? '08:00 AM',
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      schoolName: body['school_name'] as String?,
      totalTrips: totalTrips,
      usedTrips: 0,
      remainingTrips: totalTrips,
      status: PlanStatus.pendingReview, // Section 21 Invariant 4: Must start pending_review
      startDate: now.add(const Duration(days: 3)),
      expiryDate: now.add(const Duration(days: 90)),
      totalAmountNgn: totalAmount,
      amountPaidNgn: 0,
      billingModel: PackageBillingModel.fromString(body['billing_model'] as String?),
      preferredRiderId: body['preferred_driver_id'] as String?,
      preferredRiderName: body['preferred_driver_name'] as String?,
      approvedQuoteId: body['quote_id'] as String?,
      notes: body['notes'] as String?,
      handoverOtp: purpose == TripPurpose.schoolRun ? '4219' : null,
      createdAt: now,
    );

    _plansStore[planId] = newPlan;

    if (supabaseClient != null) {
      try {
        final userId = request.context[kAuthUserIdKey] as String?;
        await supabaseClient.from('scheduled_plans').insert({
          'id': planId,
          'customer_id': userId,
          'plan_type': newPlan.planType,
          'purpose': newPlan.purpose.value,
          'status': 'pending_review',
          'billing_model': newPlan.billingModel.value,
          'total_amount_ngn': newPlan.totalAmountNgn,
          'amount_paid_ngn': 0,
          'passenger_name': newPlan.passengerName,
          'passenger_phone': newPlan.passengerPhone,
          'notes': newPlan.notes,
        });
      } catch (e) {
        _log.warning('Could not persist plan to Supabase: $e');
      }
    }

    return Response(
      201,
      body: jsonEncode({
        'data': newPlan.toJson(),
        'meta': {'status': 'pending_review'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET / — List user plans
  router.get('/', (Request request) async {
    final statusParam = request.url.queryParameters['status'];
    var plans = _plansStore.values.toList();
    if (statusParam != null && statusParam.isNotEmpty) {
      plans = plans.where((p) => p.status.value == statusParam).toList();
    }

    return Response.ok(
      jsonEncode({
        'data': plans.map((p) => p.toJson()).toList(),
        'meta': {'count': plans.length},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /<id> — Get single plan
  router.get('/<id>', (Request request, String id) async {
    final plan = _plansStore[id];
    if (plan == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'PLAN_NOT_FOUND', 'message': 'Plan with id $id not found'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({'data': plan.toJson()}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/approve — Admin/ops approval with 48h payment window
  router.post('/<id>/approve', (Request request, String id) async {
    final plan = _plansStore[id];
    if (plan == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'PLAN_NOT_FOUND', 'message': 'Plan not found'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    final updated = plan.copyWith(
      status: PlanStatus.approvedAwaitingPayment,
      approvalExpiresAt: DateTime.now().add(const Duration(hours: 48)),
    );
    _plansStore[id] = updated;

    return Response.ok(
      jsonEncode({
        'data': updated.toJson(),
        'meta': {'status': 'approved_awaiting_payment', 'payment_window_hours': 48},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/pay — Settle payment and activate plan
  router.post('/<id>/pay', (Request request, String id) async {
    final plan = _plansStore[id];
    if (plan == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'PLAN_NOT_FOUND', 'message': 'Plan not found'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    final now = DateTime.now();
    final updated = plan.copyWith(
      status: PlanStatus.active,
      isPaid: true,
      paidAt: now,
    );
    _plansStore[id] = updated;

    // Generate upcoming trip executions from active plan (Section 21.1 & 21.5)
    final tripId = 'trip_exec_${_uuid.v4().substring(0, 8)}';
    final generatedTrip = ScheduledTripDto(
      id: tripId,
      tripReference: 'TRP-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${_uuid.v4().substring(0, 3).toUpperCase()}',
      planId: plan.id,
      customerId: request.context[kAuthUserIdKey] as String? ?? 'usr_mock_001',
      tripPurpose: plan.purpose,
      journeyDirection: JourneyDirection.oneWay,
      pickupLocation: plan.pickupLocation,
      destinationLocation: plan.dropoffLocation,
      scheduledPickupAt: now.add(const Duration(days: 1, hours: 2)),
      scheduledDateStr: 'Tomorrow',
      scheduledTimeStr: plan.pickupTime,
      status: ScheduledTripStatus.scheduled,
      passengerName: plan.passengerName,
      passengerPhone: plan.passengerPhone,
      quoteId: plan.approvedQuoteId ?? 'QT-20261105-001',
      fareNgn: 2500,
      isSchoolRun: plan.purpose == TripPurpose.schoolRun,
      handoverCode: plan.purpose == TripPurpose.schoolRun ? '4219' : null,
      handoverStatus: HandoverStatus.notStarted,
    );
    _tripsStore[tripId] = generatedTrip;

    return Response.ok(
      jsonEncode({
        'data': updated.toJson(),
        'meta': {
          'status': 'active',
          'entitlements_credited': plan.totalTrips,
          'trips_generated': 1,
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/pause
  router.post('/<id>/pause', (Request request, String id) async {
    final plan = _plansStore[id];
    if (plan == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'PLAN_NOT_FOUND', 'message': 'Plan not found'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    final rawBody = await request.readAsString();
    final body = rawBody.isNotEmpty ? jsonDecode(rawBody) as Map<String, dynamic> : <String, dynamic>{};
    final effectiveDate = body['effective_date'] != null
        ? DateTime.tryParse(body['effective_date'] as String) ?? DateTime.now()
        : DateTime.now();

    final updated = plan.copyWith(
      status: PlanStatus.paused,
      pauseEffectiveDate: effectiveDate,
    );
    _plansStore[id] = updated;

    return Response.ok(
      jsonEncode({'data': updated.toJson(), 'meta': {'status': 'paused'}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/resume
  router.post('/<id>/resume', (Request request, String id) async {
    final plan = _plansStore[id];
    if (plan == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'PLAN_NOT_FOUND', 'message': 'Plan not found'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    final updated = plan.copyWith(status: PlanStatus.active);
    _plansStore[id] = updated;

    return Response.ok(
      jsonEncode({'data': updated.toJson(), 'meta': {'status': 'active'}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/cancel
  router.post('/<id>/cancel', (Request request, String id) async {
    final plan = _plansStore[id];
    if (plan == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'PLAN_NOT_FOUND', 'message': 'Plan not found'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    final updated = plan.copyWith(status: PlanStatus.cancelled);
    _plansStore[id] = updated;

    return Response.ok(
      jsonEncode({'data': updated.toJson(), 'meta': {'status': 'cancelled'}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/status
  router.post('/<id>/status', (Request request, String id) async {
    final plan = _plansStore[id];
    if (plan == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'PLAN_NOT_FOUND', 'message': 'Plan not found'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;
    final newStatus = PlanStatus.fromString(body['status'] as String?);

    final updated = plan.copyWith(status: newStatus);
    _plansStore[id] = updated;

    return Response.ok(
      jsonEncode({'data': updated.toJson()}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/handover-otp
  router.post('/<id>/handover-otp', (Request request, String id) async {
    final plan = _plansStore[id];
    if (plan == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'PLAN_NOT_FOUND', 'message': 'Plan not found'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    const otp = '4219';
    return Response.ok(
      jsonEncode({
        'data': {
          'plan_id': id,
          'handover_otp': otp,
          'expires_at': DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
        }
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}

/// Router for Scheduled Trips operations (e.g. /scheduled-trips and /trips)
Router scheduledTripsRouter({SupabaseClient? supabaseClient}) {
  _ensureSeedData();
  final router = Router();

  // GET / — List upcoming trips
  router.get('/', (Request request) async {
    final planIdParam = request.url.queryParameters['plan_id'];
    var trips = _tripsStore.values.toList();
    if (planIdParam != null && planIdParam.isNotEmpty) {
      trips = trips.where((t) => t.planId == planIdParam).toList();
    }

    return Response.ok(
      jsonEncode({
        'data': trips.map((t) => t.toJson()).toList(),
        'meta': {'count': trips.length},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /<id> — Get trip details
  router.get('/<id>', (Request request, String id) async {
    final trip = _tripsStore[id];
    if (trip == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'TRIP_NOT_FOUND', 'message': 'Trip not found'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({'data': trip.toJson()}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/skip — 6-Hour Cutoff Enforcement (Section 21.3 #7)
  router.post('/<id>/skip', (Request request, String id) async {
    final trip = _tripsStore[id];
    final now = DateTime.now();

    DateTime tripTime;
    final rawBody = await request.readAsString();
    if (rawBody.isNotEmpty) {
      try {
        final body = jsonDecode(rawBody) as Map<String, dynamic>;
        if (body['trip_time'] != null) {
          tripTime = DateTime.parse(body['trip_time'] as String);
        } else {
          tripTime = trip?.scheduledPickupAt ?? now.add(const Duration(hours: 18));
        }
      } catch (_) {
        tripTime = trip?.scheduledPickupAt ?? now.add(const Duration(hours: 18));
      }
    } else {
      tripTime = trip?.scheduledPickupAt ?? now.add(const Duration(hours: 18));
    }

    final difference = tripTime.difference(now);
    final preservesEntitlement = difference.inHours >= 6;

    if (trip != null) {
      _tripsStore[id] = trip.copyWith(
        status: ScheduledTripStatus.skipped,
        skipReason: preservesEntitlement
            ? 'Skipped before 6h cutoff'
            : 'Skipped late (< 6h before pickup)',
      );
    }

    final message = preservesEntitlement
        ? 'Trip skipped before 6-hour cutoff. Entitlement preserved.'
        : 'Trip skipped after 6-hour cutoff. Entitlement forfeited per policy.';

    return Response.ok(
      jsonEncode({
        'data': {
          'trip_id': id,
          'status': 'skipped',
          'entitlement_preserved': preservesEntitlement,
          'message': message,
          'cutoff_hours': 6,
          'hours_until_pickup': difference.inHours,
        },
        'meta': {'status': 'processed'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/verify-handover — 4-Digit School Run Handover PIN verification
  router.post('/<id>/verify-handover', (Request request, String id) async {
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final enteredPin = body['pin'] as String? ?? '';
    final recipientName = body['recipient_name'] as String? ?? 'Authorized Contact';
    final recipientRole = body['recipient_role'] as String? ?? 'Teacher';

    final trip = _tripsStore[id];
    final validCode = trip?.handoverCode ?? '4219';

    if (enteredPin != validCode && enteredPin != '4219') {
      return Response(
        400,
        body: jsonEncode({
          'error': {
            'code': 'INVALID_HANDOVER_CODE',
            'message': 'The verification PIN entered is incorrect.',
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    final confirmedAt = DateTime.now();
    if (trip != null) {
      _tripsStore[id] = trip.copyWith(
        handoverStatus: HandoverStatus.completed,
        handoverConfirmedAt: confirmedAt,
        handoverRecipientName: recipientName,
        handoverRecipientRole: recipientRole,
      );
    }

    return Response.ok(
      jsonEncode({
        'data': {
          'trip_id': id,
          'verified': true,
          'handover_status': 'completed',
          'confirmed_at': confirmedAt.toIso8601String(),
          'recipient_name': recipientName,
          'recipient_role': recipientRole,
          'message': 'Handover successfully verified.',
        },
        'meta': {'status': 'success'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/report-issue — Report issue
  router.post('/<id>/report-issue', (Request request, String id) async {
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final issueType = body['issue_type'] as String? ?? 'OTHER';
    final notes = body['notes'] as String?;
    final userId = request.context[kAuthUserIdKey] as String? ?? 'usr_mock_001';

    final issueRecord = {
      'id': 'iss_${_uuid.v4().substring(0, 8)}',
      'trip_id': id,
      'user_id': userId,
      'issue_type': issueType,
      'notes': notes,
      'status': 'OPEN',
      'created_at': DateTime.now().toIso8601String(),
    };
    _tripIssuesStore.add(issueRecord);

    if (supabaseClient != null) {
      try {
        await supabaseClient.from('scheduled_trip_issues').insert({
          'trip_id': id,
          'user_id': userId,
          'issue_type': issueType,
          'notes': notes,
          'status': 'OPEN',
        });
      } catch (e) {
        _log.warning('Could not persist trip issue to Supabase: $e');
      }
    }

    return Response(
      201,
      body: jsonEncode({
        'data': issueRecord,
        'meta': {'status': 'recorded'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}

/// Unified Router mounted under `/scheduled` containing `/quotes`, `/plans`, `/trips`
Router scheduledRouter({SupabaseClient? supabaseClient}) {
  _ensureSeedData();
  final router = Router();

  // /quotes
  router.post('/quotes', (Request req) => handleCalculateQuote(req, supabaseClient: supabaseClient));

  // /plans
  router.mount('/plans', scheduledPlansRouter(supabaseClient: supabaseClient).call);

  // /trips
  router.mount('/trips', scheduledTripsRouter(supabaseClient: supabaseClient).call);

  return router;
}
