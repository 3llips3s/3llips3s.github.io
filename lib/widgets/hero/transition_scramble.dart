import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// A widget that unscrambles text from an initial string to a final string.
///
/// Utilizes [Text.rich] to transition between two strings and their respective 
/// [TextStyle]s character-by-character, creating a "morphing" effect.
class TransitionScramble extends StatefulWidget {
  /// The starting text string.
  final String initialText;

  /// The target text string to be revealed.
  final String finalText;

  /// The style to apply to the initial text.
  final TextStyle initialStyle;

  /// The style to apply to the final text.
  final TextStyle finalStyle;

  /// The total duration of the transition.
  final Duration duration;

  /// Optional callback invoked when the transition finishes.
  final VoidCallback? onComplete;

  /// Whether to start the animation automatically upon initialization.
  final bool autoStart;

  const TransitionScramble({
    super.key,
    required this.initialText,
    required this.finalText,
    required this.initialStyle,
    required this.finalStyle,
    this.duration = const Duration(milliseconds: 1200),
    this.onComplete,
    this.autoStart = true,
  }) : assert(initialText.length == finalText.length,
            'initialText and finalText must be the same length');

  @override
  State<TransitionScramble> createState() => _TransitionScrambleState();
}

class _TransitionScrambleState extends State<TransitionScramble> {
  static const String _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789aceminorsuvwxz!@#\$%^&*-_+=<>';

  final Random _random = Random();
  Timer? _timer;
  bool _isComplete = false;
  bool _hasStarted = false;
  int _elapsedMs = 0;
  
  // Which index is currently actively scrambling
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => start());
    }
  }

  /// Begins the character-by-character transition animation.
  void start() {
    if (_isComplete || _hasStarted) return;
    _hasStarted = true;
    _elapsedMs = 0;
    _currentIndex = 0;

    const int frameMs = 32;
    final int charDurationMs = widget.duration.inMilliseconds ~/ widget.finalText.length;

    _timer = Timer.periodic(const Duration(milliseconds: frameMs), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      
      setState(() {
        _elapsedMs += frameMs;
        _currentIndex = (_elapsedMs ~/ charDurationMs).clamp(0, widget.finalText.length - 1);

        if (_elapsedMs >= widget.duration.inMilliseconds) {
          _timer?.cancel();
          _isComplete = true;
          _currentIndex = widget.finalText.length; // Ensure everything locks
          widget.onComplete?.call();
        }
      });
    });
  }

  int _randomCharCode() => _chars.codeUnitAt(_random.nextInt(_chars.length));
  
  String _getRandomChar() => String.fromCharCode(_randomCharCode());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasStarted) {
      return Text(widget.initialText, style: widget.initialStyle);
    }
    
    if (_isComplete) {
      return Text(widget.finalText, style: widget.finalStyle);
    }

    final List<TextSpan> spans = [];

    for (int i = 0; i < widget.finalText.length; i++) {
      if (i < _currentIndex) {
        spans.add(TextSpan(text: widget.finalText[i], style: widget.finalStyle));
      } else if (i == _currentIndex) {
        spans.add(TextSpan(text: _getRandomChar(), style: widget.finalStyle));
      } else {
        spans.add(TextSpan(text: widget.initialText[i], style: widget.initialStyle));
      }
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }
}
