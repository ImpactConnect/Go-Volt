import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/scheduled_repository.dart';

class ScheduledBookingState extends Equatable {
  const ScheduledBookingState({
    this.bookingType = ScheduledBookingType.oneOff,
    this.purpose = TripPurpose.schoolRun,
    this.pickupLocation = LocationDto.empty,
    this.destinationLocation = LocationDto.empty,
    this.returnPickupLocation,
    this.returnDestinationLocation,
    this.journeyDirection = JourneyDirection.oneWay,
    this.scheduledDate,
    this.pickupTime = '8:00 AM',
    this.returnPickupTime,
    this.returnLater = false,
    this.frequency = ScheduleFrequency.weekly,
    this.selectedDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    this.startDate,
    this.endDate,
    this.excludedDates = const [],
    this.isMyself = true,
    this.passengerName = '',
    this.passengerPhone = '',
    this.savePassenger = false,
    this.specialInstructions = '',
    this.preferredDriver,
    this.billingModel = PackageBillingModel.payPerTrip,
    this.activeQuote,
    this.createdPlan,
    this.isLoading = false,
    this.errorMessage,
  });

  final ScheduledBookingType bookingType;
  final TripPurpose purpose;
  final LocationDto pickupLocation;
  final LocationDto destinationLocation;
  final LocationDto? returnPickupLocation;
  final LocationDto? returnDestinationLocation;
  final JourneyDirection journeyDirection;
  final DateTime? scheduledDate;
  final String pickupTime;
  final String? returnPickupTime;
  final bool returnLater;
  final ScheduleFrequency frequency;
  final List<String> selectedDays;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<DateTime> excludedDates;
  final bool isMyself;
  final String passengerName;
  final String passengerPhone;
  final bool savePassenger;
  final String? specialInstructions;
  final RiderDto? preferredDriver;
  final PackageBillingModel billingModel;
  final ScheduledQuoteDto? activeQuote;
  final ScheduledPlanDto? createdPlan;
  final bool isLoading;
  final String? errorMessage;

  bool get isRecurring => bookingType == ScheduledBookingType.recurring;
  bool get isRoundTrip => journeyDirection == JourneyDirection.roundTrip;

