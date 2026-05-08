import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages the submission of user feedback to Supabase.
abstract final class FeedbackService {
  /// Submits user feedback to the backend.
  ///
  /// Returns `true` if the submission was successful, otherwise `false`. 
  /// Requires a [message] and [projectName], with an optional [contactEmail]. 
  /// The [deviceInfo] map is included for debugging context.
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
