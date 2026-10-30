import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/merchant_auth_notifier.dart';

class MerchantSidebar extends ConsumerWidget {
  const MerchantSidebar({
    super.key,
    required this.currentRoute,
  });

  final String currentRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(merchantAuthNotifierProvider);
    final role = userState.role;

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF0F1512),
        border: Border(
          right: BorderSide(color: Color(0xFF1F2B24), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Brand Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: GVColors.brandGreen,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: GVColors.brandGreen.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.bolt, color: Colors.black, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'GO',
                          style: GVTypography.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '·',
                          style: GVTypography.h3.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'VOLTS',
                          style: GVTypography.h3.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'MERCHANT PORTAL',
                      style: GVTypography.caption.copyWith(
                        color: Colors.white54,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Active Branch Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF16211C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF24362E)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, color: GVColors.brandGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACTIVE BRANCH',
                          style: GVTypography.caption.copyWith(
                            color: Colors.white54,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userState.activeBranchName,
                          style: GVTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1D2821), height: 1),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                _buildSectionHeader('OPERATIONS'),
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: 'Dashboard Overview',
                  route: '/dashboard',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.local_shipping_outlined,
                  activeIcon: Icons.local_shipping,
                  title: 'Delivery Bookings',
                  route: '/bookings',
                  badgeCount: 3,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle,
                  title: 'Create Delivery',
                  route: '/create-delivery',
                  highlight: true,
                ),

                const SizedBox(height: 16),
                _buildSectionHeader('MANAGEMENT'),
                if (role.canManageStaff)
                  _buildNavItem(
                    context: context,
                    icon: Icons.storefront_outlined,
                    activeIcon: Icons.storefront,
                    title: 'Branches & Staff',
                    route: '/branches',
                  ),
                if (role.canViewBilling)
                  _buildNavItem(
                    context: context,
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    title: 'Invoices & Billing',
                    route: '/billing',
                  ),

                if (role.canAccessDeveloperApi) ...[
                  const SizedBox(height: 16),
                  _buildSectionHeader('DEVELOPER & PARTNER'),
                  _buildNavItem(
                    context: context,
                    icon: Icons.code_outlined,
                    activeIcon: Icons.code,
                    title: 'Partner API & Keys',
                    route: '/developer',
                  ),
                ],
              ],
            ),
          ),

          // User Profile Card at Bottom
          const Divider(color: Color(0xFF1D2821), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF16211C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: GVColors.brandGreen.withValues(alpha: 0.2),
                    child: Text(
                      userState.fullName.isNotEmpty ? userState.fullName[0] : 'M',
                      style: const TextStyle(color: GVColors.brandGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userState.fullName,
                          style: GVTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          role.label,
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
    int? badgeCount,
    bool highlight = false,
  }) {
    final isSelected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (highlight ? GVColors.brandGreen.withValues(alpha: 0.25) : const Color(0xFF1C2720))
                : (highlight ? GVColors.brandGreen.withValues(alpha: 0.1) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: highlight ? GVColors.brandGreen : const Color(0xFF2A3D32))
                : (highlight ? Border.all(color: GVColors.brandGreen.withValues(alpha: 0.3)) : null),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 18,
                color: isSelected
                    ? GVColors.brandGreen
                    : (highlight ? GVColors.brandGreen : Colors.white70),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected || highlight ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: GVColors.brandGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
