import 'dart:io';

import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:backend/backend.dart';
import 'package:customer_app/src/features/booking/data/booking_repository.dart';
import 'package:customer_app/src/features/errand/data/errand_repository.dart';
import 'package:customer_app/src/features/parcel/data/parcel_repository.dart';
import 'package:customer_app/src/features/scheduled/data/scheduled_repository.dart';
import 'package:customer_app/src/features/wallet/data/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

/// End-to-End Real-Life Production Simulation Test.
///
/// Spins up the actual live backend Shelf HTTP server in-process on localhost,
/// connects the production [ApiClient] and customer app Repositories over real HTTP,
/// and executes end-to-end customer lifecycles with NO hardcoded mocks:
///   1. Instant Ride Booking, Upfront Dynamic Pricing & Dispatch
///   2. Errand & Shopping Lifecycle (Shops, Catalogue, Buy Items & Custom Tasks)
///   3. Scheduled Ride & School Run Subscription (Quotes, Plans, Trips, Handover)
///   4. Parcel Delivery & Live Courier Tracking
///   5. Wallet, Double-Entry Ledger, Paystack Top-Up & Promo Coupons
///   6. Operating Locations & EV Ride Categories Catalogue
void main() {
  late HttpServer server;
  late ApiClient apiClient;
  late BookingRepository bookingRepo;
  late ErrandRepository errandRepo;
  late ScheduledRepository scheduledRepo;
  late ParcelRepository parcelRepo;
  late WalletRepository walletRepo;

  setUpAll(() async {
    // 1. Spin up the real backend Shelf server on localhost on a free dynamic port
    final handler = createServerHandler();
    server = await shelf_io.serve(handler, '127.0.0.1', 0);

    // 2. Configure customer AppConfig pointing directly to the live backend port
    final config = AppConfig(
      environment: AppEnvironment.development,
      appName: 'Go-Volts Real Simulation',
      apiBaseUrl: 'http://127.0.0.1:${server.port}/api/v1',
      supabaseUrl: 'https://placeholder.supabase.co',
      supabaseAnonKey: 'placeholder-anon-key',
      googleMapsApiKey: 'real-life-simulation-key',
    );

    // 3. Initialize production ApiClient connected to live server over real HTTP
    apiClient = ApiClient(config: config);

    // 4. Initialize production Repositories backed by live ApiClient
    bookingRepo = BookingRepository(client: apiClient);
    errandRepo = ErrandRepositoryImpl(apiClient: apiClient);
    scheduledRepo = ScheduledRepository(apiClient: apiClient, useSeedData: false);
    parcelRepo = ParcelRepositoryImpl(apiClient: apiClient);
    walletRepo = WalletRepository(apiClient: apiClient, useSeedData: false);
  });

  tearDownAll(() async {
    await server.close(force: true);
  });

  group('Lifecycle 1: Instant Ride Booking, Upfront Dynamic Pricing & Dispatch', () {
    const pickupLoc = LocationDto(
      latitude: 6.8403,
      longitude: 3.6487,
      address: 'Shaganu Central Hub, Shaganu, Ogun State',
      label: 'Shaganu Central',
      city: 'Shaganu',
      state: 'Ogun',
    );

    const dropoffLoc = LocationDto(
      latitude: 6.8450,
      longitude: 3.6520,
      address: 'Remo High Street, Shaganu, Ogun State',
      label: 'Remo High Street',
      city: 'Shaganu',
      state: 'Ogun',
    );

    test('Customer requests binding upfront quote and receives dynamic fare calculation from backend', () async {
      final quote = await bookingRepo.requestQuote(
        serviceCode: ServiceCode.instantRide,
        pickup: pickupLoc,
        dropoff: dropoffLoc,
      );

      // Verify real backend QuoteDto returned
      expect(quote.quoteId, isNotEmpty);
      expect(quote.quoteId, startsWith('qt_'));
      expect(quote.serviceCode, ServiceCode.instantRide);

      // Verify dynamic fare breakdown from backend pricing engine
      final breakdown = quote.priceBreakdown;
      expect(breakdown.baseFare, 400.0);
      expect(breakdown.platformFee, 50.0);
      expect(breakdown.distanceFare, greaterThan(0));
      expect(breakdown.timeFare, greaterThan(0));
      expect(breakdown.totalFare, breakdown.baseFare + breakdown.distanceFare + breakdown.timeFare + breakdown.platformFee);

      // Verify duration and distance computed from coordinates
      expect(quote.estimatedDistanceKm, greaterThan(0));
      expect(quote.estimatedDurationMinutes, greaterThanOrEqualTo(10));
      expect(quote.expiresAt.isAfter(DateTime.now()), isTrue);
    });

    test('Customer commits booking and backend dispatches order with exact coordinates and quote breakdown', () async {
      // 1. Get real quote
      final quote = await bookingRepo.requestQuote(
        serviceCode: ServiceCode.instantRide,
        pickup: pickupLoc,
        dropoff: dropoffLoc,
      );

      // 2. Commit booking
      final booking = await bookingRepo.createBooking(
        quoteId: quote.quoteId,
        paymentMethod: PaymentMethod.wallet,
        instructions: 'Please wait near the main entrance roundabout',
      );

      // Verify real backend BookingDto returned
      expect(booking.id, startsWith('bk_'));
      expect(booking.bookingReference, startsWith('GV-'));
      expect(booking.serviceCode, ServiceCode.instantRide);
      expect(booking.status, BookingStatus.searchingRider);
      expect(booking.paymentMethod, PaymentMethod.wallet);
      expect(booking.paymentStatus, PaymentStatus.authorized);
      expect(booking.instructions, 'Please wait near the main entrance roundabout');

      // Verify coordinates preserved from the quote (Ogun operating hub)
      expect(booking.pickupLocation.latitude, closeTo(6.8403, 0.001));
      expect(booking.pickupLocation.longitude, closeTo(3.6487, 0.001));
      expect(booking.pickupLocation.address, contains('Shaganu'));
      expect(booking.dropoffLocation.latitude, closeTo(6.8450, 0.001));
      expect(booking.dropoffLocation.longitude, closeTo(3.6520, 0.001));
      expect(booking.dropoffLocation.address, contains('Remo High Street'));

      // Verify price breakdown matches quote exactly
      expect(booking.priceBreakdown.totalFare, quote.priceBreakdown.totalFare);

      // 3. Query booking details from backend
      final fetched = await bookingRepo.getBooking(booking.id);
      expect(fetched.id, booking.id);
      expect(fetched.bookingReference, booking.bookingReference);

      // 4. Cancel booking with customer reason
      final cancelled = await bookingRepo.cancelBooking(
        booking.id,
        reason: 'Customer changed travel plans',
      );
      expect(cancelled.status, BookingStatus.cancelled);
      expect(cancelled.cancellationReason, 'Customer changed travel plans');
    });
  });

  group('Lifecycle 2: Errand & Market Shopping Flow (Flow A & Flow C)', () {
    test('Customer fetches live errand catalogue and shops list with Ogun State operating hub coordinates', () async {
      // 1. Catalogue
      final catalogue = await errandRepo.getCatalogue();
      expect(catalogue.shops, isNotEmpty);
      expect(catalogue.popularShoppingItems, isNotEmpty);
      expect(catalogue.packageCategories, contains('Electronics'));
      expect(catalogue.customErrandCategories, contains('Document Collection'));
      expect(catalogue.defaultShoppingServiceFeeKobo, 80000); // ₦800

      // 2. Filter shops by search in Ogun State
      final shops = await errandRepo.getShops(search: 'Shaganu Central');
      expect(shops.length, 1);
      final shop = shops.first;
      expect(shop.name, 'Shaganu Central Market');
      expect(shop.address, contains('Shaganu, Ogun State'));
      expect(shop.latitude, closeTo(6.8403, 0.001));
      expect(shop.longitude, closeTo(3.6487, 0.001));
      expect(shop.isPopular, isTrue);
    });

    test('Customer requests shopping quote, creates errand, and backend manages lifecycle', () async {
      // 1. Request quote for Flow A (Buy Items)
      final quote = await errandRepo.requestQuote({
        'errand_type': 'BUY_ITEMS',
        'distance_km': 2.5,
        'items': [
          {
            'name': 'Tomatoes',
            'quantity': 2,
            'unit': 'kg',
            'estimated_price_kobo': 400000,
          },
          {
            'name': 'Rice (Mama\'s Pride)',
            'quantity': 1,
            'unit': '5 kg bag',
            'estimated_price_kobo': 850000,
          },
        ],
      });

      expect(quote.errandType, ErrandType.buyItems);
      expect(quote.serviceFeeKobo, 80000); // ₦800 base fee
      expect(quote.estimatedItemsCostKobo, 1650000); // 2 tomatoes @ 400000 + 1 rice @ 850000 = ₦16,500
      expect(quote.totalKobo, greaterThan(1650000 + 80000));

      // 2. Create errand order
      final errand = await errandRepo.createErrand({
        'type': 'BUY_ITEMS',
        'shop': {
          'id': 'shop_01',
          'name': 'Shaganu Central Market',
          'address': 'Central Market Road, Shaganu, Ogun State',
          'latitude': 6.8403,
          'longitude': 3.6487,
        },
        'shopping_items': [
          {
            'name': 'Tomatoes',
            'quantity': 2,
            'unit': 'kg',
            'estimated_price_kobo': 400000,
          },
        ],
        'delivery_location': {
          'latitude': 6.8450,
          'longitude': 3.6520,
          'address': 'Remo High Street, Shaganu, Ogun State',
          'label': 'Remo Residence',
        },
        'recipient': {
          'full_name': 'Bamidele Adeleke',
          'phone_number': '0802 345 6789',
          'delivery_address': 'Remo High Street, Shaganu, Ogun State',
        },
        'payment_method': 'WALLET',
      });

      expect(errand.id, isNotEmpty);
      expect(errand.referenceNumber, startsWith('ERR-'));
      expect(errand.type, ErrandType.buyItems);
      expect(errand.deliveryLocation.address, contains('Remo High Street'));
      expect(errand.recipient.fullName, 'Bamidele Adeleke');
      expect(errand.assignedRider, isNotNull);
      expect(errand.assignedRider!.fullName, isNotEmpty);

      // 3. Query errand status
      final fetchedErrand = await errandRepo.getErrand(errand.id);
      expect(fetchedErrand.id, errand.id);

      // 4. Advance status
      final advanced = await errandRepo.advanceStatus(errand.id);
      expect(advanced.id, errand.id);
      expect(advanced.statusTimeline.length, greaterThan(1));
    });
  });

  group('Lifecycle 3: Scheduled Ride & School Run Subscription Flow', () {
    const schoolPickup = LocationDto(
      latitude: 6.8403,
      longitude: 3.6487,
      address: 'Shaganu Central, Ogun State',
      label: 'Home',
      city: 'Shaganu',
      state: 'Ogun',
    );

    const schoolDropoff = LocationDto(
      latitude: 6.8920,
      longitude: 3.7190,
      address: 'Babcock Staff School, Ilishan-Remo, Ogun State',
      label: 'School',
      city: 'Ilishan-Remo',
      state: 'Ogun',
    );

    test('Customer calculates deterministic scheduled quote and backend returns itemized breakdown', () async {
      final res = await apiClient.getScheduledQuote(
        bookingType: ScheduledBookingType.recurring,
        purpose: TripPurpose.schoolRun,
        journeyType: JourneyDirection.oneWay,
        pickupLocation: schoolPickup,
        destinationLocation: schoolDropoff,
        billingModel: PackageBillingModel.monthlyPackage,
        selectedDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      );

      expect(res.isSuccess, isTrue);
      final quote = res.data!;
      expect(quote.quoteId, isNotEmpty);
      expect(quote.purpose, TripPurpose.schoolRun);
      expect(quote.totalTripsCount, greaterThanOrEqualTo(20));
      expect(quote.baseFareNgn, greaterThan(0));
      expect(quote.totalAmountNgn, greaterThan(10000.0));
    });

    test('Customer creates recurring school plan and queries generated scheduled trips with OTP', () async {
      // 1. Calculate quote
      final quoteRes = await apiClient.getScheduledQuote(
        bookingType: ScheduledBookingType.recurring,
        purpose: TripPurpose.schoolRun,
        journeyType: JourneyDirection.oneWay,
        pickupLocation: schoolPickup,
        destinationLocation: schoolDropoff,
        billingModel: PackageBillingModel.monthlyPackage,
      );
      final quote = quoteRes.data!;

      // 2. Submit plan
      final planRes = await apiClient.submitScheduledPlan(
        quote: quote,
        passengerName: 'Zainab Adeleke',
        passengerPhone: '+234 803 123 4567',
        schoolName: 'Babcock Staff School',
      );

      expect(planRes.isSuccess, isTrue);
      final plan = planRes.data!;
      expect(plan.id, isNotEmpty);
      expect(plan.planReference, startsWith('SP-'));
      expect(plan.purpose, TripPurpose.schoolRun);
      expect(plan.pickupLocation.address, contains('Shaganu'));
      expect(plan.dropoffLocation.address, contains('Babcock Staff School'));

      // 3. Fetch scheduled trips
      final repoTrips = await scheduledRepo.getUpcomingTrips(planId: plan.id);
      expect(repoTrips, isNotNull);
      final tripsRes = await apiClient.listScheduledTrips(planId: plan.id);
      expect(tripsRes.isSuccess, isTrue);
      expect(tripsRes.data, isNotNull);

      // 4. Verify skip upcoming trip
      final skipRes = await apiClient.skipScheduledTrip('trip-sch-01');
      expect(skipRes.isSuccess, isTrue);
      expect(skipRes.data?['entitlement_preserved'], isTrue);
      expect(skipRes.data?['status'], 'skipped');
    });
  });

  group('Lifecycle 4: Parcel Delivery & Live Courier Tracking', () {
    test('Customer requests parcel quote and dispatches delivery with real courier assignment', () async {
      // 1. Get catalogue and policies
      final catalogue = await parcelRepo.getCatalogue();
      expect(catalogue.deliveryOptions, isNotEmpty);
      final standardOption = catalogue.deliveryOptions.first;

      const pickup = LocationDto(
        latitude: 6.8403,
        longitude: 3.6487,
        address: 'Shaganu Central Hub, Ogun State',
        label: 'Sender Hub',
        city: 'Shaganu',
        state: 'Ogun',
      );

      const dropoff = LocationDto(
        latitude: 6.8450,
        longitude: 3.6520,
        address: 'Remo Commercial Center, Remo High Street, Ogun State',
        label: 'Recipient Office',
        city: 'Shaganu',
        state: 'Ogun',
      );

      // 2. Request parcel quote
      final quote = await parcelRepo.requestQuote(
        pickup: pickup,
        dropoff: dropoff,
        deliveryOption: standardOption,
        category: ParcelCategoryDto.fragile,
        weightKg: 2.0,
        sizeBand: ParcelSizeBandDto.small,
        handlingOptions: [SpecialHandlingOptionDto.fragile.copyWith(isEnabled: true)],
      );

      expect(quote.baseFareKobo, standardOption.baseFareKobo);
      expect(quote.handlingFareKobo, greaterThan(0));
      expect(quote.totalAmountKobo, greaterThan(quote.baseFareKobo));

      // 3. Create delivery
      const recipient = RecipientDetailsDto(
        fullName: 'Kehinde Omotayo',
        phoneNumber: '+234 802 111 2233',
        deliveryAddress: 'Remo Commercial Center, Remo High Street, Ogun State',
      );

      const packageDetails = ParcelDetailsDto(
        category: ParcelCategoryDto.fragile,
        weightKg: 2.0,
        sizeBand: ParcelSizeBandDto.small,
        description: 'Delicate optical glass lenses',
      );

      final delivery = await parcelRepo.createDelivery(
        deliveryOption: standardOption,
        pickupLocation: pickup,
        destinationLocation: dropoff,
        recipient: recipient,
        packageDetails: packageDetails,
        priceBreakdown: quote,
        paymentMethod: PaymentMethod.wallet,
      );

      expect(delivery.id, startsWith('del_'));
      expect(delivery.trackingNumber, startsWith('DVL'));
      expect(delivery.status, BookingStatus.assigned);
      expect(delivery.riderName, isNotEmpty);
      expect(delivery.riderPhone, isNotEmpty);
      expect(delivery.pickupLocation.address, contains('Shaganu'));
      expect(delivery.destinationLocation.address, contains('Remo Commercial Center'));

      // 4. Query live delivery by tracking number
      final liveDelivery = await parcelRepo.getDelivery(delivery.trackingNumber);
      expect(liveDelivery.id, delivery.id);
      expect(liveDelivery.trackingNumber, delivery.trackingNumber);
    });
  });

  group('Lifecycle 5: Wallet, Double-Entry Ledger, Paystack Top-Up & Promo Coupons', () {
    test('Customer checks authoritative ledger balance, initiates Paystack top-up and validates coupons', () async {
      // 1. Wallet ledger balance
      final wallet = await walletRepo.getWallet();
      expect(wallet.currency, 'NGN');
      expect(wallet.balance, greaterThanOrEqualTo(0));

      // 2. Initialize Paystack payment session (₦5,000)
      final payRes = await apiClient.initializePayment(
        amount: 5000.0,
        email: 'customer@govolt.ng',
        reference: 'PSTK-TEST-${DateTime.now().millisecondsSinceEpoch}',
      );
      expect(payRes.isSuccess, isTrue);
      expect(payRes.data?['authorization_url'], contains('checkout.paystack.com'));
      expect(payRes.data?['reference'], startsWith('PSTK-TEST-'));

      // 3. Promo coupons
      final coupons = await walletRepo.getCoupons();
      expect(coupons, isNotEmpty);
      final ecoCoupon = coupons.firstWhere((c) => c.code == 'ECOSEND');
      expect(ecoCoupon.title, contains('Ogun State'));
      expect(ecoCoupon.discountAmountNaira, 400.0);
    });
  });

  group('Lifecycle 6: Operating Locations & EV Ride Categories Catalogue', () {
    test('Client fetches active operating locations and verifies Ogun State / Shaganu hub', () async {
      final res = await apiClient.getOperatingLocations();
      expect(res.isSuccess, isTrue);
      final locations = res.data!;
      expect(locations, isNotEmpty);

      final shaganuHub = locations.firstWhere((l) => l.state == 'Ogun' && l.city == 'Shaganu');
      expect(shaganuHub.centerLat, closeTo(6.8403, 0.001));
      expect(shaganuHub.centerLng, closeTo(3.6487, 0.001));
      expect(shaganuHub.status, 'fully_supported');
      expect(shaganuHub.isActive, isTrue);
    });

    test('Client fetches EV vehicle categories and verifies electric vehicle classes', () async {
      final res = await apiClient.getRideCategories();
      expect(res.isSuccess, isTrue);
      final categories = res.data!;
      expect(categories.length, greaterThanOrEqualTo(3));

      // Verify electric categories exist
      expect(categories.any((c) => c.code.contains('bike') || c.name.contains('Moto')), isTrue);
      expect(categories.any((c) => c.code.contains('standard') || c.code.contains('plus')), isTrue);
      for (final cat in categories) {
        expect(cat.baseFareKobo, greaterThan(0));
        expect(cat.passengerCapacity, greaterThan(0));
        expect(cat.co2OffsetGrams, greaterThan(0));
      }
    });
  });
}
