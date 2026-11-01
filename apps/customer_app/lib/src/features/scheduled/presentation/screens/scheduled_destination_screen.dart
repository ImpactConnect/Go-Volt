import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../booking/presentation/map_picker_screen.dart';
import '../../../home/application/home_notifier.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 5 (SP-05): Scheduled Destination Screen
/// Configures destination address, shortcuts, and interactive red map pin.
class ScheduledDestinationScreen extends ConsumerStatefulWidget {
  const ScheduledDestinationScreen({super.key});

  @override
  ConsumerState<ScheduledDestinationScreen> createState() =>
      _ScheduledDestinationScreenState();
}

class _ScheduledDestinationScreenState
    extends ConsumerState<ScheduledDestinationScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final dest = ref.read(scheduledBookingNotifierProvider).destinationLocation;
    _searchController = TextEditingController(text: dest.address);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<LocationDto>(
      MaterialPageRoute(
        builder: (context) => const MapPickerScreen(isPickup: false),
      ),
    );

    if (result != null && mounted) {
      ref.read(scheduledBookingNotifierProvider.notifier).setDestinationLocation(result);
      _searchController.text = result.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduledBookingNotifierProvider);
    final notifier = ref.read(scheduledBookingNotifierProvider.notifier);
    final homeState = ref.watch(homeNotifierProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Destination',
                    style: GVTypography.h1.copyWith(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),

                  // Search Field
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
                        hintText: 'Search or enter address',
                        hintStyle: GVTypography.bodyMedium.copyWith(
                          color: subtextColor,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: GVColors.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (val) {
                        notifier.setDestinationLocation(
                          state.destinationLocation.copyWith(address: val),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: GVSpacing.md),

                  // Shortcut 1: Select on map
                  _buildLocationShortcut(
                    icon: Icons.location_on_outlined,
                    title: 'Select on map',
                    subtitle: 'Pinpoint exact location on map',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: _openMapPicker,
                  ),
                  const Divider(height: 1),

                  // Dynamic Saved Places from DB
                  if (homeState.savedPlaces.isNotEmpty) ...[
                    for (final saved in homeState.savedPlaces) ...[
                      _buildLocationShortcut(
                        icon: saved.isSchool
                            ? Icons.school_rounded
                            : (saved.isWork
                                ? Icons.business_center_rounded
                                : (saved.isHome
                                    ? Icons.home_rounded
                                    : Icons.place_rounded)),
                        title: saved.label,
                        subtitle: saved.address,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        onTap: () {
                          final loc = LocationDto(
                            latitude: saved.latitude,
                            longitude: saved.longitude,
                            address: saved.address,
                            label: saved.label,
                            city: 'Shaganu',
                            state: 'Ogun',
                          );
                          _searchController.text = loc.address;
                          notifier.setDestinationLocation(loc);
                        },
                      ),
                      const Divider(height: 1),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: GVSpacing.sm),

            // Map preview with red destination pin
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    color: isDark
                        ? const Color(0xFF1E2822)
                        : const Color(0xFFE5EDE8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black87 : Colors.white,
                              borderRadius: BorderRadius.circular(
                                GVBorderRadius.full,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              (state.destinationLocation.label?.isNotEmpty ?? false)
                                  ? state.destinationLocation.label!
                                  : 'Destination',
                              style: GVTypography.labelSmall.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.small(
                      backgroundColor: isDark ? cardBg : Colors.white,
                      onPressed: () {},
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CTA: Continue
            Padding(
              padding: const EdgeInsets.all(GVSpacing.lg),
              child: GVButton(
                text: 'Continue',
                onPressed: () {
                  if (state.isRecurring) {
                    context.push(AppRoutes.scheduledCalendar);
                  } else {
                    context.push(AppRoutes.scheduledTripDetails);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationShortcut({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor, size: 20),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GVTypography.labelMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
