import 'package:api_client/api_client.dart';
import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/api_providers.dart';

/// Repository handling upfront fare estimation, booking generation, and tracking.
class BookingRepository {
  const BookingRepository({required ApiClient client}) : _client = client;

  final ApiClient _client;

  /// Fetches upfront binding quote from the server.
  Future<QuoteDto> requestQuote({
    required ServiceCode serviceCode,
    required LocationDto pickup,
    required LocationDto dropoff,
    DateTime? scheduledTime,
    PackageCategory? packageCategory,
  }) async {
    final response = await _client.getQuote(
      serviceCode: serviceCode,
      pickup: pickup,
      dropoff: dropoff,
      scheduledTime: scheduledTime,
      packageCategory: packageCategory,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.error?.message ?? 'Failed to calculate upfront quote');
  }

  /// Creates a committed booking entity with guaranteed dispatch.
  Future<BookingDto> createBooking({
    required String quoteId,
    required PaymentMethod paymentMethod,
    String? instructions,
    String? recipientName,
    String? recipientPhone,
  }) async {
    final response = await _client.createBooking(
      quoteId: quoteId,
      paymentMethod: paymentMethod,
      instructions: instructions,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.error?.message ?? 'Failed to create booking');
  }

  /// Retrieves booking by ID.
  Future<BookingDto> getBooking(String bookingId) async {
    final response = await _client.getBooking(bookingId);
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?.message ?? 'Booking not found');
  }

  /// Cancels an active or pending booking.
  Future<BookingDto> cancelBooking(String bookingId, {required String reason}) async {
    final response = await _client.cancelBooking(bookingId, reason: reason);
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?.message ?? 'Failed to cancel booking');
  }

  /// Lists customer booking history.
  Future<List<BookingDto>> listBookings({String? status, int limit = 20}) async {
    final response = await _client.listBookings(status: status, limit: limit);
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return [];
  }

  static const List<RideCategoryDto> _fallbackRideCategories = [
    RideCategoryDto(
      id: 'cat_bike_std',
      code: 'bike_standard',
      name: 'GoRide Moto',
      description: 'Fast and affordable solo rides on electric two-wheelers',
      passengerCapacity: 1,
      capacityLabel: '1 Seat (Helmet provided)',
      baseFareKobo: 120000,
      etaMinutes: 2,
      features: ['Helmet provided', '1 Passenger', 'Fastest in traffic', 'Zero emission'],
      iconKey: 'electric_bike',
      displayOrder: 1,
    ),
    RideCategoryDto(
      id: 'cat_bike_plus',
      code: 'bike_plus',
      name: 'GoRide Moto Plus',
      description: 'Top-rated electric bike rider with sanitized helmet & hairnet',
      passengerCapacity: 1,
      capacityLabel: '1 Seat (Premium)',
      baseFareKobo: 180000,
      etaMinutes: 2,
      features: ['Sanitized helmet', 'Top-rated rider', 'Express lane', 'Zero emission'],
      iconKey: 'electric_bike',
      displayOrder: 2,
    ),
    RideCategoryDto(
      id: 'cat_car_std',
      code: 'standard',
      name: 'GoRide Standard',
      description: 'Affordable, reliable everyday electric car rides',
      passengerCapacity: 3,
      capacityLabel: '3 Seats',
      baseFareKobo: 280000,
      etaMinutes: 2,
      features: ['AC', '3 Seats', 'Trusted drivers'],
      iconKey: 'electric_car',
      displayOrder: 3,
    ),
    RideCategoryDto(
      id: 'cat_car_plus',
      code: 'plus',
      name: 'GoRide Plus',
      description: 'More comfort and legroom in premium electric sedans',
      passengerCapacity: 4,
      capacityLabel: '4 Seats',
      baseFareKobo: 350000,
      etaMinutes: 3,
      features: ['AC', 'Extra legroom', 'Top rated', 'Quiet ride'],
      iconKey: 'electric_car',
      displayOrder: 4,
    ),
    RideCategoryDto(
      id: 'cat_car_xl',
      code: 'xl',
      name: 'GoRide XL',
      description: 'Bigger 6-seater electric vehicles for groups or extra luggage',
      passengerCapacity: 6,
      capacityLabel: '6 Seats',
      baseFareKobo: 450000,
      etaMinutes: 4,
      features: ['AC', '6 Seats', 'Spacious trunk', 'Group trips'],
      iconKey: 'electric_car',
      displayOrder: 5,
    ),
  ];

  /// Fetches available server-managed ride categories (v1.3 §5.4).
  Future<List<RideCategoryDto>> getRideCategories() async {
    try {
      final response = await _client.getRideCategories();
      if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
        return response.data!;
      }
    } catch (_) {}
    return _fallbackRideCategories;
  }

  /// Validates a promotional coupon code.
  Future<CouponValidationDto> validateCoupon({
    required String code,
    required int quoteAmountKobo,
    String? serviceCode,
  }) async {
    final response = await _client.validateCoupon(
      code: code,
      quoteAmountKobo: quoteAmountKobo,
      serviceCode: serviceCode,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?.message ?? 'Invalid promo code');
  }

  /// Retrieves finalized digital trip receipt.
  Future<TripReceiptDto> getTripReceipt(String bookingId) async {
    final response = await _client.getTripReceipt(bookingId);
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?.message ?? 'Trip receipt not found');
  }

  /// Submits post-trip rating and feedback.
  Future<bool> submitTripRating(TripRatingDto rating) async {
    final response = await _client.submitTripRating(rating);
    return response.isSuccess;
  }
}

/// Provider for [BookingRepository].
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return BookingRepository(client: client);
});
