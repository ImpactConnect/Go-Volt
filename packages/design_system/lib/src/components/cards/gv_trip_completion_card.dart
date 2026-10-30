import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';
import '../buttons/gv_outlined_button.dart';
import '../buttons/gv_primary_button.dart';

/// Trip completion summary card matching Screen 15.
///
/// Fully dynamic — takes trip total, savings, driver details,
/// trip metric attributes, and "View receipt" / "Rate your rider" callbacks.
class GVTripCompletionCard extends StatelessWidget {
  const GVTripCompletionCard({
    super.key,
    required this.totalFareLabel,
    this.promoSavingsLabel,
    required this.driverName,
    required this.driverVehicle,
    this.driverAvatarUrl,
    required this.pickupAddress,
    required this.pickupTime,
    required this.destinationAddress,
    required this.destinationTime,
    required this.distanceLabel,
    required this.durationLabel,
    required this.rideTypeName,
    this.onViewReceipt,
    this.onRateRider,
  });

  final String totalFareLabel;
  final String? promoSavingsLabel;
  final String driverName;
  final String driverVehicle;
  final String? driverAvatarUrl;
  final String pickupAddress;
  final String pickupTime;
  final String destinationAddress;
  final String destinationTime;
  final String distanceLabel;
  final String durationLabel;
  final String rideTypeName;
  final VoidCallback? onViewReceipt;
  final VoidCallback? onRateRider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Celebration Icon
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Confetti Dots Around Badge
                const Positioned(
                  top: 0,
                  left: 20,
                  child: _ConfettiDot(color: GVColors.warning, size: 8),
                ),
                const Positioned(
                  top: 8,
                  right: 24,
                  child: _ConfettiDot(color: GVColors.electricBlue, size: 6),
                ),
                const Positioned(
                  bottom: 4,
                  left: 28,
                  child: _ConfettiDot(color: GVColors.deepPurple, size: 7),
                ),
                const Positioned(
                  bottom: 8,
                  right: 18,
                  child: _ConfettiDot(color: GVColors.limeHighlight, size: 9),
                ),

                // Center Success Circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: GVColors.brandGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: GVColors.brandGreen.withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 46,
                    color: GVColors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Header Text
          Text(
            'Trip completed!',
            style: GVTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            'Thanks for riding with Go-Volts.',
            style: GVTypography.bodyMedium.copyWith(
              color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: GVSpacing.lg),

          // Total Fare Highlight Box
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GVSpacing.lg,
              vertical: GVSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131A16) : GVColors.white,
              borderRadius: GVBorderRadius.cardRadius,
              border: Border.all(
                color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Total fare',
                  style: GVTypography.bodySmall.copyWith(
                    color:
                        isDark ? GVColors.neutral400 : GVColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalFareLabel,
                  style: GVTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isDark ? GVColors.white : GVColors.textPrimary,
                  ),
                ),
                if (promoSavingsLabel != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: GVColors.statusActiveBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 13,
                          color: GVColors.statusActiveFg,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          promoSavingsLabel!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: GVColors.statusActiveFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Driver Snippet
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131A16) : GVColors.white,
              borderRadius: GVBorderRadius.cardRadius,
              border: Border.all(
                color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isDark
                      ? const Color(0xFF243029)
                      : GVColors.softBackground,
                  backgroundImage: driverAvatarUrl != null
                      ? NetworkImage(driverAvatarUrl!)
                      : null,
                  child: driverAvatarUrl == null
                      ? const Icon(Icons.person,
                          color: GVColors.brandGreen, size: 24)
                      : null,
                ),
                const SizedBox(width: GVSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: GVTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                      Text(
                        driverVehicle,
                        style: GVTypography.bodySmall.copyWith(
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
          const SizedBox(height: GVSpacing.md),

          // Trip Details (Route & Metrics)
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131A16) : GVColors.white,
              borderRadius: GVBorderRadius.cardRadius,
              border: Border.all(
                color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip details',
                  style: GVTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? GVColors.white : GVColors.textPrimary,
                  ),
                ),
                const SizedBox(height: GVSpacing.sm),

                // Pickup
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: GVColors.brandGreen,
                      ),
                    ),
                    const SizedBox(width: GVSpacing.sm),
                    Expanded(
                      child: Text(
                        pickupAddress,
                        style: GVTypography.bodySmall.copyWith(
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      pickupTime,
                      style: GVTypography.caption.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    width: 2,
                    height: 18,
                    color: isDark ? GVColors.neutral700 : GVColors.neutral300,
                  ),
                ),

                // Dropoff
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: GVColors.error,
                      ),
                    ),
                    const SizedBox(width: GVSpacing.sm),
                    Expanded(
                      child: Text(
                        destinationAddress,
                        style: GVTypography.bodySmall.copyWith(
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      destinationTime,
                      style: GVTypography.caption.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: GVSpacing.sm),
                  child: Divider(color: GVColors.divider),
                ),

                // Distance, Duration, Ride type table
                _DetailRow(
                  label: 'Distance',
                  value: distanceLabel,
                  isDark: isDark,
                ),
                const SizedBox(height: 4),
                _DetailRow(
                  label: 'Duration',
                  value: durationLabel,
                  isDark: isDark,
                ),
                const SizedBox(height: 4),
                _DetailRow(
                  label: 'Ride type',
                  value: rideTypeName,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.lg),

          // Actions
          if (onViewReceipt != null)
            GVPrimaryButton(
              label: 'View receipt',
              onPressed: onViewReceipt,
            ),
          if (onRateRider != null) ...[
            const SizedBox(height: GVSpacing.sm),
            GVOutlinedButton(
              label: 'Rate your rider',
              onPressed: onRateRider,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GVTypography.bodySmall.copyWith(
            color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
          ),
        ),
        const SizedBox(width: GVSpacing.sm),
        Flexible(
          child: Text(
            value,
            style: GVTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  const _ConfettiDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
