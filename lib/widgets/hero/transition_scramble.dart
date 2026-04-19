import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Unscrambles text from an initial string to a final string, letter by letter.
/// It uses a RichText canvas to seamlessly transition between two TextStyles.
class TransitionScramble extends StatefulWidget {
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

  final String initialText;
  final String finalText;
  final TextStyle initialStyle;
  final TextStyle finalStyle;
  final Duration duration;
  final VoidCallback? onComplete;
  final bool autoStart;

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

  void start() {
    if (_isComplete || _hasStarted) return;
    _hasStarted = true;
    _elapsedMs = 0;
    _currentIndex = 0;

    const int frameMs = 32; // ~30 fps is good for rapid scrambling
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
        // Locked correctly in the final text and final style
        spans.add(TextSpan(text: widget.finalText[i], style: widget.finalStyle));
      } else if (i == _currentIndex) {
        // Actively scrambling in the final style color (infecting the white text)
        spans.add(TextSpan(text: _getRandomChar(), style: widget.finalStyle));
      } else {
        // Idle initial text in the initial style
        spans.add(TextSpan(text: widget.initialText[i], style: widget.initialStyle));
      }
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }
}
