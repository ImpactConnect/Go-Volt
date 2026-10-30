import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Screen 3: Numeric stepper for package weight.
class GVWeightStepper extends StatelessWidget {
  const GVWeightStepper({
    super.key,
    required this.weightKg,
    required this.onChanged,
    this.minWeightKg = 0.5,
    this.maxWeightKg = 15.0,
    this.stepKg = 0.5,
  });

  final double weightKg;
  final ValueChanged<double> onChanged;
  final double minWeightKg;
  final double maxWeightKg;
  final double stepKg;

  void _decrement() {
    final next = (weightKg - stepKg);
    if (next >= minWeightKg) {
      onChanged(double.parse(next.toStringAsFixed(1)));
    }
  }

  void _increment() {
    final next = (weightKg + stepKg);
    if (next <= maxWeightKg) {
      onChanged(double.parse(next.toStringAsFixed(1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF1A221E) : GVColors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final canDecrement = weightKg > minWeightKg;
    final canIncrement = weightKg < maxWeightKg;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GVSpacing.sm,
        vertical: GVSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Decrement button
          IconButton(
            icon: Icon(
              Icons.remove,
              color: canDecrement
                  ? (isDark ? GVColors.white : GVColors.textPrimary)
                  : GVColors.neutral400,
            ),
            onPressed: canDecrement ? _decrement : null,
            splashRadius: 20,
          ),

          // Value display
          Text(
            '${weightKg.toStringAsFixed(1)} kg',
            style: GVTypography.body.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
          ),

          // Increment button
          IconButton(
            icon: Icon(
              Icons.add,
              color: canIncrement
                  ? (isDark ? GVColors.white : GVColors.textPrimary)
                  : GVColors.neutral400,
            ),
            onPressed: canIncrement ? _increment : null,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
