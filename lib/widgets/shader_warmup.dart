import 'dart:js_interop';
import 'dart:ui';
import 'package:flutter/material.dart';

@JS('window.removeLoader')
external void _removeLoader();

/// A widget that compiles core shaders before the application is fully visible.
///
/// Occupies a 1x1 pixel space while forcing a complex [Stack] of children to 
/// paint at a larger size, triggering the compilation of opacity, transform, 
/// clip, blur, and text shaders. 
///
/// Once the warm-up frame renders, it invokes [onWarmupComplete] and 
/// dismisses the native HTML loader via the JavaScript `window.removeLoader` hook.
class AppShaderWarmup extends StatefulWidget {
  /// The callback invoked once the shader warm-up is complete.
  final VoidCallback onWarmupComplete;

  const AppShaderWarmup({
    super.key,
    required this.onWarmupComplete,
  });

  @override
  State<AppShaderWarmup> createState() => _AppShaderWarmupState();
}

class _AppShaderWarmupState extends State<AppShaderWarmup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The warm-up frame has been painted by the GPU.
      // Remove the HTML loader and signal the app to transition.
      try {
        _removeLoader();
      } catch (e) {
        debugPrint('Error calling window.removeLoader(): $e');
      }
      widget.onWarmupComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    // We use a 1×1 clipping box with an unconstrained OverflowBox inside.
    // This forces children to paint at full size (triggering shader compilation)
    // while remaining invisible — clipped and fully transparent.
    return RepaintBoundary(
      child: SizedBox(
        width: 1,
        height: 1,
        child: Opacity(
          opacity: 0.01,
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxWidth: 200,
            maxHeight: 200,
            child: _buildWarmupScene(),
          ),
        ),
      ),
    );
  }

  Widget _buildWarmupScene() {
    return Stack(
      children: [
        // 1. BoxDecoration: rounded corners, gradient, shadow, border
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Colors.black, Colors.white],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),

        // 2. Transforms (translate + scale shader)
        Transform.translate(
          offset: const Offset(10, 10),
          child: Transform.scale(
            scale: 1.5,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: ColoredBox(color: Colors.red),
            ),
          ),
        ),

        // 3. Gaussian blur shader via BackdropFilter
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // 4. Opacity layer (AnimatedOpacity compositing path)
        AnimatedOpacity(
          opacity: 0.5,
          duration: Duration.zero,
          child: Container(
            width: 40,
            height: 40,
            color: Colors.blue,
          ),
        ),

        // 5. Text glyph atlas for JetBrains Mono & Inter
        const Positioned(
          left: 0,
          top: 0,
          child: Text(
            'Warmup',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Positioned(
          left: 0,
          top: 20,
          child: Text(
            'Warmup',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}
