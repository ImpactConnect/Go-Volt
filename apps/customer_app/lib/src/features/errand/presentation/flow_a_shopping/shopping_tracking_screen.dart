import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/live_google_map_view.dart';
import '../../../../core/router/app_router.dart';
import '../../application/shopping_errand_notifier.dart';

/// Screen A7 (ME-12): Track Errand (Errand in Progress).
/// Matches high-fidelity design template Row 1 Screen A7.
class ShoppingTrackingScreen extends ConsumerWidget {
  const ShoppingTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(shoppingErrandNotifierProvider);
    final notifier = ref.read(shoppingErrandNotifierProvider.notifier);

    final errand = state.activeErrand;
    final status = errand?.status ?? ErrandStatus.shoppingInProgress;
    final rider = errand?.assignedRider ??
        const RiderDto(
          id: 'unassigned',
          profileId: '',
          fullName: 'Assigning Rider...',
          phoneNumber: '',
          vehicleModel: 'Electric Courier',
          vehiclePlate: 'Go-Volt EV',
          rating: 5.0,
          totalTripsCompleted: 0,
        );

    final shopName = state.selectedShop?.name ?? 'Kakuri Main Market';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF161F1A) : GVColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? GVColors.white : GVColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Errand in Progress',
          style: GVTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Stepper Timeline (Assigned -> Shopping -> Delivering)
            _buildTimelineHeader(context, status, isDark),

            // Live Map Area
            Expanded(
              child: Stack(
                children: [
                  LiveGoogleMapView(
                    initialLatitude: state.selectedShop?.latitude ?? 10.4682,
                    initialLongitude: state.selectedShop?.longitude ?? 7.4201,
                    pickerTitle: shopName,
                    pickerAddress: state.deliveryLocation.address,
                  ),

                  // Floating Rider Callout / Simulation pill
                  Positioned(
                    top: GVSpacing.md,
                    left: GVSpacing.md,
                    right: GVSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GVSpacing.md,
                        vertical: GVSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF161F1A).withValues(alpha: 0.92)
                            : GVColors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(GVBorderRadius.full),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.electric_moped_rounded,
                            color: Color(0xFF00C853),
                            size: 20,
                          ),
                          const SizedBox(width: GVSpacing.sm),
                          Expanded(
                            child: Text(
                              'Ahmed is 6 mins away from $shopName',
                              style: GVTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Panel: Assigned Rider & Live Status Banner
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161F1A) : GVColors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(GVBorderRadius.lg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(GVSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rider Card
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: Color(0xFF00C853),
                        ),
                      ),
                      const SizedBox(width: GVSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rider.fullName,
                              style: GVTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFB300),
                                  size: 16,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  rider.rating.toStringAsFixed(1),
                                  style: GVTypography.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: GVSpacing.sm),
                                Text(
                                  '•  Rider • ${rider.vehiclePlate}',
                                  style: GVTypography.caption.copyWith(
                                    color: isDark
                                        ? GVColors.neutral400
                                        : GVColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Call button
                      _buildCircularActionBtn(
                        icon: Icons.phone_rounded,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${rider.fullName}...')),
                          );
                        },
                      ),
                      const SizedBox(width: GVSpacing.sm),
                      // Chat button
                      _buildCircularActionBtn(
                        icon: Icons.chat_rounded,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening chat with ${rider.fullName}...')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: GVSpacing.md),

                  // Shopping in progress status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(GVSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2B23)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E4035)
                            : const Color(0xFFC8E6C9),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C853),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_cart_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: GVSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _statusTitleFor(status),
                                style: GVTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _statusSubtitleFor(status, shopName),
                                style: GVTypography.caption.copyWith(
                                  color: isDark
                                      ? GVColors.neutral300
                                      : const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: GVSpacing.sm),

                  // Simulation Button to advance state (Shopping -> Items Purchased -> Delivering -> Completed)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      icon: const Icon(Icons.fast_forward_rounded, size: 18),
                      label: Text(
                        'Simulate Next Milestone: ${status.label}',
                        style: GVTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00C853),
                        ),
                      ),
                      onPressed: () => notifier.advanceStatusForTesting(),
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

  Widget _buildTimelineHeader(
    BuildContext context,
    ErrandStatus status,
    bool isDark,
  ) {
    final isShopping = status == ErrandStatus.shoppingInProgress ||
        status == ErrandStatus.itemsPurchased ||
        status == ErrandStatus.outForDelivery ||
        status == ErrandStatus.delivered ||
        status == ErrandStatus.completed;
    final isDelivering = status == ErrandStatus.outForDelivery ||
        status == ErrandStatus.delivered ||
        status == ErrandStatus.completed;

    return Container(
      color: isDark ? const Color(0xFF161F1A) : GVColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: GVSpacing.xl,
        vertical: GVSpacing.md,
      ),
      child: Row(
        children: [
          _buildMilestoneNode('Assigned', isCompleted: true, isDark: isDark),
          Expanded(child: _buildTimelineBar(isShopping)),
          _buildMilestoneNode(
            'Shopping',
            isCompleted: isShopping,
            isCurrent: status == ErrandStatus.shoppingInProgress,
            isDark: isDark,
          ),
          Expanded(child: _buildTimelineBar(isDelivering)),
          _buildMilestoneNode(
            'Delivering',
            isCompleted: isDelivering,
            isCurrent: status == ErrandStatus.outForDelivery,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneNode(
    String label, {
    required bool isCompleted,
    bool isCurrent = false,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? const Color(0xFF00C853)
                : (isDark ? const Color(0xFF2E3D35) : const Color(0xFFE0E0E0)),
            border: isCurrent
                ? Border.all(color: const Color(0xFF00C853), width: 3)
                : null,
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GVTypography.caption.copyWith(
            fontWeight: isCompleted || isCurrent ? FontWeight.bold : FontWeight.w400,
            color: isCompleted || isCurrent
                ? (isDark ? Colors.white : GVColors.textPrimary)
                : GVColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineBar(bool isActive) {
    return Container(
      height: 3,
      color: isActive ? const Color(0xFF00C853) : const Color(0xFFE0E0E0),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    );
  }

  Widget _buildCircularActionBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Color(0xFF00C853), size: 18),
        onPressed: onTap,
      ),
    );
  }

  String _statusTitleFor(ErrandStatus status) {
    switch (status) {
      case ErrandStatus.agentAssigned:
        return 'Rider assigned';
      case ErrandStatus.shoppingInProgress:
        return 'Shopping in progress';
      case ErrandStatus.itemsPurchased:
        return 'Items purchased & packaged';
      case ErrandStatus.outForDelivery:
        return 'On the way to you';
      case ErrandStatus.delivered:
      case ErrandStatus.completed:
        return 'Items delivered successfully!';
      default:
        return status.label;
    }
  }

  String _statusSubtitleFor(ErrandStatus status, String shopName) {
    switch (status) {
      case ErrandStatus.agentAssigned:
        return 'Heading towards $shopName.';
      case ErrandStatus.shoppingInProgress:
        return 'Buying your items at $shopName.';
      case ErrandStatus.itemsPurchased:
        return 'All items secured. Departing $shopName.';
      case ErrandStatus.outForDelivery:
        return 'Ahmed is approaching your delivery destination.';
      case ErrandStatus.delivered:
      case ErrandStatus.completed:
        return 'Order completed. Enjoy your items!';
      default:
        return 'Tracking your errand in real-time.';
    }
  }
}
