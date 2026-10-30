import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// State representation for the Customer Home Dashboard.
class HomeState extends Equatable {
  const HomeState({
    required this.currentLocation,
    this.serviceAreas = const [],
    this.savedPlaces = const [],
    this.campaigns = const [],
    this.activeBooking,
    this.isLoading = false,
    this.errorMessage,
  });

  final ServiceAreaDto currentLocation;
  final List<ServiceAreaDto> serviceAreas;
  final List<SavedPlaceDto> savedPlaces;
  final List<CampaignBannerDto> campaigns;
  final ActiveBookingSummaryDto? activeBooking;
  final bool isLoading;
  final String? errorMessage;

  /// Dynamic time-aware greeting prefix (e.g. "Good morning", "Good afternoon", "Good evening").
  String get greetingPrefix {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Checks if a given service is available in the currently selected area.
  bool isServiceAvailable(ServiceCode service) {
    return currentLocation.isServiceAvailable(service);
  }

  /// True if customer has an ongoing active booking.
  bool get hasActiveBooking => activeBooking != null;

  HomeState copyWith({
    ServiceAreaDto? currentLocation,
    List<ServiceAreaDto>? serviceAreas,
    List<SavedPlaceDto>? savedPlaces,
    List<CampaignBannerDto>? campaigns,
    ActiveBookingSummaryDto? activeBooking,
    bool clearActiveBooking = false,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      currentLocation: currentLocation ?? this.currentLocation,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      campaigns: campaigns ?? this.campaigns,
      activeBooking: clearActiveBooking ? null : (activeBooking ?? this.activeBooking),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentLocation,
        serviceAreas,
        savedPlaces,
        campaigns,
        activeBooking,
        isLoading,
        errorMessage,
      ];
}

