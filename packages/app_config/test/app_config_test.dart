import 'package:app_config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('AppConfig.dev produces expected dev configuration', () {
      final config = AppConfig.dev();
      expect(config.environment, AppEnvironment.development);
      expect(config.isDevelopment, isTrue);
      expect(config.isProduction, isFalse);
      expect(config.isStaging, isFalse);
      expect(config.appName, 'Go-Volts Dev');
      expect(config.apiBaseUrl, contains('10.0.2.2:8080'));
      expect(config.enableSentry, isFalse);
    });

    test('AppConfig.staging produces expected staging configuration', () {
      final config = AppConfig.staging();
      expect(config.environment, AppEnvironment.staging);
      expect(config.isStaging, isTrue);
      expect(config.enableSentry, isTrue);
    });

    test('AppConfig.prod produces expected production configuration', () {
      final config = AppConfig.prod();
      expect(config.environment, AppEnvironment.production);
      expect(config.isProduction, isTrue);
      expect(config.appName, 'Go-Volts');
      expect(config.enableSentry, isTrue);
    });

    test('AppConfig.initialize updates current singleton', () {
      final custom = AppConfig.staging();
      AppConfig.initialize(custom);
      expect(AppConfig.current.environment, AppEnvironment.staging);
    });

    test('AppEnvironment.fromString parses case-insensitively with fallback to dev', () {
      expect(AppEnvironment.fromString('STAGING'), AppEnvironment.staging);
      expect(AppEnvironment.fromString('prod'), AppEnvironment.production);
      expect(AppEnvironment.fromString('production'), AppEnvironment.production);
      expect(AppEnvironment.fromString('unknown'), AppEnvironment.development);
    });
  });
}
