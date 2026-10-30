import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/notifications_notifier.dart';

/// Screen 15: HOME-07-NOTIFICATIONS
///
/// Customer Notifications Center with category filters, unread synchronization,
/// deep-link navigation, and theme parity across Light & Dark modes.
/// Matches Screen 15 Design Board and Specification §13.2.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsState = ref.watch(notificationsNotifierProvider);
    final notifier = ref.read(notificationsNotifierProvider.notifier);

    final appBarBg = isDark ? const Color(0xFF0F1512) : Colors.white;
    final titleColor = isDark ? Colors.white : GVColors.textPrimary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: titleColor),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Notifications',
          style: GVTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: notificationsState.unreadCount > 0
                  ? () => notifier.markAllAsRead()
                  : null,
              child: Text(
                'Mark all read',
                style: GVTypography.label.copyWith(
                  color: notificationsState.unreadCount > 0
                      ? GVColors.brandGreen
                      : (isDark ? GVColors.neutral500 : GVColors.neutral400),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Horizontal Filter Categories: [All, Bookings, Promotions, Account]
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: NotificationCategory.values.map((category) {
                  final isSelected =
                      notificationsState.selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCategoryChip(
                      category: category,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () => notifier.selectCategory(category),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Notifications List
            Expanded(
              child: notificationsState.filteredNotifications.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      itemCount:
                          notificationsState.filteredNotifications.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notif =
                            notificationsState.filteredNotifications[index];
                        return GVNotificationItemTile(
                          title: notif.title,
                          message: notif.message,
                          timeAgo: notif.timeAgo,
                          isRead: notif.isRead,
                          onTap: () {
                            notifier.markAsRead(notif.id);
                            if (notif.targetRoute != null && context.mounted) {
                              try {
                                context.push(notif.targetRoute!);
                              } catch (_) {
                                // Safe fallback if opened without router context
                              }
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required NotificationCategory category,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final chipBg = isSelected
        ? GVColors.brandGreen
        : (isDark ? const Color(0xFF1C2420) : Colors.white);
    final borderColor = isSelected
        ? GVColors.brandGreen
        : (isDark ? const Color(0xFF2E3D35) : GVColors.border);
    final textColor = isSelected
        ? Colors.white
        : (isDark ? GVColors.neutral300 : GVColors.textSecondary);

    return Material(
      color: chipBg,
      borderRadius: BorderRadius.circular(GVBorderRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GVBorderRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GVBorderRadius.full),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            category.displayName,
            style: GVTypography.caption.copyWith(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C2420)
                    : GVColors.brandGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 36,
                color: isDark ? GVColors.neutral400 : GVColors.brandGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: GVTypography.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : GVColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You have no notifications in this category right now.',
              style: GVTypography.bodySmall.copyWith(
                color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
