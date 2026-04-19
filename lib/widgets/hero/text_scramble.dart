import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Animates text using a character-by-character scramble effect.
///
/// Each character goes through three phases:
///   1. **Scramble** — fully random characters
///   2. **Settle** — flickers between random and final value
///   3. **Lock** — shows the final character permanently
///
/// This creates a smooth left-to-right "decryption" feel.
class TextScramble extends StatefulWidget {
  const TextScramble({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 1200),
    this.style,
    this.onComplete,
    this.autoStart = true,
  });

  final String text;
  final Duration duration;
  final TextStyle? style;
  final VoidCallback? onComplete;
  final bool autoStart;

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

  // How long before lock each character starts "settling"
  // (flickering between random and final).
  static const int _settleMs = 180;
  // Pure scramble phase before any character starts settling.
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
          // ── Phase 3: Locked ──
          buf.writeCharCode(widget.text.codeUnitAt(i));
        } else if (_elapsedMs >= lockTime - _settleMs) {
          // ── Phase 2: Settling ──
          // Increasing probability of showing the final character.
          final double progress =
              (_elapsedMs - (lockTime - _settleMs)) / _settleMs;
          if (_random.nextDouble() < progress) {
            buf.writeCharCode(widget.text.codeUnitAt(i));
          } else {
            buf.writeCharCode(_randomCharCode());
          }
          allLocked = false;
        } else {
          // ── Phase 1: Pure scramble ──
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
