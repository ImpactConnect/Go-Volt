import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_repository.dart';
import '../domain/booking_flow_state.dart';

/// StateNotifier managing end-to-end booking lifecycle, quote negotiation, and dispatch.
class BookingNotifier extends StateNotifier<BookingFlowState> {
  BookingNotifier({required BookingRepository repository})
      : _repository = repository,
        super(const BookingFlowState());

  final BookingRepository _repository;

  void selectService(ServiceCode serviceCode) {
    state = state.copyWith(
      serviceCode: serviceCode,
      clearQuote: true,
      clearError: true,
    );
  }

  void setPickupLocation(LocationDto pickup) {
    state = state.copyWith(
      pickupLocation: pickup,
      clearQuote: true,
      clearError: true,
    );
    if (state.hasValidRoute) {
      fetchQuote();
    }
  }

  void setDropoffLocation(LocationDto dropoff) {
    state = state.copyWith(
      dropoffLocation: dropoff,
      clearQuote: true,
      clearError: true,
    );
    if (state.hasValidRoute) {
      fetchQuote();
    }
  }

  void swapLocations() {
    if (state.pickupLocation == null && state.dropoffLocation == null) return;
    final tempPickup = state.pickupLocation;
    state = state.copyWith(
      pickupLocation: state.dropoffLocation,
      dropoffLocation: tempPickup,
      clearQuote: true,
      clearError: true,
    );
    if (state.hasValidRoute) {
      fetchQuote();
    }
  }

  void clearPickupLocation() {
    state = state.copyWith(
      pickupLocation: null,
      clearQuote: true,
      clearError: true,
    );
  }

  void clearDropoffLocation() {
    state = state.copyWith(
      dropoffLocation: null,
      clearQuote: true,
      clearError: true,
    );
  }

  Future<void> fetchRideCategories() async {
    try {
      final categories = await _repository.getRideCategories();
      state = state.copyWith(rideCategories: categories);
    } catch (_) {
      // Fallback or keep current
    }
  }

  void selectRideCategory(String categoryId) {
    state = state.copyWith(selectedRideCategoryId: categoryId);
  }

  Future<bool> applyCoupon(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return false;

    state = state.copyWith(
      isApplyingCoupon: true,
      clearCouponError: true,
    );

    try {
      final quoteAmount =
          state.quote?.priceBreakdown.totalAmountKobo ?? 280000;

      final validation = await _repository.validateCoupon(
        code: trimmed,
        quoteAmountKobo: quoteAmount,
        serviceCode: state.serviceCode.code,
      );

      state = state.copyWith(
        appliedCoupon: validation,
        isApplyingCoupon: false,
        clearCouponError: true,
      );
      return validation.isValid;
    } catch (e) {
      state = state.copyWith(
        isApplyingCoupon: false,
        couponError: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void removeCoupon() {
    state = state.copyWith(
      clearCoupon: true,
      clearCouponError: true,
    );
  }

  void selectVehicleType(VehicleType vehicleType) {
    state = state.copyWith(selectedVehicleType: vehicleType);
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void setPackageDetails({
    required PackageCategory category,
    required double weightKg,
    required String recipientName,
    required String recipientPhone,
    String? instructions,
  }) {
    state = state.copyWith(
      packageCategory: category,
      packageWeightKg: weightKg,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      instructions: instructions,
    );
    if (state.hasValidRoute) {
      fetchQuote();
    }
  }

  void setSchedule({
    required DateTime scheduledTime,
    String? recurringFrequency,
  }) {
    state = state.copyWith(
      scheduledTime: scheduledTime,
      recurringFrequency: recurringFrequency,
    );
    if (state.hasValidRoute) {
      fetchQuote();
    }
  }

  Future<void> fetchQuote() async {
    if (!state.hasValidRoute) return;

    state = state.copyWith(isLoadingQuote: true, clearError: true);

    try {
      final quote = await _repository.requestQuote(
        serviceCode: state.serviceCode,
        pickup: state.pickupLocation!,
        dropoff: state.dropoffLocation!,
        scheduledTime: state.scheduledTime,
        packageCategory: state.packageCategory,
      );

      state = state.copyWith(
        quote: quote,
        isLoadingQuote: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingQuote: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<BookingDto?> commitBooking() async {
    if (state.quote == null) {
      await fetchQuote();
      if (state.quote == null) return null;
    }

    state = state.copyWith(isCreatingBooking: true, clearError: true);

    try {
      final booking = await _repository.createBooking(
        quoteId: state.quote!.quoteId,
        paymentMethod: state.selectedPaymentMethod,
        instructions: state.instructions,
        recipientName: state.recipientName,
        recipientPhone: state.recipientPhone,
      );

      state = state.copyWith(
        activeBooking: booking,
        isCreatingBooking: false,
      );

      return booking;
    } catch (e) {
      state = state.copyWith(
        isCreatingBooking: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  Future<bool> cancelBooking(String bookingId, {required String reason}) async {
    try {
      final updated = await _repository.cancelBooking(bookingId, reason: reason);
      state = state.copyWith(activeBooking: updated);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void resetFlow() {
    state = const BookingFlowState();
  }
}

/// Provider for [BookingNotifier].
final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, BookingFlowState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingNotifier(repository: repository);
});
