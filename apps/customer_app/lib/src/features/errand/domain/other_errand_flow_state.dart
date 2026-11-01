import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// Immutable state container for Flow C: Other Errand (Screens C1 to C6).
class OtherErrandFlowState extends Equatable {
  const OtherErrandFlowState({
    this.taskDescription = '',
    this.category = '',
    this.urgency = ErrandUrgency.standard,
    this.pickupLocation = LocationDto.empty,
    this.contactPerson = '',
    this.phoneNumber = '',
    this.deliveryLocation = LocationDto.empty,
    this.additionalInstructions = '',
    this.quote,
    this.paymentMethod = PaymentMethod.wallet,
    this.activeErrand,
    this.isQuoteAccepted = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final String taskDescription;
  final String category;
  final ErrandUrgency urgency;
  final LocationDto pickupLocation;
  final String contactPerson;
  final String phoneNumber;
  final LocationDto deliveryLocation;
  final String additionalInstructions;
  final ErrandQuoteDto? quote;
  final PaymentMethod paymentMethod;
  final ErrandDto? activeErrand;
  final bool isQuoteAccepted;
  final bool isLoading;
  final String? errorMessage;

  bool get canProceedFromDescribe =>
      taskDescription.trim().isNotEmpty && taskDescription.length <= 300;

  bool get canProceedFromDetails =>
      pickupLocation.address.trim().isNotEmpty &&
      contactPerson.trim().isNotEmpty &&
      phoneNumber.trim().isNotEmpty &&
      deliveryLocation.address.trim().isNotEmpty;

  OtherErrandFlowState copyWith({
    String? taskDescription,
    String? category,
    ErrandUrgency? urgency,
    LocationDto? pickupLocation,
    String? contactPerson,
    String? phoneNumber,
    LocationDto? deliveryLocation,
    String? additionalInstructions,
    ErrandQuoteDto? quote,
    PaymentMethod? paymentMethod,
    ErrandDto? activeErrand,
    bool clearActiveErrand = false,
    bool? isQuoteAccepted,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OtherErrandFlowState(
      taskDescription: taskDescription ?? this.taskDescription,
      category: category ?? this.category,
      urgency: urgency ?? this.urgency,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      contactPerson: contactPerson ?? this.contactPerson,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      additionalInstructions:
          additionalInstructions ?? this.additionalInstructions,
      quote: quote ?? this.quote,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      activeErrand: clearActiveErrand ? null : (activeErrand ?? this.activeErrand),
      isQuoteAccepted: isQuoteAccepted ?? this.isQuoteAccepted,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        taskDescription,
        category,
        urgency,
        pickupLocation,
        contactPerson,
        phoneNumber,
        deliveryLocation,
        additionalInstructions,
        quote,
        paymentMethod,
        activeErrand,
        isQuoteAccepted,
        isLoading,
        errorMessage,
      ];
}

