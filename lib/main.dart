import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;
import 'config/env_config.dart';
import 'services/analytics_service.dart';
import 'app.dart';

/// Entry point for the Studio 10200 application.
///
/// Initializes environment configurations, Supabase, and analytics before
/// launching [StudioApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensures edge-to-edge drawing on Android Chrome by re-injecting 
  // 'viewport-fit=cover' which is stripped by the Flutter Web engine.
  if (kIsWeb) {
    final viewportMeta = web.document.querySelector('meta[name="viewport"]');
    if (viewportMeta != null) {
      final currentContent = viewportMeta.getAttribute('content') ?? '';
      if (!currentContent.contains('viewport-fit=cover')) {
        viewportMeta.setAttribute('content', '$currentContent, viewport-fit=cover');
      }
    }
  }

  await EnvConfig.init();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  // Trigger initial session tracking and page load logging.
  AnalyticsService.instance.logEvent(
    name: 'session_start',
    interactionType: 'page_load',
  );

  runApp(const StudioApp());
}
