import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/project_data.dart';
import '../../services/analytics_service.dart';
import '../../utils/local_storage_helper.dart';
import '../../utils/share_helper.dart';
import '../../utils/url_launcher_helper.dart';
import '../feedback/feedback_dialog.dart';

/// A card that displays detailed information about a portfolio project.
///
/// Features a side-by-side layout optimized for portrait screenshots. Includes
/// a title, description, primary actions (e.g., open, download), and secondary
/// actions (e.g., share, feedback).
class ProjectCard extends StatelessWidget {
  /// The project metadata to be displayed in the card.
  final ProjectInfo project;

  /// Whether the screenshot should be positioned on the left side of the card.
  final bool imageOnLeft;

  const ProjectCard({
    super.key,
    required this.project,
    required this.imageOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;
    final Color textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final imageCol = Expanded(
      flex: isMobile ? 40 : 35,
      child: _screenshotColumn(context, textSecondary),
    );

    final textCol = Expanded(
      flex: isMobile ? 60 : 65,
      child: _content(context, isDark, isMobile),
    );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 48,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.only(
            top: isMobile ? 16 : 28,
            bottom: isMobile ? 24 : 32,
            left: isMobile ? 16 : 32,
            right: isMobile ? 16 : 32,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  imageOnLeft
                      ? [
                        imageCol,
                        SizedBox(width: isMobile ? 16 : 32), // Direct gap
                        textCol,
                      ]
                      : [
                        textCol,
                        SizedBox(width: isMobile ? 16 : 32),
                        imageCol,
                      ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _screenshotColumn(BuildContext context, Color textSecondary) {
    final int imageCount = 1 + (project.galleryImages?.length ?? 0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.zoomIn,
          child: GestureDetector(
            onTap: () => _openLightbox(context),
            child: Hero(
              tag: project.screenshotPath,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  project.screenshotPath,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (_, __, ___) => Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.darkTextSecondary,
                          size: 48,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
        if (imageCount > 0) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imageCount, (index) {
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      index == 0
                          ? AppColors.primary
                          : textSecondary.withValues(alpha: 0.3),
                ),
              );
            }),
          ),
        ],
        const SizedBox(height: 16),
        _secondaryActions(context, textSecondary),
      ],
    );
  }

