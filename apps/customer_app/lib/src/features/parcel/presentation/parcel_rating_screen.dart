import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 17 — Rate Your Experience:
/// Courier info card (Daniel Okafor, Yamaha Bike - ABC-123XY), interactive 5-star rating,
/// multi-select compliment tags ('Excellent', 'Good', 'On time', 'Handled with care',
/// 'Great communication', 'Others'), optional comment box with 200-char counter,
/// and Submit / Done CTAs returning to Home.
class ParcelRatingScreen extends ConsumerStatefulWidget {
  const ParcelRatingScreen({
    super.key,
    this.initialRating = 5,
  });

  final int initialRating;

  @override
  ConsumerState<ParcelRatingScreen> createState() => _ParcelRatingScreenState();
}

class _ParcelRatingScreenState extends ConsumerState<ParcelRatingScreen> {
  late int _rating;
  late final Set<String> _selectedCompliments;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _selectedCompliments = {};
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleDone() {
    if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.home);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  void _handleSubmit() {
    setState(() => _isSubmitting = true);

    final state = ref.read(parcelBookingNotifierProvider);
    final tracking = state.activeDelivery?.trackingNumber ?? '';
    final riderName = state.activeDelivery?.riderName ?? 'Courier';
    final riderVehicle =
        state.activeDelivery?.riderVehicle ?? 'Go-Volt Delivery';

    final ratingDto = ParcelRatingDto(
      trackingNumber: tracking,
      ratingStars: _rating,
      compliments: _selectedCompliments.toList(),
      comment: _commentController.text.trim().isNotEmpty
          ? _commentController.text.trim()
          : null,
      riderName: riderName,
      riderVehicle: riderVehicle,
      submittedAt: DateTime.now(),
    );

    ref.read(parcelBookingNotifierProvider.notifier).submitRating(ratingDto);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Your feedback helps us improve.'),
        backgroundColor: GVColors.brandGreen,
      ),
    );

    _handleDone();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parcelBookingNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final riderName = state.activeDelivery?.riderName ?? 'Courier';
    final riderVehicle =
        state.activeDelivery?.riderVehicle ?? 'Go-Volt Delivery';

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
          onPressed: _handleDone,
        ),
        title: Text(
          'Rate your experience',
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: GVSpacing.sm),

                    // Courier Preview Header Row
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: GVColors.brandGreen.withValues(alpha: 0.12),
                            border: Border.all(
                              color: GVColors.brandGreen,
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: GVColors.brandGreen,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: GVSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                riderName,
                                style: GVTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? GVColors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                riderVehicle,
                                style: GVTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? GVColors.neutral400
                                      : GVColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: GVSpacing.xxl),

                    // Interactive 5-Star Rating Bar
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          final isFilled = starValue <= _rating;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _rating = starValue);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: GVSpacing.xs,
                              ),
                              child: Icon(
                                isFilled
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 38,
                                color: isFilled
                                    ? const Color(0xFFFFB800)
                                    : (isDark
                                        ? const Color(0xFF3E4F44)
                                        : GVColors.neutral300),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: GVSpacing.xxl),

                    // Compliment Tags
                    Wrap(
                      spacing: GVSpacing.sm,
                      runSpacing: GVSpacing.sm,
                      children: ParcelRatingDto.availableCompliments.map((tag) {
                        final isSelected = _selectedCompliments.contains(tag);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedCompliments.remove(tag);
                              } else {
                                _selectedCompliments.add(tag);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: GVSpacing.md,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? GVColors.brandGreen.withValues(alpha: 0.12)
                                  : (isDark
                                      ? const Color(0xFF19221C)
                                      : GVColors.softBackground),
                              borderRadius: BorderRadius.circular(
                                GVBorderRadius.full,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? GVColors.brandGreen
                                    : (isDark
                                        ? const Color(0xFF2E3D35)
                                        : GVColors.border),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: GVTypography.bodySmall.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? (isDark
                                        ? GVColors.brandGreen
                                        : GVColors.deepGreen)
                                    : (isDark
                                        ? GVColors.neutral300
                                        : GVColors.textPrimary),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: GVSpacing.xxl),

                    // Comment Box Label
                    Text(
                      'Add a comment (optional)',
                      style: GVTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xs),

                    // Comment TextField
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF19221C)
                            : GVColors.softBackground,
                        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2E3D35)
                              : GVColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _commentController,
                            maxLines: 4,
                            maxLength: 200,
                            style: GVTypography.bodyMedium.copyWith(
                              color: isDark
                                  ? GVColors.white
                                  : GVColors.textPrimary,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Tell us more about your experience...',
                              hintStyle: GVTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? GVColors.neutral500
                                    : GVColors.textSecondary,
                              ),
                              contentPadding: const EdgeInsets.all(GVSpacing.md),
                              border: InputBorder.none,
                              counterText: '', // Hide default counter
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: GVSpacing.md,
                              bottom: GVSpacing.sm,
                            ),
                            child: Text(
                              '${_commentController.text.length}/200',
                              style: GVTypography.bodySmall.copyWith(
                                color: isDark
                                    ? GVColors.neutral500
                                    : GVColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: GVSpacing.xxl),
                  ],
                ),
              ),
            ),

            // Bottom Buttons (Submit & Done)
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GVPrimaryButton(
                    label: 'Submit',
                    isLoading: _isSubmitting,
                    onPressed: _handleSubmit,
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  TextButton(
                    onPressed: _handleDone,
                    child: Text(
                      'Done',
                      style: GVTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                      ),
                    ),
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
