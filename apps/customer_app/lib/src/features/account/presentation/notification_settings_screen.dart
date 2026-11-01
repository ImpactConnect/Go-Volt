import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_notifier.dart';
import '../application/settings_notifier.dart';

/// Screen B2: Notification Settings Grouped by Service (§B2 & Master Spec).
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final prefs = settings.notifications;
    final user = ref.watch(authNotifierProvider).profile;

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'Notification Settings'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Ride Notifications Group
            _buildSectionHeader('Ride Notifications', Icons.electric_bike_rounded),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.card,
              ),
              child: Column(
                children: [
                  _buildSwitchRow(
                    title: 'Booking Confirmations',
                    subtitle: 'Instant alerts when your ride request is confirmed',
                    value: prefs.rideBookingUpdates,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(rideBookingUpdates: val),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchRow(
                    title: 'Rider Assignment',
                    subtitle: 'Driver name, plate number, and ETA alerts',
                    value: prefs.rideRiderAssigned,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(rideRiderAssigned: val),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchRow(
                    title: 'Trip Status & Receipts',
                    subtitle: 'Arrival notifications and trip receipt summaries',
                    value: prefs.rideTripStatus,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(rideTripStatus: val),
                          );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Parcel Delivery Group
            _buildSectionHeader('Parcel Logistics', Icons.local_shipping_outlined),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.card,
              ),
              child: Column(
                children: [
                  _buildSwitchRow(
                    title: 'Delivery Progress Updates',
                    subtitle: 'Milestone notifications from pickup to transit',
                    value: prefs.parcelDeliveryUpdates,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(parcelDeliveryUpdates: val),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchRow(
                    title: 'Courier Assignment',
                    subtitle: 'Alert when a courier bike accepts your package',
                    value: prefs.parcelRiderAssigned,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(parcelRiderAssigned: val),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchRow(
                    title: 'Proof of Delivery Confirmation',
                    subtitle: 'Recipient signature and delivery completion alert',
                    value: prefs.parcelDeliveryCompletion,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(parcelDeliveryCompletion: val),
                          );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Market Errand Group
            _buildSectionHeader('Market Errand Shopping', Icons.storefront_outlined),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.card,
              ),
              child: Column(
                children: [
                  _buildSwitchRow(
                    title: 'Shopping Agent Updates',
                    subtitle: 'Real-time item substitution and market pricing inquiries',
                    value: prefs.errandShoppingUpdates,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(errandShoppingUpdates: val),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchRow(
                    title: 'Order Reconciliation & Payment',
                    subtitle: 'Final checkout receipt and wallet reconciliation alerts',
                    value: prefs.errandPaymentUpdates,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(errandPaymentUpdates: val),
                          );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // General & Security Group
            _buildSectionHeader('General & Security', Icons.security_outlined),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.card,
              ),
              child: Column(
                children: [
                  _buildSwitchRow(
                    title: 'Green Volt Points & Rewards',
                    subtitle: 'Notifications for points earned and milestone tiers',
                    value: prefs.rewardsAndPoints,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(rewardsAndPoints: val),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchRow(
                    title: 'Marketing & Promo Vouchers',
                    subtitle: 'Special discount codes and weekly commute savings',
                    value: prefs.promotionsAndCoupons,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(promotionsAndCoupons: val),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchRow(
                    title: 'School-Run Security Codes',
                    subtitle: 'Instant transmission of single-use 6-digit handover OTPs',
                    value: prefs.schoolRunSecurityAlerts,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(schoolRunSecurityAlerts: val),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchRow(
                    title: 'SMS Dispatch Emergency Alerts',
                    subtitle: 'Emergency SMS updates if cellular data is interrupted',
                    value: prefs.smsDispatchAlerts,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).updateNotificationPreference(
                            userId: user?.id,
                            update: (cur) => cur.copyWith(smsDispatchAlerts: val),
                          );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GVSpacing.xs, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: GVColors.brandGreen),
          const SizedBox(width: 6),
          Text(title, style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: GVColors.brandGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
