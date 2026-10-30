import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class MerchantModalDialog extends StatelessWidget {
  const MerchantModalDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.content,
    this.child,
    this.primaryActionLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onPrimaryAction,
    this.onCancel,
    this.icon,
    this.accentColor = GVColors.brandGreen,
    this.isLoading = false,
    this.maxWidth = 520,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget? content;
  final Widget? child;
  final String primaryActionLabel;
  final String cancelLabel;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color accentColor;
  final bool isLoading;
  final double maxWidth;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141C18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        side: const BorderSide(color: Color(0xFF24332A)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: accentColor, size: 20),
                    ),
                    const SizedBox(width: GVSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GVTypography.h3.copyWith(color: Colors.white),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: GVTypography.caption.copyWith(color: Colors.white60),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () {
                      if (onCancel != null) {
                        onCancel!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
              const Divider(color: Color(0xFF223028), height: GVSpacing.xl),

              // Body Content
              Flexible(
                child: SingleChildScrollView(
                  child: content ?? child ?? const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Action Buttons
              if (actions != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (onCancel != null) {
                                onCancel!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Color(0xFF324538)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(cancelLabel),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    ElevatedButton(
                      onPressed: isLoading ? null : onPrimaryAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: GVColors.nearBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Text(primaryActionLabel),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
