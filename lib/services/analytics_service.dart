import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../utils/device_info_helper.dart';

/// Provides a singleton service for logging application events to Supabase.
///
/// Generates a unique [sessionId] upon initialization to track user journeys 
/// within a single application session. All operations fail silently to ensure 
/// that analytics tracking never interrupts the user experience.
class AnalyticsService {
  AnalyticsService._() : sessionId = const Uuid().v4();

  /// The global singleton instance of the [AnalyticsService].
  static final AnalyticsService instance = AnalyticsService._();

  /// The unique identifier for the current application session.
  final String sessionId;

  /// Logs an interaction event to the backend analytics table.
  ///
  /// The [name] specifies the event category, while [interactionType] 
  /// describes the specific action taken. An optional [projectName] can 
  /// be provided to add project-specific context.
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
      debugPrint('Analytics silent fail: $e');
    }
  }
}
