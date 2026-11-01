import 'dart:io';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Reusable production-grade Live Google Map widget.
/// Supports live camera navigation, zoom in/out controls, live GPS recenter,
/// center pin location selection, and custom markers/polylines.
class LiveGoogleMapView extends StatefulWidget {
  const LiveGoogleMapView({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialZoom = 15.5,
    this.markers = const {},
    this.polylines = const {},
    this.isPicker = false,
    this.pickerTitle,
    this.pickerAddress,
    this.pinColor,
    this.onPositionChanged,
    this.onMapCreated,
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onMyLocationTapped,
    this.showZoomControls = true,
    this.showMyLocationButton = true,
    this.mapPadding = EdgeInsets.zero,
  });

  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool isPicker;
  final String? pickerTitle;
  final String? pickerAddress;
  final Color? pinColor;
  final ValueChanged<LatLng>? onPositionChanged;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final ValueChanged<CameraPosition>? onCameraMove;
  final VoidCallback? onCameraIdle;
  final ValueChanged<LatLng>? onTap;
  final VoidCallback? onMyLocationTapped;
  final bool showZoomControls;
  final bool showMyLocationButton;
  final EdgeInsets mapPadding;

  @override
  State<LiveGoogleMapView> createState() => LiveGoogleMapViewState();
}

class LiveGoogleMapViewState extends State<LiveGoogleMapView> {
  GoogleMapController? _controller;
  late LatLng _currentCenter;
  double _currentZoom = 15.5;
  bool _isCameraMoving = false;

  @override
  void initState() {
    super.initState();
    _currentCenter = LatLng(widget.initialLatitude, widget.initialLongitude);
    _currentZoom = widget.initialZoom;
  }

