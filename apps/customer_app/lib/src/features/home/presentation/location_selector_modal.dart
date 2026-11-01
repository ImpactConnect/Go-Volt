import 'dart:async';

import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/google_places_service.dart';
import 'current_location_map_screen.dart';
import '../application/home_notifier.dart';
import '../application/home_state.dart';

/// Screen 14: HOME-06-LOCATION-SELECTOR
///
/// Service zone switcher and address selector matching Screen 14 Design Board
/// and Specification §13.3. Supports modal sheet and standalone presentation.
class LocationSelectorModal extends ConsumerStatefulWidget {
  const LocationSelectorModal({super.key});

  /// Presents the Location Selector Modal as an interactive bottom sheet.
  static Future<ServiceAreaDto?> show(BuildContext context) {
    return showModalBottomSheet<ServiceAreaDto>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationSelectorModal(),
    );
  }

  @override
  ConsumerState<LocationSelectorModal> createState() =>
      _LocationSelectorModalState();
}

class _LocationSelectorModalState extends ConsumerState<LocationSelectorModal> {
  int _selectedTab = 0; // 0: Current location, 1: Search address
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ServiceAreaDto? _selectedArea;
  Timer? _debounceTimer;
  String? _placesSessionToken;
  List<PlacePrediction> _livePredictions = [];
  bool _isLoadingPredictions = false;

  @override
  void initState() {
    super.initState();
    _selectedArea = ref.read(homeNotifierProvider).currentLocation;
    _placesSessionToken = GooglePlacesService.generateSessionToken();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeState = ref.watch(homeNotifierProvider);
    final sheetBg = isDark ? const Color(0xFF141B17) : Colors.white;

    // Filter service areas and saved places based on search input
    final filteredAreas = _searchQuery.isEmpty
        ? homeState.serviceAreas
        : homeState.serviceAreas
            .where((a) =>
                a.name.toLowerCase().contains(_searchQuery) ||
                a.state.toLowerCase().contains(_searchQuery) ||
                a.displayName.toLowerCase().contains(_searchQuery))
            .toList();

    final filteredPlaces = _searchQuery.isEmpty
        ? homeState.savedPlaces
        : homeState.savedPlaces
            .where((p) =>
                p.label.toLowerCase().contains(_searchQuery) ||
                p.address.toLowerCase().contains(_searchQuery))
            .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Select your location',
                    style: GVTypography.h2.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : GVColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color:
                          isDark ? GVColors.neutral400 : GVColors.textSecondary,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Segmented Tab Switcher: [Current location] | [Search address]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSegmentedTabs(isDark),
            ),
            const SizedBox(height: 16),

