import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_shadows.dart';

/// Driver/rider info card shown on Ride Tracking and Driver Assigned screens.
///
/// Per spec R07: minimise personal data exposed; show approved fields only.
class GVDriverCard extends StatelessWidget {
  const GVDriverCard({
    super.key,
    required this.displayName,
    required this.vehicleDescription,
    required this.plateNumber,
    this.rating,
    this.etaLabel,
    this.avatarUrl,
    this.onCall,
    this.onMessage,
    this.onSafety,
  });

  final String displayName;
  final String vehicleDescription;
  final String plateNumber;
  final double? rating;
  final String? etaLabel;
  final String? avatarUrl;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onSafety;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: GVColors.white,
        borderRadius: GVBorderRadius.cardRadius,
        boxShadow: GVShadows.card,
      ),
      padding: const EdgeInsets.all(GVSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: GVColors.softBackground,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: GVColors.textSecondary, size: 28)
                    : null,
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: GVTypography.bodyMedium),
                    Text(
                      '$vehicleDescription · $plateNumber',
                      style: GVTypography.bodySmall
                          .copyWith(color: GVColors.textSecondary),
                    ),
                    if (rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: GVColors.warning),
                          const SizedBox(width: 2),
                          Text(rating!.toStringAsFixed(1),
                              style: GVTypography.caption),
                        ],
                      ),
                  ],
                ),
              ),
              if (etaLabel != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('ETA (est.)',
                        style: GVTypography.caption
                            .copyWith(color: GVColors.textSecondary)),
                    Text(etaLabel!, style: GVTypography.bodyMedium),
                  ],
                ),
            ],
          ),
          if (onCall != null || onMessage != null || onSafety != null) ...[
            const SizedBox(height: GVSpacing.md),
            Row(
              children: [
                if (onCall != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCall,
                      icon: const Icon(Icons.phone_outlined, size: 16),
                      label: const Text('Call'),
                    ),
                  ),
                if (onCall != null && onMessage != null)
                  const SizedBox(width: GVSpacing.sm),
                if (onMessage != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMessage,
                      icon: const Icon(Icons.chat_outlined, size: 16),
                      label: const Text('Chat'),
                    ),
                  ),
                if (onSafety != null) ...[
                  const SizedBox(width: GVSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSafety,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GVColors.error,
                        side: const BorderSide(color: GVColors.error),
                      ),
                      icon: const Icon(Icons.shield_outlined, size: 16),
                      label: const Text('Safety'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
