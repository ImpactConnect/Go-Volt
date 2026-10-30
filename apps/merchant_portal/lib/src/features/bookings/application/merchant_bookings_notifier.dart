import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/merchant_delivery_model.dart';

class MerchantBookingsState extends Equatable {
  const MerchantBookingsState({
    this.bookings = const [],
    this.selectedBranchFilter = 'ALL',
    this.selectedStatusFilter = 'ALL',
    this.searchQuery = '',
    this.selectedBooking,
    this.isLoading = false,
    this.actionMessage,
    this.errorMessage,
  });

  final List<MerchantDeliveryBooking> bookings;
  final String selectedBranchFilter;
  final String selectedStatusFilter;
  final String searchQuery;
  final MerchantDeliveryBooking? selectedBooking;
  final bool isLoading;
  final String? actionMessage;
  final String? errorMessage;

  List<MerchantDeliveryBooking> get filteredBookings {
    return bookings.where((b) {
      if (selectedBranchFilter != 'ALL' && b.branchId != selectedBranchFilter) {
        return false;
      }
      if (selectedStatusFilter.toUpperCase() != 'ALL') {
        final filter = selectedStatusFilter.toLowerCase().replaceAll('_', '');
        final status = b.status.name.toLowerCase().replaceAll('_', '');
        if (!status.contains(filter) && !filter.contains(status)) {
          return false;
        }
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchesRef = b.trackingReference.toLowerCase().contains(q);
        final matchesRecipient = b.recipientName.toLowerCase().contains(q);
        final matchesPhone = b.recipientPhone.contains(q);
        final matchesAddress = b.deliveryAddress.toLowerCase().contains(q);
        final matchesRider = b.assignedRiderName?.toLowerCase().contains(q) ?? false;
        if (!matchesRef && !matchesRecipient && !matchesPhone && !matchesAddress && !matchesRider) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // KPI Getters
  int get totalDeliveriesCount => bookings.length;
  int get activeDispatchCount =>
      bookings.where((b) => b.status == BookingStatus.inProgress || b.status == BookingStatus.searchingRider || b.status == BookingStatus.assigned).length;
  int get completedTodayCount =>
      bookings.where((b) => b.status == BookingStatus.completed).length;
  int get cancelledCount =>
      bookings.where((b) => b.status == BookingStatus.cancelled).length;

  MerchantBookingsState copyWith({
    List<MerchantDeliveryBooking>? bookings,
    String? selectedBranchFilter,
    String? selectedStatusFilter,
    String? searchQuery,
    MerchantDeliveryBooking? selectedBooking,
    bool clearSelectedBooking = false,
    bool? isLoading,
    String? actionMessage,
    String? errorMessage,
    bool clearActionMessage = false,
    bool clearErrorMessage = false,
  }) {
    return MerchantBookingsState(
      bookings: bookings ?? this.bookings,
      selectedBranchFilter: selectedBranchFilter ?? this.selectedBranchFilter,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBooking: clearSelectedBooking ? null : (selectedBooking ?? this.selectedBooking),
      isLoading: isLoading ?? this.isLoading,
      actionMessage: clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        bookings,
        selectedBranchFilter,
        selectedStatusFilter,
        searchQuery,
        selectedBooking,
        isLoading,
        actionMessage,
        errorMessage,
      ];
}

class MerchantBookingsNotifier extends StateNotifier<MerchantBookingsState> {
  MerchantBookingsNotifier() : super(const MerchantBookingsState()) {
    _loadInitialBookings();
  }

  void _loadInitialBookings() {
    state = state.copyWith(
      bookings: [
        MerchantDeliveryBooking(
          id: 'dlv_001',
          trackingReference: 'GV-MC-2026-001',
          branchId: 'br_lekki_01',
          branchName: 'Lekki Phase 1 Flagship',
          recipientName: 'Dr. Folashade Adeyemi',
          recipientPhone: '+2348039988771',
          deliveryAddress: 'Plot 12, Admiralty Way, Lekki',
          deliveryZone: 'Lekki / Victoria Island',
          packageCategory: 'Food & Hot Meal',
          weightKg: 2.5,
          specialInstructions: 'Handle with care; keep thermal bag zipped',
          grossFareKobo: 250000, // ₦2,500.00
          status: BookingStatus.inProgress,
          assignedRiderName: 'Babajide Ogundipe',
          assignedRiderPhone: '+2348031122334',
          assignedRiderPlate: 'LAG-428-EV',
          assignedRiderBattery: 89,
          recipientOtp: '4819',
          createdAt: DateTime(2026, 10, 26, 11, 30),
          timeline: const [
            DeliveryTimelineEvent(
              status: 'QUOTED',
              timestamp: '11:25:10',
              note: 'Upfront quote locked at ₦2,500 via Corporate Wallet',
            ),
            DeliveryTimelineEvent(
              status: 'RIDER_ASSIGNED',
              timestamp: '11:27:45',
              note: 'Assigned to Babajide Ogundipe (LAG-428-EV · 89% battery)',
            ),
            DeliveryTimelineEvent(
              status: 'PICKED_UP',
              timestamp: '11:35:20',
              note: 'Food collected from Lekki Flagship kitchen',
            ),
          ],
        ),
        MerchantDeliveryBooking(
          id: 'dlv_002',
          trackingReference: 'GV-MC-2026-002',
          branchId: 'br_vi_02',
          branchName: 'Victoria Island Central Hub',
          recipientName: 'Tunde Alabi & Partners',
          recipientPhone: '+2348021122338',
          deliveryAddress: 'Ahmadu Bello Way, Victoria Island',
          deliveryZone: 'Lagos Island',
          packageCategory: 'Documents & Contract',
          weightKg: 0.8,
          isFragile: true,
          specialInstructions: 'Legal docs; require recipient signature',
          grossFareKobo: 180000, // ₦1,800.00
          status: BookingStatus.searchingRider,
          recipientOtp: '7294',
          createdAt: DateTime(2026, 10, 26, 12, 10),
          timeline: const [
            DeliveryTimelineEvent(
              status: 'READY_FOR_DISPATCH',
              timestamp: '12:10:00',
              note: 'Order prepared and packaged at VI Kitchen',
            ),
          ],
        ),
        MerchantDeliveryBooking(
          id: 'dlv_003',
          trackingReference: 'GV-MC-2026-003',
          branchId: 'br_ikeja_03',
          branchName: 'Ikeja City Mall Outlet',
          recipientName: 'Mrs. Chioma Eze',
          recipientPhone: '+2348057766554',
          deliveryAddress: 'Mobolaji Bank Anthony Way, Ikeja',
          deliveryZone: 'Ikeja / Mainland',
          packageCategory: 'Food & Bakery',
          weightKg: 3.2,
          grossFareKobo: 320000, // ₦3,200.00
          status: BookingStatus.completed,
          assignedRiderName: 'Musa Garba',
          assignedRiderPhone: '+2348092233445',
          assignedRiderPlate: 'LAG-771-EV',
          assignedRiderBattery: 78,
          recipientOtp: '9183',
          proofOfDeliveryUrl: 'https://cdn.govolts.ng/pod/mc_003_signature.png',
          createdAt: DateTime(2026, 10, 26, 9, 15),
          timeline: const [
            DeliveryTimelineEvent(
              status: 'PICKED_UP',
              timestamp: '09:25:00',
              note: 'Package collected at Ikeja City Mall pickup dock',
            ),
            DeliveryTimelineEvent(
              status: 'COMPLETED',
              timestamp: '09:52:14',
              note: 'Delivered to recipient. Verified OTP: 9183 + Digital Signature',
            ),
          ],
        ),
      ],
    );
  }

  void setBranchFilter(String branchId) {
    state = state.copyWith(selectedBranchFilter: branchId);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatusFilter: status);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectBooking(MerchantDeliveryBooking? booking) {
    state = state.copyWith(
      selectedBooking: booking,
      clearSelectedBooking: booking == null,
    );
  }

  void clearSelection() => selectBooking(null);

  /// Create and dispatch a new delivery booking
  Future<MerchantDeliveryBooking> createDeliveryBooking({
    required String branchId,
    required String branchName,
    required String recipientName,
    required String recipientPhone,
    required String deliveryAddress,
    required String deliveryZone,
    required String packageCategory,
    required double weightKg,
    bool isFragile = false,
    String specialInstructions = '',
    required int grossFareKobo,
  }) async {
    state = state.copyWith(isLoading: true, clearActionMessage: true, clearErrorMessage: true);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final count = state.bookings.length + 1;
    final refCode = 'GV-MC-2026-${count.toString().padLeft(3, '0')}';
    final otp = '${(1000 + (count * 137) % 9000)}';

    final newBooking = MerchantDeliveryBooking(
      id: 'dlv_${count.toString().padLeft(3, '0')}',
      trackingReference: refCode,
      branchId: branchId,
      branchName: branchName,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      deliveryAddress: deliveryAddress,
      deliveryZone: deliveryZone,
      packageCategory: packageCategory,
      weightKg: weightKg,
      isFragile: isFragile,
      specialInstructions: specialInstructions,
      grossFareKobo: grossFareKobo,
      status: BookingStatus.searchingRider,
      recipientOtp: otp,
      createdAt: DateTime.now(),
      timeline: const [
        DeliveryTimelineEvent(
          status: 'CREATED',
          timestamp: 'Just now',
          note: 'Delivery order created via Merchant Portal. Dispatch searching nearby electric moped.',
        ),
      ],
    );

    state = state.copyWith(
      isLoading: false,
      bookings: [newBooking, ...state.bookings],
      actionMessage: 'Delivery $refCode for $recipientName successfully dispatched! Recipient OTP: $otp',
    );

    return newBooking;
  }

  /// Cancel an eligible delivery booking
  Future<bool> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    final target = state.bookings.firstWhere((b) => b.id == bookingId, orElse: () => throw Exception('Not found'));
    if (!target.canBeCancelled) {
      state = state.copyWith(
        errorMessage: 'Cannot cancel delivery $bookingId: Order is already in-transit or completed.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearActionMessage: true, clearErrorMessage: true);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final updated = state.bookings.map((b) {
      if (b.id == bookingId) {
        final newTimeline = List<DeliveryTimelineEvent>.from(b.timeline)
          ..add(
            DeliveryTimelineEvent(
              status: 'CANCELLED',
              timestamp: 'Just now',
              note: 'Merchant cancelled delivery. Reason: $reason. Corporate wallet refunded.',
            ),
          );
        return b.copyWith(
          status: BookingStatus.cancelled,
          timeline: newTimeline,
        );
      }
      return b;
    }).toList();

    state = state.copyWith(
      isLoading: false,
      bookings: updated,
      actionMessage: 'Booking ${target.trackingReference} successfully cancelled and refunded.',
    );
    return true;
  }

  /// Bulk batch dispatch upload
  Future<int> batchCreateDeliveries(List<MerchantDeliveryBooking> items) async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    state = state.copyWith(
      isLoading: false,
      bookings: [...items, ...state.bookings],
      actionMessage: 'Successfully ingested ${items.length} bulk delivery orders into dispatch queue!',
    );
    return items.length;
  }
}

final merchantBookingsNotifierProvider =
    StateNotifierProvider<MerchantBookingsNotifier, MerchantBookingsState>((ref) {
  return MerchantBookingsNotifier();
});
