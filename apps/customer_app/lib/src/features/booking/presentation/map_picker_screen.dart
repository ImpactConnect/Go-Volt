import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void _onMapTapped(TapDownDetails details, Size mapSize) {
    // Map screen tap to approximate GPS offset around the current coordinate
    final dx = details.localPosition.dx - (mapSize.width / 2);
    final dy = details.localPosition.dy - (mapSize.height / 2);

    // Subtle coordinate offset: ~0.005 degrees per 100 pixels
    final newLat = _currentSelectedLocation.latitude - (dy * 0.00005);
    final newLng = _currentSelectedLocation.longitude + (dx * 0.00005);

    setState(() {
      _currentSelectedLocation = LocationDto(
        latitude: double.parse(newLat.toStringAsFixed(5)),
        longitude: double.parse(newLng.toStringAsFixed(5)),
        label: widget.isPickup ? 'Exact Pickup Pin' : 'Exact Delivery Pin',
        address:
            '${newLat.toStringAsFixed(4)}°N, ${newLng.toStringAsFixed(4)}°E (Map Pin)',
      );
    });
  }

  void _selectLandmark(LocationDto landmark) {
    setState(() {
      _currentSelectedLocation = landmark;
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

    final mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Interactive Map Canvas with Tap Handler
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) => _onMapTapped(details, mediaSize),
              behavior: HitTestBehavior.opaque,
              child: _MapCanvas(isDark: isDark, isPickup: widget.isPickup),
            ),
          ),

          // Center Pin with Floating Callout Bubble
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                CustomPaint(
                  size: const Size(12, 6),
                  painter: _BubbleTrianglePainter(
                    color: isDark ? const Color(0xFF1A221E) : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Icon(Icons.location_on_rounded, size: 44, color: pinColor),
                const SizedBox(height: 38),
              ],
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
                  _FloatingCircularButton(
                    icon: _isLocating
                        ? Icons.hourglass_top_rounded
                        : Icons.my_location_rounded,
                    tooltip: 'Locate me via GPS',
                    onTap: _isLocating ? () {} : _fetchCurrentGps,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // Hint badge near top center
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                    const Icon(
                      Icons.touch_app_rounded,
                      size: 16,
                      color: GVColors.brandGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap anywhere on map to set exact GPS pin',
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
                    GVPrimaryButton(label: buttonLabel, onPressed: _onConfirm),
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

/// Stylized map canvas preview
class _MapCanvas extends StatelessWidget {
  const _MapCanvas({required this.isDark, required this.isPickup});
  final bool isDark;
  final bool isPickup;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF111814) : const Color(0xFFE8ECE9);
    final streetColor = isDark
        ? const Color(0xFF1E2822)
        : const Color(0xFFFCFDFD);
    final waterColor = isDark
        ? const Color(0xFF0D1D22)
        : const Color(0xFFD0E3EA);

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
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    // River / waterway feature
    final waterPaint = Paint()..color = waterColor;
    final waterPath = Path()
      ..moveTo(0, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.25,
        size.width,
        size.height * 0.16,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    final streetPaint = Paint()
      ..color = streetColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final secondaryStreetPaint = Paint()
      ..color = streetColor.withValues(alpha: 0.8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Road network
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
