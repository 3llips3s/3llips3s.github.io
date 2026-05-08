import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Provides simplified access to the native browser `localStorage` API.
abstract final class LocalStorageHelper {
  /// Reads a boolean value from the browser's [localStorage].
  ///
  /// Returns `false` if the platform is not web, if the [key] does not exist, 
  /// or if storage access is restricted.
  static bool readBool(String key) {
    if (!kIsWeb) return false;
    try {
      final value = web.window.localStorage.getItem(key);
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Writes a boolean [value] to the browser's [localStorage] at the given [key].
  ///
  /// This is a no-op on non-web platforms or if storage access is restricted.
  static void writeBool(String key, bool value) {
    if (!kIsWeb) return;
    try {
      web.window.localStorage.setItem(key, value.toString());
    } catch (_) {
      // Ignore write errors (e.g., quota exceeded or incognito blocking)
    }
  }
}
