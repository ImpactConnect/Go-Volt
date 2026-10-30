import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';

/// A single payment method option.
class GVPaymentMethod {
  const GVPaymentMethod({
    required this.id,
    required this.label,
    required this.icon,
    this.subtitle,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final IconData icon;
  final String? subtitle;
  final bool isDefault;
}

/// Payment method selection row — used on R04, D05, W02 screens.
///
/// Per spec R04: only show enabled methods from backend; show wallet balance.
class GVPaymentMethodRow extends StatelessWidget {
  const GVPaymentMethodRow({
    super.key,
    required this.methods,
    required this.selectedId,
    required this.onSelected,
    this.walletBalance,
    this.onAddMethod,
  });

  final List<GVPaymentMethod> methods;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final String? walletBalance;
  final VoidCallback? onAddMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GVColors.white,
        borderRadius: GVBorderRadius.cardRadius,
        border: Border.all(color: GVColors.border),
      ),
      child: Column(
        children: [
          ...methods.map((method) {
            final selected = method.id == selectedId;
            return InkWell(
              onTap: () => onSelected(method.id),
              borderRadius: selected
                  ? GVBorderRadius.cardRadius
                  : BorderRadius.zero,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GVSpacing.md,
                  vertical: GVSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? GVColors.brandGreen.withValues(alpha: 0.06)
                      : Colors.transparent,
                  border: methods.last != method
                      ? const Border(
                          bottom: BorderSide(color: GVColors.border))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(method.icon,
                        size: 22,
                        color: selected
                            ? GVColors.brandGreen
                            : GVColors.textSecondary),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(method.label,
                              style: GVTypography.bodySmallMedium),
                          if (method.id == 'wallet' &&
                              walletBalance != null)
                            Text(
                              'Balance: $walletBalance',
                              style: GVTypography.caption.copyWith(
                                color: GVColors.textSecondary,
                              ),
                            )
                          else if (method.subtitle != null)
                            Text(method.subtitle!,
                                style: GVTypography.caption.copyWith(
                                    color: GVColors.textSecondary)),
                        ],
                      ),
                    ),
                    // ignore: deprecated_member_use
                    Radio<String>(
                      value: method.id,
                      // ignore: deprecated_member_use
                      groupValue: selectedId,
                      // ignore: deprecated_member_use
                      onChanged: (v) => onSelected(v!),
                      activeColor: GVColors.brandGreen,
                    ),
                  ],
                ),
              ),
            );
          }),
          if (onAddMethod != null)
            InkWell(
              onTap: onAddMethod,
              child: Padding(
                padding: const EdgeInsets.all(GVSpacing.md),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline,
                        size: 20, color: GVColors.brandGreen),
                    const SizedBox(width: GVSpacing.sm),
                    Text('Add payment method',
                        style: GVTypography.bodySmallMedium
                            .copyWith(color: GVColors.brandGreen)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
