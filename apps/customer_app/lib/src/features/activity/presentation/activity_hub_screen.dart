import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/activity_notifier.dart';
import '../domain/activity_item.dart';
import 'widgets/cancellation_details_bottom_sheet.dart';
import 'widgets/digital_receipt_bottom_sheet.dart';

/// Screen H07: Go-Volts Unified Activity Hub (Rides, Parcel Deliveries, Scheduled Trips).
class ActivityHubScreen extends ConsumerStatefulWidget {
  const ActivityHubScreen({super.key});

  @override
  ConsumerState<ActivityHubScreen> createState() => _ActivityHubScreenState();
}

class _ActivityHubScreenState extends ConsumerState<ActivityHubScreen> {
  bool _isSearchVisible = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openReceipt(ActivityItem item) {
    if (item.receipt != null) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DigitalReceiptBottomSheet(receipt: item.receipt!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Digital receipt for ${item.reference} is being generated.'),
        ),
      );
    }
  }

  void _openCancellationDetails(ActivityItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CancellationDetailsBottomSheet(item: item),
    );
  }

  void _handleItemAction(ActivityItem item) {
    switch (item.status) {
      case ActivityStatus.active:
        if (item.serviceType == ActivityServiceType.ride) {
          context.push(AppRoutes.liveTracking);
        } else if (item.serviceType == ActivityServiceType.delivery) {
          context.push(AppRoutes.parcelLiveTracking);
        } else if (item.serviceType == ActivityServiceType.errand) {
          if (item.errandType == ErrandType.pickupPackage) {
            context.push(AppRoutes.errandPackageTracking);
          } else if (item.errandType == ErrandType.otherErrand) {
            context.push(AppRoutes.errandCustomTracking);
          } else {
            context.push(AppRoutes.errandTracking);
          }
        } else {
          context.push(AppRoutes.scheduledTripInProgress);
        }
        break;

      case ActivityStatus.upcoming:
        if (item.serviceType == ActivityServiceType.scheduled) {
          context.push(AppRoutes.scheduledPlanDetails);
        } else if (item.serviceType == ActivityServiceType.delivery) {
          context.push(AppRoutes.parcelLiveTracking);
        } else {
          context.push(AppRoutes.liveTracking);
        }
        break;

      case ActivityStatus.completed:
        if (item.serviceType == ActivityServiceType.errand) {
          context.push(AppRoutes.errandCompleted);
        } else {
          _openReceipt(item);
        }
        break;

      case ActivityStatus.cancelled:
        _openCancellationDetails(item);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityNotifierProvider);
    final notifier = ref.read(activityNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : GVColors.softBackground;
    final cardBg = isDark ? const Color(0xFF1C2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final filteredItems = state.filteredItems;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Activity',
          style: GVTypography.h2.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.close : Icons.search,
              color: GVColors.deepGreen,
            ),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  notifier.setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: GVColors.deepGreen),
            onPressed: () => notifier.refresh(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar (expandable)
            if (_isSearchVisible)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: GVSpacing.md, vertical: GVSpacing.xs),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by location, driver, reference...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      borderSide: BorderSide(color: borderColor),
                    ),
                  ),
                  onChanged: (val) => notifier.setSearchQuery(val),
                ),
              ),

            // Service Category Filter Pills: All | Rides | Deliveries | Scheduled
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: GVSpacing.md, vertical: GVSpacing.xs),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildServicePill(
                      label: 'All Services',
                      isSelected: state.selectedService == null,
                      onTap: () => notifier.setServiceFilter(null),
                    ),
                    const SizedBox(width: 8),
                    _buildServicePill(
                      label: 'Rides',
                      icon: Icons.directions_car,
                      isSelected:
                          state.selectedService == ActivityServiceType.ride,
                      onTap: () =>
                          notifier.setServiceFilter(ActivityServiceType.ride),
                    ),
                    const SizedBox(width: 8),
                    _buildServicePill(
                      label: 'Deliveries',
                      icon: Icons.local_shipping,
                      isSelected:
                          state.selectedService == ActivityServiceType.delivery,
                      onTap: () => notifier
                          .setServiceFilter(ActivityServiceType.delivery),
                    ),
                    const SizedBox(width: 8),
                    _buildServicePill(
                      label: 'Scheduled',
                      icon: Icons.calendar_month,
                      isSelected: state.selectedService ==
                          ActivityServiceType.scheduled,
                      onTap: () => notifier
                          .setServiceFilter(ActivityServiceType.scheduled),
                    ),
                    const SizedBox(width: 8),
                    _buildServicePill(
                      label: 'Errands',
                      icon: Icons.storefront_outlined,
                      isSelected: state.selectedService ==
                          ActivityServiceType.errand,
                      onTap: () => notifier
                          .setServiceFilter(ActivityServiceType.errand),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: GVSpacing.xs),

            // Status Sub-Tabs: Active | Upcoming | Completed | Cancelled
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatusTab(
                        label: 'Active (${state.activeCount})',
                        isSelected:
                            state.selectedStatus == ActivityStatus.active,
                        onTap: () =>
                            notifier.setStatusFilter(ActivityStatus.active),
                      ),
                    ),
                    Expanded(
                      child: _buildStatusTab(
                        label: 'Upcoming (${state.upcomingCount})',
                        isSelected:
                            state.selectedStatus == ActivityStatus.upcoming,
                        onTap: () =>
                            notifier.setStatusFilter(ActivityStatus.upcoming),
                      ),
                    ),
                    Expanded(
                      child: _buildStatusTab(
                        label: 'Completed (${state.completedCount})',
                        isSelected:
                            state.selectedStatus == ActivityStatus.completed,
                        onTap: () =>
                            notifier.setStatusFilter(ActivityStatus.completed),
                      ),
                    ),
                    Expanded(
                      child: _buildStatusTab(
                        label: 'Cancelled (${state.cancelledCount})',
                        isSelected:
                            state.selectedStatus == ActivityStatus.cancelled,
                        onTap: () =>
                            notifier.setStatusFilter(ActivityStatus.cancelled),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: GVSpacing.sm),

            // List of Activity Cards
            Expanded(
              child: filteredItems.isEmpty
                  ? _buildEmptyState(state.selectedStatus)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: GVSpacing.md, vertical: GVSpacing.xs),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _buildActivityCard(
                          item: item,
                          cardBg: cardBg,
                          borderColor: borderColor,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicePill({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? GVColors.deepGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? GVColors.deepGreen : GVColors.border,
          ),
          boxShadow: isSelected ? GVShadows.card : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : GVColors.deepGreen,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : GVColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(GVBorderRadius.sm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? GVColors.brandGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(GVBorderRadius.sm),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? GVColors.deepGreen : GVColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required ActivityItem item,
    required Color cardBg,
    required Color borderColor,
  }) {
    final statusColor = switch (item.status) {
      ActivityStatus.active => GVColors.brandGreen,
      ActivityStatus.upcoming => const Color(0xFF1E88E5),
      ActivityStatus.completed => GVColors.deepGreen,
      ActivityStatus.cancelled => GVColors.error,
    };

    final serviceIcon = switch (item.serviceType) {
      ActivityServiceType.ride => Icons.directions_car,
      ActivityServiceType.delivery => Icons.local_shipping,
      ActivityServiceType.scheduled => Icons.calendar_month,
      ActivityServiceType.errand => Icons.storefront_outlined,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: GVSpacing.sm),
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: borderColor),
        boxShadow: GVShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Service Badge, Ref, Fare
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(serviceIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      item.serviceType.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.reference,
                  style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                item.formattedFare,
                style: GVTypography.h3.copyWith(
                  color: GVColors.deepGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: GVSpacing.sm),

          // Title & Passenger/Recipient info
          Text(
            item.title,
            style: GVTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          if (item.schoolPassengerName != null) ...[
            const SizedBox(height: 2),
            Text(
              'Passenger: ${item.schoolPassengerName}',
              style: GVTypography.caption.copyWith(color: GVColors.brandGreen),
            ),
          ],
          if (item.recipientName != null) ...[
            const SizedBox(height: 2),
            Text(
              'Recipient: ${item.recipientName} (${item.recipientPhone ?? ''})',
              style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
            ),
          ],

          const SizedBox(height: GVSpacing.xs),

          // Route Timeline Preview
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: GVColors.brandGreen, size: 10),
                  Container(
                    width: 1.5,
                    height: 18,
                    color: GVColors.neutral300,
                  ),
                  const Icon(Icons.location_on, color: GVColors.error, size: 12),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.pickupAddress,
                      style: GVTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.dropoffAddress,
                      style: GVTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Driver details (if assigned)
          if (item.driverName != null) ...[
            const Divider(height: GVSpacing.md),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: GVColors.statusActiveBg,
                  child: const Icon(Icons.person, size: 16, color: GVColors.deepGreen),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${item.driverName} • ★ ${item.driverRating.toStringAsFixed(1)}',
                    style: GVTypography.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (item.vehiclePlate != null)
                  Text(
                    item.vehiclePlate!,
                    style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
                  ),
              ],
            ),
          ],

          const Divider(height: GVSpacing.md),

          // Footer Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.timestamp.day}/${item.timestamp.month} • ${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.status == ActivityStatus.active
                      ? GVColors.brandGreen
                      : (item.status == ActivityStatus.cancelled
                          ? Colors.grey.shade200
                          : GVColors.deepGreen),
                  foregroundColor: item.status == ActivityStatus.active
                      ? GVColors.deepGreen
                      : (item.status == ActivityStatus.cancelled
                          ? Colors.black87
                          : Colors.white),
                  elevation: 0,
                  minimumSize: const Size(80, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _handleItemAction(item),
                child: Text(
                  switch (item.status) {
                    ActivityStatus.active => 'Track Live',
                    ActivityStatus.upcoming => 'View Details',
                    ActivityStatus.completed => 'Receipt',
                    ActivityStatus.cancelled => 'Refund Details',
                  },
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ActivityStatus status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: GVColors.neutral400,
          ),
          const SizedBox(height: GVSpacing.sm),
          Text(
            'No ${status.label.toLowerCase()} activities found',
            style: GVTypography.h3.copyWith(color: GVColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Your ${status.label.toLowerCase()} rides, parcel deliveries and scheduled pickups will appear here.',
            style: GVTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
