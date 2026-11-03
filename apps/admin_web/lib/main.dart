import 'package:app_config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(AppConfig.fromEnvironment());
  runApp(
    const ProviderScope(
      child: AdminApp(),
    ),
  );
}
