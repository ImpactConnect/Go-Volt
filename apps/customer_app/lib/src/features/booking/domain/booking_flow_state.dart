import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// State representation for active booking flows in Go-Volts customer app.
class BookingFlowState extends Equatable {
  const BookingFlowState({
    this.serviceCode = ServiceCode.instantRide,
    this.pickupLocation,
    this.dropoffLocation,
    this.selectedVehicleType = VehicleType.electricBike,
    this.selectedPaymentMethod = PaymentMethod.wallet,
    this.quote,
    this.packageCategory,
    this.packageWeightKg,
    this.recipientName,
    this.recipientPhone,
    this.instructions,
    this.scheduledTime,
    this.recurringFrequency,
    this.activeBooking,
    this.isLoadingQuote = false,
    this.isCreatingBooking = false,
    this.errorMessage,
    this.rideCategories = const [],
    this.selectedRideCategoryId,
    this.appliedCoupon,
    this.walletCreditAppliedKobo = 0,
    this.isApplyingCoupon = false,
    this.couponError,
  });

  final ServiceCode serviceCode;
  final LocationDto? pickupLocation;
  final LocationDto? dropoffLocation;
  final VehicleType selectedVehicleType;
  final PaymentMethod selectedPaymentMethod;
  final QuoteDto? quote;
  final PackageCategory? packageCategory;
  final double? packageWeightKg;
  final String? recipientName;
  final String? recipientPhone;
  final String? instructions;
  final DateTime? scheduledTime;
  final String? recurringFrequency;
  final BookingDto? activeBooking;
  final bool isLoadingQuote;
  final bool isCreatingBooking;
  final String? errorMessage;

  // Phase 3 & v1.3 Additions
  final List<RideCategoryDto> rideCategories;
  final String? selectedRideCategoryId;
  final CouponValidationDto? appliedCoupon;
  final int walletCreditAppliedKobo;
  final bool isApplyingCoupon;
  final String? couponError;

  bool get hasValidRoute => pickupLocation != null && dropoffLocation != null;

  RideCategoryDto? get selectedRideCategory {
    if (rideCategories.isEmpty) return null;
    if (selectedRideCategoryId == null) return rideCategories.first;
    return rideCategories.firstWhere(
      (c) => c.id == selectedRideCategoryId,
      orElse: () => rideCategories.first,
    );
  }

  BookingFlowState copyWith({
    ServiceCode? serviceCode,
    LocationDto? pickupLocation,
    LocationDto? dropoffLocation,
    VehicleType? selectedVehicleType,
    PaymentMethod? selectedPaymentMethod,
    QuoteDto? quote,
    PackageCategory? packageCategory,
    double? packageWeightKg,
    String? recipientName,
    String? recipientPhone,
    String? instructions,
    DateTime? scheduledTime,
    String? recurringFrequency,
    BookingDto? activeBooking,
    bool? isLoadingQuote,
    bool? isCreatingBooking,
    String? errorMessage,
    List<RideCategoryDto>? rideCategories,
    String? selectedRideCategoryId,
    CouponValidationDto? appliedCoupon,
    int? walletCreditAppliedKobo,
    bool? isApplyingCoupon,
    String? couponError,
    bool clearQuote = false,
    bool clearError = false,
    bool clearCoupon = false,
    bool clearCouponError = false,
  }) {
    return BookingFlowState(
      serviceCode: serviceCode ?? this.serviceCode,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      quote: clearQuote ? null : (quote ?? this.quote),
      packageCategory: packageCategory ?? this.packageCategory,
      packageWeightKg: packageWeightKg ?? this.packageWeightKg,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      instructions: instructions ?? this.instructions,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      activeBooking: activeBooking ?? this.activeBooking,
      isLoadingQuote: isLoadingQuote ?? this.isLoadingQuote,
      isCreatingBooking: isCreatingBooking ?? this.isCreatingBooking,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      rideCategories: rideCategories ?? this.rideCategories,
      selectedRideCategoryId:
          selectedRideCategoryId ?? this.selectedRideCategoryId,
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      walletCreditAppliedKobo:
          walletCreditAppliedKobo ?? this.walletCreditAppliedKobo,
      isApplyingCoupon: isApplyingCoupon ?? this.isApplyingCoupon,
      couponError:
          clearCouponError ? null : (couponError ?? this.couponError),
    );
  }

  @override
  List<Object?> get props => [
        serviceCode,
        pickupLocation,
        dropoffLocation,
        selectedVehicleType,
        selectedPaymentMethod,
        quote,
        packageCategory,
        packageWeightKg,
        recipientName,
        recipientPhone,
        instructions,
        scheduledTime,
        recurringFrequency,
        activeBooking,
        isLoadingQuote,
        isCreatingBooking,
        errorMessage,
        rideCategories,
        selectedRideCategoryId,
        appliedCoupon,
        walletCreditAppliedKobo,
        isApplyingCoupon,
        couponError,
      ];
}
