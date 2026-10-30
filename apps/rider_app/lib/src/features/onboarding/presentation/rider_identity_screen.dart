import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/onboarding_notifier.dart';

/// Screen RD03: Driver Identity Verification (Board 1 Screen 3).
class RiderIdentityScreen extends ConsumerWidget {
  const RiderIdentityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    final hasNin = state.documents.any((d) => d.type == DocumentType.nationalId);
    final hasLicense = state.documents.any((d) => d.type == DocumentType.driversLicense);
    final hasLasrra = state.documents.any((d) => d.type == DocumentType.lasrra);

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: GVSpacing.sm),
              Text(
                'Identity Verification',
                style: GVTypography.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Verify your identity to keep Go-Volts safe and trustworthy.',
                style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Checklist Items
              _buildDocTile(
                icon: Icons.badge_outlined,
                title: 'National ID',
                subtitle: 'Upload a valid National ID card',
                isCompleted: hasNin,
                onTap: () {
                  notifier.addDocument(
                    RiderDocumentDto(
                      id: 'doc_nin',
                      type: DocumentType.nationalId,
                      documentNumber: 'NIN-12345678901',
                      fileUrl: 'mock://nin_card_chinedu.jpg',
                      expiryDate: DateTime.now().add(const Duration(days: 1000)),
                      status: DocumentVerificationStatus.approved,
                    ),
                  );
                },
              ),
              const SizedBox(height: GVSpacing.sm),
              _buildDocTile(
                icon: Icons.face_outlined,
                title: 'Selfie',
                subtitle: 'Take a clear selfie',
                isCompleted: hasLicense,
                onTap: () {
                  notifier.addDocument(
                    RiderDocumentDto(
                      id: 'doc_selfie',
                      type: DocumentType.driversLicense,
                      documentNumber: 'DL-98214-LAG',
                      fileUrl: 'mock://selfie_chinedu.jpg',
                      expiryDate: DateTime.now().add(const Duration(days: 800)),
                      status: DocumentVerificationStatus.approved,
                    ),
                  );
                },
              ),
              const SizedBox(height: GVSpacing.sm),
              _buildDocTile(
                icon: Icons.receipt_long_outlined,
                title: 'Proof of Address',
                subtitle: 'Utility bill or LASRRA document',
                isCompleted: hasLasrra,
                onTap: () {
                  notifier.addDocument(
                    RiderDocumentDto(
                      id: 'doc_lasrra',
                      type: DocumentType.lasrra,
                      documentNumber: 'LASRRA-776214',
                      fileUrl: 'mock://utility_bill.jpg',
                      expiryDate: DateTime.now().add(const Duration(days: 400)),
                      status: DocumentVerificationStatus.pending,
                    ),
                  );
                },
              ),
              const SizedBox(height: GVSpacing.xl),

              // Photo Preview Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildPhotoPreview(
                      label: 'National ID',
                      icon: Icons.credit_card,
                      hasImage: true,
                      onEdit: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Re-upload National ID card photo')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: _buildPhotoPreview(
                      label: 'Selfie',
                      icon: Icons.person,
                      hasImage: true,
                      onEdit: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Retake selfie photo')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.xxl),

              // Primary Continue Button
              GVPrimaryButton(
                label: 'Continue',
                onPressed: () => context.push('/onboarding/vehicle'),
              ),
              const SizedBox(height: GVSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2420),
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(color: const Color(0xFF2A3630)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GVColors.deepGreen.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: GVColors.brandGreen, size: 22),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GVTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GVTypography.caption.copyWith(color: Colors.white60),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Icon(Icons.check_circle, color: GVColors.brandGreen, size: 22)
            else
              const Icon(Icons.chevron_right, color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview({
    required String label,
    required IconData icon,
    required bool hasImage,
    required VoidCallback onEdit,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF141917),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: GVColors.brandGreen.withValues(alpha: 0.5)),
                gradient: LinearGradient(
                  colors: [
                    GVColors.deepGreen.withValues(alpha: 0.4),
                    const Color(0xFF141917),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: GVColors.brandGreen, size: 40),
                    const SizedBox(height: 4),
                    Text(
                      'Verified Photo',
                      style: GVTypography.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 6,
              right: 6,
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1C2420),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: GVColors.brandGreen,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GVTypography.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
