import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/shift_notifier.dart';
import 'widgets/decline_reason_dialog.dart';
import 'widgets/dispatch_offer_modal.dart';
import 'widgets/go_online_modal.dart';
import 'widgets/request_accepted_modal.dart';

/// Screen RD09: Rider Shift Home, Master Availability Switch & Live Dispatch Telematics.
class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  bool _modalShown = false;

  void _promptGoOnline(BuildContext context, ShiftNotifier notifier) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GoOnlineModal(
        onConfirm: () {
          Navigator.of(ctx).pop();
          notifier.toggleAvailability();
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _showOfferModal(BuildContext context, ShiftNotifier notifier, DispatchOfferDto offer) {
    if (_modalShown) return;
    _modalShown = true;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DispatchOfferModal(
        offer: offer,
        onAccept: () async {
          Navigator.of(ctx).pop();
          _modalShown = false;
          await notifier.acceptOffer();
          if (context.mounted) {
            final activeJob = ref.read(shiftNotifierProvider).activeJob;
            if (activeJob != null) {
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (accCtx) => RequestAcceptedModal(
                  job: activeJob,
                  onNavigate: () {
                    Navigator.of(accCtx).pop();
                    context.push('/trip/active', extra: activeJob);
                  },
                  onContactPassenger: () {
                    Navigator.of(accCtx).pop();
                    context.push('/inbox');
                  },
                ),
              );
            }
          }
        },
        onDecline: () {
          Navigator.of(ctx).pop();
          _modalShown = false;
          showDialog<void>(
            context: context,
            builder: (dCtx) => DeclineReasonDialog(
              onConfirm: (reason, note) {
                notifier.declineOffer(reason, note: note);
              },
            ),
          );
        },
      ),
    ).whenComplete(() {
      _modalShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shiftNotifierProvider);
    final notifier = ref.read(shiftNotifierProvider.notifier);

    // Auto-trigger modal when an incoming offer is received and not yet presented
    if (state.currentOffer != null && !_modalShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && state.currentOffer != null && !_modalShown) {
          _showOfferModal(context, notifier, state.currentOffer!);
        }
      });
    }

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt, color: GVColors.brandGreen),
            tooltip: 'Simulate Inbound Job Offer',
            onPressed: () => notifier.triggerIncomingOffer(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Conflict or Error Alert Banner
            if (state.conflictMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(GVSpacing.sm),
                margin: const EdgeInsets.only(bottom: GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D1C1C),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.conflictMessage!,
                        style: GVTypography.caption.copyWith(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60, size: 16),
                      onPressed: () => notifier.clearAlerts(),
                    ),
                  ],
                ),
              ),
            ],

            if (state.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(GVSpacing.sm),
                margin: const EdgeInsets.only(bottom: GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D1C1C),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: GVTypography.caption.copyWith(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60, size: 16),
                      onPressed: () => notifier.clearAlerts(),
                    ),
                  ],
                ),
              ),
            ],

            // Active Job Banner (When accepted)
            if (state.activeJob != null) ...[
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                margin: const EdgeInsets.only(bottom: GVSpacing.md),
                decoration: BoxDecoration(
                  color: GVColors.deepGreen,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: GVColors.brandGreen, width: 2),
                  boxShadow: GVShadows.glow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const GVStatusChip(
                          label: 'ACTIVE TRIP ASSIGNED',
                          status: GVStatusType.active,
                        ),
                        Text(
                          '₦${state.activeJob!.netEarningsNaira.toStringAsFixed(0)} net',
                          style: GVTypography.h3.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    Text(
                      'Pickup: ${state.activeJob!.pickupAddress}',
                      style: GVTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Dropoff: ${state.activeJob!.dropoffAddress}',
                      style: GVTypography.caption.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: GVSpacing.sm),
                    GVPrimaryButton(
                      label: 'Navigate to Pickup',
                      onPressed: () {
                        context.push('/trip/active', extra: state.activeJob!);
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Availability Master Switch Banner
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: state.isOnline ? GVColors.deepGreen : const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(
                  color: state.isOnline ? GVColors.brandGreen : const Color(0xFF2A3630),
                  width: 1.5,
                ),
                boxShadow: state.isOnline ? GVShadows.glow : null,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            state.isOnline ? Icons.power_settings_new : Icons.toggle_off,
                            color: state.isOnline ? GVColors.brandGreen : Colors.white54,
                            size: 28,
                          ),
                          const SizedBox(width: GVSpacing.xs),
                          Text(
                            state.isOnline ? 'YOU ARE ONLINE' : 'YOU ARE OFFLINE',
                            style: GVTypography.h3.copyWith(
                              color: state.isOnline ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: state.isOnline,
                        activeThumbColor: GVColors.brandGreen,
                        activeTrackColor: GVColors.deepGreen,
                        onChanged: (val) {
                          if (val) {
                            _promptGoOnline(context, notifier);
                          } else {
                            notifier.toggleAvailability();
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: GVSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          state.isOnline
                              ? 'Ready to receive ride & parcel dispatch requests.'
                              : 'Go online to receive dispatch offers.',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141917),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Zone: Lekki',
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Radar Searching Card when Online & no active job (Board 2 Screen 3)
            if (state.isOnline && state.activeJob == null) ...[
              const SizedBox(height: GVSpacing.md),
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF141E18),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: GVColors.brandGreen.withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: GVColors.brandGreen.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: GVColors.deepGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: GVColors.brandGreen, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.radar,
                          color: GVColors.brandGreen,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Waiting for ride requests...',
                            style: GVTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Searching in Victoria Island / Lekki corridor',
                            style: GVTypography.caption.copyWith(color: GVColors.brandGreen),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 4 Driver Quick Actions (Board 2 Screen 1)
            const SizedBox(height: GVSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.electric_rickshaw,
                    label: 'Ride Requests',
                    badge: state.currentOffer != null ? '1' : null,
                    onTap: () {
                      if (state.currentOffer != null) {
                        _showOfferModal(context, notifier, state.currentOffer!);
                      } else {
                        notifier.triggerIncomingOffer();
                      }
                    },
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.account_balance_wallet,
                    label: 'Earnings',
                    onTap: () => context.push('/earnings'),
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.history,
                    label: 'Trip History',
                    onTap: () => context.push('/trips'),
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.chat_bubble_outline,
                    label: 'Messages',
                    onTap: () => context.push('/inbox'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.md),

            // Service Tier Eligibility Filter
            Text(
              'Active Dispatch Mode',
              style: GVTypography.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: GVSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ServiceTierEligibility.values.map((tier) {
                  final isSelected = state.activeTier == tier;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        tier.label,
                        style: GVTypography.caption.copyWith(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selectedColor: GVColors.deepGreen,
                      backgroundColor: const Color(0xFF1C2420),
                      side: BorderSide(
                        color: isSelected ? GVColors.brandGreen : const Color(0xFF2A3630),
                      ),
                      checkmarkColor: GVColors.brandGreen,
                      onSelected: (_) => notifier.setServiceTier(tier),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Vehicle & Battery Status Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: GVColors.deepGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.two_wheeler, color: GVColors.brandGreen),
                  ),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spiro Commando EV · LA-482-VI',
                          style: GVTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          state.currentZone,
                          style: GVTypography.caption.copyWith(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.battery_charging_full,
                            color: state.batteryLevel < 20 ? Colors.redAccent : GVColors.brandGreen,
                            size: 18,
                          ),
                          Text(
                            '${state.batteryLevel}%',
                            style: GVTypography.bodyMedium.copyWith(
                              color: state.batteryLevel < 20 ? Colors.redAccent : GVColors.brandGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Range: ~${(state.batteryLevel * 0.72).round()} km',
                        style: GVTypography.caption.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Lagos Demand Heatmap & Geofencing Card (RD11)
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.amber, size: 20),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Lagos Fleet Demand Heatmap',
                                style: GVTypography.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B2A10),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '1.3x High Surge',
                          style: GVTypography.caption.copyWith(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Peak order clusters detected in Victoria Island (Admiralty / Ozumba) and Lekki Phase 1.',
                    style: GVTypography.caption.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.speed, color: GVColors.brandGreen, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Geofenced speed limit: 45 km/h expressway · 30 km/h school corridors',
                          style: GVTypography.caption.copyWith(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Shift Metrics Summary
            Text(
              "Today's Shift Performance",
              style: GVTypography.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: GVSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Net Earnings',
                    value: '₦${state.shift.earningsTodayNaira.toStringAsFixed(0)}',
                    icon: Icons.payments,
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Completed Trips',
                    value: '${state.shift.jobsCompletedToday} Jobs',
                    icon: Icons.task_alt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Online Time',
                    value: '${state.shift.onlineHoursToday.toStringAsFixed(1)} hrs',
                    icon: Icons.timer,
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Acceptance Rate',
                    value: '${state.shift.acceptanceRatePercent}%',
                    icon: Icons.percent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.lg),

            // Quick Actions & Navigation
            Text(
              'Fleet Actions',
              style: GVTypography.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: GVSpacing.xs),
            ListTile(
              tileColor: const Color(0xFF1C2420),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                side: const BorderSide(color: Color(0xFF2A3630)),
              ),
              leading: const Icon(Icons.electric_bolt, color: GVColors.brandGreen),
              title: Text(
                'Locate Nearest Battery Swap Station',
                style: GVTypography.bodyMedium.copyWith(color: Colors.white),
              ),
              subtitle: Text(
                'Ikeja Hub (1.4 km) · 8 charged packs available',
                style: GVTypography.caption.copyWith(color: Colors.white60),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
              onTap: () => context.go('/swaps'),
            ),
            const SizedBox(height: GVSpacing.sm),
            ListTile(
              tileColor: const Color(0xFF1C2420),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                side: const BorderSide(color: Color(0xFF2A3630)),
              ),
              leading: const Icon(Icons.verified, color: GVColors.brandGreen),
              title: Text(
                'My Certifications & Service Tiers',
                style: GVTypography.bodyMedium.copyWith(color: Colors.white),
              ),
              subtitle: Text(
                'Parcel Delivery (Active) · Rides (Verified)',
                style: GVTypography.caption.copyWith(color: Colors.white60),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GVTypography.caption.copyWith(color: Colors.white60),
              ),
              Icon(icon, color: GVColors.brandGreen, size: 18),
            ],
          ),
          const SizedBox(height: GVSpacing.xs),
          Text(
            value,
            style: GVTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: GVSpacing.md, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2420),
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(color: const Color(0xFF2A3630)),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GVColors.deepGreen.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: GVColors.brandGreen, size: 20),
                ),
                if (badge != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: GVSpacing.xs),
            Text(
              label,
              style: GVTypography.caption.copyWith(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
