import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_shadows.dart';

/// Driver App bottom tab navigation destinations.
enum GVDriverNavTab {
  home,
  earnings,
  trips,
  inbox,
  account,
}

/// Go-Volts Driver App bottom navigation bar.
///
/// Implements the 5-tab driver shell: Home, Earnings, Trips, Inbox, Account.
/// Includes badge support for unread messages or notifications.
class GVDriverBottomNavigation extends StatelessWidget {
  const GVDriverBottomNavigation({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.inboxBadgeCount = 0,
    this.tripsBadgeCount = 0,
  });

  final GVDriverNavTab currentTab;
  final ValueChanged<GVDriverNavTab> onTabSelected;
  final int inboxBadgeCount;
  final int tripsBadgeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141917),
        border: Border(
          top: BorderSide(color: Color(0xFF232D28), width: 1),
        ),
        boxShadow: GVShadows.elevated,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: GVDriverNavTab.values.map((tab) {
              final selected = tab == currentTab;
              return Expanded(
                child: InkWell(
                  onTap: () => onTabSelected(tab),
                  splashColor: GVColors.brandGreen.withValues(alpha: 0.1),
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            _iconFor(tab, selected: selected),
                            color: selected
                                ? GVColors.brandGreen
                                : Colors.white60,
                            size: 24,
                          ),
                          if (tab == GVDriverNavTab.inbox && inboxBadgeCount > 0)
                            Positioned(
                              top: -4,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  inboxBadgeCount > 9 ? '9+' : '$inboxBadgeCount',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (tab == GVDriverNavTab.trips && tripsBadgeCount > 0)
                            Positioned(
                              top: -4,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: GVColors.brandGreen,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  tripsBadgeCount > 9 ? '9+' : '$tripsBadgeCount',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _labelFor(tab),
                        style: GVTypography.caption.copyWith(
                          color: selected
                              ? GVColors.brandGreen
                              : Colors.white60,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 11,
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

  IconData _iconFor(GVDriverNavTab tab, {required bool selected}) {
    return switch (tab) {
      GVDriverNavTab.home => selected ? Icons.home : Icons.home_outlined,
      GVDriverNavTab.earnings =>
        selected ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
      GVDriverNavTab.trips =>
        selected ? Icons.receipt_long : Icons.receipt_long_outlined,
      GVDriverNavTab.inbox =>
        selected ? Icons.chat_bubble : Icons.chat_bubble_outline,
      GVDriverNavTab.account =>
        selected ? Icons.person : Icons.person_outline,
    };
  }

  String _labelFor(GVDriverNavTab tab) {
    return switch (tab) {
      GVDriverNavTab.home => 'Home',
      GVDriverNavTab.earnings => 'Earnings',
      GVDriverNavTab.trips => 'Trips',
      GVDriverNavTab.inbox => 'Inbox',
      GVDriverNavTab.account => 'Account',
    };
  }
}
