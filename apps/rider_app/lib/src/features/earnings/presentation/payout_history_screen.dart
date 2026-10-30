import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum PayoutFilter { all, completed, pending }

class PayoutRecord {
  const PayoutRecord({
    required this.amount,
    required this.bankName,
    required this.dateTime,
    required this.isCompleted,
  });

  final String amount;
  final String bankName;
  final String dateTime;
  final bool isCompleted;
}

/// Screen RD23: Payout and Withdrawal History (Board 4 Screen 5).
class PayoutHistoryScreen extends ConsumerStatefulWidget {
  const PayoutHistoryScreen({super.key});

  @override
  ConsumerState<PayoutHistoryScreen> createState() =>
      _PayoutHistoryScreenState();
}

class _PayoutHistoryScreenState extends ConsumerState<PayoutHistoryScreen> {
  PayoutFilter _currentFilter = PayoutFilter.all;

  final List<PayoutRecord> _records = const [
    PayoutRecord(
      amount: '₦20,000',
      bankName: 'Withdraw to GTBank',
      dateTime: '24 Oct 2026, 6:30 PM',
      isCompleted: true,
    ),
    PayoutRecord(
      amount: '₦15,000',
      bankName: 'Withdraw to GTBank',
      dateTime: '20 Oct 2026, 4:12 PM',
      isCompleted: true,
    ),
    PayoutRecord(
      amount: '₦25,000',
      bankName: 'Withdraw to GTBank',
      dateTime: '15 Oct 2026, 2:45 PM',
      isCompleted: true,
    ),
    PayoutRecord(
      amount: '₦10,000',
      bankName: 'Withdraw to GTBank',
      dateTime: '10 Oct 2026, 5:20 PM',
      isCompleted: true,
    ),
    PayoutRecord(
      amount: '₦18,000',
      bankName: 'Withdraw to GTBank',
      dateTime: '5 Oct 2026, 3:18 PM',
      isCompleted: false,
    ),
    PayoutRecord(
      amount: '₦12,000',
      bankName: 'Withdraw to GTBank',
      dateTime: '28 Sep 2026, 1:10 PM',
      isCompleted: true,
    ),
    PayoutRecord(
      amount: '₦22,000',
      bankName: 'Withdraw to GTBank',
      dateTime: '22 Sep 2026, 11:05 AM',
      isCompleted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _records.where((rec) {
      if (_currentFilter == PayoutFilter.completed) return rec.isCompleted;
      if (_currentFilter == PayoutFilter.pending) return !rec.isCompleted;
      return true;
    }).toList();

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
          'Payout History',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md, vertical: GVSpacing.sm),
              child: Row(
                children: [
                  _buildFilterChip('All', PayoutFilter.all),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', PayoutFilter.completed),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', PayoutFilter.pending),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.xs),

            // History List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(GVSpacing.md),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: GVSpacing.sm),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Container(
                    padding: const EdgeInsets.all(GVSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2420),
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      border: Border.all(color: const Color(0xFF2A3630)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: GVColors.deepGreen.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(GVBorderRadius.md),
                          ),
                          child: const Icon(
                            Icons.arrow_upward,
                            color: GVColors.brandGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: GVSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.amount,
                                style: GVTypography.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.bankName}\n${item.dateTime}',
                                style: GVTypography.caption.copyWith(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GVStatusChip(
                          label: item.isCompleted ? 'Completed' : 'Pending',
                          status: item.isCompleted ? GVStatusType.active : GVStatusType.pending,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, PayoutFilter filter) {
    final isSelected = _currentFilter == filter;
    return InkWell(
      onTap: () => setState(() => _currentFilter = filter),
      borderRadius: BorderRadius.circular(GVBorderRadius.full),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? GVColors.brandGreen : const Color(0xFF1C2420),
          borderRadius: BorderRadius.circular(GVBorderRadius.full),
          border: Border.all(
            color: isSelected ? GVColors.brandGreen : const Color(0xFF2A3630),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
