import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/admin_auth_notifier.dart';

class AdminSidebarItem {
  const AdminSidebarItem({
    required this.title,
    required this.icon,
    required this.route,
    this.badge,
    this.badgeColor,
    required this.isVisible,
  });

  final String title;
  final IconData icon;
  final String route;
  final String? badge;
  final Color? badgeColor;
  final bool isVisible;
}

class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({
    super.key,
    required this.currentRoute,
  });

  final String currentRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(adminAuthNotifierProvider);
    final role = authState.role;

    final List<Map<String, dynamic>> groups = [
      {
        'group': 'LIVE OPERATIONS',
        'items': [
          AdminSidebarItem(
            title: 'Live Operations',
            icon: Icons.dashboard_outlined,
            route: '/overview',
            badge: 'LIVE',
            badgeColor: GVColors.brandGreen,
            isVisible: role.canAccessOperations,
          ),
          AdminSidebarItem(
            title: 'Bookings & Trips',
            icon: Icons.receipt_long_outlined,
            route: '/bookings',
            isVisible: role.canAccessOperations,
          ),
        ],
      },
      {
        'group': 'FLEET & PARTNERS',
        'items': [
          AdminSidebarItem(
            title: 'Riders & KYC',
            icon: Icons.electric_moped_outlined,
            route: '/riders',
            badge: '3 Review',
            badgeColor: Colors.amber,
            isVisible: role.canAccessRiders,
          ),
          AdminSidebarItem(
            title: 'Merchants & Hubs',
            icon: Icons.storefront_outlined,
            route: '/merchants',
            isVisible: role.canAccessOperations,
          ),
        ],
      },
      {
        'group': 'COMMERCIAL & GROWTH',
        'items': [
          AdminSidebarItem(
            title: 'Pricing & Zones',
            icon: Icons.price_change_outlined,
            route: '/pricing',
            isVisible: role.canAccessPricing,
          ),
          AdminSidebarItem(
            title: 'Promotions & Loyalty',
            icon: Icons.card_giftcard_outlined,
            route: '/promotions',
            isVisible: role.canAccessPromotions,
          ),
        ],
      },
      {
        'group': 'GOVERNANCE & AUDIT',
        'items': [
          AdminSidebarItem(
            title: 'Finance & Refunds',
            icon: Icons.account_balance_wallet_outlined,
            route: '/finance',
            badge: '1 Req',
            badgeColor: Colors.redAccent,
            isVisible: role.canAccessFinance,
          ),
          AdminSidebarItem(
            title: 'Support & Safety',
            icon: Icons.shield_outlined,
            route: '/support',
            isVisible: role.canAccessSafety || role.canAccessOperations,
          ),
          AdminSidebarItem(
            title: 'Audit Logs',
            icon: Icons.history_outlined,
            route: '/audit',
            isVisible: role.canAccessAudit,
          ),
          AdminSidebarItem(
            title: 'Integrations (Retail Ai)',
            icon: Icons.hub_outlined,
            route: '/integrations',
            isVisible: role.canAccessIntegrations,
          ),
        ],
      },
    ];

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF101713),
        border: Border(
          right: BorderSide(color: Color(0xFF1F2B25), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo & Branding
          Container(
            padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md, vertical: GVSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1F2B25))),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: GVColors.deepGreen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GVColors.brandGreen),
                    boxShadow: GVShadows.glow,
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: GVColors.brandGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GO-VOLTS',
                      style: GVTypography.h3.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ADMIN CONSOLE',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: GVSpacing.sm),
              children: groups.map((g) {
                final groupTitle = g['group'] as String;
                final allItems = g['items'] as List<AdminSidebarItem>;
                final visibleItems = allItems.where((i) => i.isVisible).toList();

                if (visibleItems.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 6),
                      child: Text(
                        groupTitle,
                        style: GVTypography.caption.copyWith(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    ...visibleItems.map((item) {
                      final isSelected = currentRoute == item.route ||
                          (item.route != '/overview' && currentRoute.startsWith(item.route));

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              if (currentRoute != item.route) {
                                context.go(item.route);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF173827) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(color: GVColors.brandGreen.withValues(alpha: 0.5))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 18,
                                    color: isSelected ? GVColors.brandGreen : Colors.white60,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: GVTypography.bodySmall.copyWith(
                                        color: isSelected ? Colors.white : Colors.white70,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (item.badge != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (item.badgeColor ?? GVColors.brandGreen)
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: (item.badgeColor ?? GVColors.brandGreen)
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                      child: Text(
                                        item.badge!,
                                        style: GVTypography.caption.copyWith(
                                          color: item.badgeColor ?? GVColors.brandGreen,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),

          // Role Switcher Footer
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1F2B25))),
              color: Color(0xFF0C120F),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE ROLE',
                      style: GVTypography.caption.copyWith(
                        color: Colors.white38,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'STAGING',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14241B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF274332)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user, size: 14, color: GVColors.brandGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          role.label,
                          style: GVTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
