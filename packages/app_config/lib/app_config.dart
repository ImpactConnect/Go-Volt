import 'package:flutter/foundation.dart';

/// Supported deployment environments.
enum AppEnvironment {
  development('dev', 'Development'),
  staging('staging', 'Staging'),
  production('prod', 'Production');

  const AppEnvironment(this.key, this.label);

  final String key;
  final String label;

  static AppEnvironment fromString(String raw) {
    return switch (raw.toLowerCase().trim()) {
      'staging' => AppEnvironment.staging,
      'production' || 'prod' => AppEnvironment.production,
      _ => AppEnvironment.development,
    };
  }
}

/// Non-secret runtime environment configuration for Go-Volts clients.
@immutable
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.sentryDsn,
    this.googleMapsApiKey,
    this.googleWebClientId,
    this.enableSentry = false,
  });

  /// Default development configuration.
  factory AppConfig.dev() {
    return const AppConfig(
      environment: AppEnvironment.development,
      appName: 'Go-Volts Dev',
      apiBaseUrl:
          kIsWeb ? 'http://localhost:8080/api/v1' : 'http://10.0.2.2:8080/api/v1',
      supabaseUrl: 'https://bxrhqpvarxaqcuhfqieq.supabase.co',
      supabaseAnonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ4cmhxcHZhcnhhcWN1aGZxaWVxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMxMDI4MjMsImV4cCI6MjEwODY3ODgyM30.0ddSWsHWCYzJBlOuaAC0WB8bLKWwpVJZY7IfnFKVQ-Q',
      googleWebClientId:
          '635282245140-fcdk1kkt5dbk87gh5qam7ljbhi5t3tm9.apps.googleusercontent.com',
      enableSentry: false,
    );
  }

  /// Default staging configuration.
  factory AppConfig.staging() {
    return const AppConfig(
      environment: AppEnvironment.staging,
      appName: 'Go-Volts Staging',
      apiBaseUrl: 'https://staging-api.govolts.ng/api/v1',
      supabaseUrl: 'https://staging-supabase.govolts.ng',
      supabaseAnonKey: 'staging-anon-key-placeholder',
      enableSentry: true,
    );
  }

  /// Production configuration.
  factory AppConfig.prod() {
    return const AppConfig(
      environment: AppEnvironment.production,
      appName: 'Go-Volts',
      apiBaseUrl: 'https://api.govolts.ng/api/v1',
      supabaseUrl: 'https://supabase.govolts.ng',
      supabaseAnonKey: 'prod-anon-key-placeholder',
      enableSentry: true,
    );
  }

  /// Resolved configuration from compile-time environment flags.
  factory AppConfig.fromEnvironment() {
    const rawEnv = String.fromEnvironment('ENV', defaultValue: 'dev');
    final env = AppEnvironment.fromString(rawEnv);

    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    const supabaseUrl = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    const supabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
    const mapsKey = String.fromEnvironment(
      'GOOGLE_MAPS_KEY',
      defaultValue: '',
    );
    const googleClientId = String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
      defaultValue: '',
    );

    final base = switch (env) {
      AppEnvironment.production => AppConfig.prod(),
      AppEnvironment.staging => AppConfig.staging(),
      AppEnvironment.development => AppConfig.dev(),
    };

    return AppConfig(
      environment: env,
      appName: base.appName,
      apiBaseUrl: apiBaseUrl.isNotEmpty ? apiBaseUrl : base.apiBaseUrl,
      supabaseUrl: supabaseUrl.isNotEmpty ? supabaseUrl : base.supabaseUrl,
      supabaseAnonKey: supabaseAnonKey.isNotEmpty ? supabaseAnonKey : base.supabaseAnonKey,
      googleMapsApiKey: mapsKey.isNotEmpty ? mapsKey : base.googleMapsApiKey,
      googleWebClientId: googleClientId.isNotEmpty ? googleClientId : base.googleWebClientId,
      enableSentry: env == AppEnvironment.production || env == AppEnvironment.staging,
    );
  }

  final AppEnvironment environment;
  final String appName;
  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String? sentryDsn;
  final String? googleMapsApiKey;
  final String? googleWebClientId;
  final bool enableSentry;

  bool get isProduction => environment == AppEnvironment.production;
  bool get isDevelopment => environment == AppEnvironment.development;
  bool get isStaging => environment == AppEnvironment.staging;

  static AppConfig _current = AppConfig.dev();

  static AppConfig get current => _current;

  static void initialize(AppConfig config) {
    _current = config;
  }
}
