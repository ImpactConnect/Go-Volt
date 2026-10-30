import 'package:app_config/app_config.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/core/router/app_router.dart';

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
      debugPrint('[Go-Volts] Supabase client initialized: ${config.supabaseUrl}');
    } catch (e) {
      debugPrint('[Go-Volts] Supabase initialization failed: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: CustomerApp(),
    ),
  );
}

class CustomerApp extends ConsumerWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Go-Volts',
      theme: GVTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
