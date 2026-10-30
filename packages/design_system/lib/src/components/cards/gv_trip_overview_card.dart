import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Trip Overview Card matching Screen 7 ("Route Preview & Serviceability").
///
/// Fully dynamic — takes pickup & destination details, route metrics,
/// serviceability status message, and change/action callbacks.
class GVTripOverviewCard extends StatelessWidget {
  const GVTripOverviewCard({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.distanceLabel,
    required this.durationLabel,
    this.trafficCondition = 'Light traffic',
    this.isServiceable = true,
    this.serviceableMessage = 'Rides are available in this area',
    this.onChange,
  });

  final String pickupAddress;
  final String destinationAddress;
  final String distanceLabel;
  final String durationLabel;
  final String trafficCondition;
  final bool isServiceable;
  final String serviceableMessage;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A221E) : GVColors.white,
        borderRadius: GVBorderRadius.cardRadius,
        border: Border.all(
          color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(GVSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with "Trip overview" and "Change" action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip overview',
                style: GVTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
              if (onChange != null)
                TextButton(
                  onPressed: onChange,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Change',
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: GVColors.brandGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: GVSpacing.sm),

          // Pickup Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: GVColors.brandGreen,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: Text(
                  pickupAddress,
                  style: GVTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? GVColors.white : GVColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Container(
              width: 2,
              height: 18,
              color: isDark ? GVColors.neutral700 : GVColors.neutral300,
            ),
          ),

          // Destination Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: GVColors.error,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: Text(
                  destinationAddress,
                  style: GVTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? GVColors.white : GVColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.md),

          // Metrics (Duration, Distance, Traffic)
          Row(
            children: [
              const Icon(
                Icons.directions_car_rounded,
                size: 16,
                color: GVColors.brandGreen,
              ),
              const SizedBox(width: 6),
              Text(
                '$durationLabel • $distanceLabel',
                style: GVTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? GVColors.neutral500 : GVColors.neutral400,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trafficCondition,
                style: GVTypography.bodySmall.copyWith(
                  color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.md),

          // Serviceability Notice
          Container(
            padding: const EdgeInsets.all(GVSpacing.sm + 2),
            decoration: BoxDecoration(
              color: isServiceable
                  ? (isDark ? const Color(0xFF13221A) : const Color(0xFFF0FDF4))
                  : (isDark
                      ? const Color(0xFF2C1515)
                      : const Color(0xFFFEF2F2)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isServiceable
                    ? (isDark ? const Color(0xFF1E4632) : const Color(0xFFBBF7D0))
                    : (isDark
                        ? const Color(0xFF5A2222)
                        : const Color(0xFFFECACA)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isServiceable
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  size: 18,
                  color: isServiceable ? GVColors.brandGreen : GVColors.error,
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isServiceable ? 'Serviceable' : 'Area Not Serviceable',
                        style: GVTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isServiceable
                              ? GVColors.brandGreen
                              : GVColors.error,
                        ),
                      ),
                      Text(
                        serviceableMessage,
                        style: GVTypography.caption.copyWith(
                          color: isDark
                              ? GVColors.neutral400
                              : GVColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

