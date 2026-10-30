import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../application/tracking_notifier.dart';

/// R11 & D09: Trip Completed, Eco-Points Earned, Receipt and Driver Rating Screen.
class TripCompletedScreen extends ConsumerStatefulWidget {
  const TripCompletedScreen({super.key});

  @override
  ConsumerState<TripCompletedScreen> createState() =>
      _TripCompletedScreenState();
}

class _TripCompletedScreenState extends ConsumerState<TripCompletedScreen> {
  double _selectedRating = 5.0;
  int _selectedTipKobo = 0;
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  final List<int> _tipPresets = [0, 20000, 50000, 100000]; // ₦0, ₦200, ₦500, ₦1000

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitReview() async {
    setState(() => _isSubmitting = true);
    final notifier = ref.read(liveTrackingNotifierProvider.notifier);
    notifier.setTripRating(
      _selectedRating,
      tipKobo: _selectedTipKobo,
      feedback: _feedbackController.text.trim(),
    );
    await notifier.submitTripRating();
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rating and Eco-Points saved to your profile!'),
        backgroundColor: GVColors.brandGreen,
      ),
    );
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(liveTrackingNotifierProvider);
    final booking = trackingState?.booking;
    final breakdown = booking?.priceBreakdown ??
        const PriceBreakdownDto(
          baseFare: 500.0,
          distanceFare: 1200.0,
          timeFare: 300.0,
          totalFare: 2200.0,
        );

    final driverName = booking?.riderName ?? 'Babatunde Raji';
    const co2Saved = 1.4;
    final ecoPointsEarned = (co2Saved * 10).round() + 5; // e.g., 19 points

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(
        title: 'Trip Summary',
        leading: SizedBox.shrink(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Celebration checkmark
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: GVColors.statusActiveBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: GVColors.brandGreen,
                  size: 44,
                ),
              ),
              const SizedBox(height: GVSpacing.sm),
              Text('You Have Arrived!', style: GVTypography.h2),
              Text(
                'Thank you for riding electric with Go-Volts',
                style: GVTypography.bodySmall
                    .copyWith(color: GVColors.textSecondary),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Eco-Points & Carbon Offset Banner
              Container(
                width: double.infinity,
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.eco,
                            color: GVColors.brandGreen, size: 24),
                        const SizedBox(width: GVSpacing.xs),
                        Flexible(
                          child: Text(
                            '${co2Saved.toStringAsFixed(1)} kg CO₂ Avoided',
                            style: GVTypography.h3.copyWith(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+$ecoPointsEarned Eco-Points credited to your Go-Volts Wallet',
                      style: GVTypography.bodySmallMedium
                          .copyWith(color: GVColors.accentGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Final Fare breakdown
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: GVColors.softBackground,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: GVColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text('Total Fare Paid',
                              style: GVTypography.bodyMedium,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Flexible(
                          child: Text(
                            '₦${breakdown.totalFare.toStringAsFixed(0)}',
                            style: GVTypography.h2
                                .copyWith(color: GVColors.deepGreen),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: GVSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text('Payment Method',
                              style: GVTypography.caption,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Flexible(
                          child: Text(
                            'Go-Volts Wallet (Paid)',
                            style: GVTypography.bodySmallMedium
                                .copyWith(color: GVColors.brandGreen),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text('Booking Reference',
                              style: GVTypography.caption,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Flexible(
                          child: Text(
                            booking?.bookingReference ?? 'GV-TRK-8392',
                            style: GVTypography.bodySmallMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Rating driver section
              Text('Rate $driverName', style: GVTypography.h3),
              const SizedBox(height: 6),
              Text(
                'How was your zero-emission journey?',
                style: GVTypography.bodySmall
                    .copyWith(color: GVColors.textSecondary),
              ),
              const SizedBox(height: GVSpacing.sm),

              // Interactive 5-Star Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starVal = index + 1.0;
                  final isSelected = starVal <= _selectedRating;
                  return IconButton(
                    iconSize: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: Icon(
                      isSelected
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: isSelected ? GVColors.warning : GVColors.border,
                    ),
                    onPressed: () => setState(() => _selectedRating = starVal),
                  );
                }),
              ),
              const SizedBox(height: GVSpacing.md),

              // Driver tip selector
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Add a Tip for Driver',
                    style: GVTypography.bodySmallMedium),
              ),
              const SizedBox(height: GVSpacing.xs),
              Row(
                children: _tipPresets.map((amountKobo) {
                  final isSelected = _selectedTipKobo == amountKobo;
                  final label =
                      amountKobo == 0 ? 'No tip' : '₦${amountKobo ~/ 100}';
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              isSelected ? GVColors.brandGreen : Colors.white,
                          foregroundColor: isSelected
                              ? GVColors.deepGreen
                              : GVColors.nearBlack,
                          side: BorderSide(
                            color: isSelected
                                ? GVColors.brandGreen
                                : GVColors.border,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () =>
                            setState(() => _selectedTipKobo = amountKobo),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: GVSpacing.md),

              // Optional feedback input
              TextField(
                controller: _feedbackController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Leave a compliment or feedback (optional)',
                  hintText: 'e.g., Smooth electric ride, courteous driver...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Done CTA
              GVPrimaryButton(
                label: 'Complete & Return Home',
                isLoading: _isSubmitting,
                onPressed: _handleSubmitReview,
              ),
              const SizedBox(height: GVSpacing.sm),
              GVSecondaryButton(
                label: 'View Itemized Tax Receipt',
                onPressed: () => context.push(AppRoutes.receipt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
