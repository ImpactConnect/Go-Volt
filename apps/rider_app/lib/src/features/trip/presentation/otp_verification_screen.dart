import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/active_trip_notifier.dart';

/// Screen RD15: Handover OTP Verification (Passenger Ride, School-Run & High-Value Cargo).
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.job,
  });

  final DispatchOfferDto job;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) return;

    final notifier =
        ref.read(activeTripNotifierProvider(widget.job).notifier);
    final success = await notifier.verifyOtp(otp);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: GVColors.deepGreen,
          content: Text('Handover OTP verified successfully! You may now begin transit.'),
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeTripNotifierProvider(widget.job));
    final isSchoolRun = widget.job.serviceType == ServiceTierEligibility.schoolRunCommute;
    final otpLength = isSchoolRun ? 6 : 4;

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Verify Handover OTP'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: GVSpacing.md),
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: GVColors.deepGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: GVColors.brandGreen, width: 2),
                            boxShadow: GVShadows.glow,
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: GVColors.brandGreen,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: GVSpacing.md),
                      Text(
                        isSchoolRun
                            ? 'Guardian Handover OTP'
                            : 'Enter Customer Verification PIN',
                        textAlign: TextAlign.center,
                        style: GVTypography.h2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: GVSpacing.xs),
                      Text(
                        isSchoolRun
                            ? 'Ask the authorised parent/guardian to provide their 6-digit single-use OTP. Never bypass handover verification.'
                            : 'Ask the passenger or sender for their $otpLength-digit trip start code.',
                        textAlign: TextAlign.center,
                        style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: GVSpacing.lg),

                      // Child or Customer Info Card
                      Container(
                        padding: const EdgeInsets.all(GVSpacing.md),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C2420),
                          borderRadius: BorderRadius.circular(GVBorderRadius.md),
                          border: Border.all(color: const Color(0xFF2A3630)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSchoolRun ? Icons.school : Icons.person,
                              color: GVColors.brandGreen,
                              size: 28,
                            ),
                            const SizedBox(width: GVSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSchoolRun
                                        ? 'Student: ${widget.job.childName ?? "Child"}'
                                        : 'Customer: ${widget.job.customerName}',
                                    style: GVTypography.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    isSchoolRun
                                        ? 'School: ${widget.job.schoolName ?? "School"}'
                                        : 'Pickup: ${widget.job.pickupAddress}',
                                    style: GVTypography.caption.copyWith(color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: GVSpacing.xl),

                      // OTP Input Field
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: otpLength,
                        textAlign: TextAlign.center,
                        style: GVTypography.h1.copyWith(
                          color: Colors.white,
                          letterSpacing: 12,
                        ),
                        decoration: InputDecoration(
                          hintText: '• ' * otpLength,
                          hintStyle: const TextStyle(letterSpacing: 12, color: Colors.white24),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: GVSpacing.md),

                      // Attempts & Error Banner
                      if (state.otpError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(GVSpacing.sm),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D1C1C),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.otpError!,
                                  style: GVTypography.caption.copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: GVSpacing.md),
                      ],

                      Text(
                        'Demo PIN: 1234 (Commute) or 123456 (School-Run)',
                        textAlign: TextAlign.center,
                        style: GVTypography.caption.copyWith(color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              ),

              // Verify CTA
              GVPrimaryButton(
                label: state.isLoading ? 'Verifying PIN...' : 'Verify & Confirm Handover',
                onPressed: state.isLoading ? null : _handleVerify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
