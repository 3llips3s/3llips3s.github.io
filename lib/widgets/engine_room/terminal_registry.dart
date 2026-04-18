import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../config/app_colors.dart';
import 'terminal_quadrant.dart';
import 'terminal_cta.dart';

class QuadrantData {
  final String command;
  final String output;
  QuadrantData(this.command, this.output);
}

final List<QuadrantData> _registryData = [
  QuadrantData('ls core', 'Dart, Flutter, Flutter Flame'),
  QuadrantData('ls state', 'setState, Provider, Riverpod'),
  QuadrantData('ls data', 'Hive_CE, Shared_Preferences, PostgreSQL (Supabase)'),
  QuadrantData('ls ops', 'Git, GitHub, Wiredash'),
];

/// The Engine Room replacement. A zero-frame terminal system report.
class TerminalRegistry extends StatefulWidget {
  const TerminalRegistry({super.key});

  @override
  State<TerminalRegistry> createState() => _TerminalRegistryState();
}

class _TerminalRegistryState extends State<TerminalRegistry> {
  bool _hasTriggered = false;
  bool _showCTA = false;
  late List<QuadrantState> _quadrantStates;

  @override
  void initState() {
    super.initState();
    _quadrantStates = List.filled(_registryData.length, QuadrantState.idle);
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_hasTriggered && info.visibleFraction > 0.3) {
      _hasTriggered = true;
      _startSequence();
    }
  }

  void _startSequence() {
    if (!mounted) return;
    setState(() {
      _quadrantStates[0] = QuadrantState.typing;
    });
  }

  void _onCommandComplete(int index) {
    if (!mounted) return;
    setState(() {
      _quadrantStates[index] = QuadrantState.scrambling;
    });
  }

  void _onOutputComplete(int index) {
    if (!mounted) return;
    setState(() {
      _quadrantStates[index] = QuadrantState.bloomed;
    });

    // Hold the bloom for a short beat, then dim and move to next
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _quadrantStates[index] = QuadrantState.settled;
        if (index + 1 < _registryData.length) {
          _quadrantStates[index + 1] = QuadrantState.typing;
        } else {
          // All quadrants complete
          _showCTA = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;

    return VisibilityDetector(
      key: const ValueKey('TerminalRegistryView'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 120,
          bottom: 80,
          left: isMobile ? 32 : 64,
          right: isMobile ? 32 : 64,
        ),
        // No background or border. The canvas is the natural scaffold color.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (Left Aligned) ──
            Text(
              '[ S T A C K ]',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary.withValues(alpha: 0.6),
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 64),

            // ── Grid Layout ──
            if (isMobile) _buildMobileLayout() else _buildDesktopLayout(),

            const SizedBox(height: 40),

            // ── GitHub CTA Finish ──
            Center(child: TerminalCTA(visible: _showCTA)),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildQuadrant(0)),
            const SizedBox(width: 32),
            Expanded(child: _buildQuadrant(1)),
          ],
        ),
        const SizedBox(height: 48),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildQuadrant(2)),
            const SizedBox(width: 32),
            Expanded(child: _buildQuadrant(3)),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_registryData.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: _buildQuadrant(index),
        );
      }),
    );
  }

  Widget _buildQuadrant(int index) {
    final data = _registryData[index];
    return TerminalQuadrant(
      command: data.command,
      output: data.output,
      state: _quadrantStates[index],
      onCommandComplete: () => _onCommandComplete(index),
      onOutputComplete: () => _onOutputComplete(index),
    );
  }
}
