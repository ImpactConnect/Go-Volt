import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/shopping_errand_notifier.dart';

/// Screen A1 (ME-01): Market Errand Landing & Service Type Selector.
/// Matches high-fidelity design template Row 1 Screen A1.
class MarketErrandHomeScreen extends ConsumerWidget {
  const MarketErrandHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shoppingState = ref.watch(shoppingErrandNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? GVColors.white : GVColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Market Errand',
          style: GVTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.sm),

              // Active Errand Progress Banner (if active)
              if (shoppingState.activeErrand != null &&
                  shoppingState.activeErrand!.status.isActive) ...[
                _buildActiveErrandBanner(context, shoppingState),
                const SizedBox(height: GVSpacing.md),
              ],

              // Hero Banner (Illustration + Slogan)
              _buildHeroBanner(context, isDark),

              const SizedBox(height: GVSpacing.xl),

              Text(
                'Choose a service',
                style: GVTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? GVColors.neutral300 : GVColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              // Option 1: Buy Items From a Shop (Flow A)
              _buildServiceOptionCard(
                context,
                isDark: isDark,
                title: 'Buy Items From a Shop',
                description: 'We\'ll go to a shop or market, buy your items and deliver.',
                icon: Icons.shopping_basket_rounded,
                iconColor: const Color(0xFF059669),
                iconBgColor: const Color(0xFFE8F5E9),
                onTap: () {
                  ref.read(shoppingErrandNotifierProvider.notifier).resetFlow();
                  context.push(AppRoutes.errandSelectShop);
                },
              ),

              const SizedBox(height: GVSpacing.md),

              // Option 2: Pick Up a Package (Flow B)
              _buildServiceOptionCard(
                context,
                isDark: isDark,
                title: 'Pick Up a Package',
                description: 'We\'ll collect a package and deliver it to you.',
                icon: Icons.inventory_2_rounded,
                iconColor: const Color(0xFFE65100),
                iconBgColor: const Color(0xFFFFF3E0),
                onTap: () {
                  context.push(AppRoutes.errandPackagePickup);
                },
              ),

              const SizedBox(height: GVSpacing.md),

              // Option 3: Other Errand (Flow C)
              _buildServiceOptionCard(
                context,
                isDark: isDark,
                title: 'Other Errand',
                description: 'Tell us what you need help with.',
                icon: Icons.assignment_rounded,
                iconColor: const Color(0xFF5E35B1),
                iconBgColor: const Color(0xFFEDE7F6),
                onTap: () {
                  context.push(AppRoutes.errandDescribeTask);
                },
              ),

              const SizedBox(height: GVSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GVSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2C24) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
        border: Border.all(
          color: isDark ? const Color(0xFF2E4C3C) : const Color(0xFFC8E6C9),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get things done easily',
                  style: GVTypography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? GVColors.white : const Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: GVSpacing.xs),
                Text(
                  'Buy items, pick up packages or run other errands for you.',
                  style: GVTypography.bodyMedium.copyWith(
                    color: isDark ? GVColors.neutral300 : const Color(0xFF2E7D32),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: GVSpacing.sm),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2E4C3C) : GVColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.electric_moped_rounded,
              size: 40,
              color: Color(0xFF00C853),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOptionCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F1A) : GVColors.white,
        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(GVBorderRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(GVSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? iconColor.withValues(alpha: 0.18) : iconBgColor,
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: GVSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GVTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: GVTypography.bodySmall.copyWith(
                          color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? GVColors.neutral500 : const Color(0xFF9E9E9E),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveErrandBanner(BuildContext context, dynamic shoppingState) {
    final errand = shoppingState.activeErrand;
    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF00C853).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF00C853)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_rounded, color: Color(0xFF00C853)),
          const SizedBox(width: GVSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ongoing Errand: ${errand.referenceNumber}',
                  style: GVTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Status: ${errand.status.label}',
                  style: GVTypography.caption.copyWith(
                    color: GVColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GVOutlinedButton(
            label: 'Track',
            expanded: false,
            onPressed: () => context.push(AppRoutes.errandTracking),
          ),
        ],
      ),
    );
  }
}
