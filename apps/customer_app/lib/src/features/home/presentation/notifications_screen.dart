import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum NotificationCategory { all, trips, plans, payments, offers }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.category,
    this.isRead = false,
    this.route,
  });

  final String id;
  final String title;
  final String message;
  final String timestamp;
  final NotificationCategory category;
  final bool isRead;
  final String? route;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      category: category,
      isRead: isRead ?? this.isRead,
      route: route,
    );
  }
}

/// Screen H06: Notifications Center with Categorized Filter Tabs and Deep Links.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationCategory _selectedCategory = NotificationCategory.all;

  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      const NotificationItem(
        id: 'notif_1',
        title: 'Driver Approaching Pickup',
        message: 'Babajide Ogundipe is 2 minutes away at 14 Marina Road in Spiro EV.',
        timestamp: '10 mins ago',
        category: NotificationCategory.trips,
        isRead: false,
        route: '/live-tracking',
      ),
      const NotificationItem(
        id: 'notif_2',
        title: 'School-Run Handover Security Code',
        message: 'Your single-use morning pickup verification OTP is 482910.',
        timestamp: '2 hours ago',
        category: NotificationCategory.plans,
        isRead: false,
        route: '/school-run-safety',
      ),
      const NotificationItem(
        id: 'notif_3',
        title: 'Wallet Top-Up Successful',
        message: '₦10,000 has been credited to your Go-Volts ride wallet via Paystack.',
        timestamp: 'Yesterday, 18:30',
        category: NotificationCategory.payments,
        isRead: true,
        route: '/wallet',
      ),
      const NotificationItem(
        id: 'notif_4',
        title: 'Lagos Island Zero-Emission Discount',
        message: 'Use code VOLT50 for 50% off your next 3 electric commutes this weekend.',
        timestamp: '2 days ago',
        category: NotificationCategory.offers,
        isRead: true,
        route: '/wallet-rewards',
      ),
      const NotificationItem(
        id: 'notif_5',
        title: 'Scheduled Commute Plan Approved',
        message: 'Your Lekki-VI work commute quote has been approved. 48-hour countdown active.',
        timestamp: '3 days ago',
        category: NotificationCategory.plans,
        isRead: true,
        route: '/scheduled-plans',
      ),
    ];
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        backgroundColor: GVColors.deepGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == NotificationCategory.all
        ? _notifications
        : _notifications.where((n) => n.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _notifications.any((n) => !n.isRead) ? _markAllAsRead : null,
            child: const Text('Mark all read', style: TextStyle(color: GVColors.brandGreen)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tabs
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All', NotificationCategory.all),
                  _buildFilterChip('Trips', NotificationCategory.trips),
                  _buildFilterChip('Plans', NotificationCategory.plans),
                  _buildFilterChip('Payments', NotificationCategory.payments),
                  _buildFilterChip('Offers', NotificationCategory.offers),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.sm),

            // Notification List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                          const SizedBox(height: GVSpacing.md),
                          Text(
                            'No notifications in this category',
                            style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final notif = filtered[index];
                        return _buildNotificationCard(notif);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationCategory category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: GVColors.deepGreen,
        backgroundColor: const Color(0xFF1C2420),
        labelStyle: TextStyle(
          color: isSelected ? GVColors.brandGreen : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (val) {
          if (val) setState(() => _selectedCategory = category);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: notif.isRead ? const Color(0xFF1C2420) : const Color(0xFF223129),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(
          color: notif.isRead ? const Color(0xFF2A3630) : GVColors.brandGreen.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            final idx = _notifications.indexWhere((n) => n.id == notif.id);
            if (idx != -1) {
              _notifications[idx] = _notifications[idx].copyWith(isRead: true);
            }
          });
          if (notif.route != null) {
            try {
              context.push(notif.route!);
            } catch (_) {
              // Standalone fallback
            }
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(notif.category).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(notif.category),
                color: _getCategoryColor(notif.category),
                size: 20,
              ),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: GVTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notif.timestamp,
                        style: GVTypography.caption.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: GVTypography.caption.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.trips:
        return Icons.two_wheeler;
      case NotificationCategory.plans:
        return Icons.calendar_month;
      case NotificationCategory.payments:
        return Icons.account_balance_wallet;
      case NotificationCategory.offers:
        return Icons.local_offer;
      case NotificationCategory.all:
        return Icons.notifications;
    }
  }

  Color _getCategoryColor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.trips:
        return GVColors.brandGreen;
      case NotificationCategory.plans:
        return Colors.lightBlueAccent;
      case NotificationCategory.payments:
        return Colors.amber;
      case NotificationCategory.offers:
        return Colors.orangeAccent;
      case NotificationCategory.all:
        return Colors.white70;
    }
  }
}
