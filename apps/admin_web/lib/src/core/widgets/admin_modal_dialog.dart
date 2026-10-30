import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class AdminModalDialog extends StatelessWidget {
  const AdminModalDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.content,
    this.child,
    this.confirmLabel,
    this.primaryActionLabel,
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onPrimaryAction,
    this.onCancel,
    this.isDestructive = false,
    this.isLoading = false,
    this.maxWidth = 540,
    this.accentColor,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? content;
  final Widget? child;
  final String? confirmLabel;
  final String? primaryActionLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool isLoading;
  final double maxWidth;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final effectiveContent = content ?? child ?? const SizedBox.shrink();
    final effectiveConfirmLabel = confirmLabel ?? primaryActionLabel ?? 'Confirm';
    final effectiveOnConfirm = onConfirm ?? onPrimaryAction;
    final effectiveAccentColor = accentColor ?? (isDestructive ? Colors.redAccent : GVColors.brandGreen);

    return Dialog(
      backgroundColor: const Color(0xFF161E1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        side: const BorderSide(color: Color(0xFF283830), width: 1),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: effectiveAccentColor, size: 22),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GVTypography.h2.copyWith(color: Colors.white),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle!,
                                  style: GVTypography.caption.copyWith(color: Colors.white70),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF25332C), height: GVSpacing.lg),
              effectiveContent,
              const SizedBox(height: GVSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Color(0xFF2A3630)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    child: Text(cancelLabel),
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: effectiveAccentColor,
                      foregroundColor: isDestructive ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isLoading ? null : effectiveOnConfirm,
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            effectiveConfirmLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
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
