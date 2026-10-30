import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';

/// Map panel placeholder / wrapper.
/// Actual google_maps_flutter widget is instantiated inside customer_app.
/// This widget provides the standardised container and fallback states.
class GVMapPanel extends StatelessWidget {
  const GVMapPanel({super.key, required this.child, this.isLoading = false, this.isOffline = false, this.onRecenter});
  final Widget child;
  final bool isLoading;
  final bool isOffline;
  final VoidCallback? onRecenter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isLoading)
          const Center(child: CircularProgressIndicator(color: GVColors.brandGreen))
        else if (isOffline)
          Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, size: 40, color: GVColors.textDisabled),
            const SizedBox(height: 8),
            Text('Map unavailable offline', style: GVTypography.bodySmall.copyWith(color: GVColors.textSecondary)),
          ]))
        else child,
        if (onRecenter != null && !isOffline && !isLoading)
          Positioned(right: 12, bottom: 12,
            child: FloatingActionButton.small(
              onPressed: onRecenter, backgroundColor: GVColors.white,
              child: const Icon(Icons.my_location, color: GVColors.brandGreen, size: 20),
            )),
      ],
    );
  }
}
