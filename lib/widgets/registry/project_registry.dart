import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../../config/project_data.dart';
import 'project_card.dart';

/// Section that displays all projects in a stacked vertical layout.
///
/// Each card slides up and fades in with a staggered delay via [flutter_animate].
class ProjectRegistry extends StatelessWidget {
  const ProjectRegistry({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;

    return Padding(
      padding: EdgeInsets.only(
        top: 120,
        bottom: 80,
        left: isMobile ? 0 : 24,
        right: isMobile ? 0 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section heading ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'P R O J E C T S',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                    letterSpacing: 2,
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
                  imageOnLeft: index % 2 == 0,
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: (150 * index).ms)
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
