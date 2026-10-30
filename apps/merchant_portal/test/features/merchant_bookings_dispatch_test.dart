import 'package:app_models/app_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_portal/src/features/bookings/application/merchant_bookings_notifier.dart';
import 'package:merchant_portal/src/features/bookings/domain/merchant_delivery_model.dart';

void main() {
  group('Phase 4: Merchant Bookings & Dispatch Engine', () {
    test('initializes with seed bookings and correct KPI counts', () {
      final notifier = MerchantBookingsNotifier();

      expect(notifier.state.bookings, isNotEmpty);
      expect(notifier.state.totalDeliveriesCount, notifier.state.bookings.length);
      expect(notifier.state.activeDispatchCount, greaterThanOrEqualTo(1));
      expect(notifier.state.completedTodayCount, greaterThanOrEqualTo(1));
    });

    test('filters bookings by branch correctly', () {
      final notifier = MerchantBookingsNotifier();

      notifier.setBranchFilter('br_lekki_01');
      final filtered = notifier.state.filteredBookings;
      expect(filtered.every((b) => b.branchId == 'br_lekki_01'), isTrue);

      // Reset to ALL
      notifier.setBranchFilter('ALL');
      expect(notifier.state.filteredBookings.length, notifier.state.bookings.length);
    });

    test('filters bookings by status correctly', () {
      final notifier = MerchantBookingsNotifier();

      notifier.setStatusFilter('in_progress');
      final filtered = notifier.state.filteredBookings;
      expect(filtered.every((b) => b.status == BookingStatus.inProgress), isTrue);

      notifier.setStatusFilter('ALL');
      expect(notifier.state.filteredBookings.length, notifier.state.bookings.length);
    });

    test('searches bookings by query (recipient, reference, driver)', () {
      final notifier = MerchantBookingsNotifier();

      notifier.setSearchQuery('GV-MC');
      expect(notifier.state.filteredBookings, isNotEmpty);
      expect(
        notifier.state.filteredBookings.every((b) => b.trackingReference.contains('GV-MC')),
        isTrue,
      );

      notifier.setSearchQuery('NonExistentRecipient123');
      expect(notifier.state.filteredBookings, isEmpty);
    });

    test('creates and dispatches a single delivery booking with locked quote & OTP', () async {
      final notifier = MerchantBookingsNotifier();
      final initialCount = notifier.state.bookings.length;

      final booking = await notifier.createDeliveryBooking(
        branchId: 'br_lekki_01',
        branchName: 'Lekki Phase 1 Flagship',
        recipientName: 'Adeola Johnson',
        recipientPhone: '+2348021234567',
        deliveryAddress: '15 Admiralty Way, Lekki Phase 1',
        deliveryZone: 'Lekki / Victoria Island',
        packageCategory: 'Hot Meals & Groceries',
        weightKg: 2.5,
        isFragile: false,
        specialInstructions: 'Ring doorbell',
        grossFareKobo: 285000,
      );

      expect(notifier.state.bookings.length, initialCount + 1);
      expect(booking.recipientName, 'Adeola Johnson');
      expect(booking.recipientOtp.length, 4);
      expect(booking.grossFareKobo, 285000);
      expect(booking.status, BookingStatus.searchingRider);
      expect(booking.canBeCancelled, isTrue);
      expect(booking.timeline, isNotEmpty);
      expect(notifier.state.actionMessage, contains('Adeola Johnson'));
    });

    test('drawer selection and cancellation flow', () async {
      final notifier = MerchantBookingsNotifier();

      // Create a cancellable booking
      final booking = await notifier.createDeliveryBooking(
        branchId: 'br_vi_02',
        branchName: 'Victoria Island Hub',
        recipientName: 'Tunde Bakare',
        recipientPhone: '+2348039876543',
        deliveryAddress: 'Ahmadu Bello Way, VI',
        deliveryZone: 'Lekki / Victoria Island',
        packageCategory: 'Parcels',
        weightKg: 1.0,
        grossFareKobo: 210000,
      );

      // Select booking
      notifier.selectBooking(booking);
      expect(notifier.state.selectedBooking, isNotNull);
      expect(notifier.state.selectedBooking!.id, booking.id);

      // Clear selection
      notifier.clearSelection();
      expect(notifier.state.selectedBooking, isNull);

      // Cancel booking
      final success = await notifier.cancelBooking(
        bookingId: booking.id,
        reason: 'Customer updated delivery address',
      );

      expect(success, isTrue);
      final cancelled = notifier.state.bookings.firstWhere((b) => b.id == booking.id);
      expect(cancelled.status, BookingStatus.cancelled);
      expect(cancelled.canBeCancelled, isFalse);
      expect(
        cancelled.timeline.any((t) => t.status == 'CANCELLED'),
        isTrue,
      );
    });

    test('bulk CSV ingestion batch creates deliveries', () async {
      final notifier = MerchantBookingsNotifier();
      final initialCount = notifier.state.bookings.length;

      final batch = [
        MerchantDeliveryBooking(
          id: 'dlv_batch_01',
          trackingReference: 'GV-BATCH-001',
          branchId: 'br_ikeja_03',
          branchName: 'Ikeja City Mall',
          recipientName: 'Femi Otedola',
          recipientPhone: '+2348051112233',
          deliveryAddress: '10 Mobolaji Bank Anthony Way, Ikeja',
          deliveryZone: 'Ikeja / Mainland',
          packageCategory: 'Documents',
          weightKg: 0.5,
          grossFareKobo: 250000,
          status: BookingStatus.searchingRider,
          recipientOtp: '5561',
          createdAt: DateTime.now(),
          timeline: const [
            DeliveryTimelineEvent(
              status: 'BATCH_INGESTED',
              timestamp: 'Just now',
              note: 'CSV Batch Ingestion',
            ),
          ],
        ),
        MerchantDeliveryBooking(
          id: 'dlv_batch_02',
          trackingReference: 'GV-BATCH-002',
          branchId: 'br_ikeja_03',
          branchName: 'Ikeja City Mall',
          recipientName: 'Bisola Aiyeola',
          recipientPhone: '+2348052223344',
          deliveryAddress: 'Alausa Secretariat, Ikeja',
          deliveryZone: 'Ikeja / Mainland',
          packageCategory: 'Fashion & Apparel',
          weightKg: 1.2,
          grossFareKobo: 270000,
          status: BookingStatus.searchingRider,
          recipientOtp: '9082',
          createdAt: DateTime.now(),
          timeline: const [
            DeliveryTimelineEvent(
              status: 'BATCH_INGESTED',
              timestamp: 'Just now',
              note: 'CSV Batch Ingestion',
            ),
          ],
        ),
      ];

      final ingestedCount = await notifier.batchCreateDeliveries(batch);
      expect(ingestedCount, 2);
      expect(notifier.state.bookings.length, initialCount + 2);
      expect(notifier.state.actionMessage, contains('2'));
    });
  });
}
