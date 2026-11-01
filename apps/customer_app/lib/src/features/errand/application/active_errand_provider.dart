import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_router.dart';
import 'package_errand_notifier.dart';
import 'shopping_errand_notifier.dart';
import 'other_errand_notifier.dart';

/// Summary model for persistent active errand tracking cards and notifications.
class ActiveErrandSummary {
  const ActiveErrandSummary({
    required this.errandId,
    required this.referenceCode,
    required this.type,
    required this.title,
    required this.statusBadge,
    required this.statusMessage,
    required this.targetRoute,
    this.rider,
    this.etaMinutes = 15,
  });

  final String errandId;
  final String referenceCode;
  final ErrandType type;
  final String title;
  final String statusBadge;
  final String statusMessage;
  final String targetRoute;
  final RiderDto? rider;
  final int etaMinutes;
}

/// Computes the currently active errand across all three errand flows.
final activeErrandProvider = Provider<ErrandDto?>((ref) {
  final shoppingState = ref.watch(shoppingErrandNotifierProvider);
  if (shoppingState.activeErrand != null && shoppingState.activeErrand!.status.isActive) {
    return shoppingState.activeErrand;
  }

  final packageState = ref.watch(packageErrandNotifierProvider);
  if (packageState.activeErrand != null && packageState.activeErrand!.status.isActive) {
    return packageState.activeErrand;
  }

  final otherState = ref.watch(otherErrandNotifierProvider);
  if (otherState.activeErrand != null && otherState.activeErrand!.status.isActive) {
    return otherState.activeErrand;
  }

  return null;
});

/// Derives a display-ready summary for hero cards on the Home Dashboard.
final activeErrandSummaryProvider = Provider<ActiveErrandSummary?>((ref) {
  final errand = ref.watch(activeErrandProvider);
  if (errand == null) return null;

  switch (errand.type) {
    case ErrandType.buyItems:
      final shopName = errand.shop?.name ?? 'Market';
      final count = errand.items.length;
      final statusText = errand.status == ErrandStatus.shoppingInProgress
          ? 'Shopping in progress at $shopName'
          : (errand.status == ErrandStatus.outForDelivery
              ? 'Delivering items to your address'
              : 'Rider assigned to purchase $count items');
      return ActiveErrandSummary(
        errandId: errand.id,
        referenceCode: errand.referenceNumber,
        type: errand.type,
        title: 'Buy Items: $shopName ($count items)',
        statusBadge: errand.status.label,
        statusMessage: statusText,
        targetRoute: AppRoutes.errandTracking,
        rider: errand.assignedRider,
        etaMinutes: 15,
      );

    case ErrandType.pickupPackage:
      final hubName = errand.pickupDetails?.pickupBusinessName.split(',').first ?? 'Pickup Hub';
      final statusText = errand.status == ErrandStatus.outForDelivery
          ? 'Package on the way to you'
          : 'Rider en route to collect package from $hubName';
      return ActiveErrandSummary(
        errandId: errand.id,
        referenceCode: errand.referenceNumber,
        type: errand.type,
        title: 'Package Pickup: $hubName',
        statusBadge: errand.status.label,
        statusMessage: statusText,
        targetRoute: AppRoutes.errandPackageTracking,
        rider: errand.assignedRider,
        etaMinutes: 12,
      );

    case ErrandType.otherErrand:
      final category = errand.customErrandDetails?.category ?? 'Custom Task';
      final statusText = errand.status == ErrandStatus.outForDelivery
          ? 'Delivering documents / task completed'
          : 'Task in progress • Executing errand';
      return ActiveErrandSummary(
        errandId: errand.id,
        referenceCode: errand.referenceNumber,
        type: errand.type,
        title: 'Errand: $category',
        statusBadge: errand.status.label,
        statusMessage: statusText,
        targetRoute: AppRoutes.errandCustomTracking,
        rider: errand.assignedRider,
        etaMinutes: 10,
      );
  }
});

