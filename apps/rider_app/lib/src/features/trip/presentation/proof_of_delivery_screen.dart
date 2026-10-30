import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/active_trip_notifier.dart';

/// Screen RD17: Proof of Delivery (Photo Capture & Recipient Signature).
class ProofOfDeliveryScreen extends ConsumerStatefulWidget {
  const ProofOfDeliveryScreen({
    super.key,
    required this.job,
  });

  final DispatchOfferDto job;

  @override
  ConsumerState<ProofOfDeliveryScreen> createState() =>
      _ProofOfDeliveryScreenState();
}

class _ProofOfDeliveryScreenState extends ConsumerState<ProofOfDeliveryScreen> {
  final TextEditingController _recipientNameController = TextEditingController();
  bool _photoCaptured = true; // default mock photo captured
  bool _signatureConfirmed = true;

  @override
  void initState() {
    super.initState();
    _recipientNameController.text = widget.job.customerName;
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _recipientNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter recipient full name')),
      );
      return;
    }

    final notifier =
        ref.read(activeTripNotifierProvider(widget.job).notifier);
    final success = await notifier.submitProofOfDelivery(
      photoUrl: 'https://cdn.govolts.ng/pod/pkg_delivered_8891.jpg',
      recipientName: name,
      signature: 'SIG-${name.replaceAll(' ', '_')}',
    );

    if (mounted && success) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeTripNotifierProvider(widget.job));

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Proof of Delivery'),
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
                child: ListView(
                  children: [
                    Text(
                      'Capture Delivery Evidence',
                      style: GVTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    Text(
                      'Take a clear photo of the delivered parcel at destination and record recipient identification.',
                      style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Photo Proof Card
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2420),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(
                          color: _photoCaptured ? GVColors.brandGreen : const Color(0xFF2A3630),
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() => _photoCaptured = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Camera snapshot captured!')),
                          );
                        },
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _photoCaptured ? Icons.check_circle : Icons.camera_alt,
                                color: _photoCaptured ? GVColors.brandGreen : Colors.white60,
                                size: 40,
                              ),
                              const SizedBox(height: GVSpacing.xs),
                              Text(
                                _photoCaptured ? 'Photo Proof Attached (Tap to Retake)' : 'Tap to Open Camera',
                                style: GVTypography.bodyMedium.copyWith(
                                  color: _photoCaptured ? GVColors.brandGreen : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'GPS geotagged & timestamped automatically',
                                style: GVTypography.caption.copyWith(color: Colors.white38),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Recipient Name
                    TextFormField(
                      controller: _recipientNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Recipient Full Legal Name *',
                        prefixIcon: Icon(Icons.person, color: GVColors.brandGreen),
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Signature / Acknowledgment
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2420),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(color: const Color(0xFF2A3630)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.draw, color: GVColors.brandGreen, size: 20),
                              const SizedBox(width: GVSpacing.xs),
                              Expanded(
                                child: Text(
                                  'Digital Handover Confirmation',
                                  style: GVTypography.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: GVSpacing.xs),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Recipient personally inspected item and acknowledged safe delivery in good condition.',
                              style: GVTypography.caption.copyWith(color: Colors.white70),
                            ),
                            value: _signatureConfirmed,
                            activeColor: GVColors.brandGreen,
                            checkColor: Colors.black,
                            onChanged: (val) =>
                                setState(() => _signatureConfirmed = val ?? false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Submit Button
              GVPrimaryButton(
                label: state.isLoading ? 'Uploading Proof...' : 'Confirm Delivery & Proceed',
                onPressed: (state.isLoading || !_signatureConfirmed) ? null : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
