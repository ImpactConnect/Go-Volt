import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// Immutable state container for Flow B: Pick Up a Package (Screens B1 to B6).
class PackageFlowState extends Equatable {
  const PackageFlowState({
    this.pickupDetails = PackagePickupDetailsDto.empty,
    this.packageDescription = '',
    this.category = '',
    this.sizeBand = '',
    this.weightBand = '',
    this.isFragile = false,
    this.keepUpright = false,
    this.deliveryLocation = LocationDto.empty,
    this.recipient = RecipientDetailsDto.defaultRecipient,
    this.deliveryInstructions = '',
    this.quote,
    this.paymentMethod = PaymentMethod.wallet,
    this.activeErrand,
    this.isLoading = false,
    this.errorMessage,
  });

  final PackagePickupDetailsDto pickupDetails;
  final String packageDescription;
  final String category;
  final String sizeBand;
  final String weightBand;
  final bool isFragile;
  final bool keepUpright;
  final LocationDto deliveryLocation;
  final RecipientDetailsDto recipient;
  final String deliveryInstructions;
  final ErrandQuoteDto? quote;
  final PaymentMethod paymentMethod;
  final ErrandDto? activeErrand;
  final bool isLoading;
  final String? errorMessage;

  bool get canProceedFromPickup =>
      pickupDetails.pickupBusinessName.trim().isNotEmpty &&
      pickupDetails.address.trim().isNotEmpty &&
      pickupDetails.contactPerson.trim().isNotEmpty &&
      pickupDetails.phoneNumber.trim().isNotEmpty;

  bool get canProceedFromPackage =>
      packageDescription.trim().isNotEmpty &&
      category.isNotEmpty &&
      sizeBand.isNotEmpty &&
      weightBand.isNotEmpty;

  bool get canProceedFromDelivery =>
      deliveryLocation.address.trim().isNotEmpty &&
      recipient.fullName.trim().isNotEmpty &&
      recipient.phoneNumber.trim().isNotEmpty;

  PackageFlowState copyWith({
    PackagePickupDetailsDto? pickupDetails,
    String? packageDescription,
    String? category,
    String? sizeBand,
    String? weightBand,
    bool? isFragile,
    bool? keepUpright,
    LocationDto? deliveryLocation,
    RecipientDetailsDto? recipient,
    String? deliveryInstructions,
    ErrandQuoteDto? quote,
    PaymentMethod? paymentMethod,
    ErrandDto? activeErrand,
    bool clearActiveErrand = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PackageFlowState(
      pickupDetails: pickupDetails ?? this.pickupDetails,
      packageDescription: packageDescription ?? this.packageDescription,
      category: category ?? this.category,
      sizeBand: sizeBand ?? this.sizeBand,
      weightBand: weightBand ?? this.weightBand,
      isFragile: isFragile ?? this.isFragile,
      keepUpright: keepUpright ?? this.keepUpright,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      recipient: recipient ?? this.recipient,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      quote: quote ?? this.quote,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      activeErrand: clearActiveErrand ? null : (activeErrand ?? this.activeErrand),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        pickupDetails,
        packageDescription,
        category,
        sizeBand,
        weightBand,
        isFragile,
        keepUpright,
        deliveryLocation,
        recipient,
        deliveryInstructions,
        quote,
        paymentMethod,
        activeErrand,
        isLoading,
        errorMessage,
      ];
}

