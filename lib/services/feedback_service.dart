import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin service wrapper for inserting feedback into the Supabase `feedback` table.
///
/// Keeps the dialog widget free of direct Supabase import details.
abstract final class FeedbackService {
  /// Submits user feedback. Returns `true` on success, `false` on failure.
  static Future<bool> submit({
    required String message,
    required String projectName,
    String? contactEmail,
    required Map<String, dynamic> deviceInfo,
  }) async {
    try {
      final client = Supabase.instance.client;
      await client.from('feedback').insert({
        'message': message,
        'project_name': projectName,
        'contact_email': contactEmail,
        'device_info': deviceInfo,
      });
      return true;
    } catch (e) {
      debugPrint('Feedback submit failed: $e');
      return false;
    }
  }
}
