/// Environment configuration for API endpoints
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment currentEnvironment = Environment.production;

  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        // Local development
        return 'http://10.0.2.2:8000/api';
      case Environment.staging:
        // Azure staging
        return 'https://fixoo-dkcnaaejgnbff6f8.southeastasia-01.azurewebsites.net/api';
      case Environment.production:
        // Azure production
        return 'https://fixoo-dkcnaaejgnbff6f8.southeastasia-01.azurewebsites.net/api';
    }
  }

  static String get environmentName {
    switch (currentEnvironment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  /// Set environment at app startup
  static void setEnvironment(Environment env) {
    currentEnvironment = env;
    print('🔧 Environment set to: ${env.name.toUpperCase()}');
    print('🌐 API Base URL: $baseUrl');
  }

  /// Log current configuration
  static void logConfig() {
    print('═══════════════════════════════════════');
    print('📱 App Configuration');
    print('Environment: $environmentName');
    print('Base URL: $baseUrl');
    print('═══════════════════════════════════════');
  }
}