  Widget _content(BuildContext context, bool isDark, bool isMobile) {
    final Color textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          project.name,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.description,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.w400,
                color: textPrimary,
                height: 1.5,
              ),
            ),
            if (project.secondaryText != null) ...[
              SizedBox(height: isMobile ? 8 : 16),
              Text(
                project.secondaryText!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w400,
                  color:
                      isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 16),
        _primaryActions(context, isDark, isMobile),
      ],
    );
  }

  Widget _primaryActions(BuildContext context, bool isDark, bool isMobile) {
    final bool hasPlay = project.webUrl != null;
    final bool hasDownload = project.apkUrl != null;

    final List<Widget> buttons = [];

    if (hasDownload) {
      buttons.add(
        _actionButton(
          label: 'Download',
          icon: Icons.android,
          onPressed: () => _handleApkDownload(context, project.apkUrl!, isDark),
          filled: false,
          isDark: isDark,
          isMobile: isMobile,
        ),
      );
    }

    if (hasPlay) {
      buttons.add(
        _actionButton(
          label: project.primaryActionLabel ?? 'Open',
          icon: project.primaryActionIcon ?? Icons.open_in_new_rounded,
          onPressed: () {
            AnalyticsService.instance.logEvent(
              name: 'app_launch',
              projectName: project.name,
              interactionType: 'web_play',
            );
            UrlLauncherHelper.openUrl(project.webUrl!);
          },
          filled: true,
          isDark: isDark,
          isMobile: isMobile,
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    if (buttons.length == 1) {
      return SizedBox(width: double.infinity, child: buttons.first);
    }

    // Two buttons: stack vertically on mobile, side-by-side on desktop
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [buttons[0], const SizedBox(height: 8), buttons[1]],
      );
    } else {
      return Row(
        children: [
          Expanded(child: buttons[0]),
          const SizedBox(width: 16),
          Expanded(child: buttons[1]),
        ],
      );
    }
  }

  Widget _secondaryActions(BuildContext context, Color textSecondary) {
    // Mute the icons heavily so the eye ignores them until explicitly sought out
    final mutedColor = textSecondary.withValues(alpha: 0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _iconButton(
          icon: Icons.share_rounded,
          tooltip: 'Share',
          color: mutedColor,
          onPressed: () {
            AnalyticsService.instance.logEvent(
              name: 'engagement',
              projectName: project.name,
              interactionType: 'share_click',
            );
            ShareHelper.share(
              context,
              title: project.name,
              text: '${project.name} — ${project.description}',
              url:
                  project.webUrl ??
                  'https://github.com/${ProjectData.githubOrg}/${project.repoName}',
            );
          },
        ),
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.feedback_outlined,
          tooltip: 'Feedback',
          color: mutedColor,
          onPressed: () {
            AnalyticsService.instance.logEvent(
              name: 'engagement',
              projectName: project.name,
              interactionType: 'feedback_open',
            );
            FeedbackDialog.show(context, projectName: project.name);
          },
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool filled,
    required bool isDark,
    required bool isMobile,
  }) {
    final padding = EdgeInsets.symmetric(vertical: isMobile ? 12 : 20);
    final borderRadius = BorderRadius.circular(4);

    final Color foregroundColor =
        filled ? Colors.white : AppColors.primaryLight;

    final buttonStyle =
        filled
            ? FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: padding,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            )
            : OutlinedButton.styleFrom(
              side: BorderSide(
                color: foregroundColor.withValues(alpha: 0.5),
                width: 1.5, // Slightly thicker border for premium feel
              ),
              padding: padding,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: foregroundColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
      ],
    );

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: child,
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          hoverColor: AppColors.primary.withValues(alpha: 0.1),
          splashColor: AppColors.primary.withValues(alpha: 0.3),
          highlightColor: AppColors.primary.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }

  void _handleApkDownload(BuildContext context, String url, bool isDark) {
    if (LocalStorageHelper.readBool('skip_apk_disclaimer')) {
      AnalyticsService.instance.logEvent(
        name: 'app_launch',
        projectName: project.name,
        interactionType: 'apk_download',
      );
      UrlLauncherHelper.openUrl(url);
      return;
    }

    bool dontShowAgain = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: AlertDialog(
                backgroundColor:
                    isDark ? AppColors.darkCard : AppColors.lightCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                titlePadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                title: Text(
                  "Quick Heads Up",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                    height: 1.4,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Since you\'re installing this app outside the Play Store, Android will show a safety warning.\n\nThat\'s expected. Tap "Keep" or “Download anyway” to continue.\n\nThe code is public on ',
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap:
                                    () => UrlLauncherHelper.openUrl(
                                      'https://github.com/${ProjectData.githubOrg}/${project.repoName}',
                                    ),
                                child: Text(
                                  'GitHub',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryLight,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(
                            text:
                                ', if you\'d like to see what\'s under the hood.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => dontShowAgain = !dontShowAgain);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: dontShowAgain,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => dontShowAgain = val);
                                  }
                                },
                                activeColor: AppColors.primary,
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color:
                                      isDark
                                          ? AppColors.darkDividerStrong
                                          : AppColors.lightDivider,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Don't show this again",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color:
                                    isDark
                                        ? AppColors.darkTextPrimary.withValues(
                                          alpha: 0.3,
                                        )
                                        : AppColors.lightTextPrimary.withValues(
                                          alpha: 0.4,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'no, thanks',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (dontShowAgain) {
                        LocalStorageHelper.writeBool(
                          'skip_apk_disclaimer',
                          true,
                        );
                      }
                      Navigator.of(context).pop();
                      AnalyticsService.instance.logEvent(
                        name: 'app_launch',
                        projectName: project.name,
                        interactionType: 'apk_download',
                      );
                      UrlLauncherHelper.openUrl(url);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'sounds good',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openLightbox(BuildContext context) {
    final images = [project.screenshotPath, ...(project.galleryImages ?? [])];
    final PageController pageController = PageController();
    int currentIndex = 0;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Image Viewer',
      barrierColor: Colors.black.withValues(alpha: 0.9), // Deep immersion
      transitionDuration: const Duration(milliseconds: 600),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Core Image View Gallery
                  Positioned.fill(
                    child: PageView.builder(
                      controller: pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() => currentIndex = index);
                      },
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final imagePath = images[index];
                        Widget imageWidget = Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                        );

                        // Only the primary image triggers the Hero boundary flight
                        if (index == 0) {
                          imageWidget = Hero(
                            tag: project.screenshotPath,
                            child: imageWidget,
                          );
                        }

                        return GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          behavior:
                              HitTestBehavior
                                  .translucent, // Allow taps on empty space to pop
                          child: InteractiveViewer(
                            maxScale: 4.0,
                            child: Padding(
                              // Perfectly symmetrical bounds on all actionable sides
                              padding: const EdgeInsets.symmetric(
                                horizontal: 80,
                                vertical: 80,
                              ),
                              child: Center(
                                child: GestureDetector(
                                  onTap:
                                      () {}, // Traps taps exactly on the image so they don't pop
                                  child: imageWidget,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Faint Ghost Arrows for Gallery Navigation
                  if (images.length > 1) ...[
                    // Left Arrow
                    if (currentIndex > 0)
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded),
                            iconSize: 28, // Matches Close button size
                            color: AppColors.primaryLight,
                            padding: const EdgeInsets.all(
                              16,
                            ), // Matches Close button hit-box
                            onPressed: () {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                              );
                            },
                          ),
                        ),
                      ),
                    // Right Arrow
                    if (currentIndex < images.length - 1)
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded),
                            iconSize: 28, // Matches Close button size
                            color: AppColors.primaryLight,
                            padding: const EdgeInsets.all(
                              16,
                            ), // Matches Close button hit-box
                            onPressed: () {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                              );
                            },
                          ),
                        ),
                      ),
                  ],

                  // Floating Dismiss Button aligned to bottom
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        iconSize: 28,
                        color: AppColors.primaryLight,
                        padding: const EdgeInsets.all(16),
                        tooltip: 'Close Viewer',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
