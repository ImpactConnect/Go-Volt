import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_trips_notifier.dart';

/// Screen 33 (SP-35): Handover Verification Screen
/// Gated safety screen requiring the driver/parent to enter the 4-digit PIN given by the authorised school receiver.
class HandoverVerificationScreen extends ConsumerStatefulWidget {
  const HandoverVerificationScreen({super.key});

  @override
  ConsumerState<HandoverVerificationScreen> createState() =>
      _HandoverVerificationScreenState();
}

class _HandoverVerificationScreenState
    extends ConsumerState<HandoverVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredPin => _controllers.map((c) => c.text).join();

  Future<void> _handleConfirm() async {
    final pin = _enteredPin;
    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 4 digits of the verification code.'),
        ),
      );
      return;
    }

    final state = ref.read(scheduledTripsNotifierProvider);
    final notifier = ref.read(scheduledTripsNotifierProvider.notifier);
    final trip =
        state.selectedTrip ??
        (state.upcomingTrips.isNotEmpty ? state.upcomingTrips.first : null);

    if (trip == null) return;

    final success = await notifier.verifyHandover(
      tripId: trip.id,
      pin: pin,
      recipientName: 'Mrs. Aisha Muhammadu',
      recipientRole: 'School Teacher',
    );

    if (!mounted) return;

    if (success) {
      context.push(AppRoutes.scheduledHandoverConfirmed);
    } else {
      final msg =
          ref.read(scheduledTripsNotifierProvider).errorMessage ??
          'Invalid verification code. Please check with recipient.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduledTripsNotifierProvider);
    final trip =
        state.selectedTrip ??
        (state.upcomingTrips.isNotEmpty ? state.upcomingTrips.first : null);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.neutral50;
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: GVSpacing.lg),

              // Green shield badge
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: GVColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.security_rounded,
                    color: GVColors.primary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              Text(
                'Handover verification',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the verification code from the authorised contact at the destination.',
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: GVSpacing.xxl),

              // 4 PIN Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 58,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(GVBorderRadius.card),
                      border: Border.all(
                        color: _controllers[index].text.isNotEmpty
                            ? GVColors.primary
                            : borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: GVTypography.h1.copyWith(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: GVSpacing.xxl),

              // Child profile card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.card),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFFDE047),
                      child: const Icon(
                        Icons.child_care_rounded,
                        color: Color(0xFF854D0E),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (trip?.passengerName.isNotEmpty ?? false)
                                ? trip!.passengerName
                                : 'Child Passenger',
                            style: GVTypography.bodyLarge.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trip?.destinationLocation.label?.isNotEmpty == true
                                ? trip!.destinationLocation.label!
                                : (trip?.destinationLocation.address ?? 'School Destination'),
                            style: GVTypography.caption.copyWith(
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Confirm handover button
              GVButton(
                text: 'Confirm handover',
                type: GVButtonType.primary,
                isLoading: state.isLoading,
                onPressed: _handleConfirm,
              ),
              const SizedBox(height: GVSpacing.sm),

              TextButton(
                onPressed: () {
                  context.push(AppRoutes.scheduledReportIssue);
                },
                child: Text(
                  "Can't verify? Contact support",
                  style: GVTypography.bodyMedium.copyWith(
                    color: GVColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
