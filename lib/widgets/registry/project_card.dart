import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../../config/project_data.dart';
import '../../utils/share_helper.dart';
import '../../utils/url_launcher_helper.dart';

/// Individual project card with screenshot, description, and action buttons.
///
/// Layout alternates between image-left/text-right and text-left/image-right
/// based on [imageOnLeft]. On mobile (< 768px), this always stacks vertically.
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

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: isMobile
          ? _mobileLayout(context, isDark)
          : _desktopLayout(context, isDark),
    );
  }

  // ── Desktop: side-by-side with alternating order ─────────────
  Widget _desktopLayout(BuildContext context, bool isDark) {
    final screenshot = _screenshot();
    final content = _content(context, isDark);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: imageOnLeft
            ? [Expanded(child: screenshot), Expanded(child: content)]
            : [Expanded(child: content), Expanded(child: screenshot)],
      ),
    );
  }

  // ── Mobile: stacked vertically ───────────────────────────────
  Widget _mobileLayout(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _screenshot(),
        _content(context, isDark),
      ],
    );
  }

  // ── Screenshot ────────────────────────────────────────────────
  Widget _screenshot() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.asset(
        project.screenshotPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.darkSurface,
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              color: AppColors.darkTextSecondary,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  // ── Text content + actions ────────────────────────────────────
  Widget _content(BuildContext context, bool isDark) {
    final Color textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Title ──
          Text(
            project.name,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // ── German description ──
          Text(
            project.descriptionDe,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),

          // ── English translation ──
          Text(
            project.descriptionEn,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textSecondary.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // ── Primary action buttons ──
          _primaryActions(isDark),

          const SizedBox(height: 12),

          // ── Secondary action buttons (share + feedback) ──
          _secondaryActions(isDark, textSecondary),
        ],
      ),
    );
  }

  // ── Primary: Play / Download ──────────────────────────────────
  Widget _primaryActions(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        if (project.webUrl != null)
          _actionButton(
            label: 'Play',
            icon: Icons.play_arrow_rounded,
            onPressed: () => UrlLauncherHelper.openUrl(project.webUrl!),
            filled: true,
            isDark: isDark,
          ),
        if (project.apkUrl != null)
          _actionButton(
            label: 'Download',
            icon: Icons.download_rounded,
            onPressed: () => UrlLauncherHelper.openUrl(project.apkUrl!),
            filled: false,
            isDark: isDark,
          ),
      ],
    );
  }

  // ── Secondary: Share + Feedback ───────────────────────────────
  Widget _secondaryActions(bool isDark, Color textSecondary) {
    return Row(
      mainAxisAlignment:
          imageOnLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        _iconButton(
          icon: Icons.share_rounded,
          tooltip: 'Share',
          color: textSecondary,
          onPressed: () => ShareHelper.share(
            title: project.name,
            text: '${project.name} — ${project.descriptionEn}',
            url: project.webUrl ??
                'https://github.com/${ProjectData.githubOrg}/${project.repoName}',
          ),
        ),
        const SizedBox(width: 4),
        _iconButton(
          icon: Icons.feedback_outlined,
          tooltip: 'Feedback',
          color: textSecondary,
          onPressed: () {
            // Wiredash integration deferred to Phase 5.
          },
        ),
      ],
    );
  }

  // ── Filled / outlined action button ───────────────────────────
  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool filled,
    required bool isDark,
  }) {
    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  // ── Small icon button ─────────────────────────────────────────
  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      tooltip: tooltip,
      splashRadius: 20,
    );
  }
}
