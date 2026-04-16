import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;
import '../config/app_colors.dart';

/// Native browser Share API via `dart:js_interop`.
///
/// Falls back to copying the link to the clipboard if the Share API
/// is not available (e.g. desktop browsers, or HTTP local environments).
abstract final class ShareHelper {
  /// Share a project link using the native Share API.
  /// Falls back to clipboard copy + Snackbar if unavailable.
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

      // Note: navigator.share requires HTTPS.
      // It will throw an error on localhost/HTTP causing the fallback to run.
      await navigator.share(shareData).toDart;
      return; // Share sheet successfully triggered!
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
              style: GoogleFonts.inter(
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
        // Hack to simulate top-aligned snackbar via bottom margin calculation
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
