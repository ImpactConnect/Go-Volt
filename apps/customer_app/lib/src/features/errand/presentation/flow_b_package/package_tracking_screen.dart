import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/package_errand_notifier.dart';

/// Screen B6: Package in Transit (Pick Up a Package Flow).
/// Displays live milestone stepper, interactive route map, assigned rider card, and ETA status banner.
class PackageTrackingScreen extends ConsumerWidget {
  const PackageTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(packageErrandNotifierProvider);
    final currentStatus =
        state.activeErrand?.status ?? ErrandStatus.outForDelivery;
    final rider = state.activeErrand?.assignedRider ??
        const RiderDto(
          id: 'rider_01',
          profileId: 'prof_ahmed',
          fullName: 'Ahmed Ibrahim',
          phoneNumber: '+234 803 456 7890',
          vehicleModel: 'Yamaha EV',
          vehiclePlate: 'ABC-123KY',
          rating: 4.8,
          totalTripsCompleted: 320,
        );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Package in Transit',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.errandHome),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper: Picked Up -> In Transit -> Delivered
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.white,
              child: _buildStepper(currentStatus),
            ),
            const Divider(height: 1),

            // Live Map View Simulation
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE8F0EA),
                    child: CustomPaint(
                      painter: _PackageRoutePainter(),
                      child: Container(),
                    ),
                  ),

                  // Floating Origin Badge (Barnawa)
                  Positioned(
                    top: 36,
                    left: 36,
                    child: _buildLocationPin(
                      label: state.pickupDetails.pickupBusinessName.split(',').first,
                      icon: Icons.storefront,
                      color: GVColors.primary,
                    ),
                  ),

                  // Floating Destination Pin (Power Plant)
                  Positioned(
                    bottom: 60,
                    right: 48,
                    child: _buildLocationPin(
                      label: state.deliveryLocation.label ?? 'Destination',
                      icon: Icons.place,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Sheets / Rider Card + ETA Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rider Details Card
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: GVColors.primary.withValues(alpha: 0.15),
                        child: const Icon(Icons.person, color: GVColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rider.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${rider.rating}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '•  Rider - ${rider.vehiclePlate}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          padding: const EdgeInsets.all(10),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline,
                            size: 18, color: GVColors.primary),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          padding: const EdgeInsets.all(10),
                        ),
                        icon: const Icon(Icons.phone_outlined,
                            size: 18, color: GVColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ETA Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GVColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: GVColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.two_wheeler,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'On the way to you',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: GVColors.primary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'ETA: 12 mins (4.2 km)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Milestone simulation action button
                  TextButton.icon(
                    onPressed: () async {
                      await ref
                          .read(packageErrandNotifierProvider.notifier)
                          .advanceMilestone();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Milestone advanced successfully!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.fast_forward, size: 16, color: GVColors.primary),
                    label: const Text(
                      'Simulate Next Milestone',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: GVColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPin({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(ErrandStatus status) {
    // 3 steps: Picked Up -> In Transit -> Delivered
    final isPickedUp = status == ErrandStatus.outForDelivery ||
        status == ErrandStatus.delivered ||
        status == ErrandStatus.completed ||
        status == ErrandStatus.agentAssigned;
    final isInTransit = status == ErrandStatus.outForDelivery ||
        status == ErrandStatus.delivered ||
        status == ErrandStatus.completed;
    final isDelivered = status == ErrandStatus.delivered || status == ErrandStatus.completed;

    return Row(
      children: [
        _buildStepNode(label: 'Picked Up', isDone: isPickedUp, isActive: !isInTransit),
        Expanded(child: _buildStepLine(isDone: isInTransit)),
        _buildStepNode(label: 'In Transit', isDone: isInTransit, isActive: isInTransit && !isDelivered),
        Expanded(child: _buildStepLine(isDone: isDelivered)),
        _buildStepNode(label: 'Delivered', isDone: isDelivered, isActive: false),
      ],
    );
  }

  Widget _buildStepNode({
    required String label,
    required bool isDone,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? GVColors.primary : Colors.grey.shade300,
            border: isActive
                ? Border.all(color: GVColors.primary, width: 2.5)
                : null,
          ),
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            size: isDone ? 16 : 8,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
            color: isDone ? GVColors.primary : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isDone}) {
    return Container(
      height: 3,
      margin: const EdgeInsets.only(bottom: 18),
      color: isDone ? GVColors.primary : Colors.grey.shade300,
    );
  }
}

class _PackageRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = GVColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(60, 50);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.25,
      size.width * 0.65,
      size.height * 0.55,
      size.width - 70,
      size.height - 70,
    );
    canvas.drawPath(path, routePaint);

    // Draw Rider position along curve
    final riderPaint = Paint()..color = GVColors.primary;
    final riderPos = Offset(size.width * 0.48, size.height * 0.42);
    canvas.drawCircle(riderPos, 14, riderPaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(riderPos, 6, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
