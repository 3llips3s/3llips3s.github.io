import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// A custom animated icon that morphs between a modern hamburger menu and a close (X) icon.
///
/// Uses a [CustomPainter] to directly manipulate line positions, rotations, and opacities
/// based on an internal animation controller. This provides the most performant and
/// exact transition possible without relying on deeply nested standard widgets.
class CustomAnimatedMenuIcon extends StatefulWidget {
  /// Whether the menu is currently in the "open" (X) state.
  final bool isOpen;

  /// Callback when the icon is tapped.
  final VoidCallback onTap;

  /// The total bounding box size of the icon (hit target size).
  final double size;

  /// The color of the strokes.
  final Color color;

  const CustomAnimatedMenuIcon({
    super.key,
    required this.isOpen,
    required this.onTap,
    this.size = 48.0,
    this.color = AppColors.primary,
  });

  @override
  State<CustomAnimatedMenuIcon> createState() => _CustomAnimatedMenuIconState();
}

class _CustomAnimatedMenuIconState extends State<CustomAnimatedMenuIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.isOpen) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomAnimatedMenuIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _MenuIconPainter(
                  animationValue: Curves.easeInOut.transform(_controller.value),
                  color: widget.color,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuIconPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _MenuIconPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // The stroke thickness scales with the overall size.
    final double strokeWidth = size.width * 0.05;
    final Paint paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    // The actual visible lines span 60% of the bounding box to leave internal padding.
    final double width = size.width * 0.55;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Vertical distance from center for the top and bottom lines in hamburger state.
    final double lineSpacing = width * 0.35;

    final double lineLength = width;
    final double middleLineLength =
        width * 0.6; // Middle line is 60% of the full width

    // --- Top Line ---
    canvas.save();
    final double topOffset = -lineSpacing;
    final double topDy = topOffset * (1.0 - animationValue);
    final double topRotation = (math.pi / 4) * animationValue;

    // Translate to the dynamic center, rotate, and draw relative to that origin.
    canvas.translate(center.dx, center.dy + topDy);
    canvas.rotate(topRotation);
    canvas.drawLine(
      Offset(-lineLength / 2, 0),
      Offset(lineLength / 2, 0),
      paint,
    );
    canvas.restore();

    // --- Middle Line ---
    if (animationValue < 1.0) {
      final Paint middlePaint =
          Paint()
            ..color = color.withValues(alpha: color.a * (1.0 - animationValue))
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;

      // Shrink slightly as it fades out
      final double currentMiddleLength =
          middleLineLength * (1.0 - (animationValue * 0.2));

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.drawLine(
        Offset(-currentMiddleLength / 2, 0),
        Offset(currentMiddleLength / 2, 0),
        middlePaint,
      );
      canvas.restore();
    }

    // --- Bottom Line ---
    canvas.save();
    final double bottomOffset = lineSpacing;
    final double bottomDy = bottomOffset * (1.0 - animationValue);
    final double bottomRotation = -(math.pi / 4) * animationValue;

    canvas.translate(center.dx, center.dy + bottomDy);
    canvas.rotate(bottomRotation);
    canvas.drawLine(
      Offset(-lineLength / 2, 0),
      Offset(lineLength / 2, 0),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MenuIconPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        color != oldDelegate.color;
  }
}