            // Search Address Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(isDark),
            ),
            const SizedBox(height: 16),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // GPS Tile
                  _buildGpsOptionTile(isDark, homeState),
                  const SizedBox(height: 20),

                  // Live Google Places Address Predictions
                  if (_livePredictions.isNotEmpty) ...[
                    Text(
                      'Address suggestions',
                      style: GVTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : GVColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._livePredictions.map(
                      (prediction) => _buildPredictionTile(isDark, prediction),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Saved Locations Section
                  if (filteredPlaces.isNotEmpty) ...[
                    Text(
                      'Saved locations',
                      style: GVTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : GVColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...filteredPlaces.map(
                      (place) => _buildSavedPlaceTile(isDark, place, homeState),
                    ),
                    _buildAddNewAddressTile(isDark),
                    const SizedBox(height: 20),
                  ],

                  // Service Areas Section
                  Text(
                    'Service areas',
                    style: GVTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : GVColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...filteredAreas.map(
                    (area) => _buildServiceAreaTile(isDark, area),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom CTA: Confirm Location
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedArea != null
                      ? () {
                          ref
                              .read(homeNotifierProvider.notifier)
                              .selectLocation(_selectedArea!);
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop(_selectedArea);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GVColors.brandGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Confirm location',
                    style: GVTypography.buttonLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Segmented tabs matching Screen 14 design
  Widget _buildSegmentedTabs(bool isDark) {
    final containerBg =
        isDark ? const Color(0xFF1C2420) : GVColors.softBackground;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Current location',
              isSelected: _selectedTab == 0,
              isDark: isDark,
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: 'Search address',
              isSelected: _selectedTab == 1,
              isDark: isDark,
              onTap: () {
                setState(() => _selectedTab = 1);
                if (_searchController.text.isNotEmpty) {
                  _onSearchChanged(_searchController.text);
                } else {
                  _onSearchChanged('Shaganu');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2E3D35) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected && !isDark ? GVShadows.card : null,
        ),
        child: Center(
          child: Text(
            title,
            style: GVTypography.caption.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.white : GVColors.textPrimary)
                  : (isDark ? GVColors.neutral400 : GVColors.textSecondary),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Address Search TextField
  Widget _buildSearchBar(bool isDark) {
    final fieldBg = isDark ? const Color(0xFF1C2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      style: TextStyle(color: isDark ? Colors.white : GVColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search for an address',
        hintStyle: TextStyle(
          color: isDark ? GVColors.neutral500 : GVColors.neutral400,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
          size: 20,
        ),
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
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null),
        filled: true,
        fillColor: fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GVColors.brandGreen, width: 1.5),
        ),
      ),
    );
  }

  /// Live Google Places Prediction Item
  Widget _buildPredictionTile(bool isDark, PlacePrediction prediction) {
    final tileBg = isDark ? const Color(0xFF1C2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;
    final isSelected = _selectedArea?.name == prediction.mainText;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: tileBg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            final placesService = ref.read(googlePlacesServiceProvider);
            LocationDto? loc;
            try {
              loc = await placesService.getPlaceDetails(
                prediction.placeId,
                sessionToken: _placesSessionToken,
              );
            } catch (_) {}

            final area = ServiceAreaDto(
              id: 'place_${prediction.placeId}',
              name: loc?.label ?? prediction.mainText,
              state: loc?.state ?? 'Ogun',
              status: ServiceAreaStatus.fullySupported,
              statusDescription: 'Operating Service Area',
              availableServices: const [
                ServiceCode.instantRide,
                ServiceCode.instantDelivery,
                ServiceCode.scheduledRide,
                ServiceCode.scheduledPickup,
              ],
            );
            setState(() {
              _selectedArea = area;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? GVColors.brandGreen : borderColor,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF131A16)
                        : GVColors.softBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: GVColors.brandGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediction.mainText,
                        style: GVTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : GVColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prediction.secondaryText.isNotEmpty
                            ? prediction.secondaryText
                            : prediction.description,
                        style: GVTypography.caption.copyWith(
                          color: isDark
                              ? GVColors.neutral400
                              : GVColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.north_west_rounded,
                  color:
                      isSelected ? GVColors.brandGreen : GVColors.neutral400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Use current location (Detected via GPS) Tile
  Widget _buildGpsOptionTile(bool isDark, HomeState homeState) {
    final tileBg = isDark ? const Color(0xFF1C2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Material(
      color: tileBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _openCurrentLocationMap(homeState),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: GVColors.brandGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: GVColors.brandGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use current location',
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : GVColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Detected via GPS',
                      style: GVTypography.caption.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? GVColors.neutral500 : GVColors.neutral400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Saved Location row item (Home / Work)
  Widget _buildSavedPlaceTile(
    bool isDark,
    SavedPlaceDto place,
    HomeState homeState,
  ) {
    final tileBg = isDark ? const Color(0xFF1C2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    IconData placeIcon;
    switch (place.type) {
      case SavedPlaceType.home:
        placeIcon = Icons.home_rounded;
        break;
      case SavedPlaceType.work:
        placeIcon = Icons.work_rounded;
        break;
      default:
        placeIcon = Icons.location_on_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: tileBg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            // Map saved place to closest service area if matching
            final matchingArea = homeState.serviceAreas.firstWhere(
              (a) => place.address.toLowerCase().contains(a.name.toLowerCase()),
              orElse: () => homeState.currentLocation,
            );
            setState(() => _selectedArea = matchingArea);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF131A16)
                        : GVColors.softBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    placeIcon,
                    color: isDark ? Colors.white70 : GVColors.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.label,
                        style: GVTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : GVColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        place.address,
                        style: GVTypography.caption.copyWith(
                          color: isDark
                              ? GVColors.neutral400
                              : GVColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? GVColors.neutral500 : GVColors.neutral400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "+ Add new address" action
  Widget _buildAddNewAddressTile(bool isDark) {
    return InkWell(
      onTap: _showAddAddressDialog,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              size: 20,
              color: GVColors.brandGreen,
            ),
            const SizedBox(width: 8),
            Text(
              'Add new address',
              style: GVTypography.label.copyWith(
                color: GVColors.brandGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Service Area row item with Radio and Live Status Badge
  Widget _buildServiceAreaTile(bool isDark, ServiceAreaDto area) {
    final isSelected = area.id == _selectedArea?.id;
    final isFullySupported = area.status == ServiceAreaStatus.fullySupported;

    final tileBg = isSelected
        ? GVColors.brandGreen.withValues(alpha: 0.08)
        : (isDark ? const Color(0xFF1C2420) : Colors.white);
    final borderColor = isSelected
        ? GVColors.brandGreen
        : (isDark ? const Color(0xFF2E3D35) : GVColors.border);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: tileBg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedArea = area;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? GVColors.brandGreen
                          : (isDark ? Colors.white38 : GVColors.neutral400),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: GVColors.brandGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    area.displayName,
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isDark ? Colors.white : GVColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Status pill badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isFullySupported
                        ? GVColors.brandGreen.withValues(alpha: 0.15)
                        : Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    area.effectiveStatusDescription,
                    style: GVTypography.caption.copyWith(
                      color: isFullySupported
                          ? GVColors.brandGreen
                          : Colors.amber.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? GVColors.neutral500 : GVColors.neutral400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Opens the Live Google Map screen for real-time GPS coordinate selection.
  Future<void> _openCurrentLocationMap(HomeState homeState) async {
    final loc = await CurrentLocationMapScreen.open(context);
    if (loc != null && mounted) {
      final matchingArea = homeState.serviceAreas.firstWhere(
        (a) =>
            a.name.toLowerCase().contains('shaganu') ||
            a.state.toLowerCase().contains('ogun'),
        orElse: () => homeState.currentLocation,
      );
      setState(() => _selectedArea = matchingArea);
      ref.read(homeNotifierProvider.notifier).selectLocation(matchingArea);

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(matchingArea);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Current location confirmed: ${loc.label ?? loc.address} (${loc.latitude.toStringAsFixed(4)}°N, ${loc.longitude.toStringAsFixed(4)}°E)',
          ),
          backgroundColor: GVColors.brandGreen,
        ),
      );
    }
  }

  /// Prompt dialog to add a new custom saved place
  void _showAddAddressDialog() {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Add New Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(labelText: 'Label (e.g. Gym, School)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Street Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final label = labelCtrl.text.trim();
              final address = addressCtrl.text.trim();
              if (label.isNotEmpty && address.isNotEmpty) {
                ref.read(homeNotifierProvider.notifier).addSavedPlace(
                      SavedPlaceDto(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        label: label,
                        address: address,
                        type: SavedPlaceType.custom,
                        latitude: 6.8403,
                        longitude: 3.6487,
                      ),
                    );
                Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
