import 'package:web/web.dart' as web;

/// Provides utility methods for collecting device metadata from the browser.
///
/// Used by [AnalyticsService] and [FeedbackService] to capture 
/// context such as the user agent, screen dimensions, and platform.
abstract final class DeviceInfoHelper {
  /// Collects and returns a JSON-serializable map with device metadata.
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
  /// For example, returns "Chrome 120 / macOS" or "Safari 17 / iOS".
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
