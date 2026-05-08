import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;
import '../config/app_colors.dart';

/// Provides utility methods for sharing content using the native browser Share API.
abstract final class ShareHelper {
  /// Shares content using the native browser Share API.
  ///
  /// Requires a [title], [text], and [url]. If the native Share API is 
  /// unavailable (e.g., on desktop browsers or insecure connections), it 
  /// falls back to copying the [url] to the system clipboard.
  static Future<void> share(
    BuildContext context, {
    required String title,
    required String text,
    required String url,
  }) async {
    bool shareFailed = false;

    // 1. Attempt Native Web Share API
    try {
      final navigator = web.window.navigator;
      final shareData = web.ShareData(title: title, text: text, url: url);

      // Navigator.share requires HTTPS and will throw on insecure connections, 
      // triggering the clipboard fallback.
      await navigator.share(shareData).toDart;
      return;
    } catch (_) {
      shareFailed = true;
    }

    // 2. Fallback: Flutter Native Clipboard
    if (shareFailed && context.mounted) {
      try {
        await Clipboard.setData(ClipboardData(text: url));
        if (context.mounted) _showSnackbar(context, url, success: true);
      } catch (_) {
        // Even the clipboard failed (likely due to strict HTTP security policies).
        if (context.mounted) _showSnackbar(context, url, success: false);
      }
    }
  }

  static void _showSnackbar(
    BuildContext context,
    String url, {
    required bool success,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    // A washed-out purple that guarantees black text is highly readable, even in dark mode
    final Color washedPurple =
        Color.lerp(AppColors.primary, Colors.white, 0.4)!;

    final color =
        success
            ? washedPurple.withValues(alpha: 0.95)
            : Colors.redAccent.shade200;
    final icon = success ? Icons.check_rounded : Icons.error_outline_rounded;
    final text =
        success
            ? 'Link copied to clipboard'
            : 'Unable to share on current network';

    // Calculate margin to push the snackbar precisely to the top of the screen
    final topMargin = MediaQuery.sizeOf(context).height - 90;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        // Positions the snackbar at the top of the screen via margin offset.
        margin: EdgeInsets.only(
          bottom: topMargin > 0 ? topMargin : 24,
          left: 24,
          right: 24,
        ),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }
}
