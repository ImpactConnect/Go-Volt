import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_durations.dart';

/// Animated shimmer loading skeleton.
class GVLoadingSkeleton extends StatefulWidget {
  const GVLoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<GVLoadingSkeleton> createState() => _GVLoadingSkeletonState();
}

class _GVLoadingSkeletonState extends State<GVLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: GVDurations.shimmer,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: GVColors.border.withValues(alpha: _animation.value),
        ),
      ),
    );
  }
}

/// Pre-built skeleton for a list tile.
class GVListTileSkeleton extends StatelessWidget {
  const GVListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GVSpacing.md,
        vertical: GVSpacing.sm,
      ),
      child: Row(
        children: [
          const GVLoadingSkeleton(width: 40, height: 40, borderRadius: 20),
          const SizedBox(width: GVSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GVLoadingSkeleton(
                    width: MediaQuery.sizeOf(context).width * 0.5, height: 14),
                const SizedBox(height: GVSpacing.xs),
                GVLoadingSkeleton(
                    width: MediaQuery.sizeOf(context).width * 0.3, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state placeholder matching spec §6 "never show a blank screen".
class GVEmptyState extends StatelessWidget {
  const GVEmptyState({
    super.key,
    required this.title,
    this.description,
    this.action,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String? description;
  final Widget? action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GVSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: GVColors.textDisabled),
            const SizedBox(height: GVSpacing.md),
            Text(title,
                style: GVTypography.h3, textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: GVSpacing.sm),
              Text(description!,
                  style: GVTypography.body
                      .copyWith(color: GVColors.textSecondary),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: GVSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with retry action.
class GVErrorState extends StatelessWidget {
  const GVErrorState({
    super.key,
    this.message = 'Something went wrong. Please try again.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GVSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 48, color: GVColors.textDisabled),
            const SizedBox(height: GVSpacing.md),
            Text(message,
                style: GVTypography.body
                    .copyWith(color: GVColors.textSecondary),
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: GVSpacing.lg),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Offline banner that appears at the top of the screen when disconnected.
class GVOfflineBanner extends StatelessWidget {
  const GVOfflineBanner({super.key, this.visible = true});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: GVDurations.medium,
      child: visible
          ? Container(
              key: const ValueKey('offline'),
              width: double.infinity,
              color: GVColors.warning,
              padding: const EdgeInsets.symmetric(
                vertical: GVSpacing.sm,
                horizontal: GVSpacing.md,
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off,
                      size: 16, color: GVColors.nearBlack),
                  const SizedBox(width: GVSpacing.sm),
                  Text(
                    'You\'re offline. Some features may be unavailable.',
                    style: GVTypography.caption
                        .copyWith(color: GVColors.nearBlack),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('online')),
    );
  }
}

/// Bottom sheet for consequential actions (cancel, delete, skip).
///
/// Per spec §3: "Confirm before destructive actions."
class GVConfirmationSheet extends StatelessWidget {
  const GVConfirmationSheet({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    this.cancelLabel = 'Go back',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.isLoading = false,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool isLoading;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String description,
    required String confirmLabel,
    String cancelLabel = 'Go back',
    bool isDestructive = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: GVColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GVConfirmationSheet(
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        GVSpacing.lg,
        GVSpacing.lg,
        GVSpacing.lg,
        GVSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: GVColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: GVSpacing.lg),
          Text(title, style: GVTypography.h3),
          const SizedBox(height: GVSpacing.sm),
          Text(description,
              style: GVTypography.body
                  .copyWith(color: GVColors.textSecondary)),
          const SizedBox(height: GVSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDestructive ? GVColors.error : GVColors.brandGreen,
                foregroundColor:
                    isDestructive ? GVColors.white : GVColors.nearBlack,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(confirmLabel, style: GVTypography.buttonLarge),
            ),
          ),
          const SizedBox(height: GVSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: onCancel,
              child: Text(cancelLabel,
                  style: GVTypography.buttonLarge
                      .copyWith(color: GVColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}
