import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active environment configuration provider for the Rider App.
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.dev();
});

/// Shared ApiClient instance initialized with AppConfig baseURL and timeout.
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(config: config);
});
