import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Item for [GVStatRow].
class GVStatItem {
  const GVStatItem({
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;
}

/// A 3-column metrics summary bar with vertical dividers.
/// Used in Driver Dashboards (Flow B Screen 1, Flow C Screen 5, Flow D Screen 1).
class GVStatRow extends StatelessWidget {
  const GVStatRow({
    super.key,
    required this.items,
    this.backgroundColor = const Color(0xFF1C2420),
    this.borderColor = const Color(0xFF2A3630),
  });

  final List<GVStatItem> items;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GVSpacing.md,
        vertical: GVSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 36,
                color: Colors.white12,
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    items[i].value,
                    style: GVTypography.h3.copyWith(
                      color: items[i].valueColor ?? Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items[i].label,
                    style: GVTypography.caption.copyWith(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
