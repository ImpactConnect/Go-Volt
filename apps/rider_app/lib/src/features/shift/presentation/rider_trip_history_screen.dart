import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripHistoryItem {
  const TripHistoryItem({
    required this.route,
    required this.date,
    required this.fare,
    required this.status,
    required this.service,
  });

  final String route;
  final String date;
  final String fare;
  final String status;
  final String service;
}

/// Screen RD31: Driver Trip History & Activity (Tab 3 in 5-tab shell).
class RiderTripHistoryScreen extends ConsumerStatefulWidget {
  const RiderTripHistoryScreen({super.key});

  @override
  ConsumerState<RiderTripHistoryScreen> createState() =>
      _RiderTripHistoryScreenState();
}

class _RiderTripHistoryScreenState
    extends ConsumerState<RiderTripHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Completed', 'Cancelled'];

  final List<TripHistoryItem> _trips = const [
    TripHistoryItem(
      route: 'Victoria Island → Lekki Phase 1',
      date: 'Today, 2:30 PM',
      fare: '₦2,100',
      status: 'Completed',
      service: 'Passenger EV Ride',
    ),
    TripHistoryItem(
      route: 'Kaduna Mall → Barnawa',
      date: 'Today, 1:45 PM',
      fare: '₦3,200',
      status: 'Completed',
      service: 'Express Delivery',
    ),
    TripHistoryItem(
      route: 'Tudun Wada → Kawo',
      date: 'Today, 12:10 PM',
      fare: '₦2,800',
      status: 'Completed',
      service: 'Passenger Ride',
    ),
    TripHistoryItem(
      route: 'Mando → Rigasa',
      date: 'Today, 11:05 AM',
      fare: '₦2,500',
      status: 'Completed',
      service: 'Parcel Delivery',
    ),
    TripHistoryItem(
      route: 'Kakuri → Sabon Tasha',
      date: 'Today, 09:30 AM',
      fare: '₦3,000',
      status: 'Completed',
      service: 'School-Run Leg',
    ),
    TripHistoryItem(
      route: 'Ikeja GRA → Maryland Mall',
      date: 'Yesterday, 5:15 PM',
      fare: '₦1,900',
      status: 'Completed',
      service: 'Passenger EV Ride',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _trips.where((t) {
      if (_selectedFilter == 'All') return true;
      return t.status == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        title: const Text(
          'Trip History',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md, vertical: GVSpacing.sm),
              child: Row(
                children: _filters.map((f) {
                  final isSelected = f == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = f),
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
                          f,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Trips List
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
                            Icons.two_wheeler,
                            color: GVColors.brandGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: GVSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.route,
                                style: GVTypography.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.date} · ${item.service}',
                                style: GVTypography.caption.copyWith(color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.fare,
                              style: GVTypography.bodyMedium.copyWith(
                                color: GVColors.brandGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.status,
                              style: GVTypography.caption.copyWith(color: Colors.white54, fontSize: 11),
                            ),
                          ],
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
}
