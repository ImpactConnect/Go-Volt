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

  /// Fetches available server-managed ride categories (v1.3 §5.4).
  Future<List<RideCategoryDto>> getRideCategories() async {
    final response = await _client.getRideCategories();
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return [];
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
