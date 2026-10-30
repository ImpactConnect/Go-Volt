import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/booking_notifier.dart';

/// Screen 4 & Screen 6 — Map Location Picker for Pickup and Destination
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
  late LocationDto _currentSelectedLocation;

  static const LocationDto _defaultPickup = LocationDto(
    latitude: 6.4253,
    longitude: 3.4283,
    address: 'Adetokunbo Ademola St, Victoria Island, Lagos',
    label: 'Eko Hotel and Suites',
  );

  static const LocationDto _defaultDestination = LocationDto(
    latitude: 6.4358,
    longitude: 3.4682,
    address: 'Lekki, Lagos',
    label: 'Palms Mall',
  );

  @override
  void initState() {
    super.initState();
    final booking = ref.read(bookingNotifierProvider);
    if (widget.initialLocation != null) {
      _currentSelectedLocation = widget.initialLocation!;
    } else if (widget.isPickup) {
      _currentSelectedLocation =
          booking.pickupLocation ?? _defaultPickup;
    } else {
      _currentSelectedLocation =
          booking.dropoffLocation ?? _defaultDestination;
    }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinColor =
        widget.isPickup ? GVColors.brandGreen : GVColors.error;
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
          // Simulated Interactive Map Canvas
          Positioned.fill(
            child: _MapCanvas(
              isDark: isDark,
              isPickup: widget.isPickup,
            ),
          ),

          // Center Pin with Floating Callout Bubble
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentSelectedLocation.label ??
                            _currentSelectedLocation.address.split(',').first,
                        style: GVTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? Colors.white : GVColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Small callout triangle
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
                const SizedBox(height: 38), // Offset for pin point
              ],
            ),
          ),

          // User GPS Blue Dot (if pickup)
          if (widget.isPickup)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.42,
              top: MediaQuery.of(context).size.height * 0.52,
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

          // Top Action Controls (Back & GPS Recenter)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FloatingCircularButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                    isDark: isDark,
                  ),
                  Row(
                    children: [
                      _FloatingCircularButton(
                        icon: Icons.my_location_rounded,
                        tooltip: 'Recenter GPS',
                        onTap: () {
                          setState(() {
                            if (widget.isPickup) {
                              _currentSelectedLocation = _defaultPickup;
                            } else {
                              _currentSelectedLocation = _defaultDestination;
                            }
                          });
                        },
                        isDark: isDark,
                      ),
                      if (!widget.isPickup) ...[
                        const SizedBox(width: GVSpacing.sm),
                        _FloatingCircularButton(
                          icon: Icons.layers_outlined,
                          tooltip: 'Map layers',
                          onTap: () {},
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Confirmation Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                GVSpacing.lg,
                GVSpacing.lg,
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
                      titleText,
                      style: GVTypography.caption.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.sm),

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
                                _currentSelectedLocation.address,
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
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: 'Edit address',
                        ),
                      ],
                    ),
                    const SizedBox(height: GVSpacing.lg),

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

/// Stylized Lagos map canvas preview
class _MapCanvas extends StatelessWidget {
  const _MapCanvas({required this.isDark, required this.isPickup});
  final bool isDark;
  final bool isPickup;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isDark ? const Color(0xFF111814) : const Color(0xFFE8ECE9);
    final streetColor =
        isDark ? const Color(0xFF1E2822) : const Color(0xFFFCFDFD);
    final waterColor =
        isDark ? const Color(0xFF0D1D22) : const Color(0xFFD0E3EA);

    return CustomPaint(
      painter: _MapCanvasPainter(
        bgColor: bgColor,
        streetColor: streetColor,
        waterColor: waterColor,
        isPickup: isPickup,
      ),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  _MapCanvasPainter({
    required this.bgColor,
    required this.streetColor,
    required this.waterColor,
    required this.isPickup,
  });

  final Color bgColor;
  final Color streetColor;
  final Color waterColor;
  final bool isPickup;

  @override
  void paint(Canvas canvas, Size size) {
    // Fill land background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    // Lagoon / Ocean Water Bodies (Lagos Island / Lekki Coastline)
    final waterPaint = Paint()..color = waterColor;
    final waterPath = Path()
      ..moveTo(0, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.22,
        size.width,
        size.height * 0.12,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Major Arterial Streets
    final streetPaint = Paint()
      ..color = streetColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final secondaryStreetPaint = Paint()
      ..color = streetColor.withValues(alpha: 0.8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Grid lines simulating Victoria Island / Lekki Expressway
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.42),
      streetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.65),
      Offset(size.width, size.height * 0.70),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.2),
      Offset(size.width * 0.30, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.68, size.height * 0.2),
      Offset(size.width * 0.72, size.height),
      secondaryStreetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) => false;
}
