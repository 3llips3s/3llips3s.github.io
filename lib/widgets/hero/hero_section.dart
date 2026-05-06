import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colors.dart';
import '../../config/project_data.dart';
import 'model_viewer_widget.dart';
import 'text_scramble.dart';
import 'transition_scramble.dart';
import 'terminal_typing.dart';

/// Full-viewport hero section with 3D model and animated intro sequence.
///
/// Animation timeline:
///   Frame 1    → Scramble "3llips3s" (1200 ms)
///   +400 ms    → Fade in "here..." letter-by-letter (no cursor)
///   +300 ms    → Start typing tagline with blinking cursor
///   +500 ms    → Fade-in + scale-up 3D model  &  Fade-in + slide-up CTA
class HeroSection extends StatefulWidget {
  const HeroSection({super.key, this.onSeeMyWork});

  /// Callback to smooth-scroll to the Project Registry.
  final VoidCallback? onSeeMyWork;

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  // ── Animation phase flags ──────────────────────────────────────
  String _hereText = '';
  bool _startTyping = false;
  bool _showFinale = false;
  bool _showFinalName = false;

  final GlobalKey<TerminalTypingState> _typingKey = GlobalKey();
  Timer? _hereTimer;

  @override
  void initState() {
    super.initState();
    _precacheAssets();
  }

  /// Pre-cache 3D model poster for instant load.
  void _precacheAssets() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const AssetImage('assets/images/hoops_poster.webp'),
        context,
      );
    });
  }

  /// Heavy image precaching deferred to avoid jank during entrance animations.
  void _precacheProjectAssets() {
    for (final project in ProjectData.projects) {
      precacheImage(AssetImage(project.screenshotPath), context);
      if (project.galleryImages != null) {
        for (final img in project.galleryImages!) {
          precacheImage(AssetImage(img), context);
        }
      }
    }
  }

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
      // Trigger the CSS-based fade + scale on the model-viewer element.
      ModelViewerWidget.reveal();

      // Stop cursor blinking after assets have settled (approx 2s entrance)
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          _typingKey.currentState?.stopBlinking();
          // Defer heavy project image loading until hero animation is completely finished
          _precacheProjectAssets();
        }
      });
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
      child:
          isMobile
              ? _mobileLayout(isDark, screenSize.height)
              : _desktopLayout(isDark, screenSize.height),
    );
  }

  // ── Desktop: side-by-side ──────────────────────────────────────

  Widget _desktopLayout(bool isDark, double screenHeight) {
    return Column(
      children: [
        const Spacer(flex: 3), // ← equal space above model
        SizedBox(
          height: screenHeight * 0.40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: const ModelViewerWidget(),
          ),
        ),
        const Spacer(flex: 2), // ← equal space below model
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _textContent(isDark, false),
        ),
        const Spacer(flex: 2), // ← equal space below text
        _buildAnimatedCta(isDark),
        const Spacer(flex: 1), // ← breathing room below CTA
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
          const Spacer(flex: 3), // ← equal space above model
          SizedBox(
            height: screenHeight * 0.32,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: const ModelViewerWidget(),
            ),
          ),
          const Spacer(flex: 3), // ← equal space below model
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _textContent(isDark, true),
          ),
          const Spacer(), // ← breathing room below text
        ],
      ),
    );
  }

  // ── Shared text / animation column ─────────────────────────────

  Widget _textContent(bool isDark, bool isMobile) {
    final Color textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final TextStyle monoStyle = TextStyle(fontFamily: 'JetBrainsMono', 
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    );

    final TextStyle hereStyle = TextStyle(fontFamily: 'Inter', 
      fontSize: 28,
      fontWeight: FontWeight.w300,
      color: textSecondary,
    );

    final TextStyle taglineStyle = TextStyle(fontFamily: 'Inter', 
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textSecondary,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      clipBehavior: Clip.none,
      alignment: isMobile ? Alignment.topLeft : Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Step 1 & 2: "3llips3s here..." ──
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Stack pre-allocates the full username width to prevent
              // layout shifts and clipping during the scramble animations.
              Stack(
                children: [
                  Text(
                    '3llips3s',
                    style: monoStyle.copyWith(color: Colors.transparent),
                  ),
                  _showFinalName
                      ? TransitionScramble(
                        key: const ValueKey('final_transition'),
                        initialText: 'G1ch1a_K',
                        finalText: '3llips3s',
                        initialStyle: monoStyle,
                        finalStyle: monoStyle.copyWith(
                          color: AppColors.primary,
                        ),
                        duration: const Duration(milliseconds: 1800),
                        onComplete: _onScrambleComplete,
                      )
                      : TextScramble(
                        key: const ValueKey('easter_egg'),
                        text: 'G1ch1a_K',
                        duration: const Duration(milliseconds: 600),
                        style: monoStyle,
                        onComplete: () {
                          // Pause briefly on the easter egg, then sweep to the final public name
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (mounted) setState(() => _showFinalName = true);
                          });
                        },
                      ),
                ],
              ),
              const SizedBox(width: 12),
              Stack(
                children: [
                  // Invisible full text to establish final layout width immediately
                  Text(
                    'here...',
                    style: hereStyle.copyWith(color: Colors.transparent),
                  ),
                  Text(_hereText, style: hereStyle),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Step 3: Terminal typing (flush-left with username) ──
          AnimatedOpacity(
            opacity: _startTyping ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: isMobile ? Alignment.centerLeft : Alignment.center,
              child: TerminalTyping(
                key: _typingKey,
                text: 'I build mobile & web apps @ Studio 10200',
                charDelay: const Duration(milliseconds: 60),
                style: taglineStyle,
                cursorColor: AppColors.primary,
                onComplete: _onTypingComplete,
                autoStart: false,
                finalCursorOpacity: isMobile ? 0.0 : 0.75,
              ),
            ),
          ),

          if (isMobile) ...[
            const SizedBox(height: 120),
            // ── Step 4: "See My Work" CTA (Fade In + Slide Up) ──
            _buildAnimatedCta(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedCta(bool isDark) {
    final Color textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    return AnimatedSlide(
      offset: _showFinale ? Offset.zero : const Offset(0, 0.5),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _showFinale ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 600),
        child: Center(child: _seeMyWorkCta(isDark, textPrimary)),
      ),
    );
  }

  // ── "See My Work" CTA — borderless text + pulsing arrow ────────

  Widget _seeMyWorkCta(bool isDark, Color textColor) {
    return GestureDetector(
      onTap: widget.onSeeMyWork,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Static text — no animation
            Text(
              'see my work',
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            // Pulsing arrow — continuous opacity 0.4 → 1.0
            Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 48,
                  color: AppColors.primaryLight,
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .fade(
                  begin: 0.4,
                  end: 1.0,
                  duration: 1200.ms,
                  curve: Curves.easeInOut,
                ),
          ],
        ),
      ),
    );
  }
}
