import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 3 — Package Details (Category Grid, Weight Stepper, Size Selector, Special Handling).
class PackageDetailsScreen extends ConsumerWidget {
  const PackageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parcelBookingNotifierProvider);
    final notifier = ref.read(parcelBookingNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = ParcelCategoryDto.defaultCategories;
    final sizeBands = ParcelSizeBandDto.defaultBands;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : GVColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? GVColors.white : GVColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (GoRouter.maybeOf(context) != null) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          'Package details',
          style: GVTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: GVSpacing.xs),

                    // Top Package Box Illustration Header
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF16201B)
                            : const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                      ),
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8A87C).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.inventory_2_rounded,
                            size: 38,
                            color: Color(0xFFD38B5D),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // 1. Package Category Header & Grid
                    Text(
                      'Package category',
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.sm),
                    GVPackageCategoryGrid(
                      items: GVPackageCategoryGrid.defaultItems,
                      selectedCode: state.selectedCategory.code,
                      onSelected: (code) {
                        final cat = categories.firstWhere(
                          (c) => c.code == code,
                          orElse: () => ParcelCategoryDto.other,
                        );
                        notifier.selectCategory(cat);
                      },
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // 2. Weight (approx.)
                    Text(
                      'Weight (approx.)',
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    GVWeightStepper(
                      weightKg: state.weightKg,
                      onChanged: (w) => notifier.setWeight(w),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // 3. Package Size (approx.) Dropdown
                    Text(
                      'Package size (approx.)',
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GVSpacing.md,
                        vertical: GVSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A221E)
                            : GVColors.white,
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2E3D35)
                              : GVColors.border,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.selectedSizeBand.code,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          dropdownColor: isDark
                              ? const Color(0xFF1A221E)
                              : GVColors.white,
                          items: sizeBands.map((band) {
                            return DropdownMenuItem<String>(
                              value: band.code,
                              child: Text(
                                band.label,
                                style: GVTypography.bodyMedium.copyWith(
                                  color: isDark
                                      ? GVColors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (code) {
                            if (code != null) {
                              final band = sizeBands.firstWhere(
                                (b) => b.code == code,
                                orElse: () => ParcelSizeBandDto.small,
                              );
                              notifier.selectSizeBand(band);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // 4. Special Handling (optional)
                    Text(
                      'Special handling (optional)',
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    GVSpecialHandlingToggles(
                      options: state.handlingOptions.map((opt) {
                        return GVHandlingOptionItem(
                          code: opt.code,
                          label: opt.label,
                          isEnabled: opt.isEnabled,
                        );
                      }).toList(),
                      onChanged: (code, isEnabled) {
                        notifier.toggleHandlingOption(code, isEnabled);
                      },
                    ),
                    const SizedBox(height: GVSpacing.xl),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA: Continue
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A16) : GVColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: GVPrimaryButton(
                label: 'Continue',
                onPressed: () {
                  if (GoRouter.maybeOf(context) != null) {
                    context.push(AppRoutes.parcelPickupLocation);
                  } else {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.parcelPickupLocation);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

