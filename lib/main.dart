import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'config/env_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // NATIVELY SOLVE PERSISTENT GREY BAR PWA ISSUE
  // Flutter Web engine explicitly overwrites the index.html viewport meta tag 
  // on initialization and actively removes `viewport-fit=cover`. Without it, 
  // Android Chrome bounds the PWA above the gesture bar and paints default grey.
  // We cleanly re-inject it exactly here to ensure edge-to-edge drawing under the nav bar.
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
  runApp(const StudioApp());
}
