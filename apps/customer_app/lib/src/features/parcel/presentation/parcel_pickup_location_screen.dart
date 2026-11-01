import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/widgets/live_google_map_view.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/gps_location_service.dart';
import '../../booking/presentation/map_picker_screen.dart';
import '../../home/application/home_notifier.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 4 — Pickup Location: Full-screen interactive map with pickup pin at Victoria Island
/// and floating bottom sheet with confirmed pickup address and saved places.
class ParcelPickupLocationScreen extends ConsumerStatefulWidget {
  const ParcelPickupLocationScreen({super.key});

  @override
  ConsumerState<ParcelPickupLocationScreen> createState() =>
      _ParcelPickupLocationScreenState();
}

class _ParcelPickupLocationScreenState
    extends ConsumerState<ParcelPickupLocationScreen> {
  static const LocationDto _defaultPickup = LocationDto(
    latitude: GpsLocationService.defaultLat,
    longitude: GpsLocationService.defaultLng,
    address: 'Central Roundabout, Shaganu, Ogun State',
    label: 'Shaganu Central',
  );

  static const LocationDto _chooseOnMap = LocationDto(
    latitude: GpsLocationService.defaultLat,
    longitude: GpsLocationService.defaultLng,
    address: 'Pick exact GPS or landmark on map',
    label: 'Choose on map',
  );

  late LocationDto _currentLocation;

  @override
  void initState() {
    super.initState();
    final flowState = ref.read(parcelBookingNotifierProvider);
    _currentLocation = flowState.pickupLocation ?? _defaultPickup;
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<LocationDto>(
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          isPickup: true,
          initialLocation: _currentLocation,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentLocation = result;
      });
      ref
          .read(parcelBookingNotifierProvider.notifier)
          .setPickupLocation(result);
    }
  }

  void _onConfirm() {
    ref
        .read(parcelBookingNotifierProvider.notifier)
        .setPickupLocation(_currentLocation);
    if (GoRouter.maybeOf(context) != null) {
      context.push(AppRoutes.recipientDetails);
    } else {
      Navigator.of(context).pushNamed(AppRoutes.recipientDetails);
    }
  }

  void _showEditAddressDialog() {
    final controller = TextEditingController(text: _currentLocation.address);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2822) : GVColors.white,
        title: Text(
          'Edit Pickup Address',
          style: GVTypography.h3.copyWith(
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Pickup Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
            ),
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
                final newAddress = controller.text.trim();
                setState(() {
                  _currentLocation = _currentLocation.copyWith(
                    address: newAddress,
                    label: newAddress.split(',').first.trim(),
                  );
                });
                ref
                    .read(parcelBookingNotifierProvider.notifier)
                    .setPickupLocation(_currentLocation);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GVColors.brandGreen,
              foregroundColor: GVColors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinColor = GVColors.brandGreen;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Google Map
          Positioned.fill(
            child: LiveGoogleMapView(
              initialLatitude: _currentLocation.latitude,
              initialLongitude: _currentLocation.longitude,
              initialZoom: 16.0,
              isPicker: false,
              showZoomControls: true,
              showMyLocationButton: false,
              onPositionChanged: (newCoord) {
                setState(() {
                  _currentLocation = LocationDto(
                    latitude: double.parse(newCoord.latitude.toStringAsFixed(5)),
                    longitude: double.parse(newCoord.longitude.toStringAsFixed(5)),
                    address:
                        '${newCoord.latitude.toStringAsFixed(4)}°N, ${newCoord.longitude.toStringAsFixed(4)}°E',
                    label: 'Pickup Location',
                  );
                });
                ref.read(parcelBookingNotifierProvider.notifier).setPickupLocation(_currentLocation);
              },
            ),
          ),

          // 2. Centered Pin Marker with Callout Bubble
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Callout Speech Bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A221E) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    _currentLocation.label ?? 'Eko Hotel and Suites',
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : GVColors.textPrimary,
                    ),
                  ),
                ),
                // Small triangle indicator
                CustomPaint(
                  size: const Size(12, 6),
                  painter: _BubbleTrianglePainter(
                    color: isDark ? const Color(0xFF1A221E) : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),

                // Map Pin Marker
                Icon(
                  Icons.location_on_rounded,
                  size: 44,
                  color: pinColor,
                ),
                const SizedBox(height: 38), // Center offset
              ],
            ),
          ),

          // 3. User GPS Blue Dot
          Positioned(
            left: MediaQuery.of(context).size.width * 0.45,
            top: MediaQuery.of(context).size.height * 0.42,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.25),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
          ),

          // 4. Top Navigation Bar & Action Controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GVSpacing.md,
                  vertical: GVSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FloatingButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      tooltip: 'Back',
                      isDark: isDark,
                      onTap: () {
                        if (GoRouter.maybeOf(context) != null) {
                          context.pop();
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Pickup location',
                        textAlign: TextAlign.center,
                        style: GVTypography.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                    ),
                    _FloatingButton(
                      icon: Icons.my_location_rounded,
                      tooltip: 'Recenter GPS',
                      isDark: isDark,
                      onTap: () async {
                        final gpsPos =
                            await GpsLocationService.getCurrentPosition();
                        if (!mounted || !context.mounted) return;
                        setState(() {
                          _currentLocation = gpsPos;
                        });
                        ref
                            .read(parcelBookingNotifierProvider.notifier)
                            .setPickupLocation(gpsPos);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'GPS detected: ${gpsPos.latitude.toStringAsFixed(4)}°N, ${gpsPos.longitude.toStringAsFixed(4)}°E',
                            ),
                            backgroundColor: GVColors.brandGreen,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Floating Bottom Sheet
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
                    // Subtitle
                    Text(
                      'Pickup location',
                      style: GVTypography.caption.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.sm),

                    // Confirmed Address Row with Edit Pencil
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
                                _currentLocation.label ?? 'Eko Hotel and Suites',
                                style: GVTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _currentLocation.address,
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
                          color: GVColors.neutral500,
                          onPressed: _showEditAddressDialog,
                        ),
                      ],
                    ),

                    const SizedBox(height: GVSpacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: GVSpacing.sm),

                    // Saved Places Section
                    Text(
                      'Saved places',
                      style: GVTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xs),

                    for (final place in [
                      ...ref.watch(homeNotifierProvider).savedPlaces.map(
                            (p) => LocationDto(
                              latitude: p.latitude,
                              longitude: p.longitude,
                              address: p.address,
                              label: p.label,
                            ),
                          ),
                      _chooseOnMap,
                    ]) ...[
                      _ParcelSavedPlaceTile(
                        icon: place.label == 'Home'
                            ? Icons.home_rounded
                            : (place.label == 'Work'
                                ? Icons.work_rounded
                                : Icons.location_on_outlined),
                        title: place.label ?? 'Saved place',
                        subtitle: place.address,
                        isSelected: _currentLocation.label == place.label,
                        onTap: () {
                          if (place.label != 'Choose on map') {
                            setState(() {
                              _currentLocation = place;
                            });
                            ref
                                .read(parcelBookingNotifierProvider.notifier)
                                .setPickupLocation(place);
                          } else {
                            _openMapPicker();
                          }
                        },
                        isDark: isDark,
                      ),
                    ],

                    const SizedBox(height: GVSpacing.lg),

                    // Sticky Primary CTA
                    GVPrimaryButton(
                      label: 'Continue',
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

class _FloatingButton extends StatelessWidget {
  const _FloatingButton({
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
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2822) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: isDark ? Colors.white : GVColors.textPrimary,
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}

class _ParcelSavedPlaceTile extends StatelessWidget {
  const _ParcelSavedPlaceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.isSelected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: GVSpacing.xs,
          horizontal: GVSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? GVColors.brandGreen
                  : (isDark ? GVColors.neutral400 : GVColors.textSecondary),
              size: 20,
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isDark ? Colors.white : GVColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
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
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? GVColors.neutral500 : GVColors.neutral400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _BubbleTrianglePainter extends CustomPainter {
  const _BubbleTrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
