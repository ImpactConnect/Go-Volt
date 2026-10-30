import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DocumentItem {
  const DocumentItem({
    required this.title,
    required this.expiry,
    required this.isVerified,
    required this.icon,
  });

  final String title;
  final String expiry;
  final bool isVerified;
  final IconData icon;
}

/// Screen RD26: Driver Compliance Documents Management (Board 5 Screen 2).
class DriverDocumentsScreen extends ConsumerWidget {
  const DriverDocumentsScreen({super.key});

  final List<DocumentItem> _docs = const [
    DocumentItem(
      title: "Driver's License",
      expiry: 'Expires: 12 Dec 2027',
      isVerified: true,
      icon: Icons.badge_outlined,
    ),
    DocumentItem(
      title: 'Vehicle Registration',
      expiry: 'Expires: 05 Mar 2027',
      isVerified: true,
      icon: Icons.description_outlined,
    ),
    DocumentItem(
      title: 'Vehicle Insurance',
      expiry: 'Expires: 22 Jan 2027',
      isVerified: true,
      icon: Icons.security_outlined,
    ),
    DocumentItem(
      title: 'Road Worthiness',
      expiry: 'Expires: 10 Nov 2026',
      isVerified: false,
      icon: Icons.fact_check_outlined,
    ),
    DocumentItem(
      title: 'Profile Photo',
      expiry: 'Uploaded: 12 Oct 2026',
      isVerified: true,
      icon: Icons.person_outline,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Documents',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Notice Banner
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF132A1C),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: GVColors.brandGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: GVColors.brandGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Keep your documents up to date. All documents must be valid to keep your account active.',
                        style: GVTypography.caption.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Required Documents List
              Text(
                'Required Documents',
                style: GVTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.sm),
              for (final doc in _docs) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: GVSpacing.sm),
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
                          color: doc.isVerified
                              ? GVColors.deepGreen.withValues(alpha: 0.4)
                              : Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          doc.icon,
                          color: doc.isVerified ? GVColors.brandGreen : Colors.amber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: GVSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.title,
                              style: GVTypography.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              doc.expiry,
                              style: GVTypography.caption.copyWith(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                      GVStatusChip(
                        label: doc.isVerified ? 'Verified' : 'Pending',
                        status: doc.isVerified ? GVStatusType.active : GVStatusType.pending,
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: GVSpacing.xl),

              // Upload New Document Button
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select JPG, PNG or PDF to upload')),
                  );
                },
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                child: Container(
                  padding: const EdgeInsets.all(GVSpacing.lg),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141917),
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    border: Border.all(
                      color: GVColors.brandGreen,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        color: GVColors.brandGreen,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload New Document',
                        style: GVTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'JPG, PNG or PDF (Max 5MB)',
                        style: GVTypography.caption.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
