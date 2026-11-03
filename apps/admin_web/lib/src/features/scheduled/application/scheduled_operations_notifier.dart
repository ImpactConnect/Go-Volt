import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/scheduled_operations_models.dart';

class ScheduledOperationsState {
  const ScheduledOperationsState({
    this.trips = const [],
    this.safekeepingRoster = const [],
    this.calendarExceptions = const [],
    this.selectedManifestTime = 'ALL', // 'ALL', 'MORNING', 'AFTERNOON'
    this.selectedTab = 'MANIFESTS', // 'MANIFESTS', 'SAFEKEEPING', 'EXCEPTIONS'
    this.searchQuery = '',
    this.actionMessage,
    this.isLoading = false,
  });

  final List<ScheduledTripDto> trips;
  final List<GuardianSafekeepingModel> safekeepingRoster;
  final List<SchoolCalendarExceptionModel> calendarExceptions;
  final String selectedManifestTime;
  final String selectedTab;
  final String searchQuery;
  final String? actionMessage;
  final bool isLoading;

  int get todayManifestCount => trips.length;

  int get activeSchoolRunsCount => trips
      .where((t) =>
          t.status == ScheduledTripStatus.driverAssigned ||
          t.status == ScheduledTripStatus.driverApproaching ||
          t.status == ScheduledTripStatus.arrivedAtPickup ||
          t.status == ScheduledTripStatus.pickupConfirmed ||
          t.status == ScheduledTripStatus.inProgress ||
          t.status == ScheduledTripStatus.handoverPending)
      .length;

  int get pendingHandoverCount => safekeepingRoster
      .where((s) => !s.isVerified)
      .length;

  int get activeExceptionsCount =>
      calendarExceptions.where((e) => e.isActive).length;

