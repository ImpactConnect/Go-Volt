import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/other_errand_notifier.dart';

/// Screen C5: Errand in Progress (Flow C: Other Errand).
/// Live milestone stepper (Assigned -> In Progress -> Delivering), live map, assigned rider card, and task status banner.
class CustomErrandTrackingScreen extends ConsumerWidget {
  const CustomErrandTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(otherErrandNotifierProvider);
    final currentStatus =
        state.activeErrand?.status ?? ErrandStatus.inProgress;
    final rider = state.activeErrand?.assignedRider ??
        const RiderDto(
          id: 'unassigned',
          profileId: '',
          fullName: 'Assigning Rider...',
          phoneNumber: '',
          vehicleModel: 'Electric Courier',
          vehiclePlate: 'Go-Volt EV',
          rating: 5.0,
          totalTripsCompleted: 0,
        );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Errand in Progress',
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
            // Stepper: Assigned -> In Progress -> Delivering
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.white,
              child: _buildStepper(currentStatus),
            ),
            const Divider(height: 1),

            // Map Area Simulation
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE8F0EA),
                    child: CustomPaint(
                      painter: _TaskRoutePainter(),
                      child: Container(),
                    ),
                  ),

                  // Origin Pin
                  Positioned(
                    top: 40,
                    left: 36,
                    child: _buildLocationPin(
                      label: state.pickupLocation.address.split(',').first,
                      icon: Icons.assignment_turned_in,
                      color: GVColors.primary,
                    ),
                  ),

                  // Destination Pin
                  Positioned(
                    bottom: 60,
                    right: 48,
                    child: _buildLocationPin(
                      label: state.deliveryLocation.address.split(',').first,
                      icon: Icons.place,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Rider Card + Task Status Banner
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

                  // Task Status Banner
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
                            Icons.assignment_outlined,
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
                                'Task in progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: GVColors.primary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Collecting your document now.',
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

                  // Simulation Advance Button
                  TextButton.icon(
                    onPressed: () async {
                      await ref
                          .read(otherErrandNotifierProvider.notifier)
                          .advanceStatus();
                      final active = ref.read(otherErrandNotifierProvider).activeErrand;
                      if (active?.status == ErrandStatus.completed && context.mounted) {
                        context.pushReplacement(AppRoutes.errandCompleted);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Milestone advanced! Advance again to complete errand.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.fast_forward, size: 16, color: GVColors.primary),
                    label: const Text(
                      'Advance Task Milestone',
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
    // Assigned -> In Progress -> Delivering
    final isAssigned = true;
    final isInProgress = status == ErrandStatus.inProgress ||
        status == ErrandStatus.outForDelivery ||
        status == ErrandStatus.delivered ||
        status == ErrandStatus.completed;
    final isDelivering = status == ErrandStatus.outForDelivery ||
        status == ErrandStatus.delivered ||
        status == ErrandStatus.completed;

    return Row(
      children: [
        _buildStepNode(label: 'Assigned', isDone: isAssigned, isActive: !isInProgress),
        Expanded(child: _buildStepLine(isDone: isInProgress)),
        _buildStepNode(label: 'In Progress', isDone: isInProgress, isActive: isInProgress && !isDelivering),
        Expanded(child: _buildStepLine(isDone: isDelivering)),
        _buildStepNode(label: 'Delivering', isDone: isDelivering, isActive: false),
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

class _TaskRoutePainter extends CustomPainter {
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

    final riderPaint = Paint()..color = GVColors.primary;
    final riderPos = Offset(size.width * 0.48, size.height * 0.42);
    canvas.drawCircle(riderPos, 14, riderPaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(riderPos, 6, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
