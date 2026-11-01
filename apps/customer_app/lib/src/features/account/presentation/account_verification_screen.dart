import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_notifier.dart';
import '../application/profile_notifier.dart';

/// Screen A4: Account Identity Verification & Document Submission (§A4).
class AccountVerificationScreen extends ConsumerStatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  ConsumerState<AccountVerificationScreen> createState() => _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends ConsumerState<AccountVerificationScreen> {
  final Map<String, String> _uploadedDocs = {};
  bool _isUploading = false;

  void _handleUpload(String docName) async {
    setState(() => _isUploading = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    setState(() {
      _uploadedDocs[docName] = 'https://storage.govolts.ng/docs/verified_${docName.toLowerCase().replaceAll(' ', '_')}.jpg';
      _isUploading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$docName uploaded successfully.'),
          backgroundColor: GVColors.deepGreen,
        ),
      );
    }
  }

  void _submitForReview() async {
    final user = ref.read(profileNotifierProvider).profile ?? ref.read(authNotifierProvider).profile;
    final success = await ref.read(profileNotifierProvider.notifier).submitVerification(
          userId: user?.id,
          documentUrls: _uploadedDocs,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Verification documents submitted for review.' : 'Submission failed. Please try again.'),
          backgroundColor: success ? GVColors.deepGreen : GVColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final verification = profileState.verification;
    final status = verification.status;

    Color bannerBg;
    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusDescription;

    switch (status) {
      case VerificationStatus.verified:
        bannerBg = const Color(0xFFE8F5E9);
        statusColor = const Color(0xFF2E7D32);
        statusIcon = Icons.check_circle_rounded;
        statusTitle = 'Identity Verified';
        statusDescription = 'Your account has been fully vetted with valid identity credentials. You have full access to zero-emission rides, parcel logistics, and School-Run custody handover.';
        break;
      case VerificationStatus.pending:
        bannerBg = const Color(0xFFFFF8E1);
        statusColor = const Color(0xFFF57F17);
        statusIcon = Icons.access_time_rounded;
        statusTitle = 'Verification Under Review';
        statusDescription = 'Your identity documents have been submitted to the Go-Volts Compliance Team. Verification is typically completed within 2 to 4 hours.';
        break;
      case VerificationStatus.actionRequired:
      case VerificationStatus.rejected:
        bannerBg = const Color(0xFFFFEBEE);
        statusColor = const Color(0xFFC62828);
        statusIcon = Icons.error_outline_rounded;
        statusTitle = 'Action Required';
        statusDescription = verification.rejectionReason ?? 'Please re-upload a clear, unexpired government ID and proof of Lagos residence.';
        break;
      case VerificationStatus.notRequired:
        bannerBg = const Color(0xFFE3F2FD);
        statusColor = const Color(0xFF1565C0);
        statusIcon = Icons.info_outline_rounded;
        statusTitle = 'Basic Account (Tier 1)';
        statusDescription = 'You can complete standard rides and parcel deliveries. Verify your identity to unlock School-Run custody handover and higher wallet daily limits.';
        break;
    }

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'Account Verification'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: bannerBg,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(statusIcon, color: statusColor, size: 28),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusTitle,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusDescription,
                          style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Tier & Benefit Details
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account Tier & Privileges', style: GVTypography.h3),
                  const SizedBox(height: GVSpacing.sm),
                  _buildBenefitRow(
                    icon: Icons.electric_bike,
                    title: 'Zero-Emission Rides & Parcel Delivery',
                    isUnlocked: true,
                  ),
                  const SizedBox(height: 10),
                  _buildBenefitRow(
                    icon: Icons.shield,
                    title: 'School-Run Commute Child Custody Authorization',
                    isUnlocked: status == VerificationStatus.verified,
                  ),
                  const SizedBox(height: 10),
                  _buildBenefitRow(
                    icon: Icons.account_balance_wallet,
                    title: '₦500,000 Wallet Balance & High-Volume Merchant Errands',
                    isUnlocked: status == VerificationStatus.verified,
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Required Documents Checklist & Upload
            if (status != VerificationStatus.verified) ...[
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  boxShadow: GVShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Required Documents', style: GVTypography.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Upload high-resolution copies of your valid identity credentials.',
                      style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
                    ),
                    const SizedBox(height: GVSpacing.md),
                    ...verification.requiredDocuments.map((doc) {
                      final isUploaded = _uploadedDocs.containsKey(doc);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: GVColors.softBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isUploaded ? Icons.check_circle : Icons.upload_file,
                                color: isUploaded ? GVColors.brandGreen : GVColors.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  doc,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isUploaded ? Colors.grey.shade200 : GVColors.deepGreen,
                                  foregroundColor: isUploaded ? Colors.black87 : Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                ),
                                onPressed: _isUploading ? null : () => _handleUpload(doc),
                                child: Text(isUploaded ? 'Re-upload' : 'Upload', style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),
              GVPrimaryButton(
                label: profileState.isSaving ? 'Submitting Documents...' : 'Submit for Verification',
                onPressed: (profileState.isSaving || _uploadedDocs.isEmpty) ? null : _submitForReview,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required String title,
    required bool isUnlocked,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isUnlocked ? GVColors.brandGreen : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isUnlocked ? Colors.black87 : Colors.black45,
              fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Icon(
          isUnlocked ? Icons.check : Icons.lock_outline,
          color: isUnlocked ? GVColors.brandGreen : Colors.grey,
          size: 16,
        ),
      ],
    );
  }
}

