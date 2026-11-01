import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// Immutable state container for Flow B: Pick Up a Package (Screens B1 to B6).
class PackageFlowState extends Equatable {
  const PackageFlowState({
    this.pickupDetails = const PackagePickupDetailsDto(
      pickupBusinessName: 'Jumia Pickup Point, Barnawa',
      address: 'Barnawa, Kaduna',
      latitude: 10.4851,
      longitude: 7.4294,
      contactPerson: 'Mr. Sani Musa',
      phoneNumber: '0806 321 0987',
      referenceOrderNumber: 'JM-7788290',
    ),
    this.packageDescription = 'Electronics (Headset)',
    this.category = 'Electronics',
    this.sizeBand = 'Medium (up to 50 cm)',
    this.weightBand = '2 - 5 kg',
    this.isFragile = true,
    this.keepUpright = false,
    this.deliveryLocation = const LocationDto(
      latitude: 10.4921,
      longitude: 7.4112,
      address: '3, De-West Plaza, Power Plant',
      label: 'De-West Plaza',
    ),
    this.recipient = const RecipientDetailsDto(
      fullName: 'Omotayo Kehinde',
      phoneNumber: '0803 456 7890',
      deliveryAddress: '3, De-West Plaza, Power Plant',
    ),
    this.deliveryInstructions = 'Ring the bell and hand over to the reception.',
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

