import 'package:web/web.dart' as web;

/// Native browser Share API via `dart:js_interop`.
///
/// Falls back to copying the link to the clipboard if the Share API
/// is not available (e.g. desktop browsers).
abstract final class ShareHelper {
  /// Share a project link using the native Share API.
  /// Falls back to clipboard copy if unavailable.
  static Future<void> share({
    required String title,
    required String text,
    required String url,
  }) async {
    try {
      final navigator = web.window.navigator;
      final shareData = web.ShareData(
        title: title,
        text: text,
        url: url,
      );
      navigator.share(shareData);
      return;
    } catch (_) {
      // Share API not available or failed — fall through to clipboard.
    }

    // Fallback: copy the URL to the clipboard.
    try {
      web.window.navigator.clipboard.writeText(url);
    } catch (_) {
      // Clipboard API also not available — silently fail.
    }
  }
}
