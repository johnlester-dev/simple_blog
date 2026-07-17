enum AppEnvironment { development, sandbox, production }

abstract final class Environment {
  static const String _environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static AppEnvironment get current {
    return switch (_environmentName) {
      'development' => AppEnvironment.development,
      'sandbox' => AppEnvironment.sandbox,
      'production' => AppEnvironment.production,
      _ => throw StateError('Unsupported APP_ENV: $_environmentName'),
    };
  }

  static void validate() {
    current;

    if (supabaseUrl.trim().isEmpty) {
      throw StateError('SUPABASE_URL is missing. Pass it using --dart-define.');
    }

    if (supabasePublishableKey.trim().isEmpty) {
      throw StateError(
        'SUPABASE_PUBLISHABLE_KEY is missing. '
        'Pass it using --dart-define.',
      );
    }
  }
}
