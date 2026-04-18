import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../hero/terminal_typing.dart';
import '../hero/text_scramble.dart';

enum QuadrantState { idle, typing, scrambling, bloomed, settled }

class TerminalQuadrant extends StatefulWidget {
  final String command;
  final String output;
  final QuadrantState state;
  final VoidCallback onCommandComplete;
  final VoidCallback onOutputComplete;

  const TerminalQuadrant({
    super.key,
    required this.command,
    required this.output,
    required this.state,
    required this.onCommandComplete,
    required this.onOutputComplete,
  });

  @override
  State<TerminalQuadrant> createState() => _TerminalQuadrantState();
}

class _TerminalQuadrantState extends State<TerminalQuadrant> {

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Derived colors
    final Color basePrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color dimmedColor = basePrimary.withValues(alpha: 0.6); // Steady state
    
    // Command Colors (Deep Purple)
    final Color commandColor = AppColors.primary;
    final Color ghostPromptColor = AppColors.primary.withValues(alpha: 0.5);

    // Current active color based on state for standard output text
    Color currentOutputColor = basePrimary.withValues(alpha: 0.2); // ghost
    if (widget.state == QuadrantState.typing || widget.state == QuadrantState.scrambling || widget.state == QuadrantState.bloomed) {
      currentOutputColor = basePrimary; // vibrant
    } else if (widget.state == QuadrantState.settled) {
      currentOutputColor = dimmedColor;
    }

    // Styles
    final TextStyle baseStyle = GoogleFonts.jetBrainsMono(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: currentOutputColor,
    );

    final TextStyle promptStyle = GoogleFonts.jetBrainsMono(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ghostPromptColor,
    );
    
    // Bloom text shadow
    final List<Shadow> textShadows = widget.state == QuadrantState.bloomed
        ? [const Shadow(color: AppColors.primary, blurRadius: 12)]
        : [];

    final TextStyle bloomingOutputStyle = baseStyle.copyWith(shadows: textShadows);
    final TextStyle bloomingCommandStyle = GoogleFonts.jetBrainsMono(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: commandColor,
      shadows: textShadows,
    );

    final bool showCursorLine1 = widget.state == QuadrantState.idle || widget.state == QuadrantState.typing;
    final bool showCursorLine2 = widget.state == QuadrantState.scrambling || widget.state == QuadrantState.bloomed;

    final List<String> techItems = widget.output.split(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Line 1: Prompt & Command ──
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('\$ ', style: promptStyle),
            if (widget.state != QuadrantState.idle)
              TerminalTyping(
                text: widget.command,
                style: bloomingCommandStyle,
                charDelay: const Duration(milliseconds: 80), // Slower typing
                cursorChar: '_',
                cursorColor: showCursorLine1 ? commandColor : Colors.transparent,
                autoStart: true,
                onComplete: widget.onCommandComplete,
              )
            else
              _BlinkingCursor(color: ghostPromptColor, active: showCursorLine1),
          ],
        ),

        const SizedBox(height: 4),

        // ── Line 2+: Output & Scramble (Stacked) ──
        if (widget.state.index >= QuadrantState.scrambling.index)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(techItems.length, (index) {
              final isLast = index == techItems.length - 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('· ', style: promptStyle),
                    TextScramble(
                      text: techItems[index],
                      style: bloomingOutputStyle,
                      duration: const Duration(milliseconds: 600), // Slower scramble
                      autoStart: true,
                      onComplete: index == 0 ? widget.onOutputComplete : null,
                    ),
                    if (showCursorLine2 && isLast)
                      _BlinkingCursor(color: currentOutputColor, active: true),
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;
  final bool active;
  
  const _BlinkingCursor({required this.color, required this.active});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 530));
    if (widget.active) _anim.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_BlinkingCursor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _anim.repeat(reverse: true);
    } else if (!widget.active && oldWidget.active) {
      _anim.stop();
      _anim.value = 0; // Hide
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _anim,
      child: Text('_', style: GoogleFonts.jetBrainsMono(color: widget.color, fontSize: 16)),
    );
  }
}
