import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Go_Volt Design System — Foundations & Tokens', () {
    test('GVColors tokens verify brand, functional, and portal palettes', () {
      expect(GVColors.brandGreen, const Color(0xFF00C853));
      expect(GVColors.deepGreen, const Color(0xFF064E3B));
      expect(GVColors.limeHighlight, const Color(0xFFA7F432));
      expect(GVColors.accentGreen, const Color(0xFF22D17A));

      // Neutral tokens
      expect(GVColors.nearBlack, const Color(0xFF0B0F0D));
      expect(GVColors.darkBg, const Color(0xFF0F1512));
      expect(GVColors.deepSlate, const Color(0xFF1F2937));
      expect(GVColors.softBackground, const Color(0xFFF3F6F4));
      expect(GVColors.white, const Color(0xFFFFFFFF));

      // Portal tokens
      expect(GVColors.voltGreen, GVColors.brandGreen);
      expect(GVColors.electricBlue, GVColors.info);
      expect(GVColors.warningOrange, GVColors.warning);
      expect(GVColors.errorRed, GVColors.error);
      expect(GVColors.neutral900, const Color(0xFF0F1512));
      expect(GVColors.neutral100, const Color(0xFFF3F4F6));
    });

    test('GVSpacing scales provide expected padding and gap constants', () {
      expect(GVSpacing.xs, 4.0);
      expect(GVSpacing.sm, 8.0);
      expect(GVSpacing.md, 16.0);
      expect(GVSpacing.lg, 24.0);
      expect(GVSpacing.xl, 32.0);
      expect(GVSpacing.xxl, 48.0);
    });

    test('GVBorderRadius defines standard scalar and component-specific radii', () {
      expect(GVBorderRadius.xs, 4.0);
      expect(GVBorderRadius.sm, 8.0);
      expect(GVBorderRadius.md, 12.0);
      expect(GVBorderRadius.lg, 16.0);
      expect(GVBorderRadius.xl, 20.0);
      expect(GVBorderRadius.xxl, 24.0);
      expect(GVBorderRadius.full, 9999.0);

      expect(GVBorderRadius.buttonRadius, const BorderRadius.all(Radius.circular(12.0)));
      expect(GVBorderRadius.cardRadius, const BorderRadius.all(Radius.circular(12.0)));
      expect(GVBorderRadius.chipRadius, const BorderRadius.all(Radius.circular(8.0)));
      expect(GVBorderRadius.fieldRadius, const BorderRadius.all(Radius.circular(8.0)));
    });

    test('GVShadows defines elevation tokens', () {
      expect(GVShadows.card, isNotEmpty);
      expect(GVShadows.elevated, isNotEmpty);
    });

    test('GVDurations defines transition and micro-interaction durations', () {
      expect(GVDurations.fast, const Duration(milliseconds: 120));
      expect(GVDurations.medium, const Duration(milliseconds: 250));
      expect(GVDurations.slow, const Duration(milliseconds: 400));
      expect(GVDurations.shimmer, const Duration(milliseconds: 1200));
      expect(GVDurations.splash, const Duration(milliseconds: 800));
    });

    test('GVStatusType contains all core delivery and trip statuses', () {
      expect(GVStatusType.values, containsAll([
        GVStatusType.pending,
        GVStatusType.active,
        GVStatusType.assigned,
        GVStatusType.delayed,
        GVStatusType.completed,
        GVStatusType.cancelled,
        GVStatusType.failed,
      ]));
    });
  });
}
