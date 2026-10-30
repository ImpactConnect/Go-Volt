import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/router/app_router.dart';

/// Screen 1: Splash Screen (AUTH-00-SPLASH)
/// Specification Section 2 & Design Board 1/2.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Non-blocking Supabase session check per spec §2.4
      ref.read(authNotifierProvider.notifier).checkSession();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(AppRoutes.home);
      } else if (next.status == AuthStatus.unauthenticated ||
          next.status == AuthStatus.error) {
        context.go(AppRoutes.welcome);
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF0F1B14), Color(0xFF0B140F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF022C22)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Subtle background glow
              Center(
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        GVColors.brandGreen.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Centered Brand Content
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bolt Logo Icon with Glow
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B0F0D),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: GVColors.limeHighlight.withValues(alpha: 0.5),
                              width: 2.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GVColors.brandGreen.withValues(alpha: 0.45),
                                blurRadius: 32,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.electric_bolt_rounded,
                              size: 48,
                              color: GVColors.limeHighlight,
                            ),
                          ),
                        ),
                        const SizedBox(height: GVSpacing.lg),

                        // Branded Wordmark
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'GO-VOLTS',
                              style: GVTypography.display.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.5,
                                fontSize: 32,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: GVSpacing.xs),

                        // Official Tagline
                        Text(
                          'Rides. Deliveries. A Greener Tomorrow.',
                          style: GVTypography.bodyMedium.copyWith(
                            color: GVColors.limeHighlight,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom EV Motorbike & Skyline Illustration Graphic
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Opacity(
                  opacity: 0.7,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.two_wheeler_rounded,
                        size: 96,
                        color: GVColors.brandGreen.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: GVSpacing.sm),
                      Container(
                        height: 4,
                        width: 140,
                        decoration: BoxDecoration(
                          color: GVColors.brandGreen.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: GVSpacing.md),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
