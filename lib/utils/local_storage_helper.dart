import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Provides native browser localStorage access to avoid heavy plugins.
abstract final class LocalStorageHelper {
  /// Reads a boolean from `window.localStorage`.
  /// Safe to call on non-web platforms (returns false).
  static bool readBool(String key) {
    if (!kIsWeb) return false;
    try {
      final value = web.window.localStorage.getItem(key);
      return value == 'true';
    } catch (_) {
      return false; // Fallback gracefully if storage is restricted
    }
  }

  /// Writes a boolean to `window.localStorage`.
  /// Safe to call on non-web platforms (no-op).
  static void writeBool(String key, bool value) {
    if (!kIsWeb) return;
    try {
      web.window.localStorage.setItem(key, value.toString());
    } catch (_) {
      // Ignore write errors (e.g., quota exceeded or incognito blocking)
    }
  }
}
