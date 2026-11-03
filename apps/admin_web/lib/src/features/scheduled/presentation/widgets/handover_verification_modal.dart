import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/admin_auth_notifier.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/scheduled_operations_notifier.dart';
import '../../domain/scheduled_operations_models.dart';

class HandoverVerificationModal extends ConsumerStatefulWidget {
  const HandoverVerificationModal({
    super.key,
    required this.safekeeping,
  });

  final GuardianSafekeepingModel safekeeping;

  @override
  ConsumerState<HandoverVerificationModal> createState() =>
      _HandoverVerificationModalState();
}

class _HandoverVerificationModalState
    extends ConsumerState<HandoverVerificationModal> {
  final _otpController = TextEditingController();
  final _bypassReasonController = TextEditingController();
  bool _showBypass = false;

  @override
  void dispose() {
    _otpController.dispose();
    _bypassReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthNotifierProvider);
    final notifier = ref.read(scheduledOperationsNotifierProvider.notifier);
    final student = widget.safekeeping;

    return AdminModalDialog(
      title: 'School-Run Safekeeping & Handover — ${student.passengerName}',
      maxWidth: 760,
      cancelLabel: 'Close',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Student Profile Card
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF14241B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF263C2E)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF1B3A27),
                  child: Text(
                    student.passengerName[0],
                    style: const TextStyle(
                      color: GVColors.brandGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            student.passengerName,
                            style: GVTypography.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF263C2E),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Age ${student.age}',
                              style: GVTypography.caption.copyWith(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student.schoolName,
                        style: GVTypography.bodySmall.copyWith(
                          color: GVColors.brandGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildOtpStatusBadge(student.isVerified),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Care Notes & Route Info
          if (student.specialCareNotes != null) ...[
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              margin: const EdgeInsets.only(bottom: GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2312),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_services_outlined, color: Colors.amber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Special Care Protocol: "${student.specialCareNotes}"',
                      style: GVTypography.bodySmall.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Authorized Guardian Contacts Checklist
          Text(
            'AUTHORIZED GUARDIANS & EMERGENCY CONTACTS',
            style: GVTypography.caption.copyWith(
              color: GVColors.brandGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(GVSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFF161F1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF263C2E)),
            ),
            child: Column(
              children: student.authorizedContacts.map((contact) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user, size: 16, color: GVColors.brandGreen),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${contact.name} (${contact.relationship})',
                          style: GVTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        contact.phone,
                        style: GVTypography.caption.copyWith(color: Colors.white70),
                      ),
                      if (contact.isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF143021),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Primary',
                            style: GVTypography.caption.copyWith(
                              color: GVColors.brandGreen,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // OTP Verification Section
          if (!student.isVerified) ...[
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF161F1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF263C2E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SINGLE-USE HANDOVER OTP AUTHENTICATION',
                    style: GVTypography.caption.copyWith(
                      color: GVColors.brandGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter the 6-digit code presented by the receiving school marshal or authorized parent:',
                    style: GVTypography.bodySmall.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: TextField(
                          key: const Key('handover_otp_input'),
                          controller: _otpController,
                          maxLength: 6,
                          style: const TextStyle(
                            color: Colors.white,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'e.g. 482910',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: const Color(0xFF14241B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF263C2E)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        key: const Key('verify_otp_btn'),
                        onPressed: () async {
                          final entered = _otpController.text.trim();
                          if (entered.isEmpty) return;
                          final success = await notifier.verifyHandoverOtp(
                            student.passengerId,
                            entered,
                            officerName: authState.fullName,
                          );
                          if (success && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Verify Handover OTP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GVColors.brandGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Emergency Bypass Accordion
                  if (!_showBypass) ...[
                    TextButton.icon(
                      onPressed: () => setState(() => _showBypass = true),
                      icon: const Icon(Icons.emergency_outlined, size: 16, color: Colors.amber),
                      label: const Text(
                        'Emergency Handover Override (No phone / network unavailable)',
                        style: TextStyle(color: Colors.amber, fontSize: 12),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.sm),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B1D0E),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mandatory Emergency Audit Justification',
                            style: GVTypography.caption.copyWith(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            key: const Key('emergency_bypass_input'),
                            controller: _bypassReasonController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter reason (e.g. Verified parent in person with NIN/ID card)...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: const Color(0xFF14241B),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color(0xFF263C2E)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            key: const Key('submit_emergency_bypass_btn'),
                            onPressed: () async {
                              final reason = _bypassReasonController.text.trim();
                              if (reason.isEmpty) return;
                              await notifier.emergencyBypassOtp(
                                student.passengerId,
                                officerName: authState.fullName,
                                reason: reason,
                              );
                              if (context.mounted) Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.warning, size: 16),
                            label: const Text('Confirm Emergency Handover Bypass'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF14241B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GVColors.brandGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: GVColors.brandGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HANDOVER AUTHENTICATED & VERIFIED',
                          style: GVTypography.bodySmall.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Verified at: ${student.verifiedAt?.toLocal().toString().split('.').first ?? 'Today'} by ${student.verifiedByStaffOrDriver ?? 'Officer'}',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtpStatusBadge(bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isVerified
            ? const Color(0xFF143021)
            : const Color(0xFF2B1D0E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isVerified ? GVColors.brandGreen : Colors.amber,
        ),
      ),
      child: Text(
        isVerified ? 'VERIFIED' : 'OTP PENDING',
        style: TextStyle(
          color: isVerified ? GVColors.brandGreen : Colors.amber,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
