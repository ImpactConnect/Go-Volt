import 'package:flutter/material.dart';
import 'help_centre_screen.dart';

/// Legacy / Route alias for Help & Support Center.
/// Delegates to [HelpCentreScreen] for unified state management and searchable FAQs.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpCentreScreen();
  }
}
