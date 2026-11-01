import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';
import '../../../features/auth/data/operating_location_repository.dart';
import 'home_state.dart';

final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final isNewUser = authState.status == AuthStatus.authenticated &&
      authState.profile != null &&
      authState.profile!.ecoPointsBalance == 0 &&
      authState.profile!.carbonAvoidedKg == 0.0;

  final initialPlaces =
      isNewUser ? <SavedPlaceDto>[] : HomeNotifier.defaultSavedPlaces;

  // Load operating locations from DB asynchronously; provider gives fallback.
  final locationRepo = ref.read(operatingLocationRepositoryProvider);
  final notifier = HomeNotifier(initialSavedPlaces: initialPlaces);
  locationRepo.getActiveLocations().then((locations) {
    if (locations.isNotEmpty) {
      notifier.setServiceAreasFromDb(locations);
    }
  });
  return notifier;
});

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier({List<SavedPlaceDto>? initialSavedPlaces})
      : super(_buildInitialState(initialSavedPlaces));

  static final ServiceAreaDto defaultArea = const ServiceAreaDto(
    id: 'ogun-shaganu',
    name: 'Shaganu',
    state: 'Ogun',
    status: ServiceAreaStatus.fullySupported,
    statusDescription: 'Fully supported',
    availableServices: [
      ServiceCode.instantRide,
      ServiceCode.instantDelivery,
      ServiceCode.scheduledRide,
      ServiceCode.scheduledPickup,
    ],
  );

  /// Seed list — mirrors the DB fallback. Replaced at runtime when DB loads.
  static final List<ServiceAreaDto> predefinedAreas = [
    const ServiceAreaDto(
      id: 'ogun-shaganu',
      name: 'Shaganu',
      state: 'Ogun',
      status: ServiceAreaStatus.fullySupported,
      statusDescription: 'Fully supported',
      availableServices: [
        ServiceCode.instantRide,
        ServiceCode.instantDelivery,
        ServiceCode.scheduledRide,
        ServiceCode.scheduledPickup,
      ],
    ),
    const ServiceAreaDto(
      id: 'ogun-remo-north',
      name: 'Remo North',
      state: 'Ogun',
      status: ServiceAreaStatus.limited,
      statusDescription: 'Limited services',
      availableServices: [
        ServiceCode.instantDelivery,
      ],
    ),
  ];

  /// Empty by default — new users have no saved places.
  static final List<SavedPlaceDto> defaultSavedPlaces = [];

  /// Updates service areas when DB data arrives.
  void setServiceAreasFromDb(List<OperatingLocationDto> locations) {
    final areas = locations
        .map(
          (loc) => ServiceAreaDto(
            id: '${loc.state.toLowerCase()}-${loc.city.toLowerCase()}',
            name: loc.city,
            state: loc.state,
            status: loc.isFullySupported
                ? ServiceAreaStatus.fullySupported
                : ServiceAreaStatus.limited,
            statusDescription: loc.statusDescription,
            availableServices:
                loc.availableServices.map(_toServiceCode).whereType<ServiceCode>().toList(),
          ),
        )
        .toList();

    if (areas.isNotEmpty) {
      state = state.copyWith(
        serviceAreas: areas,
        currentLocation: areas.first,
      );
    }
  }

  static ServiceCode? _toServiceCode(String raw) {
    switch (raw) {
      case 'instant_ride':
        return ServiceCode.instantRide;
      case 'instant_delivery':
        return ServiceCode.instantDelivery;
      case 'scheduled_ride':
        return ServiceCode.scheduledRide;
      case 'scheduled_pickup':
        return ServiceCode.scheduledPickup;
      default:
        return null;
    }
  }

  static final List<CampaignBannerDto> defaultCampaigns = [
    const CampaignBannerDto(
      id: 'promo_ride_20',
      title: 'Save 20% on your next ride',
      promoCode: 'GO20',
      subtitle: 'Use code GO20',
      description: 'Zero-emission rides across your city at 20% off',
      ctaText: 'Learn more',
      ctaRoute: '/ride-booking',
      bannerType: 'discount',
      discountPercentage: 20,
    ),
    const CampaignBannerDto(
      id: 'promo_referral_500',
      title: 'Refer a friend, get 500 points',
      subtitle: 'Invite friends and earn rewards',
      description: 'Get 500 Eco-Points for every friend who takes their first EV ride',
      ctaText: 'Refer now',
      ctaRoute: '/wallet-rewards',
      bannerType: 'referral',
      pointsReward: 500,
    ),
  ];

  static HomeState _buildInitialState(List<SavedPlaceDto>? initialSavedPlaces) {
    return HomeState(
      currentLocation: defaultArea,
      serviceAreas: predefinedAreas,
      savedPlaces: initialSavedPlaces ?? const [],
      campaigns: defaultCampaigns,
      activeBooking: null,
    );
  }

  /// Clears saved places for a clean new user baseline.
  void clearSavedPlaces() {
    state = state.copyWith(savedPlaces: const []);
  }


  /// Changes currently selected service zone.
  void selectLocation(ServiceAreaDto area) {
    state = state.copyWith(currentLocation: area);
  }

  /// Sets exact GPS coordinates selected from the Live Map.
  void setCurrentCoordinates(LocationDto coords) {
    state = state.copyWith(currentCoordinates: coords);
  }

  /// Sets or clears active booking summary card.
  void setActiveBooking(ActiveBookingSummaryDto? booking) {
    if (booking == null) {
      state = state.copyWith(clearActiveBooking: true);
    } else {
      state = state.copyWith(activeBooking: booking);
    }
  }

  /// Simulates an active booking for demo / testing.
  void setSampleActiveBooking() {
    state = state.copyWith(
      activeBooking: const ActiveBookingSummaryDto(
        bookingId: 'bk_824755',
        referenceCode: 'GV-824755',
        serviceType: ServiceCode.instantRide,
        serviceTitle: 'Ride booking',
        status: BookingStatus.assigned,
        statusBadge: 'In progress',
        riderName: 'Babajide S.',
        statusMessage: 'Rider approaching',
        etaMinutes: 3,
        targetRoute: '/live-tracking',
      ),
    );
  }

  /// Clears active booking.
  void clearActiveBooking() {
    state = state.copyWith(clearActiveBooking: true);
  }

  /// Adds a new saved place.
  void addSavedPlace(SavedPlaceDto place) {
    final updated = [...state.savedPlaces, place];
    state = state.copyWith(savedPlaces: updated);
  }

  /// Removes a saved place by id.
  void removeSavedPlace(String id) {
    final updated = state.savedPlaces.where((p) => p.id != id).toList();
    state = state.copyWith(savedPlaces: updated);
  }

  /// Refreshes dashboard data.
  Future<void> refreshDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(isLoading: false);
  }
}

