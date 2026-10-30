import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_durations.dart';

/// Primary call-to-action button.
///
/// States: default, loading, disabled.
/// Full-width by default; set [expanded] to false for inline use.
class GVPrimaryButton extends StatelessWidget {
  const GVPrimaryButton({
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

  bool get _disabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final Widget button = AnimatedContainer(
      duration: GVDurations.fast,
      width: expanded ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
        onPressed: _disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _disabled ? GVColors.brandGreen.withValues(alpha: 0.4) : GVColors.brandGreen,
          foregroundColor: GVColors.nearBlack,
          elevation: 0,
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
                  color: GVColors.nearBlack,
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
    return button;
  }
}
