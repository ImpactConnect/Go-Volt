import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';

/// Location input field — pickup or drop-off.
class GVLocationField extends StatelessWidget {
  const GVLocationField({super.key, required this.label, this.value, this.hint, this.isPickup = true, this.onTap, this.onClear});
  final String label;
  final String? value;
  final String? hint;
  final bool isPickup;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, borderRadius: GVBorderRadius.fieldRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: GVColors.white,
          borderRadius: GVBorderRadius.fieldRadius,
          border: Border.all(color: value != null ? GVColors.brandGreen : GVColors.border),
        ),
        child: Row(
          children: [
            Icon(isPickup ? Icons.radio_button_checked : Icons.location_on_outlined,
              color: isPickup ? GVColors.brandGreen : GVColors.nearBlack, size: 20),
            const SizedBox(width: GVSpacing.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: GVTypography.caption.copyWith(color: GVColors.textSecondary)),
              Text(value ?? (hint ?? 'Search location'), style: GVTypography.body.copyWith(
                color: value != null ? GVColors.nearBlack : GVColors.textDisabled)),
            ])),
            if (value != null && onClear != null)
              GestureDetector(onTap: onClear, child: const Icon(Icons.clear, size: 16, color: GVColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
