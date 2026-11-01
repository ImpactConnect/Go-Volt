import 'package:flutter/material.dart';
import 'gv_destructive_button.dart';
import 'gv_outlined_button.dart';
import 'gv_primary_button.dart';
import 'gv_secondary_button.dart';

enum GVButtonType {
  primary,
  secondary,
  outline,
  destructive,
}

/// Unified button component for Go-Volts design system.
/// Delegates to GVPrimaryButton, GVSecondaryButton, GVOutlinedButton, or GVDestructiveButton.
class GVButton extends StatelessWidget {
  const GVButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = GVButtonType.primary,
    this.isLoading = false,
    this.expanded = true,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final GVButtonType type;
  final bool isLoading;
  final bool expanded;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      GVButtonType.primary => GVPrimaryButton(
          label: text,
          onPressed: onPressed,
          isLoading: isLoading,
          expanded: expanded,
          icon: icon,
        ),
      GVButtonType.secondary => GVSecondaryButton(
          label: text,
          onPressed: onPressed,
          isLoading: isLoading,
          expanded: expanded,
          icon: icon,
        ),
      GVButtonType.outline => GVOutlinedButton(
          label: text,
          onPressed: onPressed,
          expanded: expanded,
          icon: icon,
        ),
      GVButtonType.destructive => GVDestructiveButton(
          label: text,
          onPressed: onPressed,
          isLoading: isLoading,
          expanded: expanded,
        ),
    };
  }
}

