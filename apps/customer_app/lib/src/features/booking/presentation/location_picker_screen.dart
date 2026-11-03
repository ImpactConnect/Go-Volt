import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/gps_location_service.dart';
import '../../home/application/home_notifier.dart';
import '../../home/presentation/create_destinations_pop_sheet.dart';
import '../application/booking_notifier.dart';
import 'map_picker_screen.dart';

enum _PickerMode {
  dualEntry, // Screen 2
  searchPickup, // Screen 3
  searchDestination, // Screen 5
}

/// Screen 2, Screen 3 & Screen 5 — Location Picker & Dual Route Entry
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key, this.initialMode});

  final String? initialMode;

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  late _PickerMode _mode;
  final TextEditingController _searchController = TextEditingController();

  static const LocationDto _defaultCurrentLocation = LocationDto(
    latitude: GpsLocationService.defaultLat,
    longitude: GpsLocationService.defaultLng,
    address: 'Central Roundabout, Shaganu, Ogun State',
    label: 'Shaganu Central',
  );

  static final List<LocationDto> _pickupSuggestions =
      GpsLocationService.getOperatingLandmarks();

  static final List<LocationDto> _destinationSuggestions =
      GpsLocationService.getOperatingLandmarks();

  @override
  void initState() {
    super.initState();
    if (widget.initialMode == 'pickup') {
      _mode = _PickerMode.searchPickup;
      _searchController.text = 'Eko Hotel';
    } else if (widget.initialMode == 'destination') {
      _mode = _PickerMode.searchDestination;
      _searchController.text = 'Palms Mall';
    } else {
      _mode = _PickerMode.dualEntry;
    }

    // Default pickup to current location if unset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final booking = ref.read(bookingNotifierProvider);
      if (booking.pickupLocation == null) {
        ref
            .read(bookingNotifierProvider.notifier)
            .setPickupLocation(_defaultCurrentLocation);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelectPickup(LocationDto location) {
    ref.read(bookingNotifierProvider.notifier).setPickupLocation(location);
    setState(() {
      _mode = _PickerMode.dualEntry;
      _searchController.clear();
    });
  }

  void _onSelectDestination(LocationDto location) {
    ref.read(bookingNotifierProvider.notifier).setDropoffLocation(location);
    setState(() {
      _mode = _PickerMode.dualEntry;
      _searchController.clear();
    });
  }

  Future<void> _openMapPicker({required bool isPickup}) async {
    final result = await Navigator.of(context).push<LocationDto>(
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(isPickup: isPickup),
      ),
    );

    if (result != null && mounted) {
      if (isPickup) {
        _onSelectPickup(result);
      } else {
        _onSelectDestination(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (_mode) {
      case _PickerMode.searchPickup:
        return _buildSearchScreen(
          isDark: isDark,
          isPickup: true,
          suggestions: _pickupSuggestions,
          onSelect: _onSelectPickup,
        );
      case _PickerMode.searchDestination:
        return _buildSearchScreen(
          isDark: isDark,
          isPickup: false,
          suggestions: _destinationSuggestions,
          onSelect: _onSelectDestination,
        );
      case _PickerMode.dualEntry:
        return _buildDualEntryScreen(isDark: isDark);
    }
  }

  /// Screen 2 — Dual Entry (Pickup & Destination)
  Widget _buildDualEntryScreen({required bool isDark}) {
    final booking = ref.watch(bookingNotifierProvider);
    final pickupLabel =
        booking.pickupLocation?.label ??
        booking.pickupLocation?.address ??
        'Pickup location';
    final destinationLabel =
        booking.dropoffLocation?.label ??
        booking.dropoffLocation?.address ??
        'Where are you going?';

    final hasDestination = booking.dropoffLocation != null;
    final canContinue =
        booking.pickupLocation != null && booking.dropoffLocation != null;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Simulated Map Background (Screen 2 top half)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.40,
            child: _MapHeaderPreview(isDark: isDark),
          ),

          // Top Floating Navigation Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircularIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                    isDark: isDark,
                  ),
                  _CircularIconButton(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Current location',
                    onTap: () {
                      ref
                          .read(bookingNotifierProvider.notifier)
                          .setPickupLocation(_defaultCurrentLocation);
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Route Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: MediaQuery.of(context).size.height * 0.32,
            child: Container(
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
                child: ListView(
                  padding: const EdgeInsets.all(GVSpacing.lg),
                  children: [
                    // Sheet Title
                    Text(
                      'Enter your locations',
                      style: GVTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Dual Location Input Box
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A221E)
                            : GVColors.softBackground,
                        borderRadius: GVBorderRadius.cardRadius,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2E3D35)
                              : GVColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Pickup Row
                          InkWell(
                            onTap: () {
                              setState(() {
                                _mode = _PickerMode.searchPickup;
                                _searchController.text =
                                    booking.pickupLocation?.label ??
                                    'Eko Hotel';
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: GVColors.brandGreen,
                                  ),
                                ),
                                const SizedBox(width: GVSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pickup location',
                                        style: GVTypography.caption.copyWith(
                                          color: isDark
                                              ? GVColors.neutral400
                                              : GVColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        pickupLabel,
                                        style: GVTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : GVColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  color: isDark
                                      ? GVColors.neutral400
                                      : GVColors.neutral600,
                                  onPressed: () {
                                    ref
                                        .read(bookingNotifierProvider.notifier)
                                        .clearPickupLocation();
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Vertical Connector
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const SizedBox(width: 6),
                                Container(
                                  width: 2,
                                  height: 20,
                                  color: isDark
                                      ? GVColors.neutral600
                                      : GVColors.neutral300,
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Divider(
                                    color: isDark
                                        ? const Color(0xFF2E3D35)
                                        : GVColors.border,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Destination Row
                          InkWell(
                            onTap: () {
                              setState(() {
                                _mode = _PickerMode.searchDestination;
                                _searchController.text =
                                    booking.dropoffLocation?.label ??
                                    'Palms Mall';
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: GVColors.error,
                                  ),
                                ),
                                const SizedBox(width: GVSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Destination',
                                        style: GVTypography.caption.copyWith(
                                          color: isDark
                                              ? GVColors.neutral400
                                              : GVColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        destinationLabel,
                                        style: GVTypography.bodyMedium.copyWith(
                                          fontWeight: hasDestination
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          color: hasDestination
                                              ? (isDark
                                                    ? Colors.white
                                                    : GVColors.textPrimary)
                                              : (isDark
                                                    ? GVColors.neutral500
                                                    : GVColors.neutral400),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.add,
                                  size: 20,
                                  color: isDark
                                      ? GVColors.neutral400
                                      : GVColors.neutral600,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // "Use current location" Quick Action
                    InkWell(
                      onTap: () async {
                        final gpsPos =
                            await GpsLocationService.getCurrentPosition();
                        ref
                            .read(bookingNotifierProvider.notifier)
                            .setPickupLocation(gpsPos);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'GPS detected: ${gpsPos.latitude.toStringAsFixed(4)}°N, ${gpsPos.longitude.toStringAsFixed(4)}°E',
                              ),
                              backgroundColor: GVColors.brandGreen,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: GVColors.brandGreen.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                              child: const Icon(
                                Icons.near_me_rounded,
                                color: GVColors.brandGreen,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: GVSpacing.md),
                            Text(
                              'Use current location',
                              style: GVTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: GVColors.brandGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: GVColors.divider),
                    const SizedBox(height: GVSpacing.sm),

                    // Saved places Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saved places',
                          style: GVTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : GVColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GVSpacing.xs),

                    // Dynamic Saved Places List
                    for (final place
                        in ref.watch(homeNotifierProvider).savedPlaces)
                      _SavedPlaceTile(
                        icon: place.isHome
                            ? Icons.home_rounded
                            : (place.isWork
                                  ? Icons.work_rounded
                                  : Icons.place_rounded),
                        title: place.label,
                        subtitle: place.address,
                        onTap: () {
                          _onSelectDestination(
                            LocationDto(
                              latitude: place.latitude,
                              longitude: place.longitude,
                              address: place.address,
                              label: place.label,
                            ),
                          );
                        },
                        isDark: isDark,
                      ),

                    // Add new location tile
                    _SavedPlaceTile(
                      icon: Icons.add_rounded,
                      title: 'Add new location',
                      subtitle: 'Save your frequent destinations',
                      onTap: () => CreateDestinationsPopSheet.show(context),
                      isDark: isDark,
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Continue Button
                    GVPrimaryButton(
                      label: 'Continue',
                      onPressed: canContinue
                          ? () => context.push(AppRoutes.rideBooking)
                          : null,
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

  /// Screen 3 & Screen 5 — Autocomplete Search Screen
  Widget _buildSearchScreen({
    required bool isDark,
    required bool isPickup,
    required List<LocationDto> suggestions,
    required ValueChanged<LocationDto> onSelect,
  }) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? suggestions
        : suggestions.where((s) {
            return (s.label?.toLowerCase().contains(query) ?? false) ||
                s.address.toLowerCase().contains(query);
          }).toList();

    final pinColor = isPickup ? GVColors.brandGreen : GVColors.error;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131A16) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF131A16) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : GVColors.textPrimary,
          ),
          onPressed: () {
            setState(() => _mode = _PickerMode.dualEntry);
          },
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: GVSpacing.md),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A221E) : GVColors.softBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
              ),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: GVTypography.bodyMedium.copyWith(
                color: isDark ? Colors.white : GVColors.textPrimary,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: isPickup
                    ? 'Enter pickup location'
                    : 'Where are you going?',
                hintStyle: GVTypography.bodyMedium.copyWith(
                  color: isDark ? GVColors.neutral500 : GVColors.textDisabled,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: GVSpacing.md,
                  vertical: 10,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: GVSpacing.sm),
        children: [
          if (isPickup) ...[
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GVColors.brandGreen.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: GVColors.brandGreen,
                  size: 20,
                ),
              ),
              title: Text(
                'Use current location',
                style: GVTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: GVColors.brandGreen,
                ),
              ),
              subtitle: Text(
                'Detected via GPS sensor',
                style: GVTypography.caption.copyWith(
                  color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final pos = await GpsLocationService.getCurrentPosition();
                onSelect(pos);
              },
            ),
            const Divider(color: GVColors.divider),
          ],

          // "Set location on map" Action (Screens 4 & 6 Entrypoint)
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pinColor.withValues(alpha: 0.12),
              ),
              child: Icon(Icons.map_outlined, color: pinColor, size: 20),
            ),
            title: Text(
              'Set location on map',
              style: GVTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: pinColor,
              ),
            ),
            subtitle: Text(
              'Pin point your exact spot on the map',
              style: GVTypography.caption.copyWith(
                color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _openMapPicker(isPickup: isPickup),
          ),
          const Divider(color: GVColors.divider),

          // Autocomplete suggestions
          ...filtered.map((location) {
            return ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF243029)
                      : GVColors.softBackground,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: pinColor,
                  size: 20,
                ),
              ),
              title: Text(
                location.label ?? location.address.split(',').first,
                style: GVTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : GVColors.textPrimary,
                ),
              ),
              subtitle: Text(
                location.address,
                style: GVTypography.caption.copyWith(
                  color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(
                Icons.north_west_rounded,
                size: 16,
                color: GVColors.neutral400,
              ),
              onTap: () => onSelect(location),
            );
          }),
        ],
      ),
    );
  }
}

class _SavedPlaceTile extends StatelessWidget {
  const _SavedPlaceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF243029)
                    : const Color(0xFF1E2822),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
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
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 18),
              color: isDark ? GVColors.neutral500 : GVColors.neutral400,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({
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
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
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

class _MapHeaderPreview extends StatelessWidget {
  const _MapHeaderPreview({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF111814) : const Color(0xFFE8ECE9),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _HeaderMapPainter(isDark: isDark),
          ),
          // Center pickup marker on map
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.location_on_rounded,
                size: 32,
                color: GVColors.brandGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMapPainter extends CustomPainter {
  const _HeaderMapPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final streetColor = isDark
        ? const Color(0xFF1E2822)
        : const Color(0xFFFCFDFD);
    final streetPaint = Paint()
      ..color = streetColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      streetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeaderMapPainter oldDelegate) => false;
}
