import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen RD05: Account Under Review / Application Submitted (Board 1 Screen 5).
class RiderApplicationReviewScreen extends ConsumerWidget {
  const RiderApplicationReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Account Under Review',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: GVSpacing.lg),

              // Header Document Illustration / Icon with Clock Badge
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2420),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GVColors.brandGreen.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.description_outlined,
                          color: Colors.white70,
                          size: 44,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: GVColors.brandGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: GVColors.darkBg, width: 3),
                        ),
                        child: const Icon(
                          Icons.access_time_filled,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Headline & Subtext
              Text(
                'Application Submitted',
                textAlign: TextAlign.center,
                style: GVTypography.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Your information is being reviewed. We will notify you once your account is approved. This usually takes up to 24 hours.',
                textAlign: TextAlign.center,
                style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
              ),
              const SizedBox(height: GVSpacing.xxl),

              // 5-Stage Stepper
              Container(
                padding: const EdgeInsets.all(GVSpacing.lg),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2420),
                  borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                  border: Border.all(color: const Color(0xFF2A3630)),
                ),
                child: const GVTimelineStepper(
                  steps: [
                    GVTimelineStepItem(
                      title: 'Account Created',
                      state: GVStepState.completed,
                    ),
                    GVTimelineStepItem(
                      title: 'Identity Verified',
                      state: GVStepState.completed,
                    ),
                    GVTimelineStepItem(
                      title: 'Vehicle Information Submitted',
                      state: GVStepState.completed,
                    ),
                    GVTimelineStepItem(
                      title: 'Under Review',
                      subtitle: 'Estimated time: 24 hours',
                      state: GVStepState.inProgress,
                    ),
                    GVTimelineStepItem(
                      title: 'Approved',
                      subtitle: 'You can go online and start receiving ride requests.',
                      state: GVStepState.pending,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xxl),

              // Go to Dashboard Button
              GVOutlinedButton(
                label: 'Go to Dashboard',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: GVSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
