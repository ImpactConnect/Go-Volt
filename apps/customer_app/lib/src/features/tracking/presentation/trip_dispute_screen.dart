import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/tracking_notifier.dart';

/// R13: Ride Issue & Dispute Reporting Screen.
class TripDisputeScreen extends ConsumerStatefulWidget {
  const TripDisputeScreen({super.key});

  @override
  ConsumerState<TripDisputeScreen> createState() => _TripDisputeScreenState();
}

class _TripDisputeScreenState extends ConsumerState<TripDisputeScreen> {
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Fare Discrepancy';
  bool _isSubmitting = false;
  String? _caseReference;

  final List<String> _disputeCategories = [
    'Fare Discrepancy',
    'Route or Traffic Issue',
    'Driver Conduct or Speed',
    'Safety or Security Concern',
    'Item Left Behind in Vehicle',
    'Vehicle Cleanliness or Condition',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitDispute() async {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe what happened.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final caseRef = await ref
        .read(liveTrackingNotifierProvider.notifier)
        .submitDispute(_selectedCategory, text);
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _caseReference = caseRef;
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(liveTrackingNotifierProvider);
    final tripReference =
        trackingState?.booking.bookingReference ?? 'GV-TRK-8392';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(title: 'Report Trip Issue'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: _caseReference != null
              ? _buildSuccessView()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(GVSpacing.md),
                        decoration: BoxDecoration(
                          color: GVColors.softBackground,
                          borderRadius:
                              BorderRadius.circular(GVBorderRadius.md),
                          border: Border.all(color: GVColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.receipt_long,
                                color: GVColors.deepGreen),
                            const SizedBox(width: GVSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Trip Reference',
                                      style: GVTypography.caption),
                                  Text(tripReference,
                                      style: GVTypography.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: GVSpacing.lg),

                      Text('Select Issue Category', style: GVTypography.h3),
                      const SizedBox(height: GVSpacing.sm),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _disputeCategories
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(
                                    cat,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),
                      const SizedBox(height: GVSpacing.md),

                      Text('Details of what occurred', style: GVTypography.h3),
                      const SizedBox(height: GVSpacing.sm),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText:
                              'Please describe the situation so Go-Volts support can investigate and take rapid action...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: GVSpacing.sm),
                      Text(
                        'Our customer success team will review this case and respond via email/push notification within 2 hours.',
                        style: GVTypography.caption
                            .copyWith(color: GVColors.textSecondary),
                      ),
                      const SizedBox(height: GVSpacing.xl),

                      GVPrimaryButton(
                        label: 'Submit Dispute Ticket',
                        isLoading: _isSubmitting,
                        onPressed: _handleSubmitDispute,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: const BoxDecoration(
              color: GVColors.statusActiveBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check,
                color: GVColors.brandGreen, size: 48),
          ),
          const SizedBox(height: GVSpacing.md),
          Text('Ticket Submitted', style: GVTypography.h2),
          const SizedBox(height: GVSpacing.xs),
          Text(
            'Case ID: $_caseReference',
            style: GVTypography.bodyMedium
                .copyWith(color: GVColors.deepGreen),
          ),
          const SizedBox(height: GVSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
            child: Text(
              'Your report has been logged with Go-Volts Operational Support. We are reviewing the trip telemetry and will follow up shortly.',
              textAlign: TextAlign.center,
              style: GVTypography.bodySmall
                  .copyWith(color: GVColors.textSecondary),
            ),
          ),
          const SizedBox(height: GVSpacing.xl),
          GVPrimaryButton(
            label: 'Return to Live Trip',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
