import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';
import 'model_viewer_widget.dart';
import 'text_scramble.dart';
import 'terminal_typing.dart';

/// Full-viewport hero section with 3D model and animated intro sequence.
///
/// Animation timeline:
///   Frame 1    → Scramble "3llips3s" (800 ms)
///   +400 ms    → Type out "here..." letter-by-letter (no cursor)
///   +300 ms    → Start typing tagline with blinking cursor
///   +done      → Slide in GitHub CTA + reveal 3D model simultaneously
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  // ── Animation phase flags ──────────────────────────────────────
  String _hereText = '';
  bool _startTyping = false;
  bool _showFinale = false;

  final GlobalKey<TerminalTypingState> _typingKey = GlobalKey();
  Timer? _hereTimer;

  // ── Sequence callbacks ─────────────────────────────────────────

  void _onScrambleComplete() {
    const hereTarget = 'here...';
    int index = 0;

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _hereTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (index < hereTarget.length) {
          setState(() {
            index++;
            _hereText = hereTarget.substring(0, index);
          });
        } else {
          timer.cancel();
          _onHereComplete();
        }
      });
    });
  }

  void _onHereComplete() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _startTyping = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _typingKey.currentState?.start();
      });
    });
  }

  void _onTypingComplete() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _showFinale = true);
      // Trigger the CSS-based smooth slide-down on the model-viewer element.
      ModelViewerWidget.reveal();
    });
  }

  @override
  void dispose() {
    _hereTimer?.cancel();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isMobile = screenSize.width < 768;

    return SizedBox(
      width: double.infinity,
      height: screenSize.height,
      child: isMobile
          ? _mobileLayout(isDark, screenSize.height)
          : _desktopLayout(isDark),
    );
  }

  // ── Desktop: side-by-side ──────────────────────────────────────

  Widget _desktopLayout(bool isDark) {
    return Row(
      children: [
        // Text column
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(left: 64, right: 32),
            child: _textContent(isDark),
          ),
        ),
        // 3D model column — revealed via CSS transition
        const Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: ModelViewerWidget(),
          ),
        ),
      ],
    );
  }

  // ── Mobile: stacked ────────────────────────────────────────────
  //
  // Two equal Spacers above and below the model guarantee that the
  // model always has the same gap to the address bar as to the text.

  Widget _mobileLayout(bool isDark, double screenHeight) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(), // ← equal space above model
          SizedBox(
            height: screenHeight * 0.32,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: const ModelViewerWidget(),
            ),
          ),
          const Spacer(), // ← equal space below model
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _textContent(isDark),
          ),
          const Spacer(), // ← breathing room below text
        ],
      ),
    );
  }

  // ── Shared text / animation column ─────────────────────────────

  Widget _textContent(bool isDark) {
    final Color textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final TextStyle monoStyle = GoogleFonts.jetBrainsMono(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    );

    final TextStyle hereStyle = GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w300,
      color: textSecondary,
    );

    final TextStyle taglineStyle = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textSecondary,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Step 1 & 2: "3llips3s here..." ──
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              TextScramble(
                text: '3llips3s',
                duration: const Duration(milliseconds: 1200),
                style: monoStyle,
                onComplete: _onScrambleComplete,
              ),
              const SizedBox(width: 12),
              Text(_hereText, style: hereStyle),
            ],
          ),

          const SizedBox(height: 24),

          // ── Step 3: Terminal typing (flush-left with username) ──
          AnimatedOpacity(
            opacity: _startTyping ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: TerminalTyping(
              key: _typingKey,
              text: 'I build mobile & web apps @ Studio 10200',
              charDelay: const Duration(milliseconds: 60),
              style: taglineStyle,
              cursorColor: AppColors.primary,
              onComplete: _onTypingComplete,
              autoStart: false,
            ),
          ),

          const SizedBox(height: 40),

          // ── Step 4: GitHub CTA (centred) ──
          AnimatedSlide(
            offset: _showFinale ? Offset.zero : const Offset(0, 0.5),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: _showFinale ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              child: Center(child: _githubButton(isDark, textPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  // ── GitHub CTA button ──────────────────────────────────────────

  Widget _githubButton(bool isDark, Color textColor) {
    return OutlinedButton.icon(
      onPressed:
          () => launchUrl(
            Uri.parse('https://github.com/3llips3s'),
            mode: LaunchMode.externalApplication,
          ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Image.asset(
        'assets/images/github_icon.png',
        width: 20,
        height: 20,
        color: isDark ? Colors.white : Colors.black,
      ),
      label: Text(
        'GitHub',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
