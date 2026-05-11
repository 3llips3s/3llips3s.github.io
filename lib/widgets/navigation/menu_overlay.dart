import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colors.dart';

/// A full-screen menu overlay that displays a list of navigation links.
///
/// Uses a highly performant solid dark background (`Colors.black.withOpacity(0.95)`)
/// to simulate a blurred tint effect without the GPU cost of `ImageFilter.blur`.
class MenuOverlay extends StatelessWidget {
  /// Whether the menu is currently visible.
  final bool isOpen;

  /// The currently active section (e.g., 'Home', 'Projects').
  final String activeSection;

  /// Callback when a section is selected.
  final Function(String) onSectionSelected;

  const MenuOverlay({
    super.key,
    required this.isOpen,
    required this.activeSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    // The canonical names of the sections.
    final List<String> sections = ['Home', 'Projects', 'Stack', 'Contact'];

    // Using IgnorePointer to prevent clicks when the menu is invisible,
    // and AnimatedOpacity to handle the fade in/out of the background.
    return IgnorePointer(
      ignoring: !isOpen,
      child: AnimatedOpacity(
        opacity: isOpen ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: 0.95),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // We build the items unconditionally so flutter_animate can reverse smoothly
                ...sections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sectionName = entry.value;
                  final isActive =
                      activeSection.toLowerCase() == sectionName.toLowerCase();

                  // Format to match the "P R O J E C T S" style
                  final displayTitle = sectionName
                      .toUpperCase()
                      .split('')
                      .join(' ');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => onSectionSelected(sectionName),
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              displayTitle,
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color:
                                    isActive
                                        ? AppColors.primaryLight
                                        : AppColors.darkTextSecondary,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        )
                        .animate(target: isOpen ? 1 : 0)
                        .fadeIn(
                          duration: 600.ms,
                          delay: isOpen ? (200 * index).ms : 0.ms,
                          curve: Curves.easeOut,
                        )
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                          delay: isOpen ? (200 * index).ms : 0.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
