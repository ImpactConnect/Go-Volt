import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Representation of a handling switch item.
class GVHandlingOptionItem {
  const GVHandlingOptionItem({
    required this.code,
    required this.label,
    required this.isEnabled,
  });

  final String code;
  final String label;
  final bool isEnabled;
}

/// Screen 3: Special Handling Toggles (Fragile, Keep upright, Perishable).
class GVSpecialHandlingToggles extends StatelessWidget {
  const GVSpecialHandlingToggles({
    super.key,
    required this.options,
    required this.onChanged,
  });

  final List<GVHandlingOptionItem> options;
  final void Function(String code, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF1A221E) : GVColors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      options[i].label,
                      style: GVTypography.bodyMedium.copyWith(
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: options[i].isEnabled,
                    activeThumbColor: GVColors.brandGreen,
                    onChanged: (val) => onChanged(options[i].code, val),
                  ),
                ],
              ),
            ),
            if (i < options.length - 1)
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF2E3D35) : GVColors.neutral100,
              ),
          ],
        ],
      ),
    );
  }
}
