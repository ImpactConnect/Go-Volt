import 'dart:convert';
import 'dart:math' as math;
import 'package:app_models/app_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// In-memory store for active and historical errands
final Map<String, ErrandDto> _errandsStore = {};

// Reference shops in Kaduna / Lagos
final List<ShopDto> _defaultShops = [
  const ShopDto(
    id: 'shop_01',
    name: 'Kakuri Main Market',
    address: 'Kakuri, Kaduna',
    latitude: 10.4682,
    longitude: 7.4201,
    category: 'Open Market',
    distanceKm: 1.2,
    isPopular: true,
    isSaved: true,
    phoneNumber: '+234 803 111 2233',
    operatingHours: '7:00 AM - 6:30 PM',
    rating: 4.8,
  ),
  const ShopDto(
    id: 'shop_02',
    name: 'Murtala Supermarket',
    address: 'Murtala Square, Kaduna',
    latitude: 10.5185,
    longitude: 7.4382,
    category: 'Supermarket',
    distanceKm: 2.4,
    isPopular: true,
    isSaved: false,
    phoneNumber: '+234 802 333 4455',
    operatingHours: '8:00 AM - 9:00 PM',
    rating: 4.7,
  ),
  const ShopDto(
    id: 'shop_03',
    name: 'De-West Stores',
    address: 'Agwa, Kaduna',
    latitude: 10.4921,
    longitude: 7.4112,
    category: 'Grocery Store',
    distanceKm: 3.1,
    isPopular: false,
    isSaved: false,
    phoneNumber: '+234 809 555 6677',
    operatingHours: '8:30 AM - 8:30 PM',
    rating: 4.6,
  ),
  const ShopDto(
    id: 'shop_04',
    name: 'Barnawa Central Market',
    address: 'Barnawa, Kaduna',
    latitude: 10.4850,
    longitude: 7.4420,
    category: 'Open Market',
    distanceKm: 4.0,
    isPopular: true,
    isSaved: true,
    phoneNumber: '+234 805 777 8899',
    operatingHours: '7:00 AM - 7:00 PM',
    rating: 4.9,
  ),
  const ShopDto(
    id: 'shop_05',
    name: 'Kasuwan Barchi Market',
    address: 'Tudun Wada, Kaduna',
    latitude: 10.5312,
    longitude: 7.4089,
    category: 'Textile & Goods Market',
    distanceKm: 5.5,
    isPopular: false,
    isSaved: false,
    phoneNumber: '+234 806 888 9900',
    operatingHours: '8:00 AM - 6:00 PM',
    rating: 4.5,
  ),
];

final List<ShoppingItemDto> _popularShoppingItems = [
  const ShoppingItemDto(
    id: 'item_pop_01',
    name: 'Tomatoes',
    quantity: 2,
    unit: 'kg',
    estimatedPriceKobo: 400000, // ₦4,000
    preferenceNotes: 'Fresh, medium size',
  ),
  const ShoppingItemDto(
    id: 'item_pop_02',
    name: 'Onions',
    quantity: 1,
    unit: 'kg',
    estimatedPriceKobo: 150000, // ₦1,500
    preferenceNotes: 'Dry red onions',
  ),
  const ShoppingItemDto(
    id: 'item_pop_03',
    name: 'Rice (Mama\'s Pride)',
    quantity: 1,
    unit: '5 kg bag',
    estimatedPriceKobo: 850000, // ₦8,500
    preferenceNotes: 'Well parboiled',
  ),
  const ShoppingItemDto(
    id: 'item_pop_04',
    name: 'Yam Tubers',
    quantity: 3,
    unit: 'pcs',
    estimatedPriceKobo: 450000, // ₦4,500
    preferenceNotes: 'Large Abuja yam',
  ),
  const ShoppingItemDto(
    id: 'item_pop_05',
    name: 'Vegetable Oil (Kings)',
    quantity: 1,
    unit: '2L bottle',
    estimatedPriceKobo: 420000, // ₦4,200
  ),
];

