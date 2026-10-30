import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Available vehicle types for driver registration.
enum GVVehicleType {
  motorbike(label: 'Motorbike', icon: Icons.two_wheeler),
  car(label: 'Car', icon: Icons.directions_car),
  tricycle(label: 'Tricycle', icon: Icons.electric_rickshaw);

  const GVVehicleType({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

/// Selector tabs for vehicle categories (Board 1 Screen 4).
class GVVehicleCategorySelector extends StatelessWidget {
  const GVVehicleCategorySelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final GVVehicleType selectedType;
  final ValueChanged<GVVehicleType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: GVVehicleType.values.map((type) {
        final isSelected = type == selectedType;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onTypeSelected(type),
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: GVSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? GVColors.brandGreen.withValues(alpha: 0.15)
                      : const Color(0xFF1C2420),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(
                    color: isSelected ? GVColors.brandGreen : const Color(0xFF2A3630),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      color: isSelected ? GVColors.brandGreen : Colors.white60,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      type.label,
                      style: GVTypography.caption.copyWith(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
