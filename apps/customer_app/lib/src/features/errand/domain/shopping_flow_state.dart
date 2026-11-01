import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// Immutable state container for Flow A: Buy Items From a Shop (Screens A1 to A7).
class ShoppingFlowState extends Equatable {
  const ShoppingFlowState({
    this.selectedShop,
    this.items = const [],
    this.preferences = const ShoppingPreferencesDto(
      substitutionPolicy: SubstitutionPolicy.contactFirst,
      additionalInstructions: '',
    ),
    this.deliveryLocation = LocationDto.empty,
    this.recipient = RecipientDetailsDto.defaultRecipient,
    this.deliveryTimeStr = 'As soon as possible',
    this.deliveryNotes = '',
    this.quote,
    this.paymentMethod = PaymentMethod.wallet,
    this.activeErrand,
    this.isLoading = false,
    this.errorMessage,
  });

  final ShopDto? selectedShop;
  final List<ShoppingItemDto> items;
  final ShoppingPreferencesDto preferences;
  final LocationDto deliveryLocation;
  final RecipientDetailsDto recipient;
  final String deliveryTimeStr;
  final String? deliveryNotes;
  final ErrandQuoteDto? quote;
  final PaymentMethod paymentMethod;
  final ErrandDto? activeErrand;
  final bool isLoading;
  final String? errorMessage;

  int get totalEstimatedItemsKobo =>
      items.fold(0, (acc, item) => acc + (item.estimatedPriceKobo * item.quantity));

  int get itemsCount => items.length;

  bool get canProceedFromShop => selectedShop != null;
  bool get canProceedFromItems => items.isNotEmpty;
  bool get canProceedFromDelivery =>
      deliveryLocation.address.isNotEmpty &&
      recipient.fullName.isNotEmpty &&
      recipient.phoneNumber.isNotEmpty;

  ShoppingFlowState copyWith({
    ShopDto? selectedShop,
    bool clearShop = false,
    List<ShoppingItemDto>? items,
    ShoppingPreferencesDto? preferences,
    LocationDto? deliveryLocation,
    RecipientDetailsDto? recipient,
    String? deliveryTimeStr,
    String? deliveryNotes,
    ErrandQuoteDto? quote,
    PaymentMethod? paymentMethod,
    ErrandDto? activeErrand,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ShoppingFlowState(
      selectedShop: clearShop ? null : (selectedShop ?? this.selectedShop),
      items: items ?? this.items,
      preferences: preferences ?? this.preferences,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      recipient: recipient ?? this.recipient,
      deliveryTimeStr: deliveryTimeStr ?? this.deliveryTimeStr,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      quote: quote ?? this.quote,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      activeErrand: activeErrand ?? this.activeErrand,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        selectedShop,
        items,
        preferences,
        deliveryLocation,
        recipient,
        deliveryTimeStr,
        deliveryNotes,
        quote,
        paymentMethod,
        activeErrand,
        isLoading,
        errorMessage,
      ];
}

