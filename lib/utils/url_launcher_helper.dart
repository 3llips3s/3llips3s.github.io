import 'package:url_launcher/url_launcher.dart';

/// Provides utility methods for launching external URLs and system applications.
abstract final class UrlLauncherHelper {
  /// Opens an external HTTP/HTTPS URL in the default system browser.
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Launches the default system mail client to send an email to the given [address].
  static Future<void> sendEmail(String address) async {
    final uri = Uri(scheme: 'mailto', path: address);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
