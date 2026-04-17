import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../../config/project_data.dart';
import '../../utils/share_helper.dart';
import '../../utils/url_launcher_helper.dart';

/// Side-by-side project card for portrait screenshots.
///
/// Layout is side-by-side (Row) on both mobile and desktop so the tall
/// screenshot is fully visible without dominating vertical scroll space.
/// Buttons stack vertically on mobile to fit the narrower text column.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.imageOnLeft,
  });

  final ProjectInfo project;
  final bool imageOnLeft;

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
      child: _content(isDark, isMobile),
    );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 48,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          // Master padding explicitly offset (top reduced) because Flutter's internal
          // typographic line-height math forces visual top-heaviness when mathematically symmetric.
          padding: EdgeInsets.only(
            top: isMobile ? 16 : 28, // Finetuned optical center
            bottom: isMobile ? 24 : 32, // Physical mathematical bound
            left: isMobile ? 16 : 32, // Standard lateral bound
            right: isMobile ? 16 : 32, // Standard lateral bound
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

  // ── Screenshot Column ─────────────────────────────────────────────
  Widget _screenshotColumn(BuildContext context, Color textSecondary) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Image scales to column width, establishing natural height
        MouseRegion(
          cursor: SystemMouseCursors.zoomIn,
          child: GestureDetector(
            onTap: () => _openLightbox(context),
            child: Hero(
              tag: project.screenshotPath,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
        const SizedBox(height: 24), // Minimum gap
        // ── Secondary action buttons (share + feedback) ──
        _secondaryActions(context, textSecondary),
      ],
    );
  }

  // ── Text content + actions ────────────────────────────────────────
  Widget _content(bool isDark, bool isMobile) {
    final Color textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Title (Flush Top) ──
        Text(
          project.name,
          style: GoogleFonts.jetBrainsMono(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 16),

        // ── Descriptions (Centered) ──
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.descriptionDe != null)
              Text(
                project.descriptionDe!,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w400,
                  color: textPrimary,
                  height: 1.5,
                ),
              ),
            if (project.descriptionDe != null && project.descriptionEn != null)
              SizedBox(height: isMobile ? 8 : 12),
            if (project.descriptionEn != null)
              Text(
                project.descriptionEn!,
                style: GoogleFonts.inter(
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
        ),

        const SizedBox(height: 16),

        // ── Primary action buttons (Flush Bottom) ──
        _primaryActions(isDark, isMobile),
      ],
    );
  }

  // ── Primary: Download (left/top) / Play (right/bottom) ────────────
  Widget _primaryActions(bool isDark, bool isMobile) {
    final bool hasPlay = project.webUrl != null;
    final bool hasDownload = project.apkUrl != null;

    final List<Widget> buttons = [];

    if (hasDownload) {
      buttons.add(
        _actionButton(
          label: 'Download',
          icon: Icons.android,
          onPressed: () => UrlLauncherHelper.openUrl(project.apkUrl!),
          filled: false,
          isDark: isDark,
          isMobile: isMobile,
        ),
      );
    }

    if (hasPlay) {
      buttons.add(
        _actionButton(
          label: 'Play',
          icon: Icons.play_arrow_rounded,
          onPressed: () => UrlLauncherHelper.openUrl(project.webUrl!),
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

  // ── Secondary: Share + Feedback — centered below image ──────────────
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
          onPressed:
              () => ShareHelper.share(
                context, // Pass context for the fallback snackbar
                title: project.name,
                text: '${project.name} — ${project.descriptionEn}',
                url:
                    project.webUrl ??
                    'https://github.com/${ProjectData.githubOrg}/${project.repoName}',
              ),
        ),
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.feedback_outlined,
          tooltip: 'Feedback',
          color: mutedColor,
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Action Button Builder ──────────────────────────────────────────
  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool filled,
    required bool isDark,
    required bool isMobile,
  }) {
    final padding = EdgeInsets.symmetric(vertical: isMobile ? 12 : 14);

    final buttonStyle =
        filled
            ? FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            )
            : OutlinedButton.styleFrom(
              side: BorderSide(
                color:
                    isDark
                        ? AppColors.darkDividerStrong
                        : AppColors.lightDividerStrong,
              ),
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color:
                filled
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
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

  // ── Small icon button ──────────────────────────────────────────────
  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 22, color: color),
      tooltip: tooltip,
      splashRadius: 20,
    );
  }

  // ── Lightbox Viewer ────────────────────────────────────────────────
  void _openLightbox(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Image Viewer',
      barrierColor: Colors.black.withValues(alpha: 0.95), // Deep immersion
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCirc),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Core Image View (Pan/Zoom capable)
              Center(
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                    child: Hero(
                      tag: project.screenshotPath,
                      child: Image.asset(
                        project.screenshotPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              // Floating Dismiss Button aligned to bottom
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: Text(
                      'Close',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent, // Let barrier act as background
                      side: const BorderSide(color: AppColors.darkDividerStrong),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Pill
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
