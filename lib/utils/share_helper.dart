import 'dart:js_interop';
import 'package:flutter/material.dart';
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

    try {
      final navigator = web.window.navigator;
      final shareData = web.ShareData(
        title: title,
        text: text,
        url: url,
      );
      
      // Note: navigator.share requires HTTPS. 
      // It will throw an error on localhost/HTTP causing the fallback to run.
      await navigator.share(shareData).toDart;
      return;
    } catch (_) {
      shareFailed = true;
    }

    if (shareFailed && context.mounted) {
      // Fallback: copy the URL to the clipboard.
      try {
        web.window.navigator.clipboard.writeText(url);
        _showCopySnackbar(context, url);
      } catch (_) {
        // Clipboard API also blocked — silently fail or alert.
      }
    }
  }

  static void _showCopySnackbar(BuildContext context, String url) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Link copied to clipboard',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }
}