  ScheduledBookingState copyWith({
    ScheduledBookingType? bookingType,
    TripPurpose? purpose,
    LocationDto? pickupLocation,
    LocationDto? destinationLocation,
    LocationDto? returnPickupLocation,
    LocationDto? returnDestinationLocation,
    JourneyDirection? journeyDirection,
    DateTime? scheduledDate,
    String? pickupTime,
    String? returnPickupTime,
    bool? returnLater,
    ScheduleFrequency? frequency,
    List<String>? selectedDays,
    DateTime? startDate,
    DateTime? endDate,
    List<DateTime>? excludedDates,
    bool? isMyself,
    String? passengerName,
    String? passengerPhone,
    bool? savePassenger,
    String? specialInstructions,
    RiderDto? preferredDriver,
    bool clearPreferredDriver = false,
    PackageBillingModel? billingModel,
    ScheduledQuoteDto? activeQuote,
    ScheduledPlanDto? createdPlan,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ScheduledBookingState(
      bookingType: bookingType ?? this.bookingType,
      purpose: purpose ?? this.purpose,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      returnPickupLocation: returnPickupLocation ?? this.returnPickupLocation,
      returnDestinationLocation:
          returnDestinationLocation ?? this.returnDestinationLocation,
      journeyDirection: journeyDirection ?? this.journeyDirection,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      pickupTime: pickupTime ?? this.pickupTime,
      returnPickupTime: returnPickupTime ?? this.returnPickupTime,
      returnLater: returnLater ?? this.returnLater,
      frequency: frequency ?? this.frequency,
      selectedDays: selectedDays ?? this.selectedDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      excludedDates: excludedDates ?? this.excludedDates,
      isMyself: isMyself ?? this.isMyself,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      savePassenger: savePassenger ?? this.savePassenger,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      preferredDriver: clearPreferredDriver
          ? null
          : (preferredDriver ?? this.preferredDriver),
      billingModel: billingModel ?? this.billingModel,
      activeQuote: activeQuote ?? this.activeQuote,
      createdPlan: createdPlan ?? this.createdPlan,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        bookingType,
        purpose,
        pickupLocation,
        destinationLocation,
        journeyDirection,
        scheduledDate,
        pickupTime,
        returnLater,
        frequency,
        selectedDays,
        startDate,
        endDate,
        isMyself,
        passengerName,
        passengerPhone,
        preferredDriver,
        billingModel,
        activeQuote,
        createdPlan,
        isLoading,
        errorMessage,
      ];
}

final scheduledBookingNotifierProvider =
    StateNotifierProvider<ScheduledBookingNotifier, ScheduledBookingState>(
        (ref) {
  final repository = ref.watch(scheduledRepositoryProvider);
  return ScheduledBookingNotifier(repository: repository);
});

class ScheduledBookingNotifier extends StateNotifier<ScheduledBookingState> {
  ScheduledBookingNotifier({required ScheduledRepository repository})
      : _repository = repository,
        super(ScheduledBookingState(
          scheduledDate: DateTime.now().add(const Duration(days: 3)),
          startDate: DateTime(2026, 11, 3),
          endDate: DateTime(2027, 1, 30),
        ));

  final ScheduledRepository _repository;

  void setBookingType(ScheduledBookingType type) {
    state = state.copyWith(bookingType: type);
  }

  void setTripPurpose(TripPurpose purpose) {
    state = state.copyWith(purpose: purpose);
  }

  void setPickupLocation(LocationDto location) {
    state = state.copyWith(pickupLocation: location);
  }

  void setDestinationLocation(LocationDto location) {
    state = state.copyWith(destinationLocation: location);
  }

  void setJourneyDirection(JourneyDirection direction) {
    state = state.copyWith(journeyDirection: direction);
  }

  void setDateAndTime({
    required DateTime date,
    required String time,
    bool? returnLater,
    String? returnTime,
  }) {
    state = state.copyWith(
      scheduledDate: date,
      pickupTime: time,
      returnLater: returnLater ?? state.returnLater,
      returnPickupTime: returnTime ?? state.returnPickupTime,
    );
  }

  void setRecurringSchedule({
    required ScheduleFrequency frequency,
    required List<String> days,
    required DateTime startDate,
    required DateTime endDate,
    List<DateTime>? excludedDates,
  }) {
    state = state.copyWith(
      frequency: frequency,
      selectedDays: days,
      startDate: startDate,
      endDate: endDate,
      excludedDates: excludedDates ?? state.excludedDates,
    );
  }

  void toggleDay(String day) {
    final list = List<String>.from(state.selectedDays);
    if (list.contains(day)) {
      if (list.length > 1) {
        list.remove(day);
      }
    } else {
      list.add(day);
    }
    state = state.copyWith(selectedDays: list);
  }

  void setPassengerDetails({
    required String name,
    required String phone,
    bool? isMyself,
    bool? savePassenger,
    String? instructions,
  }) {
    state = state.copyWith(
      passengerName: name,
      passengerPhone: phone,
      isMyself: isMyself ?? state.isMyself,
      savePassenger: savePassenger ?? state.savePassenger,
      specialInstructions: instructions ?? state.specialInstructions,
    );
  }

  void setPreferredDriver(RiderDto? driver) {
    if (driver == null) {
      state = state.copyWith(clearPreferredDriver: true);
    } else {
      state = state.copyWith(preferredDriver: driver);
    }
  }

  void setBillingModel(PackageBillingModel model) {
    state = state.copyWith(billingModel: model);
  }

  /// Calculates deterministic quote for review (Screens 11 & 12).
  Future<ScheduledQuoteDto?> generateQuote() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final quote = await _repository.calculateQuote(
        bookingType: state.bookingType,
        purpose: state.purpose,
        journeyType: state.journeyDirection,
        pickupLocation: state.pickupLocation,
        destinationLocation: state.destinationLocation,
        returnPickupLocation: state.returnPickupLocation,
        returnDestinationLocation: state.returnDestinationLocation,
        scheduledDate: state.scheduledDate,
        pickupTime: state.pickupTime,
        returnPickupTime: state.returnPickupTime,
        selectedDays: state.selectedDays,
        startDate: state.startDate,
        endDate: state.endDate,
        billingModel: state.billingModel,
      );
      state = state.copyWith(activeQuote: quote, isLoading: false);
      return quote;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate quote: ${e.toString()}',
      );
      return null;
    }
  }

  /// Submits the plan or booking request to operations (Screen 13).
  Future<ScheduledPlanDto?> submitRequest() async {
    final quote = state.activeQuote;
    if (quote == null) return null;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final plan = await _repository.submitPlanRequest(
        quote: quote,
        passengerName: state.passengerName,
        passengerPhone: state.passengerPhone,
        specialInstructions: state.specialInstructions,
        preferredDriverId: state.preferredDriver?.id,
        preferredDriverName: state.preferredDriver?.name,
      );
      state = state.copyWith(createdPlan: plan, isLoading: false);
      return plan;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit request: ${e.toString()}',
      );
      return null;
    }
  }
}

