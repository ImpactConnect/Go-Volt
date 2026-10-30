import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 15 — Delivered (Proof of Delivery):
/// Celebratory completion badge, handover details, digital recipient signature,
/// and primary "View receipt" action.
class ParcelDeliveredScreen extends ConsumerWidget {
  const ParcelDeliveredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parcelBookingNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final recipient = state.recipient;
    final recipientName = recipient?.fullName ?? 'John Doe';
    final destinationAddress =
        state.destinationLocation?.address ?? 'Palms Mall, Lekki, Lagos';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : GVColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? GVColors.white : GVColors.textPrimary,
            size: 24,
          ),
          onPressed: () {
            if (GoRouter.maybeOf(context) != null) {
              context.go(AppRoutes.home);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: GVSpacing.lg,
            vertical: GVSpacing.md,
          ),
          child: Column(
            children: [
              // Reusable Proof of Delivery Card from Design System
              GVProofOfDeliveryCard(
                recipientName: recipientName,
                deliveryAddress: destinationAddress,
                deliveredAtLabel: 'Oct 29, 2026, 10:45 AM',
                receivedByName: recipientName,
                onViewReceipt: () {
                  if (GoRouter.maybeOf(context) != null) {
                    context.push(AppRoutes.parcelReceipt);
                  } else {
                    Navigator.of(context).pushNamed(AppRoutes.parcelReceipt);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
