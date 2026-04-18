import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';

class TerminalCTA extends StatefulWidget {
  final bool visible;

  const TerminalCTA({super.key, required this.visible});

  @override
  State<TerminalCTA> createState() => _TerminalCTAState();
}

class _TerminalCTAState extends State<TerminalCTA> {
  bool _isHovered = false;

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/3llips3s');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch \$url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    // Bloom styling
    final List<Shadow> textShadows =
        _isHovered
            ? [const Shadow(color: AppColors.primary, blurRadius: 12)]
            : [];

    final Color underlineColor =
        _isHovered
            ? AppColors.primaryLight
            : AppColors.primary.withValues(alpha: 0.8);
    final List<BoxShadow> underlineShadows =
        _isHovered
            ? [
              const BoxShadow(
                color: AppColors.primary,
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ]
            : [];

    return AnimatedOpacity(
      opacity: widget.visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: _launchGitHub,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Icon & Username (Slides up 16px) ──
                Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -1), // Optical baseline nudge
                          child: Image.asset(
                            'assets/images/github_icon.png',
                            width: 20,
                            height: 20,
                            color: textColor,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.code,
                                  color: textColor,
                                  size: 18,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/3llips3s',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            shadows: textShadows,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                    .animate(target: widget.visible ? 1 : 0)
                    .moveY(
                      begin: 16,
                      end: 0,
                      duration: 1000.ms,
                      delay: 400.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(duration: 1000.ms, delay: 400.ms),

                const SizedBox(height: 4),

                // ── Underline (Slides in from left) ──
                Container(
                      width: 118, // Exact flush baseline for JetBrainsMono+Icon
                      height: 1,
                      decoration: BoxDecoration(
                        color: underlineColor,
                        boxShadow: underlineShadows,
                      ),
                    )
                    .animate(target: widget.visible ? 1 : 0)
                    .moveX(
                      begin: -118,
                      end: 0,
                      duration: 1000.ms,
                      delay: 1400.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(duration: 1000.ms, delay: 1400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
