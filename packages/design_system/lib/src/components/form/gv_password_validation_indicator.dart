import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';

/// Live checklist component showing password security criteria.
/// Matches Screen 4 (AUTH-02-SIGNUP) and Screen 10 (AUTH-07B-NEW-PASSWORD).
class GVPasswordValidationIndicator extends StatelessWidget {
  const GVPasswordValidationIndicator({
    super.key,
    required this.password,
  });

  final String password;

  bool get hasMinLength => password.length >= 8;
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasLetter => password.contains(RegExp(r'[a-zA-Z]'));
  bool get isValid => hasMinLength && hasNumber && hasLetter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckItem(
          context: context,
          label: 'At least 8 characters',
          isValid: hasMinLength,
        ),
        const SizedBox(height: GVSpacing.xs),
        _buildCheckItem(
          context: context,
          label: 'Include a number',
          isValid: hasNumber,
        ),
        const SizedBox(height: GVSpacing.xs),
        _buildCheckItem(
          context: context,
          label: 'Include a letter',
          isValid: hasLetter,
        ),
      ],
    );
  }

  Widget _buildCheckItem({
    required BuildContext context,
    required String label,
    required bool isValid,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? GVColors.neutral500 : GVColors.neutral400;
    final textColor = isValid
        ? (isDark ? Colors.white : GVColors.textPrimary)
        : inactiveColor;

    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: isValid ? GVColors.brandGreen : inactiveColor,
        ),
        const SizedBox(width: GVSpacing.xs),
        Text(
          label,
          style: GVTypography.caption.copyWith(
            color: textColor,
            fontWeight: isValid ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

