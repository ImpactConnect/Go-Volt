import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_border_radius.dart';

/// Destructive button — red treatment for irreversible actions.
/// Always use with a [GVConfirmationSheet] before executing.
class GVDestructiveButton extends StatelessWidget {
  const GVDestructiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: GVColors.error,
          foregroundColor: GVColors.white,
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
                  color: GVColors.white,
                ),
              )
            : Text(label, style: GVTypography.buttonLarge),
      ),
    );
  }
}
