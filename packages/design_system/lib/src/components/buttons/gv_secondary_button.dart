import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_border_radius.dart';

/// Secondary button — white/neutral fill with defined border.
class GVSecondaryButton extends StatelessWidget {
  const GVSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.expanded = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expanded;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: GVColors.nearBlack,
          backgroundColor: GVColors.white,
          side: const BorderSide(color: GVColors.border, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: GVBorderRadius.buttonRadius,
          ),
          minimumSize: Size(expanded ? double.infinity : 120, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: GVColors.textSecondary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                    Flexible(
                      child: Text(
                        label,
                        style: GVTypography.buttonLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
