import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Manages the loading and exposure of environment variables.
abstract final class EnvConfig {
  /// Initializes the environment configuration by loading the `.env` file.
  ///
  /// This must be called during application startup before `runApp`.
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  /// The Supabase project URL.
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  /// The Supabase anonymous key.
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
