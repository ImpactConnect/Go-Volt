import 'dart:async';
import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Screen RD10: High-visibility Dispatch Offer Modal with countdown timer and trip economics.
class DispatchOfferModal extends StatefulWidget {
  const DispatchOfferModal({
    super.key,
    required this.offer,
    required this.onAccept,
    required this.onDecline,
  });

  final DispatchOfferDto offer;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  State<DispatchOfferModal> createState() => _DispatchOfferModalState();
}

class _DispatchOfferModalState extends State<DispatchOfferModal> {
  late int _remainingSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.offer.remainingSeconds;
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = widget.offer.remainingSeconds;
      setState(() => _remainingSeconds = remaining);
      if (remaining <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final progress = (_remainingSeconds / offer.timeoutSeconds).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141917),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: GVColors.brandGreen, width: 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header & Countdown Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: GVColors.deepGreen,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: GVColors.brandGreen),
                            ),
                            child: Text(
                              offer.serviceType.label.toUpperCase(),
                              style: GVTypography.caption.copyWith(
                                color: GVColors.brandGreen,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (offer.surgeMultiplier > 1.0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B2A10),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.amber),
                            ),
                            child: Text(
                              '⚡ ${offer.surgeMultiplier}x Surge',
                              style: GVTypography.caption.copyWith(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Timer Badge
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: _remainingSeconds <= 5 ? Colors.redAccent : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_remainingSeconds}s',
                        style: GVTypography.label.copyWith(
                          color: _remainingSeconds <= 5 ? Colors.redAccent : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFF232D28),
                  valueColor: AlwaysStoppedAnimation(
                    _remainingSeconds <= 5 ? Colors.redAccent : GVColors.brandGreen,
                  ),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Net Earnings Spotlight
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR TAKE-HOME (80%)',
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₦${offer.netEarningsNaira.toStringAsFixed(0)} net',
                          style: GVTypography.h1.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Gross: ₦${offer.grossFareNaira.toStringAsFixed(0)}',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                        ),
                        Text(
                          'Fee: ₦${(offer.grossFareNaira - offer.netEarningsNaira).toStringAsFixed(0)} (20%)',
                          style: GVTypography.caption.copyWith(color: Colors.white54),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          offer.paymentMethod,
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Route & Waypoints Details
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2420),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFF2A3630)),
                ),
                child: Column(
                  children: [
                    // Pickup Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.radio_button_checked, color: GVColors.brandGreen, size: 18),
                        const SizedBox(width: GVSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PICKUP · ${offer.pickupDistanceKm} km away (${offer.pickupEtaMinutes} min)',
                                style: GVTypography.caption.copyWith(
                                  color: GVColors.brandGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                offer.pickupAddress,
                                style: GVTypography.bodyMedium.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(color: Colors.white12, height: 1),
                    ),
                    // Dropoff Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.amber, size: 18),
                        const SizedBox(width: GVSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DROPOFF · ${offer.tripDistanceKm} km (${offer.estimatedTripMinutes} min trip)',
                                style: GVTypography.caption.copyWith(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                offer.dropoffAddress,
                                style: GVTypography.bodyMedium.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Conditional Service Tier Details
              if (offer.serviceType == ServiceTierEligibility.parcelDelivery &&
                  offer.parcelDescription != null) ...[
                const SizedBox(height: GVSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(GVSpacing.xs),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2420),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A3630)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: GVColors.brandGreen, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${offer.parcelDescription!} · ${offer.packageWeightKg ?? 1.0}kg${offer.isFragile ? ' (FRAGILE)' : ''}',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (offer.serviceType == ServiceTierEligibility.schoolRunCommute) ...[
                const SizedBox(height: GVSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(GVSpacing.xs),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132F23),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GVColors.brandGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school, color: GVColors.brandGreen, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Student: ${offer.childName ?? "Child"} · OTP Verification Required',
                          style: GVTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: GVSpacing.md),

              // Actions: Accept / Decline
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: widget.onDecline,
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  Expanded(
                    flex: 4,
                    child: GVPrimaryButton(
                      label: 'Accept Offer',
                      onPressed: _remainingSeconds > 0 ? widget.onAccept : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
