import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_state.dart';

final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(_initialState);

  static final ServiceAreaDto defaultArea = const ServiceAreaDto(
    id: 'victoria-island',
    name: 'Victoria Island',
    state: 'Lagos',
    status: ServiceAreaStatus.fullySupported,
    statusDescription: 'Fully supported',
    availableServices: [
      ServiceCode.instantRide,
      ServiceCode.instantDelivery,
      ServiceCode.scheduledRide,
      ServiceCode.scheduledPickup,
    ],
  );

  static final List<ServiceAreaDto> predefinedAreas = [
    const ServiceAreaDto(
      id: 'victoria-island',
      name: 'Victoria Island',
      state: 'Lagos',
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
      id: 'lekki-phase-1',
      name: 'Lekki',
      state: 'Lagos',
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
      id: 'ikoyi',
      name: 'Ikoyi',
      state: 'Lagos',
      status: ServiceAreaStatus.limited,
      statusDescription: 'Limited services',
      // In Ikoyi, instant rides are currently unavailable/limited per screen design 13
      availableServices: [
        ServiceCode.instantDelivery,
        ServiceCode.scheduledPickup,
      ],
    ),
  ];

  static final List<SavedPlaceDto> defaultSavedPlaces = [
    const SavedPlaceDto(
      id: 'place_home',
      label: 'Home',
      address: 'Victoria Island, Lagos',
      type: SavedPlaceType.home,
      latitude: 6.4281,
      longitude: 3.4219,
    ),
    const SavedPlaceDto(
      id: 'place_work',
      label: 'Work',
      address: 'Lekki Phase 1, Lagos',
      type: SavedPlaceType.work,
      latitude: 6.4474,
      longitude: 3.4739,
    ),
  ];

  static final List<CampaignBannerDto> defaultCampaigns = [
    const CampaignBannerDto(
      id: 'promo_ride_20',
      title: 'Save 20% on your next ride',
      promoCode: 'GO20',
      subtitle: 'Use code GO20',
      description: 'Zero-emission rides across Lagos Island at 20% off',
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

  static HomeState get _initialState {
    return HomeState(
      currentLocation: defaultArea,
      serviceAreas: predefinedAreas,
      savedPlaces: defaultSavedPlaces,
      campaigns: defaultCampaigns,
      activeBooking: null,
    );
  }

  /// Changes currently selected service zone.
  void selectLocation(ServiceAreaDto area) {
    state = state.copyWith(currentLocation: area);
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

  /// Refreshes dashboard data.
  Future<void> refreshDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(isLoading: false);
  }
}

