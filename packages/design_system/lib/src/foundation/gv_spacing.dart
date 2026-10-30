/// Go-Volts 8-point spacing system.
abstract final class GVSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  /// Standard horizontal page margin.
  static const double pageHorizontal = md;

  /// Card internal padding.
  static const double cardPadding = md;

  /// Standard section vertical gap.
  static const double sectionGap = lg;

  /// Bottom navigation height (including safe area).
  static const double bottomNavHeight = 72.0;

  /// Minimum touch target size per accessibility guidelines.
  static const double minTouchTarget = 44.0;
}