Router errandsRouter() {
  final router = Router();

  // GET /catalogue (v1.6 §2038)
  router.get('/catalogue', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';

    final catalogue = ErrandCatalogueDto(
      shops: _defaultShops,
      popularShoppingItems: _popularShoppingItems,
      packageCategories: const [
        'Electronics',
        'Fashion & Apparel',
        'Documents & Certificates',
        'Food & Bakery',
        'Fragile / Glassware',
        'Medical Supplies',
        'Household Essentials',
        'Other Package',
      ],
      customErrandCategories: const [
        'Document Collection',
        'Government / University Run',
        'Laundry & Dry Cleaning',
        'Bank / Utility Bill Run',
        'Personal Chores',
        'Equipment Pickup',
        'Other Custom Task',
      ],
      supportedUnits: const [
        'kg',
        'pcs',
        'packs',
        'bags',
        'bunches',
        'baskets',
        'litres',
        'bottles',
      ],
      weightBands: const [
        'Under 1 kg',
        '1 - 2 kg',
        '2 - 5 kg',
        '5 - 10 kg',
        '10 - 20 kg',
      ],
      sizeBands: const [
        'Small (fits in pocket/handbag)',
        'Medium (up to 50 cm)',
        'Large (box / bulk package)',
      ],
      urgencyOptions: const [
        'Standard (same day)',
        'Express (urgent)',
      ],
      defaultShoppingServiceFeeKobo: 80000, // ₦800
      defaultPackageServiceFeeKobo: 70000,  // ₦700
      defaultCustomErrandServiceFeeKobo: 100000, // ₦1,000
      deliveryRatePerKmKobo: 10000,         // ₦100/km
      baseDeliveryFareKobo: 100000,          // ₦1,000
    );

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

  // GET /shops (Screen A2: Select Shop / Market)
  router.get('/shops', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final queryParams = request.url.queryParameters;
    final search = queryParams['search']?.trim().toLowerCase() ?? '';
    final tab = queryParams['tab']?.trim().toLowerCase() ?? 'nearby';

    var results = List<ShopDto>.from(_defaultShops);

    if (tab == 'popular') {
      results = results.where((s) => s.isPopular).toList();
    } else if (tab == 'saved') {
      results = results.where((s) => s.isSaved).toList();
    }

    if (search.isNotEmpty) {
      results = results
          .where((s) =>
              s.name.toLowerCase().contains(search) ||
              s.address.toLowerCase().contains(search) ||
              s.category.toLowerCase().contains(search))
          .toList();
    }

    return Response.ok(
      jsonEncode({
        'data': results.map((s) => s.toJson()).toList(),
        'meta': {
          'request_id': requestId,
          'count': results.length,
          'tab': tab,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /quotes (v1.6 §1761-1786)
  router.post('/quotes', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final errandType = ErrandType.fromString(body['errand_type'] as String?);
    final distanceKm = (body['distance_km'] as num?)?.toDouble() ?? 2.5;

    int estimatedItemsKobo = 0;
    int serviceFeeKobo = 0;
    int deliveryFeeKobo = 0;
    int surchargesKobo = 0;

    switch (errandType) {
      case ErrandType.buyItems:
        serviceFeeKobo = 80000; // ₦800 base shopping service fee
        deliveryFeeKobo = 100000 + (distanceKm * 8000).round(); // ~₦1,200 for 2.5km
        final items = (body['items'] as List<dynamic>?) ?? [];
        for (final item in items) {
          final itemMap = item as Map<String, dynamic>;
          final estPrice = (itemMap['estimated_price_kobo'] as num?)?.toInt() ?? 0;
          final qty = (itemMap['quantity'] as num?)?.toInt() ?? 1;
          estimatedItemsKobo += estPrice * qty;
        }
        if (estimatedItemsKobo == 0) {
          estimatedItemsKobo = 1400000; // ₦14,000 baseline estimate as on design template
        }
        break;

      case ErrandType.pickupPackage:
        serviceFeeKobo = 70000; // ₦700 base package handling fee
        deliveryFeeKobo = 100000 + (distanceKm * 4000).round(); // ~₦1,100
        final isFragile = body['is_fragile'] as bool? ?? false;
        if (isFragile) {
          surchargesKobo += 20000; // ₦200 fragile care
        }
        break;

      case ErrandType.otherErrand:
        serviceFeeKobo = 100000; // ₦1,000
        deliveryFeeKobo = 100000 + (distanceKm * 8000).round(); // ~₦1,200
        final urgency = body['urgency'] as String?;
        if (urgency == 'EXPRESS') {
          surchargesKobo += 50000; // ₦500 express surcharge
        }
        break;
    }

    final totalKobo = estimatedItemsKobo + serviceFeeKobo + deliveryFeeKobo + surchargesKobo;
    final quoteId = 'quote_err_${_uuid.v4().substring(0, 8)}';

    final quote = ErrandQuoteDto(
      id: quoteId,
      errandType: errandType,
      estimatedItemsCostKobo: estimatedItemsKobo,
      serviceFeeKobo: serviceFeeKobo,
      deliveryFeeKobo: deliveryFeeKobo,
      surchargesKobo: surchargesKobo,
      totalKobo: totalKobo,
      isFinalQuote: errandType != ErrandType.buyItems,
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 15)),
      distanceKm: distanceKm,
      estimatedMinutes: (10 + (distanceKm * 4)).round(),
    );

    return Response.ok(
      jsonEncode({
        'data': quote.toJson(),
        'meta': {
          'request_id': requestId,
          'quote_id': quoteId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST / (Create errand request)
  router.post('/', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final errandId = 'err_${_uuid.v4().substring(0, 10)}';
    final randNum = 10000 + math.Random().nextInt(90000);
    final refNumber = 'ERR-$randNum';

    final errandType = ErrandType.fromString(body['type'] as String?);
    final paymentMethod = PaymentMethod.fromString(body['payment_method'] as String? ?? 'WALLET');

    // Initial status determination (v1.6 §1873-1905)
    ErrandStatus initialStatus;
    if (errandType == ErrandType.otherErrand && body['requires_manual_quote'] == true) {
      initialStatus = ErrandStatus.reviewRequired;
    } else {
      initialStatus = ErrandStatus.agentAssigned;
    }

    // Default assigned rider if active
    const rider = RiderDto(
      id: 'rider_err_01',
      profileId: 'prof_ahmed_01',
      fullName: 'Ahmed Ibrahim',
      phoneNumber: '+234 803 456 7890',
      vehicleModel: 'Yamaha EV',
      vehicleType: VehicleType.electricBike,
      vehiclePlate: 'ABC-123KY',
      batteryLevelPercent: 92,
      rating: 4.8,
      status: RiderStatus.online,
      totalTripsCompleted: 320,
    );

    final rawQuote = body['quote'] as Map<String, dynamic>?;
    final quote = rawQuote != null
        ? ErrandQuoteDto.fromJson(rawQuote)
        : ErrandQuoteDto(
            id: 'quote_${_uuid.v4().substring(0, 8)}',
            errandType: errandType,
            serviceFeeKobo: 80000,
            deliveryFeeKobo: 120000,
            totalKobo: 200000,
          );

    final errand = ErrandDto(
      id: errandId,
      referenceNumber: refNumber,
      customerId: body['customer_id'] as String? ?? 'cust_current',
      type: errandType,
      status: initialStatus,
      shop: body['shop'] != null ? ShopDto.fromJson(body['shop'] as Map<String, dynamic>) : null,
      items: (body['items'] as List<dynamic>?)
              ?.map((i) => ShoppingItemDto.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [],
      preferences: body['preferences'] != null
          ? ShoppingPreferencesDto.fromJson(body['preferences'] as Map<String, dynamic>)
          : null,
      pickupDetails: body['pickup_details'] != null
          ? PackagePickupDetailsDto.fromJson(body['pickup_details'] as Map<String, dynamic>)
          : null,
      packageDetails: body['package_details'] != null
          ? ParcelDetailsDto.fromJson(body['package_details'] as Map<String, dynamic>)
          : null,
      customErrandDetails: body['custom_errand_details'] != null
          ? CustomErrandDetailsDto.fromJson(body['custom_errand_details'] as Map<String, dynamic>)
          : null,
      deliveryLocation: LocationDto.fromJson(
        body['delivery_location'] as Map<String, dynamic>? ??
            const LocationDto(
              latitude: 10.5185,
              longitude: 7.4382,
              address: '3, Ahmadu Bello Way, Bayero University, Kaduna',
              label: 'Bayero University',
            ).toJson(),
      ),
      recipient: RecipientDetailsDto.fromJson(
        body['recipient'] as Map<String, dynamic>? ??
            const RecipientDetailsDto(
              fullName: 'Omotayo Kehinde',
              phoneNumber: '0803 456 7890',
              deliveryAddress: '3, Ahmadu Bello Way, Bayero University, Kaduna',
            ).toJson(),
      ),
      deliveryTimeStr: body['delivery_time_str'] as String? ?? 'As soon as possible',
      deliveryNotes: body['delivery_notes'] as String?,
      quote: quote,
      paymentMethod: paymentMethod,
      paymentStatus: PaymentStatus.captured,
      assignedRider: initialStatus == ErrandStatus.agentAssigned ? rider : null,
      statusTimeline: [
        {
          'status': initialStatus.code,
          'title': initialStatus == ErrandStatus.reviewRequired
              ? 'Request submitted for review'
              : 'Rider assigned',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }
      ],
      createdAt: DateTime.now().toUtc(),
    );

    _errandsStore[errandId] = errand;
    _errandsStore[refNumber] = errand;

    return Response(
      201,
      body: jsonEncode({
        'data': errand.toJson(),
        'meta': {
          'request_id': requestId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET / (List errands)
  router.get('/', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final queryParams = request.url.queryParameters;
    final statusFilter = queryParams['status']?.toLowerCase();

    var list = _errandsStore.values.toSet().toList();
    if (statusFilter == 'active') {
      list = list.where((e) => e.status.isActive).toList();
    } else if (statusFilter == 'completed') {
      list = list.where((e) => e.status == ErrandStatus.completed).toList();
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Response.ok(
      jsonEncode({
        'data': list.map((e) => e.toJson()).toList(),
        'meta': {
          'request_id': requestId,
          'count': list.length,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /<id> (Get errand details)
  router.get('/<id>', (Request request, String id) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final errand = _errandsStore[id];

    if (errand == null) {
      return Response.notFound(
        jsonEncode({
          'error': {
            'code': 'ERRAND_NOT_FOUND',
            'message': 'No errand found for id $id',
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({
        'data': errand.toJson(),
        'meta': {
          'request_id': requestId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/quote/accept (Screen C4: Accept quote)
  router.post('/<id>/quote/accept', (Request request, String id) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final errand = _errandsStore[id];

    if (errand == null) {
      return Response.notFound(
        jsonEncode({
          'error': {
            'code': 'ERRAND_NOT_FOUND',
            'message': 'No errand found for id $id',
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    const rider = RiderDto(
      id: 'rider_err_01',
      profileId: 'prof_ahmed_01',
      fullName: 'Ahmed Ibrahim',
      phoneNumber: '+234 803 456 7890',
      vehicleModel: 'Yamaha EV',
      vehicleType: VehicleType.electricBike,
      vehiclePlate: 'ABC-123KY',
      batteryLevelPercent: 92,
      rating: 4.8,
      status: RiderStatus.online,
      totalTripsCompleted: 320,
    );

    final updated = errand.copyWith(
      status: ErrandStatus.agentAssigned,
      paymentStatus: PaymentStatus.captured,
      assignedRider: rider,
    );
    _errandsStore[id] = updated;

    return Response.ok(
      jsonEncode({
        'data': updated.toJson(),
        'meta': {
          'request_id': requestId,
          'message': 'Quote accepted successfully. Rider assigned.',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/quote/decline (Screen C4: Decline quote)
  router.post('/<id>/quote/decline', (Request request, String id) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final errand = _errandsStore[id];

    if (errand == null) {
      return Response.notFound(
        jsonEncode({
          'error': {
            'code': 'ERRAND_NOT_FOUND',
            'message': 'No errand found for id $id',
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    final updated = errand.copyWith(
      status: ErrandStatus.cancelled,
      cancellationReason: 'Customer declined quote',
    );
    _errandsStore[id] = updated;

    return Response.ok(
      jsonEncode({
        'data': updated.toJson(),
        'meta': {
          'request_id': requestId,
          'message': 'Quote declined. Errand cancelled.',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/advance-status (Progress lifecycle for testing & live simulation)
  router.post('/<id>/advance-status', (Request request, String id) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final errand = _errandsStore[id];

    if (errand == null) {
      return Response.notFound(
        jsonEncode({
          'error': {
            'code': 'ERRAND_NOT_FOUND',
            'message': 'No errand found for id $id',
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    ErrandStatus nextStatus;
    if (errand.type == ErrandType.buyItems) {
      switch (errand.status) {
        case ErrandStatus.agentAssigned:
          nextStatus = ErrandStatus.shoppingInProgress;
          break;
        case ErrandStatus.shoppingInProgress:
          nextStatus = ErrandStatus.itemsPurchased;
          break;
        case ErrandStatus.itemsPurchased:
          nextStatus = ErrandStatus.outForDelivery;
          break;
        case ErrandStatus.outForDelivery:
          nextStatus = ErrandStatus.delivered;
          break;
        case ErrandStatus.delivered:
          nextStatus = ErrandStatus.completed;
          break;
        default:
          nextStatus = errand.status;
      }
    } else {
      switch (errand.status) {
        case ErrandStatus.agentAssigned:
          nextStatus = ErrandStatus.inProgress;
          break;
        case ErrandStatus.inProgress:
          nextStatus = ErrandStatus.outForDelivery;
          break;
        case ErrandStatus.outForDelivery:
          nextStatus = ErrandStatus.delivered;
          break;
        case ErrandStatus.delivered:
          nextStatus = ErrandStatus.completed;
          break;
        default:
          nextStatus = errand.status;
      }
    }

    final updated = errand.copyWith(
      status: nextStatus,
      completedAt: nextStatus == ErrandStatus.completed ? DateTime.now().toUtc() : null,
    );
    _errandsStore[id] = updated;

    return Response.ok(
      jsonEncode({
        'data': updated.toJson(),
        'meta': {
          'request_id': requestId,
          'previous_status': errand.status.code,
          'new_status': nextStatus.code,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /<id>/cancel (Cancel errand)
  router.post('/<id>/cancel', (Request request, String id) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final errand = _errandsStore[id];

    if (errand == null) {
      return Response.notFound(
        jsonEncode({
          'error': {
            'code': 'ERRAND_NOT_FOUND',
            'message': 'No errand found for id $id',
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    final updated = errand.copyWith(
      status: ErrandStatus.cancelled,
      cancellationReason: 'Cancelled by customer',
    );
    _errandsStore[id] = updated;

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

  // POST /<id>/rating (Rate errand)
  router.post('/<id>/rating', (Request request, String id) async {
    final requestId = request.context['requestId'] as String? ?? 'unknown';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;
    final rating = (body['rating'] as num?)?.toDouble() ?? 5.0;

    final errand = _errandsStore[id];
    if (errand != null) {
      _errandsStore[id] = errand.copyWith(rating: rating);
    }

    return Response.ok(
      jsonEncode({
        'data': {
          'success': true,
          'errand_id': id,
          'rating': rating,
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
