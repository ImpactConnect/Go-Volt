import 'dart:async';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/booking_notifier.dart';

/// Screen 11 — Finding a Rider ("Searching for a nearby rider")
///
/// Features:
/// - Smooth animated concentric radar waves with nearby driver markers.
/// - Dynamic 4-step matching checklist.
/// - Status notification alert.
/// - Cancellation action with confirmation sheet.
class FindingDriverScreen extends ConsumerStatefulWidget {
  const FindingDriverScreen({
    super.key,
    this.autoAdvance = true,
  });

  final bool autoAdvance;

  @override
  ConsumerState<FindingDriverScreen> createState() => _FindingDriverScreenState();
}

class _FindingDriverScreenState extends ConsumerState<FindingDriverScreen> {
  int _currentStepIndex = 1; // 0: Sending, 1: Looking, 2: Confirming, 3: Finalizing
  Timer? _stepTimer;
  Timer? _completionTimer;

  static const List<String> _steps = [
    'Sending your request',
    'Looking for nearby riders',
    'Confirming rider',
    'Finalizing your ride',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.autoAdvance) {
      _startStepProgression();
    }
  }

  void _startStepProgression() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentStepIndex < _steps.length - 1) {
        setState(() {
          _currentStepIndex++;
        });
      } else {
        timer.cancel();
        _navigateToLiveTracking();
      }
    });
  }

  void _navigateToLiveTracking() {
    _completionTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (GoRouter.maybeOf(context) != null) {
        context.go(AppRoutes.liveTracking);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.liveTracking);
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _completionTimer?.cancel();
    super.dispose();
  }

  void _handleBack() {
    _confirmCancel();
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2621) : GVColors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(GVBorderRadius.xl),
            ),
          ),
          padding: const EdgeInsets.all(GVSpacing.lg),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? GVColors.neutral700 : GVColors.neutral300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: GVSpacing.md),
                Text(
                  'Cancel ride request?',
                  style: GVTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: GVSpacing.sm),
                Text(
                  'Are you sure you want to cancel? No cancellation fee applies before a rider is assigned.',
                  style: GVTypography.bodyMedium.copyWith(
                    color: isDark ? GVColors.neutral400 : GVColors.neutral600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: GVSpacing.xl),
                GVPrimaryButton(
                  label: 'Keep searching',
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
                const SizedBox(height: GVSpacing.sm),
                GVOutlinedButton(
                  label: 'Cancel ride',
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      _stepTimer?.cancel();
      _completionTimer?.cancel();
      ref.read(bookingNotifierProvider.notifier).resetFlow();
      if (GoRouter.maybeOf(context) != null) {
        context.go(AppRoutes.home);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Screen 11 Radar & Status View
          SafeArea(
            child: GVRadarMatchingView(
              currentStep: _currentStepIndex,
              steps: _steps,
              title: 'Finding a rider for you...',
              subtitle: 'This usually takes less than 1 minute.',
              noticeText: "You'll be notified as soon as a rider accepts your request.",
              cancelButtonText: 'Cancel ride',
              onCancel: _confirmCancel,
            ),
          ),

          // Floating Back Arrow Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: GVColors.textPrimary, size: 20),
                    onPressed: _handleBack,
                    tooltip: 'Back',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
