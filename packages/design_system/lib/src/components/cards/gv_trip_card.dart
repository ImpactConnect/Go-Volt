import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';
import '../chips/gv_status_chip.dart';

/// Trip history/upcoming card shown in the Trips tab.
class GVTripCard extends StatelessWidget {
  const GVTripCard({
    super.key,
    required this.serviceLabel,
    required this.origin,
    required this.destination,
    required this.dateLabel,
    required this.status,
    this.amount,
    this.onTap,
  });

  final String serviceLabel;
  final String origin;
  final String destination;
  final String dateLabel;
  final GVStatusType status;
  final String? amount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: GVBorderRadius.cardRadius,
      child: Container(
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: GVColors.white,
          borderRadius: GVBorderRadius.cardRadius,
          border: Border.all(color: GVColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(serviceLabel, style: GVTypography.label),
                const Spacer(),
                GVStatusChip(status: status, compact: true),
              ],
            ),
            const SizedBox(height: GVSpacing.sm),
            _RouteRow(origin: origin, destination: destination),
            const SizedBox(height: GVSpacing.sm),
            Row(
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 13, color: GVColors.textSecondary),
                const SizedBox(width: 4),
                Text(dateLabel,
                    style: GVTypography.caption
                        .copyWith(color: GVColors.textSecondary)),
                if (amount != null) ...[
                  const Spacer(),
                  Text(amount!,
                      style: GVTypography.bodySmallMedium),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.origin, required this.destination});
  final String origin;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            const Icon(Icons.circle, size: 8, color: GVColors.brandGreen),
            Container(
              width: 1.5,
              height: 16,
              color: GVColors.border,
            ),
            const Icon(Icons.location_on,
                size: 12, color: GVColors.nearBlack),
          ],
        ),
        const SizedBox(width: GVSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(origin,
                  style: GVTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text(destination,
                  style: GVTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
