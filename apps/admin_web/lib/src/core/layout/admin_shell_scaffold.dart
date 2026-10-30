import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/admin_sidebar.dart';
import 'admin_top_bar.dart';

class AdminShellScaffold extends StatelessWidget {
  const AdminShellScaffold({
    super.key,
    required this.child,
    required this.state,
  });

  final Widget child;
  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    final currentRoute = state.uri.path;

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      body: Row(
        children: [
          // Left Sidebar Navigation
          AdminSidebar(currentRoute: currentRoute),

          // Main Screen Area with Top Bar
          Expanded(
            child: Column(
              children: [
                const AdminTopBar(),
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
