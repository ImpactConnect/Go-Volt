import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main scaffold shell managing the persistent 5-tab GVBottomNavigation.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: GVBottomNavigation(
        currentTab: GVNavTab.values[navigationShell.currentIndex],
        onTabSelected: (tab) {
          navigationShell.goBranch(
            tab.index,
            initialLocation: tab.index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
