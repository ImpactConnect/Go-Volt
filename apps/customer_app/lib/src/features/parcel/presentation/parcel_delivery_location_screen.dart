import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 6 — Delivery Location: Full-screen interactive map with red destination pin at Lekki (Palms Mall)
/// and floating bottom sheet confirming dropoff destination and saved places.
class ParcelDeliveryLocationScreen extends ConsumerStatefulWidget {
  const ParcelDeliveryLocationScreen({super.key});

  @override
  ConsumerState<ParcelDeliveryLocationScreen> createState() =>
      _ParcelDeliveryLocationScreenState();
}

class _ParcelDeliveryLocationScreenState
    extends ConsumerState<ParcelDeliveryLocationScreen> {
  static const LocationDto _defaultDestination = LocationDto(
    latitude: 6.4357,
    longitude: 3.4418,
    address: 'Lekki, Lagos',
    label: 'Palms Mall',
  );

  static const List<LocationDto> _savedPlaces = [
    LocationDto(
      latitude: 6.4281,
      longitude: 3.4219,
      address: 'Victoria Island, Lagos',
      label: 'Home',
    ),
    LocationDto(
      latitude: 6.4474,
      longitude: 3.4723,
      address: 'Lekki Phase 1, Lagos',
      label: 'Work',
    ),
    LocationDto(
      latitude: 6.4357,
      longitude: 3.4418,
      address: 'Tap to select a location',
      label: 'Choose on map',
    ),
  ];

  late LocationDto _currentLocation;

  @override
  void initState() {
    super.initState();
    final flowState = ref.read(parcelBookingNotifierProvider);
    _currentLocation = flowState.destinationLocation ?? _defaultDestination;
  }

  void _onConfirm() {
    ref
        .read(parcelBookingNotifierProvider.notifier)
        .setDestinationLocation(_currentLocation);

    if (GoRouter.maybeOf(context) != null) {
      context.push(AppRoutes.parcelReviewQuote);
    } else {
      Navigator.of(context).pushNamed(AppRoutes.parcelReviewQuote);
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
          'Edit Delivery Destination',
          style: GVTypography.h3.copyWith(
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Destination Address',
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
                    .setDestinationLocation(_currentLocation);
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
    final pinColor = GVColors.error;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Interactive Vector Map Canvas for Lekki Area
          Positioned.fill(
            child: _ParcelDestinationMapCanvas(
              isDark: isDark,
            ),
          ),

          // 2. Centered Red Pin Marker with Callout Bubble
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
                    _currentLocation.label ?? 'Palms Mall',
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

                // Map Pin Marker (Red for Destination)
                Icon(
                  Icons.location_on_rounded,
                  size: 44,
                  color: pinColor,
                ),
                const SizedBox(height: 38), // Center offset
              ],
            ),
          ),

          // 3. Top Action Navigation Bar
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
                        'Delivery location',
                        textAlign: TextAlign.center,
                        style: GVTypography.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _FloatingButton(
                          icon: Icons.my_location_rounded,
                          tooltip: 'Recenter GPS',
                          isDark: isDark,
                          onTap: () {
                            setState(() {
                              _currentLocation = _defaultDestination;
                            });
                            ref
                                .read(parcelBookingNotifierProvider.notifier)
                                .setDestinationLocation(_defaultDestination);
                          },
                        ),
                        const SizedBox(width: GVSpacing.xs),
                        _FloatingButton(
                          icon: Icons.layers_outlined,
                          tooltip: 'Layers',
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Floating Bottom Sheet
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
                      'Destination location',
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
                                _currentLocation.label ?? 'Palms Mall',
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

                    for (final place in _savedPlaces) ...[
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
                                .setDestinationLocation(place);
                          } else {
                            _showEditAddressDialog();
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

class _ParcelDestinationMapCanvas extends StatelessWidget {
  const _ParcelDestinationMapCanvas({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isDark ? const Color(0xFF111814) : const Color(0xFFE8ECE9);
    final streetColor =
        isDark ? const Color(0xFF1E2822) : const Color(0xFFFCFDFD);
    final waterColor =
        isDark ? const Color(0xFF0D1D22) : const Color(0xFFD0E3EA);

    return CustomPaint(
      painter: _ParcelDestinationMapPainter(
        bgColor: bgColor,
        streetColor: streetColor,
        waterColor: waterColor,
      ),
    );
  }
}

class _ParcelDestinationMapPainter extends CustomPainter {
  _ParcelDestinationMapPainter({
    required this.bgColor,
    required this.streetColor,
    required this.waterColor,
  });

  final Color bgColor;
  final Color streetColor;
  final Color waterColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    // Lekki Coastal Waterway
    final waterPaint = Paint()..color = waterColor;
    final waterPath = Path()
      ..moveTo(0, size.height * 0.12)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.20,
        size.width,
        size.height * 0.08,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    final streetPaint = Paint()
      ..color = streetColor
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final secondaryStreetPaint = Paint()
      ..color = streetColor.withValues(alpha: 0.8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Lekki-Epe expressway line & arterials
    canvas.drawLine(
      Offset(0, size.height * 0.48),
      Offset(size.width, size.height * 0.38),
      streetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.68),
      Offset(size.width, size.height * 0.60),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.18),
      Offset(size.width * 0.38, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.76, size.height * 0.15),
      Offset(size.width * 0.72, size.height),
      secondaryStreetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ParcelDestinationMapPainter oldDelegate) =>
      false;
}
