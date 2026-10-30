import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_border_radius.dart';

/// 6-digit OTP code entry component for Email and Recovery verification.
/// Matches Screen 5 (AUTH-03-EMAIL-OTP) and Screen 9 (AUTH-07A-RESET-OTP).
class GVEmailOtpInput extends StatelessWidget {
  const GVEmailOtpInput({
    super.key,
    this.controller,
    this.focusNode,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.autofocus = true,
    this.hasError = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 54,
      textStyle: GVTypography.h2.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(
          color: hasError ? GVColors.error : borderColor,
          width: 1.2,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: hasError ? GVColors.error : GVColors.brandGreen,
          width: 1.8,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: isDark ? const Color(0xFF16241C) : const Color(0xFFF0FDF4),
        border: Border.all(
          color: hasError ? GVColors.error : GVColors.brandGreen.withValues(alpha: 0.6),
          width: 1.4,
        ),
      ),
    );

    return Pinput(
      length: length,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      onCompleted: onCompleted,
      onChanged: onChanged,
    );
  }
}

