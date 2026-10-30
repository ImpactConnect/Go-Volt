import 'package:flutter/material.dart';
import '../navigation/merchant_sidebar.dart';
import 'merchant_top_bar.dart';

class MerchantShellScaffold extends StatelessWidget {
  const MerchantShellScaffold({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  final String currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C120F),
      body: Row(
        children: [
          // Fixed Left Sidebar
          MerchantSidebar(currentRoute: currentRoute),

          // Main Area: TopBar + Screen Content
          Expanded(
            child: Column(
              children: [
                const MerchantTopBar(),
                Expanded(
                  child: Container(
                    color: const Color(0xFF0C120F),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
