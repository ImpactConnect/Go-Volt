import 'dart:convert';
import 'package:app_models/app_models.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';

final _log = Logger('RideCategoriesRoute');

/// Default seed catalogue: 2 Bikes + 3 Cars (v1.3 §5.4 & §6.8.1).
/// Admin-managed catalogue records, not hardcoded constants.
final List<RideCategoryDto> _seededCategories = [
  // 1. Bike Option 1: GoRide Moto
  const RideCategoryDto(
    id: 'cat_bike_std',
    code: 'bike_standard',
    name: 'GoRide Moto',
    description: 'Fast and affordable solo rides on electric two-wheelers',
    passengerCapacity: 1,
    capacityLabel: '1 Seat (Helmet provided)',
    baseFareKobo: 120000, // ₦1,200
    etaMinutes: 2,
    features: ['Helmet provided', '1 Passenger', 'Fastest in traffic', 'Zero emission'],
    iconKey: 'electric_bike',
    isAvailable: true,
    displayOrder: 1,
    co2OffsetGrams: 450,
  ),
  // 2. Bike Option 2: GoRide Moto Plus
  const RideCategoryDto(
    id: 'cat_bike_plus',
    code: 'bike_plus',
    name: 'GoRide Moto Plus',
    description: 'Top-rated electric bike rider with sanitized helmet & hairnet',
    passengerCapacity: 1,
    capacityLabel: '1 Seat (Premium)',
    baseFareKobo: 180000, // ₦1,800
    etaMinutes: 2,
    features: ['Sanitized helmet', 'Top-rated rider', 'Express lane', 'Zero emission'],
    iconKey: 'electric_bike',
    isAvailable: true,
    displayOrder: 2,
    co2OffsetGrams: 450,
  ),
  // 3. Car Option 1: GoRide Standard
  const RideCategoryDto(
    id: 'cat_car_std',
    code: 'standard',
    name: 'GoRide Standard',
    description: 'Affordable, reliable everyday electric car rides',
    passengerCapacity: 3,
    capacityLabel: '3 Seats',
    baseFareKobo: 280000, // ₦2,800
    etaMinutes: 2,
    features: ['AC', '3 Seats', 'Trusted drivers'],
    iconKey: 'electric_car',
    isAvailable: true,
    displayOrder: 3,
    co2OffsetGrams: 850,
  ),
  // 4. Car Option 2: GoRide Plus
  const RideCategoryDto(
    id: 'cat_car_plus',
    code: 'plus',
    name: 'GoRide Plus',
    description: 'More comfort and legroom in premium electric sedans',
    passengerCapacity: 4,
    capacityLabel: '4 Seats',
    baseFareKobo: 350000, // ₦3,500
    etaMinutes: 3,
    features: ['AC', 'Extra legroom', 'Top rated', 'Quiet ride'],
    iconKey: 'electric_car',
    isAvailable: true,
    displayOrder: 4,
    co2OffsetGrams: 950,
  ),
  // 5. Car Option 3: GoRide XL
  const RideCategoryDto(
    id: 'cat_car_xl',
    code: 'xl',
    name: 'GoRide XL',
    description: 'Bigger 6-seater electric vehicles for groups or extra luggage',
    passengerCapacity: 6,
    capacityLabel: '6 Seats',
    baseFareKobo: 450000, // ₦4,500
    etaMinutes: 4,
    features: ['AC', '6 Seats', 'Spacious trunk', 'Group trips'],
    iconKey: 'electric_car',
    isAvailable: true,
    displayOrder: 5,
    co2OffsetGrams: 1200,
  ),
];

// In-memory store for ride categories
final Map<String, RideCategoryDto> _categoriesStore = {
  for (final cat in _seededCategories) cat.id: cat,
};

/// Router for Ride Categories & Catalogue Endpoints.
Router rideCategoriesRouter({SupabaseClient? supabaseClient}) {
  final router = Router();

  // ---------------------------------------------------------------------------
  // GET / — List published ride categories for customers
  // Returns active categories sorted by displayOrder
  // ---------------------------------------------------------------------------
  router.get('/', (Request request) async {
    if (supabaseClient != null) {
      try {
        final records = await supabaseClient
            .from('ride_categories')
            .select('*')
            .eq('status', 'active')
            .eq('is_available', true)
            .order('display_order', ascending: true);

        final list = (records as List<dynamic>)
            .map((e) => RideCategoryDto.fromJson(e as Map<String, dynamic>))
            .toList();

        return Response.ok(
          jsonEncode({
            'data': list.map((c) => c.toJson()).toList(),
            'meta': {'count': list.length, 'source': 'database'},
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        _log.warning('Could not query Supabase for ride categories: $e');
      }
    }

    // In-memory active categories
    final activeList = _categoriesStore.values
        .where((c) => c.isAvailable)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Response.ok(
      jsonEncode({
        'data': activeList.map((c) => c.toJson()).toList(),
        'meta': {'count': activeList.length, 'source': 'in_memory'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // ---------------------------------------------------------------------------
  // GET /<id> — Get specific category by id or code
  // ---------------------------------------------------------------------------
  router.get('/<id>', (Request request, String id) async {
    final cat = _categoriesStore[id] ??
        _categoriesStore.values.cast<RideCategoryDto?>().firstWhere(
              (c) => c?.code == id,
              orElse: () => null,
            );

    if (cat == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'CATEGORY_NOT_FOUND', 'message': 'Ride category not found'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({'data': cat.toJson()}),
      headers: {'content-type': 'application/json'},
    );
  });

  // ---------------------------------------------------------------------------
  // ADMIN: POST /admin — Admin creates or updates a ride option
  // ---------------------------------------------------------------------------
  router.post('/admin', (Request request) async {
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final category = RideCategoryDto.fromJson(body);
    _categoriesStore[category.id] = category;

    if (supabaseClient != null) {
      try {
        await supabaseClient.from('ride_categories').upsert(category.toJson());
      } catch (e) {
        _log.warning('Could not upsert ride category to Supabase: $e');
      }
    }

    return Response(
      201,
      body: jsonEncode({
        'data': category.toJson(),
        'meta': {'status': 'saved'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // ---------------------------------------------------------------------------
  // ADMIN: POST /admin/<id>/toggle — Toggle category availability
  // ---------------------------------------------------------------------------
  router.post('/admin/<id>/toggle', (Request request, String id) async {
    final cat = _categoriesStore[id];
    if (cat == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'CATEGORY_NOT_FOUND', 'message': 'Ride category not found'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    final updated = RideCategoryDto(
      id: cat.id,
      code: cat.code,
      name: cat.name,
      description: cat.description,
      passengerCapacity: cat.passengerCapacity,
      baseFareKobo: cat.baseFareKobo,
      etaMinutes: cat.etaMinutes,
      capacityLabel: cat.capacityLabel,
      features: cat.features,
      iconKey: cat.iconKey,
      imageUrl: cat.imageUrl,
      serviceAreaId: cat.serviceAreaId,
      pricingRuleId: cat.pricingRuleId,
      isAvailable: !cat.isAvailable,
      displayOrder: cat.displayOrder,
      co2OffsetGrams: cat.co2OffsetGrams,
    );
    _categoriesStore[id] = updated;

    if (supabaseClient != null) {
      try {
        await supabaseClient
            .from('ride_categories')
            .update({'is_available': updated.isAvailable})
            .eq('id', id);
      } catch (e) {
        _log.warning('Could not toggle ride category in Supabase: $e');
      }
    }

    return Response.ok(
      jsonEncode({
        'data': updated.toJson(),
        'meta': {'is_available': updated.isAvailable},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
