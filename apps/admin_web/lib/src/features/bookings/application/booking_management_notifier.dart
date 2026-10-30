import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/booking_management_state.dart';

final bookingManagementNotifierProvider =
    StateNotifierProvider<BookingManagementNotifier, BookingManagementState>((ref) {
  return BookingManagementNotifier();
});

class BookingManagementNotifier extends StateNotifier<BookingManagementState> {
  BookingManagementNotifier() : super(const BookingManagementState()) {
    _loadInitialBookings();
  }

  void _loadInitialBookings() {
    state = state.copyWith(
      bookings: [
        const AdminBookingItem(
          id: 'BK-001',
          reference: 'GV-BK-2026-001',
          source: 'Customer Mobile App',
          customerName: 'Chidinma Okafor',
          customerPhone: '+2348039988776',
          riderName: 'Babajide Ogundipe',
          riderPhone: '+2348031122334',
          riderPlate: 'LAG-428-EV',
          serviceType: ServiceTierEligibility.parcelDelivery,
          status: BookingStatus.inProgress,
          pickupAddress: 'Plot 14 Admiralty Way, Lekki',
          dropoffAddress: 'Ahmadu Bello Way, Victoria Island',
          grossFareKobo: 300000,
          platformCommissionKobo: 60000,
          createdAt: '2026-10-24 14:15',
          timeline: [
            AdminBookingTimelineEvent(
              status: 'QUOTED',
              timestamp: '14:10:02',
              note: 'Upfront quote locked at ₦3,000 (1.0x baseline)',
            ),
            AdminBookingTimelineEvent(
              status: 'RIDER_ASSIGNED',
              timestamp: '14:11:45',
              note: 'Assigned to Babajide Ogundipe (LAG-428-EV)',
            ),
            AdminBookingTimelineEvent(
              status: 'PICKED_UP',
              timestamp: '14:22:10',
              note: 'Package collected with sender digital signature',
            ),
          ],
        ),
        const AdminBookingItem(
          id: 'BK-002',
          reference: 'GV-BK-2026-002',
          source: 'Retail Ai Partner',
          customerName: 'Mrs. Folake Adeleke',
          customerPhone: '+2348021122334',
          riderName: 'Tunde Adeleke',
          riderPhone: '+2348029988776',
          riderPlate: 'LAG-992-ET',
          serviceType: ServiceTierEligibility.schoolRunCommute,
          status: BookingStatus.assigned,
          pickupAddress: 'Corona School, VI',
          dropoffAddress: 'Parkview Estate, Ikoyi',
          grossFareKobo: 400000,
          platformCommissionKobo: 80000,
          createdAt: '2026-10-24 14:00',
          timeline: [
            AdminBookingTimelineEvent(
              status: 'QUOTED',
              timestamp: '13:58:00',
              note: 'Plan subscription quote verified',
            ),
            AdminBookingTimelineEvent(
              status: 'RIDER_ASSIGNED',
              timestamp: '14:02:15',
              note: 'Dedicated chaperone Tunde Adeleke confirmed',
            ),
          ],
        ),
        const AdminBookingItem(
          id: 'BK-003',
          reference: 'GV-BK-2026-003',
          source: 'Merchant Portal',
          customerName: 'Ereke E-Commerce Store',
          customerPhone: '+2348099988877',
          serviceType: ServiceTierEligibility.parcelDelivery,
          status: BookingStatus.searchingRider,
          pickupAddress: '18 Allen Avenue, Ikeja',
          dropoffAddress: 'Gbagada Expressway, Lagos',
          grossFareKobo: 350000,
          platformCommissionKobo: 70000,
          createdAt: '2026-10-24 14:28',
          timeline: [
            AdminBookingTimelineEvent(
              status: 'QUOTED',
              timestamp: '14:28:10',
              note: 'Merchant API bulk dispatch created',
            ),
            AdminBookingTimelineEvent(
              status: 'DISPATCHING',
              timestamp: '14:28:15',
              note: 'Searching for nearby EV trikes',
            ),
          ],
        ),
        const AdminBookingItem(
          id: 'BK-004',
          reference: 'GV-BK-2026-004',
          source: 'Customer Mobile App',
          customerName: 'Dr. Kehinde Balogun',
          customerPhone: '+2348055544433',
          riderName: 'Emeka Nwosu',
          riderPhone: '+2348038877665',
          riderPlate: 'LAG-889-ET',
          serviceType: ServiceTierEligibility.passengerRide,
          status: BookingStatus.completed,
          pickupAddress: 'Ozumba Mbadiwe Ave, VI',
          dropoffAddress: 'Broad Street, Lagos Island',
          grossFareKobo: 280000,
          platformCommissionKobo: 56000,
          createdAt: '2026-10-24 12:30',
          timeline: [
            AdminBookingTimelineEvent(
              status: 'COMPLETED',
              timestamp: '13:05:00',
              note: 'Trip ended. Fare settled to wallet ledger.',
            ),
          ],
        ),
      ],
    );
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
