import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Displays a 3D model using the Google `<model-viewer>` web component.
///
/// Embeds the web component via [HtmlElementView] and utilizes native CSS 
/// transitions for a smooth fade and scale emergence. This bypasses Flutter's 
/// compositor to ensure high-performance rendering on the web.
class ModelViewerWidget extends StatefulWidget {
  const ModelViewerWidget({super.key});

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
        element.id = 'studio-model-viewer';
        element.setAttribute('src', 'assets/assets/3d/hoops.glb');

        element.setAttribute('orientation', '90deg 0deg 0deg');
        element.setAttribute('auto-rotate', '');
        element.setAttribute('auto-rotate-delay', '0');
        element.setAttribute('rotation-per-second', '12deg');
        element.setAttribute('autoplay', '');
        element.setAttribute('interaction-prompt', 'none');
        element.setAttribute('loading', 'eager');
        element.style.setProperty('width', '100%');
        element.style.setProperty('height', '100%');
        element.style.setProperty('background-color', 'transparent');
        element.style.setProperty('--poster-color', 'transparent');
        element.style.setProperty('outline', 'none');
        element.style.setProperty('border', 'none');
        element.style.setProperty('opacity', '0');
        element.style.setProperty('transform', 'scale(0)');
        element.style.setProperty(
          'transition',
          'opacity 2.2s ease-out, transform 3.2s cubic-bezier(0.16, 1, 0.3, 1)',
        );

        element.addEventListener('load', (web.Event event) {
          element.style.setProperty('opacity', '1');
          element.style.setProperty('transform', 'scale(1)');
        }.toJS);

        return element;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: _viewType);
  }
}
