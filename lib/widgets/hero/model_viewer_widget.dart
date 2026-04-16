import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Displays the 3D hoops model using Google's `<model-viewer>` web component
/// embedded directly in the page via [HtmlElementView].
///
/// Starts hidden and slides down smoothly via CSS transitions when
/// [reveal] is called. CSS animations bypass Flutter's compositor
/// which doesn't handle platform view transforms reliably on web.
class ModelViewerWidget extends StatefulWidget {
  const ModelViewerWidget({super.key});

  /// Trigger the CSS fade-in + scale-up animation.
  static void reveal() {
    final el = web.document.getElementById('studio-model-viewer')
        as web.HTMLElement?;
    if (el != null) {
      el.style.setProperty('opacity', '1');
      el.style.setProperty('transform', 'scale(1)');
    }
  }

  @override
  State<ModelViewerWidget> createState() => _ModelViewerWidgetState();
}

class _ModelViewerWidgetState extends State<ModelViewerWidget> {
  static bool _factoryRegistered = false;
  static const String _viewType = 'studio-model-viewer';

  @override
  void initState() {
    super.initState();
    _registerFactory();
  }

  void _registerFactory() {
    if (_factoryRegistered) return;
    _factoryRegistered = true;

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId, {Object? params}) {
        final element =
            web.document.createElement('model-viewer') as web.HTMLElement;

        // ── Identity (for JS-driven animation) ──────────────────
        element.id = 'studio-model-viewer';

        // ── Model source ────────────────────────────────────────
        element.setAttribute('src', 'assets/3d/hoops.glb');

        // ── Orientation — rotate 90° on X-axis so hoops sit upright ──
        element.setAttribute('orientation', '90deg 0deg 0deg');

        // ── Rotation (camera orbits the model) ──────────────────
        element.setAttribute('auto-rotate', '');
        element.setAttribute('auto-rotate-delay', '0');
        element.setAttribute('rotation-per-second', '12deg'); // 2 RPM

        // ── Play embedded animations if the GLB contains any ────
        element.setAttribute('autoplay', '');

        // ── Disable all interaction ─────────────────────────────
        element.setAttribute('interaction-prompt', 'none');
        element.setAttribute('loading', 'eager');

        // ── Initial state: hidden + scaled to zero ──────────────
        element.style.setProperty('width', '100%');
        element.style.setProperty('height', '100%');
        element.style.setProperty('background-color', 'transparent');
        element.style.setProperty('--poster-color', 'transparent');
        element.style.setProperty('outline', 'none');
        element.style.setProperty('border', 'none');
        element.style.setProperty('opacity', '0');
        element.style.setProperty('transform', 'scale(0)');
        // CSS transition for the gentle fade + scale emergence.
        element.style.setProperty(
          'transition',
          'opacity 1.2s ease-out, transform 1.6s cubic-bezier(0.25, 1, 0.5, 1)',
        );

        return element;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: _viewType);
  }
}
