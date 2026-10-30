import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_shadows.dart';

/// Bottom tab navigation destinations.
enum GVNavTab { home, trips, plans, wallet, account }

/// Go-Volts bottom navigation bar.
///
/// Bottom navigation: Home, Trips, Plans, Wallet, Account.
/// Per spec §3: hide during auth and focused checkout/safety flows.
class GVBottomNavigation extends StatelessWidget {
  const GVBottomNavigation({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final GVNavTab currentTab;
  final ValueChanged<GVNavTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: GVColors.white,
        border: Border(top: BorderSide(color: GVColors.border)),
        boxShadow: GVShadows.elevated,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: GVNavTab.values.map((tab) {
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
                            : GVColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _labelFor(tab),
                        style: GVTypography.caption.copyWith(
                          color: selected
                              ? GVColors.brandGreen
                              : GVColors.textSecondary,
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
        GVNavTab.trips =>
          selected ? Icons.directions_bike : Icons.directions_bike_outlined,
        GVNavTab.plans =>
          selected ? Icons.calendar_month : Icons.calendar_month_outlined,
        GVNavTab.wallet =>
          selected ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
        GVNavTab.account =>
          selected ? Icons.person_rounded : Icons.person_outline,
      };

  String _labelFor(GVNavTab tab) => switch (tab) {
        GVNavTab.home => 'Home',
        GVNavTab.trips => 'Trips',
        GVNavTab.plans => 'Plans',
        GVNavTab.wallet => 'Wallet',
        GVNavTab.account => 'Account',
      };
}
