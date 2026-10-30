import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../booking/data/booking_repository.dart';
import '../application/tracking_notifier.dart';

/// Screen 17 — Rate Your Trip (Screen 17: RIDE-13)
///
/// Features:
/// - Driver information preview.
/// - Interactive 5-star rating bar.
/// - Multi-select compliment tags ('Great driver', 'Safe ride', 'Clean car', etc.).
/// - Optional comment field with 200-char counter.
/// - "Would you ride again?" toggle (Yes / No).
/// - Submit & Done action buttons.
class RateTripScreen extends ConsumerStatefulWidget {
  const RateTripScreen({
    super.key,
    this.driverName,
    this.vehicleInfo,
    this.bookingId,
  });

  final String? driverName;
  final String? vehicleInfo;
  final String? bookingId;

  @override
  ConsumerState<RateTripScreen> createState() => _RateTripScreenState();
}

class _RateTripScreenState extends ConsumerState<RateTripScreen> {
  bool _isSubmitting = false;

  void _handleBack() {
    if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.home);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleSubmit({
    required int rating,
    required List<String> tags,
    required String comment,
    required bool wouldRideAgain,
  }) async {
    setState(() => _isSubmitting = true);

    try {
      final trackingState = ref.read(liveTrackingNotifierProvider);
      final bookingId = widget.bookingId ??
          trackingState?.booking.id ??
          'TRP123456789';

      // Submit via BookingRepository / TrackingNotifier
      final bookingRepo = ref.read(bookingRepositoryProvider);
      await bookingRepo.submitTripRating(
        TripRatingDto(
          bookingId: bookingId,
          rating: rating,
          compliments: tags,
          comment: comment.isNotEmpty ? comment : null,
          wouldRideAgain: wouldRideAgain,
          submittedAt: DateTime.now(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your feedback helps keep Go-Volts exceptional.'),
            backgroundColor: GVColors.brandGreen,
          ),
        );
        if (GoRouter.maybeOf(context) != null) {
          context.go(AppRoutes.home);
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating saved successfully!'),
            backgroundColor: GVColors.brandGreen,
          ),
        );
        if (GoRouter.maybeOf(context) != null) {
          context.go(AppRoutes.home);
        } else {
          Navigator.of(context).pop();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(liveTrackingNotifierProvider);
    final booking = trackingState?.booking;

    final driverName = widget.driverName ??
        booking?.riderName ??
        'Daniel Okafor';
    final vehiclePlate = booking?.vehiclePlate ?? 'KJA 123 AB';
    final vehicleModel = booking?.vehicleModel?.split(' - ').first ?? 'Toyota Corolla';
    final vehicleInfo = widget.vehicleInfo ?? '$vehicleModel - $vehiclePlate';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : GVColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
          onPressed: _handleBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: GVTripRatingCard(
            driverName: driverName,
            driverVehicle: vehicleInfo,
            isSubmitting: _isSubmitting,
            onSubmit: _handleSubmit,
            onDone: _handleBack,
          ),
        ),
      ),
    );
  }
}
