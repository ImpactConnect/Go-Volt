import 'dart:async';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../auth/merchant_auth_notifier.dart';
import '../auth/merchant_role.dart';

class MerchantTopBar extends ConsumerStatefulWidget {
  const MerchantTopBar({super.key});

  @override
  ConsumerState<MerchantTopBar> createState() => _MerchantTopBarState();
}

class _MerchantTopBarState extends ConsumerState<MerchantTopBar> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(merchantAuthNotifierProvider);
    final authNotifier = ref.read(merchantAuthNotifierProvider.notifier);
    final timeFormat = DateFormat('HH:mm:ss');
    final formattedTime = timeFormat.format(_now);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1512),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1F2B24), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Branch Dropdown Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF16211C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF24362E)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: userState.activeBranchId,
                  dropdownColor: const Color(0xFF16211C),
                  icon: const Icon(Icons.arrow_drop_down, color: GVColors.brandGreen),
                  style: GVTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'br_lekki_01',
                      child: Row(
                        children: [
                          Icon(Icons.storefront, size: 16, color: GVColors.brandGreen),
                          SizedBox(width: 8),
                          Text('Lekki Phase 1 Flagship'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'br_vi_02',
                      child: Row(
                        children: [
                          Icon(Icons.storefront, size: 16, color: GVColors.brandGreen),
                          SizedBox(width: 8),
                          Text('Victoria Island Central Hub'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'br_ikeja_03',
                      child: Row(
                        children: [
                          Icon(Icons.storefront, size: 16, color: GVColors.brandGreen),
                          SizedBox(width: 8),
                          Text('Ikeja City Mall Outlet'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      final name = val == 'br_lekki_01'
                          ? 'Lekki Phase 1 Flagship'
                          : (val == 'br_vi_02'
                              ? 'Victoria Island Central Hub'
                              : 'Ikeja City Mall Outlet');
                      authNotifier.switchBranch(branchId: val, branchName: name);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Corporate Wallet Balance Quick Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF122419),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GVColors.brandGreen.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 16, color: GVColors.brandGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Corporate Wallet: ',
                    style: GVTypography.caption.copyWith(color: Colors.white70),
                  ),
                  Text(
                    userState.formattedWalletBalance,
                    style: GVTypography.bodySmall.copyWith(
                      color: GVColors.brandGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Live Lagos WAT Clock
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF16211C),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF24362E)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: GVColors.brandGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$formattedTime WAT (Lagos)',
                    style: GVTypography.caption.copyWith(
                      color: Colors.white70,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Role View Switcher Simulator (Store Owner, Branch Manager, Dispatch Attendant)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1D16),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.manage_accounts, color: Colors.amber, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Simulate Role: ',
                    style: GVTypography.caption.copyWith(color: Colors.amber, fontSize: 11),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<MerchantRole>(
                      value: userState.role,
                      dropdownColor: const Color(0xFF211E16),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      items: MerchantRole.values.map((r) {
                        return DropdownMenuItem(
                          value: r,
                          child: Text(r.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) authNotifier.setRole(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
