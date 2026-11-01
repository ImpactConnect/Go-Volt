import 'package:flutter/material.dart';

/// Go-Volts brand color tokens.
///
/// Based on Customer App Screen Specifications v1.0 §2 Design Tokens.
/// These are authoritative — do not override ad-hoc.
abstract final class GVColors {
  // ── Primary Brand ─────────────────────────────────────────────────────────

  /// Brand Green — primary actions, active icons, selected states.
  static const Color brandGreen = Color(0xFF00C853);

  /// Deep Green — headers, dark hero surfaces, navigation backgrounds.
  static const Color deepGreen = Color(0xFF064E3B);

  /// Lime Highlight — selected accents, progress indicators.
  static const Color limeHighlight = Color(0xFFA7F432);

  /// Accent Green — success states, secondary emphasis.
  static const Color accentGreen = Color(0xFF22D17A);

  // ── Neutral ────────────────────────────────────────────────────────────────

  /// Near Black — dark surfaces, primary text on light backgrounds.
  static const Color nearBlack = Color(0xFF0B0F0D);

  /// Dark Background — dark theme canvas and scaffold surface.
  static const Color darkBg = Color(0xFF0F1512);

  /// Deep Slate — secondary neutral, card backgrounds on dark surfaces.
  static const Color deepSlate = Color(0xFF1F2937);

  /// Soft Background — app canvas / page background.
  static const Color softBackground = Color(0xFFF3F6F4);

  /// White — cards, text on dark surfaces.
  static const Color white = Color(0xFFFFFFFF);

  // ── Semantic ───────────────────────────────────────────────────────────────

  /// Error / destructive actions.
  static const Color error = Color(0xFFDC2626);

  /// Warning / pending / attention state.
  static const Color warning = Color(0xFFF59E0B);

  /// Informational status.
  static const Color info = Color(0xFF2563EB);

  /// Aliases & Dashboard / Web tokens
  static const Color voltGreen = brandGreen;
  static const Color primary = brandGreen;
  static const Color electricBlue = info;
  static const Color warningOrange = warning;
  static const Color errorRed = error;
  static const Color deepPurple = Color(0xFF8B5CF6);

  // ── Neutrals ───────────────────────────────────────────────────────────────
  static const Color neutral950 = Color(0xFF070B09);
  static const Color neutral900 = Color(0xFF0F1512);
  static const Color neutral850 = Color(0xFF131A16);
  static const Color neutral800 = Color(0xFF1C2621);
  static const Color neutral700 = Color(0xFF2E3D35);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral50 = Color(0xFFF9FAFB);

  // ── Text ───────────────────────────────────────────────────────────────────

  /// Primary text on light backgrounds.
  static const Color textPrimary = nearBlack;

  /// Secondary / supporting text.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Disabled text.
  static const Color textDisabled = Color(0xFF9CA3AF);

  /// Text on dark/green surfaces.
  static const Color textOnDark = white;

  // ── Border & Divider ───────────────────────────────────────────────────────

  /// Default border color.
  static const Color border = Color(0xFFE2E7E2);

  /// Subtle divider.
  static const Color divider = Color(0xFFF0F2F0);

  // ── Map markers (for reference) ────────────────────────────────────────────

  /// Pickup marker — bright green pin.
  static const Color mapPickup = brandGreen;

  /// Drop-off marker — near-black pin.
  static const Color mapDropoff = nearBlack;

  // ── Status chip backgrounds ────────────────────────────────────────────────

  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusPendingFg = Color(0xFF92400E);
  static const Color statusActiveBg = Color(0xFFD1FAE5);
  static const Color statusActiveFg = Color(0xFF065F46);
  static const Color statusAssignedBg = Color(0xFFDBEAFE);
  static const Color statusAssignedFg = Color(0xFF1E40AF);
  static const Color statusDelayedBg = Color(0xFFFEE2E2);
  static const Color statusDelayedFg = Color(0xFF991B1B);
  static const Color statusCompletedBg = Color(0xFFD1FAE5);
  static const Color statusCompletedFg = Color(0xFF065F46);
  static const Color statusCancelledBg = Color(0xFFF3F4F6);
  static const Color statusCancelledFg = Color(0xFF6B7280);
}
