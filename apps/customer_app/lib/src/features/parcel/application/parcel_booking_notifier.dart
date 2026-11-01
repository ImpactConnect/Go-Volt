import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/parcel_repository.dart';
import '../domain/parcel_booking_flow_state.dart';

final parcelBookingNotifierProvider =
    StateNotifierProvider<ParcelBookingNotifier, ParcelBookingFlowState>((ref) {
  final repository = ref.watch(parcelRepositoryProvider);
  return ParcelBookingNotifier(repository: repository);
});

class ParcelBookingNotifier extends StateNotifier<ParcelBookingFlowState> {
  ParcelBookingNotifier({
    ParcelRepository? repository,
    ParcelBookingFlowState? initialState,
  })  : _repository = repository,
        super(initialState ?? const ParcelBookingFlowState());

  final ParcelRepository? _repository;

  void selectDeliveryOption(DeliveryOptionDto option) {
    state = state.copyWith(selectedDeliveryOption: option);
    _recalculateQuote();
  }

  void selectCategory(ParcelCategoryDto category) {
    final updatedOptions = state.handlingOptions.map((opt) {
      if (opt.code == 'FRAGILE' && category.code == 'FRAGILE') {
        return opt.copyWith(isEnabled: true);
      }
      if (opt.code == 'PERISHABLE' && category.code == 'FOOD') {
        return opt.copyWith(isEnabled: true);
      }
      return opt;
    }).toList();

    state = state.copyWith(
      selectedCategory: category,
      handlingOptions: updatedOptions,
    );
    _recalculateQuote();
  }

  void setWeight(double weight) {
    // If weight exceeds small band, upgrade to medium or large
    ParcelSizeBandDto size = state.selectedSizeBand;
    if (weight > 5.0) {
      size = ParcelSizeBandDto.large;
    } else if (weight > 2.0 && size.code == 'SMALL') {
      size = ParcelSizeBandDto.medium;
    }

    state = state.copyWith(weightKg: weight, selectedSizeBand: size);
    _recalculateQuote();
  }

  void selectSizeBand(ParcelSizeBandDto sizeBand) {
    state = state.copyWith(selectedSizeBand: sizeBand);
    _recalculateQuote();
  }

  void toggleHandlingOption(String code, bool isEnabled) {
    final updated = state.handlingOptions.map((opt) {
      if (opt.code == code) {
        return opt.copyWith(isEnabled: isEnabled);
      }
      return opt;
    }).toList();

    state = state.copyWith(handlingOptions: updated);
    _recalculateQuote();
  }

  void setPickupLocation(LocationDto location) {
    state = state.copyWith(pickupLocation: location);
    _recalculateQuote();
  }

  void setRecipient(RecipientDetailsDto recipient) {
    state = state.copyWith(
      recipient: recipient,
      destinationLocation: LocationDto(
        latitude: recipient.latitude ?? 6.4357,
        longitude: recipient.longitude ?? 3.4418,
        address: recipient.deliveryAddress,
        label: recipient.deliveryAddress.split(',').first.trim(),
      ),
    );
    _recalculateQuote();
  }

  void setDestinationLocation(LocationDto location) {
    state = state.copyWith(
      destinationLocation: location,
      recipient: state.recipient?.copyWith(
        deliveryAddress: location.address,
        latitude: location.latitude,
        longitude: location.longitude,
      ),
    );
    _recalculateQuote();
  }

  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setTermsAccepted(bool accepted) {
    state = state.copyWith(termsAccepted: accepted);
  }

