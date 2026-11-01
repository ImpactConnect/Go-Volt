import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// Immutable state container for the Go-Volts Send parcel booking flow (Screens 1 to 17).
class ParcelBookingFlowState extends Equatable {
  const ParcelBookingFlowState({
    this.selectedDeliveryOption = DeliveryOptionDto.standard,
    this.selectedCategory = ParcelCategoryDto.fragile,
    this.weightKg = 1.5,
    this.selectedSizeBand = ParcelSizeBandDto.small,
    this.handlingOptions = const [
      SpecialHandlingOptionDto(
        code: 'FRAGILE',
        label: 'Fragile (Handle with care)',
        surchargeKobo: 20000,
        isEnabled: true,
      ),
      SpecialHandlingOptionDto(
        code: 'KEEP_UPRIGHT',
        label: 'Keep upright',
        surchargeKobo: 0,
        isEnabled: false,
      ),
      SpecialHandlingOptionDto(
        code: 'PERISHABLE',
        label: 'Perishable (e.g. food)',
        surchargeKobo: 10000,
        isEnabled: false,
      ),
    ],
    this.pickupLocation = const LocationDto(
      latitude: 6.8403,
      longitude: 3.6487,
      address: 'Central Roundabout, Shaganu, Ogun State',
      label: 'Shaganu Central',
    ),
    this.recipient = RecipientDetailsDto.defaultRecipient,
    this.destinationLocation = const LocationDto(
      latitude: 6.8420,
      longitude: 3.6500,
      address: 'Main Market, Shaganu, Ogun State',
      label: 'Shaganu Main Market',
    ),
    this.quote = ParcelPriceBreakdownDto.defaultBreakdown,
    this.paymentMethod = PaymentMethod.wallet,
    this.appliedPromoCode,
    this.discountKobo = 0,
    this.isLoading = false,
    this.errorMessage,
    this.activeDelivery,
    this.termsAccepted = true,
    this.submittedRating,
  });

  final DeliveryOptionDto selectedDeliveryOption;
  final ParcelCategoryDto selectedCategory;
  final double weightKg;
  final ParcelSizeBandDto selectedSizeBand;
  final List<SpecialHandlingOptionDto> handlingOptions;
  final LocationDto? pickupLocation;
  final RecipientDetailsDto? recipient;
  final LocationDto? destinationLocation;
  final ParcelPriceBreakdownDto? quote;
  final PaymentMethod paymentMethod;
  final String? appliedPromoCode;
  final int discountKobo;
  final bool isLoading;
  final String? errorMessage;
  final ParcelDeliveryDto? activeDelivery;
  final bool termsAccepted;
  final ParcelRatingDto? submittedRating;

  bool get isFragile =>
      handlingOptions.any((h) => h.code == 'FRAGILE' && h.isEnabled) ||
      selectedCategory.code == 'FRAGILE';

  int get totalHandlingSurchargeKobo => handlingOptions
      .where((h) => h.isEnabled)
      .fold(0, (acc, h) => acc + h.surchargeKobo);

  ParcelDetailsDto get packageDetails => ParcelDetailsDto(
    category: selectedCategory,
    weightKg: weightKg,
    sizeBand: selectedSizeBand,
    handlingOptions: handlingOptions,
  );

  ParcelBookingFlowState copyWith({
    DeliveryOptionDto? selectedDeliveryOption,
    ParcelCategoryDto? selectedCategory,
    double? weightKg,
    ParcelSizeBandDto? selectedSizeBand,
    List<SpecialHandlingOptionDto>? handlingOptions,
    LocationDto? pickupLocation,
    RecipientDetailsDto? recipient,
    LocationDto? destinationLocation,
    ParcelPriceBreakdownDto? quote,
    PaymentMethod? paymentMethod,
    String? appliedPromoCode,
    bool clearAppliedPromoCode = false,
    int? discountKobo,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    ParcelDeliveryDto? activeDelivery,
    bool clearActiveDelivery = false,
    bool? termsAccepted,
    ParcelRatingDto? submittedRating,
    bool clearSubmittedRating = false,
  }) {
    return ParcelBookingFlowState(
      selectedDeliveryOption:
          selectedDeliveryOption ?? this.selectedDeliveryOption,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      weightKg: weightKg ?? this.weightKg,
      selectedSizeBand: selectedSizeBand ?? this.selectedSizeBand,
      handlingOptions: handlingOptions ?? this.handlingOptions,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      recipient: recipient ?? this.recipient,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      quote: quote ?? this.quote,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      appliedPromoCode: clearAppliedPromoCode
          ? null
          : (appliedPromoCode ?? this.appliedPromoCode),
      discountKobo: discountKobo ?? this.discountKobo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      activeDelivery: clearActiveDelivery
          ? null
          : (activeDelivery ?? this.activeDelivery),
      termsAccepted: termsAccepted ?? this.termsAccepted,
      submittedRating: clearSubmittedRating
          ? null
          : (submittedRating ?? this.submittedRating),
    );
  }

  @override
  List<Object?> get props => [
    selectedDeliveryOption,
    selectedCategory,
    weightKg,
    selectedSizeBand,
    handlingOptions,
    pickupLocation,
    recipient,
    destinationLocation,
    quote,
    paymentMethod,
    appliedPromoCode,
    discountKobo,
    isLoading,
    errorMessage,
    activeDelivery,
    termsAccepted,
    submittedRating,
  ];
}
