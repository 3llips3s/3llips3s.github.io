import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads and exposes environment variables from `.env`.
abstract final class EnvConfig {
  /// Must be called before `runApp`.
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  static String get wiredashProjectId =>
      dotenv.env['WIREDASH_PROJECT_ID'] ?? '';

  static String get wiredashSecret =>
      dotenv.env['WIREDASH_SECRET'] ?? '';

  /// Returns `true` if both Wiredash credentials are present.
  static bool get isWiredashConfigured =>
      wiredashProjectId.isNotEmpty && wiredashSecret.isNotEmpty;
}
