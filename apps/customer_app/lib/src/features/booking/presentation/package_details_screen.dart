import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/booking_notifier.dart';

/// D01 - D04 — Instant Parcel Delivery Details Screen
class PackageDetailsScreen extends ConsumerStatefulWidget {
  const PackageDetailsScreen({super.key});

  @override
  ConsumerState<PackageDetailsScreen> createState() =>
      _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends ConsumerState<PackageDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _instructionsController = TextEditingController();

  PackageCategory _selectedCategory = PackageCategory.general;
  double _weightKg = 1.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingNotifierProvider.notifier).fetchQuote();
    });
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _submitDelivery() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(bookingNotifierProvider.notifier);
    notifier.setPackageDetails(
      category: _selectedCategory,
      weightKg: _weightKg,
      recipientName: _recipientNameController.text.trim(),
      recipientPhone: _recipientPhoneController.text.trim(),
      instructions: _instructionsController.text.trim(),
    );

    final booking = await notifier.commitBooking();
    if (booking != null && mounted) {
      context.push(AppRoutes.findingDriver);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingNotifierProvider);
    final quote = bookingState.quote;
    final breakdown = quote?.priceBreakdown;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(title: 'Send Package'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Route overview card
                Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: GVColors.softBackground,
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    border: Border.all(color: GVColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_rounded,
                          color: GVColors.brandGreen, size: 28),
                      const SizedBox(width: GVSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Doorstep Courier Delivery',
                              style: GVTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Fast electric dispatch • 100% emission free',
                              style: GVTypography.caption.copyWith(
                                color: GVColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: GVSpacing.lg),

                // 2. Package Category Selector
                Text(
                  'Package Category',
                  style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: GVSpacing.sm),

                Wrap(
                  spacing: GVSpacing.sm,
                  children: [
                    _buildCategoryChip(
                      category: PackageCategory.general,
                      label: 'Box / Parcel',
                      icon: Icons.inventory_2_outlined,
                    ),
                    _buildCategoryChip(
                      category: PackageCategory.documents,
                      label: 'Documents',
                      icon: Icons.description_outlined,
                    ),
                    _buildCategoryChip(
                      category: PackageCategory.food,
                      label: 'Food / Perishable',
                      icon: Icons.fastfood_outlined,
                    ),
                    _buildCategoryChip(
                      category: PackageCategory.fragile,
                      label: 'Fragile Electronics',
                      icon: Icons.warning_amber_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.lg),

                // 3. Weight Bracket Selector
                Text(
                  'Approximate Weight',
                  style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: GVSpacing.sm),

                Row(
                  children: [
                    _buildWeightRadio(label: '< 2 kg', weight: 1.5),
                    const SizedBox(width: GVSpacing.sm),
                    _buildWeightRadio(label: '2 – 5 kg', weight: 3.5),
                    const SizedBox(width: GVSpacing.sm),
                    _buildWeightRadio(label: '5 – 15 kg', weight: 8.0),
                  ],
                ),
                const SizedBox(height: GVSpacing.lg),

                // 4. Recipient Details
                Text(
                  'Recipient Information',
                  style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: GVSpacing.sm),

                GVFormField(
                  label: 'Recipient Full Name',
                  hint: 'e.g. Babatunde Raji',
                  controller: _recipientNameController,
                  prefix: const Icon(Icons.person_outline_rounded),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter recipient name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.md),

                GVFormField(
                  label: 'Recipient Phone Number',
                  hint: '802 345 6789',
                  controller: _recipientPhoneController,
                  keyboardType: TextInputType.phone,
                  prefix: Container(
                    padding: const EdgeInsets.symmetric(horizontal: GVSpacing.sm),
                    alignment: Alignment.centerLeft,
                    width: 72,
                    child: Text(
                      '🇳🇬 +234',
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter recipient phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.md),

                GVFormField(
                  label: 'Delivery Instructions (Optional)',
                  hint: 'e.g. Leave with security guard at reception',
                  controller: _instructionsController,
                  prefix: const Icon(Icons.comment_outlined),
                ),
                const SizedBox(height: GVSpacing.lg),

                // 5. Upfront Fare Breakdown
                if (breakdown != null) ...[
                  GVPriceBreakdown(
                    isEstimate: false,
                    lines: [
                      GVPriceLine(
                        label: 'Courier Base Rate',
                        amountLabel: '₦${breakdown.baseFare.toStringAsFixed(0)}',
                      ),
                      GVPriceLine(
                        label: 'Distance Fare (~${quote?.estimatedDistanceKm.toStringAsFixed(1) ?? '6.2'} km)',
                        amountLabel:
                            '₦${breakdown.distanceFare.toStringAsFixed(0)}',
                      ),
                      GVPriceLine(
                        label: 'Carbon Offset Savings',
                        amountLabel: '-₦${breakdown.discountAmount.toStringAsFixed(0)}',
                        isDiscount: true,
                      ),
                      GVPriceLine(
                        label: 'Parcel Insurance & Handling',
                        amountLabel: '₦${breakdown.platformFee.toStringAsFixed(0)}',
                      ),
                    ],
                    totalLabel: '₦${breakdown.totalFare.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: GVSpacing.lg),
                ],

                // 6. Submit Button
                GVPrimaryButton(
                  label: 'Confirm Electric Delivery',
                  isLoading: bookingState.isCreatingBooking,
                  onPressed: _submitDelivery,
                ),
                const SizedBox(height: GVSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required PackageCategory category,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedCategory = category),
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : GVColors.textPrimary,
      ),
      label: Text(label),
      selectedColor: GVColors.brandGreen,
      backgroundColor: GVColors.softBackground,
      labelStyle: GVTypography.bodySmall.copyWith(
        color: isSelected ? Colors.white : GVColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildWeightRadio({required String label, required double weight}) {
    final isSelected = _weightKg == weight;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _weightKg = weight),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: GVSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? GVColors.brandGreen.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(GVBorderRadius.sm),
            border: Border.all(
              color: isSelected ? GVColors.brandGreen : GVColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GVTypography.bodySmallMedium.copyWith(
              color: isSelected ? GVColors.brandGreen : GVColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
