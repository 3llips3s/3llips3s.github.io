import 'dart:async';
import 'package:flutter/material.dart';

/// A widget that simulates terminal typing by rendering text character-by-character.
///
/// Provides a customizable blinking cursor and supports both automatic and 
/// manual animation triggers.
class TerminalTyping extends StatefulWidget {
  /// The text string to be typed out.
  final String text;

  /// The delay between each character being rendered.
  final Duration charDelay;

  /// The style to apply to the typed text and cursor.
  final TextStyle? style;

  /// The color of the blinking cursor.
  final Color? cursorColor;

  /// The character to use as the cursor.
  final String cursorChar;

  /// Optional callback invoked when the typing animation finishes.
  final VoidCallback? onComplete;

  /// Whether to start the animation automatically upon initialization.
  final bool autoStart;

  /// The opacity of the cursor after the animation is stopped or finished.
  final double finalCursorOpacity;

  const TerminalTyping({
    super.key,
    required this.text,
    this.charDelay = const Duration(milliseconds: 45),
    this.style,
    this.cursorColor,
    this.cursorChar = '▌',
    this.onComplete,
    this.autoStart = true,
    this.finalCursorOpacity = 0.0,
  });

  @override
  State<TerminalTyping> createState() => TerminalTypingState();
}

class TerminalTypingState extends State<TerminalTyping>
    with SingleTickerProviderStateMixin {
  int _charIndex = 0;
  Timer? _typingTimer;
  late AnimationController _cursorBlink;
  bool _isComplete = false;
  bool _isStarted = false;
  bool _hideCursor = false;

  @override
  void initState() {
    super.initState();
    _cursorBlink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => start());
    }
  }

  /// Begins the character-by-character typing animation.
  void start() {
    if (_isComplete || _isStarted) return;
    _isStarted = true;
    _typingTimer = Timer.periodic(widget.charDelay, (_) {
      if (!mounted) {
        _typingTimer?.cancel();
        return;
      }
      if (_charIndex < widget.text.length) {
        setState(() => _charIndex++);
      } else {
        _typingTimer?.cancel();
        _isComplete = true;
        widget.onComplete?.call();
      }
    });
  }

  /// Stops the cursor blinking and applies [TerminalTyping.finalCursorOpacity].
  void stopBlinking() {
    _cursorBlink.stop();
    setState(() {
      _hideCursor = true;
      _isComplete = true; // Ensure logic treats it as finished
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorBlink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        widget.style ?? Theme.of(context).textTheme.bodyLarge!;

    final String displayed = widget.text.substring(0, _charIndex);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: displayed, style: style),
          // Blinking cursor (maintains space, can remain partially visible)
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Opacity(
              opacity: _hideCursor ? widget.finalCursorOpacity : 1.0,
              child: FadeTransition(
                opacity: _cursorBlink,
                child: Text(
                  widget.cursorChar,
                  style: style.copyWith(
                    color: widget.cursorColor ??
                        Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
