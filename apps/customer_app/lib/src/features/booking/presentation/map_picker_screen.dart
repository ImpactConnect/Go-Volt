import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/presentation/widgets/live_google_map_view.dart';
import '../../../core/services/gps_location_service.dart';
import '../application/booking_notifier.dart';

/// Screen 4 & Screen 6 — Map Location Picker for Pickup and Destination.
/// Supports exact GPS pin dropping, real-time GPS detection, and landmark snapping.
class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({
    super.key,
    this.isPickup = true,
    this.initialLocation,
  });

  final bool isPickup;
  final LocationDto? initialLocation;

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  final GlobalKey<LiveGoogleMapViewState> _mapKey = GlobalKey();
  late LocationDto _currentSelectedLocation;
  bool _isLocating = false;
  late final List<LocationDto> _landmarks;

  static const LocationDto _defaultFallback = LocationDto(
    latitude: GpsLocationService.defaultLat,
    longitude: GpsLocationService.defaultLng,
    address: 'Central Roundabout, Shaganu, Ogun State',
    label: 'Shaganu Central',
  );

  @override
  void initState() {
    super.initState();
    _landmarks = GpsLocationService.getOperatingLandmarks();
    final booking = ref.read(bookingNotifierProvider);
    if (widget.initialLocation != null) {
      _currentSelectedLocation = widget.initialLocation!;
    } else if (widget.isPickup) {
      _currentSelectedLocation = booking.pickupLocation ?? _defaultFallback;
    } else {
      _currentSelectedLocation = booking.dropoffLocation ?? _defaultFallback;
    }
  }

  Future<void> _fetchCurrentGps() async {
    setState(() => _isLocating = true);
    try {
      final detected = await GpsLocationService.getCurrentPosition(
        label: widget.isPickup ? 'My Current Location' : 'Destination Pin',
      );
      if (mounted) {
        setState(() {
          _currentSelectedLocation = detected;
        });
        _mapKey.currentState?.animateTo(
          LatLng(detected.latitude, detected.longitude),
          zoom: 16.5,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'GPS coordinates acquired: ${detected.latitude.toStringAsFixed(4)}°N, ${detected.longitude.toStringAsFixed(4)}°E',
            ),
            backgroundColor: GVColors.brandGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  LocationDto? _findClosestLandmark(double lat, double lng) {
    for (final lm in _landmarks) {
      final dLat = (lm.latitude - lat).abs();
      final dLng = (lm.longitude - lng).abs();
      if (dLat < 0.0015 && dLng < 0.0015) {
        return lm;
      }
    }
    return null;
  }

  void _selectLandmark(LocationDto landmark) {
    setState(() {
      _currentSelectedLocation = landmark;
    });
    _mapKey.currentState?.animateTo(
      LatLng(landmark.latitude, landmark.longitude),
      zoom: 16.5,
    );
  }

  void _onPositionChanged(LatLng newCoord) {
    setState(() {
      final closest =
          _findClosestLandmark(newCoord.latitude, newCoord.longitude);
      if (closest != null) {
        _currentSelectedLocation = LocationDto(
          latitude: newCoord.latitude,
          longitude: newCoord.longitude,
          label: closest.label,
          address: closest.address,
        );
      } else {
        _currentSelectedLocation = LocationDto(
          latitude: double.parse(newCoord.latitude.toStringAsFixed(5)),
          longitude: double.parse(newCoord.longitude.toStringAsFixed(5)),
          label: widget.isPickup
              ? 'Selected Pickup Point'
              : 'Selected Destination',
          address:
              '${newCoord.latitude.toStringAsFixed(4)}°N, ${newCoord.longitude.toStringAsFixed(4)}°E, Shaganu, Ogun',
        );
      }
    });
  }

  void _onConfirm() {
    final notifier = ref.read(bookingNotifierProvider.notifier);
    if (widget.isPickup) {
      notifier.setPickupLocation(_currentSelectedLocation);
    } else {
      notifier.setDropoffLocation(_currentSelectedLocation);
    }
    Navigator.of(context).pop(_currentSelectedLocation);
  }

  void _editAddress() {
    final controller = TextEditingController(
      text: _currentSelectedLocation.label ?? _currentSelectedLocation.address,
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Location / Landmark Label'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Landmark or Destination Name',
            hintText: 'e.g. Near Shaganu Market Gate 2',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _currentSelectedLocation = _currentSelectedLocation.copyWith(
                    label: controller.text.trim(),
                  );
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinColor = widget.isPickup ? GVColors.brandGreen : GVColors.error;
    final titleText = widget.isPickup
        ? 'Selected pickup location'
        : 'Selected destination';
    final buttonLabel = widget.isPickup
        ? 'Confirm pickup location'
        : 'Confirm destination';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Live Google Map with Animated Center Crosshair Pin
          Positioned.fill(
            child: LiveGoogleMapView(
              key: _mapKey,
              initialLatitude: _currentSelectedLocation.latitude,
              initialLongitude: _currentSelectedLocation.longitude,
              initialZoom: 16.0,
              isPicker: true,
              pickerTitle:
                  widget.isPickup ? 'Pick-up point' : 'Destination point',
              pickerAddress: _currentSelectedLocation.label ??
                  _currentSelectedLocation.address,
              pinColor: pinColor,
              showZoomControls: true,
              showMyLocationButton: true,
              onMyLocationTapped: _fetchCurrentGps,
              onPositionChanged: _onPositionChanged,
            ),
          ),

          // Top Action Controls (Back & Header Pill)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.sm,
              ),
              child: Row(
                children: [
                  _FloatingCircularButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2822) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
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
                            decoration: BoxDecoration(
                              color: pinColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.isPickup
                                  ? 'Set your pickup spot'
                                  : 'Set your destination',
                              style: GVTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : GVColors.textPrimary,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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

          // Hint badge near top center
          Positioned(
            top: 72,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pan_tool_alt_rounded,
                      size: 15,
                      color: pinColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Drag map to adjust ${widget.isPickup ? 'pickup' : 'destination'} point',
                      style: GVTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : GVColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Sheet: Landmark Chips + Address Details + Confirm
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                GVSpacing.lg,
                GVSpacing.md,
                GVSpacing.lg,
                GVSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A16) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
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
                    // Drag notch
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick Landmark Chips
                    Text(
                      'Nearby Landmarks:',
                      style: GVTypography.caption.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _landmarks.length,
                        separatorBuilder: (c, i) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final l = _landmarks[index];
                          final isSelected =
                              _currentSelectedLocation.label == l.label;
                          return ChoiceChip(
                            label: Text(
                              l.label ?? l.address,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? GVColors.deepGreen
                                    : (isDark
                                        ? Colors.white70
                                        : GVColors.textPrimary),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: GVColors.brandGreen,
                            backgroundColor: isDark
                                ? const Color(0xFF1E2822)
                                : GVColors.softBackground,
                            onSelected: (_) => _selectLandmark(l),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Subtitle
                    Text(
                      titleText,
                      style: GVTypography.caption.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xs),

                    // Location Info Row
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pinColor.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: pinColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: GVSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentSelectedLocation.label ??
                                    _currentSelectedLocation.address
                                        .split(',')
                                        .first,
                                style: GVTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_currentSelectedLocation.address} (${_currentSelectedLocation.latitude.toStringAsFixed(4)}, ${_currentSelectedLocation.longitude.toStringAsFixed(4)})',
                                style: GVTypography.caption.copyWith(
                                  color: isDark
                                      ? GVColors.neutral400
                                      : GVColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: isDark
                              ? GVColors.neutral400
                              : GVColors.neutral600,
                          onPressed: _editAddress,
                          tooltip: 'Edit label or landmark name',
                        ),
                      ],
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Confirm Action Button
                    GVPrimaryButton(
                      label: buttonLabel,
                      onPressed: _onConfirm,
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

class _FloatingCircularButton extends StatelessWidget {
  const _FloatingCircularButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF1E2621) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        color: isDark ? Colors.white : GVColors.textPrimary,
        onPressed: onTap,
      ),
    );
  }
}
