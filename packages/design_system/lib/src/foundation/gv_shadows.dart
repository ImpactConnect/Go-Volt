import 'package:flutter/material.dart';

/// Go-Volts elevation and shadow tokens.
abstract final class GVShadows {
  /// Subtle card shadow.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Elevated panel / bottom sheet shadow.
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, -4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, -2),
    ),
  ];

  /// Floating action / FAB shadow.
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x1E000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Drop-down / overlay shadow.
  static const List<BoxShadow> dropdown = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Glowing accent shadow for EV active indicators.
  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x3300C853),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