  bool applyPromoCode(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code == 'DELIVER20' || code == 'GO20') {
      // 20% discount on base fare in exact integer kobo
      final base = state.selectedDeliveryOption.baseFareKobo;
      final discount = (base * 0.20).round();

      state = state.copyWith(appliedPromoCode: code, discountKobo: discount);
      _recalculateQuote();
      return true;
    } else {
      state = state.copyWith(clearAppliedPromoCode: true, discountKobo: 0);
      _recalculateQuote();
      return false;
    }
  }

  void removePromoCode() {
    state = state.copyWith(clearAppliedPromoCode: true, discountKobo: 0);
    _recalculateQuote();
  }

  void _recalculateQuote() {
    final baseFare = state.selectedDeliveryOption.baseFareKobo;
    final handling =
        state.totalHandlingSurchargeKobo + state.selectedSizeBand.surchargeKobo;
    const distanceFare = 30000; // ₦300 for 12.4 km sample route
    const insuranceFare = 0;

    final quote = ParcelPriceBreakdownDto(
      baseFareKobo: baseFare,
      distanceFareKobo: distanceFare,
      handlingFareKobo: handling,
      insuranceFareKobo: insuranceFare,
      discountKobo: state.discountKobo,
      distanceKm: 12.4,
      estimatedMinutes: state.selectedDeliveryOption.code == 'EXPRESS'
          ? 15
          : 25,
    );

    state = state.copyWith(quote: quote);
  }

  Future<ParcelDeliveryDto> commitBooking({bool simulateDelay = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (simulateDelay) {
      // Simulate backend confirmation & dispatch initiation
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    ParcelDeliveryDto delivery;
    if (_repository != null) {
      delivery = await _repository.createDelivery(
        deliveryOption: state.selectedDeliveryOption,
        pickupLocation: state.pickupLocation ??
            const LocationDto(
              latitude: 6.4281,
              longitude: 3.4219,
              address: 'Adetokunbo Ademola St, Victoria Island, Lagos',
              label: 'Eko Hotel and Suites',
            ),
        destinationLocation: state.destinationLocation ??
            const LocationDto(
              latitude: 6.4357,
              longitude: 3.4418,
              address: 'Palms Mall, Lekki, Lagos',
              label: 'Palms Mall',
            ),
        recipient: state.recipient ?? RecipientDetailsDto.defaultRecipient,
        packageDetails: state.packageDetails,
        priceBreakdown: state.quote ?? ParcelPriceBreakdownDto.defaultBreakdown,
        paymentMethod: state.paymentMethod,
        couponCode: state.appliedPromoCode,
      );
    } else {
      delivery = ParcelDeliveryDto(
        id: 'del_${DateTime.now().millisecondsSinceEpoch}',
        trackingNumber: 'DVL12345678',
        status: BookingStatus.assigned,
        deliveryOption: state.selectedDeliveryOption,
        pickupLocation: state.pickupLocation ??
            const LocationDto(
              latitude: 6.4281,
              longitude: 3.4219,
              address: 'Adetokunbo Ademola St, Victoria Island, Lagos',
              label: 'Eko Hotel and Suites',
            ),
        destinationLocation: state.destinationLocation ??
            const LocationDto(
              latitude: 6.4357,
              longitude: 3.4418,
              address: 'Palms Mall, Lekki, Lagos',
              label: 'Palms Mall',
            ),
        recipient: state.recipient ?? RecipientDetailsDto.defaultRecipient,
        packageDetails: state.packageDetails,
        priceBreakdown: state.quote ?? ParcelPriceBreakdownDto.defaultBreakdown,
        paymentMethod: state.paymentMethod,
        riderName: null,
        riderPhone: null,
        riderRating: null,
        riderTotalTrips: null,
        riderVehicle: null,
        createdAt: DateTime.now(),
        pickupTimestamp: DateTime.now().add(const Duration(minutes: 6)),
        etaMinutes: 6,
      );
    }

    state = state.copyWith(isLoading: false, activeDelivery: delivery);

    return delivery;
  }

  void updateDeliveryStatus(BookingStatus status, {int? etaMinutes}) {
    if (state.activeDelivery != null) {
      final updated = state.activeDelivery!.copyWith(
        status: status,
        etaMinutes: etaMinutes ?? state.activeDelivery!.etaMinutes,
      );
      state = state.copyWith(activeDelivery: updated);
    }
  }

  void cancelDelivery() {
    if (state.activeDelivery != null) {
      _repository?.cancelDelivery(
        state.activeDelivery!.id,
        reason: 'Customer cancelled delivery',
      );
      final updated = state.activeDelivery!.copyWith(
        status: BookingStatus.cancelled,
      );
      state = state.copyWith(activeDelivery: updated);
    }
  }

  void submitRating(ParcelRatingDto rating) {
    _repository?.submitRating(rating);
    state = state.copyWith(submittedRating: rating);
  }

  void reset() {
    state = const ParcelBookingFlowState();
  }
}
