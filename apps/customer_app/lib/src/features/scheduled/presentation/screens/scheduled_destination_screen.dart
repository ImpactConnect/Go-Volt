import 'dart:async';

import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/presentation/widgets/live_google_map_view.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/google_places_service.dart';
import '../../../booking/presentation/map_picker_screen.dart';
import '../../../home/application/home_notifier.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 5 (SP-05): Scheduled Destination Screen
/// Configures destination address, shortcuts, real-time Google Places autocomplete,
/// and interactive red live map pin coordinate.
class ScheduledDestinationScreen extends ConsumerStatefulWidget {
  const ScheduledDestinationScreen({super.key});

  @override
  ConsumerState<ScheduledDestinationScreen> createState() =>
      _ScheduledDestinationScreenState();
}

class _ScheduledDestinationScreenState
    extends ConsumerState<ScheduledDestinationScreen> {
  final _searchController = TextEditingController();
  final GlobalKey<LiveGoogleMapViewState> _mapKey = GlobalKey();
  Timer? _debounceTimer;
  String? _placesSessionToken;
  List<PlacePrediction> _livePredictions = [];
  bool _isLoadingPredictions = false;

  @override
  void initState() {
    super.initState();
    final dest =
        ref.read(scheduledBookingNotifierProvider).destinationLocation;
    _searchController.text = dest.address;
    _placesSessionToken = GooglePlacesService.generateSessionToken();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _livePredictions = [];
        _isLoadingPredictions = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 250), () async {
      setState(() => _isLoadingPredictions = true);
      try {
        final predictions = await ref
            .read(googlePlacesServiceProvider)
            .searchPredictions(query, sessionToken: _placesSessionToken);
        if (mounted) {
          setState(() {
            _livePredictions = predictions;
            _isLoadingPredictions = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _isLoadingPredictions = false);
        }
      }
    });
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    setState(() => _isLoadingPredictions = true);
    final placesService = ref.read(googlePlacesServiceProvider);
    LocationDto? resolved;
    try {
      resolved = await placesService.getPlaceDetails(
        prediction.placeId,
        sessionToken: _placesSessionToken,
      );
    } catch (_) {}

    _placesSessionToken = GooglePlacesService.generateSessionToken();

    resolved ??= LocationDto(
      latitude: GooglePlacesService.operatingLat,
      longitude: GooglePlacesService.operatingLng,
      address: prediction.description.isNotEmpty
          ? prediction.description
          : prediction.mainText,
      label: prediction.mainText,
      city: 'Shaganu',
      state: 'Ogun',
    );

    ref
        .read(scheduledBookingNotifierProvider.notifier)
        .setDestinationLocation(resolved);
    _searchController.text = resolved.address;
    _mapKey.currentState
        ?.animateTo(LatLng(resolved.latitude, resolved.longitude));

    if (mounted) {
      setState(() {
        _livePredictions.clear();
        _isLoadingPredictions = false;
      });
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<LocationDto>(
      MaterialPageRoute(
        builder: (context) => const MapPickerScreen(isPickup: false),
      ),
    );

    if (result != null && mounted) {
      ref
          .read(scheduledBookingNotifierProvider.notifier)
          .setDestinationLocation(result);
      _searchController.text = result.address;
      _mapKey.currentState
          ?.animateTo(LatLng(result.latitude, result.longitude));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduledBookingNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: textColor,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Destination',
                    style: GVTypography.h1.copyWith(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),

                  // Search Field with Live Google Places Autocomplete
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GVTypography.bodyMedium.copyWith(color: textColor),
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search or enter destination in Shaganu, Ogun',
                        hintStyle: GVTypography.bodyMedium
                            .copyWith(color: subtextColor),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: GVColors.error),
                        suffixIcon: _isLoadingPredictions
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: GVColors.brandGreen,
                                  ),
                                ),
                              )
                            : (_searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: GVSpacing.sm),

                  // Autocomplete Live Suggestions or Default Shortcuts
                  if (_livePredictions.isNotEmpty) ...[
                    Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _livePredictions.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final pred = _livePredictions[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.location_on_rounded,
                              color: GVColors.error,
                              size: 20,
                            ),
                            title: Text(
                              pred.mainText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            subtitle: Text(
                              pred.secondaryText.isNotEmpty
                                  ? pred.secondaryText
                                  : pred.description,
                              style:
                                  TextStyle(color: subtextColor, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectPrediction(pred),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    // Shortcut 1: Select on map
                    _buildLocationShortcut(
                      icon: Icons.map_outlined,
                      title: 'Select on map',
                      subtitle: 'Pinpoint destination on live map',
                      pinColor: GVColors.error,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      onTap: _openMapPicker,
                    ),
                    const Divider(height: 1),

                    // Shortcut 2: Dynamic Saved Places (e.g. Work, Custom) or Remo High Street
                    if (homeState.savedPlaces.isNotEmpty) ...[
                      for (final saved in homeState.savedPlaces.take(2)) ...[
                        _buildLocationShortcut(
                          icon: saved.isWork
                              ? Icons.work_rounded
                              : (saved.isHome
                                  ? Icons.home_rounded
                                  : Icons.place_rounded),
                          title: saved.label,
                          subtitle: saved.address,
                          pinColor: GVColors.error,
                          textColor: textColor,
                          subtextColor: subtextColor,
                          onTap: () {
                            final loc = LocationDto(
                              latitude: saved.latitude,
                              longitude: saved.longitude,
                              address: saved.address,
                              label: saved.label,
                              city: 'Shaganu',
                              state: 'Ogun',
                            );
                            ref
                                .read(scheduledBookingNotifierProvider.notifier)
                                .setDestinationLocation(loc);
                            _searchController.text = loc.address;
                            _mapKey.currentState?.animateTo(
                                LatLng(loc.latitude, loc.longitude));
                          },
                        ),
                        const Divider(height: 1),
                      ],
                    ] else ...[
                      _buildLocationShortcut(
                        icon: Icons.school_rounded,
                        title: 'Remo High Street',
                        subtitle: 'Remo High Street, Shaganu, Ogun State',
                        pinColor: GVColors.error,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        onTap: () {
                          const loc = LocationDto(
                            latitude: 6.8450,
                            longitude: 3.6520,
                            address: 'Remo High Street, Shaganu, Ogun State',
                            label: 'Remo High Street',
                            city: 'Shaganu',
                            state: 'Ogun',
                          );
                          ref
                              .read(scheduledBookingNotifierProvider.notifier)
                              .setDestinationLocation(loc);
                          _searchController.text = loc.address;
                          _mapKey.currentState?.animateTo(
                              LatLng(loc.latitude, loc.longitude));
                        },
                      ),
                      const Divider(height: 1),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: GVSpacing.sm),

            // Map preview with red destination pin
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: LiveGoogleMapView(
                      key: _mapKey,
                      initialLatitude: state.destinationLocation.latitude,
                      initialLongitude: state.destinationLocation.longitude,
                      initialZoom: 16.0,
                      showZoomControls: true,
                      showMyLocationButton: false,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 48,
                          color: GVColors.error,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black87 : Colors.white,
                            borderRadius:
                                BorderRadius.circular(GVBorderRadius.full),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            state.destinationLocation.label ?? 'Destination',
                            style: GVTypography.labelSmall.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.small(
                      backgroundColor: isDark ? cardBg : Colors.white,
                      onPressed: () {
                        _mapKey.currentState?.animateTo(
                          LatLng(
                            state.destinationLocation.latitude,
                            state.destinationLocation.longitude,
                          ),
                        );
                      },
                      child: const Icon(Icons.my_location_rounded,
                          color: GVColors.error),
                    ),
                  ),
                ],
              ),
            ),

            // CTA: Continue
            Padding(
              padding: const EdgeInsets.all(GVSpacing.lg),
              child: GVButton(
                text: 'Continue',
                onPressed: () {
                  context.push(AppRoutes.scheduledTripDetails);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationShortcut({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? pinColor,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    final effectiveColor = pinColor ?? textColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: effectiveColor, size: 20),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GVTypography.labelMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: GVColors.neutral400, size: 20),
          ],
        ),
      ),
    );
  }
}
