import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_trips_notifier.dart';

/// Screen 34 (SP-36): Handover Confirmed Screen
/// Confirms successful 4-digit PIN verified handover to authorised school recipient, providing audit record and note-taking.
class HandoverConfirmedScreen extends ConsumerWidget {
  const HandoverConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledTripsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.neutral50;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final trip = state.selectedTrip ??
        (state.completedTrips.isNotEmpty ? state.completedTrips.first : null);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            size: 24,
            color: textColor,
          ),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: GVSpacing.md),

              // Celebration badge with sparkles
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: GVColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: GVColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              Text(
                'Handover confirmed!',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'The child has been safely handed over to the authorised contact.',
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: GVSpacing.xl),

              // Child profile card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.card),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFFDE047),
                      child: const Icon(
                        Icons.child_care_rounded,
                        color: Color(0xFF854D0E),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fatima Okafor',
                            style: GVTypography.bodyLarge.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'JSS 1 • Age 10',
                            style: GVTypography.caption.copyWith(
                              color: subtextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Handover Recipient record card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.card),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: GVColors.primary.withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.person_rounded,
                            color: GVColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: GVSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Handover to',
                                style: GVTypography.caption.copyWith(
                                  color: subtextColor,
                                ),
                              ),
                              Text(
                                trip?.handoverRecipientName ??
                                    'Mrs. Aisha Muhammadu',
                                style: GVTypography.bodyLarge.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                trip?.handoverRecipientRole ?? 'School Teacher',
                                style: GVTypography.caption.copyWith(
                                  color: GVColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: GVColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mon, 6 Nov 2026, 8:29 AM',
                          style: GVTypography.bodySmall.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip?.destinationAddress ??
                                'Remo High Street, Shaganu, Ogun State',
                            style: GVTypography.bodySmall.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xxl),

              // Action buttons
              GVButton(
                text: 'View trip details',
                type: GVButtonType.primary,
                onPressed: () {
                  context.push(AppRoutes.scheduledPaymentRefundDetails);
                },
              ),
              const SizedBox(height: GVSpacing.sm),
              GVButton(
                text: 'Add note',
                type: GVButtonType.outline,
                onPressed: () {
                  _showAddNoteDialog(context);
                },
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Handover Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'e.g. Handed school backpack and lunch box.',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GVColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note appended to handover audit record.'),
                ),
              );
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }
}
