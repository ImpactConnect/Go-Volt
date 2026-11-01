import 'dart:async';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:dio/dio.dart';
import 'api_response.dart';

typedef TokenProvider = FutureOr<String?> Function();

/// Resilient HTTP client for Go-Volts REST endpoints.
class ApiClient {
  ApiClient({
    required AppConfig config,
    TokenProvider? tokenProvider,
    Dio? customDio,
  }) : _config = config,
       _tokenProvider = tokenProvider {
    _dio =
        customDio ??
        Dio(
          BaseOptions(
            baseUrl: _config.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Client-App': _config.appName,
              'X-Client-Env': _config.environment.key,
            },
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_tokenProvider != null) {
            final token = await _tokenProvider();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          options.headers['X-Request-Id'] = DateTime.now()
              .microsecondsSinceEpoch
              .toString();
          handler.next(options);
        },
        onError: (DioException err, handler) {
          handler.next(err);
        },
      ),
    );
  }

  final AppConfig _config;
  final TokenProvider? _tokenProvider;
  late final Dio _dio;

  Dio get dio => _dio;

  // ---------------------------------------------------------------------------
  // QUOTES & PRICING
  // ---------------------------------------------------------------------------

  Future<ApiResponse<QuoteDto>> getQuote({
    required ServiceCode serviceCode,
    required LocationDto pickup,
    required LocationDto dropoff,
    DateTime? scheduledTime,
    PackageCategory? packageCategory,
  }) async {
    return _send<QuoteDto>(
      method: 'POST',
      path: '/quotes',
      data: {
        'service_code': serviceCode.code,
        'pickup': pickup.toJson(),
        'dropoff': dropoff.toJson(),
        if (scheduledTime != null)
          'scheduled_time': scheduledTime.toIso8601String(),
        if (packageCategory != null) 'package_category': packageCategory.code,
      },
      parser: (data) => QuoteDto.fromJson(data as Map<String, dynamic>),
    );
  }

  // ---------------------------------------------------------------------------
  // BOOKINGS
  // ---------------------------------------------------------------------------

  Future<ApiResponse<BookingDto>> createBooking({
    required String quoteId,
    required PaymentMethod paymentMethod,
    String? rideCategoryId,
    String? couponCode,
    int? walletCreditAppliedKobo,
    String? instructions,
    String? recipientName,
    String? recipientPhone,
    String? idempotencyKey,
  }) async {
    final key =
        idempotencyKey ??
        'idem_${DateTime.now().microsecondsSinceEpoch}_${quoteId.hashCode.abs()}';

    return _send<BookingDto>(
      method: 'POST',
      path: '/bookings',
      headers: {'Idempotency-Key': key},
      data: {
        'quote_id': quoteId,
        'payment_method': paymentMethod.code,
        'ride_category_id': ?rideCategoryId,
        'coupon_code': ?couponCode,
        'wallet_credit_applied_kobo': ?walletCreditAppliedKobo,
        'instructions': ?instructions,
        'recipient_name': ?recipientName,
        'recipient_phone': ?recipientPhone,
      },
      parser: (data) => BookingDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Fetches published ride categories for an area (v1.3 §5.4 & §6.8.1).
  Future<ApiResponse<List<RideCategoryDto>>> getRideCategories({
    double? latitude,
    double? longitude,
    String? serviceAreaId,
  }) async {
    return _send<List<RideCategoryDto>>(
      method: 'GET',
      path: '/catalogue/ride-categories',
      queryParameters: {
        'lat': ?latitude,
        'lng': ?longitude,
        'service_area_id': ?serviceAreaId,
      },
      parser: (data) {
        if (data is List) {
          return data
              .map((e) => RideCategoryDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <RideCategoryDto>[];
      },
    );
  }

  /// Fetches active operating locations provisioned by the admin platform.
  Future<ApiResponse<List<OperatingLocationDto>>> getOperatingLocations() async {
    return _send<List<OperatingLocationDto>>(
      method: 'GET',
      path: '/operating-locations',
      parser: (data) {
        if (data is List) {
          return data
              .map((e) =>
                  OperatingLocationDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <OperatingLocationDto>[];
      },
    );
  }

  /// Advisory validation of a coupon against a quote (v1.3 §6.4 & §8.7).
  Future<ApiResponse<CouponValidationDto>> validateCoupon({
    required String code,
    required int quoteAmountKobo,
    String? serviceCode,
  }) async {
    return _send<CouponValidationDto>(
      method: 'POST',
      path: '/coupons/validate',
      data: {
        'code': code.trim().toUpperCase(),
        'quote_amount_kobo': quoteAmountKobo,
        'service_code': ?serviceCode,
      },
      parser: (data) =>
          CouponValidationDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Fetches itemized digital trip receipt (Screen 16: RIDE-12).
  Future<ApiResponse<TripReceiptDto>> getTripReceipt(String bookingId) async {
    return _send<TripReceiptDto>(
      method: 'GET',
      path: '/bookings/$bookingId/receipt',
      parser: (data) => TripReceiptDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Submits post-trip customer rating and feedback (Screen 17: RIDE-13).
  Future<ApiResponse<bool>> submitTripRating(TripRatingDto rating) async {
    return _send<bool>(
      method: 'POST',
      path: '/bookings/${rating.bookingId}/rating',
      data: rating.toJson(),
      parser: (data) => true,
    );
  }

  // ---------------------------------------------------------------------------
  // PARCEL DELIVERY (GO-VOLTS SEND — v1.4 §6.4 & §22)
  // ---------------------------------------------------------------------------

  /// Fetches active parcel options and policy notices (v1.4 §6.4 & §22.3).
  Future<ApiResponse<ParcelCatalogueDto>> getDeliveryCatalogue({
    double? latitude,
    double? longitude,
  }) async {
    return _send<ParcelCatalogueDto>(
      method: 'GET',
      path: '/delivery/catalogue',
      queryParameters: {'lat': ?latitude, 'lng': ?longitude},
      parser: (data) =>
          ParcelCatalogueDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Calculates authoritative parcel fare quote (v1.4 §6.4 & §22.4).
  Future<ApiResponse<ParcelPriceBreakdownDto>> requestParcelQuote({
    required LocationDto pickup,
    required LocationDto dropoff,
    required DeliveryOptionDto deliveryOption,
    required ParcelCategoryDto category,
    required double weightKg,
    required ParcelSizeBandDto sizeBand,
    List<SpecialHandlingOptionDto> handlingOptions = const [],
    String? couponCode,
  }) async {
    return _send<ParcelPriceBreakdownDto>(
      method: 'POST',
      path: '/deliveries/quotes',
      data: {
        'pickup': pickup.toJson(),
        'dropoff': dropoff.toJson(),
        'delivery_option': deliveryOption.toJson(),
        'package_category': category.toJson(),
        'weight_kg': weightKg,
        'size_band': sizeBand.toJson(),
        'handling_options': handlingOptions.map((e) => e.toJson()).toList(),
        'coupon_code': ?couponCode,
      },
      parser: (data) =>
          ParcelPriceBreakdownDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Creates a parcel booking from quote and policy acknowledgement (v1.4 §6.4 & §22.5).
  Future<ApiResponse<ParcelDeliveryDto>> createParcelDelivery({
    required DeliveryOptionDto deliveryOption,
    required LocationDto pickupLocation,
    required LocationDto destinationLocation,
    required RecipientDetailsDto recipient,
    required ParcelDetailsDto packageDetails,
    required ParcelPriceBreakdownDto priceBreakdown,
    required PaymentMethod paymentMethod,
    String? couponCode,
    String? idempotencyKey,
  }) async {
    final key =
        idempotencyKey ?? 'idem_del_${DateTime.now().microsecondsSinceEpoch}';

    return _send<ParcelDeliveryDto>(
      method: 'POST',
      path: '/deliveries',
      headers: {'Idempotency-Key': key},
      data: {
        'delivery_option': deliveryOption.toJson(),
        'pickup': pickupLocation.toJson(),
        'dropoff': destinationLocation.toJson(),
        'recipient': recipient.toJson(),
        'package_details': packageDetails.toJson(),
        'price_breakdown': priceBreakdown.toJson(),
        'payment_method': paymentMethod.code,
        'coupon_code': ?couponCode,
      },
      parser: (data) =>
          ParcelDeliveryDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Retrieves own parcel delivery status (v1.4 §6.4).
  Future<ApiResponse<ParcelDeliveryDto>> getParcelDelivery(String id) async {
    return _send<ParcelDeliveryDto>(
      method: 'GET',
      path: '/deliveries/$id',
      parser: (data) =>
          ParcelDeliveryDto.fromJson(data as Map<String, dynamic>),
    );
  }

  // ---------------------------------------------------------------------------
  // MARKET ERRAND (v1.6 §1556-2034)
  // ---------------------------------------------------------------------------

  /// Fetches market errand catalogue: shops, categories, item units & rules.
  Future<ApiResponse<ErrandCatalogueDto>> getErrandCatalogue() async {
    return _send<ErrandCatalogueDto>(
      method: 'GET',
      path: '/errands/catalogue',
      parser: (data) =>
          ErrandCatalogueDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Fetches available shops and open markets.
  Future<ApiResponse<List<ShopDto>>> getErrandShops({
    String? search,
    String? tab,
    double? latitude,
    double? longitude,
  }) async {
    return _send<List<ShopDto>>(
      method: 'GET',
      path: '/errands/shops',
      queryParameters: {
        'search': ?search,
        'tab': ?tab,
        'lat': ?latitude,
        'lng': ?longitude,
      },
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.map((s) => ShopDto.fromJson(s as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Calculates authoritative errand quote.
  Future<ApiResponse<ErrandQuoteDto>> requestErrandQuote(
    Map<String, dynamic> payload,
  ) async {
    return _send<ErrandQuoteDto>(
      method: 'POST',
      path: '/errands/quotes',
      data: payload,
      parser: (data) =>
          ErrandQuoteDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Creates a new errand booking.
  Future<ApiResponse<ErrandDto>> createErrand(
    Map<String, dynamic> errandPayload, {
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ??
        'idem_err_${DateTime.now().microsecondsSinceEpoch}';

    return _send<ErrandDto>(
      method: 'POST',
      path: '/errands',
      headers: {'Idempotency-Key': key},
      data: errandPayload,
      parser: (data) => ErrandDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Retrieves errand status and assigned rider.
  Future<ApiResponse<ErrandDto>> getErrand(String id) async {
    return _send<ErrandDto>(
      method: 'GET',
      path: '/errands/$id',
      parser: (data) => ErrandDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Lists customer errands.
  Future<ApiResponse<List<ErrandDto>>> listErrands({String? status}) async {
    return _send<List<ErrandDto>>(
      method: 'GET',
      path: '/errands',
      queryParameters: {'status': ?status},
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.map((e) => ErrandDto.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Accepts a quote for Flow C custom errand.
  Future<ApiResponse<ErrandDto>> acceptErrandQuote(String id) async {
    return _send<ErrandDto>(
      method: 'POST',
      path: '/errands/$id/quote/accept',
      parser: (data) => ErrandDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Declines a quote for Flow C custom errand.
  Future<ApiResponse<ErrandDto>> declineErrandQuote(String id) async {
    return _send<ErrandDto>(
      method: 'POST',
      path: '/errands/$id/quote/decline',
      parser: (data) => ErrandDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Progresses errand lifecycle status for testing/simulation.
  Future<ApiResponse<ErrandDto>> advanceErrandStatus(String id) async {
    return _send<ErrandDto>(
      method: 'POST',
      path: '/errands/$id/advance-status',
      parser: (data) => ErrandDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Cancels an active errand.
  Future<ApiResponse<ErrandDto>> cancelErrand(String id) async {
    return _send<ErrandDto>(
      method: 'POST',
      path: '/errands/$id/cancel',
      parser: (data) => ErrandDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Submits rating for completed errand.
  Future<ApiResponse<bool>> rateErrand(String id, double rating) async {
    return _send<bool>(
      method: 'POST',
      path: '/errands/$id/rating',
      data: {'rating': rating},
      parser: (data) => true,
    );
  }

  /// Cancels an active parcel delivery (v1.4 §6.4 & §22.10).
  Future<ApiResponse<bool>> cancelParcelDelivery(
    String id, {
    required String reason,
  }) async {
    return _send<bool>(
      method: 'POST',
      path: '/deliveries/$id/cancel',
      data: {'reason': reason},
      parser: (data) => true,
    );
  }

  /// Submits post-delivery courier rating and feedback (Screen 17 & v1.4 §22.2).
  Future<ApiResponse<bool>> submitParcelRating(ParcelRatingDto rating) async {
    return _send<bool>(
      method: 'POST',
      path: '/deliveries/${rating.trackingNumber}/rating',
      data: rating.toJson(),
      parser: (data) => true,
    );
  }

  Future<ApiResponse<BookingDto>> getBooking(String bookingId) async {
    return _send<BookingDto>(
      method: 'GET',
      path: '/bookings/$bookingId',
      parser: (data) => BookingDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<BookingDto>> cancelBooking(
    String bookingId, {
    required String reason,
  }) async {
    return _send<BookingDto>(
      method: 'POST',
      path: '/bookings/$bookingId/cancel',
      data: {'reason': reason},
      parser: (data) => BookingDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<BookingDto>>> listBookings({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    return _send<List<BookingDto>>(
      method: 'GET',
      path: '/bookings',
      queryParameters: {'status': ?status, 'limit': limit, 'offset': offset},
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list
            .map((e) => BookingDto.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // USER PROFILE & VERIFICATION (Spec Group A)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<ProfileDto>> getProfile({String? userId}) async {
    return _send<ProfileDto>(
      method: 'GET',
      path: '/api/v1/profile/me',
      queryParameters: {
        'user_id': ?userId,
      },
      parser: (data) => ProfileDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<ProfileDto>> updateProfile({
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? currentAddress,
    String? city,
    String? state,
    String? gender,
    String? avatarUrl,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    return _send<ProfileDto>(
      method: 'PATCH',
      path: '/api/v1/profile/me',
      data: {
        'user_id': ?userId,
        'full_name': ?fullName,
        'email': ?email,
        'phone_number': ?phoneNumber,
        'current_address': ?currentAddress,
        'city': ?city,
        'state': ?state,
        'gender': ?gender,
        'avatar_url': ?avatarUrl,
        'emergency_contact_name': ?emergencyContactName,
        'emergency_contact_phone': ?emergencyContactPhone,
      },
      parser: (data) => ProfileDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<AccountVerificationDto>> getAccountVerification({String? userId}) async {
    return _send<AccountVerificationDto>(
      method: 'GET',
      path: '/api/v1/profile/verification',
      queryParameters: {
        'user_id': ?userId,
      },
      parser: (data) => AccountVerificationDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> submitAccountVerification({
    String? userId,
    Map<String, String>? documentUrls,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'POST',
      path: '/api/v1/profile/verification/submit',
      data: {
        'user_id': ?userId,
        'document_urls': ?documentUrls,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // WALLET
  // ---------------------------------------------------------------------------

  Future<ApiResponse<WalletDto>> getWallet() async {
    return _send<WalletDto>(
      method: 'GET',
      path: '/wallet',
      parser: (data) => WalletDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<WalletTransactionDto>>> listWalletTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    return _send<List<WalletTransactionDto>>(
      method: 'GET',
      path: '/wallet/transactions',
      queryParameters: {'limit': limit, 'offset': offset},
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list
            .map(
              (e) => WalletTransactionDto.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PAYMENT (Paystack Backend Adapter)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<Map<String, dynamic>>> initializePayment({
    required double amount,
    required String email,
    required String reference,
    String? bookingId,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'POST',
      path: '/payments/initialize',
      data: {
        'amount': amount,
        'email': email,
        'reference': reference,
        'booking_id': ?bookingId,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyPayment(
    String reference,
  ) async {
    return _send<Map<String, dynamic>>(
      method: 'GET',
      path: '/payments/verify/$reference',
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // DEVICE TOKENS (Push Notifications)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<Map<String, dynamic>>> registerDevice({
    required String fcmToken,
    required String platform,
    String? deviceModel,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'POST',
      path: '/devices',
      data: {
        'fcm_token': fcmToken,
        'platform': platform,
        'device_model': ?deviceModel,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> unregisterDevice({
    required String fcmToken,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'DELETE',
      path: '/devices',
      data: {'fcm_token': fcmToken},
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // SCHEDULED PLANS (Commuter & School-Run)
  // SCHEDULED PLANS & COMMUTE (v1.5 Section 21)
  // ---------------------------------------------------------------------------

  /// Calculates a deterministic quote for one-off or recurring scheduled pickup.
  Future<ApiResponse<ScheduledQuoteDto>> getScheduledQuote({
    required ScheduledBookingType bookingType,
    required TripPurpose purpose,
    required JourneyDirection journeyType,
    required LocationDto pickupLocation,
    required LocationDto destinationLocation,
    LocationDto? returnPickupLocation,
    LocationDto? returnDestinationLocation,
    String? pickupTime,
    String? returnPickupTime,
    List<String> selectedDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    PackageBillingModel billingModel = PackageBillingModel.payPerTrip,
  }) async {
    return _send<ScheduledQuoteDto>(
      method: 'POST',
      path: '/scheduled-quotes',
      data: {
        'booking_type': bookingType.value,
        'purpose': purpose.value,
        'journey_type': journeyType.value,
        'pickup_location': pickupLocation.toJson(),
        'destination_location': destinationLocation.toJson(),
        'return_pickup_location': ?returnPickupLocation?.toJson(),
        'return_destination_location': ?returnDestinationLocation?.toJson(),
        'pickup_time': ?pickupTime,
        'return_pickup_time': ?returnPickupTime,
        'selected_days': selectedDays,
        'billing_model': billingModel.value,
      },
      parser: (data) {
        if (data is Map<String, dynamic>) {
          final payload = data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data;
          return ScheduledQuoteDto.fromJson(payload);
        }
        throw const FormatException('Expected Map for ScheduledQuoteDto');
      },
    );
  }

  /// Submits a recurring plan request to operations for review (status: pending_review).
  Future<ApiResponse<ScheduledPlanDto>> submitScheduledPlan({
    required ScheduledQuoteDto quote,
    required String passengerName,
    required String passengerPhone,
    String? specialInstructions,
    String? preferredDriverId,
    String? preferredDriverName,
    String? schoolName,
  }) async {
    return _send<ScheduledPlanDto>(
      method: 'POST',
      path: '/scheduled-plans',
      data: {
        ...quote.toJson(),
        'passenger_name': passengerName,
        'passenger_phone': passengerPhone,
        'notes': ?specialInstructions,
        'preferred_driver_id': ?preferredDriverId,
        'preferred_driver_name': ?preferredDriverName,
        'school_name': ?schoolName,
      },
      parser: (data) {
        if (data is Map<String, dynamic>) {
          final payload = data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data;
          return ScheduledPlanDto.fromJson(payload);
        }
        throw const FormatException('Expected Map for ScheduledPlanDto');
      },
    );
  }

  /// Fetches customer's scheduled plans.
  Future<ApiResponse<List<ScheduledPlanDto>>> listScheduledPlans({
    String? status,
  }) async {
    return _send<List<ScheduledPlanDto>>(
      method: 'GET',
      path: '/scheduled-plans',
      queryParameters: status != null ? {'status': status} : null,
      parser: (data) {
        final list = (data is Map<String, dynamic> && data.containsKey('data'))
            ? data['data'] as List<dynamic>? ?? []
            : data as List<dynamic>? ?? [];
        return list
            .map(
              (item) => ScheduledPlanDto.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  /// Fetches a single scheduled plan by ID.
  Future<ApiResponse<ScheduledPlanDto>> getScheduledPlan(String planId) async {
    return _send<ScheduledPlanDto>(
      method: 'GET',
      path: '/scheduled-plans/$planId',
      parser: (data) {
        if (data is Map<String, dynamic>) {
          final payload = data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data;
          return ScheduledPlanDto.fromJson(payload);
        }
        throw const FormatException('Expected Map for ScheduledPlanDto');
      },
    );
  }

  /// Operations approves a pending plan, activating 48h payment window.
  Future<ApiResponse<ScheduledPlanDto>> approveScheduledPlan(
    String planId,
  ) async {
    return _send<ScheduledPlanDto>(
      method: 'POST',
      path: '/scheduled-plans/$planId/approve',
      parser: (data) {
        if (data is Map<String, dynamic>) {
          final payload = data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data;
          return ScheduledPlanDto.fromJson(payload);
        }
        throw const FormatException('Expected Map for ScheduledPlanDto');
      },
    );
  }

  /// Pays for and activates an approved plan.
  Future<ApiResponse<ScheduledPlanDto>> payScheduledPlan(
    String planId, {
    required String paymentMethod,
  }) async {
    return _send<ScheduledPlanDto>(
      method: 'POST',
      path: '/scheduled-plans/$planId/pay',
      data: {'payment_method': paymentMethod},
      parser: (data) {
        if (data is Map<String, dynamic>) {
          final payload = data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data;
          return ScheduledPlanDto.fromJson(payload);
        }
        throw const FormatException('Expected Map for ScheduledPlanDto');
      },
    );
  }

  /// Pauses an active plan from a specified date.
  Future<ApiResponse<ScheduledPlanDto>> pauseScheduledPlan(
    String planId, {
    required DateTime effectiveDate,
  }) async {
    return _send<ScheduledPlanDto>(
      method: 'POST',
      path: '/scheduled-plans/$planId/pause',
      data: {'effective_date': effectiveDate.toIso8601String()},
      parser: (data) {
        if (data is Map<String, dynamic>) {
          final payload = data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data;
          return ScheduledPlanDto.fromJson(payload);
        }
        throw const FormatException('Expected Map for ScheduledPlanDto');
      },
    );
  }

  /// Resumes a paused plan.
  Future<ApiResponse<ScheduledPlanDto>> resumeScheduledPlan(
    String planId,
  ) async {
    return _send<ScheduledPlanDto>(
      method: 'POST',
      path: '/scheduled-plans/$planId/resume',
      parser: (data) {
        if (data is Map<String, dynamic>) {
          final payload = data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data;
          return ScheduledPlanDto.fromJson(payload);
        }
        throw const FormatException('Expected Map for ScheduledPlanDto');
      },
    );
  }

  /// Cancels a scheduled plan.
  Future<ApiResponse<ScheduledPlanDto>> cancelScheduledPlan(
    String planId, {
    String? reason,
  }) async {
    return _send<ScheduledPlanDto>(
      method: 'POST',
      path: '/scheduled-plans/$planId/cancel',
      data: {'reason': ?reason},
      parser: (data) {
        if (data is Map<String, dynamic>) {
          final payload = data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data;
          return ScheduledPlanDto.fromJson(payload);
        }
        throw const FormatException('Expected Map for ScheduledPlanDto');
      },
    );
  }

  /// Lists upcoming scheduled trips, optionally filtered by planId.
  Future<ApiResponse<List<ScheduledTripDto>>> listScheduledTrips({
    String? planId,
  }) async {
    return _send<List<ScheduledTripDto>>(
      method: 'GET',
      path: '/scheduled-trips',
      queryParameters: planId != null ? {'plan_id': planId} : null,
      parser: (data) {
        final list = (data is Map<String, dynamic> && data.containsKey('data'))
            ? data['data'] as List<dynamic>? ?? []
            : data as List<dynamic>? ?? [];
        return list
            .map(
              (item) => ScheduledTripDto.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  /// Skips a trip, checking the 6-hour cutoff for entitlement preservation.
  Future<ApiResponse<Map<String, dynamic>>> skipScheduledTrip(
    String tripId, {
    DateTime? tripTime,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'POST',
      path: '/scheduled-trips/$tripId/skip',
      data: tripTime != null ? {'trip_time': tripTime.toIso8601String()} : null,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data;
        }
        return {'status': 'skipped'};
      },
    );
  }

  /// Verifies school run 4-digit PIN handover.
  Future<ApiResponse<Map<String, dynamic>>> verifyScheduledHandover(
    String tripId, {
    required String pin,
    required String recipientName,
    required String recipientRole,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'POST',
      path: '/scheduled-trips/$tripId/verify-handover',
      data: {
        'pin': pin,
        'recipient_name': recipientName,
        'recipient_role': recipientRole,
      },
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data;
        }
        return {'verified': true};
      },
    );
  }

  /// Reports a safety or service incident for a scheduled trip.
  Future<ApiResponse<Map<String, dynamic>>> reportScheduledTripIssue(
    String tripId, {
    required String issueType,
    String? notes,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'POST',
      path: '/scheduled-trips/$tripId/report-issue',
      data: {'issue_type': issueType, 'notes': ?notes},
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data;
        }
        return {'status': 'recorded'};
      },
    );
  }

  // ---------------------------------------------------------------------------
  // LEGACY PLANS (Commuter & School-Run)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<List<Map<String, dynamic>>>> getScheduledPlans() async {
    return _send<List<Map<String, dynamic>>>(
      method: 'GET',
      path: '/plans',
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.cast<Map<String, dynamic>>();
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createScheduledPlan({
    required String planName,
    required String planType,
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String dropoffAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String pickupTime,
    required List<int> daysOfWeek,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'POST',
      path: '/plans',
      data: {
        'plan_name': planName,
        'plan_type': planType,
        'pickup_address': pickupAddress,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'dropoff_address': dropoffAddress,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'pickup_time': pickupTime,
        'days_of_week': daysOfWeek,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // SETTINGS & SAVED PLACES (Spec Group B)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<NotificationPreferencesDto>> getNotificationPreferences({String? userId}) async {
    return _send<NotificationPreferencesDto>(
      method: 'GET',
      path: '/api/v1/notification-preferences',
      queryParameters: {
        'user_id': ?userId,
      },
      parser: (data) => NotificationPreferencesDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<NotificationPreferencesDto>> updateNotificationPreferences({
    String? userId,
    required NotificationPreferencesDto preferences,
  }) async {
    return _send<NotificationPreferencesDto>(
      method: 'PATCH',
      path: '/api/v1/notification-preferences',
      data: {
        'user_id': ?userId,
        ...preferences.toJson(),
      },
      parser: (data) => NotificationPreferencesDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<SavedPlaceDto>>> getSavedPlaces({String? userId}) async {
    return _send<List<SavedPlaceDto>>(
      method: 'GET',
      path: '/api/v1/saved-places',
      queryParameters: {
        'user_id': ?userId,
      },
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.map((item) => SavedPlaceDto.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  Future<ApiResponse<SavedPlaceDto>> addSavedPlace({
    String? userId,
    required String label,
    required String address,
    required SavedPlaceType type,
    required double latitude,
    required double longitude,
    String? additionalInstructions,
  }) async {
    return _send<SavedPlaceDto>(
      method: 'POST',
      path: '/api/v1/saved-places',
      data: {
        'user_id': ?userId,
        'label': label,
        'address': address,
        'type': type.code,
        'latitude': latitude,
        'longitude': longitude,
        'additional_instructions': ?additionalInstructions,
      },
      parser: (data) => SavedPlaceDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<SavedPlaceDto>> updateSavedPlace({
    required String placeId,
    String? userId,
    String? label,
    String? address,
    SavedPlaceType? type,
    double? latitude,
    double? longitude,
    String? additionalInstructions,
  }) async {
    return _send<SavedPlaceDto>(
      method: 'PATCH',
      path: '/api/v1/saved-places/$placeId',
      data: {
        'user_id': ?userId,
        'label': ?label,
        'address': ?address,
        'type': ?type?.code,
        'latitude': ?latitude,
        'longitude': ?longitude,
        'additional_instructions': ?additionalInstructions,
      },
      parser: (data) => SavedPlaceDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteSavedPlace({
    required String placeId,
    String? userId,
    bool force = false,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'DELETE',
      path: '/api/v1/saved-places/$placeId',
      queryParameters: {
        'user_id': ?userId,
        if (force) 'force': 'true',
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // SAFETY & EMERGENCY (Spec Group D1-D2)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<List<TrustedContactDto>>> getTrustedContacts({String? userId}) async {
    return _send<List<TrustedContactDto>>(
      method: 'GET',
      path: '/api/v1/safety/trusted-contacts',
      queryParameters: {
        'user_id': ?userId,
      },
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.map((item) => TrustedContactDto.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  Future<ApiResponse<TrustedContactDto>> addTrustedContact({
    String? userId,
    required String name,
    required String phoneNumber,
    String relationship = 'Friend',
    bool autoShareRides = false,
  }) async {
    return _send<TrustedContactDto>(
      method: 'POST',
      path: '/api/v1/safety/trusted-contacts',
      data: {
        'user_id': ?userId,
        'name': name,
        'phone_number': phoneNumber,
        'relationship': relationship,
        'auto_share_rides': autoShareRides,
      },
      parser: (data) => TrustedContactDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteTrustedContact({
    required String contactId,
    String? userId,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'DELETE',
      path: '/api/v1/safety/trusted-contacts/$contactId',
      queryParameters: {
        'user_id': ?userId,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> reportSafetyIncident({
    String? userId,
    required String category,
    required String description,
    String? relatedBookingId,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'POST',
      path: '/api/v1/safety/report-incident',
      data: {
        'user_id': ?userId,
        'category': category,
        'description': description,
        'related_booking_id': ?relatedBookingId,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // SUPPORT & FAQS (Spec Group D3-D5)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<List<SupportFaqDto>>> getFaqs({String? category}) async {
    return _send<List<SupportFaqDto>>(
      method: 'GET',
      path: '/api/v1/support/faqs',
      queryParameters: {
        'category': ?category,
      },
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.map((item) => SupportFaqDto.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  Future<ApiResponse<List<SupportTicketDto>>> getSupportTickets({String? userId}) async {
    return _send<List<SupportTicketDto>>(
      method: 'GET',
      path: '/api/v1/support/tickets',
      queryParameters: {
        'user_id': ?userId,
      },
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.map((item) => SupportTicketDto.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  Future<ApiResponse<SupportTicketDto>> createSupportTicket({
    String? userId,
    required String serviceCategory,
    required String issueType,
    required String subject,
    required String description,
    String? relatedEntityId,
  }) async {
    return _send<SupportTicketDto>(
      method: 'POST',
      path: '/api/v1/support/tickets',
      data: {
        'user_id': ?userId,
        'service_category': serviceCategory,
        'issue_type': issueType,
        'subject': subject,
        'description': description,
        'related_entity_id': ?relatedEntityId,
      },
      parser: (data) => SupportTicketDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<SupportTicketDto>> getSupportTicketDetails({
    required String ticketId,
    String? userId,
  }) async {
    return _send<SupportTicketDto>(
      method: 'GET',
      path: '/api/v1/support/tickets/$ticketId',
      queryParameters: {
        'user_id': ?userId,
      },
      parser: (data) => SupportTicketDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<SupportTicketDto>> replyToSupportTicket({
    required String ticketId,
    String? userId,
    required String message,
    String? senderName,
  }) async {
    return _send<SupportTicketDto>(
      method: 'POST',
      path: '/api/v1/support/tickets/$ticketId/reply',
      data: {
        'user_id': ?userId,
        'message': message,
        'sender_name': ?senderName,
      },
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final ticketMap = map['ticket'] as Map<String, dynamic>? ?? map;
        return SupportTicketDto.fromJson(ticketMap);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // INTERNAL REQUEST DISPATCHER
  // ---------------------------------------------------------------------------

  Future<ApiResponse<T>> _send<T>({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method, headers: headers),
      );

      final statusCode = response.statusCode ?? 200;
      final body = response.data;

      if (body is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(body, parser, statusCode: statusCode);
      }

      return ApiResponse<T>.success(parser(body), statusCode: statusCode);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>.failure(
        ApiError(
          code: 'UNEXPECTED_ERROR',
          message: e.toString(),
          statusCode: 500,
        ),
        statusCode: 500,
      );
    }
  }

  ApiResponse<T> _handleDioError<T>(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode ?? 0;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ApiResponse<T>.failure(ApiError.network(), statusCode: 0);
    }

    if (response != null && response.data is Map<String, dynamic>) {
      final body = response.data as Map<String, dynamic>;
      final errorJson = body['error'];
      if (errorJson is Map<String, dynamic>) {
        return ApiResponse<T>.failure(
          ApiError.fromJson(errorJson, statusCode: statusCode),
          statusCode: statusCode,
        );
      }
    }

    return ApiResponse<T>.failure(
      ApiError.server(e.message, statusCode),
      statusCode: statusCode,
    );
  }
}
