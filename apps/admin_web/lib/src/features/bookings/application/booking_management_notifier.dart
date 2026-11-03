import 'package:app_models/app_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/supabase_admin_client.dart';
import '../domain/booking_management_state.dart';

final bookingManagementNotifierProvider =
    StateNotifierProvider<BookingManagementNotifier, BookingManagementState>((ref) {
  return BookingManagementNotifier();
});

class BookingManagementNotifier extends StateNotifier<BookingManagementState> {
  BookingManagementNotifier() : super(const BookingManagementState()) {
    fetchRealBookings();
  }

  Future<void> fetchRealBookings() async {
    final client = tryGetSupabaseClient();
    if (client == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final res = await client.from('bookings').select();
      final list = res as List<dynamic>;

      final mapped = list.map((b) {
        final status = BookingStatus.fromString(b['status']?.toString() ?? '');

        return AdminBookingItem(
          id: b['id']?.toString() ?? '',
          reference: b['reference']?.toString() ?? b['id']?.toString() ?? '',
          source: b['source']?.toString() ?? 'Go-Volts Mobile App',
          customerName: b['customer_name']?.toString() ?? 'Customer',
          customerPhone: b['customer_phone']?.toString() ?? '',
          riderName: b['rider_name']?.toString(),
          riderPhone: b['rider_phone']?.toString(),
          riderPlate: b['rider_plate']?.toString(),
          serviceType: ServiceTierEligibility.passengerRide,
          status: status,
          pickupAddress: b['pickup_address']?.toString() ?? 'Lagos',
          dropoffAddress: b['dropoff_address']?.toString() ?? 'Lagos',
          grossFareKobo: (b['fare_kobo'] as num?)?.toInt() ?? 0,
          platformCommissionKobo: (b['commission_kobo'] as num?)?.toInt() ?? 0,
          createdAt: b['created_at']?.toString() ?? '',
          timeline: const [],
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        bookings: mapped,
      );
    } catch (e) {
      debugPrint('[BookingManagementNotifier] Error fetching bookings: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  @visibleForTesting
  void updateStateForTesting(BookingManagementState newState) {
    state = newState;
  }


  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatusFilter: status);
  }

  void setServiceFilter(String service) {
    state = state.copyWith(selectedServiceFilter: service);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectBooking(AdminBookingItem? booking) {
    state = state.copyWith(selectedBooking: booking);
  }

  /// Manually reassign a booking to another driver with an audit note.
  Future<bool> reassignBooking({
    required String bookingId,
    required String newRiderName,
    required String newRiderPlate,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) return false;

    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final updated = state.bookings.map((b) {
      if (b.id == bookingId) {
        final newTimeline = List<AdminBookingTimelineEvent>.from(b.timeline)
          ..add(
            AdminBookingTimelineEvent(
              status: 'REASSIGNED',
              timestamp: 'Just now',
              note: 'Admin reassigned to $newRiderName ($newRiderPlate). Reason: $reason',
            ),
          );

        return AdminBookingItem(
          id: b.id,
          reference: b.reference,
          source: b.source,
          customerName: b.customerName,
          customerPhone: b.customerPhone,
          riderName: newRiderName,
          riderPhone: '+2348000000000',
          riderPlate: newRiderPlate,
          serviceType: b.serviceType,
          status: BookingStatus.assigned,
          pickupAddress: b.pickupAddress,
          dropoffAddress: b.dropoffAddress,
          grossFareKobo: b.grossFareKobo,
          platformCommissionKobo: b.platformCommissionKobo,
          createdAt: b.createdAt,
          timeline: newTimeline,
        );
      }
      return b;
    }).toList();

    state = state.copyWith(
      isLoading: false,
      bookings: updated,
      actionMessage: 'Booking $bookingId reassigned to $newRiderName (Reason: $reason)',
    );
    return true;
  }

  /// Cancel an existing booking with a mandatory audit reason.
  Future<bool> cancelBooking({
    required String bookingId,
    required String reason,
    required bool refundCustomer,
  }) async {
    if (reason.trim().isEmpty) return false;

    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final updated = state.bookings.map((b) {
      if (b.id == bookingId) {
        final newTimeline = List<AdminBookingTimelineEvent>.from(b.timeline)
          ..add(
            AdminBookingTimelineEvent(
              status: 'CANCELLED',
              timestamp: 'Just now',
              note: 'Cancelled by Operations Admin. Reason: $reason${refundCustomer ? " (Refund Processed)" : ""}',
            ),
          );

        return AdminBookingItem(
          id: b.id,
          reference: b.reference,
          source: b.source,
          customerName: b.customerName,
          customerPhone: b.customerPhone,
          riderName: b.riderName,
          riderPhone: b.riderPhone,
          riderPlate: b.riderPlate,
          serviceType: b.serviceType,
          status: BookingStatus.cancelled,
          pickupAddress: b.pickupAddress,
          dropoffAddress: b.dropoffAddress,
          grossFareKobo: b.grossFareKobo,
          platformCommissionKobo: b.platformCommissionKobo,
          createdAt: b.createdAt,
          timeline: newTimeline,
        );
      }
      return b;
    }).toList();

    state = state.copyWith(
      isLoading: false,
      bookings: updated,
      actionMessage: 'Booking $bookingId cancelled. Reason: $reason',
    );
    return true;
  }
}
