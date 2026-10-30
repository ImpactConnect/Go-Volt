import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/onboarding_notifier.dart';

/// Screen RD08: Application Review & Service Tier Certification Status.
class RiderApplicationStatusScreen extends ConsumerWidget {
  const RiderApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final rider = state.submittedRider;

    final riderRef = rider?.id ?? 'RDR-2026-9041';
    final riderName = rider?.fullName ?? (state.fullName.isNotEmpty ? state.fullName : 'Babajide Ogundipe');
    final vehiclePlate = rider?.vehiclePlate ?? (state.vehiclePlate.isNotEmpty ? state.vehiclePlate : 'LA-482-VI');

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Application Status'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: GVColors.brandGreen),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Go-Volts Lagos Fleet Operations: +234 1 800 4686'),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(GVSpacing.md),
                children: [
                  // Status Header Card
                  Container(
                    padding: const EdgeInsets.all(GVSpacing.md),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [GVColors.deepGreen, Color(0xFF133B26)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      boxShadow: GVShadows.elevated,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: GVStatusChip(
                                label: 'APPLICATION UNDER REVIEW',
                                status: GVStatusType.pending,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              riderRef,
                              style: GVTypography.caption.copyWith(
                                color: GVColors.brandGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: GVSpacing.sm),
                        Text(
                          riderName,
                          style: GVTypography.h2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Assigned EV: $vehiclePlate · Ikeja / VI Fleet',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                        ),
                        const Divider(color: Colors.white24, height: GVSpacing.lg),
                        Text(
                          'Compliance officers are reviewing your Lagos MOT credentials and guarantor reference. Verification turnaround is typically 4–24 hours.',
                          style: GVTypography.caption.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.lg),

                  // Verification Pipeline Steps
                  Text(
                    'Verification Checklist',
                    style: GVTypography.h3.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  _buildStageItem(
                    title: '1. Personal Identity & KYC',
                    statusText: 'Verified & Cleared',
                    isComplete: true,
                    icon: Icons.check_circle,
                    color: GVColors.brandGreen,
                  ),
                  _buildStageItem(
                    title: '2. Regulatory Documents (NIN, License)',
                    statusText: 'Under Review by Legal Compliance',
                    isComplete: false,
                    icon: Icons.hourglass_top,
                    color: Colors.amber,
                  ),
                  _buildStageItem(
                    title: '3. Vehicle Roadworthiness & BMS Sync',
                    statusText: 'Inspection Slot Booked at Ikeja Hub',
                    isComplete: false,
                    icon: Icons.schedule,
                    color: Colors.amber,
                  ),
                  _buildStageItem(
                    title: '4. Guarantor Verification',
                    statusText: 'Verification SMS Dispatched',
                    isComplete: false,
                    icon: Icons.phone_in_talk,
                    color: Colors.white70,
                  ),
                  _buildStageItem(
                    title: '5. EV Safety & Handover Training',
                    statusText: 'Passed (4/4 100%)',
                    isComplete: true,
                    icon: Icons.check_circle,
                    color: GVColors.brandGreen,
                  ),
                  const SizedBox(height: GVSpacing.lg),

                  // Service Tier Eligibility (Concept note §10.1)
                  Text(
                    'Service Tier Eligibility & Certifications',
                    style: GVTypography.h3.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Go-Volts operates multi-tier certifications. Each service requires distinct safety and background thresholds.',
                    style: GVTypography.caption.copyWith(color: Colors.white60),
                  ),
                  const SizedBox(height: GVSpacing.sm),

                  _buildTierCard(
                    title: 'Parcel & Cargo Delivery',
                    desc: 'Small to medium packages and document dispatch across Lagos.',
                    statusLabel: 'PROVISIONALLY APPROVED',
                    statusColor: GVColors.brandGreen,
                    icon: Icons.local_shipping,
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  _buildTierCard(
                    title: 'Passenger EV Commute',
                    desc: 'On-demand electric passenger motorcycle rides.',
                    statusLabel: 'PENDING ROAD TEST',
                    statusColor: Colors.amber,
                    icon: Icons.two_wheeler,
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  _buildTierCard(
                    title: 'School-Run Dedicated Chaperone',
                    desc: 'Scheduled child school commutes with single-use OTP verification.',
                    statusLabel: 'REQUIRES ENHANCED VETTING',
                    statusColor: Colors.white54,
                    icon: Icons.school,
                  ),
                  const SizedBox(height: GVSpacing.xl),
                ],
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: const BoxDecoration(
                color: Color(0xFF141917),
                border: Border(
                  top: BorderSide(color: Color(0xFF232D28), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GVPrimaryButton(
                    label: 'Access Shift Dashboard (Demo Preview)',
                    onPressed: () => context.go('/jobs'),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  GVSecondaryButton(
                    label: 'Contact Fleet Support',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support Hotline: +234 1 800 4686 · support@govolts.ng'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageItem({
    required String title,
    required String statusText,
    required bool isComplete,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(GVSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: GVSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GVTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  statusText,
                  style: GVTypography.caption.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required String title,
    required String desc,
    required String statusLabel,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: GVColors.brandGreen, size: 28),
          const SizedBox(width: GVSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GVTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      statusLabel,
                      style: GVTypography.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GVTypography.caption.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
