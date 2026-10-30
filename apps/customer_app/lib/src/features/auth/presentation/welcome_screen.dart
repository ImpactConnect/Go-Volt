import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

/// Screen 2: Welcome / Onboarding Screen (AUTH-01-WELCOME)
/// Specification Section 3 & Design Board 1/2.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _currentSlide = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Move faster.\nGo greener.\nGo further.',
      subtitle: 'Reliable rides and deliveries powered by clean energy.',
      icon: Icons.two_wheeler_rounded,
    ),
    _OnboardingSlide(
      title: 'Smart, silent\nurban commutes.',
      subtitle: 'Book verified electric motorcycle rides across Lagos Island with upfront fares.',
      icon: Icons.electric_bolt_rounded,
    ),
    _OnboardingSlide(
      title: 'Doorstep deliveries\nwith zero emissions.',
      subtitle: 'Send parcels and track riders in real time while reducing your carbon footprint.',
      icon: Icons.local_shipping_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral300 : GVColors.textSecondary;
    final slide = _slides[_currentSlide];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Skip Action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.push(AppRoutes.login),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? GVColors.neutral300 : GVColors.textSecondary,
                    ),
                    child: Text(
                      'Skip',
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.md),

              // Title Headline
              Text(
                slide.title,
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: GVSpacing.sm),

              // Subtitle
              Text(
                slide.subtitle,
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),

              // Center Hero Illustration Graphic
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF1C2621)
                                : GVColors.brandGreen.withValues(alpha: 0.1),
                            border: Border.all(
                              color: GVColors.brandGreen.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              slide.icon,
                              size: 90,
                              color: GVColors.brandGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: GVSpacing.md),

                        // 3-Dot Pagination Carousel Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_slides.length, (index) {
                            final isActive = index == _currentSlide;
                            return GestureDetector(
                              onTap: () => setState(() => _currentSlide = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? GVColors.brandGreen
                                      : (isDark ? GVColors.neutral700 : GVColors.neutral300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Actions
              Column(
                children: [
                  // Primary Button: "Get started ->"
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.push(AppRoutes.signupOptions),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GVColors.brandGreen,
                        foregroundColor: GVColors.nearBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GVBorderRadius.full),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get started',
                            style: GVTypography.buttonLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: GVColors.nearBlack,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20, color: GVColors.nearBlack),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: GVSpacing.sm),

                  // Secondary Button: "I already have an account / Log in"
                  TextButton(
                    onPressed: () => context.push(AppRoutes.login),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : GVColors.textPrimary,
                    ),
                    child: Text(
                      'I already have an account',
                      style: GVTypography.buttonMedium.copyWith(
                        color: isDark ? GVColors.neutral300 : GVColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
