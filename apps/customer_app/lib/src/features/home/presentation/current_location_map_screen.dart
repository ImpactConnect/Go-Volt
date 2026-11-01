import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/presentation/widgets/live_google_map_view.dart';
import '../../../core/services/gps_location_service.dart';
import '../../booking/application/booking_notifier.dart';
import '../../parcel/application/parcel_booking_notifier.dart';
import '../application/home_notifier.dart';

/// Screen displaying an embedded live Google Map for viewing, zooming,
/// and confirming the customer's exact current GPS coordinates.
class CurrentLocationMapScreen extends ConsumerStatefulWidget {
  const CurrentLocationMapScreen({
    super.key,
    this.initialLocation,
  });

  final LocationDto? initialLocation;

  static Future<LocationDto?> open(
    BuildContext context, {
    LocationDto? initialLocation,
  }) {
    return Navigator.of(context).push<LocationDto>(
      MaterialPageRoute(
        builder: (_) => CurrentLocationMapScreen(
          initialLocation: initialLocation,
        ),
      ),
    );
  }

  @override
  ConsumerState<CurrentLocationMapScreen> createState() =>
      _CurrentLocationMapScreenState();
}

class _CurrentLocationMapScreenState
    extends ConsumerState<CurrentLocationMapScreen> {
  final GlobalKey<LiveGoogleMapViewState> _mapKey = GlobalKey();
  late double _currentLat;
  late double _currentLng;
  late String _address;
  late String _label;
  bool _isLocating = false;
  late final List<LocationDto> _operatingLandmarks;

  @override
  void initState() {
    super.initState();
    _operatingLandmarks = GpsLocationService.getOperatingLandmarks();

    final homeState = ref.read(homeNotifierProvider);
    final initLoc = widget.initialLocation ??
        homeState.currentCoordinates ??
        const LocationDto(
          latitude: GpsLocationService.defaultLat,
          longitude: GpsLocationService.defaultLng,
          address: 'Central Roundabout, Shaganu, Ogun State',
          label: 'Shaganu Central',
        );

    _currentLat = initLoc.latitude;
    _currentLng = initLoc.longitude;
    _address = initLoc.address;
    _label = initLoc.label ?? 'My Current Location';

    // Auto-locate GPS on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectCurrentGps(animate: true);
    });
  }

  Future<void> _detectCurrentGps({bool animate = true}) async {
    setState(() => _isLocating = true);
    try {
      final detected = await GpsLocationService.getCurrentPosition(
        label: 'My Current Location',
      );
      if (mounted) {
        setState(() {
          _currentLat = detected.latitude;
          _currentLng = detected.longitude;
          _address = detected.address;
          _label = detected.label ?? 'My Current Location';
        });

        if (animate) {
          _mapKey.currentState?.animateTo(
            LatLng(_currentLat, _currentLng),
            zoom: 16.5,
          );
        }
      }
    } catch (_) {
      // Keep existing coordinates
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _onPositionChanged(LatLng newCoord) {
    setState(() {
      _currentLat = newCoord.latitude;
      _currentLng = newCoord.longitude;
      // Reverse-geocode to closest known landmark or coordinate string
      final closest = _findClosestLandmark(newCoord.latitude, newCoord.longitude);
      if (closest != null) {
        _address = closest.address;
        _label = closest.label ?? 'Selected Location';
      } else {
        _address =
            '${newCoord.latitude.toStringAsFixed(4)}°N, ${newCoord.longitude.toStringAsFixed(4)}°E, Shaganu';
        _label = 'Live GPS Pin';
      }
    });
  }

  LocationDto? _findClosestLandmark(double lat, double lng) {
    for (final lm in _operatingLandmarks) {
      final dLat = (lm.latitude - lat).abs();
      final dLng = (lm.longitude - lng).abs();
      if (dLat < 0.0015 && dLng < 0.0015) {
        return lm;
      }
    }
    return null;
  }

  void _selectLandmark(LocationDto lm) {
    setState(() {
      _currentLat = lm.latitude;
      _currentLng = lm.longitude;
      _address = lm.address;
      _label = lm.label ?? 'Selected Landmark';
    });
    _mapKey.currentState?.animateTo(
      LatLng(lm.latitude, lm.longitude),
      zoom: 16.5,
    );
  }

  void _confirmLocation() {
    final confirmed = LocationDto(
      latitude: _currentLat,
      longitude: _currentLng,
      address: _address,
      label: _label,
    );

    // 1. Update Home Dashboard State
    final homeNotifier = ref.read(homeNotifierProvider.notifier);
    homeNotifier.setCurrentCoordinates(confirmed);

    // 2. Fill in coordinates for Ride Booking (Rider and Admin will receive this)
    final bookingNotifier = ref.read(bookingNotifierProvider.notifier);
    bookingNotifier.setPickupLocation(confirmed);

    // 3. Fill in coordinates for Parcel Dispatch
    final parcelNotifier = ref.read(parcelBookingNotifierProvider.notifier);
    parcelNotifier.setPickupLocation(confirmed);

    // 4. Return to caller
    Navigator.of(context).pop(confirmed);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A221E) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Scaffold(
      backgroundColor: cardBg,
      body: Stack(
        children: [
          // 1. Full Live Google Map
          Positioned.fill(
            child: LiveGoogleMapView(
              key: _mapKey,
              initialLatitude: _currentLat,
              initialLongitude: _currentLng,
              initialZoom: 16.0,
              isPicker: true,
              pickerTitle: _label,
              pickerAddress: _address,
              pinColor: GVColors.brandGreen,
              showZoomControls: true,
              showMyLocationButton: true,
              onMyLocationTapped: () => _detectCurrentGps(animate: true),
              onPositionChanged: _onPositionChanged,
            ),
          ),

          // 2. Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Back / Close Button
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2822) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: textColor,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Live GPS Pill
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2822) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: GVColors.brandGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Live Map • Current Location',
                              style: GVTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            if (_isLocating)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: GVColors.brandGreen,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Quick Landmarks Carousel above Bottom Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 215,
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _operatingLandmarks.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final lm = _operatingLandmarks[index];
                  final isSelected =
                      (lm.latitude - _currentLat).abs() < 0.0005 &&
                      (lm.longitude - _currentLng).abs() < 0.0005;

                  return ActionChip(
                    avatar: Icon(
                      Icons.place_rounded,
                      size: 14,
                      color: isSelected ? Colors.white : GVColors.brandGreen,
                    ),
                    label: Text(
                      lm.label ?? lm.address,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : GVColors.textPrimary),
                      ),
                    ),
                    backgroundColor: isSelected
                        ? GVColors.brandGreen
                        : (isDark ? const Color(0xFF1E2822) : Colors.white),
                    elevation: 3,
                    shadowColor: Colors.black26,
                    side: BorderSide(
                      color: isSelected
                          ? GVColors.brandGreen
                          : (isDark ? const Color(0xFF2E3D35) : GVColors.border),
                    ),
                    onPressed: () => _selectLandmark(lm),
                  );
                },
              ),
            ),
          ),

          // 4. Bottom Confirmation Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: borderColor)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location Info Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: GVColors.brandGreen.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: GVColors.brandGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _label,
                                      style: GVTypography.h3.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: GVColors.brandGreen
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${_currentLat.toStringAsFixed(4)}°, ${_currentLng.toStringAsFixed(4)}°',
                                      style: GVTypography.caption.copyWith(
                                        color: GVColors.brandGreen,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _address,
                                style: GVTypography.bodySmall.copyWith(
                                  color: subtextColor,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Confirm CTA Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GVColors.brandGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Confirm & Use This Location',
                          style: GVTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
