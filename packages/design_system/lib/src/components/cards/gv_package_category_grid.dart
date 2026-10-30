import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Item representation for package categories in the category grid.
class GVPackageCategoryItem {
  const GVPackageCategoryItem({
    required this.code,
    required this.label,
    required this.icon,
  });

  final String code;
  final String label;
  final IconData icon;
}

/// Screen 3: Package Category Grid (Documents, Electronics, Clothing, Food, Fragile, Other).
class GVPackageCategoryGrid extends StatelessWidget {
  const GVPackageCategoryGrid({
    super.key,
    required this.items,
    required this.selectedCode,
    required this.onSelected,
  });

  final List<GVPackageCategoryItem> items;
  final String selectedCode;
  final ValueChanged<String> onSelected;

  static const List<GVPackageCategoryItem> defaultItems = [
    GVPackageCategoryItem(
      code: 'DOCUMENTS',
      label: 'Documents',
      icon: Icons.description_outlined,
    ),
    GVPackageCategoryItem(
      code: 'ELECTRONICS',
      label: 'Electronics',
      icon: Icons.devices_rounded,
    ),
    GVPackageCategoryItem(
      code: 'CLOTHING',
      label: 'Clothing',
      icon: Icons.checkroom_rounded,
    ),
    GVPackageCategoryItem(
      code: 'FOOD',
      label: 'Food',
      icon: Icons.restaurant_rounded,
    ),
    GVPackageCategoryItem(
      code: 'FRAGILE',
      label: 'Fragile',
      icon: Icons.wine_bar_rounded,
    ),
    GVPackageCategoryItem(
      code: 'OTHER',
      label: 'Other',
      icon: Icons.more_horiz_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: GVSpacing.sm,
        mainAxisSpacing: GVSpacing.sm,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item.code == selectedCode;

        final bg = isSelected
            ? (isDark ? const Color(0xFF13221A) : const Color(0xFFF0FDF4))
            : (isDark ? const Color(0xFF1A221E) : GVColors.white);

        final borderColor = isSelected
            ? GVColors.brandGreen
            : (isDark ? const Color(0xFF2E3D35) : GVColors.border);

        final itemColor = isSelected
            ? GVColors.deepGreen
            : (isDark ? GVColors.white : GVColors.textPrimary);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelected(item.code),
            borderRadius: BorderRadius.circular(GVBorderRadius.md),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 26,
                    color: itemColor,
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    item.label,
                    style: GVTypography.caption.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: itemColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

