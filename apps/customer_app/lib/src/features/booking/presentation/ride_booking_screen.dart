import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/booking_notifier.dart';

/// R02, R03, R04, R05 — Ride Electric Booking & Upfront Quote Screen
class RideBookingScreen extends ConsumerStatefulWidget {
  const RideBookingScreen({super.key});

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingNotifierProvider.notifier).fetchQuote();
    });
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    final booking =
        await ref.read(bookingNotifierProvider.notifier).commitBooking();
    if (booking != null && mounted) {
      context.push(AppRoutes.findingDriver);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingNotifierProvider);
    final quote = bookingState.quote;
    final breakdown = quote?.priceBreakdown;
    final selectedVehicle = bookingState.selectedVehicleType;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(title: 'Ride Electric'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Route summary header
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
                      children: [
                        const Icon(Icons.radio_button_checked,
                            color: GVColors.brandGreen, size: 16),
                        const SizedBox(width: GVSpacing.sm),
                        Expanded(
                          child: Text(
                            bookingState.pickupLocation?.address ?? 'Marina, Lagos Island',
                            style: GVTypography.bodySmallMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 7),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 14,
                          child: VerticalDivider(
                            color: GVColors.border,
                            thickness: 2,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: GVColors.nearBlack, size: 16),
                        const SizedBox(width: GVSpacing.sm),
                        Expanded(
                          child: Text(
                            bookingState.dropoffLocation?.address ?? 'Victoria Island',
                            style: GVTypography.bodySmallMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // 2. EV Vehicle Selection
              Text(
                'Select Electric Class',
                style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: GVSpacing.sm),

              _buildVehicleOption(
                type: VehicleType.electricBike,
                name: 'Volt Bike',
                capacity: '1 person',
                etaMinutes: 3,
                co2Offset: '0.4 kg',
                fareMultiplier: 1.0,
                baseFare: breakdown?.totalFare ?? 1200,
                icon: Icons.electric_scooter_rounded,
                isSelected: selectedVehicle == VehicleType.electricBike,
              ),
              const SizedBox(height: GVSpacing.sm),

              _buildVehicleOption(
                type: VehicleType.electricTricycle,
                name: 'Volt Trike (Comfort)',
                capacity: '3 seats • Covered EV',
                etaMinutes: 5,
                co2Offset: '1.2 kg',
                fareMultiplier: 1.6,
                baseFare: (breakdown?.totalFare ?? 1200) * 1.6,
                icon: Icons.electric_rickshaw_rounded,
                isSelected: selectedVehicle == VehicleType.electricTricycle,
              ),
              const SizedBox(height: GVSpacing.sm),

              _buildVehicleOption(
                type: VehicleType.electricVan,
                name: 'Volt Cargo / Executive',
                capacity: '500 kg payload / 6 seats',
                etaMinutes: 8,
                co2Offset: '2.0 kg',
                fareMultiplier: 2.2,
                baseFare: (breakdown?.totalFare ?? 1200) * 2.2,
                icon: Icons.airport_shuttle_rounded,
                isSelected: selectedVehicle == VehicleType.electricVan,
              ),
              const SizedBox(height: GVSpacing.lg),

              // 3. Price Breakdown Component
              if (bookingState.isLoadingQuote)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(GVSpacing.md),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (breakdown != null) ...[
                GVPriceBreakdown(
                  isEstimate: false,
                  estimateDisclaimer:
                      'Binding upfront fare. Zero surge surprise upon arrival.',
                  lines: [
                    GVPriceLine(
                      label: 'Base Fare',
                      amountLabel: '₦${breakdown.baseFare.toStringAsFixed(0)}',
                    ),
                    GVPriceLine(
                      label:
                          'Distance Fare (~${quote?.estimatedDistanceKm.toStringAsFixed(1) ?? '8.5'} km)',
                      amountLabel:
                          '₦${breakdown.distanceFare.toStringAsFixed(0)}',
                    ),
                    GVPriceLine(
                      label: 'Clean Air Subsidy',
                      amountLabel: '-₦${breakdown.discountAmount.toStringAsFixed(0)}',
                      isDiscount: true,
                    ),
                    GVPriceLine(
                      label: 'Platform & Safety Fee',
                      amountLabel: '₦${breakdown.platformFee.toStringAsFixed(0)}',
                    ),
                  ],
                  totalLabel: '₦${breakdown.totalFare.toStringAsFixed(0)}',
                ),
                const SizedBox(height: GVSpacing.lg),
              ],

              // 4. Payment Method Selector
              Text(
                'Payment Method',
                style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: GVSpacing.sm),

              GVPaymentMethodRow(
                selectedId: bookingState.selectedPaymentMethod.code,
                onSelected: (id) {
                  ref
                      .read(bookingNotifierProvider.notifier)
                      .setPaymentMethod(PaymentMethod.fromString(id));
                },
                methods: const [
                  GVPaymentMethod(
                    id: 'WALLET',
                    label: 'Go-Volts Wallet',
                    subtitle: 'Balance: ₦15,000 (Instant checkout)',
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                  GVPaymentMethod(
                    id: 'CARD',
                    label: 'Debit Card (Paystack)',
                    subtitle: 'Mastercard •••• 4242',
                    icon: Icons.credit_card_rounded,
                  ),
                  GVPaymentMethod(
                    id: 'CASH',
                    label: 'Cash / Direct Bank Transfer',
                    subtitle: 'Pay rider directly upon arrival',
                    icon: Icons.payments_outlined,
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.lg),

              // 5. Driver Pickup Instructions
              GVFormField(
                label: 'Driver Instructions (Optional)',
                hint: 'e.g. Waiting by the blue gate / Call when outside',
                controller: _instructionsController,
                prefix: const Icon(Icons.note_alt_outlined),
              ),
              const SizedBox(height: GVSpacing.xl),

              // 6. Action Button
              GVPrimaryButton(
                label: 'Confirm Electric Ride',
                isLoading: bookingState.isCreatingBooking,
                onPressed: _confirmBooking,
              ),
              const SizedBox(height: GVSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleOption({
    required VehicleType type,
    required String name,
    required String capacity,
    required int etaMinutes,
    required String co2Offset,
    required double fareMultiplier,
    required double baseFare,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(bookingNotifierProvider.notifier).selectVehicleType(type);
      },
      child: Container(
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? GVColors.softBackground : Colors.white,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(
            color: isSelected ? GVColors.brandGreen : GVColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? GVShadows.elevated : GVShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? GVColors.brandGreen.withValues(alpha: 0.15)
                    : GVColors.softBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? GVColors.brandGreen : GVColors.nearBlack,
                size: 26,
              ),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: GVTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: GVSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: GVColors.limeHighlight.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$co2Offset CO₂',
                          style: GVTypography.caption.copyWith(
                            color: GVColors.deepGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$capacity • $etaMinutes min away',
                    style: GVTypography.bodySmall.copyWith(
                      color: GVColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₦${baseFare.toStringAsFixed(0)}',
              style: GVTypography.amountSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? GVColors.brandGreen : GVColors.nearBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
