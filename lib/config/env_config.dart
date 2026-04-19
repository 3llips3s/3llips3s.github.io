import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads and exposes environment variables from `.env`.
abstract final class EnvConfig {
  /// Must be called before `runApp`.
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
