import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/scheduled_notifier.dart';

/// SP19 - SP23: School Run Minor Safety, Handover OTP & Authorized Contacts Screen.
class SchoolRunSafetyScreen extends ConsumerWidget {
  const SchoolRunSafetyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledState = ref.watch(scheduledNotifierProvider);
    final schoolRunPlan = scheduledState.schoolRunPlan ??
        scheduledState.plans.firstOrNull;

    if (schoolRunPlan == null) {
      return Scaffold(
        appBar: const GVTopBar(title: 'School Run Safety'),
        body: Center(
          child: Text('No active school-run plan found.', style: GVTypography.bodyMedium),
        ),
      );
    }

    final otp = schoolRunPlan.handoverOtp ?? '------';
    final childName = schoolRunPlan.passengerName;
    final schoolName = schoolRunPlan.schoolName ?? schoolRunPlan.dropoffLocation.label ?? 'Designated School';
    final contacts = schoolRunPlan.authorizedContacts;

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'School Run Safety & Handover'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // SP22: Handover Verification OTP Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user, color: GVColors.brandGreen, size: 24),
                      const SizedBox(width: GVSpacing.xs),
                      Flexible(
                        child: Text(
                          'School Pickup Verification OTP',
                          style: GVTypography.h3.copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.md),
                  // Formatted OTP digits
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      boxShadow: GVShadows.card,
                    ),
                    child: Text(
                      '${otp.substring(0, 3)}  ${otp.substring(3)}',
                      style: GVTypography.h1.copyWith(
                        letterSpacing: 6,
                        color: GVColors.deepGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  Text(
                    'Time-limited single-use code • Valid for 45 mins',
                    style: GVTypography.bodySmallMedium.copyWith(color: GVColors.accentGreen),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: GVSpacing.sm),
                    child: Text(
                      'Provide this 6-digit code to the Go-Volts driver at the school gate to verify custody transfer.',
                      textAlign: TextAlign.center,
                      style: GVTypography.caption.copyWith(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GVColors.brandGreen,
                      side: const BorderSide(color: GVColors.brandGreen),
                    ),
                    onPressed: () {
                      ref
                          .read(scheduledNotifierProvider.notifier)
                          .refreshHandoverOtp(schoolRunPlan.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('New single-use OTP generated successfully.'),
                          backgroundColor: GVColors.brandGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Generate New OTP'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // SP19: Minor Passenger Profile Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.child_care, color: GVColors.brandGreen),
                      const SizedBox(width: GVSpacing.xs),
                      Flexible(
                        child: Text('Passenger Profile',
                            style: GVTypography.h3,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  Text('Child Name: $childName', style: GVTypography.bodyMedium),
                  Text('School: $schoolName', style: GVTypography.bodySmall),
                  if (schoolRunPlan.notes != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Special Instructions: ${schoolRunPlan.notes}',
                      style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // SP20: Authorized Guardians & Contacts
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text('Authorized Guardians',
                            style: GVTypography.h3,
                            overflow: TextOverflow.ellipsis),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Guardians can be updated via Parent Profile Verification.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Guardian'),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  ...contacts.map((contact) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: GVColors.statusActiveBg,
                          child: Text(
                            contact.name[0],
                            style: const TextStyle(
                              color: GVColors.brandGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(contact.name, style: GVTypography.bodySmallMedium),
                        subtitle: Text(
                          '${contact.relationship} • ${contact.phone}',
                          style: GVTypography.caption,
                        ),
                        trailing: contact.isPrimary
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: GVColors.statusActiveBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Primary',
                                  style: GVTypography.bodySmallMedium
                                      .copyWith(color: GVColors.brandGreen),
                                ),
                              )
                            : null,
                      )),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // SP23: Failed Handover Escalation Protocol
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: GVColors.error.withValues(alpha: 0.3)),
                boxShadow: GVShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: GVColors.error),
                      const SizedBox(width: GVSpacing.xs),
                      Flexible(
                        child: Text(
                          'Custody & Handover Policy',
                          style: GVTypography.h3.copyWith(color: GVColors.error),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Go-Volts drivers are strictly forbidden from leaving a child unattended or releasing a child to an unverified individual. In the event of an unverified handover, operations security officer is dispatched immediately.',
                    style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  GVDestructiveButton(
                    label: 'Call Operations Safety Officer',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Connecting to Go-Volts Minor Safety Officer hotline...'),
                          backgroundColor: GVColors.error,
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
}
