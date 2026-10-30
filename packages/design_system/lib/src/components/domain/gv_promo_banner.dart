import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';

/// Dismissible promotional banner shown on the Home screen.
class GVPromoBanner extends StatelessWidget {
  const GVPromoBanner({super.key, required this.title, required this.subtitle, this.onTap, this.onDismiss});
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [GVColors.deepGreen, Color(0xFF107A40)]),
        borderRadius: GVBorderRadius.cardRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap, borderRadius: GVBorderRadius.cardRadius,
          child: Padding(
            padding: const EdgeInsets.all(GVSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.local_offer_outlined, color: GVColors.limeHighlight, size: 28),
                const SizedBox(width: GVSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: GVTypography.bodyMedium.copyWith(color: GVColors.white)),
                  Text(subtitle, style: GVTypography.bodySmall.copyWith(color: GVColors.white.withValues(alpha: 0.8))),
                ])),
                if (onDismiss != null)
                  IconButton(icon: const Icon(Icons.close, size: 18, color: GVColors.white), onPressed: onDismiss),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
