import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../utils/device_info_helper.dart';

/// Singleton analytics service for silent event logging.
///
/// Generates a unique [sessionId] at construction to track
/// the user's journey within a single app session. All errors
/// are caught and silently swallowed — analytics must never
/// interrupt the user experience.
class AnalyticsService {
  AnalyticsService._() : sessionId = const Uuid().v4();

  static final AnalyticsService instance = AnalyticsService._();

  /// Unique ID for this app session, generated once at launch.
  final String sessionId;

  /// Logs an interaction event to the `studio_analytics` table.
  ///
  /// [name] — event category (e.g. 'app_launch', 'engagement', 'external_intent')
  /// [projectName] — optional project context (e.g. 'Artikel Vogel')
  /// [interactionType] — specific action (e.g. 'web_play', 'share_click')
  Future<void> logEvent({
    required String name,
    String? projectName,
    required String interactionType,
  }) async {
    try {
      final client = Supabase.instance.client;
      await client.from('studio_analytics').insert({
        'event_name': name,
        'project_name': projectName,
        'interaction_type': interactionType,
        'session_id': sessionId,
        'device_metadata': DeviceInfoHelper.collect(),
      });
    } catch (e) {
      // Fail silently — analytics must never break the UX.
      debugPrint('Analytics silent fail: $e');
    }
  }
}
