import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Detailed driver & vehicle card supporting live tracking states
/// matching Screens 12 ("Rider Assigned"), 13 ("Driver Approaching"),
/// and 14 ("On Trip").
class GVRiderInfoCard extends StatelessWidget {
  const GVRiderInfoCard({
    super.key,
    required this.riderName,
    required this.vehicleModel,
    required this.plateNumber,
    this.vehicleColor,
    this.rating,
    this.tripCount,
    this.avatarUrl,
    this.statusTitle,
    this.statusSubtitle,
    this.etaMinutes,
    this.onCall,
    this.onMessage,
    this.onShareTrip,
    this.onSafety,
    this.vehicleBannerText,
    this.vehicleBannerImage,
    this.showCallMessageButtons = true,
    this.showShareSafetyPills = true,
  });

  final String riderName;
  final String vehicleModel;
  final String plateNumber;
  final String? vehicleColor;
  final double? rating;
  final int? tripCount;
  final String? avatarUrl;
  final String? statusTitle;
  final String? statusSubtitle;
  final int? etaMinutes;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onShareTrip;
  final VoidCallback? onSafety;
  final String? vehicleBannerText;
  final Widget? vehicleBannerImage;
  final bool showCallMessageButtons;
  final bool showShareSafetyPills;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final vehicleSummary = [
      vehicleModel,
      if (vehicleColor != null) vehicleColor,
      plateNumber,
    ].join(' • ');

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
          // Optional Status Header (e.g. "Rider assigned! / Your rider is on the way...")
          if (statusTitle != null) ...[
            Text(
              statusTitle!,
              style: GVTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? GVColors.white : GVColors.textPrimary,
              ),
            ),
            if (statusSubtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                statusSubtitle!,
                style: GVTypography.bodySmall.copyWith(
                  color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: GVSpacing.md),
          ],

          // Driver Profile Row
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: isDark
                    ? const Color(0xFF243029)
                    : GVColors.softBackground,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? const Icon(
                        Icons.person,
                        color: GVColors.brandGreen,
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: GVSpacing.md),

              // Driver Name, Rating, Vehicle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riderName,
                      style: GVTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (rating != null) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: GVColors.warning,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: GVTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? GVColors.white
                                  : GVColors.textPrimary,
                            ),
                          ),
                        ],
                        if (tripCount != null) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '($tripCount trips)',
                              style: GVTypography.caption.copyWith(
                                color: isDark
                                    ? GVColors.neutral400
                                    : GVColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicleSummary,
                      style: GVTypography.caption.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action Buttons: Call & Message
              if (showCallMessageButtons) ...[
                if (onCall != null)
                  _ActionCircleButton(
                    icon: Icons.phone_rounded,
                    tooltip: 'Call driver',
                    onTap: onCall!,
                    isDark: isDark,
                  ),
                if (onCall != null && onMessage != null)
                  const SizedBox(width: GVSpacing.sm),
                if (onMessage != null)
                  _ActionCircleButton(
                    icon: Icons.chat_bubble_rounded,
                    tooltip: 'Message driver',
                    onTap: onMessage!,
                    isDark: isDark,
                  ),
              ],
            ],
          ),

          // ETA Alert (e.g. "Rider will arrive in 6 min")
          if (etaMinutes != null) ...[
            const SizedBox(height: GVSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF13221A)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E4632)
                      : const Color(0xFFBBF7D0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: GVColors.brandGreen,
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GVTypography.bodySmall.copyWith(
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'Rider will arrive in '),
                          TextSpan(
                            text: '$etaMinutes min',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: GVColors.brandGreen,
                            ),
                          ),
                          const TextSpan(
                            text: '. Please be at the pickup location.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Share Trip & Safety Pills
          if (showShareSafetyPills && (onShareTrip != null || onSafety != null)) ...[
            const SizedBox(height: GVSpacing.md),
            Row(
              children: [
                if (onShareTrip != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onShareTrip,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF2E3D35)
                              : GVColors.border,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(
                        Icons.share_outlined,
                        size: 16,
                        color: GVColors.textPrimary,
                      ),
                      label: Text(
                        'Share trip',
                        style: GVTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                if (onShareTrip != null && onSafety != null)
                  const SizedBox(width: GVSpacing.sm),
                if (onSafety != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSafety,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF2E3D35)
                              : GVColors.border,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: GVColors.brandGreen,
                      ),
                      label: Text(
                        'Safety',
                        style: GVTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          // Vehicle Banner identifier (Screen 12 bottom)
          if (vehicleBannerText != null) ...[
            const SizedBox(height: GVSpacing.md),
            Container(
              padding: const EdgeInsets.all(GVSpacing.sm + 2),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF131A16)
                    : GVColors.softBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  vehicleBannerImage ??
                      Container(
                        width: 48,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF243029)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          size: 24,
                          color: GVColors.brandGreen,
                        ),
                      ),
                  const SizedBox(width: GVSpacing.sm),
                  Expanded(
                    child: Text(
                      vehicleBannerText!,
                      style: GVTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionCircleButton extends StatelessWidget {
  const _ActionCircleButton({
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
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF1E3626)
                  : const Color(0xFFE8F5E9),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2E5A3D)
                    : const Color(0xFFC8E6C9),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 18,
              color: GVColors.brandGreen,
            ),
          ),
        ),
      ),
    );
  }
}
