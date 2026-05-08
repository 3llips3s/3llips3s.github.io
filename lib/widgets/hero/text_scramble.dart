import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// A widget that animates text using a character-by-character scramble effect.
///
/// Transitions each character through a random scramble and a flicker phase 
/// before locking onto the final value, creating a "decryption" aesthetic.
class TextScramble extends StatefulWidget {
  /// The final text string to be revealed.
  final String text;

  /// The total duration of the scramble animation.
  final Duration duration;

  /// The style to apply to the text.
  final TextStyle? style;

  /// Optional callback invoked when the scramble animation finishes.
  final VoidCallback? onComplete;

  /// Whether to start the animation automatically upon initialization.
  final bool autoStart;

  const TextScramble({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 1200),
    this.style,
    this.onComplete,
    this.autoStart = true,
  });

  @override
  State<TextScramble> createState() => TextScrambleState();
}

class TextScrambleState extends State<TextScramble> {
  static const String _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789aceminorsuvwxz!@#\$%^&*-_+=<>';

  final Random _random = Random();
  late String _displayed;
  Timer? _timer;
  bool _isComplete = false;
  bool _hasStarted = false;
  late final List<int> _lockTimeMs;
  int _elapsedMs = 0;

  static const int _settleMs = 180;
  static const int _pureScrambleMs = 300;

  @override
  void initState() {
    super.initState();
    _displayed = widget.text;

    final int totalMs = widget.duration.inMilliseconds;
    final int lockPhaseMs = totalMs - _pureScrambleMs;
    _lockTimeMs = List.generate(widget.text.length, (i) {
      return _pureScrambleMs +
          ((i + 1) / widget.text.length * lockPhaseMs).round();
    });

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => start());
    }
  }

  /// Begins the character-by-character scramble animation.
  void start() {
    if (_isComplete || _hasStarted) return;
    _hasStarted = true;
    _elapsedMs = 0;
    _displayed = String.fromCharCodes(
      List.generate(widget.text.length, (_) => _randomCharCode()),
    );

    const int frameMs = 16;
    _timer = Timer.periodic(const Duration(milliseconds: frameMs), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      _elapsedMs += frameMs;

      final buf = StringBuffer();
      bool allLocked = true;

      for (int i = 0; i < widget.text.length; i++) {
        final int lockTime = _lockTimeMs[i];

        if (_elapsedMs >= lockTime) {
          buf.writeCharCode(widget.text.codeUnitAt(i));
        } else if (_elapsedMs >= lockTime - _settleMs) {
          final double progress =
              (_elapsedMs - (lockTime - _settleMs)) / _settleMs;
          if (_random.nextDouble() < progress) {
            buf.writeCharCode(widget.text.codeUnitAt(i));
          } else {
            buf.writeCharCode(_randomCharCode());
          }
          allLocked = false;
        } else {
          buf.writeCharCode(_randomCharCode());
          allLocked = false;
        }
      }

      setState(() => _displayed = buf.toString());

      if (allLocked) {
        _timer?.cancel();
        _isComplete = true;
        widget.onComplete?.call();
      }
    });

    setState(() {});
  }

  int _randomCharCode() => _chars.codeUnitAt(_random.nextInt(_chars.length));

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? Theme.of(context).textTheme.displayMedium;

    return AnimatedOpacity(
      opacity: _hasStarted ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Text(
        _hasStarted ? _displayed : widget.text,
        style: style,
      ),
    );
  }
}
