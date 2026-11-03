import 'package:app_config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  AppConfig.initialize(config);

  if (config.supabaseUrl.isNotEmpty &&
      config.supabaseAnonKey.isNotEmpty &&
      !config.supabaseUrl.contains('placeholder')) {
    try {
      await Supabase.initialize(
        url: config.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: config.supabaseAnonKey,
      );
      debugPrint('[Go-Volts Admin] Supabase initialized: ${config.supabaseUrl}');
    } catch (e) {
      debugPrint('[Go-Volts Admin] Supabase initialization failed: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: AdminApp(),
    ),
  );
}
