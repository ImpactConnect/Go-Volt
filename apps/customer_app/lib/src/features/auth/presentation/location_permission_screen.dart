import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

/// A07 — Location Permission Onboarding Screen
class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;

  Future<void> _requestLocation() async {
    setState(() => _isLoading = true);
    try {
      final permission = await Geolocator.requestPermission();
      if (mounted) {
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          context.go(AppRoutes.home);
        } else {
          // Fallback to home anyway so user is not blocked
          context.go(AppRoutes.home);
        }
      }
    } catch (_) {
      if (mounted) context.go(AppRoutes.home);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Map pin / Electric beacon visual
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: GVColors.brandGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 64,
                    color: GVColors.brandGreen,
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              Text(
                'Enable Precise Location',
                textAlign: TextAlign.center,
                style: GVTypography.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: GVColors.textPrimary,
                ),
              ),
              const SizedBox(height: GVSpacing.sm),

              Text(
                'Go-Volts uses your location to discover nearby electric drivers, estimate pickup ETAs accurately, and calculate upfront fares.',
                textAlign: TextAlign.center,
                style: GVTypography.bodyMedium.copyWith(
                  color: GVColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(),

              GVPrimaryButton(
                label: 'Allow Location Services',
                isLoading: _isLoading,
                onPressed: _requestLocation,
              ),
              const SizedBox(height: GVSpacing.sm),

              GVOutlinedButton(
                label: 'Enter Location Manually',
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
