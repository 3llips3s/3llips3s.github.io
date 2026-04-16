import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../../config/project_data.dart';
import 'project_card.dart';

/// Section that displays all projects in a leap-frog grid.
///
/// Cards alternate between image-left and image-right layouts.
/// Each card slides up and fades in on viewport entry via [flutter_animate].
class ProjectRegistry extends StatelessWidget {
  const ProjectRegistry({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 64,
        horizontal: isMobile ? 0 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section heading ──
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 48,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[ PROJECT REGISTRY ]',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Things I\'ve built',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ── Project cards ──
          ...List.generate(ProjectData.projects.length, (index) {
            return ProjectCard(
              project: ProjectData.projects[index],
              imageOnLeft: index.isEven,
            )
                .animate()
                .fadeIn(
                  duration: 600.ms,
                  delay: (150 * index).ms,
                )
                .slideY(
                  begin: 0.05,
                  end: 0,
                  duration: 600.ms,
                  delay: (150 * index).ms,
                  curve: Curves.easeOutCubic,
                );
          }),
        ],
      ),
    );
  }
}
