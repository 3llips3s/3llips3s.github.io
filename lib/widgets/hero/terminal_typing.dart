import 'dart:async';
import 'package:flutter/material.dart';

/// Types out text character-by-character with a blinking cursor.
class TerminalTyping extends StatefulWidget {
  const TerminalTyping({
    super.key,
    required this.text,
    this.charDelay = const Duration(milliseconds: 45),
    this.style,
    this.cursorColor,
    this.cursorChar = '▌',
    this.onComplete,
    this.autoStart = true,
  });

  final String text;
  final Duration charDelay;
  final TextStyle? style;
  final Color? cursorColor;
  final String cursorChar;
  final VoidCallback? onComplete;
  final bool autoStart;

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

  /// Public method so the parent can trigger typing manually.
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

  /// Stops the cursor blinking and hides it.
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
          // Blinking cursor (hidden if stopBlinking called)
          if (!_hideCursor)
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
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
        ],
      ),
    );
  }
}
