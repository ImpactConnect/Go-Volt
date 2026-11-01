import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/errand_repository.dart';
import '../domain/shopping_flow_state.dart';

final shoppingErrandNotifierProvider =
    StateNotifierProvider<ShoppingErrandNotifier, ShoppingFlowState>((ref) {
  final repository = ref.watch(errandRepositoryProvider);
  return ShoppingErrandNotifier(repository: repository);
});

class ShoppingErrandNotifier extends StateNotifier<ShoppingFlowState> {
  ShoppingErrandNotifier({required this.repository})
      : super(ShoppingFlowState(
          items: [
            const ShoppingItemDto(
              id: 'it_01',
              name: 'Tomatoes',
              quantity: 2,
              unit: 'kg',
              estimatedPriceKobo: 200000, // ₦2,000/kg * 2 = ₦4,000
              preferenceNotes: 'Fresh, medium size',
            ),
            const ShoppingItemDto(
              id: 'it_02',
              name: 'Onions',
              quantity: 1,
              unit: 'kg',
              estimatedPriceKobo: 150000, // ₦1,500
              preferenceNotes: 'Dry red onions',
            ),
            const ShoppingItemDto(
              id: 'it_03',
              name: 'Rice (Mama\'s Pride)',
              quantity: 1,
              unit: '5 kg bag',
              estimatedPriceKobo: 850000, // ₦8,500
              preferenceNotes: 'Well parboiled',
            ),
          ],
        )) {
    // Select Kakuri Main Market by default if available
    _initDefaultShop();
  }

  final ErrandRepository repository;

  Future<void> _initDefaultShop() async {
    try {
      final shops = await repository.getShops();
      if (shops.isNotEmpty && state.selectedShop == null) {
        state = state.copyWith(selectedShop: shops.first);
        await calculateQuote();
      }
    } catch (_) {
      // Safe fallback handled by repository
    }
  }

  void selectShop(ShopDto shop) {
    state = state.copyWith(selectedShop: shop);
    calculateQuote();
  }

  void setCustomShop({
    required String name,
    required String address,
    String? phoneNumber,
  }) {
    final customShop = ShopDto(
      id: 'custom_shop_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      address: address,
      latitude: 10.5000,
      longitude: 7.4300,
      category: 'Custom Location',
      phoneNumber: phoneNumber,
      isCustom: true,
      distanceKm: 2.5,
    );
    state = state.copyWith(selectedShop: customShop);
    calculateQuote();
  }

  void addItem(ShoppingItemDto item) {
    final updated = List<ShoppingItemDto>.from(state.items)..add(item);
    state = state.copyWith(items: updated);
    calculateQuote();
  }

  void removeItem(String itemId) {
    final updated = state.items.where((i) => i.id != itemId).toList();
    state = state.copyWith(items: updated);
    calculateQuote();
  }

  void incrementQuantity(String itemId) {
    final updated = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updated);
    calculateQuote();
  }

  void decrementQuantity(String itemId) {
    final item = state.items.firstWhere((i) => i.id == itemId);
    if (item.quantity <= 1) {
      removeItem(itemId);
      return;
    }
    final updated = state.items.map((i) {
      if (i.id == itemId) {
        return i.copyWith(quantity: i.quantity - 1);
      }
      return i;
    }).toList();
    state = state.copyWith(items: updated);
    calculateQuote();
  }

  void setSubstitutionPolicy(SubstitutionPolicy policy) {
    state = state.copyWith(
      preferences: state.preferences.copyWith(substitutionPolicy: policy),
    );
  }

  void setAdditionalInstructions(String instructions) {
    state = state.copyWith(
      preferences:
          state.preferences.copyWith(additionalInstructions: instructions),
    );
  }

  void setDeliveryLocation(LocationDto location) {
    state = state.copyWith(deliveryLocation: location);
    calculateQuote();
  }

  void setRecipient(RecipientDetailsDto recipient) {
    state = state.copyWith(recipient: recipient);
  }

  void setDeliveryTime(String timeStr) {
    state = state.copyWith(deliveryTimeStr: timeStr);
  }

  void setDeliveryNotes(String notes) {
    state = state.copyWith(deliveryNotes: notes);
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  Future<void> calculateQuote() async {
    final shop = state.selectedShop;
    final distanceKm = shop?.distanceKm ?? 2.5;

    final payload = {
      'errand_type': 'BUY_ITEMS',
      'distance_km': distanceKm,
      'items': state.items.map((i) => i.toJson()).toList(),
    };

    try {
      final quote = await repository.requestQuote(payload);
      state = state.copyWith(quote: quote);
    } catch (e) {
      // Deterministic calculation
      final itemsCost = state.totalEstimatedItemsKobo;
      const serviceFee = 80000;
      final deliveryFee = 100000 + (distanceKm * 8000).round();
      final total = itemsCost + serviceFee + deliveryFee;

      state = state.copyWith(
        quote: ErrandQuoteDto(
          id: 'quote_local',
          errandType: ErrandType.buyItems,
          estimatedItemsCostKobo: itemsCost,
          serviceFeeKobo: serviceFee,
          deliveryFeeKobo: deliveryFee,
          totalKobo: total,
          distanceKm: distanceKm,
        ),
      );
    }
  }

  Future<bool> submitOrder() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      if (state.quote == null) {
        await calculateQuote();
      }

      final payload = {
        'type': 'BUY_ITEMS',
        'shop': state.selectedShop?.toJson(),
        'items': state.items.map((i) => i.toJson()).toList(),
        'preferences': state.preferences.toJson(),
        'delivery_location': state.deliveryLocation.toJson(),
        'recipient': state.recipient.toJson(),
        'delivery_time_str': state.deliveryTimeStr,
        'delivery_notes': state.deliveryNotes,
        'quote': state.quote?.toJson(),
        'payment_method': state.paymentMethod.code,
      };

      final created = await repository.createErrand(payload);
      state = state.copyWith(
        activeErrand: created,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> advanceStatusForTesting() async {
    final current = state.activeErrand;
    if (current == null) return;

    try {
      final updated = await repository.advanceStatus(current.id);
      state = state.copyWith(activeErrand: updated);
    } catch (_) {
      // Offline fallback milestone advancement
      ErrandStatus next;
      switch (current.status) {
        case ErrandStatus.agentAssigned:
          next = ErrandStatus.shoppingInProgress;
          break;
        case ErrandStatus.shoppingInProgress:
          next = ErrandStatus.itemsPurchased;
          break;
        case ErrandStatus.itemsPurchased:
          next = ErrandStatus.outForDelivery;
          break;
        case ErrandStatus.outForDelivery:
          next = ErrandStatus.delivered;
          break;
        case ErrandStatus.delivered:
          next = ErrandStatus.completed;
          break;
        default:
          next = current.status;
      }
      state = state.copyWith(
        activeErrand: current.copyWith(
          status: next,
          completedAt: next == ErrandStatus.completed ? DateTime.now() : null,
        ),
      );
    }
  }

  void resetFlow() {
    state = const ShoppingFlowState();
  }
}

