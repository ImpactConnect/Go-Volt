import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../application/onboarding_notifier.dart';

/// Screen RD04: Regulatory & Compliance Document Uploads.
class RiderDocumentsScreen extends ConsumerStatefulWidget {
  const RiderDocumentsScreen({super.key});

  @override
  ConsumerState<RiderDocumentsScreen> createState() =>
      _RiderDocumentsScreenState();
}

class _RiderDocumentsScreenState extends ConsumerState<RiderDocumentsScreen> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    // Pre-populate initial required documents if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingNotifierProvider);
      if (state.documents.isEmpty) {
        final notifier = ref.read(onboardingNotifierProvider.notifier);
        notifier.addDocument(
          RiderDocumentDto(
            id: 'DOC-NIN-01',
            type: DocumentType.nationalId,
            documentNumber: '10928374651',
            fileUrl: 'https://cdn.govolts.ng/docs/nin_card.jpg',
            expiryDate: DateTime.now().add(const Duration(days: 1400)),
            status: DocumentVerificationStatus.approved,
          ),
        );
        notifier.addDocument(
          RiderDocumentDto(
            id: 'DOC-DL-02',
            type: DocumentType.driversLicense,
            documentNumber: 'DL-LAG-2024-883',
            fileUrl: 'https://cdn.govolts.ng/docs/license_card.jpg',
            expiryDate: DateTime.now().add(const Duration(days: 520)),
            status: DocumentVerificationStatus.approved,
          ),
        );
        notifier.addDocument(
          RiderDocumentDto(
            id: 'DOC-VR-03',
            type: DocumentType.vehicleRegistration,
            documentNumber: 'VR-LAG-2901-EV',
            fileUrl: 'https://cdn.govolts.ng/docs/vehicle_ownership.jpg',
            expiryDate: DateTime.now().add(const Duration(days: 365)),
            status: DocumentVerificationStatus.pending,
          ),
        );
      }
    });
  }

  void _showUploadDialog(DocumentType type) {
    final docNumberCtrl = TextEditingController();
    DateTime selectedExpiry = DateTime.now().add(const Duration(days: 365));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C2420),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: GVSpacing.md,
                right: GVSpacing.md,
                top: GVSpacing.md,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + GVSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Upload ${type.title}',
                          style: GVTypography.h3.copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  Text(
                    'Ensure all numbers, stamps, and signatures are crisp and clearly legible.',
                    style: GVTypography.caption.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  TextField(
                    controller: docNumberCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: '${type.title} Document Number',
                      prefixIcon: const Icon(
                        Icons.numbers,
                        color: GVColors.brandGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Document Expiry Date',
                      style: GVTypography.bodyMedium.copyWith(color: Colors.white),
                    ),
                    subtitle: Text(
                      _dateFormat.format(selectedExpiry),
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.calendar_month,
                      color: GVColors.brandGreen,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedExpiry,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 10),
                        ),
                      );
                      if (picked != null) {
                        setModalState(() => selectedExpiry = picked);
                      }
                    },
                  ),
                  const SizedBox(height: GVSpacing.md),
                  GVPrimaryButton(
                    label: 'Attach & Save Document',
                    onPressed: () {
                      final docNumber = docNumberCtrl.text.trim().isNotEmpty
                          ? docNumberCtrl.text.trim()
                          : 'DOC-${DateTime.now().millisecondsSinceEpoch}';
                      ref
                          .read(onboardingNotifierProvider.notifier)
                          .addDocument(
                            RiderDocumentDto(
                              id: 'DOC-${DateTime.now().millisecondsSinceEpoch}',
                              type: type,
                              documentNumber: docNumber,
                              fileUrl:
                                  'https://cdn.govolts.ng/docs/${type.code.toLowerCase()}.jpg',
                              expiryDate: selectedExpiry,
                              status: DocumentVerificationStatus.pending,
                            ),
                          );
                      Navigator.pop(modalCtx);
                    },
                  ),
                  const SizedBox(height: GVSpacing.xs),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Application'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
      ),
      backgroundColor: GVColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            const LinearProgressIndicator(
              value: 0.40,
              backgroundColor: Color(0xFF232D28),
              valueColor: AlwaysStoppedAnimation(GVColors.brandGreen),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Step 2 of 5: Document Uploads',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '40% completed',
                    style: GVTypography.caption.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF232D28), height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(GVSpacing.md),
                children: [
                  Text(
                    'Identity & Regulatory Credentials',
                    style: GVTypography.h2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Upload clear photos of your required identification documents. Lagos State MOT compliance is strictly enforced.',
                    style: GVTypography.caption.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: GVSpacing.lg),

                  _buildDocCard(
                    type: DocumentType.nationalId,
                    documents: state.documents,
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  _buildDocCard(
                    type: DocumentType.driversLicense,
                    documents: state.documents,
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  _buildDocCard(
                    type: DocumentType.vehicleRegistration,
                    documents: state.documents,
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  _buildDocCard(
                    type: DocumentType.insuranceCert,
                    documents: state.documents,
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  _buildDocCard(
                    type: DocumentType.lasrra,
                    documents: state.documents,
                  ),
                  const SizedBox(height: GVSpacing.xl),
                ],
              ),
            ),

            // Next CTA
            Padding(
              padding: const EdgeInsets.all(GVSpacing.md),
              child: GVPrimaryButton(
                label: 'Save & Continue to Vehicle Details',
                onPressed: () {
                  if (state.hasRequiredDocuments) {
                    context.push('/onboarding/vehicle');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please upload NIN, Driver\'s License, and Vehicle Registration before proceeding.',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard({
    required DocumentType type,
    required List<RiderDocumentDto> documents,
  }) {
    final doc = documents.where((d) => d.type == type).firstOrNull;
    final isUploaded = doc != null;

    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(
          color: isUploaded ? const Color(0xFF2E4638) : const Color(0xFF2A3630),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUploaded ? Icons.check_circle : Icons.upload_file,
                color: isUploaded ? GVColors.brandGreen : Colors.white54,
                size: 24,
              ),
              const SizedBox(width: GVSpacing.xs),
              Expanded(
                child: Text(
                  type.title,
                  style: GVTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isUploaded)
                GVStatusChip(
                  label: doc.status.label,
                  status: doc.status == DocumentVerificationStatus.approved
                      ? GVStatusType.active
                      : GVStatusType.pending,
                ),
            ],
          ),
          const SizedBox(height: GVSpacing.xs),
          if (isUploaded) ...[
            Text(
              'No: ${doc.documentNumber} · Expires: ${_dateFormat.format(doc.expiryDate)}',
              style: GVTypography.caption.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: GVSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.edit, size: 16, color: GVColors.brandGreen),
                label: const Text(
                  'Update / Replace File',
                  style: TextStyle(color: GVColors.brandGreen),
                ),
                onPressed: () => _showUploadDialog(type),
              ),
            ),
          ] else ...[
            Text(
              'Government verified document required for rider activation.',
              style: GVTypography.caption.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: GVSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GVColors.deepGreen,
                  foregroundColor: GVColors.brandGreen,
                ),
                icon: const Icon(Icons.add_a_photo, size: 16),
                label: const Text('Capture & Upload'),
                onPressed: () => _showUploadDialog(type),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
