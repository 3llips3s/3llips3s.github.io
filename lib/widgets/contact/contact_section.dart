import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../config/app_colors.dart';
import '../../services/analytics_service.dart';
import '../../utils/url_launcher_helper.dart';

class ContactSection extends StatefulWidget {
  final bool isTerminalComplete;
  final VoidCallback? onAnimationComplete;

  const ContactSection({
    super.key,
    required this.isTerminalComplete,
    this.onAnimationComplete,
  });

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  bool _isVisible = false;
  bool _hasFiredComplete = false;

  final String _contactText = "Do you have an idea? Let's build it :)";
  final String _emailAddress = 'contact@studio10200.dev';

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final words = _contactText.split(' ');
    final bool shouldAnimate = _isVisible && widget.isTerminalComplete;

    // Fire the completion callback once after the full animation sequence
    if (shouldAnimate && !_hasFiredComplete) {
      _hasFiredComplete = true;
      // Total: words(9) × 200ms stagger + 800ms breathing + 1000ms button slide
      // Added +1000ms extra delay for breathing room before the footer arrow fades in.
      final totalMs = words.length * 200 + 800 + 1000 + 1000;
      Future.delayed(Duration(milliseconds: totalMs), () {
        widget.onAnimationComplete?.call();
      });
    }

    return VisibilityDetector(
      key: const ValueKey('ContactSectionView'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 80, // Match TerminalRegistry spacing exactly
          bottom: 120, // Ample padding before the absolute footer
          left: isMobile ? 32 : 64,
          right: isMobile ? 32 : 64,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (Matching others identically) ──
            Text(
              'H E L L O',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 80),

            // ── Body & Actions ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Words (Left to Right Sequence)
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 6,
                  runSpacing: 8,
                  children: List.generate(words.length, (index) {
                    return Text(
                          words[index],
                          style: GoogleFonts.inter(
                            fontSize:
                                isMobile
                                    ? 18
                                    : 24, // Smaller text fitting mostly on one line
                            fontWeight: FontWeight.w400,
                            color: textColor.withValues(
                              alpha: 0.7,
                            ), // Muted color structurally
                            height: 1.4,
                          ),
                        )
                        .animate(target: shouldAnimate ? 1 : 0)
                        .fadeIn(
                          duration: 800.ms, // Slowed down
                          delay: Duration(
                            milliseconds: index * 200,
                          ), // Larger stagger
                          curve: Curves.easeOut,
                        )
                        .moveX(
                          begin: -20,
                          end: 0,
                          duration: 800.ms,
                          delay: Duration(milliseconds: index * 200),
                        );
                  }),
                ),

                const SizedBox(
                  height: 80,
                ), // Extended explicit breathing room below words
                // Actions Group (Centered Below Text explicitly overcoming flush-left parent)
                Align(
                  alignment: Alignment.center,
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Spacer perfectly balances the 56px Copy Button + 16px Padding ensuring the Email button itself sits dead center on the screen.
                          const SizedBox(width: 72),

                          // Primary Action: Email
                          ElevatedButton(
                            onPressed: () {
                              AnalyticsService.instance.logEvent(
                                name: 'external_intent',
                                interactionType: 'email_start',
                              );
                              UrlLauncherHelper.openUrl(
                                'mailto:$_emailAddress',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor:
                                  isDark
                                      ? AppColors.darkScaffold
                                      : AppColors.lightScaffold,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mail_rounded,
                                  size: 20,
                                  color:
                                      isDark
                                          ? AppColors.darkScaffold
                                          : AppColors.lightScaffold,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'email me',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    height: 1.0,
                                    color:
                                        isDark
                                            ? AppColors.darkScaffold
                                            : AppColors.lightScaffold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Secondary Action: Copy (Icon Only completely boundaryless)
                          Tooltip(
                            message: 'Copy Email',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: _emailAddress),
                                  );
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(
                                    context,
                                  ).clearSnackBars();
                                  final topMargin =
                                      MediaQuery.sizeOf(context).height - 90;
                                  final washedPurple =
                                      Color.lerp(
                                        AppColors.primary,
                                        Colors.white,
                                        0.4,
                                      )!;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check_rounded,
                                            color: Colors.black87,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Email copied to clipboard!",
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: washedPurple.withValues(
                                        alpha: 0.95,
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      margin: EdgeInsets.only(
                                        bottom: topMargin > 0 ? topMargin : 24,
                                        left: 24,
                                        right: 24,
                                      ),
                                      elevation: 8,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(40),
                                splashColor: AppColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                hoverColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon(
                                    Icons.copy_rounded,
                                    size: 24,
                                    color: textColor.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate(target: shouldAnimate ? 1 : 0)
                      // Slides right-to-left strictly after the final word animation locks in (with 800ms breathing delay)
                      .moveX(
                        begin: 40,
                        end: 0,
                        duration: 1000.ms,
                        delay: Duration(milliseconds: words.length * 200 + 800),
                        curve: Curves.easeOutCubic,
                      )
                      .fadeIn(
                        duration: 1000.ms,
                        delay: Duration(milliseconds: words.length * 200 + 800),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
