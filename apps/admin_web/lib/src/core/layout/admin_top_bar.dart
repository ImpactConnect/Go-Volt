import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/admin_auth_notifier.dart';
import '../auth/admin_role.dart';

class AdminTopBar extends ConsumerWidget {
  const AdminTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(adminAuthNotifierProvider);
    final authNotifier = ref.read(adminAuthNotifierProvider.notifier);

    final serviceAreas = [
      'Lekki / Victoria Island',
      'Ikeja Commercial Hub',
      'Lagos Island Marina',
      'Surulere Central',
      'All Lagos Zones',
    ];

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
      decoration: const BoxDecoration(
        color: Color(0xFF101713),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1F2B25), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          // Left: Service Area Scope Selector
          Row(
            children: [
              const Icon(Icons.location_on, color: GVColors.brandGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Service Area:',
                style: GVTypography.caption.copyWith(color: Colors.white60),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16221B),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF23362A)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: authState.selectedServiceArea,
                    dropdownColor: const Color(0xFF16221B),
                    style: GVTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: GVColors.brandGreen),
                    items: serviceAreas.map((area) {
                      return DropdownMenuItem<String>(
                        value: area,
                        child: Text(area),
                      );
                    }).toList(),
                    onChanged: (newArea) {
                      if (newArea != null) {
                        authNotifier.setServiceArea(newArea);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Live Ops Status Pulse
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF14241B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: GVColors.brandGreen,
                        shape: BoxShape.circle,
                        boxShadow: GVShadows.glow,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Fleet Live · Lagos WAT',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Right: Role Simulator Dropdown & Admin Profile
          Row(
            children: [
              // RBAC Role Switcher
              Row(
                children: [
                  const Icon(Icons.security, size: 16, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    'Role View:',
                    style: GVTypography.caption.copyWith(color: Colors.white60),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282312),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<StaffRole>(
                        value: authState.role,
                        dropdownColor: const Color(0xFF1F1D13),
                        style: GVTypography.caption.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.amber, size: 18),
                        items: StaffRole.values.map((role) {
                          return DropdownMenuItem<StaffRole>(
                            value: role,
                            child: Text(role.label),
                          );
                        }).toList(),
                        onChanged: (newRole) {
                          if (newRole != null) {
                            authNotifier.setRole(newRole);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Staff User Avatar & Name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF16221B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF23362A)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: GVColors.deepGreen,
                      child: Text(
                        authState.fullName.substring(0, 1),
                        style: const TextStyle(
                          color: GVColors.brandGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      authState.fullName,
                      style: GVTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.logout, size: 16, color: Colors.white60),
                      tooltip: 'Sign Out',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Admin Session Closed')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
