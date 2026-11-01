import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_shadows.dart';

/// Bottom tab navigation destinations matching Go-Volts specification.
enum GVNavTab {
  home,
  send,
  scheduled,
  activity,
  profile,
  rewards,
  wallet;

  // Backward compatibility aliases
  static const GVNavTab trips = activity;
  static const GVNavTab plans = scheduled;
  static const GVNavTab account = profile;
}

/// Go-Volts bottom navigation bar.
///
/// Persistent 5-tab navigation: Home, Send, Scheduled, Activity, Profile.
/// Theme-aware supporting both Light and Dark mode.
class GVBottomNavigation extends StatelessWidget {
  const GVBottomNavigation({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.tabs = defaultTabs,
  });

  static const List<GVNavTab> defaultTabs = [
    GVNavTab.home,
    GVNavTab.send,
    GVNavTab.scheduled,
    GVNavTab.activity,
    GVNavTab.profile,
  ];

  final GVNavTab currentTab;
  final ValueChanged<GVNavTab> onTabSelected;
  final List<GVNavTab> tabs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1512) : GVColors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;
    final unselectedColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: GVShadows.elevated,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: tabs.map((tab) {
              final selected = tab == currentTab;
              return Expanded(
                child: InkWell(
                  onTap: () => onTabSelected(tab),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _iconFor(tab, selected: selected),
                        color: selected
                            ? GVColors.brandGreen
                            : unselectedColor,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _labelFor(tab),
                        style: GVTypography.caption.copyWith(
                          color: selected
                              ? GVColors.brandGreen
                              : unselectedColor,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(GVNavTab tab, {required bool selected}) => switch (tab) {
        GVNavTab.home =>
          selected ? Icons.home_rounded : Icons.home_outlined,
        GVNavTab.send =>
          selected ? Icons.local_shipping_rounded : Icons.local_shipping_outlined,
        GVNavTab.scheduled =>
          selected ? Icons.calendar_month_rounded : Icons.calendar_month_outlined,
        GVNavTab.activity =>
          selected ? Icons.receipt_long_rounded : Icons.receipt_long_outlined,
        GVNavTab.profile =>
          selected ? Icons.person_rounded : Icons.person_outline_rounded,
        GVNavTab.rewards =>
          selected ? Icons.card_giftcard_rounded : Icons.card_giftcard_outlined,
        GVNavTab.wallet =>
          selected ? Icons.account_balance_wallet_rounded : Icons.account_balance_wallet_outlined,
      };

  String _labelFor(GVNavTab tab) => switch (tab) {
        GVNavTab.home => 'Home',
        GVNavTab.send => 'Send',
        GVNavTab.scheduled => 'Scheduled',
        GVNavTab.activity => 'Activity',
        GVNavTab.profile => 'Profile',
        GVNavTab.rewards => 'Rewards',
        GVNavTab.wallet => 'Wallet',
      };
}