  List<ScheduledTripDto> get filteredTrips {
    return trips.where((t) {
      // Time Manifest Filter
      if (selectedManifestTime == 'MORNING') {
        final hour = t.scheduledPickupAt.hour;
        if (hour >= 12) return false;
      } else if (selectedManifestTime == 'AFTERNOON') {
        final hour = t.scheduledPickupAt.hour;
        if (hour < 12) return false;
      }

      // Search Query Filter
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchRef = t.tripReference.toLowerCase().contains(q);
        final matchPassenger = t.passengerName.toLowerCase().contains(q);
        final matchDriver = t.assignedDriver?.fullName.toLowerCase().contains(q) ?? false;
        final matchSchool = t.destinationLocation.address.toLowerCase().contains(q) ||
            t.pickupLocation.address.toLowerCase().contains(q);
        if (!matchRef && !matchPassenger && !matchDriver && !matchSchool) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<GuardianSafekeepingModel> get filteredSafekeeping {
    if (searchQuery.isEmpty) return safekeepingRoster;
    final q = searchQuery.toLowerCase();
    return safekeepingRoster.where((s) {
      return s.passengerName.toLowerCase().contains(q) ||
          s.schoolName.toLowerCase().contains(q) ||
          s.authorizedContacts.any((c) => c.name.toLowerCase().contains(q));
    }).toList();
  }

  ScheduledOperationsState copyWith({
    List<ScheduledTripDto>? trips,
    List<GuardianSafekeepingModel>? safekeepingRoster,
    List<SchoolCalendarExceptionModel>? calendarExceptions,
    String? selectedManifestTime,
    String? selectedTab,
    String? searchQuery,
    String? actionMessage,
    bool clearActionMessage = false,
    bool? isLoading,
  }) {
    return ScheduledOperationsState(
      trips: trips ?? this.trips,
      safekeepingRoster: safekeepingRoster ?? this.safekeepingRoster,
      calendarExceptions: calendarExceptions ?? this.calendarExceptions,
      selectedManifestTime: selectedManifestTime ?? this.selectedManifestTime,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      actionMessage: clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ScheduledOperationsNotifier extends StateNotifier<ScheduledOperationsState> {
  ScheduledOperationsNotifier() : super(const ScheduledOperationsState()) {
    _loadSeedData();
  }

  void _loadSeedData() {
    final now = DateTime.now();

    const vettedDriverIbrahim = RiderDto(
      id: 'RIDER-001',
      profileId: 'PROF-001',
      fullName: 'Ahmed Ibrahim',
      phoneNumber: '+2348031234567',
      rating: 4.8,
      status: RiderStatus.assigned,
      vehiclePlate: 'ABC-123XY',
      vehicleModel: 'Spiro EV Sedan',
      batteryLevelPercent: 88,
    );

    const vettedDriverZainab = RiderDto(
      id: 'RIDER-004',
      profileId: 'PROF-004',
      fullName: 'Zainab Danjuma',
      phoneNumber: '+2348039871122',
      rating: 4.95,
      status: RiderStatus.online,
      vehiclePlate: 'KD-882-AB',
      vehicleModel: 'Roam Commuter EV',
      batteryLevelPercent: 92,
    );

    // Trips for Today's Manifest (Morning & Afternoon school runs)
    final trip1 = ScheduledTripDto(
      id: 'TRIP-SCH-001',
      tripReference: 'SCH-2026-0801',
      customerId: 'CUST-001',
      passengerProfileId: 'STU-001',
      passengerName: 'Zayd Cole',
      passengerPhone: '0803 456 7890 (Mother)',
      tripPurpose: TripPurpose.schoolRun,
      isSchoolRun: true,
      pickupLocation: const LocationDto(
        latitude: 10.4600,
        longitude: 7.4100,
        address: '12 Katuru Road, Ungwan Rimi, Kaduna',
      ),
      destinationLocation: const LocationDto(
        latitude: 10.5180,
        longitude: 7.4380,
        address: 'Kaduna Capital School, Malali, Kaduna',
      ),
      scheduledPickupAt: DateTime(now.year, now.month, now.day, 7, 30),
      scheduledDateStr: 'Today',
      scheduledTimeStr: '07:30 AM',
      status: ScheduledTripStatus.inProgress,
      assignedDriver: vettedDriverIbrahim,
      quoteId: 'Q-SCH-01',
      fareNgn: 1800.0,
      handoverCode: '482910',
      handoverStatus: HandoverStatus.codePending,
      specialInstructions: 'Hand child directly to Mrs. Bello (Grade 3 Class Teacher).',
    );

    final trip2 = ScheduledTripDto(
      id: 'TRIP-SCH-002',
      tripReference: 'SCH-2026-0802',
      customerId: 'CUST-002',
      passengerProfileId: 'STU-002',
      passengerName: 'Maryam Sani',
      passengerPhone: '0806 321 0987 (Father)',
      tripPurpose: TripPurpose.schoolRun,
      isSchoolRun: true,
      pickupLocation: const LocationDto(
        latitude: 10.5230,
        longitude: 7.4210,
        address: '4 Constitution Road, Kaduna',
      ),
      destinationLocation: const LocationDto(
        latitude: 10.5350,
        longitude: 7.4420,
        address: 'Essence International School, Kaduna',
      ),
      scheduledPickupAt: DateTime(now.year, now.month, now.day, 7, 45),
      scheduledDateStr: 'Today',
      scheduledTimeStr: '07:45 AM',
      status: ScheduledTripStatus.completed,
      assignedDriver: vettedDriverZainab,
      quoteId: 'Q-SCH-02',
      fareNgn: 2200.0,
      handoverCode: '591044',
      handoverStatus: HandoverStatus.verified,
      handoverConfirmedAt: now.subtract(const Duration(minutes: 30)),
      handoverRecipientName: 'Mr. John Adams (School Gate Marshal)',
    );

    final trip3 = ScheduledTripDto(
      id: 'TRIP-SCH-003',
      tripReference: 'SCH-2026-0803',
      customerId: 'CUST-001',
      passengerProfileId: 'STU-001',
      passengerName: 'Zayd Cole',
      passengerPhone: '0803 456 7890 (Mother)',
      tripPurpose: TripPurpose.schoolRun,
      isSchoolRun: true,
      pickupLocation: const LocationDto(
        latitude: 10.5180,
        longitude: 7.4380,
        address: 'Kaduna Capital School, Malali, Kaduna',
      ),
      destinationLocation: const LocationDto(
        latitude: 10.4600,
        longitude: 7.4100,
        address: '12 Katuru Road, Ungwan Rimi, Kaduna',
      ),
      scheduledPickupAt: DateTime(now.year, now.month, now.day, 14, 00),
      scheduledDateStr: 'Today',
      scheduledTimeStr: '02:00 PM',
      status: ScheduledTripStatus.scheduled,
      assignedDriver: vettedDriverIbrahim,
      quoteId: 'Q-SCH-03',
      fareNgn: 1800.0,
      handoverCode: '729184',
      handoverStatus: HandoverStatus.notStarted,
    );

    final trip4 = ScheduledTripDto(
      id: 'TRIP-SCH-004',
      tripReference: 'SCH-2026-0804',
      customerId: 'CUST-003',
      passengerProfileId: 'STU-003',
      passengerName: 'Aliyu Bello',
      passengerPhone: '0802 999 4433 (Guardian)',
      tripPurpose: TripPurpose.schoolRun,
      isSchoolRun: true,
      pickupLocation: const LocationDto(
        latitude: 10.5010,
        longitude: 7.4120,
        address: 'Barnawa GRA, Kaduna',
      ),
      destinationLocation: const LocationDto(
        latitude: 10.5180,
        longitude: 7.4380,
        address: 'Command Children School, Kaduna',
      ),
      scheduledPickupAt: DateTime(now.year, now.month, now.day, 14, 30),
      scheduledDateStr: 'Today',
      scheduledTimeStr: '02:30 PM',
      status: ScheduledTripStatus.driverAssigned,
      assignedDriver: vettedDriverZainab,
      quoteId: 'Q-SCH-04',
      fareNgn: 2000.0,
      handoverCode: '318902',
      handoverStatus: HandoverStatus.notStarted,
    );

    // Safekeeping Roster
    final safekeepingRoster = [
      const GuardianSafekeepingModel(
        passengerId: 'STU-001',
        passengerName: 'Zayd Cole',
        age: 8,
        schoolName: 'Kaduna Capital School',
        pickupAddress: '12 Katuru Road, Ungwan Rimi, Kaduna',
        dropoffAddress: 'Kaduna Capital School, Malali',
        morningTimeStr: '07:30 AM',
        afternoonTimeStr: '02:00 PM',
        singleUseOtp: '482910',
        otpStatus: HandoverStatus.codePending,
        specialCareNotes: 'Mild asthma; inhaler in front backpack pocket. Call mother on arrival.',
        authorizedContacts: [
          AuthorizedContactDto(
            id: 'CON-01',
            name: 'Khadijah Cole',
            relationship: 'Mother',
            phone: '0803 456 7890',
            isPrimary: true,
          ),
          AuthorizedContactDto(
            id: 'CON-02',
            name: 'Alexander Cole',
            relationship: 'Father',
            phone: '0802 333 4455',
          ),
          AuthorizedContactDto(
            id: 'CON-03',
            name: 'Mrs. Bello',
            relationship: 'Class Teacher',
            phone: '0805 111 9900',
          ),
        ],
      ),
      GuardianSafekeepingModel(
        passengerId: 'STU-002',
        passengerName: 'Maryam Sani',
        age: 6,
        schoolName: 'Essence International School',
        pickupAddress: '4 Constitution Road, Kaduna',
        dropoffAddress: 'Essence International School',
        morningTimeStr: '07:45 AM',
        afternoonTimeStr: '02:15 PM',
        singleUseOtp: '591044',
        otpStatus: HandoverStatus.verified,
        verifiedAt: now.subtract(const Duration(minutes: 30)),
        verifiedByStaffOrDriver: 'Zainab Danjuma (EV Chaperone)',
        authorizedContacts: const [
          AuthorizedContactDto(
            id: 'CON-04',
            name: 'Sani Musa',
            relationship: 'Father',
            phone: '0806 321 0987',
            isPrimary: true,
          ),
          AuthorizedContactDto(
            id: 'CON-05',
            name: 'Fatima Sani',
            relationship: 'Mother',
            phone: '0803 222 1199',
          ),
        ],
      ),
    ];

    // Calendar Exceptions
    final exceptions = [
      SchoolCalendarExceptionModel(
        id: 'EXC-001',
        title: 'Democracy Day Public Holiday',
        reason: 'Federal Government declared official public holiday across all schools.',
        startDate: now.add(const Duration(days: 4)),
        endDate: now.add(const Duration(days: 4)),
        affectedSchools: const ['All Kaduna Schools', 'All Kano Schools'],
        isFullDay: true,
        notifyParents: true,
        notifyDrivers: true,
        status: 'ACTIVE',
        createdBy: 'Admin Adeola (Ops Supervisor)',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      SchoolCalendarExceptionModel(
        id: 'EXC-002',
        title: 'Mid-Term Break (Term 1)',
        reason: 'Scheduled mid-term academic break.',
        startDate: now.add(const Duration(days: 12)),
        endDate: now.add(const Duration(days: 14)),
        affectedSchools: const ['Kaduna Capital School', 'Essence International School'],
        isFullDay: true,
        notifyParents: true,
        notifyDrivers: true,
        status: 'ACTIVE',
        createdBy: 'Admin Adeola (Ops Supervisor)',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    state = state.copyWith(
      trips: [trip1, trip2, trip3, trip4],
      safekeepingRoster: safekeepingRoster,
      calendarExceptions: exceptions,
    );
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void setManifestFilter(String filter) {
    state = state.copyWith(selectedManifestTime: filter);
  }

  void setSelectedTab(String tab) {
    state = state.copyWith(selectedTab: tab);
  }

  /// Verifies Single-Use Handover OTP presented at the school gate.
  Future<bool> verifyHandoverOtp(
    String passengerId,
    String enteredOtp, {
    required String officerName,
  }) async {
    final student = state.safekeepingRoster.firstWhere((s) => s.passengerId == passengerId);

    if (student.singleUseOtp.trim() != enteredOtp.trim()) {
      state = state.copyWith(
        actionMessage: 'Error: Invalid OTP code entered for ${student.passengerName}.',
      );
      return false;
    }

    final updatedRoster = state.safekeepingRoster.map((s) {
      if (s.passengerId == passengerId) {
        return s.copyWith(
          otpStatus: HandoverStatus.verified,
          verifiedAt: DateTime.now(),
          verifiedByStaffOrDriver: officerName,
        );
      }
      return s;
    }).toList();

    // Also update matching in-progress trips
    final updatedTrips = state.trips.map((t) {
      if (t.passengerProfileId == passengerId && t.status == ScheduledTripStatus.inProgress) {
        return t.copyWith(
          handoverStatus: HandoverStatus.verified,
          status: ScheduledTripStatus.completed,
          handoverConfirmedAt: DateTime.now(),
          handoverRecipientName: officerName,
        );
      }
      return t;
    }).toList();

    state = state.copyWith(
      safekeepingRoster: updatedRoster,
      trips: updatedTrips,
      actionMessage:
          'Handover verified! OTP authenticated for ${student.passengerName} by $officerName.',
    );
    return true;
  }

  /// Emergency OTP bypass when phone network is down or emergency guardian arrives.
  Future<bool> emergencyBypassOtp(
    String passengerId, {
    required String officerName,
    required String reason,
  }) async {
    final student = state.safekeepingRoster.firstWhere((s) => s.passengerId == passengerId);

    final updatedRoster = state.safekeepingRoster.map((s) {
      if (s.passengerId == passengerId) {
        return s.copyWith(
          otpStatus: HandoverStatus.verified,
          verifiedAt: DateTime.now(),
          verifiedByStaffOrDriver: 'EMERGENCY OVERRIDE: $officerName ($reason)',
        );
      }
      return s;
    }).toList();

    state = state.copyWith(
      safekeepingRoster: updatedRoster,
      actionMessage:
          'Emergency OTP bypass logged for ${student.passengerName}. Reason: "$reason" by $officerName.',
    );
    return true;
  }

  /// Reassigns a vetted chaperone / driver to a school trip.
  Future<bool> reassignDriver(
    String tripId,
    RiderDto newDriver, {
    required String reason,
  }) async {
    final updatedTrips = state.trips.map((t) {
      if (t.id == tripId) {
        return t.copyWith(
          assignedDriver: newDriver,
          status: ScheduledTripStatus.driverAssigned,
        );
      }
      return t;
    }).toList();

    state = state.copyWith(
      trips: updatedTrips,
      actionMessage:
          'Vetted chaperone reassigned to ${newDriver.fullName} for trip $tripId ($reason).',
    );
    return true;
  }

  /// Adds a new calendar exception (public holiday, flood closure, strike).
  Future<bool> addCalendarException(SchoolCalendarExceptionModel exception) async {
    final updated = [...state.calendarExceptions, exception];
    state = state.copyWith(
      calendarExceptions: updated,
      actionMessage:
          'Calendar exception "${exception.title}" created. Automatic commute runs paused for affected dates.',
    );
    return true;
  }

  /// Toggles status of calendar exception.
  Future<bool> toggleCalendarExceptionStatus(String exceptionId) async {
    final updated = state.calendarExceptions.map((e) {
      if (e.id == exceptionId) {
        return e.copyWith(
          status: e.status == 'ACTIVE' ? 'CANCELLED' : 'ACTIVE',
        );
      }
      return e;
    }).toList();

    state = state.copyWith(
      calendarExceptions: updated,
      actionMessage: 'Calendar exception $exceptionId status updated.',
    );
    return true;
  }

  /// Cancels or skips an individual scheduled trip.
  Future<bool> cancelOrSkipTrip(String tripId, {required String reason}) async {
    final updatedTrips = state.trips.map((t) {
      if (t.id == tripId) {
        return t.copyWith(
          status: ScheduledTripStatus.skipped,
          skipReason: reason,
        );
      }
      return t;
    }).toList();

    state = state.copyWith(
      trips: updatedTrips,
      actionMessage: 'Trip $tripId skipped ($reason). Wallet credit initiated.',
    );
    return true;
  }
}

final scheduledOperationsNotifierProvider =
    StateNotifierProvider<ScheduledOperationsNotifier, ScheduledOperationsState>(
        (ref) {
  return ScheduledOperationsNotifier();
});
