import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';
import '../domain/activity_item.dart';
import '../domain/activity_state.dart';

final activityNotifierProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final isNewUser = authState.status == AuthStatus.authenticated &&
      authState.profile != null &&
      authState.profile!.ecoPointsBalance == 0 &&
      authState.profile!.carbonAvoidedKg == 0.0;

  return ActivityNotifier(initialItems: isNewUser ? const [] : null);
});

class ActivityNotifier extends StateNotifier<ActivityState> {
  ActivityNotifier({List<ActivityItem>? initialItems})
      : super(
          ActivityState(
            items: initialItems ?? _generateInitialActivities(),
            selectedStatus: ActivityStatus.upcoming,
          ),
        );

  void setStatusFilter(ActivityStatus status) {
    state = state.copyWith(selectedStatus: status);
  }

  void setServiceFilter(ActivityServiceType? service) {
    if (service == null) {
      state = state.copyWith(clearServiceFilter: true);
    } else {
      state = state.copyWith(selectedService: service);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void refresh() {
    state = state.copyWith(isLoading: true);
    Future.delayed(const Duration(milliseconds: 300), () {
      state = state.copyWith(isLoading: false);
    });
  }

  static List<ActivityItem> _generateInitialActivities() {
    final now = DateTime.now();

    return [
      // 1. ACTIVE: Ride
      ActivityItem(
        id: 'act-act-001',
        reference: 'GV-TRP-20261031-01',
        serviceType: ActivityServiceType.ride,
        status: ActivityStatus.active,
        title: 'GoRide Standard: Babcock University',
        pickupAddress: 'Central Roundabout, Shaganu, Ogun',
        dropoffAddress: 'Babcock University, Ilishan-Remo, Ogun',
        timestamp: now.subtract(const Duration(minutes: 8)),
        fareKobo: 250000,
        driverName: 'Ahmed Ibrahim',
        driverRating: 4.8,
        driverTripsCount: 320,
        vehicleModel: 'Toyota Corolla - OGN-123XY',
        vehiclePlate: 'OGN-123XY',
      ),

      // 2. ACTIVE: Parcel Delivery
      ActivityItem(
        id: 'act-act-002',
        reference: 'GV-DEL-20261031-44',
        serviceType: ActivityServiceType.delivery,
        status: ActivityStatus.active,
        title: 'Parcel Delivery: Confidential Documents',
        pickupAddress: 'Remo High Street, Shaganu, Ogun',
        dropoffAddress: 'Shaganu Community Market, Ogun',
        timestamp: now.subtract(const Duration(minutes: 20)),
        fareKobo: 120000,
        driverName: 'Musa Bello',
        driverRating: 4.7,
        driverTripsCount: 198,
        vehicleModel: 'Go-Volts Electric Bike - OGN-456YZ',
        vehiclePlate: 'OGN-456YZ',
        recipientName: 'Fatima Abdullahi',
        recipientPhone: '+234 803 123 4567',
      ),

      // 3. UPCOMING: School Run Scheduled Plan
      ActivityItem(
        id: 'act-up-001',
        reference: 'SP-20261105-001',
        serviceType: ActivityServiceType.scheduled,
        status: ActivityStatus.upcoming,
        title: 'School Run: Remo International School',
        pickupAddress: 'Central Roundabout, Shaganu, Ogun',
        dropoffAddress: 'Remo International School, Ilishan-Remo, Ogun',
        timestamp: now.add(const Duration(days: 1, hours: 2)),
        fareKobo: 250000,
        driverName: 'Ahmed Ibrahim',
        driverRating: 4.8,
        driverTripsCount: 320,
        vehicleModel: 'Toyota Corolla - OGN-123XY',
        schoolPassengerName: 'Fatima Okafor (JSS 1)',
      ),

      // 4. UPCOMING: Work Commute Scheduled Plan
      ActivityItem(
        id: 'act-up-002',
        reference: 'SP-20261105-002',
        serviceType: ActivityServiceType.scheduled,
        status: ActivityStatus.upcoming,
        title: 'Work Commute: Shaganu Energy Hub',
        pickupAddress: 'Remo High Street, Shaganu, Ogun',
        dropoffAddress: 'Shaganu Energy Hub, Ogun',
        timestamp: now.add(const Duration(days: 2, hours: 1)),
        fareKobo: 300000,
        driverName: 'Grace Johnson',
        driverRating: 4.9,
        driverTripsCount: 450,
        vehicleModel: 'Nissan Leaf Electric - OGN-901EF',
      ),

      // 5. UPCOMING: Scheduled Parcel Dispatch
      ActivityItem(
        id: 'act-up-003',
        reference: 'GV-DEL-20261101-12',
        serviceType: ActivityServiceType.delivery,
        status: ActivityStatus.upcoming,
        title: 'Scheduled Delivery: Medical Supplies',
        pickupAddress: 'Remo Specialist Hospital, Ogun',
        dropoffAddress: 'Shaganu General Hospital, Ogun',
        timestamp: now.add(const Duration(days: 1, hours: 5)),
        fareKobo: 280000,
        recipientName: 'Dr. Aliyu Shehu',
        recipientPhone: '+234 802 998 7766',
      ),

      // 6. COMPLETED: Ride
      ActivityItem(
        id: 'act-comp-001',
        reference: 'GV-TRP-20261029-88',
        serviceType: ActivityServiceType.ride,
        status: ActivityStatus.completed,
        title: 'GoRide Plus to Remo High Street',
        pickupAddress: 'Central Roundabout, Shaganu, Ogun',
        dropoffAddress: 'Remo High Street, Shaganu, Ogun',
        timestamp: now.subtract(const Duration(days: 2, hours: 3)),
        fareKobo: 350000,
        driverName: 'Grace Johnson',
        driverRating: 4.9,
        driverTripsCount: 450,
        vehicleModel: 'Nissan Leaf Electric',
        vehiclePlate: 'OGN-901EF',
        receipt: TripReceiptDto(
          receiptReference: 'RCP-20261029-88',
          bookingId: 'GV-TRP-20261029-88',
          serviceType: 'GoRide Plus',
          driverName: 'Grace Johnson',
          driverRating: 4.9,
          driverTripsCount: 450,
          vehicleModel: 'Nissan Leaf Electric',
          vehiclePlate: 'OGN-901EF',
          pickupAddress: 'Central Roundabout, Shaganu, Ogun',
          pickupTime: now.subtract(const Duration(days: 2, hours: 3, minutes: 22)),
          dropoffAddress: 'Remo High Street, Shaganu, Ogun',
          dropoffTime: now.subtract(const Duration(days: 2, hours: 3)),
          distanceKm: 8.4,
          durationMinutes: 22,
          priceBreakdown: const PriceBreakdownDto(
            baseAmountKobo: 200000,
            distanceAmountKobo: 120000,
            timeAmountKobo: 0,
            serviceFeeKobo: 30000,
            totalAmountKobo: 350000,
          ),
          totalPaidKobo: 350000,
          paymentMethod: PaymentMethod.wallet,
          paymentReference: 'PAY-WALLET-8819',
          carbonSavedGrams: 1450,
        ),
      ),

      // 7. COMPLETED: Parcel Delivery
      ActivityItem(
        id: 'act-comp-002',
        reference: 'GV-DEL-20261028-19',
        serviceType: ActivityServiceType.delivery,
        status: ActivityStatus.completed,
        title: 'Parcel Delivery: Electronics & Accessories',
        pickupAddress: 'Remo Tech Hub, Shaganu, Ogun',
        dropoffAddress: 'GRA Phase 1, Shaganu, Ogun',
        timestamp: now.subtract(const Duration(days: 3, hours: 4)),
        fareKobo: 220000,
        driverName: 'Musa Bello',
        driverRating: 4.7,
        driverTripsCount: 198,
        vehicleModel: 'Go-Volts Electric Bike',
        vehiclePlate: 'OGN-456YZ',
        recipientName: 'Kalu Chukwu',
        receipt: TripReceiptDto(
          receiptReference: 'RCP-20261028-19',
          bookingId: 'GV-DEL-20261028-19',
          serviceType: 'Go-Volts Send Express',
          driverName: 'Musa Bello',
          driverRating: 4.7,
          driverTripsCount: 198,
          vehicleModel: 'Go-Volts Electric Bike',
          vehiclePlate: 'OGN-456YZ',
          pickupAddress: 'Remo Tech Hub, Shaganu, Ogun',
          pickupTime: now.subtract(const Duration(days: 3, hours: 4, minutes: 18)),
          dropoffAddress: 'GRA Phase 1, Shaganu, Ogun',
          dropoffTime: now.subtract(const Duration(days: 3, hours: 4)),
          distanceKm: 5.2,
          durationMinutes: 18,
          priceBreakdown: const PriceBreakdownDto(
            baseAmountKobo: 150000,
            distanceAmountKobo: 50000,
            timeAmountKobo: 0,
            serviceFeeKobo: 20000,
            totalAmountKobo: 220000,
          ),
          totalPaidKobo: 220000,
          paymentMethod: PaymentMethod.wallet,
          paymentReference: 'PAY-WALLET-7712',
          carbonSavedGrams: 890,
        ),
      ),

      // 8. COMPLETED: Scheduled Trip
      ActivityItem(
        id: 'act-comp-003',
        reference: 'SP-20261027-005',
        serviceType: ActivityServiceType.scheduled,
        status: ActivityStatus.completed,
        title: 'School Run: Remo International School',
        pickupAddress: 'Central Roundabout, Shaganu, Ogun',
        dropoffAddress: 'Remo International School, Ilishan-Remo, Ogun',
        timestamp: now.subtract(const Duration(days: 4, hours: 8)),
        fareKobo: 250000,
        driverName: 'Ahmed Ibrahim',
        driverRating: 4.8,
        driverTripsCount: 320,
        vehicleModel: 'Toyota Corolla - OGN-123XY',
        schoolPassengerName: 'Fatima Okafor (JSS 1)',
        receipt: TripReceiptDto(
          receiptReference: 'RCP-20261027-005',
          bookingId: 'SP-20261027-005',
          serviceType: 'School Run Package',
          driverName: 'Ahmed Ibrahim',
          driverRating: 4.8,
          driverTripsCount: 320,
          vehicleModel: 'Toyota Corolla',
          vehiclePlate: 'OGN-123XY',
          pickupAddress: 'Central Roundabout, Shaganu, Ogun',
          pickupTime: now.subtract(const Duration(days: 4, hours: 8, minutes: 25)),
          dropoffAddress: 'Remo International School, Ilishan-Remo, Ogun',
          dropoffTime: now.subtract(const Duration(days: 4, hours: 8)),
          distanceKm: 7.1,
          durationMinutes: 25,
          priceBreakdown: const PriceBreakdownDto(
            baseAmountKobo: 200000,
            distanceAmountKobo: 40000,
            timeAmountKobo: 0,
            serviceFeeKobo: 10000,
            totalAmountKobo: 250000,
          ),
          totalPaidKobo: 250000,
          paymentMethod: PaymentMethod.wallet,
          paymentReference: 'PAY-SCHED-5521',
          carbonSavedGrams: 1100,
        ),
      ),

      // 9. CANCELLED: Ride
      ActivityItem(
        id: 'act-canc-001',
        reference: 'GV-TRP-20261024-91',
        serviceType: ActivityServiceType.ride,
        status: ActivityStatus.cancelled,
        title: 'GoRide Comfort: Ogun Cargo Airport Commute',
        pickupAddress: 'Remo High Street, Shaganu, Ogun',
        dropoffAddress: 'Gateway International Airport, Ogun',
        timestamp: now.subtract(const Duration(days: 7)),
        fareKobo: 650000,
        cancellationReason:
            'Flight rescheduled by airline. Cancelled by rider before dispatch.',
        refundStatus: 'Full refund ₦6,500 automatically credited to Go-Volts Wallet',
      ),

      // 10. CANCELLED: Parcel Delivery
      ActivityItem(
        id: 'act-canc-002',
        reference: 'GV-DEL-20261022-30',
        serviceType: ActivityServiceType.delivery,
        status: ActivityStatus.cancelled,
        title: 'Parcel Delivery: Bulk Box Goods',
        pickupAddress: 'Shaganu Central Market, Ogun',
        dropoffAddress: 'Iperu Modern Market, Ogun',
        timestamp: now.subtract(const Duration(days: 9)),
        fareKobo: 200000,
        cancellationReason:
            'Sender unavailable at pickup point after driver arrival grace period.',
        refundStatus: 'Partial refund ₦1,500 credited to Wallet (₦500 rider dispatch fee retained)',
      ),
    ];
  }
}
