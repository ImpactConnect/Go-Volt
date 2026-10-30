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

  bool get hasValidRoute => pickupLocation != null && dropoffLocation != null;

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
    bool clearQuote = false,
    bool clearError = false,
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
      ];
}
