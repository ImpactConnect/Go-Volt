import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/booking_notifier.dart';

enum _RideStep {
  routePreview, // Screen 7: Route Preview & Serviceability
  chooseRide, // Screen 8: Ride Options ("Choose a ride")
  fareDetails, // Screen 9: Fare details & Payment method
  confirmRide, // Screen 10: Booking Confirmation ("Confirm your ride")
}

/// Screens 7, 8, 9, 10 — Ride Flow: Route Preview, Ride Options,
/// Fare Breakdown, and Final Booking Confirmation.
class RideBookingScreen extends ConsumerStatefulWidget {
  const RideBookingScreen({
    super.key,
    this.initialStep,
  });

  final String? initialStep;

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  late _RideStep _currentStep;
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _instructionsController =
      TextEditingController();

  String _selectedPaymentId = 'wallet';
  bool _agreedToTerms = true;
  DateTime? _scheduledDate;

  // Fallback server catalogue ride categories (v1.3 §5.4)
  static const List<RideCategoryDto> _defaultCategories = [
    RideCategoryDto(
      id: 'goride_standard',
      code: 'standard',
      name: 'GoRide Standard',
      description: 'Affordable and reliable',
      etaMinutes: 2,
      capacityLabel: '3 Seats',
      passengerCapacity: 3,
      baseFareKobo: 280000,
      features: ['AC', '3 Seats', 'Trusted riders'],
    ),
    RideCategoryDto(
      id: 'goride_plus',
      code: 'plus',
      name: 'GoRide Plus',
      description: 'More comfort',
      etaMinutes: 3,
      capacityLabel: '4 Seats',
      passengerCapacity: 4,
      baseFareKobo: 350000,
      features: ['AC', 'Extra legroom', 'Top rated'],
    ),
    RideCategoryDto(
      id: 'goride_xl',
      code: 'xl',
      name: 'GoRide XL',
      description: 'Bigger vehicles for more space',
      etaMinutes: 4,
      capacityLabel: '6 Seats',
      passengerCapacity: 6,
      baseFareKobo: 450000,
      features: ['AC', '6 Seats', 'Spacious trunk'],
    ),
    RideCategoryDto(
      id: 'goride_green',
      code: 'green',
      name: 'GoRide Green',
      description: 'Eco-friendly rides',
      etaMinutes: 3,
      capacityLabel: '4 Seats',
      passengerCapacity: 4,
      baseFareKobo: 300000,
      features: ['Zero emission', 'Quiet ride', 'Carbon offset'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    switch (widget.initialStep) {
      case 'options':
      case 'chooseRide':
        _currentStep = _RideStep.chooseRide;
        break;
      case 'fare':
      case 'fareDetails':
        _currentStep = _RideStep.fareDetails;
        break;
      case 'confirm':
      case 'confirmRide':
        _currentStep = _RideStep.confirmRide;
        break;
      default:
        _currentStep = _RideStep.routePreview;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingNotifierProvider.notifier).fetchRideCategories();
      ref.read(bookingNotifierProvider.notifier).fetchQuote();
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _handleBack() {
    switch (_currentStep) {
      case _RideStep.routePreview:
        Navigator.of(context).maybePop();
        break;
      case _RideStep.chooseRide:
        setState(() => _currentStep = _RideStep.routePreview);
        break;
      case _RideStep.fareDetails:
        setState(() => _currentStep = _RideStep.chooseRide);
        break;
      case _RideStep.confirmRide:
        setState(() => _currentStep = _RideStep.fareDetails);
        break;
    }
  }

  Future<void> _commitBooking() async {
    final notifier = ref.read(bookingNotifierProvider.notifier);
    final booking = await notifier.commitBooking();
    if (booking != null && mounted) {
      if (GoRouter.maybeOf(context) != null) {
        context.push(AppRoutes.findingDriver);
      } else {
        Navigator.of(context).pushNamed(AppRoutes.findingDriver);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (_currentStep) {
      case _RideStep.routePreview:
        return _buildRoutePreviewScreen(isDark: isDark);
      case _RideStep.chooseRide:
        return _buildChooseRideScreen(isDark: isDark);
      case _RideStep.fareDetails:
        return _buildFareDetailsScreen(isDark: isDark);
      case _RideStep.confirmRide:
        return _buildConfirmRideScreen(isDark: isDark);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Screen 7 — Route Preview & Serviceability
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRoutePreviewScreen({required bool isDark}) {
    final booking = ref.watch(bookingNotifierProvider);
    final quote = booking.quote;

    final pickup = booking.pickupLocation?.address ??
        'Eko Hotel and Suites, Victoria Island, Lagos';
    final dropoff =
        booking.dropoffLocation?.address ?? 'Palms Mall, Lekki, Lagos';

    final durationLabel =
        quote != null ? '${quote.estimatedDurationMinutes} min' : '12 min';
    final distanceLabel =
        quote != null ? '${quote.estimatedDistanceKm.toStringAsFixed(1)} km' : '8.4 km';
    final trafficCondition = quote?.trafficCondition ?? 'Light traffic';
    final isServiceable = quote?.isServiceable ?? true;
    final serviceableMsg = quote?.serviceabilityMessage ??
        'Rides are available in this area';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Map Background with Route Polyline
          Positioned.fill(
            child: _RouteMapCanvas(isDark: isDark),
          ),

          // Top Floating Navigation Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundBackButton(onTap: _handleBack, isDark: isDark),
                  _RoundIconButton(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Recenter GPS',
                    onTap: () {},
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Overview Card & Action
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                GVSpacing.lg,
                GVSpacing.lg,
                GVSpacing.lg,
                GVSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A16) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GVTripOverviewCard(
                      pickupAddress: pickup,
                      destinationAddress: dropoff,
                      durationLabel: durationLabel,
                      distanceLabel: distanceLabel,
                      trafficCondition: trafficCondition,
                      isServiceable: isServiceable,
                      serviceableMessage: serviceableMsg,
                      onChange: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // "See ride options" Action
                    GVPrimaryButton(
                      label: 'See ride options',
                      onPressed: isServiceable
                          ? () => setState(
                              () => _currentStep = _RideStep.chooseRide)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Screen 8 — Choose a Ride (Ride Options Catalogue)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildChooseRideScreen({required bool isDark}) {
    final booking = ref.watch(bookingNotifierProvider);
    final categories = booking.rideCategories.isNotEmpty
        ? booking.rideCategories
        : _defaultCategories;

    final selectedId = booking.selectedRideCategoryId ?? categories.first.id;
    final selectedCategory = categories.firstWhere(
      (c) => c.id == selectedId,
      orElse: () => categories.first,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131A16) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF131A16) : Colors.white,
        elevation: 0,
        leading: _RoundBackButton(onTap: _handleBack, isDark: isDark),
        centerTitle: true,
        title: Text(
          'Choose a ride',
          style: GVTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : GVColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(GVSpacing.lg),
                children: [
                  // Ride Categories List
                  ...categories.map((category) {
                    final isSelected = category.id == selectedId;
                    final priceLabel = category.formattedBaseFare;
                    final etaLabel = '${category.etaMinutes} min away';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: GVSpacing.md),
                      child: GVRideCategoryCard(
                        name: category.name,
                        priceLabel: priceLabel,
                        etaLabel: etaLabel,
                        description: category.description,
                        isSelected: isSelected,
                        features: isSelected
                            ? category.features
                                .map(
                                  (f) => GVRideFeatureBadge(
                                    label: f,
                                    icon: f.contains('AC')
                                        ? Icons.ac_unit_rounded
                                        : (f.contains('Seat')
                                            ? Icons.event_seat_rounded
                                            : Icons.verified_user_rounded),
                                  ),
                                )
                                .toList()
                            : const [],
                        onTap: () {
                          ref
                              .read(bookingNotifierProvider.notifier)
                              .selectRideCategory(category.id);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Bottom Selected Category Badges & Continue Button
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A221E) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Features summary row for selected category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CategoryFeaturePill(
                        icon: Icons.ac_unit_rounded,
                        label: 'AC',
                        isDark: isDark,
                      ),
                      _CategoryFeaturePill(
                        icon: Icons.event_seat_rounded,
                        label: selectedCategory.capacityLabel,
                        isDark: isDark,
                      ),
                      _CategoryFeaturePill(
                        icon: Icons.verified_user_rounded,
                        label: 'Trusted riders',
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.lg),

                  GVPrimaryButton(
                    label: 'Continue to fare details',
                    onPressed: () =>
                        setState(() => _currentStep = _RideStep.fareDetails),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Screen 9 — Fare Details & Payment Method
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFareDetailsScreen({required bool isDark}) {
    final booking = ref.watch(bookingNotifierProvider);
    final quote = booking.quote;
    final breakdown = quote?.priceBreakdown;

    final baseAmountLabel =
        breakdown?.formattedBaseAmount ?? '₦1,500';
    final distanceAmountLabel =
        breakdown?.formattedDistanceAmount ?? '₦1,100';
    final timeAmountLabel =
        breakdown?.formattedTimeAmount ?? '₦300';
    final serviceFeeLabel =
        breakdown?.formattedServiceFee ?? '₦200';

    final totalFareLabel =
        breakdown?.formattedTotalAmount ?? '₦3,200';
    final estimatedRangeLabel =
        breakdown?.estimatedRangeDisplay ?? '(₦2,800 - ₦3,500)';

    final appliedCoupon = booking.appliedCoupon;
    final promoDiscountLabel = appliedCoupon?.formattedDiscount;

    final fareItems = [
      GVFareItem(label: 'Base fare', amountLabel: baseAmountLabel),
      GVFareItem(
        label:
            'Distance (${quote?.estimatedDistanceKm.toStringAsFixed(1) ?? '8.4'} km)',
        amountLabel: distanceAmountLabel,
      ),
      GVFareItem(
        label: 'Time (${quote?.estimatedDurationMinutes ?? 12} min)',
        amountLabel: timeAmountLabel,
      ),
      GVFareItem(label: 'Service fee', amountLabel: serviceFeeLabel),
      if (appliedCoupon != null && appliedCoupon.isValid)
        GVFareItem(
          label: 'Promo discount',
          amountLabel: '-$promoDiscountLabel',
          isDiscount: true,
        ),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131A16) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF131A16) : Colors.white,
        elevation: 0,
        leading: _RoundBackButton(onTap: _handleBack, isDark: isDark),
        centerTitle: true,
        title: Text(
          'Fare details',
          style: GVTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : GVColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(GVSpacing.lg),
                children: [
                  // Fare Breakdown Card
                  GVFareBreakdownCard(
                    title: 'Fare breakdown',
                    items: fareItems,
                    totalLabel: totalFareLabel,
                    rangeLabel: estimatedRangeLabel,
                    noticeText:
                        'Final fare may vary slightly\nDue to traffic, route changes or waiting time.',
                    promoCode: appliedCoupon?.code,
                    promoDiscountLabel: promoDiscountLabel,
                    promoController: _promoController,
                    isApplyingPromo: booking.isApplyingCoupon,
                    promoError: booking.couponError,
                    onApplyPromo: (code) {
                      ref
                          .read(bookingNotifierProvider.notifier)
                          .applyCoupon(code);
                    },
                    onRemovePromo: () {
                      ref
                          .read(bookingNotifierProvider.notifier)
                          .removeCoupon();
                      _promoController.clear();
                    },
                  ),
                  const SizedBox(height: GVSpacing.xl),

                  // Payment Method Section
                  Text(
                    'Payment method',
                    style: GVTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : GVColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: GVSpacing.sm),

                  // 1. Go-Volts Wallet
                  GVPaymentMethodTile(
                    title: 'Go-Volts Wallet',
                    subtitle: 'Balance: ₦5,200.00',
                    icon: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: GVColors.brandGreen,
                      size: 22,
                    ),
                    isSelected: _selectedPaymentId == 'wallet',
                    onTap: () {
                      setState(() => _selectedPaymentId = 'wallet');
                      ref
                          .read(bookingNotifierProvider.notifier)
                          .setPaymentMethod(PaymentMethod.wallet);
                    },
                  ),
                  const SizedBox(height: GVSpacing.sm),

                  // 2. Add New Card
                  GVPaymentMethodTile(
                    title: 'Add new card',
                    subtitle: 'Debit or credit card',
                    icon: const Icon(
                      Icons.credit_card_rounded,
                      color: GVColors.info,
                      size: 22,
                    ),
                    isSelectable: false,
                    isSelected: _selectedPaymentId == 'card',
                    onTap: () {
                      setState(() => _selectedPaymentId = 'card');
                      ref
                          .read(bookingNotifierProvider.notifier)
                          .setPaymentMethod(PaymentMethod.card);
                    },
                  ),
                  const SizedBox(height: GVSpacing.sm),

                  // 3. Bank Account
                  GVPaymentMethodTile(
                    title: 'Bank account',
                    subtitle: 'Pay directly from your bank',
                    icon: const Icon(
                      Icons.account_balance_rounded,
                      color: GVColors.deepGreen,
                      size: 22,
                    ),
                    isSelectable: false,
                    isSelected: _selectedPaymentId == 'bank',
                    onTap: () {
                      setState(() => _selectedPaymentId = 'bank');
                    },
                  ),
                  const SizedBox(height: GVSpacing.sm),

                  // 4. Cash
                  GVPaymentMethodTile(
                    title: 'Cash',
                    subtitle: 'Pay with cash',
                    icon: const Icon(
                      Icons.money_rounded,
                      color: GVColors.warning,
                      size: 22,
                    ),
                    isSelectable: false,
                    isSelected: _selectedPaymentId == 'cash',
                    onTap: () {
                      setState(() => _selectedPaymentId = 'cash');
                      ref
                          .read(bookingNotifierProvider.notifier)
                          .setPaymentMethod(PaymentMethod.cash);
                    },
                  ),
                  const SizedBox(height: GVSpacing.sm),

                  // 5. Other Payment Options
                  GVPaymentMethodTile(
                    title: 'Other payment options',
                    subtitle: 'e.g. USSD, mobile money',
                    icon: const Icon(
                      Icons.phone_iphone_rounded,
                      color: GVColors.deepPurple,
                      size: 22,
                    ),
                    isSelectable: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Bottom Sticky Total & Confirm Action
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A221E) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total fare',
                        style: GVTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : GVColors.textPrimary,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            totalFareLabel,
                            style: GVTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w900,
                              color:
                                  isDark ? Colors.white : GVColors.textPrimary,
                            ),
                          ),
                          Text(
                            estimatedRangeLabel,
                            style: GVTypography.caption.copyWith(
                              color: isDark
                                  ? GVColors.neutral400
                                  : GVColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.md),
                  GVPrimaryButton(
                    label: 'Confirm ride',
                    onPressed: () =>
                        setState(() => _currentStep = _RideStep.confirmRide),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Screen 10 — Booking Confirmation ("Confirm your ride")
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildConfirmRideScreen({required bool isDark}) {
    final booking = ref.watch(bookingNotifierProvider);
    final quote = booking.quote;
    final breakdown = quote?.priceBreakdown;

    final categories = booking.rideCategories.isNotEmpty
        ? booking.rideCategories
        : _defaultCategories;
    final selectedCategory = categories.firstWhere(
      (c) => c.id == (booking.selectedRideCategoryId ?? categories.first.id),
      orElse: () => categories.first,
    );

    final pickup = booking.pickupLocation?.address ??
        'Eko Hotel and Suites, Victoria Island, Lagos';
    final dropoff =
        booking.dropoffLocation?.address ?? 'Palms Mall, Lekki, Lagos';

    final totalAmountLabel =
        breakdown != null ? breakdown.formattedTotalAmount : '₦3,200';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131A16) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF131A16) : Colors.white,
        elevation: 0,
        leading: _RoundBackButton(onTap: _handleBack, isDark: isDark),
        centerTitle: true,
        title: Text(
          'Confirm your ride',
          style: GVTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : GVColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(GVSpacing.lg),
                children: [
                  // 1. Route Snippet Card
                  Container(
                    padding: const EdgeInsets.all(GVSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A221E)
                          : GVColors.softBackground,
                      borderRadius: GVBorderRadius.cardRadius,
                      border: Border.all(
                        color:
                            isDark ? const Color(0xFF2E3D35) : GVColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: GVColors.brandGreen,
                              ),
                            ),
                            const SizedBox(width: GVSpacing.md),
                            Expanded(
                              child: Text(
                                pickup,
                                style: GVTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 2,
                              height: 18,
                              color: isDark
                                  ? GVColors.neutral600
                                  : GVColors.neutral300,
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: GVColors.error,
                              ),
                            ),
                            const SizedBox(width: GVSpacing.md),
                            Expanded(
                              child: Text(
                                dropoff,
                                style: GVTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),

                  // 2. Selected Category Card
                  Container(
                    padding: const EdgeInsets.all(GVSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A221E) : Colors.white,
                      borderRadius: GVBorderRadius.cardRadius,
                      border: Border.all(
                        color:
                            isDark ? const Color(0xFF2E3D35) : GVColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF243029)
                                : GVColors.softBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.directions_car_rounded,
                            size: 26,
                            color: GVColors.brandGreen,
                          ),
                        ),
                        const SizedBox(width: GVSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedCategory.name,
                                style: GVTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${selectedCategory.etaMinutes} min away',
                                style: GVTypography.caption.copyWith(
                                  color: isDark
                                      ? GVColors.neutral400
                                      : GVColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          totalAmountLabel,
                          style: GVTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : GVColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),

                  // 3. Payment Method Card
                  Container(
                    padding: const EdgeInsets.all(GVSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A221E) : Colors.white,
                      borderRadius: GVBorderRadius.cardRadius,
                      border: Border.all(
                        color:
                            isDark ? const Color(0xFF2E3D35) : GVColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                GVColors.brandGreen.withValues(alpha: 0.12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: GVColors.brandGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: GVSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Go-Volts Wallet',
                                style: GVTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                              Text(
                                '₦5,200.00',
                                style: GVTypography.caption.copyWith(
                                  color: isDark
                                      ? GVColors.neutral400
                                      : GVColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(
                              () => _currentStep = _RideStep.fareDetails),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),

                  // 4. Extra Actions ("+ Add stop", "Schedule for later")
                  _ConfirmActionTile(
                    icon: Icons.add_rounded,
                    title: 'Add stop (optional)',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Multi-stop rides coming soon'),
                        ),
                      );
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  _ConfirmActionTile(
                    icon: Icons.calendar_today_rounded,
                    title: _scheduledDate == null
                        ? 'Schedule for later'
                        : 'Scheduled: ${_scheduledDate!.hour}:${_scheduledDate!.minute.toString().padLeft(2, '0')}',
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        final now = DateTime.now();
                        setState(() {
                          _scheduledDate = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: GVSpacing.lg),

                  // 5. Terms & Privacy Agreement
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        activeColor: GVColors.brandGreen,
                        onChanged: (val) {
                          setState(() => _agreedToTerms = val ?? true);
                        },
                      ),
                      Expanded(
                        child: Text(
                          'By booking, you agree to our Terms of Service and Privacy Policy.',
                          style: GVTypography.caption.copyWith(
                            color: isDark
                                ? GVColors.neutral400
                                : GVColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Book Ride Action
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A221E) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
                  ),
                ),
              ),
              child: GVPrimaryButton(
                label: 'Book ride',
                isLoading: booking.isCreatingBooking,
                onPressed: _agreedToTerms ? _commitBooking : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Helper UI Widgets
// ═══════════════════════════════════════════════════════════════════════════

class _CategoryFeaturePill extends StatelessWidget {
  const _CategoryFeaturePill({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF243029) : GVColors.softBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? GVColors.neutral300 : GVColors.neutral700,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GVTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : GVColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmActionTile extends StatelessWidget {
  const _ConfirmActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: GVBorderRadius.cardRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: GVSpacing.md,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A221E) : Colors.white,
          borderRadius: GVBorderRadius.cardRadius,
          border: Border.all(
            color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? GVColors.neutral400 : GVColors.neutral600,
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Text(
                title,
                style: GVTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : GVColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onTap, required this.isDark});
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _RoundIconButton(
      icon: Icons.arrow_back_rounded,
      tooltip: 'Back',
      onTap: onTap,
      isDark: isDark,
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF1E2621) : Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        color: isDark ? Colors.white : GVColors.textPrimary,
        onPressed: onTap,
      ),
    );
  }
}

/// Simulated Map with curved polyline connecting pickup to dropoff
class _RouteMapCanvas extends StatelessWidget {
  const _RouteMapCanvas({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RouteMapPainter(isDark: isDark),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  _RouteMapPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor =
        isDark ? const Color(0xFF111814) : const Color(0xFFE8ECE9);
    final streetColor =
        isDark ? const Color(0xFF1E2822) : const Color(0xFFFCFDFD);
    final waterColor =
        isDark ? const Color(0xFF0D1D22) : const Color(0xFFD0E3EA);

    // Land base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    // Water channel
    final waterPath = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.35,
        size.width,
        size.height * 0.20,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(waterPath, Paint()..color = waterColor);

    // Grid streets
    final streetPaint = Paint()
      ..color = streetColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.52),
      streetPaint,
    );

    // Green dynamic Route Polyline connecting VI to Lekki
    final routePaint = Paint()
      ..color = GVColors.brandGreen
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.42)
      ..cubicTo(
        size.width * 0.40,
        size.height * 0.42,
        size.width * 0.60,
        size.height * 0.55,
        size.width * 0.80,
        size.height * 0.52,
      );

    canvas.drawPath(routePath, routePaint);

    // Pickup Marker (Green Pin)
    final pickupCenter = Offset(size.width * 0.25, size.height * 0.42);
    canvas.drawCircle(
      pickupCenter,
      8,
      Paint()..color = GVColors.brandGreen,
    );
    canvas.drawCircle(
      pickupCenter,
      4,
      Paint()..color = Colors.white,
    );

    // Dropoff Marker (Red Pin)
    final dropoffCenter = Offset(size.width * 0.80, size.height * 0.52);
    canvas.drawCircle(
      dropoffCenter,
      8,
      Paint()..color = GVColors.error,
    );
    canvas.drawCircle(
      dropoffCenter,
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter oldDelegate) => false;
}
