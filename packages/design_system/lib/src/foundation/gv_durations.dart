/// Go-Volts animation duration tokens.
abstract final class GVDurations {
  /// Micro-interactions: button press, ripple.
  static const Duration fast = Duration(milliseconds: 120);

  /// Standard transitions: page fade, card expand.
  static const Duration medium = Duration(milliseconds: 250);

  /// Slow transitions: modal, full-page slide.
  static const Duration slow = Duration(milliseconds: 400);

  /// Skeleton shimmer cycle.
  static const Duration shimmer = Duration(milliseconds: 1200);

  /// Splash logo animation.
  static const Duration splash = Duration(milliseconds: 800);
}
