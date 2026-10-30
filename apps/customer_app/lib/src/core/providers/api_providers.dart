import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_notifier.dart';

/// Provides the active [AppConfig] runtime configuration.
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.current;
});

/// Provides the authenticated [ApiClient] for network communication.
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(
    config: config,
    tokenProvider: () async {
      final auth = ref.read(authNotifierProvider);
      return auth.token;
    },
  );
});
