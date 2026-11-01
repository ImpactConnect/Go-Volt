import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../data/scheduled_repository.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 9 (SP-10): Preferred Driver Screen (Optional)
/// Allows requesting a specific preferred driver or opting for best automatic assignment.
class PreferredDriverScreen extends ConsumerStatefulWidget {
  const PreferredDriverScreen({super.key});

  @override
  ConsumerState<PreferredDriverScreen> createState() =>
      _PreferredDriverScreenState();
}

class _PreferredDriverScreenState
    extends ConsumerState<PreferredDriverScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduledBookingNotifierProvider);
    final notifier = ref.read(scheduledBookingNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final drivers = ScheduledRepository.availableDrivers.where((d) {
      if (_searchQuery.isEmpty) return true;
      return d.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Preferred Driver (optional)',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Select a preferred driver if you have one. We\'ll try our best to assign them when available.',
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GVTypography.bodyMedium.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search drivers by name',
                    hintStyle:
                        GVTypography.bodyMedium.copyWith(color: subtextColor),
                    prefixIcon: Icon(Icons.search_rounded, color: subtextColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              Expanded(
                child: ListView(
                  children: [
                    ...drivers.map((driver) {
                      final isSelected =
                          state.preferredDriver?.id == driver.id;
                      return _buildDriverCard(
                        driver: driver,
                        isSelected: isSelected,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        onTap: () => notifier.setPreferredDriver(driver),
                      );
                    }),

                    const SizedBox(height: GVSpacing.xs),

                    // Option: No preferred driver
                    _buildNoDriverCard(
                      isSelected: state.preferredDriver == null,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      onTap: () => notifier.setPreferredDriver(null),
                    ),
                  ],
                ),
              ),

              // CTA: Continue
              GVButton(
                text: 'Continue',
                onPressed: () {
                  context.push(AppRoutes.scheduledPackagePricing);
                },
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverCard({
    required RiderDto driver,
    required bool isSelected,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GVSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        child: Container(
          padding: const EdgeInsets.all(GVSpacing.md),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(GVBorderRadius.md),
            border: Border.all(
              color: isSelected ? GVColors.primary : borderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  driver.avatarUrl ??
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: GVTypography.labelMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: Color(0xFFFFB800)),
                        const SizedBox(width: 4),
                        Text(
                          driver.rating.toStringAsFixed(1),
                          style: GVTypography.bodySmall.copyWith(
                            color: subtextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? GVColors.primary : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDriverCard({
    required bool isSelected,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(
            color: isSelected ? GVColors.primary : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? GVColors.primary.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: isSelected ? GVColors.primary : subtextColor,
                size: 20,
              ),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No preferred driver',
                    style: GVTypography.labelMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Assign the best available driver',
                    style: GVTypography.bodySmall.copyWith(
                      color: subtextColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? GVColors.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
