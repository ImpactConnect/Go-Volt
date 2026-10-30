import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Screen/Modal for Request Accepted (Board 2 Screen 5).
class RequestAcceptedModal extends StatelessWidget {
  const RequestAcceptedModal({
    super.key,
    required this.job,
    required this.onNavigate,
    required this.onContactPassenger,
  });

  final DispatchOfferDto job;
  final VoidCallback onNavigate;
  final VoidCallback onContactPassenger;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141917),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF232D28))),
      ),
      padding: const EdgeInsets.all(GVSpacing.md),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Nav Header Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Head to Pickup Location',
                        style: GVTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${job.pickupDistanceKm} km • ${job.pickupEtaMinutes} min',
                        style: GVTypography.caption.copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GVColors.brandGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GVBorderRadius.full),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.navigation, size: 16),
                    label: const Text('Navigate', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: onNavigate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Passenger Info Row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: GVColors.deepGreen,
                  child: Text(
                    job.customerName.isNotEmpty ? job.customerName[0] : 'A',
                    style: GVTypography.h3.copyWith(color: GVColors.brandGreen),
                  ),
                ),
                const SizedBox(width: GVSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.customerName.isNotEmpty ? job.customerName : 'Amara Bello',
                        style: GVTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '4.9 (112)',
                            style: GVTypography.caption.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Call & Chat buttons
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: GVColors.brandGreen.withValues(alpha: 0.15),
                    foregroundColor: GVColors.brandGreen,
                  ),
                  icon: const Icon(Icons.call),
                  onPressed: onContactPassenger,
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: GVColors.brandGreen.withValues(alpha: 0.15),
                    foregroundColor: GVColors.brandGreen,
                  ),
                  icon: const Icon(Icons.chat_bubble),
                  onPressed: onContactPassenger,
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.md),

            // Pickup Location Address
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_checked, color: GVColors.brandGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup',
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          job.pickupAddress,
                          style: GVTypography.bodyMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.sm),

            // Note from Customer Callout
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2B24),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: GVColors.brandGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note_alt_outlined, color: GVColors.brandGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note from customer',
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'I will be waiting at the main gate.',
                          style: GVTypography.caption.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),
          ],
        ),
      ),
    );
  }
}
