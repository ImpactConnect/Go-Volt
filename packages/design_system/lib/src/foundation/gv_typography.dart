import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'gv_colors.dart';

/// Go-Volts typography system.
///
/// Uses Poppins (geometric sans-serif) on 8-pt grid.
/// All styles maintain accessible contrast and support text scaling.
abstract final class GVTypography {
  // ── Display ───────────────────────────────────────────────────────────────

  static TextStyle get display => GoogleFonts.poppins(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: GVColors.textPrimary,
      );

  // ── Headings ──────────────────────────────────────────────────────────────

  static TextStyle get h1 => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
        color: GVColors.textPrimary,
      );

  static TextStyle get h2 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
        color: GVColors.textPrimary,
      );

  static TextStyle get h3 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: GVColors.textPrimary,
      );

  // ── Body ──────────────────────────────────────────────────────────────────

  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: GVColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: GVColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: GVColors.textSecondary,
      );

  static TextStyle get bodySmallMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: GVColors.textPrimary,
      );

  // ── Label / UI ────────────────────────────────────────────────────────────

  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
        color: GVColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.2,
        color: GVColors.textDisabled,
      );

  // ── Button ────────────────────────────────────────────────────────────────

  static TextStyle get buttonLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.1,
        color: GVColors.nearBlack,
      );

  static TextStyle get buttonMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.1,
        color: GVColors.nearBlack,
      );

  static TextStyle get buttonSmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.1,
        color: GVColors.nearBlack,
      );

  // ── Currency helper ───────────────────────────────────────────────────────

  /// Bold ₦ amount style — used in price breakdowns and wallet.
  static TextStyle get amount => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
        color: GVColors.textPrimary,
      );

  static TextStyle get amountSmall => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: GVColors.textPrimary,
      );
}

