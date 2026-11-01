import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/scheduled_trips_notifier.dart';

/// Screen 35 (SP-26): Trip Issue / Report an Issue Screen
/// Provides customer dispute and incident reporting across all 7 technical specification issue categories.
class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  TripIssueType _selectedIssue = TripIssueType.driverDidNotArrive;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final state = ref.read(scheduledTripsNotifierProvider);
    final notifier = ref.read(scheduledTripsNotifierProvider.notifier);
    final trip = state.selectedTrip ??
        (state.trips.isNotEmpty ? state.trips.first : null);

    if (trip == null) return;

    final success = await notifier.reportIssue(
      tripId: trip.id,
      issueType: _selectedIssue,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Incident report received. Support will review shortly and contact you.'),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduledTripsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.neutral50;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: textColor,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: GVSpacing.md),

              // Red alert triangle badge
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFCA5A5),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              Text(
                'Report an issue',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: GVSpacing.xl),

              // Issue options list
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.card),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: TripIssueType.values.map((issue) {
                    final isSelected = _selectedIssue == issue;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIssue = issue;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GVSpacing.md,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: issue != TripIssueType.values.last
                                ? BorderSide(color: borderColor)
                                : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getIssueIcon(issue),
                              size: 20,
                              color: isSelected
                                  ? GVColors.primary
                                  : GVColors.textSecondary,
                            ),
                            const SizedBox(width: GVSpacing.md),
                            Expanded(
                              child: Text(
                                issue.label,
                                style: GVTypography.bodyMedium.copyWith(
                                  color: textColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            // ignore: deprecated_member_use
                            Radio<TripIssueType>(
                              value: issue,
                              // ignore: deprecated_member_use
                              groupValue: _selectedIssue,
                              // ignore: deprecated_member_use
                              activeColor: GVColors.primary,
                              // ignore: deprecated_member_use
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedIssue = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Optional notes
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: GVTypography.bodyMedium.copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Additional details (optional)...',
                  hintStyle: GVTypography.bodyMedium.copyWith(
                    color: GVColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GVBorderRadius.card),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GVBorderRadius.card),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GVBorderRadius.card),
                    borderSide: const BorderSide(color: GVColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Submit button
              GVButton(
                text: 'Submit report',
                type: GVButtonType.primary,
                isLoading: state.isLoading,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIssueIcon(TripIssueType type) {
    return switch (type) {
      TripIssueType.driverDidNotArrive => Icons.person_off_outlined,
      TripIssueType.driverWasLate => Icons.access_time_outlined,
      TripIssueType.safetyConcern => Icons.shield_outlined,
      TripIssueType.wrongRoute => Icons.alt_route_rounded,
      TripIssueType.handoverIssue => Icons.groups_outlined,
      TripIssueType.vehicleIssue => Icons.directions_car_outlined,
      TripIssueType.otherIssue => Icons.help_outline_rounded,
    };
  }
}

