import 'package:url_launcher/url_launcher.dart';

/// Convenience wrappers around [url_launcher] for common link types.
abstract final class UrlLauncherHelper {
  /// Open an external HTTP/HTTPS URL in the system browser.
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Open the default mail client with a pre-filled recipient.
  static Future<void> sendEmail(String address) async {
    final uri = Uri(scheme: 'mailto', path: address);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