  @override
  void didUpdateWidget(covariant LiveGoogleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLatitude != widget.initialLatitude ||
        oldWidget.initialLongitude != widget.initialLongitude) {
      _currentCenter = LatLng(widget.initialLatitude, widget.initialLongitude);
      animateTo(_currentCenter, zoom: widget.initialZoom);
    }
  }

  /// Public controller method to animate map to coordinates
  Future<void> animateTo(LatLng target, {double? zoom}) async {
    _currentCenter = target;
    if (_controller != null) {
      await _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: zoom ?? _currentZoom,
          ),
        ),
      );
    } else {
      if (mounted) setState(() {});
    }
  }

  /// Zoom in action
  Future<void> zoomIn() async {
    if (_controller != null) {
      await _controller!.animateCamera(CameraUpdate.zoomIn());
    } else {
      setState(() => _currentZoom = (_currentZoom + 1).clamp(3.0, 21.0));
    }
  }

  /// Zoom out action
  Future<void> zoomOut() async {
    if (_controller != null) {
      await _controller!.animateCamera(CameraUpdate.zoomOut());
    } else {
      setState(() => _currentZoom = (_currentZoom - 1).clamp(3.0, 21.0));
    }
  }

  bool get _isTestEnvironment {
    try {
      return !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 1. Google Map View or Test Fallback
        Positioned.fill(
          child: _isTestEnvironment
              ? _buildTestMapCanvas(isDark)
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.initialLatitude, widget.initialLongitude),
                    zoom: widget.initialZoom,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  padding: widget.mapPadding,
                  markers: widget.markers,
                  polylines: widget.polylines,
                  onMapCreated: (controller) {
                    _controller = controller;
                    widget.onMapCreated?.call(controller);
                  },
                  onCameraMoveStarted: () {
                    if (mounted) setState(() => _isCameraMoving = true);
                  },
                  onCameraMove: (position) {
                    _currentCenter = position.target;
                    _currentZoom = position.zoom;
                    widget.onCameraMove?.call(position);
                  },
                  onCameraIdle: () {
                    if (mounted) setState(() => _isCameraMoving = false);
                    widget.onCameraIdle?.call();
                    widget.onPositionChanged?.call(_currentCenter);
                  },
                  onTap: (latLng) {
                    _currentCenter = latLng;
                    widget.onTap?.call(latLng);
                    if (widget.isPicker) {
                      widget.onPositionChanged?.call(latLng);
                    }
                  },
                ),
        ),

        // 2. Center Pin Overlay (Picker mode)
        if (widget.isPicker) _buildCenterPickerPin(isDark),

        // 3. Floating Map Controls (Zoom In/Out + My Location)
        Positioned(
          right: 16,
          bottom: widget.isPicker ? 120 : 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showMyLocationButton) ...[
                _buildMapActionButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Current location',
                  color: GVColors.brandGreen,
                  onPressed: () {
                    if (widget.onMyLocationTapped != null) {
                      widget.onMyLocationTapped!();
                    } else {
                      animateTo(
                        LatLng(widget.initialLatitude, widget.initialLongitude),
                        zoom: 16.5,
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
              if (widget.showZoomControls) ...[
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2822) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildZoomButton(
                        icon: Icons.add_rounded,
                        tooltip: 'Zoom in',
                        isDark: isDark,
                        onPressed: zoomIn,
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark ? const Color(0xFF2E3D35) : GVColors.neutral200,
                      ),
                      _buildZoomButton(
                        icon: Icons.remove_rounded,
                        tooltip: 'Zoom out',
                        isDark: isDark,
                        onPressed: zoomOut,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required String tooltip,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 44,
      height: 42,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: 22,
              color: isDark ? Colors.white : GVColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterPickerPin(bool isDark) {
    final effectivePinColor = widget.pinColor ?? GVColors.brandGreen;
    final title = widget.pickerTitle ?? 'Selected location';
    final address = widget.pickerAddress ??
        '${_currentCenter.latitude.toStringAsFixed(4)}°N, ${_currentCenter.longitude.toStringAsFixed(4)}°E';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Lift & Drop on camera drag
          AnimatedSlide(
            duration: const Duration(milliseconds: 180),
            curve: _isCameraMoving ? Curves.easeOutQuad : Curves.bounceOut,
            offset: Offset(0, _isCameraMoving ? -0.22 : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Callout Bubble
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A221E) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GVTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: effectivePinColor,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address,
                        style: GVTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : GVColors.textPrimary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(12, 6),
                  painter: _CalloutTrianglePainter(
                    color: isDark ? const Color(0xFF1A221E) : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),

                // Glowing Center Pin
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: _isCameraMoving ? 36 : 46,
                      height: _isCameraMoving ? 36 : 46,
                      decoration: BoxDecoration(
                        color: effectivePinColor.withValues(
                          alpha: _isCameraMoving ? 0.10 : 0.22,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: effectivePinColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: effectivePinColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ground Contact Dot (crosshairs shadow)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: _isCameraMoving ? 8 : 12,
            height: _isCameraMoving ? 4 : 6,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: _isCameraMoving ? 0.20 : 0.45),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 28), // Offset pin anchor point to map center
        ],
      ),
    );
  }

  /// High-fidelity test-environment fallback canvas simulating Google Map
  Widget _buildTestMapCanvas(bool isDark) {
    return GestureDetector(
      onPanStart: (_) {
        if (mounted) setState(() => _isCameraMoving = true);
      },
      onPanUpdate: (details) {
        final newLat = _currentCenter.latitude - (details.delta.dy * 0.00008);
        final newLng = _currentCenter.longitude + (details.delta.dx * 0.00008);
        final newCoord = LatLng(
          double.parse(newLat.toStringAsFixed(5)),
          double.parse(newLng.toStringAsFixed(5)),
        );
        setState(() => _currentCenter = newCoord);
      },
      onPanEnd: (_) {
        if (mounted) setState(() => _isCameraMoving = false);
        widget.onPositionChanged?.call(_currentCenter);
      },
      onTapDown: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        final size = renderBox?.size ?? const Size(400, 600);
        final dx = details.localPosition.dx - (size.width / 2);
        final dy = details.localPosition.dy - (size.height / 2);
        final newLat = _currentCenter.latitude - (dy * 0.00005);
        final newLng = _currentCenter.longitude + (dx * 0.00005);
        final newCoord = LatLng(
          double.parse(newLat.toStringAsFixed(5)),
          double.parse(newLng.toStringAsFixed(5)),
        );
        setState(() => _currentCenter = newCoord);
        widget.onTap?.call(newCoord);
        widget.onPositionChanged?.call(newCoord);
      },
      child: Container(
        color: isDark ? const Color(0xFF121B15) : const Color(0xFFE9F0EB),
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _TestMapPainter(isDark: isDark),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Google Maps • Live ${_currentCenter.latitude.toStringAsFixed(4)}, ${_currentCenter.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalloutTrianglePainter extends CustomPainter {
  const _CalloutTrianglePainter({required this.color});
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
  bool shouldRepaint(covariant _CalloutTrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _TestMapPainter extends CustomPainter {
  const _TestMapPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = isDark ? const Color(0xFF27382F) : const Color(0xFFD6E3D8)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.55),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.65, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TestMapPainter oldDelegate) => false;
}
