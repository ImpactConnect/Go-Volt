import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';

/// Standardised Go-Volts form field.
///
/// Wraps [TextFormField] with brand styling, label-above layout, and
/// accessible semantics. Never use raw [TextField] in app screens.
class GVFormField extends StatelessWidget {
  const GVFormField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final int maxLines;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GVTypography.label.copyWith(
            color: enabled ? GVColors.nearBlack : GVColors.textDisabled,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          autofillHints: autofillHints,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          textInputAction: textInputAction,
          focusNode: focusNode,
          autofocus: autofocus,
          style: GVTypography.body.copyWith(
            color: enabled ? GVColors.textPrimary : GVColors.textDisabled,
          ),
          cursorColor: GVColors.brandGreen,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            helperText: helperText,
            prefixIcon: prefix,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
