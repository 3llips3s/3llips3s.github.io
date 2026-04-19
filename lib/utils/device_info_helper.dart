import 'package:web/web.dart' as web;

/// Collects device metadata from the browser environment.
///
/// Used by both [AnalyticsService] and [FeedbackService] to capture
/// user agent, screen size, platform, and a simplified browser label.
abstract final class DeviceInfoHelper {
  /// Returns a JSON-serializable map with device metadata.
  static Map<String, dynamic> collect() {
    try {
      final userAgent = web.window.navigator.userAgent;
      final screenWidth = web.window.screen.width;
      final screenHeight = web.window.screen.height;

      return {
        'user_agent': userAgent,
        'browser_label': _parseBrowserLabel(userAgent),
        'platform': 'web',
        'screen_size': '${screenWidth}x$screenHeight',
      };
    } catch (_) {
      return {
        'user_agent': 'unknown',
        'browser_label': 'unknown',
        'platform': 'web',
        'screen_size': 'unknown',
      };
    }
  }

  /// Parses a human-readable label from the user agent string.
  ///
  /// Examples: "Chrome 120 / macOS", "Safari 17 / iOS", "Firefox 121 / Windows"
  static String _parseBrowserLabel(String ua) {
    String browser = 'Unknown';
    String os = 'Unknown';

    // ── Browser detection ─────────────────────────────────────────
    if (ua.contains('Edg/')) {
      final match = RegExp(r'Edg/(\d+)').firstMatch(ua);
      browser = 'Edge ${match?.group(1) ?? ''}';
    } else if (ua.contains('Chrome/') && !ua.contains('Chromium/')) {
      final match = RegExp(r'Chrome/(\d+)').firstMatch(ua);
      browser = 'Chrome ${match?.group(1) ?? ''}';
    } else if (ua.contains('Safari/') && !ua.contains('Chrome/')) {
      final match = RegExp(r'Version/(\d+)').firstMatch(ua);
      browser = 'Safari ${match?.group(1) ?? ''}';
    } else if (ua.contains('Firefox/')) {
      final match = RegExp(r'Firefox/(\d+)').firstMatch(ua);
      browser = 'Firefox ${match?.group(1) ?? ''}';
    }

    // ── OS detection ──────────────────────────────────────────────
    if (ua.contains('Mac OS X')) {
      os = 'macOS';
    } else if (ua.contains('Windows')) {
      os = 'Windows';
    } else if (ua.contains('Android')) {
      os = 'Android';
    } else if (ua.contains('iPhone') || ua.contains('iPad')) {
      os = 'iOS';
    } else if (ua.contains('Linux')) {
      os = 'Linux';
    } else if (ua.contains('CrOS')) {
      os = 'ChromeOS';
    }

    return '${browser.trim()} / $os';
  }
}
